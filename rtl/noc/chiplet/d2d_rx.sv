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

  // D2D Tx --> D2D Rx
  input   logic                       d2d_clk_in,
  input   logic [CHDataWidth-1:0]     d2d_rcv_data_in [RXCHANNELS-1:0],
  input   logic [RXCHANNELS-1:0]      d2d_valid_in,

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
  localparam int unsigned PLANES = 6;
  parameter int unsigned TxP = TILES*PLANES;
  parameter int unsigned W   = RXCHANNELS;
  parameter int unsigned NOC_QUEUE_DEPTH = 4;
  
  typedef logic [3:0] tile_array_t [TxP-1:0];
  typedef logic [2:0] plane_array_t [TxP-1:0];
  typedef logic [3:0] input_tile_array_t [TxP-1:0];
  typedef logic [2:0] input_plane_array_t [TxP-1:0];

  function automatic tile_array_t generate_tile();
    tile_array_t result;
    for (int i = 0; i < TxP ; i++) begin
      result[i] = i % TILES;
    end
    return result;
  endfunction

  function automatic plane_array_t generate_plane();
    plane_array_t result;
    for (int i = 0; i < TxP ; i++) begin
      result[i] = i / TILES;
    end
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

  logic rstn;

  // Asynchronous FIFO
  coh_flit_t  [W-1:0]   d2d_rcv_data_out;
  logic   [W-1:0]   d2d_rcv_wrreq, d2d_rcv_full, d2d_rcv_empty, d2d_rcv_rdreq;
  logic   [W-1:0]   in_unvalid_flit, in_valid_head, rx_credit_toggle;

  coh_flit_t  [TxP-1:0] data_out_crossbar;
  coh_flit_t  [3*TILES-1:0] coh_last_flit;
  misc_flit_t [TILES-1:0]   misc_last_flit;
  dma_flit_t  [2*TILES-1:0] dma_last_flit;
  logic       [TxP-1:0] no_backpressure, out_unvalid_flit, forwarding_head, forwarding_tail;

  typedef logic [W-1:0] op_ip_arr_t [TxP-1:0];
  op_ip_arr_t rd_fifo;

  typedef logic [CreditWidth-1:0] credits_t [TxP-1:0];
  credits_t noc_credits;

  logic [W-1:0] credit_out, credit_out_empty;

  logic [$clog2(W)-1:0] routing_table [TxP-1:0];
  logic [$clog2(W)-1:0] saved_routing_table [TxP-1:0];
  logic [TxP-1:0] routing_table_valid, saved_routing_table_valid; 
//  logic [TxP-1:0] routing_table_invalidate;

  logic [W-1:0] request_input, channel_switch;
  logic [TxP-1:0] request_output;
//  logic [W-1:0] input_enable, input_disable;
//  logic [TxP-1:0] output_enable, output_disable;
  logic [TxP-1:0] output_switch;
  logic grant_valid_input;
  logic [$clog2(W)-1:0] grant_index_i;
  logic [$clog2(TILES)-1:0] grant_index_o [5:0];
  logic [5:0] grant_valid_output;
  //logic [5:0] grant_valid_plane;

  logic [TxP-1:0] insert_lookahead_routing;
  noc::direction_t next_hop_routing;
  noc::direction_t saved_next_hop_routing [2*TILES-1:0];
  noc::routing_lock_t next_routing_lock;
  noc::tile_t assigned_tile;

  parameter int unsigned serW = $clog2((DMADataWidth-2)/64);  // bitwidth necessary for serializer counter
  logic [serW-1:0] beats [2*TILES-1:0];

  localparam int SEG = CHDataWidth - 2;

//  logic [TxP-1:0][19:0] flit_counter;

  assign rstn = !rst;

  genvar g_i;

  for (g_i=0; g_i < W; g_i++) begin
    inferred_async_fifo #(
      .g_data_width(CHDataWidth),
      .g_size(2*D2D_QUEUE_DEPTH)
    ) u_async_fifo (
      .rst_wr_n_i(rstn),
      .clk_wr_i(d2d_clk_in),
      .we_i(d2d_rcv_wrreq[g_i]),
      .d_i(d2d_rcv_data_in[g_i]),
      .wr_full_o(d2d_rcv_full[g_i]),
      .rst_rd_n_i(rstn),
      .clk_rd_i(clk),
      .rd_i(d2d_rcv_rdreq[g_i]),
      .q_o(d2d_rcv_data_out[g_i]),
      .rd_empty_o(d2d_rcv_empty[g_i])
    );
    
    assign d2d_rcv_wrreq[g_i] = d2d_valid_in[g_i];
    assign in_unvalid_flit[g_i] = d2d_rcv_empty[g_i];
    assign in_valid_head[g_i] = d2d_rcv_data_out[g_i].header.preamble.head & ~in_unvalid_flit[g_i];
    assign request_input[g_i] = channel_switch[g_i] & in_valid_head[g_i];
    assign input_tile[g_i] = in_valid_head[g_i] ? d2d_rcv_data_out[g_i].header.info.tile : saved_input_tile[g_i];
    assign input_plane[g_i] = in_valid_head[g_i] ? d2d_rcv_data_out[g_i].header.info.plane : saved_input_plane[g_i];

    always_ff @(posedge clk) begin
      if (rst) begin
        saved_input_tile[g_i] <= '0;
        saved_input_plane[g_i] <= '0;
      end else begin
        if (in_valid_head[g_i]) begin
          saved_input_tile[g_i] <= d2d_rcv_data_out[g_i].header.info.tile;
          saved_input_plane[g_i] <= d2d_rcv_data_out[g_i].header.info.plane;
        end
      end
    end

    always_comb begin
      d2d_rcv_rdreq[g_i] = 1'b0;
      for (int i = 0; i < TxP; i++) begin
        d2d_rcv_rdreq[g_i] = d2d_rcv_rdreq[g_i] | rd_fifo[i][g_i];
      end
    end

//    always_ff @(posedge clk) begin
//      if (rst) begin
//        rx_credit_toggle[g_i] <= 1'b1;
//      end else begin
//        if (d2d_rcv_rdreq[g_i] & ~in_unvalid_flit[g_i]) begin
//          rx_credit_toggle[g_i] <= ~rx_credit_toggle[g_i];
//        end
//      end
//    end

//    inferred_async_fifo #(
//      .g_data_width(1),
//      .g_size(2*D2D_QUEUE_DEPTH)
//    ) u_credit_fifo (
//      .rst_wr_n_i(rstn),
//      .clk_wr_i(clk),
//      .we_i(d2d_rcv_rdreq[g_i] & ~in_unvalid_flit[g_i]),
//      .d_i(rx_credit_toggle[g_i]),
////      .d_i('0),
//      .wr_full_o(),
//      .rst_rd_n_i(rstn),
//      .clk_rd_i(d2d_clk_in),
//      .rd_i(1'b1),
//      .q_o(credit_out[g_i]),
//      .rd_empty_o(credit_out_empty[g_i])
//    );

    inferred_async_fifo #(
      .g_data_width(1),
      .g_size(2*D2D_QUEUE_DEPTH)
    ) u_credit_fifo (
      .rst_wr_n_i(rstn),
      .clk_wr_i(clk),
      .we_i(d2d_rcv_rdreq[g_i] & ~in_unvalid_flit[g_i]),
      .d_i('0),
      .wr_full_o(),
      .rst_rd_n_i(rstn),
      .clk_rd_i(d2d_clk_in),
      .rd_i(1'b1),
      .q_o(credit_out[g_i]),
      .rd_empty_o(credit_out_empty[g_i])
    );

//    always_ff @(posedge d2d_clk_in) begin
//      if (rst) begin
//        d2d_credit_out[g_i] <= 1'b0;
//      end else begin
//        if (~credit_out_empty[g_i]) begin
//          d2d_credit_out[g_i] <= credit_out[g_i];
//        end
//      end
//    end
    assign d2d_credit_out[g_i] = ~(credit_out[g_i] | credit_out_empty[g_i]);
  end // for
  

  d2d_arbiter #(
    .CHANNELS(W)
  ) d2d_arbiter_i (
    .clk(clk),
    .rst(rst),
    .request(request_input),
    .grant_valid_other_arbiter(1'b1),
    .grant_index(grant_index_i),
    .grant_valid(grant_valid_input)
  );

  // rotating priority arbiter for each plane to keep track of
  // round-robin/rotating priority amongst tiles in each plane
  for (g_i = 0; g_i < 6; g_i++) begin
    d2d_arbiter #(
      .CHANNELS(TILES)
    ) d2d_arbiter_plane_g_i (
      .clk(clk),
      .rst(rst),
      .request(request_output[TILES*(g_i+1)-1:TILES*g_i]),
      .grant_valid_other_arbiter(grant_valid_input),
      .grant_index(grant_index_o[g_i]),  // granted tile number in plane g_i
      .grant_valid(grant_valid_output[g_i])
    );
    //assign grant_valid_plane[g_i] = grant_valid_input & (input_plane[grant_index_i] == g_i[2:0]) & grant_valid_output[g_i]; // plane g_i granted
  end

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
    assign forwarding_head[g_i] = data_out_crossbar[g_i].header.preamble.head & ~out_unvalid_flit[g_i] & no_backpressure[g_i];

    // Crossbar
    assign data_out_crossbar[g_i] = routing_table_valid[g_i] ?  d2d_rcv_data_out[routing_table[g_i]] : '0;
    //assign data_out_crossbar[g_i] = routing_table_valid[g_i] ? (d2d_rcv_data_out[routing_table[g_i]].header.preamble.head ? {d2d_rcv_data_out[routing_table[g_i]][DataWidth-1:12], 7'b0000000, d2d_rcv_data_out[routing_table[g_i]][4:0]} : d2d_rcv_data_out[routing_table[g_i]]) : '0;
    assign out_unvalid_flit[g_i] = routing_table_valid[g_i] ? in_unvalid_flit[routing_table[g_i]] : '1;

    always_comb begin
      rd_fifo[g_i] = '0;
      if (routing_table_valid[g_i]) begin
        rd_fifo[g_i][routing_table[g_i]] = no_backpressure[g_i];
      end
    end

    if (FifoBypassEnable) begin
      always_ff @(posedge clk) begin
        if (rst) begin
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
        if (rst) begin
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
      if (rst) begin
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

  // Plane 5
  for (g_i = 4*TILES; g_i < 5*TILES; g_i++) begin
    localparam int g_5 = g_i - 4*TILES;
    assign no_backpressure[g_i] = FifoBypassEnable ? ~noc5_stop_in[g_5] : noc_credits[g_i] != 0;
    assign request_output[g_i] = output_switch[g_i] & no_backpressure[g_i];
    assign forwarding_tail[g_i] = data_out_crossbar[g_i].header.preamble.tail & ~out_unvalid_flit[g_i] & no_backpressure[g_i];
    assign forwarding_head[g_i] = data_out_crossbar[g_i].header.preamble.head & ~out_unvalid_flit[g_i] & no_backpressure[g_i];

    // Crossbar
    assign data_out_crossbar[g_i] = routing_table_valid[g_i] ?  d2d_rcv_data_out[routing_table[g_i]] : '0;
    //assign data_out_crossbar[g_i] = routing_table_valid[g_i] ? (d2d_rcv_data_out[routing_table[g_i]].header.preamble.head ? {d2d_rcv_data_out[routing_table[g_i]][DataWidth-1:12], 7'b0000000, d2d_rcv_data_out[routing_table[g_i]][4:0]} : d2d_rcv_data_out[routing_table[g_i]]) : '0;
    assign out_unvalid_flit[g_i] = routing_table_valid[g_i] ? in_unvalid_flit[routing_table[g_i]] : '1;

    always_comb begin
      rd_fifo[g_i] = '0;
      if (routing_table_valid[g_i]) begin
        rd_fifo[g_i][routing_table[g_i]] = no_backpressure[g_i];
      end
    end

    if (FifoBypassEnable) begin
      always_ff @(posedge clk) begin
        if (rst) begin
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
        if (rst) begin
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
      if (rst) begin
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

  // Planes 4, 6
  // TODO: 1. data_void_out when fifo bypass disabled is incorrect bc 1 cycle latency. Fix.
  // 2. If multiple inputs to same plane, take care of the request one by one, insert round-robin arbiter.  -- COMPLETE
  // 3. Need a routing selection mechanism as well.
  for (g_i = 0; g_i < 2*TILES; g_i++) begin
    if (g_i < TILES) begin
      localparam int g_4 = g_i + 3*TILES;
      assign no_backpressure[g_4] = FifoBypassEnable ? ~noc4_stop_in[g_i] : noc_credits[g_4] != 0;
      assign request_output[g_4] = output_switch[g_4] & no_backpressure[g_4];
      assign forwarding_tail[g_4] = dma_last_flit[g_i].header.preamble.tail & (beats[g_i] == '1) & ~out_unvalid_flit[g_4] & no_backpressure[g_4];
      assign forwarding_head[g_4] = data_out_crossbar[g_4].header.preamble.head & ~out_unvalid_flit[g_4] & no_backpressure[g_4];
      // Crossbar
      assign data_out_crossbar[g_4] = routing_table_valid[g_4] ?  d2d_rcv_data_out[routing_table[g_4]] : '0;
      assign out_unvalid_flit[g_4] = routing_table_valid[g_4] ? in_unvalid_flit[routing_table[g_4]] : '1;

      always_comb begin
        rd_fifo[g_4] = '0;
        if (routing_table_valid[g_4]) begin
          rd_fifo[g_4][routing_table[g_4]] = no_backpressure[g_4];
        end
      end

      if (FifoBypassEnable) begin
        always_ff @(posedge clk) begin
          if (rst) begin
              noc4_data_void_out[g_i] <= 1'b1;
          end else begin
            if ((!routing_table_valid[g_4]) && no_backpressure[g_4]) begin
              noc4_data_void_out[g_i] <= 1'b1;
            end else if (no_backpressure[g_4]) begin
              if (beats[g_i] == '1) begin
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
          if (rst) begin
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
        if (rst) begin
          dma_last_flit[g_i] <= '0;
          beats[g_i] <= '0;
          insert_lookahead_routing[g_4] <= 1'b1;
          saved_next_hop_routing[g_i] <= '0;
        end else begin
          if (FifoBypassEnable) begin
            if (no_backpressure[g_4] & routing_table_valid[g_4] & ~out_unvalid_flit[g_4]) begin // d2d_rcv_rdreq[routing_table[g_4]] = no_backpressure[g_4]
              beats[g_i] <= beats[g_i] + 1;
              if (beats[g_i] == '0) begin
                if (insert_lookahead_routing[g_4]) begin
                  dma_last_flit[g_i].flit[DMADataWidth-1 -: CHDataWidth] <= {data_out_crossbar[g_4].flit[COHDataWidth-1:COHDataWidth-30], next_routing_lock, data_out_crossbar[g_4].flit[COHDataWidth-30-$bits(noc::routing_lock_t)-1:0]};
                  saved_next_hop_routing[g_i] <= next_hop_routing;
                end else begin
                  dma_last_flit[g_i].flit[DMADataWidth-1 -: CHDataWidth] <= data_out_crossbar[g_4];
                end
              end else if (beats[g_i] == '1 && insert_lookahead_routing[g_4]) begin
                dma_last_flit[g_i].flit[(DMADataWidth-SEG*beats[g_i] - 3) -: SEG] <= {data_out_crossbar[g_4].flit[SEG-1:5], saved_next_hop_routing[g_i]};
                insert_lookahead_routing[g_4] <= 1'b0;
              end else begin
                dma_last_flit[g_i].flit[(DMADataWidth-SEG*beats[g_i] - 3) -: SEG] <= data_out_crossbar[g_4].flit[SEG-1:0];
//                if (beats[g_i] == '1 && data_out_crossbar[g_4].header.preamble.tail) begin // optimize forwarding tail? any replacements?
                if (beats[g_i] == '1 && dma_last_flit[g_i].header.preamble.tail) begin // optimize forwarding tail? any replacements?
                  insert_lookahead_routing[g_4] <= 1'b1;
                end
              end
            end
          end else begin
            if (!out_unvalid_flit[g_4] && routing_table_valid[g_4] && no_backpressure[g_4]) begin
            //if (noc4_data_void_out[g_i] == 1'b0) begin
              beats[g_i] <= beats[g_i] + 1;
              if (beats[g_i] == '0) begin
                if (insert_lookahead_routing[g_4]) begin
                  dma_last_flit[g_i].flit[DMADataWidth-1 -: CHDataWidth] <= {data_out_crossbar[g_4].flit[COHDataWidth-1:COHDataWidth-30], next_routing_lock, data_out_crossbar[g_4].flit[COHDataWidth-30-$bits(noc::routing_lock_t)-1:0]};
                  saved_next_hop_routing[g_i] <= next_hop_routing;
                end else begin
                  dma_last_flit[g_i].flit[DMADataWidth-1 -: CHDataWidth] <= data_out_crossbar[g_4];
                end
              end else if (beats[g_i] == '1 && insert_lookahead_routing[g_4]) begin
                dma_last_flit[g_i].flit[(DMADataWidth-SEG*beats[g_i] - 3) -: SEG] <= {data_out_crossbar[g_4].flit[SEG-1:5], saved_next_hop_routing[g_i]};
                insert_lookahead_routing[g_4] <= 1'b0;
              end else begin
                dma_last_flit[g_i].flit[(DMADataWidth-SEG*beats[g_i] - 3) -: SEG] <= data_out_crossbar[g_4].flit[SEG-1:0];
//                if (beats[g_i] == '1 && data_out_crossbar[g_4].header.preamble.tail) begin 
                if (beats[g_i] == '1 && dma_last_flit[g_i].header.preamble.tail) begin 
                  insert_lookahead_routing[g_4] <= 1'b1;
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
      assign forwarding_tail[g_6] = dma_last_flit[g_i].header.preamble.tail & (beats[g_i] == '1) & ~out_unvalid_flit[g_6] & no_backpressure[g_6];
      assign forwarding_head[g_6] = data_out_crossbar[g_6].header.preamble.head & ~out_unvalid_flit[g_6] & no_backpressure[g_6];
      // Crossbar
      assign data_out_crossbar[g_6] = routing_table_valid[g_6] ?  d2d_rcv_data_out[routing_table[g_6]] : '0;
      assign out_unvalid_flit[g_6] = routing_table_valid[g_6] ? in_unvalid_flit[routing_table[g_6]] : '1;

      always_comb begin
        rd_fifo[g_6] = '0;
        if (routing_table_valid[g_6]) begin
          rd_fifo[g_6][routing_table[g_6]] = no_backpressure[g_6];
        end
      end

      if (FifoBypassEnable) begin
        always_ff @(posedge clk) begin
          if (rst) begin
              noc6_data_void_out[g_i-TILES] <= 1'b1;
          end else begin
            if ((!routing_table_valid[g_6]) && no_backpressure[g_6]) begin
              noc6_data_void_out[g_i-TILES] <= 1'b1;
            //end else if (no_backpressure[g_6] && (beats[g_i] == '1)) begin
            end else if (no_backpressure[g_6]) begin
              if (beats[g_i] == '1) begin
                noc6_data_void_out[g_i-TILES] <= out_unvalid_flit[g_6];
              end else begin
                noc6_data_void_out[g_i-TILES] <= 1'b1;
              end
            end
          end
        end
        assign noc_credits[g_6] = '0;
      end else begin
        assign noc6_data_void_out[g_i-TILES] = (routing_table_valid[g_6] & no_backpressure[g_6]) ? out_unvalid_flit[g_6] & (beats[g_i] == '1): 1'b1;

        always_ff @(posedge clk) begin
          if (rst) begin
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
        if (rst) begin
          dma_last_flit[g_i] <= '0;
          beats[g_i] <= '0;
          insert_lookahead_routing[g_6] <= 1'b1;
          saved_next_hop_routing[g_i] <= '0;
        end else begin
          if (FifoBypassEnable) begin
            if (no_backpressure[g_6] & routing_table_valid[g_6] & ~out_unvalid_flit[g_6]) begin // d2d_rcv_rdreq[routing_table[g_6]] = no_backpressure[g_6]
              beats[g_i] <= beats[g_i] + 1;
              if (beats[g_i] == '0) begin
                if (insert_lookahead_routing[g_6]) begin
                  dma_last_flit[g_i].flit[DMADataWidth-1 -: CHDataWidth] <= {data_out_crossbar[g_6].flit[COHDataWidth-1:COHDataWidth-30], next_routing_lock, data_out_crossbar[g_6].flit[COHDataWidth-30-$bits(noc::routing_lock_t)-1:0]};
                  saved_next_hop_routing[g_i] <= next_hop_routing;
                end else begin
                  dma_last_flit[g_i].flit[DMADataWidth-1 -: CHDataWidth] <= data_out_crossbar[g_6];
                end
              end else if (beats[g_i] == '1 && insert_lookahead_routing[g_6]) begin
                dma_last_flit[g_i].flit[(DMADataWidth-SEG*beats[g_i] - 3) -: SEG] <= {data_out_crossbar[g_6].flit[SEG-1:5], saved_next_hop_routing[g_i]};
                insert_lookahead_routing[g_6] <= 1'b0;
              end else begin
                dma_last_flit[g_i].flit[(DMADataWidth-SEG*beats[g_i] - 3) -: SEG] <= data_out_crossbar[g_6].flit[SEG-1:0];
//                if (beats[g_i] == '1 && data_out_crossbar[g_6].header.preamble.tail) begin // optimize forwarding_tail?
                if (beats[g_i] == '1 && dma_last_flit[g_i].header.preamble.tail) begin // optimize forwarding_tail?
                  insert_lookahead_routing[g_6] <= 1'b1;
                end
              end
            end
          end else begin
            if (noc6_data_void_out[g_i-TILES] == 1'b0) begin
              beats[g_i] <= beats[g_i] + 1;
              if (beats[g_i] == '0) begin
                if (insert_lookahead_routing[g_6]) begin
                  dma_last_flit[g_i].flit[DMADataWidth-1 -: CHDataWidth] <= {data_out_crossbar[g_6].flit[COHDataWidth-1:COHDataWidth-30], next_routing_lock, data_out_crossbar[g_6].flit[COHDataWidth-30-$bits(noc::routing_lock_t)-1:0]};
                  saved_next_hop_routing[g_i] <= next_hop_routing;
                end else begin
                  dma_last_flit[g_i].flit[DMADataWidth-1 -: CHDataWidth] <= data_out_crossbar[g_6];
                end
              end else if (beats[g_i] == '1 && insert_lookahead_routing[g_6]) begin
                dma_last_flit[g_i].flit[(DMADataWidth-SEG*beats[g_i] - 3) -: SEG] <= {data_out_crossbar[g_6].flit[SEG-1:5], saved_next_hop_routing[g_i]};
                insert_lookahead_routing[g_6] <= 1'b0;
              end else begin
                dma_last_flit[g_i].flit[(DMADataWidth-SEG*beats[g_i] - 3) -: SEG] <= data_out_crossbar[g_6].flit[SEG-1:0];
//                if (beats[g_i] == '1 && data_out_crossbar[g_6].header.preamble.tail) begin // optimize forwarding_tail?
                if (beats[g_i] == '1 && dma_last_flit[g_i].header.preamble.tail) begin // optimize forwarding_tail?
                  insert_lookahead_routing[g_6] <= 1'b1;
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

//  always_comb begin
//    routing_table = saved_routing_table;
//    routing_table_valid = saved_routing_table_valid;
//    routing_table_invalidate = '0;
//    output_enable = '0;
//    output_disable = '0;
//    input_enable = '0;
//    input_disable = '0;
//
//    for (int i = 0; i < TxP; i++) begin
//      if (forwarding_tail[i]) begin
//        routing_table_invalidate[i] = 1'b1;
//        input_enable[saved_routing_table[i]] = 1'b1;
//        output_enable[i] = 1'b1;
//      end
//      if (grant_valid_input && (tile[i] == input_tile[grant_index_i]) && (plane[i] == input_plane[grant_index_i]) && output_switch[i]) begin
//        routing_table[i] = grant_index_i;
//        routing_table_valid[i] = 1'b1;
//        input_disable[grant_index_i] = 1'b1;
//        output_disable[i] = 1'b1;
//      end
//    end
//  end

//  always_ff @(posedge clk) begin
//    if (rst) begin
//      saved_routing_table <= '0;
//      saved_routing_table_valid <= '0;
//      output_switch <= '1;
//      channel_switch <= '1;
//    end else begin
//      saved_routing_table <= routing_table;
//      saved_routing_table_valid <= routing_table_valid;
//
//      for (int i = 0; i < W; i++) begin
//        if (input_enable[i]) begin
//          channel_switch[i] <= 1'b1;
//        end
//        if (input_disable[i]) begin
//          channel_switch[i] <= 1'b0;
//        end
//      end
//      for (int j = 0; j < TxP; j++) begin
//        if (output_enable[j]) begin
//          output_switch[j] <= 1'b1;
//        end
//        if (output_disable[j]) begin
//          output_switch[j] <= 1'b0;
//        end
//        if (routing_table_invalidate[j]) begin
//          saved_routing_table_valid[j] <= 1'b0;
//        end
//      end
//    end
//  end

  // each plane has its own arbiter to select from multiple requests
  always_ff @(posedge clk) begin
    if (rst) begin
      saved_routing_table <= '{default: '0};
      saved_routing_table_valid <= '0;
      output_switch <= '1;
      channel_switch <= '1;
    end else begin
      for (int i = 0; i < TxP; i++) begin
        if (~forwarding_head[i] & forwarding_tail[i]) begin // forwarding tail : invalidate the table entry and turn the switches back on
          saved_routing_table_valid[i] <= 1'b0;
          channel_switch[saved_routing_table[i]] <= 1'b1;
          output_switch[i] <= 1'b1;
        end
        if (grant_valid_input & (plane[i] == input_plane[grant_index_i]) & (~d2d_rcv_data_out[grant_index_i].header.preamble.tail)) begin
          if ((chip_coordinates.x == d2d_rcv_data_out[grant_index_i].header.info.destination_chip.x) && (chip_coordinates.y == d2d_rcv_data_out[grant_index_i].header.info.destination_chip.y)) begin
            if (d2d_position == 2'b00 || d2d_position == 2'b01) begin
              if (tile[i] == d2d_rcv_data_out[grant_index_i].header.info.destination.x && request_output[i]) begin
                saved_routing_table[i] <= grant_index_i;
                saved_routing_table_valid[i] <= 1'b1;
                channel_switch[grant_index_i] <= 1'b0;
                output_switch[i] <= 1'b0;
              end
            end else begin
              if (tile[i] == d2d_rcv_data_out[grant_index_i].header.info.destination.y && request_output[i]) begin
                saved_routing_table[i] <= grant_index_i;
                saved_routing_table_valid[i] <= 1'b1;
                channel_switch[grant_index_i] <= 1'b0;
                output_switch[i] <= 1'b0;
              end
            end
//            if (input_tile[grant_index_i] > noc::tile_t'(TILES-1)) begin // out-of-bounds
//              if (grant_valid_output[input_plane[grant_index_i]] & (tile[i] == grant_index_o[input_plane[grant_index_i]])) begin
//                saved_routing_table[i] <= grant_index_i;
//                saved_routing_table_valid[i] <= 1'b1;
//                channel_switch[grant_index_i] <= 1'b0;
//                output_switch[i] <= 1'b0;
//              end
//            end else begin   
//              if (tile[i] == input_tile[grant_index_i] && output_switch[i]) begin
//                saved_routing_table[i] <= grant_index_i;
//                saved_routing_table_valid[i] <= 1'b1;
//                channel_switch[grant_index_i] <= 1'b0;
//                output_switch[i] <= 1'b0;
//              end
//            end
          end else begin
            if (grant_valid_output[input_plane[grant_index_i]] && (tile[i] == grant_index_o[input_plane[grant_index_i]])) begin
              saved_routing_table[i] <= grant_index_i;
              saved_routing_table_valid[i] <= 1'b1;
              channel_switch[grant_index_i] <= 1'b0;
              output_switch[i] <= 1'b0;
            end
          end
        end
//        if (grant_valid_input & grant_valid_output[input_plane[grant_index_i]] & (tile[i] == grant_index_o[input_plane[grant_index_i]])
//        & (plane[i] == input_plane[grant_index_i])) begin // both arbiters granted and indices match tile and plane
//          if (~d2d_rcv_data_out[grant_index_i].header.preamble.tail) begin  // not one-flit-long packet
//            saved_routing_table[i] <= grant_index_i;
//            saved_routing_table_valid[i] <= 1'b1;
//            channel_switch[grant_index_i] <= 1'b0;
//            output_switch[i] <= 1'b0;
//          end



//          if (plane[i] == 3'b101 || plane[i] == 3'b011) begin // planes 4 or 6
//            saved_routing_table[i] <= grant_index_i;
//            saved_routing_table_valid[i] <= 1'b1;
//            channel_switch[grant_index_i] <= 1'b0;
//            output_switch[i] <= 1'b0;
//          end else begin  // planes 1, 2, 3, or 5
//            if (~d2d_rcv_data_out[grant_index_i].header.preamble.tail) begin  // not one-flit-long packet
//              saved_routing_table[i] <= grant_index_i;
//              saved_routing_table_valid[i] <= 1'b1;
//              channel_switch[grant_index_i] <= 1'b0;
//              output_switch[i] <= 1'b0;
//            end
//          end
      end
    end
  end

  always_comb begin
    routing_table = saved_routing_table;
    routing_table_valid = saved_routing_table_valid;
    assigned_tile = noc::tile_t'(grant_index_o[input_plane[grant_index_i]]);

    for (int i = 0; i < TxP; i++) begin
//      if (grant_valid_input & grant_valid_output[input_plane[grant_index_i]] & (tile[i] == grant_index_o[input_plane[grant_index_i]]) & (plane[i] == input_plane[grant_index_i])) begin
      if (grant_valid_input & (plane[i] == input_plane[grant_index_i])) begin
        if ((chip_coordinates.x == d2d_rcv_data_out[grant_index_i].header.info.destination_chip.x) && (chip_coordinates.y == d2d_rcv_data_out[grant_index_i].header.info.destination_chip.y)) begin
          if (d2d_position == 2'b00 || d2d_position == 2'b01) begin
            if (tile[i] == d2d_rcv_data_out[grant_index_i].header.info.destination.x && request_output[i]) begin
              routing_table[i] = grant_index_i;
              routing_table_valid[i] = 1'b1;
              assigned_tile = tile[i];
            end
          end else begin
            if (tile[i] == d2d_rcv_data_out[grant_index_i].header.info.destination.y && request_output[i]) begin
              routing_table[i] = grant_index_i;
              routing_table_valid[i] = 1'b1;
              assigned_tile = tile[i];
            end
          end
//          if (input_tile[grant_index_i] > noc::tile_t'(TILES-1))  begin // out-of-bounds
//            if (grant_valid_output[input_plane[grant_index_i]] & (tile[i] == grant_index_o[input_plane[grant_index_i]])) begin
//              routing_table[i] = grant_index_i;
//              routing_table_valid[i] = 1'b1;
//            end
//          end else begin
//            if (tile[i] == input_tile[grant_index_i] && output_switch[i]) begin // if going from 3 -> 2 tiles, cannot route. BUG. TODO.
//                routing_table[i] = grant_index_i;
//                routing_table_valid[i] = 1'b1;
//                assigned_tile = tile[i];
//            end
//          end
        end else begin
          if (grant_valid_output[input_plane[grant_index_i]] && (tile[i] == grant_index_o[input_plane[grant_index_i]])) begin
            routing_table[i] = grant_index_i;
            routing_table_valid[i] = 1'b1;
          end
        end
      end
    end
  end

   // Insert routing logic here
  d2d_lookahead_routing 
  #(
    .max_dim(max_dim),  // max x or y dimensions
    .chip(chip_coordinates),
//    .TILES(TILES),
    .d2d_position(d2d_position) // 0:N, 1:S, 2:W, 3:E
  ) lookahead_routing_i (
    .clk(clk),
    .destination_chip(d2d_rcv_data_out[grant_index_i].header.info.destination_chip),
    .destination(d2d_rcv_data_out[grant_index_i].header.info.destination),
    //.destination_chip(data_out_crossbar[grant_index_o[input_plane[grant_index_i]]].header.info.destination_chip),
    //.destination(data_out_crossbar[grant_index_o[input_plane[grant_index_i]]].header.info.destination),
    //.assigned_tile(grant_index_o[input_plane[grant_index_i]]),
    .assigned_tile(assigned_tile),
    .routing_lock(next_routing_lock),
    .next_routing(next_hop_routing)
  );

endmodule
