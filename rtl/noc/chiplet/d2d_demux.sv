module d2d_demux #(
    parameter int unsigned N = 4,
    parameter int unsigned DataWidth = 66
  )
(
  input  logic clk,
  input  logic rst,
  input  logic [DataWidth-1:0] data_in,
  input  logic data_void_in,
  output logic stop_out,
  input  logic [N-1:0] route_in,
  output logic [DataWidth-1:0] noc_data_out [N-1:0],
  output logic noc_data_void_out [N-1:0],
  input  logic noc_stop_in [N-1:0]
);

typedef enum logic {
  kHeadFlit = 1'b0,
  kPayloadFlits = 1'b1
} state_t;

state_t state, new_state;

logic no_backpressure;
logic forwarding_in_progress;
logic forwarding_tail;
logic route_valid;
logic selected_tail;
logic [N-1:0] active_routing_configuration;
logic [N-1:0] routing_configuration, saved_routing_configuration, read_configuration;
logic [N-1:0] noc_stop_in_flat;

assign route_valid = |route_in;
assign selected_tail = data_in[DataWidth - 2];
assign active_routing_configuration = (state == kHeadFlit) ? route_in : saved_routing_configuration;

always_comb begin
  for (int i = 0; i < N; i++) begin
    noc_stop_in_flat[i] = noc_stop_in[i];
  end
end

always_comb begin
  routing_configuration = '0;
  read_configuration = '0;
  new_state = state;
  forwarding_in_progress = 1'b0;

  unique case (state)
    kHeadFlit: begin
      if (!data_void_in && route_valid) begin
        routing_configuration = route_in;
        if (no_backpressure) begin
          read_configuration = route_in;
          forwarding_in_progress = 1'b1;
          if (!selected_tail) begin
            new_state = kPayloadFlits;
          end
        end
      end
    end
    kPayloadFlits: begin
      routing_configuration = saved_routing_configuration;
      forwarding_in_progress = 1'b1;
      if (no_backpressure) begin
        read_configuration = saved_routing_configuration;
        if (forwarding_tail) begin
          new_state = kHeadFlit;
        end
      end
    end
    default: begin
    end
  endcase
end

assign no_backpressure = !(|(active_routing_configuration & noc_stop_in_flat));

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

assign forwarding_tail = selected_tail && !data_void_in && no_backpressure;
assign stop_out = !data_void_in && !(|read_configuration);

generate
  for (genvar g_i = 0; g_i < N; g_i++) begin : gen_demux_outputs
    assign noc_data_out[g_i] = read_configuration[g_i] ? data_in : '0;
    assign noc_data_void_out[g_i] = read_configuration[g_i] ? data_void_in : 1'b1;
  end
endgenerate

initial begin
  if ((N < 2) || (N > 4)) begin
    $error("d2d_demux only supports N=2, N=3, or N=4");
  end
end

endmodule
