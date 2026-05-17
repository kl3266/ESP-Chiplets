module d2d_mux #(
    parameter int unsigned N = 4,
    parameter int unsigned DataWidth = 66,
    parameter bit P_DMA = 1'b0,  // 0 = COH/MISC; 1 = DMA
    parameter bit FIRST_STAGE = 1'b0  // First stage of hierarchy
  )
(
  input  logic clk,
  input  logic rst,
  input  logic [DataWidth-1:0] noc_data_in [N-1:0],
  input  logic noc_data_void_in [N-1:0],
  output logic noc_stop_out [N-1:0],
  output logic [DataWidth-1:0] data_out,
  output logic data_void_out,
  input  logic stop_in
);

localparam int ReservedWidth =
    DataWidth - $bits(noc::preamble_t) - 2*$bits(noc::xy_t) - $bits(noc::message_t) - $bits(noc::tile_t) - $bits(noc::plane_t) - $bits(noc::routing_lock_t) - 2*$bits(noc::chip_xy_t) - $bits(noc::direction_t);

typedef struct packed {
  noc::xy_t source;
  noc::xy_t destination;
  noc::message_t message;
  noc::tile_t tile;
  noc::plane_t plane;
  noc::routing_lock_t routing_lock;
  noc::chip_xy_t source_chip;
  noc::chip_xy_t destination_chip;
  logic [ReservedWidth-1:0] reserved;
} packet_info_t;

typedef struct packed {
  noc::preamble_t preamble;
  packet_info_t info;
  noc::direction_t routing;
} header_t;

typedef logic [DataWidth-1:0] payload_t;
typedef union packed {
  header_t header;
  payload_t flit;
} flit_t;

typedef enum logic {
  kHeadFlit = 1'b0,
  kPayloadFlits = 1'b1
} state_t;

state_t state, new_state;
localparam int unsigned PlaneBase = P_DMA ? 4 : 0;


logic in_unvalid_flit [N-1:0];
logic out_unvalid_flit;
logic forwarding_head, forwarding_tail;
logic grant_valid;
logic no_backpressure, forwarding_in_progress;
logic [N-1:0] saved_routing_configuration, routing_configuration, read_configuration, grant;
logic [N-1:0] request;
logic [N-1:0] in_valid_head;
logic selected_tail;
flit_t flat_data_in [N-1:0];
flit_t data_out_crossbar;
logic [3:0] request_rtpe, grant_rtpe;

genvar g_i;

generate
  if (FIRST_STAGE) begin  // need add planes
    for (g_i = 0; g_i < N; g_i++) begin
      always_comb begin
        flat_data_in[g_i] = noc_data_in[g_i];
        if (!in_unvalid_flit[g_i] && noc_data_in[g_i][DataWidth-1]) begin
          flat_data_in[g_i].header.info.plane = noc::plane_t'(g_i + PlaneBase);
        end
      end
    end
  end else begin
    for (g_i = 0; g_i < N; g_i++) begin
      assign flat_data_in[g_i] = noc_data_in[g_i];
    end
  end
endgenerate

for (g_i = 0; g_i < N; g_i++) begin
  assign in_unvalid_flit[g_i] = noc_data_void_in[g_i];
  assign in_valid_head[g_i] = flat_data_in[g_i].header.preamble.head && !in_unvalid_flit[g_i];
  assign request[g_i] = in_valid_head[g_i];
  assign noc_stop_out[g_i] = !noc_data_void_in[g_i] && !read_configuration[g_i];
end

always_comb begin
  new_state = state;
  routing_configuration = '0;
  read_configuration = '0;
  forwarding_in_progress = 1'b0;
  data_out_crossbar = '0;
  out_unvalid_flit = 1'b1;
  selected_tail = 1'b0;

  unique case (state)
    kHeadFlit : begin
      if (grant_valid) begin
        routing_configuration = grant;
        for (int i = 0; i < N; i++) begin
          if (grant[i]) begin
            out_unvalid_flit = in_unvalid_flit[i];
            data_out_crossbar = flat_data_in[i];
            selected_tail = flat_data_in[i].header.preamble.tail;
          end
        end
        if (no_backpressure) begin
          read_configuration = grant;
          forwarding_in_progress = 1'b1;
          if (!selected_tail) begin
            new_state = kPayloadFlits;
          end
        end
      end
    end
    kPayloadFlits : begin
      routing_configuration = saved_routing_configuration;
      for (int i = 0; i < N; i++) begin
        if (saved_routing_configuration[i]) begin
          out_unvalid_flit = in_unvalid_flit[i];
          data_out_crossbar = flat_data_in[i];
          selected_tail = flat_data_in[i].header.preamble.tail;
        end
      end
      if (no_backpressure) begin
        read_configuration = saved_routing_configuration;
      end
      forwarding_in_progress = 1'b1;
      if (selected_tail && !out_unvalid_flit && no_backpressure) begin
        new_state = kHeadFlit;
      end
    end
    default : begin
    end
  endcase
end

always_ff @(posedge clk) begin
  if (rst) begin
    saved_routing_configuration <= '0;
    state <= kHeadFlit;
  end else begin
    state <= new_state;
    if (forwarding_in_progress && no_backpressure) begin
      saved_routing_configuration <= routing_configuration;
    end
  end
end

assign forwarding_head = grant_valid && !out_unvalid_flit && no_backpressure;
assign forwarding_tail = selected_tail & ~out_unvalid_flit & no_backpressure;
assign no_backpressure = !stop_in;
assign data_void_out = out_unvalid_flit;
assign data_out = data_out_crossbar.flit;

generate
  if (N == 2) begin
    arbiter_2 arbiter_i (
      .clk(clk),
      .rst(rst),
      .request(request),
      .forwarding_head(forwarding_head),
      .forwarding_tail(forwarding_tail),
      .grant(grant),
      .grant_valid(grant_valid)
    );
  end else if ((N == 3) || (N == 4)) begin
    always_comb begin
      request_rtpe = '0;
      request_rtpe[N-1:0] = request;
    end
    router_arbiter_rtpe arbiter_rtpe_i (
      .clk(clk),
      .rst(rst),
      .request(request_rtpe),
      .forwarding_head(forwarding_head),
      .forwarding_tail(forwarding_tail),
      .grant(grant_rtpe),
      .grant_valid(grant_valid)
    );
    assign grant = grant_rtpe[N-1:0];
  end else begin
    initial begin
      $error("d2d_mux only supports N=2, N=3, or N=4");
    end
  end
endgenerate
endmodule
