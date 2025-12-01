module d2d_tx #(
  parameter int unsigned TXCHANNELS   = 4,
  parameter int unsigned TILES        = 3,
  parameter bit FlowControl = 1'b0,
  parameter int unsigned CHDataWidth = 66,
  parameter int unsigned COHDataWidth = 66,
  parameter int unsigned MISCDataWidth = 66,
  parameter int unsigned DMADataWidth = 130
)(
  input   logic clk,
  input   logic rst,
  input   logic d2d_clk_in,
  
  // D2D Tx --> D2D Rx
  output  logic [CHDataWidth-1:0]   d2d_snd_data_out [TXCHANNELS-1:0],
  output  logic [TXCHANNELS-1:0]    d2d_valid_out,

  // D2D Rx --> D2D Tx
  input   logic [TXCHANNELS-1:0]    d2d_credit_in,

  // NoC    --> D2D
  input   logic [COHDataWidth-1:0]  noc1_data_in [TILES-1:0],
  input   logic [COHDataWidth-1:0]  noc2_data_in [TILES-1:0],
  input   logic [COHDataWidth-1:0]  noc3_data_in [TILES-1:0],
  input   logic [DMADataWidth-1:0]  noc4_data_in [TILES-1:0],
  input   logic [MISCDataWidth-1:0] noc5_data_in [TILES-1:0],
  input   logic [DMADataWidth-1:0]  noc6_data_in [TILES-1:0],
  input   logic [TILES-1:0]         noc1_data_void_in,
  input   logic [TILES-1:0]         noc2_data_void_in,
  input   logic [TILES-1:0]         noc3_data_void_in,
  input   logic [TILES-1:0]         noc4_data_void_in,
  input   logic [TILES-1:0]         noc5_data_void_in,
  input   logic [TILES-1:0]         noc6_data_void_in,

  // D2D    --> NoC
  output  logic [TILES-1:0]         noc1_stop_out,
  output  logic [TILES-1:0]         noc2_stop_out,
  output  logic [TILES-1:0]         noc3_stop_out, 
  output  logic [TILES-1:0]         noc4_stop_out, 
  output  logic [TILES-1:0]         noc5_stop_out,
  output  logic [TILES-1:0]         noc6_stop_out
  );

  localparam bit FifoBypassEnable = FlowControl == 1'b0;

  parameter int unsigned D2D_QUEUE_DEPTH = 8; 
  parameter int unsigned CreditWidth = $clog2(2*D2D_QUEUE_DEPTH + 1);
  parameter int unsigned TxP = TILES*6;
  parameter int unsigned W   = TXCHANNELS;
  parameter int unsigned NOC_QUEUE_DEPTH = 4;
  
  typedef logic [3:0] tile_array_t [TxP-1:0];
  typedef logic [2:0] plane_array_t [TxP-1:0];

  function automatic tile_array_t generate_tile();
    tile_array_t result;
    for (int i = 0; i < TxP; i++) begin
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

  coh_flit_t  [3*TILES-1:0] coh_noc_snd_data_in,  coh_noc_snd_data_out;
  misc_flit_t [1*TILES-1:0] misc_noc_snd_data_in, misc_noc_snd_data_out;
  dma_flit_t  [2*TILES-1:0] dma_noc_snd_data_in,  dma_noc_snd_data_out;

  logic [TxP-1:0] noc_snd_wrreq, noc_snd_full, noc_snd_empty, rd_fifo_or;
  
  logic [TxP-1:0] in_unvalid_flit, in_valid_head;

  // Asynchronous FIFO - Synchronized to CLK
  logic [W-1:0] d2d_snd_wrreq, d2d_snd_full, d2d_stop_out;

  // Asynchronous FIFO - Synchronized to D2D_CLK_IN
  logic [W-1:0] d2d_snd_rdreq, d2d_snd_empty;

  // Sync FIFO & Async FIFO Credits
  typedef logic [CreditWidth-1:0] credits_t [W-1:0];
  credits_t credits, noc_credits;

  // Credit Synchronize
  logic [W-1:0] d2d_credit_in_int;
//  logic [W-1:0] credit_in_sync1, credit_in_sync2, credit_in_old, credit_edge;

  // Routing Table
  parameter int unsigned TxPWidth = $clog2(TxP);
  parameter int unsigned WWidth   = $clog2(W);
  typedef logic [TxPWidth-1:0] routing_table_t [W-1:0];
  routing_table_t routing_table, final_routing_table;
  logic [W-1:0] routing_table_valid, final_routing_table_valid;

  // Arbiter Input and Control
  logic [TxP-1:0] request_input, input_switch;
  logic [W-1:0]   request_channel, channel_switch;
  logic           grant_valid_input, grant_valid_channel;

  // Arbiter Output Indices
  logic [WWidth-1:0]    grant_index_c;
  logic [TxPWidth-1:0]  grant_index_i;

  // Channel Output
  logic [W-1:0] forwarding_tail, forwarding_head, data_void_out;

  // Crossbar
  typedef logic [TxP-1:0] op_ip_arr_t [W-1:0];
  op_ip_arr_t rd_fifo;
  coh_flit_t [W-1:0]  last_flit, data_out_crossbar, data_out;
  logic [CHDataWidth-1:0] serialized_data_out [2*TILES-1:0];
  logic [W-1:0] out_unvalid_flit, no_backpressure, d2d_no_backpressure;

  
  parameter int unsigned serW = $clog2((DMADataWidth-2)/64);  // bitwidth necessary for serializer counter
  logic [serW-1:0] beats [2*TILES-1:0];
  logic serialized_rd_fifo [2*TILES-1:0];

//  logic [TxP-1:0][19:0] flit_counter;

  assign d2d_clk_out = d2d_clk_in;
  assign rstn = ~rst;

  genvar g_i;

  // Coherent NoC wiring -- need to wire noc1 tiles 0 to cfg_xlen then noc2
  // tiles 0 to cfg_xlen then noc3 tiles 0 to cfg_xlen
  for (g_i = 0; g_i < TILES; g_i++) begin
//    always_ff @(posedge clk) begin
//      if (rst) begin
//        flit_counter[g_i] = '0;
//      end else begin
//        if (!noc_data_void_in[g_i] && !noc_stop_out[g_i]) begin
//          flit_counter[g_i] = flit_counter[g_i] + 1;
//        end
//      end
//    end
    always_comb begin
      coh_noc_snd_data_in[g_i+0*TILES] = noc1_data_in[g_i];
      coh_noc_snd_data_in[g_i+1*TILES] = noc2_data_in[g_i];
      coh_noc_snd_data_in[g_i+2*TILES] = noc3_data_in[g_i];
      if ((!noc1_data_void_in[g_i]) && coh_noc_snd_data_in[g_i].header.preamble.head) begin
        coh_noc_snd_data_in[g_i+0*TILES].header.info.tile   = tile[g_i+0*TILES];  // order: tile 0, 1, 2, 3; 0, 1, 2, 3
        coh_noc_snd_data_in[g_i+0*TILES].header.info.plane  = plane[g_i+0*TILES]; // order: plane 0, 0, 0, 0; 1, 1, 1, 1; 2, 2, 2, 2;
      end
      if ((!noc2_data_void_in[g_i]) && coh_noc_snd_data_in[g_i+1*TILES].header.preamble.head) begin
        coh_noc_snd_data_in[g_i+1*TILES].header.info.tile   = tile[g_i+1*TILES];  // order: tile 0, 1, 2, 3; 0, 1, 2, 3
        coh_noc_snd_data_in[g_i+1*TILES].header.info.plane  = plane[g_i+1*TILES]; // order: plane 0, 0, 0, 0; 1, 1, 1, 1; 2, 2, 2, 2;
      end
      if ((!noc3_data_void_in[g_i]) && coh_noc_snd_data_in[g_i+2*TILES].header.preamble.head) begin
        coh_noc_snd_data_in[g_i+2*TILES].header.info.tile   = tile[g_i+2*TILES];  // order: tile 0, 1, 2, 3; 0, 1, 2, 3
        coh_noc_snd_data_in[g_i+2*TILES].header.info.plane  = plane[g_i+2*TILES]; // order: plane 0, 0, 0, 0; 1, 1, 1, 1; 2, 2, 2, 2;
      end
    end

    // Plane 1
    router_fifo #(
      .BypassEnable(FifoBypassEnable),
      .Depth(NOC_QUEUE_DEPTH),
      .Width(COHDataWidth)
    ) input_queue_p1 (
      .clk(clk),
      .rst(rst),
      .rdreq(rd_fifo_or[g_i]),
      .wrreq(noc_snd_wrreq[g_i]),
      .data_in(coh_noc_snd_data_in[g_i]),
      .empty(noc_snd_empty[g_i]),
      .full(noc_snd_full[g_i]),
      .data_out(coh_noc_snd_data_out[g_i])
    );

    // Plane 2
    router_fifo #(
      .BypassEnable(FifoBypassEnable),
      .Depth(NOC_QUEUE_DEPTH),
      .Width(COHDataWidth)
    ) input_queue_p2 (
      .clk(clk),
      .rst(rst),
      .rdreq(rd_fifo_or[g_i+1*TILES]),
      .wrreq(noc_snd_wrreq[g_i+1*TILES]),
      .data_in(coh_noc_snd_data_in[g_i+1*TILES]),
      .empty(noc_snd_empty[g_i+1*TILES]),
      .full(noc_snd_full[g_i+1*TILES]),
      .data_out(coh_noc_snd_data_out[g_i+1*TILES])
    );

    // Plane 3
    router_fifo #(
      .BypassEnable(FifoBypassEnable),
      .Depth(NOC_QUEUE_DEPTH),
      .Width(COHDataWidth)
    ) input_queue_p3 (
      .clk(clk),
      .rst(rst),
      .rdreq(rd_fifo_or[g_i+2*TILES]),
      .wrreq(noc_snd_wrreq[g_i+2*TILES]),
      .data_in(coh_noc_snd_data_in[g_i+2*TILES]),
      .empty(noc_snd_empty[g_i+2*TILES]),
      .full(noc_snd_full[g_i+2*TILES]),
      .data_out(coh_noc_snd_data_out[g_i+2*TILES])
    );


    assign noc_snd_wrreq[g_i]           = ~noc1_data_void_in[g_i];
    assign noc_snd_wrreq[g_i+1*TILES]   = ~noc2_data_void_in[g_i];
    assign noc_snd_wrreq[g_i+2*TILES]   = ~noc3_data_void_in[g_i];   
    assign in_unvalid_flit[g_i] = FifoBypassEnable ? noc_snd_empty[g_i] & noc1_data_void_in[g_i] : noc_snd_empty[g_i];
    assign in_unvalid_flit[g_i+1*TILES] = FifoBypassEnable ? noc_snd_empty[g_i+1*TILES] & noc2_data_void_in[g_i] : noc_snd_empty[g_i+1*TILES];
    assign in_unvalid_flit[g_i+2*TILES] = FifoBypassEnable ? noc_snd_empty[g_i+2*TILES] & noc3_data_void_in[g_i] : noc_snd_empty[g_i+2*TILES];
    assign in_valid_head[g_i] = coh_noc_snd_data_out[g_i].header.preamble.head & (~in_unvalid_flit[g_i]);
    assign in_valid_head[g_i+1*TILES] = coh_noc_snd_data_out[g_i+1*TILES].header.preamble.head & (~in_unvalid_flit[g_i+1*TILES]);
    assign in_valid_head[g_i+2*TILES] = coh_noc_snd_data_out[g_i+2*TILES].header.preamble.head & (~in_unvalid_flit[g_i+2*TILES]);
    assign noc1_stop_out[g_i] = FifoBypassEnable ? noc_snd_full[g_i] : ~(rd_fifo_or[g_i] & (~in_unvalid_flit[g_i]));
    assign noc2_stop_out[g_i] = FifoBypassEnable ? noc_snd_full[g_i+1*TILES] : ~(rd_fifo_or[g_i+1*TILES] & (~in_unvalid_flit[g_i+1*TILES]));
    assign noc3_stop_out[g_i] = FifoBypassEnable ? noc_snd_full[g_i+2*TILES] : ~(rd_fifo_or[g_i+2*TILES] & (~in_unvalid_flit[g_i+2*TILES]));   
    assign request_input[g_i] = input_switch[g_i] & in_valid_head[g_i];
    assign request_input[g_i+1*TILES] = input_switch[g_i+1*TILES] & in_valid_head[g_i+1*TILES];
    assign request_input[g_i+2*TILES] = input_switch[g_i+2*TILES] & in_valid_head[g_i+2*TILES];

    always_comb begin
      rd_fifo_or[g_i] = 1'b0;
      rd_fifo_or[g_i+1*TILES] = 1'b0;
      rd_fifo_or[g_i+2*TILES] = 1'b0;     
      for (int i = 0; i < W; i++) begin
        rd_fifo_or[g_i] = rd_fifo_or[g_i] | rd_fifo[i][g_i];
        rd_fifo_or[g_i+1*TILES] = rd_fifo_or[g_i+1*TILES] | rd_fifo[i][g_i+1*TILES];
        rd_fifo_or[g_i+2*TILES] = rd_fifo_or[g_i+2*TILES] | rd_fifo[i][g_i+2*TILES]; 
      end
    end
  end

  // Miscellaneous NoC wiring -- need to wire noc1 tiles 0 to cfg_xlen then noc2
  // tiles 0 to cfg_xlen then noc3 tiles 0 to cfg_xlen
  for (g_i = 0; g_i < TILES; g_i++) begin
//    always_ff @(posedge clk) begin
//      if (rst) begin
//        flit_counter[g_i] = '0;
//      end else begin
//        if (!noc_data_void_in[g_i] && !noc_stop_out[g_i]) begin
//          flit_counter[g_i] = flit_counter[g_i] + 1;
//        end
//      end
//    end
    localparam int g_5 = 4*TILES + g_i;
    always_comb begin
      misc_noc_snd_data_in[g_i] = noc5_data_in[g_i];
      if ((!noc5_data_void_in[g_i]) && misc_noc_snd_data_in[g_i].header.preamble.head) begin
        misc_noc_snd_data_in[g_i].header.info.tile   = tile[g_5];  // order: tile 0, 1, 2, 3; 0, 1, 2, 3
        misc_noc_snd_data_in[g_i].header.info.plane  = plane[g_5]; // order: plane 0, 0, 0, 0; 1, 1, 1, 1; 2, 2, 2, 2;
      end
    end

    // Plane 5
    router_fifo #(
      .BypassEnable(FifoBypassEnable),
      .Depth(NOC_QUEUE_DEPTH),
      .Width(MISCDataWidth)
    ) input_queue_p5 (
      .clk(clk),
      .rst(rst),
      .rdreq(rd_fifo_or[g_5]),
      .wrreq(noc_snd_wrreq[g_5]),
      .data_in(misc_noc_snd_data_in[g_i]),
      .empty(noc_snd_empty[g_5]),
      .full(noc_snd_full[g_5]),
      .data_out(misc_noc_snd_data_out[g_i])
    );

    assign noc_snd_wrreq[g_5] = ~noc5_data_void_in[g_i];
    assign in_unvalid_flit[g_5] = FifoBypassEnable ? noc_snd_empty[g_5] & noc5_data_void_in[g_i] : noc_snd_empty[g_5];
    assign in_valid_head[g_5] = misc_noc_snd_data_out[g_i].header.preamble.head & (~in_unvalid_flit[g_5]);
    assign noc5_stop_out[g_i] = FifoBypassEnable ? noc_snd_full[g_5] : ~(rd_fifo_or[g_5] & (~in_unvalid_flit[g_5]));
    assign request_input[g_5] = input_switch[g_5] & in_valid_head[g_5];

    always_comb begin
      rd_fifo_or[g_5] = 1'b0;
      for (int i = 0; i < W; i++) begin
        rd_fifo_or[g_5] = rd_fifo_or[g_5] | rd_fifo[i][g_5];
      end
    end
  end

  // DMA NoC wiring -- need to wire noc1 tiles 0 to cfg_xlen then noc2
  // tiles 0 to cfg_xlen then noc3 tiles 0 to cfg_xlen
  for (g_i = 0; g_i < TILES; g_i++) begin
//    always_ff @(posedge clk) begin
//      if (rst) begin
//        flit_counter[g_i] = '0;
//      end else begin
//        if (!noc_data_void_in[g_i] && !noc_stop_out[g_i]) begin
//          flit_counter[g_i] = flit_counter[g_i] + 1;
//        end
//      end
//    end
    localparam int g_4 = 3*TILES + g_i;  // index shift for plane 4
    localparam int g_6 = 5*TILES + g_i;  // index shift for plane 6
    always_comb begin
      dma_noc_snd_data_in[g_i+0*TILES] = noc4_data_in[g_i];
      dma_noc_snd_data_in[g_i+1*TILES] = noc6_data_in[g_i];
      if ((!noc4_data_void_in[g_i]) && dma_noc_snd_data_in[g_i].header.preamble.head) begin
        dma_noc_snd_data_in[g_i+0*TILES].header.info.tile   = tile[g_4];  // order: tile 0, 1, 2, 3; 0, 1, 2, 3
        dma_noc_snd_data_in[g_i+0*TILES].header.info.plane  = plane[g_4]; // order: plane 0, 0, 0, 0; 1, 1, 1, 1; 2, 2, 2, 2;
      end
      if ((!noc6_data_void_in[g_i]) && dma_noc_snd_data_in[g_i+TILES].header.preamble.head) begin
        dma_noc_snd_data_in[g_i+1*TILES].header.info.tile   = tile[g_6];  // order: tile 0, 1, 2, 3; 0, 1, 2, 3
        dma_noc_snd_data_in[g_i+1*TILES].header.info.plane  = plane[g_6]; // order: plane 0, 0, 0, 0; 1, 1, 1, 1; 2, 2, 2, 2;
      end
    end

    // Plane 4
    router_fifo #(
      .BypassEnable(FifoBypassEnable),
      .Depth(NOC_QUEUE_DEPTH),
      .Width(DMADataWidth)
    ) input_queue_p4 (
      .clk(clk),
      .rst(rst),
      .rdreq(serialized_rd_fifo[g_i]),  // read every 2, 4, 8 cycles
      .wrreq(noc_snd_wrreq[g_4]),
      .data_in(dma_noc_snd_data_in[g_i]),
      .empty(noc_snd_empty[g_4]),
      .full(noc_snd_full[g_4]),
      .data_out(dma_noc_snd_data_out[g_i])
    );

    // Plane 6
    router_fifo #(
      .BypassEnable(FifoBypassEnable),
      .Depth(NOC_QUEUE_DEPTH),
      .Width(DMADataWidth)
    ) input_queue_p6 (
      .clk(clk),
      .rst(rst),
      .rdreq(serialized_rd_fifo[g_i+1*TILES]),
      .wrreq(noc_snd_wrreq[g_6]),
      .data_in(dma_noc_snd_data_in[g_i+1*TILES]),
      .empty(noc_snd_empty[g_6]),
      .full(noc_snd_full[g_6]),
      .data_out(dma_noc_snd_data_out[g_i+1*TILES])
    );

    assign noc_snd_wrreq[g_4] = ~noc4_data_void_in[g_i];
    assign noc_snd_wrreq[g_6] = ~noc6_data_void_in[g_i];
    assign in_unvalid_flit[g_4] = FifoBypassEnable ? noc_snd_empty[g_4] & noc4_data_void_in[g_i] : noc_snd_empty[g_4];
    assign in_unvalid_flit[g_6] = FifoBypassEnable ? noc_snd_empty[g_6] & noc6_data_void_in[g_i] : noc_snd_empty[g_6];
    assign in_valid_head[g_4] = dma_noc_snd_data_out[g_i].header.preamble.head & (~in_unvalid_flit[g_4]);
    assign in_valid_head[g_6] = dma_noc_snd_data_out[g_i+1*TILES].header.preamble.head & (~in_unvalid_flit[g_6]);
    assign noc4_stop_out[g_i] = FifoBypassEnable ? noc_snd_full[g_4] : ~(rd_fifo_or[g_4] & (~in_unvalid_flit[g_4]));
    assign noc6_stop_out[g_i] = FifoBypassEnable ? noc_snd_full[g_6] : ~(rd_fifo_or[g_6] & (~in_unvalid_flit[g_6]));
    assign request_input[g_4] = input_switch[g_4] & in_valid_head[g_4];
    assign request_input[g_6] = input_switch[g_6] & in_valid_head[g_6];

    always_comb begin
      rd_fifo_or[g_4] = 1'b0;
      rd_fifo_or[g_6] = 1'b0;
      for (int i = 0; i < W; i++) begin
        rd_fifo_or[g_4] = rd_fifo_or[g_4] | rd_fifo[i][g_4];
        rd_fifo_or[g_6] = rd_fifo_or[g_6] | rd_fifo[i][g_6];
      end
    end
//  end
//
//
//  for (g_i = 0; g_i < TILES; g_i) begin
//    g_4 = g_i + 3*TILES;
//    g_6 = g_i + 5*TILES;
    // Add serializer
    always_ff @(posedge clk) begin
      if (rst) begin
        beats[g_i] <= '0;
        beats[g_i+TILES] <= '0;
//        serialized_rd_fifo[g_i] <= 1'b0;
//        serialized_rd_fifo[g_i+TILES] <= 1'b0;
      end else begin
        if (rd_fifo_or[g_4] && ((!noc4_data_void_in[g_i] && noc_snd_empty[g_4]) || !noc_snd_empty[g_4])) begin // beats == '1, something different should happen? TODO 1 cycle delay bug
          beats[g_i] <= beats[g_i] + 1;
        end
        if (rd_fifo_or[g_6] && ((!noc6_data_void_in[g_i] && noc_snd_empty[g_6]) || !noc_snd_empty[g_6])) begin
          beats[g_i+TILES] <= beats[g_i+TILES] + 1;
        end
      end//if
    end//always_ff

    always_comb begin
      serialized_rd_fifo[g_i] = 1'b0;
      serialized_rd_fifo[g_i+TILES] = 1'b0;
      // issue read to input FIFO for plane 4
      if (beats[g_i] == '1 && rd_fifo_or[g_4] && ((!noc4_data_void_in[g_i] && noc_snd_empty[g_4]) || !noc_snd_empty[g_4])) begin
        serialized_rd_fifo[g_i] = 1'b1;
      end
      // plane 6
      if (beats[g_i+TILES] == '1 && rd_fifo_or[g_6] && ((!noc6_data_void_in[g_i] && noc_snd_empty[g_6]) || !noc_snd_empty[g_6])) begin
        serialized_rd_fifo[g_i+TILES] = 1'b1;
      end
    end
    // first beat: 66 bit chunk; rest: 64 bit chunks
    localparam int SEG = CHDataWidth-2;
    assign serialized_data_out[g_i] = (beats[g_i] == '0) ? dma_noc_snd_data_out[g_i].flit[DMADataWidth-1 -: CHDataWidth] : 
      {2'b00, dma_noc_snd_data_out[g_i].flit[(DMADataWidth - SEG * beats[g_i] - 3)  -: SEG]};
    assign serialized_data_out[g_i+TILES] = (beats[g_i+TILES] == '0) ? dma_noc_snd_data_out[g_i+TILES].flit[DMADataWidth-1 -: CHDataWidth] : 
      {2'b00, dma_noc_snd_data_out[g_i+TILES].flit[(DMADataWidth - SEG * beats[g_i+TILES] - 3) -: SEG]};
  end//for g_i
  

  for (g_i = 0; g_i < W; g_i++) begin
    inferred_async_fifo #(
      .g_data_width(CHDataWidth),
      .g_size(2*D2D_QUEUE_DEPTH)
    ) u_async_fifo (
      .rst_wr_n_i(rstn),
      .clk_wr_i(clk),
      .we_i(d2d_snd_wrreq[g_i]),
      .d_i(data_out[g_i]),
      .wr_full_o(d2d_snd_full[g_i]),
      .rst_rd_n_i(rstn),
      .clk_rd_i(d2d_clk_in),
      .rd_i(d2d_snd_rdreq[g_i]),
      .q_o(d2d_snd_data_out[g_i]),
      .rd_empty_o(d2d_snd_empty[g_i])
    );

    assign d2d_snd_rdreq[g_i] = (credits[g_i] == 0) ? 1'b0 : ~d2d_snd_empty[g_i];
    assign d2d_valid_out[g_i] = d2d_snd_rdreq[g_i];
    assign d2d_no_backpressure[g_i] = credits[g_i] != '0;
    assign d2d_stop_out[g_i] = FifoBypassEnable ? d2d_snd_full[g_i] : ~(d2d_no_backpressure[g_i] & (~d2d_snd_empty[g_i]));
    assign d2d_snd_wrreq[g_i] = ~data_void_out[g_i];
    assign request_channel[g_i] = channel_switch[g_i] & no_backpressure[g_i];
    //assign request_channel[g_i] = channel_switch[g_i] & d2d_no_backpressure[g_i]; // d2d_stop_out instead of d2d_no_backpressure?
    assign no_backpressure[g_i] = FifoBypassEnable ? ~d2d_stop_out[g_i] : (noc_credits[g_i] != '0);
//    assign forwarding_tail[g_i] = data_out_crossbar[g_i].header.preamble.tail & (~out_unvalid_flit[g_i]) & no_backpressure[g_i];  // change needed
//    assign forwarding_head[g_i] = data_out_crossbar[g_i].header.preamble.head & (~out_unvalid_flit[g_i]) & no_backpressure[g_i];  // change needed

    if (FifoBypassEnable) begin
      always_ff @(posedge clk) begin
        if (rst) begin
          data_void_out[g_i] <= 1'b1;
        end else begin
          if ((!final_routing_table_valid[g_i]) && no_backpressure[g_i]) begin
            data_void_out[g_i] <= 1'b1;
          end else if (no_backpressure[g_i]) begin
            data_void_out[g_i] <= out_unvalid_flit[g_i];
          end
        end
      end
      assign noc_credits[g_i] = '0;
    end else begin
      assign data_void_out[g_i] = (final_routing_table_valid[g_i] & no_backpressure[g_i]) ? out_unvalid_flit[g_i] : 1'b1;
      always_ff @(posedge clk) begin
        if (rst) begin
          noc_credits[g_i] <= 2*D2D_QUEUE_DEPTH;
        end else begin
          if (!data_void_out[g_i]) begin
            noc_credits[g_i] <= noc_credits[g_i] - d2d_stop_out[g_i];
          end else begin
            noc_credits[g_i] <= noc_credits[g_i] + ~d2d_stop_out[g_i];
          end
        end
      end
    end

//    assign credit_edge[g_i] = credit_in_sync2[g_i] ^ credit_in_old[g_i];

    always_ff @(posedge d2d_clk_in) begin
      if (rst) begin
//        credit_in_sync1[g_i] <= 1'b0;
//        credit_in_sync2[g_i] <= 1'b0;
//        credit_in_old[g_i] <= 1'b0;
        credits[g_i] <= 2*D2D_QUEUE_DEPTH;
        d2d_credit_in_int[g_i] <= 1'b0;
      end else begin
//        credit_in_sync1[g_i] <= d2d_credit_in[g_i];
//        credit_in_sync2[g_i] <= credit_in_sync1[g_i];
//        credit_in_old[g_i] <= credit_in_sync2[g_i];

//        credits[g_i] <= credits[g_i] + credit_edge[g_i] - d2d_snd_rdreq[g_i];

//        if ((credit_in_sync2[g_i] == credit_in_old[g_i]) && d2d_snd_rdreq[g_i] && (credits[g_i] != '0)) begin
        d2d_credit_in_int[g_i] <= d2d_credit_in[g_i];
        if (!d2d_credit_in_int[g_i] && d2d_snd_rdreq[g_i] && (credits[g_i] != '0)) begin
          credits[g_i] <= credits[g_i] - 1;
//        end else if ((credit_in_sync2[g_i] != credit_in_old[g_i]) && !d2d_snd_rdreq[g_i] && (credits[g_i] != D2D_QUEUE_DEPTH)) begin
        end else if (d2d_credit_in_int[g_i] && !d2d_snd_rdreq[g_i] && (credits[g_i] != 2*D2D_QUEUE_DEPTH)) begin
          credits[g_i] <= credits[g_i] + 1;
        end
      end
    end

    always_ff @(posedge clk) begin
      if (rst) begin
        last_flit[g_i] <= '0;
      end else begin
        if (FifoBypassEnable) begin
          if ((!out_unvalid_flit[g_i]) && no_backpressure[g_i] && final_routing_table_valid[g_i]) begin
            last_flit[g_i] <= data_out_crossbar[g_i];
          end
        end else begin
          if (!data_void_out[g_i]) begin
            last_flit[g_i] <= data_out_crossbar[g_i];
          end
        end
      end
    end

    assign data_out[g_i] = FifoBypassEnable ? last_flit[g_i] : data_out_crossbar[g_i];
    assign out_unvalid_flit[g_i] = final_routing_table_valid[g_i] ? in_unvalid_flit[final_routing_table[g_i]] : 1'b1; // in_unvalid_flit[final_routing_table[g_i]] & final_routing_table_valid[g_i];
//    assign rd_fifo[g_i][final_routing_table[g_i]] = no_backpressure[g_i] & final_routing_table_valid[g_i];
    always_comb begin
      rd_fifo[g_i] = '0;
      data_out_crossbar[g_i] = '0;
      forwarding_tail[g_i] = '0;
      forwarding_head[g_i] = '0;

      if (final_routing_table_valid[g_i]) begin
        rd_fifo[g_i][final_routing_table[g_i]] = no_backpressure[g_i];
        if (final_routing_table[g_i] < 3*TILES) begin // COH Planes 1-3
          data_out_crossbar[g_i] = coh_noc_snd_data_out[final_routing_table[g_i]];
          forwarding_tail[g_i] = data_out_crossbar[g_i].header.preamble.tail & (~out_unvalid_flit[g_i]) & no_backpressure[g_i];
          forwarding_head[g_i] = data_out_crossbar[g_i].header.preamble.head & (~out_unvalid_flit[g_i]) & no_backpressure[g_i];
        end
        if (final_routing_table[g_i] >= 3*TILES && final_routing_table[g_i] < 4*TILES) begin  // DMA Plane 4
          data_out_crossbar[g_i] = serialized_data_out[final_routing_table[g_i]-3*TILES];
          forwarding_tail[g_i] = dma_noc_snd_data_out[final_routing_table[g_i]-3*TILES].header.preamble.tail & (beats[final_routing_table[g_i]-3*TILES] == '1) & (~out_unvalid_flit[g_i]) & no_backpressure[g_i]; // timing might be terrible
          forwarding_head[g_i] = dma_noc_snd_data_out[final_routing_table[g_i]-3*TILES].header.preamble.head & (beats[final_routing_table[g_i]-3*TILES] == '0) & (~out_unvalid_flit[g_i]) & no_backpressure[g_i]; // timing might be terrible 
        end
        if (final_routing_table[g_i] >= 4*TILES && final_routing_table[g_i] < 5*TILES) begin  // MISC Plane 5
          data_out_crossbar[g_i] = misc_noc_snd_data_out[final_routing_table[g_i]-4*TILES];
          forwarding_tail[g_i] = data_out_crossbar[g_i].header.preamble.tail & (~out_unvalid_flit[g_i]) & no_backpressure[g_i];
          forwarding_head[g_i] = data_out_crossbar[g_i].header.preamble.head & (~out_unvalid_flit[g_i]) & no_backpressure[g_i];
        end
        if (final_routing_table[g_i] >= 5*TILES && final_routing_table[g_i] < 6*TILES) begin  // DMA Plane 6
          data_out_crossbar[g_i] = serialized_data_out[final_routing_table[g_i]-4*TILES];
          forwarding_tail[g_i] = dma_noc_snd_data_out[final_routing_table[g_i]-4*TILES].header.preamble.tail & (beats[final_routing_table[g_i]-4*TILES] == '1) & (~out_unvalid_flit[g_i]) & no_backpressure[g_i]; // fwd_tail on the last segment of tail 
          forwarding_head[g_i] = dma_noc_snd_data_out[final_routing_table[g_i]-4*TILES].header.preamble.head & (beats[final_routing_table[g_i]-4*TILES] == '0) & (~out_unvalid_flit[g_i]) & no_backpressure[g_i]; // fwd_head on the first segment of head
        end
      end
    end
  end

  d2d_arbiter #(
    .CHANNELS(TxP)
  )  d2d_arbiter_i (
    .clk(clk),
    .rst(rst),
    .request(request_input),
    .grant_valid_other_arbiter(grant_valid_channel),
    .grant_index(grant_index_i),
    .grant_valid(grant_valid_input)
  );
  d2d_arbiter #(
    .CHANNELS(W)
  )  d2d_arbiter_c (
    .clk(clk),
    .rst(rst),
    .request(request_channel),
    .grant_valid_other_arbiter(grant_valid_input),
    .grant_index(grant_index_c),
    .grant_valid(grant_valid_channel)
  );

  always_ff @(posedge clk) begin
    if (rst) begin
      routing_table <= '{default: '0};
      routing_table_valid <= '0;
      input_switch <= '1;
      channel_switch <= '1;
    end else begin
      if (grant_valid_channel & grant_valid_input) begin
        if ((grant_index_i < 3*TILES) && ~coh_noc_snd_data_out[grant_index_i].header.preamble.tail) begin
          routing_table[grant_index_c] <= grant_index_i;
          routing_table_valid[grant_index_c] <= 1'b1;
          input_switch[grant_index_i] <= 1'b0;
          channel_switch[grant_index_c] <= 1'b0;
        end
        if ((grant_index_i >= 4*TILES && grant_index_i < 5*TILES) && ~misc_noc_snd_data_out[grant_index_i-4*TILES].header.preamble.tail) begin
          routing_table[grant_index_c] <= grant_index_i;
          routing_table_valid[grant_index_c] <= 1'b1;
          input_switch[grant_index_i] <= 1'b0;
          channel_switch[grant_index_c] <= 1'b0;
        end
        if ((grant_index_i >= 3*TILES && grant_index_i < 4*TILES) && ~dma_noc_snd_data_out[grant_index_i-3*TILES].header.preamble.tail) begin
          routing_table[grant_index_c] <= grant_index_i;
          routing_table_valid[grant_index_c] <= 1'b1;
          input_switch[grant_index_i] <= 1'b0;
          channel_switch[grant_index_c] <= 1'b0;
        end
        if (((grant_index_i >= 5*TILES && grant_index_i < 6*TILES) && ~dma_noc_snd_data_out[grant_index_i-4*TILES].header.preamble.tail)) begin
          routing_table[grant_index_c] <= grant_index_i;
          routing_table_valid[grant_index_c] <= 1'b1;
          input_switch[grant_index_i] <= 1'b0;
          channel_switch[grant_index_c] <= 1'b0;
        end
      end
      for (int j = 0; j < W; j++) begin
        if (~forwarding_head[j] & forwarding_tail[j]) begin
          routing_table_valid[j] <= 1'b0;
          input_switch[routing_table[j]] <= 1'b1;
          channel_switch[j] <= 1'b1;
        end
      end
    end
  end
  
  always_comb begin
    final_routing_table = routing_table;
    final_routing_table_valid = routing_table_valid;

    if (grant_valid_channel & grant_valid_input) begin
      final_routing_table[grant_index_c] = grant_index_i;
      final_routing_table_valid[grant_index_c] = 1'b1;
    end
  end
endmodule
