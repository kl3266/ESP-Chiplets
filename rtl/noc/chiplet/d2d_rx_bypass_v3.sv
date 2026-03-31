module d2d_rx #(
  parameter logic [1:0] d2d_position, // 0: N, 1: S, 2: W, 3: E
  parameter noc::chip_xy_t chip_coordinates,
  parameter logic [3:0] max_dim,
  parameter int unsigned RXCHANNELS   = 4,
  parameter int unsigned TILES        = 3,
  parameter bit FlowControl = 1'b0,
  parameter int unsigned CHDataWidth = 66,
  parameter int unsigned COHDataWidth = 66,
  parameter int unsigned MISCDataWidth = 66,
  parameter int unsigned DMADataWidth = 130
)(
  input   logic clk,
  input   logic rst,
  input   logic d2d_rst,

  // D2D Tx --> D2D Rx
  input   logic                       d2d_clk_in,
  input   logic [CHDataWidth-1:0]     d2d_rcv_data_in [RXCHANNELS-1:0],
  input   logic [RXCHANNELS-1:0]      d2d_valid_in,
  output  logic                       d2d_link_ready,

  // Bypass Lane
  output  logic [CHDataWidth-1:0]     bypass_data_out,
  output  logic                       bypass_data_void_out,
  input   logic                       bypass_stop_in,

  // D2D Rx --> D2D Tx
  output  logic [RXCHANNELS-1:0]      d2d_credit_out,

  // D2D    --> NoC
  output  logic [COHDataWidth-1:0]    noc1_data_out [TILES-1:0],
  output  logic [COHDataWidth-1:0]    noc2_data_out [TILES-1:0],
  output  logic [COHDataWidth-1:0]    noc3_data_out [TILES-1:0],
  output  logic [DMADataWidth-1:0]    noc4_data_out [TILES-1:0],
  output  logic [MISCDataWidth-1:0]   noc5_data_out [TILES-1:0],
  output  logic [DMADataWidth-1:0]    noc6_data_out [TILES-1:0],
  output  logic [TILES-1:0]           noc1_data_void_out,
  output  logic [TILES-1:0]           noc2_data_void_out,
  output  logic [TILES-1:0]           noc3_data_void_out,
  output  logic [TILES-1:0]           noc4_data_void_out,
  output  logic [TILES-1:0]           noc5_data_void_out,
  output  logic [TILES-1:0]           noc6_data_void_out,

  // NoC    --> D2D
  input  logic [TILES-1:0]            noc1_stop_in,
  input  logic [TILES-1:0]            noc2_stop_in,
  input  logic [TILES-1:0]            noc3_stop_in,
  input  logic [TILES-1:0]            noc4_stop_in,
  input  logic [TILES-1:0]            noc5_stop_in,
  input  logic [TILES-1:0]            noc6_stop_in
);

  localparam bit FifoBypassEnable = FlowControl == 1'b0;

  parameter int unsigned D2D_QUEUE_DEPTH = 8; 
  parameter int unsigned CreditWidth = $clog2(2*D2D_QUEUE_DEPTH + 1);
  localparam int unsigned D2D_FIFO_DEPTH = 4*D2D_QUEUE_DEPTH;
  parameter int unsigned PLANES = 6;
  parameter int unsigned TxP = TILES*PLANES + 1;
  parameter int unsigned BYPASS_IDX = TxP - 1;
  parameter int unsigned OUTW = $clog2(TxP);
  parameter int unsigned W   = RXCHANNELS;
  parameter int unsigned NOC_QUEUE_DEPTH = 4;
  
  typedef logic [3:0] tile_array_t [TxP-1:0];
  typedef logic [2:0] plane_array_t [TxP-1:0];
  typedef logic [3:0] input_tile_array_t [W-1:0];
  typedef logic [2:0] input_plane_array_t [W-1:0];

  function automatic tile_array_t generate_tile();
    tile_array_t result;
    for (int i = 0; i < TxP-1 ; i++) begin
      result[i] = i % TILES;
    end
    result[BYPASS_IDX] = '0;
    return result;
  endfunction

  function automatic plane_array_t generate_plane();
    plane_array_t result;
    for (int i = 0; i < TxP-1; i++) begin
      result[i] = i / TILES;
    end
    result[BYPASS_IDX] = '0;
    return result;
  endfunction

  localparam tile_array_t tile = generate_tile();
  localparam plane_array_t plane = generate_plane();

  input_tile_array_t  input_tile, saved_input_tile;
  input_plane_array_t input_plane, saved_input_plane;

  // Localparam to compute reserved width
  localparam int COHReservedWidth =
    COHDataWidth - $bits(noc::preamble_t) - 2*$bits(noc::xy_t) - $bits(noc::message_t) - $bits(noc::tile_t) - $bits(noc::plane_t) - $bits(noc::routing_lock_t) - 2*$bits(noc::chip_xy_t) - $bits(noc::direction_t);
  localparam int MISCReservedWidth =
    MISCDataWidth - $bits(noc::preamble_t) - 2*$bits(noc::xy_t) - $bits(noc::message_t) - $bits(noc::tile_t) - $bits(noc::plane_t) - $bits(noc::routing_lock_t) - 2*$bits(noc::chip_xy_t) - $bits(noc::direction_t);
  localparam int DMAReservedWidth =
    DMADataWidth - $bits(noc::preamble_t) - 2*$bits(noc::xy_t) - $bits(noc::message_t) - $bits(noc::tile_t) - $bits(noc::plane_t) - $bits(noc::routing_lock_t) - 2*$bits(noc::chip_xy_t) - $bits(noc::direction_t);

  // Structs and typedefs based on DataWidth and PortWidth
  typedef struct packed {
    noc::xy_t source;
    noc::xy_t destination;
    noc::message_t message;
    noc::tile_t tile;
    noc::plane_t plane;
    noc::routing_lock_t routing_lock;
    noc::chip_xy_t source_chip;
    noc::chip_xy_t destination_chip;
    logic [COHReservedWidth-1:0] reserved;
  } coh_packet_info_t;

  typedef struct packed {
    noc::xy_t source;
    noc::xy_t destination;
    noc::message_t message;
    noc::tile_t tile;
    noc::plane_t plane;
    noc::routing_lock_t routing_lock;
    noc::chip_xy_t source_chip;
    noc::chip_xy_t destination_chip;
    logic [MISCReservedWidth-1:0] reserved;
  } misc_packet_info_t;

  typedef struct packed {
    noc::xy_t source;
    noc::xy_t destination;
    noc::message_t message;
    noc::tile_t tile;
    noc::plane_t plane;
    noc::routing_lock_t routing_lock;
    noc::chip_xy_t source_chip;
    noc::chip_xy_t destination_chip;
    logic [DMAReservedWidth-1:0] reserved;
  } dma_packet_info_t;

  typedef struct packed {
    noc::preamble_t preamble;
    coh_packet_info_t info;
    noc::direction_t routing;
  } coh_header_t;

  typedef struct packed {
    noc::preamble_t preamble;
    misc_packet_info_t info;
    noc::direction_t routing;
  } misc_header_t;

  typedef struct packed {
    noc::preamble_t preamble;
    dma_packet_info_t info;
    noc::direction_t routing;
  } dma_header_t;

  typedef logic [COHDataWidth-1:0]  coh_payload_t;
  typedef logic [MISCDataWidth-1:0] misc_payload_t;
  typedef logic [DMADataWidth-1:0]  dma_payload_t;

  typedef union packed {
    coh_header_t header;
    coh_payload_t flit;
  } coh_flit_t;

  typedef union packed {
    misc_header_t header;
    misc_payload_t flit;
  } misc_flit_t;

  typedef union packed {
    dma_header_t header;
    dma_payload_t flit;
  } dma_flit_t;

  logic rst_clk;
  logic rst_d2d;
  logic fifo_rst;
  logic rstn_fifo_clk;
  logic rstn_fifo_d2d;
  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic fifo_rst_clk_sync_ff1;
  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic fifo_rst_clk_sync_ff2;
  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic fifo_rst_d2d_sync_ff1;
  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic fifo_rst_d2d_sync_ff2;

  // Asynchronous FIFO
  coh_flit_t  d2d_rcv_data_out  [W-1:0];
  logic d2d_rcv_wrreq   [W-1:0];
  logic d2d_rcv_full    [W-1:0];
  logic d2d_rcv_empty   [W-1:0];
  logic d2d_rcv_rdreq   [W-1:0];
  logic in_unvalid_flit [W-1:0];
  logic in_valid_head   [W-1:0];

  typedef enum logic[1:0] {
    state_reset,
    state_ack,
    state_train,
    state_ready
  } rx_state_t;
  rx_state_t rx_state [W-1:0];
  localparam int unsigned STARTUP_PULSES = 4;
  localparam int unsigned StartupCountWidth = $clog2(STARTUP_PULSES + 1);
  localparam int unsigned AckEventCountWidth = 8;
  logic [StartupCountWidth-1:0] startup_credit_cnt [W-1:0];
  logic d2d_ack [W-1:0];
  logic d2d_pulse [W-1:0];
//  logic [AckEventCountWidth-1:0] d2d_ack_evt_bin [W-1:0];
//  logic [AckEventCountWidth-1:0] d2d_ack_evt_gray [W-1:0];
//  logic [AckEventCountWidth-1:0] d2d_ack_evt_gray_src_reg [W-1:0];
//  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic [AckEventCountWidth-1:0] d2d_ack_evt_gray_meta [W-1:0];
//  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic [AckEventCountWidth-1:0] d2d_ack_evt_gray_sync [W-1:0];
//  logic [AckEventCountWidth-1:0] d2d_ack_evt_bin_seen [W-1:0];
  logic [AckEventCountWidth:0] credit_pending [W-1:0];

//  function automatic logic [AckEventCountWidth-1:0] bin2gray (
//    input logic [AckEventCountWidth-1:0] bin
//  );
//    return (bin >> 1) ^ bin;
//  endfunction
//
//  function automatic logic [AckEventCountWidth-1:0] gray2bin (
//    input logic [AckEventCountWidth-1:0] gray
//  );
//    logic [AckEventCountWidth-1:0] bin;
//    bin[AckEventCountWidth-1] = gray[AckEventCountWidth-1];
//    for (int k = AckEventCountWidth-2; k >= 0; k--) begin
//      bin[k] = bin[k+1] ^ gray[k];
//    end
//    return bin;
//  endfunction

  coh_flit_t  data_out_crossbar [TxP-1:0];
  coh_flit_t  coh_last_flit [3*TILES-1:0];
  misc_flit_t misc_last_flit  [TILES-1:0];
  dma_flit_t  dma_last_flit [2*TILES-1:0];
  coh_flit_t  bypass_last_flit;
  logic no_backpressure [TxP-1:0];
  logic out_unvalid_flit  [TxP-1:0];
//  logic forwarding_head [TxP-1:0];
  logic forwarding_tail [TxP-1:0];

//  typedef logic [W-1:0] op_ip_arr_t [TxP-1:0];
//  op_ip_arr_t rd_fifo;

  typedef logic [CreditWidth-1:0] credits_t [TxP-1:0];
  credits_t noc_credits;

  logic [$clog2(W)-1:0] routing_table [TxP-1:0];
  logic [$clog2(W)-1:0] saved_routing_table [TxP-1:0];
//  logic [TxP-1:0] routing_table_invalidate;

  logic credit_toggle_clk [W-1:0];
  logic routing_table_valid [TxP-1:0];
  logic saved_routing_table_valid [TxP-1:0];

  logic [W-1:0] request_input;
  logic channel_switch  [W-1:0];
  logic [TxP-1:0] request_output;
  logic output_switch   [TxP-1:0];
  logic grant_valid_input;
  logic [$clog2(W)-1:0] grant_index_i;
//  logic [$clog2(TILES)-1:0] grant_index_o [5:0];
//  logic grant_valid_output  [5:0];

  logic [OUTW-1:0] target_out [W-1:0];
  logic            target_ok  [W-1:0];
//  logic [OUTW-1:0] saved_in_to_out_map [W-1:0];
  logic [OUTW-1:0] in_to_out_map [W-1:0];
  logic            in_active     [W-1:0];

  logic insert_lookahead_routing  [TxP-1:0];
  noc::direction_t next_hop_routing;
  noc::direction_t saved_next_hop_routing [2*TILES-1:0];
  noc::routing_lock_t next_routing_lock;
//  noc::tile_t assigned_tile;

  parameter int unsigned serW = $clog2((DMADataWidth-2)/64);  // bitwidth necessary for serializer counter
  logic [serW-1:0] beats [2*TILES-1:0];

  logic is_bypass_traffic [W-1:0];

  localparam int SEG = CHDataWidth - 2;

  // Treat the NoC-side and D2D-side reset inputs as one flush event, then
  // deassert it separately in each clock domain.
  assign fifo_rst = rst | d2d_rst;

  always_ff @(posedge clk or posedge fifo_rst) begin
    if (fifo_rst) begin
      fifo_rst_clk_sync_ff1 <= 1'b1;
      fifo_rst_clk_sync_ff2 <= 1'b1;
    end else begin
      fifo_rst_clk_sync_ff1 <= 1'b0;
      fifo_rst_clk_sync_ff2 <= fifo_rst_clk_sync_ff1;
    end
  end

  always_ff @(posedge d2d_clk_in or posedge fifo_rst) begin
    if (fifo_rst) begin
      fifo_rst_d2d_sync_ff1 <= 1'b1;
      fifo_rst_d2d_sync_ff2 <= 1'b1;
    end else begin
      fifo_rst_d2d_sync_ff1 <= 1'b0;
      fifo_rst_d2d_sync_ff2 <= fifo_rst_d2d_sync_ff1;
    end
  end

  assign rst_clk = fifo_rst_clk_sync_ff2;
  assign rst_d2d = fifo_rst_d2d_sync_ff2;
  assign rstn_fifo_clk = !rst_clk;
  assign rstn_fifo_d2d = !rst_d2d;

  genvar g_i;
  generate
  for (g_i=0; g_i < W; g_i++) begin
    always_ff @(posedge d2d_clk_in) begin
      if (rst_d2d) begin
        rx_state[g_i] <= state_reset;
        startup_credit_cnt[g_i] <= '0;
        d2d_ack[g_i] <= 1'b0;
      end else begin
        if (rx_state[g_i] == state_reset) begin
          if (d2d_valid_in[g_i]) begin
            rx_state[g_i] <= state_ack;
          end
        end
        if (rx_state[g_i] == state_ack) begin
          if (startup_credit_cnt[g_i] == STARTUP_PULSES-1) begin
            d2d_ack[g_i] <= 1'b0;
            if (!d2d_valid_in[g_i]) begin
              rx_state[g_i] <= state_ready;
              startup_credit_cnt[g_i] <= '0;
            end
          end else begin
            d2d_ack[g_i] <= 1'b1;
            startup_credit_cnt[g_i] <= startup_credit_cnt[g_i] + 1'b1;
          end
        end
      end
    end

    cdc_gray_pulse #(
      .N ($clog2(D2D_FIFO_DEPTH))
    ) cdc_gray_pulse_i (
      .src_clk(d2d_clk_in),
      .dst_clk(clk),
      .src_rstn(rstn_fifo_d2d),
      .dst_rstn(rstn_fifo_clk),
      .src_pulse(d2d_ack[g_i]),
      .dst_pulse(d2d_pulse[g_i])
    );

    inferred_async_fifo #(
      .g_data_width(CHDataWidth),
      .g_size(D2D_FIFO_DEPTH)
    ) u_async_fifo (
      .rst_wr_n_i(rstn_fifo_d2d),
      .clk_wr_i(d2d_clk_in),
      .we_i(d2d_rcv_wrreq[g_i]),
      .d_i(d2d_rcv_data_in[g_i]),
      .wr_full_o(d2d_rcv_full[g_i]),
      .rst_rd_n_i(rstn_fifo_clk),
      .clk_rd_i(clk),
      .rd_i(d2d_rcv_rdreq[g_i]),
      .q_o(d2d_rcv_data_out[g_i]),
      .rd_empty_o(d2d_rcv_empty[g_i])
    );
    
    assign d2d_rcv_wrreq[g_i] = d2d_valid_in[g_i] && (rx_state[g_i] == state_ready);
    assign in_unvalid_flit[g_i] = d2d_rcv_empty[g_i];
    assign in_valid_head[g_i] = d2d_rcv_data_out[g_i].header.preamble.head & ~in_unvalid_flit[g_i];
    assign is_bypass_traffic[g_i] = chip_coordinates != d2d_rcv_data_out[g_i].header.info.destination_chip;
    assign input_tile[g_i] = in_valid_head[g_i] ? d2d_rcv_data_out[g_i].header.info.tile : saved_input_tile[g_i];
    assign input_plane[g_i] = in_valid_head[g_i] ? d2d_rcv_data_out[g_i].header.info.plane : saved_input_plane[g_i];

    logic rdreq_credit;

    assign rdreq_credit = d2d_rcv_rdreq[g_i] && ~in_unvalid_flit[g_i];

    always_ff @(posedge clk) begin
      if (rst_clk) begin
        saved_input_tile[g_i] <= '0;
        saved_input_plane[g_i] <= '0;
      end else begin
        if (in_valid_head[g_i]) begin
          saved_input_tile[g_i] <= d2d_rcv_data_out[g_i].header.info.tile;
          saved_input_plane[g_i] <= d2d_rcv_data_out[g_i].header.info.plane;
        end
      end
    end

    assign d2d_credit_out[g_i] = rdreq_credit || d2d_pulse[g_i];  // modify cdc_gray_pulse if need to mix d2d_ack with actual credits

    noc::tile_t dst_tile;
    noc::plane_t dst_plane;

    assign dst_tile = (d2d_position < 2) ? d2d_rcv_data_out[g_i].header.info.destination.x : // N/S
        d2d_rcv_data_out[g_i].header.info.destination.y; // E/W
    assign dst_plane = d2d_rcv_data_out[g_i].header.info.plane;

    always_comb begin
      target_out[g_i] = '0;
      target_ok[g_i] = 1'b0;

      if (in_valid_head[g_i]) begin
        if (is_bypass_traffic[g_i]) begin // bypass traffic
          target_out[g_i] = OUTW'(BYPASS_IDX);  // target output = bypass_idx (bypass lane)
          target_ok[g_i]  = channel_switch[g_i] && request_output[BYPASS_IDX];  // target good to link
        end else begin  // local traffic
          automatic int t_idx = input_plane[g_i] * TILES + dst_tile;
          if (t_idx < BYPASS_IDX) begin // non-bypass
            target_out[g_i] = OUTW'(t_idx);
            target_ok[g_i]  = channel_switch[g_i] && request_output[t_idx];  // target good to link
          end
        end
      end
    end
    assign request_input[g_i] = target_ok[g_i];

    always_comb begin
      d2d_rcv_rdreq[g_i] = 1'b0;
      if (in_active[g_i]) begin // after first cycle
        d2d_rcv_rdreq[g_i] = no_backpressure[in_to_out_map[g_i]];
      end else if (grant_valid_input && (grant_index_i == g_i)) begin // For the first cycle combinational path. target_ok has no_backpressure baked in
        d2d_rcv_rdreq[g_i] = 1'b1;
      end else begin
        d2d_rcv_rdreq[g_i] = 1'b0;
      end
    end 
  end // for
  
  if (W == 2) begin
    d2d_arbiter_2 #(
      .CHANNELS(W)
    ) d2d_arbiter_i (
      .clk(clk),
      .rst(rst_clk),
      .enable(1'b1),
      .request(request_input),
      .grant_valid_other_arbiter(1'b1),
      .grant_index(grant_index_i),
      .grant_valid(grant_valid_input)
    );
  end else if (W <= 4) begin
    d2d_arbiter_4 #(
      .CHANNELS(W)
    ) d2d_arbiter_i (
      .clk(clk),
      .rst(rst_clk),
      .enable(1'b1),
      .request(request_input),
      .grant_valid_other_arbiter(1'b1),
      .grant_index(grant_index_i),
      .grant_valid(grant_valid_input)
    );
  end else begin
    d2d_arbiter_9 #(
      .CHANNELS(W)
    ) d2d_arbiter_i (
      .clk(clk),
      .rst(rst_clk),
      .enable(1'b1),
      .request(request_input),
      .grant_valid_other_arbiter(1'b1),
      .grant_index(grant_index_i),
      .grant_valid(grant_valid_input)
    );
  end

  // rotating priority arbiter for each plane to keep track of
  // round-robin/rotating priority amongst tiles in each plane
//  for (g_i = 0; g_i < 6; g_i++) begin
//    if (TILES == 2) begin
//      d2d_arbiter_2 #(
//        .CHANNELS(TILES)
//      ) d2d_arbiter_plane_g_i (
//        .clk(clk),
//        .rst(rst),
//        .enable(|request_input),
//        .request(request_output[TILES*(g_i+1)-1:TILES*g_i]),
//        .grant_valid_other_arbiter(grant_valid_input),
//        .grant_index(grant_index_o[g_i]),  // granted tile number in plane g_i
//        .grant_valid(grant_valid_output[g_i])
//      );
//    end else if (TILES <= 4) begin
//      d2d_arbiter_4 #(
//        .CHANNELS(TILES)
//      ) d2d_arbiter_plane_g_i (
//        .clk(clk),
//        .rst(rst),
//        .enable(|request_input),
//        .request(request_output[TILES*(g_i+1)-1:TILES*g_i]),
//        .grant_valid_other_arbiter(grant_valid_input),
//        .grant_index(grant_index_o[g_i]),  // granted tile number in plane g_i
//        .grant_valid(grant_valid_output[g_i])
//      );
//    end else begin
//      d2d_arbiter_9 #(
//        .CHANNELS(TILES)
//      ) d2d_arbiter_plane_g_i (
//        .clk(clk),
//        .rst(rst),
//        .enable(|request_input),
//        .request(request_output[TILES*(g_i+1)-1:TILES*g_i]),
//        .grant_valid_other_arbiter(grant_valid_input),
//        .grant_index(grant_index_o[g_i]),  // granted tile number in plane g_i
//        .grant_valid(grant_valid_output[g_i])
//      );
//    end
//      //assign grant_valid_plane[g_i] = grant_valid_input & (input_plane[grant_index_i] == g_i[2:0]) & grant_valid_output[g_i]; // plane g_i granted
//  end
  endgenerate

  generate
  // Planes 1-3
  for (g_i = 0; g_i < 3*TILES; g_i++) begin
    if (g_i < TILES) begin
      assign no_backpressure[g_i] = FifoBypassEnable ? ~noc1_stop_in[g_i] : noc_credits[g_i] != 0;
    end else if (g_i < 2*TILES) begin
      assign no_backpressure[g_i] = FifoBypassEnable ? ~noc2_stop_in[g_i-TILES] : noc_credits[g_i] != 0;
    end else begin
      assign no_backpressure[g_i] = FifoBypassEnable ? ~noc3_stop_in[g_i-2*TILES] : noc_credits[g_i] != 0;
    end
    assign request_output[g_i] = output_switch[g_i] & no_backpressure[g_i];
    assign forwarding_tail[g_i] = data_out_crossbar[g_i].header.preamble.tail & ~out_unvalid_flit[g_i] & no_backpressure[g_i];
//    assign forwarding_head[g_i] = data_out_crossbar[g_i].header.preamble.head & ~out_unvalid_flit[g_i] & no_backpressure[g_i];

    // Crossbar
    assign data_out_crossbar[g_i] = routing_table_valid[g_i] ? d2d_rcv_data_out[routing_table[g_i]] : '0;
    assign out_unvalid_flit[g_i] = in_unvalid_flit[routing_table[g_i]];

//    always_comb begin
//      rd_fifo[g_i] = '0;
//      if (routing_table_valid[g_i]) begin
//        rd_fifo[g_i][routing_table[g_i]] = no_backpressure[g_i];
//      end
//    end

    if (FifoBypassEnable) begin
      always_ff @(posedge clk) begin
        if (rst_clk) begin
          if (g_i < TILES) begin
            noc1_data_void_out[g_i] <= 1'b1;
          end else if (g_i < 2*TILES) begin
            noc2_data_void_out[g_i-TILES] <= 1'b1;
          end else begin
            noc3_data_void_out[g_i-2*TILES] <= 1'b1;
          end
        end else begin
          if ((!routing_table_valid[g_i]) && no_backpressure[g_i]) begin
            if (g_i < TILES) begin
              noc1_data_void_out[g_i] <= 1'b1;
            end else if (g_i < 2*TILES) begin
              noc2_data_void_out[g_i-TILES] <= 1'b1;
            end else begin
              noc3_data_void_out[g_i-2*TILES] <= 1'b1;
            end
          end else if (no_backpressure[g_i]) begin
            if (g_i < TILES) begin
              noc1_data_void_out[g_i] <= out_unvalid_flit[g_i];
            end else if (g_i < 2*TILES) begin
              noc2_data_void_out[g_i-TILES] <= out_unvalid_flit[g_i];
            end else begin
              noc3_data_void_out[g_i-2*TILES] <= out_unvalid_flit[g_i];
            end
          end
        end
      end
      assign noc_credits[g_i] = '0;
    end else begin
      if (g_i < TILES) begin
        assign noc1_data_void_out[g_i] = (routing_table_valid[g_i] & no_backpressure[g_i]) ? out_unvalid_flit[g_i] : 1'b1;
      end else if (g_i < 2*TILES) begin
        assign noc2_data_void_out[g_i-TILES] = (routing_table_valid[g_i] & no_backpressure[g_i]) ? out_unvalid_flit[g_i] : 1'b1;
      end else begin
        assign noc3_data_void_out[g_i-2*TILES] = (routing_table_valid[g_i] & no_backpressure[g_i]) ? out_unvalid_flit[g_i] : 1'b1;
      end
      
      always_ff @(posedge clk) begin
        if (rst_clk) begin
          noc_credits[g_i] <= NOC_QUEUE_DEPTH;
        end else begin
          if (g_i < TILES) begin
            if (!noc1_data_void_out[g_i]) begin
              noc_credits[g_i] <= noc_credits[g_i] - noc1_stop_in[g_i];
            end else begin
              noc_credits[g_i] <= noc_credits[g_i] + ~noc1_stop_in[g_i];
            end
          end else if (g_i < 2*TILES) begin
            if (!noc2_data_void_out[g_i-TILES]) begin
              noc_credits[g_i] <= noc_credits[g_i] - noc2_stop_in[g_i-TILES];
            end else begin
              noc_credits[g_i] <= noc_credits[g_i] + ~noc2_stop_in[g_i-TILES];
            end
          end else begin
            if (!noc3_data_void_out[g_i-2*TILES]) begin
              noc_credits[g_i] <= noc_credits[g_i] - noc3_stop_in[g_i-2*TILES];
            end else begin
              noc_credits[g_i] <= noc_credits[g_i] + ~noc3_stop_in[g_i-2*TILES];
            end
          end
        end
      end
    end

    always_ff @(posedge clk) begin
      if (rst_clk) begin
        coh_last_flit[g_i] <= '0;
        insert_lookahead_routing[g_i] <= 1'b1;
      end else begin
        if (FifoBypassEnable) begin
          if (no_backpressure[g_i] & routing_table_valid[g_i] & ~out_unvalid_flit[g_i]) begin
            if (insert_lookahead_routing[g_i]) begin
              coh_last_flit[g_i] <= {data_out_crossbar[g_i].flit[COHDataWidth-1:COHDataWidth-30], next_routing_lock, data_out_crossbar[g_i].flit[COHDataWidth-30-$bits(noc::routing_lock_t)-1:5], next_hop_routing};
              if (!data_out_crossbar[g_i].header.preamble.tail) begin
                insert_lookahead_routing[g_i] <= 1'b0;
              end
            end else begin
              coh_last_flit[g_i] <= data_out_crossbar[g_i];
              if (data_out_crossbar[g_i].header.preamble.tail) begin
                insert_lookahead_routing[g_i] <= 1'b1;
              end
            end
          end
        end else begin
          if (g_i < TILES) begin
            if (noc1_data_void_out[g_i] == 1'b0) begin
              if (insert_lookahead_routing[g_i]) begin
                coh_last_flit[g_i] <= {data_out_crossbar[g_i].flit[COHDataWidth-1:COHDataWidth-30], next_routing_lock, data_out_crossbar[g_i].flit[COHDataWidth-30-$bits(noc::routing_lock_t)-1:5], next_hop_routing};
                if (!data_out_crossbar[g_i].header.preamble.tail) begin
                  insert_lookahead_routing[g_i] <= 1'b0;
                end
              end else begin
                coh_last_flit[g_i] <= data_out_crossbar[g_i];
                if (data_out_crossbar[g_i].header.preamble.tail) begin
                  insert_lookahead_routing[g_i] <= 1'b1;
                end
              end
            end
          end else if (g_i < 2*TILES) begin
            if (noc2_data_void_out[g_i-TILES] == 1'b0) begin
              if (insert_lookahead_routing[g_i]) begin
                coh_last_flit[g_i] <= {data_out_crossbar[g_i].flit[COHDataWidth-1:COHDataWidth-30], next_routing_lock, data_out_crossbar[g_i].flit[COHDataWidth-30-$bits(noc::routing_lock_t)-1:5], next_hop_routing};
                if (!data_out_crossbar[g_i].header.preamble.tail) begin
                  insert_lookahead_routing[g_i] <= 1'b0;
                end
              end else begin
                coh_last_flit[g_i] <= data_out_crossbar[g_i];
                if (data_out_crossbar[g_i].header.preamble.tail) begin
                  insert_lookahead_routing[g_i] <= 1'b1;
                end
              end
            end
          end else begin
            if (noc3_data_void_out[g_i-2*TILES] == 1'b0) begin
              if (insert_lookahead_routing[g_i]) begin
                coh_last_flit[g_i] <= {data_out_crossbar[g_i].flit[COHDataWidth-1:COHDataWidth-30], next_routing_lock, data_out_crossbar[g_i].flit[COHDataWidth-30-$bits(noc::routing_lock_t)-1:5], next_hop_routing};
                if (!data_out_crossbar[g_i].header.preamble.tail) begin
                  insert_lookahead_routing[g_i] <= 1'b0;
                end
              end else begin
                coh_last_flit[g_i] <= data_out_crossbar[g_i];
                if (data_out_crossbar[g_i].header.preamble.tail) begin
                  insert_lookahead_routing[g_i] <= 1'b1;
                end
              end
            end
          end
        end
      end
    end
    if (g_i < TILES) begin
      assign noc1_data_out[g_i] = FifoBypassEnable ? coh_last_flit[g_i] : data_out_crossbar[g_i];
    end else if (g_i < 2*TILES) begin
      assign noc2_data_out[g_i-TILES] = FifoBypassEnable ? coh_last_flit[g_i] : data_out_crossbar[g_i];
    end else begin
      assign noc3_data_out[g_i-2*TILES] = FifoBypassEnable ? coh_last_flit[g_i] : data_out_crossbar[g_i];
    end
  end // for
  endgenerate

  generate
  // Plane 5
  for (g_i = 4*TILES; g_i < 5*TILES; g_i++) begin
    localparam int g_5 = g_i - 4*TILES;
    assign no_backpressure[g_i] = FifoBypassEnable ? ~noc5_stop_in[g_5] : noc_credits[g_i] != 0;
    assign request_output[g_i] = output_switch[g_i] & no_backpressure[g_i];
    assign forwarding_tail[g_i] = data_out_crossbar[g_i].header.preamble.tail & ~out_unvalid_flit[g_i] & no_backpressure[g_i];
//    assign forwarding_head[g_i] = data_out_crossbar[g_i].header.preamble.head & ~out_unvalid_flit[g_i] & no_backpressure[g_i];

    // Crossbar
    assign data_out_crossbar[g_i] = routing_table_valid[g_i] ? d2d_rcv_data_out[routing_table[g_i]] : '0;
    assign out_unvalid_flit[g_i] = in_unvalid_flit[routing_table[g_i]];

//    always_comb begin
//      rd_fifo[g_i] = '0;
//      if (routing_table_valid[g_i]) begin
//        rd_fifo[g_i][routing_table[g_i]] = no_backpressure[g_i];
//      end
//    end

    if (FifoBypassEnable) begin
      always_ff @(posedge clk) begin
        if (rst_clk) begin
          noc5_data_void_out[g_5] <= 1'b1;
        end else begin
          if ((!routing_table_valid[g_i]) && no_backpressure[g_i]) begin
            noc5_data_void_out[g_5] <= 1'b1;
          end else if (no_backpressure[g_i]) begin
            noc5_data_void_out[g_5] <= out_unvalid_flit[g_i];
          end
        end
      end
      assign noc_credits[g_i] = '0;
    end else begin
      assign noc5_data_void_out[g_5] = (routing_table_valid[g_i] & no_backpressure[g_i]) ? out_unvalid_flit[g_i] : 1'b1;
      
      always_ff @(posedge clk) begin
        if (rst_clk) begin
          noc_credits[g_i] <= NOC_QUEUE_DEPTH;
        end else begin
          if (!noc5_data_void_out[g_5]) begin
            noc_credits[g_i] <= noc_credits[g_i] - noc5_stop_in[g_5];
          end else begin
            noc_credits[g_i] <= noc_credits[g_i] + ~noc5_stop_in[g_5];
          end
        end
      end
    end

    always_ff @(posedge clk) begin
      if (rst_clk) begin
        misc_last_flit[g_5] <= '0;
        insert_lookahead_routing[g_i] <= 1'b1;
      end else begin
        if (FifoBypassEnable) begin
          if (no_backpressure[g_i] & routing_table_valid[g_i] & ~out_unvalid_flit[g_i]) begin
            if (insert_lookahead_routing[g_i]) begin
              misc_last_flit[g_5] <= {data_out_crossbar[g_i].flit[MISCDataWidth-1:MISCDataWidth-30], next_routing_lock, data_out_crossbar[g_i].flit[MISCDataWidth-30-$bits(noc::routing_lock_t)-1:5], next_hop_routing};
              if (!data_out_crossbar[g_i].header.preamble.tail) begin  // 1-flit packet protection
                insert_lookahead_routing[g_i] <= 1'b0;
              end
            end else begin
              misc_last_flit[g_5] <= data_out_crossbar[g_i];
              if (data_out_crossbar[g_i].header.preamble.tail) begin
                insert_lookahead_routing[g_i] <= 1'b1;
              end
            end
          end
        end else begin
          if (noc5_data_void_out[g_5] == 1'b0) begin
            if (insert_lookahead_routing[g_i]) begin
              misc_last_flit[g_5] <= {data_out_crossbar[g_i].flit[MISCDataWidth-1:MISCDataWidth-30], next_routing_lock, data_out_crossbar[g_i].flit[MISCDataWidth-30-$bits(noc::routing_lock_t)-1:5], next_hop_routing};
              if (!data_out_crossbar[g_i].header.preamble.tail) begin  // 1-flit packet protection
                insert_lookahead_routing[g_i] <= 1'b0;
              end
            end else begin
              misc_last_flit[g_5] <= data_out_crossbar[g_i];
              if (data_out_crossbar[g_i].header.preamble.tail) begin
                insert_lookahead_routing[g_i] <= 1'b1;
              end
            end
          end
        end
      end
    end
    assign noc5_data_out[g_5] = FifoBypassEnable ? misc_last_flit[g_5] : data_out_crossbar[g_i];
  end // for
  endgenerate
  // Planes 4, 6
  // TODO: 1. data_void_out when fifo bypass disabled is incorrect bc 1 cycle latency. Fix.
  // 2. If multiple inputs to same plane, take care of the request one by one, insert round-robin arbiter.  -- COMPLETE
  // 3. Need a routing selection mechanism as well.
  generate
  for (g_i = 0; g_i < 2*TILES; g_i++) begin
    if (g_i < TILES) begin
      localparam int g_4 = g_i + 3*TILES;
      assign no_backpressure[g_4] = FifoBypassEnable ? ~noc4_stop_in[g_i] : noc_credits[g_4] != 0;
      assign request_output[g_4] = output_switch[g_4] & no_backpressure[g_4];
//      assign forwarding_tail[g_4] = dma_last_flit[g_i].header.preamble.tail & (beats[g_i] == '1) & ~out_unvalid_flit[g_4] & no_backpressure[g_4];
      assign forwarding_tail[g_4] = data_out_crossbar[g_4].header.preamble.tail & ~out_unvalid_flit[g_4] & no_backpressure[g_4];
//      assign forwarding_head[g_4] = data_out_crossbar[g_4].header.preamble.head & ~out_unvalid_flit[g_4] & no_backpressure[g_4];
      // Crossbar
      assign data_out_crossbar[g_4] = routing_table_valid[g_4] ? d2d_rcv_data_out[routing_table[g_4]] : '0;
      assign out_unvalid_flit[g_4] = in_unvalid_flit[routing_table[g_4]];

//      always_comb begin
//        rd_fifo[g_4] = '0;
//        if (routing_table_valid[g_4]) begin
//          rd_fifo[g_4][routing_table[g_4]] = no_backpressure[g_4];
//        end
//      end

      if (FifoBypassEnable) begin
        always_ff @(posedge clk) begin
          if (rst_clk) begin
              noc4_data_void_out[g_i] <= 1'b1;
          end else begin
            if ((!routing_table_valid[g_4]) && no_backpressure[g_4]) begin
              noc4_data_void_out[g_i] <= 1'b1;
            end else if (no_backpressure[g_4]) begin
              if (&beats[g_i]) begin  // == '1
                noc4_data_void_out[g_i] <= out_unvalid_flit[g_4];
              end else begin
                noc4_data_void_out[g_i] <= 1'b1;
              end
            end
          end
        end
        assign noc_credits[g_4] = '0;
      end else begin
        assign noc4_data_void_out[g_i] = (routing_table_valid[g_4] & no_backpressure[g_4]) ? out_unvalid_flit[g_4] & (beats[g_i] == '1) : 1'b1;
        always_ff @(posedge clk) begin
          if (rst_clk) begin
            noc_credits[g_4] <= NOC_QUEUE_DEPTH;
          end else begin
            if (!noc4_data_void_out[g_i]) begin
              noc_credits[g_4] <= noc_credits[g_4] - noc4_stop_in[g_i];
            end else begin
              noc_credits[g_4] <= noc_credits[g_4] + ~noc4_stop_in[g_i];
            end
          end
        end
      end

      // Insert Deserializer logic
      always_ff @(posedge clk) begin
        if (rst_clk) begin
          dma_last_flit[g_i] <= '0;
          beats[g_i] <= '0;
          insert_lookahead_routing[g_4] <= 1'b1;
          saved_next_hop_routing[g_i] <= '0;
        end else begin
          if (FifoBypassEnable) begin
            if (no_backpressure[g_4] & routing_table_valid[g_4] & ~out_unvalid_flit[g_4]) begin // d2d_rcv_rdreq[routing_table[g_4]] = no_backpressure[g_4]
              beats[g_i] <= beats[g_i] + 1;
              if (~|beats[g_i]) begin // == '0
                if (insert_lookahead_routing[g_4]) begin
                  dma_last_flit[g_i].flit[DMADataWidth-1 -: CHDataWidth] <= {data_out_crossbar[g_4].flit[COHDataWidth-1:COHDataWidth-30], 
                                                                              next_routing_lock, 
                                                                              data_out_crossbar[g_4].flit[COHDataWidth-30-$bits(noc::routing_lock_t)-1:0]};
                  saved_next_hop_routing[g_i] <= next_hop_routing;
                end else begin
                  dma_last_flit[g_i].flit[DMADataWidth-1 -: CHDataWidth] <= data_out_crossbar[g_4];
                end
              end else begin
                if ((&beats[g_i]) && insert_lookahead_routing[g_4]) begin
                  dma_last_flit[g_i].flit[(DMADataWidth-SEG*beats[g_i] - 3) -: SEG] <= {data_out_crossbar[g_4].flit[SEG-1:5], saved_next_hop_routing[g_i]};
                  insert_lookahead_routing[g_4] <= 1'b0;
                end else begin
                  dma_last_flit[g_i].flit[(DMADataWidth-SEG*beats[g_i] - 3) -: SEG] <= data_out_crossbar[g_4].flit[SEG-1:0];
                  if ((&beats[g_i]) && data_out_crossbar[g_4].header.preamble.tail) begin // optimize forwarding tail? any replacements?
                    dma_last_flit[g_i].header.preamble <= 2'b01;
                    insert_lookahead_routing[g_4] <= 1'b1;
                  end
                end
              end
            end
          end else begin
            if (!out_unvalid_flit[g_4] && routing_table_valid[g_4] && no_backpressure[g_4]) begin
            //if (noc4_data_void_out[g_i] == 1'b0) begin
              beats[g_i] <= beats[g_i] + 1;
              if (~|beats[g_i]) begin // == '0
                if (insert_lookahead_routing[g_4]) begin
                  dma_last_flit[g_i].flit[DMADataWidth-1 -: CHDataWidth] <= {data_out_crossbar[g_4].flit[COHDataWidth-1:COHDataWidth-30], 
                                                                              next_routing_lock, 
                                                                              data_out_crossbar[g_4].flit[COHDataWidth-30-$bits(noc::routing_lock_t)-1:0]};
                  saved_next_hop_routing[g_i] <= next_hop_routing;
                end else begin
                  dma_last_flit[g_i].flit[DMADataWidth-1 -: CHDataWidth] <= data_out_crossbar[g_4];
                end
              end else begin 
                if ((&beats[g_i]) && insert_lookahead_routing[g_4]) begin
                  dma_last_flit[g_i].flit[(DMADataWidth-SEG*beats[g_i] - 3) -: SEG] <= {data_out_crossbar[g_4].flit[SEG-1:5], saved_next_hop_routing[g_i]};
                  insert_lookahead_routing[g_4] <= 1'b0;
                end else begin
                  dma_last_flit[g_i].flit[(DMADataWidth-SEG*beats[g_i] - 3) -: SEG] <= data_out_crossbar[g_4].flit[SEG-1:0];
                  if ((&beats[g_i]) && data_out_crossbar[g_4].header.preamble.tail) begin 
                    dma_last_flit[g_i].header.preamble <= 2'b01;
                    insert_lookahead_routing[g_4] <= 1'b1;
                  end
                end
              end
            end
          end
        end
      end
      //assign noc4_data_out[g_i] = FifoBypassEnable ? (insert_lookahead_routing[g_4] ? {dma_last_flit[g_i].flit[DMADataWidth-1:5], next_hop_routing} : dma_last_flit[g_i]) : (insert_lookahead_routing[g_4] ? {data_out_crossbar[g_4].flit[COHDataWidth-1:5], next_hop_routing} : data_out_crossbar[g_4]);
      assign noc4_data_out[g_i] = FifoBypassEnable ? dma_last_flit[g_i] : data_out_crossbar[g_4];
    end else begin  // plane 6
      localparam int g_6 = g_i + 4*TILES;
      assign no_backpressure[g_6] = FifoBypassEnable ? ~noc6_stop_in[g_i-TILES] : noc_credits[g_6] != 0;
      assign request_output[g_6] = output_switch[g_6] & no_backpressure[g_6];
//      assign forwarding_tail[g_6] = dma_last_flit[g_i].header.preamble.tail & (beats[g_i] == '1) & ~out_unvalid_flit[g_6] & no_backpressure[g_6];
      assign forwarding_tail[g_6] = data_out_crossbar[g_6].header.preamble.tail & ~out_unvalid_flit[g_6] & no_backpressure[g_6];
//      assign forwarding_head[g_6] = data_out_crossbar[g_6].header.preamble.head & ~out_unvalid_flit[g_6] & no_backpressure[g_6];
      // Crossbar
      assign data_out_crossbar[g_6] = routing_table_valid[g_6] ? d2d_rcv_data_out[routing_table[g_6]] : '0;
      assign out_unvalid_flit[g_6] = in_unvalid_flit[routing_table[g_6]];

//      always_comb begin
//        rd_fifo[g_6] = '0;
//        if (routing_table_valid[g_6]) begin
//          rd_fifo[g_6][routing_table[g_6]] = no_backpressure[g_6];
//        end
//      end

      if (FifoBypassEnable) begin
        always_ff @(posedge clk) begin
          if (rst_clk) begin
              noc6_data_void_out[g_i-TILES] <= 1'b1;
          end else begin
            if ((!routing_table_valid[g_6]) && no_backpressure[g_6]) begin
              noc6_data_void_out[g_i-TILES] <= 1'b1;
            //end else if (no_backpressure[g_6] && (beats[g_i] == '1)) begin
            end else if (no_backpressure[g_6]) begin
              if (&beats[g_i]) begin  // == '1
                noc6_data_void_out[g_i-TILES] <= out_unvalid_flit[g_6];
              end else begin
                noc6_data_void_out[g_i-TILES] <= 1'b1;
              end
            end
          end
        end
        assign noc_credits[g_6] = '0;
      end else begin
        assign noc6_data_void_out[g_i-TILES] = (routing_table_valid[g_6] & no_backpressure[g_6]) ? out_unvalid_flit[g_6] & (&beats[g_i]): 1'b1;

        always_ff @(posedge clk) begin
          if (rst_clk) begin
            noc_credits[g_6] <= NOC_QUEUE_DEPTH;
          end else begin
            if (!noc6_data_void_out[g_i-TILES]) begin
              noc_credits[g_6] <= noc_credits[g_6] - noc6_stop_in[g_i-TILES];
            end else begin
              noc_credits[g_6] <= noc_credits[g_6] + ~noc6_stop_in[g_i-TILES];
            end
          end
        end
      end

      // Insert Deserializer logic
      always_ff @(posedge clk) begin
        if (rst_clk) begin
          dma_last_flit[g_i] <= '0;
          beats[g_i] <= '0;
          insert_lookahead_routing[g_6] <= 1'b1;
          saved_next_hop_routing[g_i] <= '0;
        end else begin
          if (FifoBypassEnable) begin
            if (no_backpressure[g_6] & routing_table_valid[g_6] & ~out_unvalid_flit[g_6]) begin // d2d_rcv_rdreq[routing_table[g_6]] = no_backpressure[g_6]
              beats[g_i] <= beats[g_i] + 1;
              if (~|beats[g_i]) begin // == '0
                if (insert_lookahead_routing[g_6]) begin
                  dma_last_flit[g_i].flit[DMADataWidth-1 -: CHDataWidth] <= {data_out_crossbar[g_6].flit[COHDataWidth-1:COHDataWidth-30], next_routing_lock, data_out_crossbar[g_6].flit[COHDataWidth-30-$bits(noc::routing_lock_t)-1:0]};
                  saved_next_hop_routing[g_i] <= next_hop_routing;
                end else begin  // non-header-flit, first 66 flit slice
                  dma_last_flit[g_i].flit[DMADataWidth-1 -: CHDataWidth] <= data_out_crossbar[g_6];
                end
              end else begin
                if ((&beats[g_i]) && insert_lookahead_routing[g_6]) begin  // header flit
                  dma_last_flit[g_i].flit[(DMADataWidth-SEG*beats[g_i] - 3) -: SEG] <= {data_out_crossbar[g_6].flit[SEG-1:5], saved_next_hop_routing[g_i]};
                  insert_lookahead_routing[g_6] <= 1'b0;
                end else begin  // body/tail
                  dma_last_flit[g_i].flit[(DMADataWidth-SEG*beats[g_i] - 3) -: SEG] <= data_out_crossbar[g_6].flit[SEG-1:0];
                  if ((&beats[g_i]) && data_out_crossbar[g_6].header.preamble.tail) begin  // tail flit
                    dma_last_flit[g_i].header.preamble <= 2'b01;
                    insert_lookahead_routing[g_6] <= 1'b1;
                  end
                end
              end
            end
          end else begin
            if (noc6_data_void_out[g_i-TILES] == 1'b0) begin
              beats[g_i] <= beats[g_i] + 1;
              if (~|beats[g_i]) begin
                if (insert_lookahead_routing[g_6]) begin
                  dma_last_flit[g_i].flit[DMADataWidth-1 -: CHDataWidth] <= {data_out_crossbar[g_6].flit[COHDataWidth-1:COHDataWidth-30], next_routing_lock, data_out_crossbar[g_6].flit[COHDataWidth-30-$bits(noc::routing_lock_t)-1:0]};
                  saved_next_hop_routing[g_i] <= next_hop_routing;
                end else begin
                  dma_last_flit[g_i].flit[DMADataWidth-1 -: CHDataWidth] <= data_out_crossbar[g_6];
                end
              end else begin
                if ((&beats[g_i]) && insert_lookahead_routing[g_6]) begin
                  dma_last_flit[g_i].flit[(DMADataWidth-SEG*beats[g_i] - 3) -: SEG] <= {data_out_crossbar[g_6].flit[SEG-1:5], saved_next_hop_routing[g_i]};
                  insert_lookahead_routing[g_6] <= 1'b0;
                end else begin
                  dma_last_flit[g_i].flit[(DMADataWidth-SEG*beats[g_i] - 3) -: SEG] <= data_out_crossbar[g_6].flit[SEG-1:0];
                  if ((&beats[g_i]) && data_out_crossbar[g_6].header.preamble.tail) begin // optimize forwarding_tail?
                    dma_last_flit[g_i].header.preamble <= 2'b01;
                    insert_lookahead_routing[g_6] <= 1'b1;
                  end
                end
              end
            end
          end
        end
      end
      //assign noc6_data_out[g_i-TILES] = FifoBypassEnable ? (insert_lookahead_routing[g_6] ? {dma_last_flit[g_i].flit[DMADataWidth-1:5], next_hop_routing} : dma_last_flit[g_i]) : (insert_lookahead_routing[g_6] ? {data_out_crossbar[g_6].flit[COHDataWidth-1:5], next_hop_routing} : data_out_crossbar[g_6]);
      assign noc6_data_out[g_i-TILES] = FifoBypassEnable ? dma_last_flit[g_i] : data_out_crossbar[g_6];
    end
  end // for
  endgenerate

  // Bypass Lane Logic here
  assign no_backpressure[BYPASS_IDX] = FifoBypassEnable ? ~bypass_stop_in : 1'b0; // noc_credits[g_i] != 0
  assign request_output[BYPASS_IDX] = output_switch[BYPASS_IDX] & no_backpressure[BYPASS_IDX];
  assign forwarding_tail[BYPASS_IDX] = data_out_crossbar[BYPASS_IDX].header.preamble.tail & ~out_unvalid_flit[BYPASS_IDX] & no_backpressure[BYPASS_IDX];
//  assign forwarding_head[BYPASS_IDX] = data_out_crossbar[BYPASS_IDX].header.preamble.head & ~out_unvalid_flit[BYPASS_IDX] & no_backpressure[BYPASS_IDX];
  assign data_out_crossbar[BYPASS_IDX] = routing_table_valid[BYPASS_IDX] ? d2d_rcv_data_out[routing_table[BYPASS_IDX]] : '0;
  assign out_unvalid_flit[BYPASS_IDX] = in_unvalid_flit[routing_table[BYPASS_IDX]];

//  always_comb begin
//    rd_fifo[BYPASS_IDX] = '0;
//    if (routing_table_valid[BYPASS_IDX]) begin
//      rd_fifo[BYPASS_IDX][routing_table[BYPASS_IDX]] = no_backpressure[BYPASS_IDX];
//    end
//  end

  always_ff @(posedge clk) begin
    if (rst_clk) begin
       bypass_data_void_out <= 1'b1;
    end else begin
       if ((!routing_table_valid[BYPASS_IDX]) && no_backpressure[BYPASS_IDX]) begin
           bypass_data_void_out <= 1'b1;
       end else if (no_backpressure[BYPASS_IDX]) begin
           bypass_data_void_out <= out_unvalid_flit[BYPASS_IDX];
       end
    end
  end

  // Bypass Header Preservation & Routing Update
  always_ff @(posedge clk) begin
    if (rst_clk) begin
       bypass_last_flit <= '0;
       insert_lookahead_routing[BYPASS_IDX] <= 1'b1;
    end else begin
      if (no_backpressure[BYPASS_IDX] & routing_table_valid[BYPASS_IDX] & ~out_unvalid_flit[BYPASS_IDX]) begin
        if (insert_lookahead_routing[BYPASS_IDX]) begin
          bypass_last_flit <= {
            data_out_crossbar[BYPASS_IDX].flit[CHDataWidth-1 : CHDataWidth-30], 
            next_routing_lock, 
            data_out_crossbar[BYPASS_IDX].flit[CHDataWidth-30-$bits(noc::routing_lock_t)-1 : 5], 
            next_hop_routing
          };
          if (!data_out_crossbar[BYPASS_IDX].header.preamble.tail) begin
            insert_lookahead_routing[BYPASS_IDX] <= 1'b0;
          end 
        end else begin
          bypass_last_flit <= data_out_crossbar[BYPASS_IDX];
          if (data_out_crossbar[BYPASS_IDX].header.preamble.tail) begin
            insert_lookahead_routing[BYPASS_IDX] <= 1'b1;
          end
        end
      end
    end
  end
  assign bypass_data_out = FifoBypassEnable ? bypass_last_flit : data_out_crossbar[BYPASS_IDX];

  always_comb begin
    d2d_link_ready = 1'b1;
    for (int i = 0; i < W; i++) begin
      d2d_link_ready &= (rx_state[i] == state_ready);
    end
  end

  always_ff @(posedge clk) begin
    if (rst_clk) begin
      saved_routing_table <= '{default: '0};
      saved_routing_table_valid <= '{default: 1'b0};
      output_switch <= '{default: 1'b1};
      channel_switch <= '{default: 1'b1};
      in_to_out_map <= '{default: '0};
      in_active <= '{default: '0};
    end else begin
      for (int i = 0; i < W; i++) begin
        if (in_active[i] && forwarding_tail[in_to_out_map[i]]) begin
          in_active[i] <= 1'b0;
          channel_switch[i] <= 1'b1;
          output_switch[in_to_out_map[i]] <= 1'b1;
          saved_routing_table_valid[in_to_out_map[i]] <= 1'b0;
        end
      end
      if (grant_valid_input) begin
        automatic logic [OUTW-1:0] allocated_out = target_out[grant_index_i];
        if (!d2d_rcv_data_out[grant_index_i].header.preamble.tail) begin
          saved_routing_table[allocated_out] <= grant_index_i;
          saved_routing_table_valid[allocated_out] <= 1'b1;
          output_switch[allocated_out] <= 1'b0;
          in_to_out_map[grant_index_i] <= allocated_out;
          in_active[grant_index_i] <= 1'b1;
          channel_switch[grant_index_i] <= 1'b0;
        end
      end
    end
  end // always_ff
  
  always_comb begin
    routing_table = saved_routing_table;
    routing_table_valid = saved_routing_table_valid;
    if (grant_valid_input) begin
      automatic logic [OUTW-1:0] o = target_out[grant_index_i];
      routing_table[o] = grant_index_i;
      routing_table_valid[o] = 1'b1;
    end
  end

  d2d_lookahead_routing
  #(
    .max_dim(max_dim),  // max x or y dimensions
    .chip(chip_coordinates),
    .d2d_position(d2d_position) // 0:N, 1:S, 2:W, 3:E
  ) lookahead_routing_i (
    .clk(clk),
    .destination_chip(d2d_rcv_data_out[grant_index_i].header.info.destination_chip),
    .destination(d2d_rcv_data_out[grant_index_i].header.info.destination),
    .routing_lock(next_routing_lock),
    .next_routing(next_hop_routing)
  );

endmodule
