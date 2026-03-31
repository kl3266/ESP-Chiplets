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
  input   logic d2d_rst,
  input   logic d2d_clk_in,
  
  // D2D Tx --> D2D Rx
  output  logic [CHDataWidth-1:0]   d2d_snd_data_out [TXCHANNELS-1:0],
  output  logic [TXCHANNELS-1:0]    d2d_valid_out,
  output  logic                     d2d_link_ready,

  // D2D Rx --> D2D Tx
  input   logic [TXCHANNELS-1:0]    d2d_credit_in,

  // NoC    --> D2D
  input   logic [COHDataWidth-1:0]  noc1_data_in [TILES-1:0],
  input   logic [COHDataWidth-1:0]  noc2_data_in [TILES-1:0],
  input   logic [COHDataWidth-1:0]  noc3_data_in [TILES-1:0],
  input   logic [DMADataWidth-1:0]  noc4_data_in [TILES-1:0],
  input   logic [MISCDataWidth-1:0] noc5_data_in [TILES-1:0],
  input   logic [DMADataWidth-1:0]  noc6_data_in [TILES-1:0],
  input   logic [CHDataWidth-1:0]   bypass_data_in,
  input   logic [TILES-1:0]         noc1_data_void_in,
  input   logic [TILES-1:0]         noc2_data_void_in,
  input   logic [TILES-1:0]         noc3_data_void_in,
  input   logic [TILES-1:0]         noc4_data_void_in,
  input   logic [TILES-1:0]         noc5_data_void_in,
  input   logic [TILES-1:0]         noc6_data_void_in,
  input   logic                     bypass_data_void_in,

  // D2D    --> NoC
  output  logic [TILES-1:0]         noc1_stop_out,
  output  logic [TILES-1:0]         noc2_stop_out,
  output  logic [TILES-1:0]         noc3_stop_out, 
  output  logic [TILES-1:0]         noc4_stop_out, 
  output  logic [TILES-1:0]         noc5_stop_out,
  output  logic [TILES-1:0]         noc6_stop_out,
  output  logic                     bypass_stop_out
  );

  localparam bit FifoBypassEnable = FlowControl == 1'b0;

  parameter int unsigned D2D_QUEUE_DEPTH = 8; 
  parameter int unsigned CreditWidth = $clog2(2*D2D_QUEUE_DEPTH + 1);
  localparam int unsigned D2D_FIFO_DEPTH = 4*D2D_QUEUE_DEPTH;
  parameter int unsigned TxP = TILES*6 + 1;
  parameter int unsigned W   = TXCHANNELS;
  parameter int unsigned NOC_QUEUE_DEPTH = 4;
  
  typedef logic [3:0] tile_array_t  [TxP-1:0];
  typedef logic [2:0] plane_array_t [TxP-1:0];

  function automatic tile_array_t generate_tile();
    tile_array_t result;
    for (int i = 0; i < TxP-1; i++) begin
      result[i] = i % TILES;
    end
    return result;
  endfunction

  function automatic plane_array_t generate_plane();
    plane_array_t result;
    for (int i = 0; i < TxP-1; i++) begin
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

  logic fifo_rst;
  logic rst_clk;
  logic rst_d2d;
  logic rstn_fifo_clk;
  logic rstn_fifo_d2d;
  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic fifo_rst_clk_sync_ff1;
  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic fifo_rst_clk_sync_ff2;
  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic fifo_rst_d2d_sync_ff1;
  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic fifo_rst_d2d_sync_ff2;

  coh_flit_t  flat_data_in  [TxP-1:0];
  logic rd_flit_or    [TxP-1:0];
  logic in_valid_flit [TxP-1:0];
  logic in_valid_head [TxP-1:0];
  logic in_valid_tail [TxP-1:0];

  // Asynchronous FIFO - Synchronized to CLK
  logic d2d_snd_wrreq [W-1:0];
  logic d2d_snd_full  [W-1:0];
  logic d2d_stop_out  [W-1:0];

  // Asynchronous FIFO - Synchronized to D2D_CLK_IN
  logic d2d_snd_rdreq [W-1:0];
  logic d2d_snd_empty [W-1:0];

  logic d2d_rdy [W-1:0];
  localparam int unsigned STARTUP_PULSES = 4;
  localparam int unsigned StartupCountWidth = $clog2(STARTUP_PULSES + 1);
  logic [StartupCountWidth-1:0] startup_credit_cnt [W-1:0];
  logic credit_evt [W-1:0];

  typedef enum logic [2:0] {
    state_reset,
    state_ack,
    state_train,
    state_ready
  } d2d_state_t;

  d2d_state_t state [W-1:0];

  // Sync FIFO & Async FIFO Credits
  typedef logic [CreditWidth-1:0] credits_t [W-1:0];
  credits_t credits;

  // Routing Table
  parameter int unsigned TxPWidth = $clog2(TxP);
  parameter int unsigned WWidth   = $clog2(W);
  typedef logic [TxPWidth-1:0] routing_table_t [W-1:0];
  routing_table_t routing_table, final_routing_table;
  logic routing_table_valid [W-1:0];
  logic final_routing_table_valid [W-1:0];

  // Arbiter Input and Control
  logic [TxP-1:0] request_input;
  logic input_switch  [TxP-1:0];
  logic [W-1:0] request_channel;
  logic channel_switch  [W-1:0];
  logic grant_valid_input, grant_valid_channel;

  // Arbiter Output Indices
  logic [WWidth-1:0]    grant_index_c;
  logic [TxPWidth-1:0]  grant_index_i;

  // Crossbar
  typedef logic [TxP-1:0] op_ip_arr_t [W-1:0];
  op_ip_arr_t rd_flit;
  coh_flit_t  data_out_crossbar [W-1:0];
  logic out_valid_flit  [W-1:0];
  logic no_backpressure [W-1:0];

  parameter int unsigned serW = $clog2((DMADataWidth-2)/(CHDataWidth-2));  // bitwidth necessary for serializer counter
  logic [serW-1:0] beats [2*TILES-1:0];
  logic serialized_rd_flit [2*TILES-1:0];

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
  assign rstn_fifo_clk = ~rst_clk;
  assign rstn_fifo_d2d = ~rst_d2d;

  genvar g_i;

  // Coherent NoC wiring -- need to wire noc1 tiles 0 to cfg_xlen then noc2
  // tiles 0 to cfg_xlen then noc3 tiles 0 to cfg_xlen
  for (g_i = 0; g_i < TILES; g_i++) begin
    always_comb begin
      flat_data_in[g_i+0*TILES] = noc1_data_in[g_i];
      flat_data_in[g_i+1*TILES] = noc2_data_in[g_i];
      flat_data_in[g_i+2*TILES] = noc3_data_in[g_i];
      if (in_valid_flit[g_i]) begin
        if (noc1_data_in[g_i][COHDataWidth-1]) begin
          flat_data_in[g_i+0*TILES].header.info.tile   = tile[g_i+0*TILES];  // order: tile 0, 1, 2, 3; 0, 1, 2, 3
          flat_data_in[g_i+0*TILES].header.info.plane  = plane[g_i+0*TILES]; // order: plane 0, 0, 0, 0; 1, 1, 1, 1; 2, 2, 2, 2;
        end
      end
      if (in_valid_flit[g_i+1*TILES]) begin
        if (noc2_data_in[g_i][COHDataWidth-1]) begin
          flat_data_in[g_i+1*TILES].header.info.tile   = tile[g_i+1*TILES];  // order: tile 0, 1, 2, 3; 0, 1, 2, 3
          flat_data_in[g_i+1*TILES].header.info.plane  = plane[g_i+1*TILES]; // order: plane 0, 0, 0, 0; 1, 1, 1, 1; 2, 2, 2, 2;
        end
      end
      if (in_valid_flit[g_i+2*TILES]) begin
        if (noc3_data_in[g_i][COHDataWidth-1]) begin
          flat_data_in[g_i+2*TILES].header.info.tile   = tile[g_i+2*TILES];  // order: tile 0, 1, 2, 3; 0, 1, 2, 3
          flat_data_in[g_i+2*TILES].header.info.plane  = plane[g_i+2*TILES]; // order: plane 0, 0, 0, 0; 1, 1, 1, 1; 2, 2, 2, 2;
        end
      end
    end

    assign in_valid_flit[g_i]           = ~noc1_data_void_in[g_i];
    assign in_valid_flit[g_i+1*TILES]   = ~noc2_data_void_in[g_i];
    assign in_valid_flit[g_i+2*TILES]   = ~noc3_data_void_in[g_i];   
    assign in_valid_head[g_i] = flat_data_in[g_i].header.preamble.head && in_valid_flit[g_i];
    assign in_valid_head[g_i+1*TILES] = flat_data_in[g_i+1*TILES].header.preamble.head && in_valid_flit[g_i+TILES];
    assign in_valid_head[g_i+2*TILES] = flat_data_in[g_i+2*TILES].header.preamble.head && in_valid_flit[g_i+2*TILES];
    assign in_valid_tail[g_i] = flat_data_in[g_i].header.preamble.tail && in_valid_flit[g_i];
    assign in_valid_tail[g_i+1*TILES] = flat_data_in[g_i+1*TILES].header.preamble.tail && in_valid_flit[g_i+TILES];
    assign in_valid_tail[g_i+2*TILES] = flat_data_in[g_i+2*TILES].header.preamble.tail && in_valid_flit[g_i+2*TILES];
    assign noc1_stop_out[g_i] = ~rd_flit_or[g_i] & in_valid_flit[g_i];
    assign noc2_stop_out[g_i] = ~rd_flit_or[g_i+1*TILES] & in_valid_flit[g_i+1*TILES];
    assign noc3_stop_out[g_i] = ~rd_flit_or[g_i+2*TILES] & in_valid_flit[g_i+2*TILES];
    assign request_input[g_i] = input_switch[g_i] & in_valid_head[g_i];
    assign request_input[g_i+1*TILES] = input_switch[g_i+1*TILES] & in_valid_head[g_i+1*TILES];
    assign request_input[g_i+2*TILES] = input_switch[g_i+2*TILES] & in_valid_head[g_i+2*TILES];

    always_comb begin
      rd_flit_or[g_i] = 1'b0;
      rd_flit_or[g_i+1*TILES] = 1'b0;
      rd_flit_or[g_i+2*TILES] = 1'b0;
      for (int i = 0; i < W; i++) begin
        rd_flit_or[g_i] = rd_flit_or[g_i] | rd_flit[i][g_i];
        rd_flit_or[g_i+1*TILES] = rd_flit_or[g_i+1*TILES] | rd_flit[i][g_i+1*TILES];
        rd_flit_or[g_i+2*TILES] = rd_flit_or[g_i+2*TILES] | rd_flit[i][g_i+2*TILES]; 
      end
    end
  end

  // Miscellaneous NoC wiring
  // tiles 0 to cfg_xlen then noc3 tiles 0 to cfg_xlen
  for (g_i = 0; g_i < TILES; g_i++) begin
    localparam int g_5 = 4*TILES + g_i;
    always_comb begin
      flat_data_in[g_5] = noc5_data_in[g_i];
      if (in_valid_flit[g_5]) begin
        if (noc5_data_in[g_i][MISCDataWidth-1]) begin
          flat_data_in[g_5].header.info.tile   = tile[g_5];  // order: tile 0, 1, 2, 3; 0, 1, 2, 3
          flat_data_in[g_5].header.info.plane  = plane[g_5]; // order: plane 0, 0, 0, 0; 1, 1, 1, 1; 2, 2, 2, 2;
        end
      end
    end

    assign in_valid_flit[g_5] = ~noc5_data_void_in[g_i];
    assign in_valid_head[g_5] = flat_data_in[g_5].header.preamble.head && in_valid_flit[g_5];
    assign in_valid_tail[g_5] = flat_data_in[g_5].header.preamble.tail && in_valid_flit[g_5];
    assign noc5_stop_out[g_i] = ~rd_flit_or[g_5] & in_valid_flit[g_5];
    assign request_input[g_5] = input_switch[g_5] & in_valid_head[g_5];

    always_comb begin
      rd_flit_or[g_5] = 1'b0;
      for (int i = 0; i < W; i++) begin
        rd_flit_or[g_5] = rd_flit_or[g_5] | rd_flit[i][g_5];
      end
    end
  end

  // DMA NoC wiring
  // tiles 0 to cfg_xlen then noc3 tiles 0 to cfg_xlen
  for (g_i = 0; g_i < TILES; g_i++) begin
    localparam int g_4 = 3*TILES + g_i;  // index shift for plane 4
    localparam int g_6 = 5*TILES + g_i;  // index shift for plane 6
    // Need Serializer
    if ((DMADataWidth-2)/(CHDataWidth-2)>1) begin
//      assign in_valid_head[g_4] = noc4_data_in[g_i][DMADataWidth-1] && (beats[g_i] == '0) && in_valid_flit[g_4];
//      assign in_valid_head[g_6] = noc6_data_in[g_i][DMADataWidth-1] && (beats[g_i+TILES] == '0) && in_valid_flit[g_6];
//      assign in_valid_tail[g_4] = noc4_data_in[g_i][DMADataWidth-2] && (beats[g_i] == '1) && in_valid_flit[g_4];
//      assign in_valid_tail[g_6] = noc6_data_in[g_i][DMADataWidth-2] && (beats[g_i+TILES] == '1) && in_valid_flit[g_6];
      assign in_valid_head[g_4] = flat_data_in[g_4].header.preamble.head && in_valid_flit[g_4];
      assign in_valid_head[g_6] = flat_data_in[g_6].header.preamble.head && in_valid_flit[g_6];
      assign in_valid_tail[g_4] = flat_data_in[g_4].header.preamble.tail && in_valid_flit[g_4];
      assign in_valid_tail[g_6] = flat_data_in[g_6].header.preamble.tail && in_valid_flit[g_6];
      assign noc4_stop_out[g_i] = ~serialized_rd_flit[g_i] & in_valid_flit[g_4];
      assign noc6_stop_out[g_i] = ~serialized_rd_flit[g_i+TILES] & in_valid_flit[g_6];

      // Add serializer
      always_ff @(posedge clk) begin
        if (rst_clk) begin
          beats[g_i] <= '0;
          beats[g_i+TILES] <= '0;
        end else begin
          if (rd_flit_or[g_4] && in_valid_flit[g_4]) begin
            beats[g_i] <= beats[g_i] + 1;
          end
          if (rd_flit_or[g_6] && in_valid_flit[g_6]) begin
            beats[g_i+TILES] <= beats[g_i+TILES] + 1;
          end
        end//if
      end//always_ff
  
      always_comb begin
        serialized_rd_flit[g_i] = 1'b0;
        serialized_rd_flit[g_i+TILES] = 1'b0;
        // issue read to input FIFO for plane 4
        if ((&beats[g_i]) && rd_flit_or[g_4] && in_valid_flit[g_4]) begin
          serialized_rd_flit[g_i] = 1'b1;
        end
        // plane 6
        if ((&beats[g_i+TILES]) && rd_flit_or[g_6] && in_valid_flit[g_6]) begin
          serialized_rd_flit[g_i+TILES] = 1'b1;
        end
      end
      // first beat: 66 bit chunk; rest: 64 bit chunks
      localparam int SEG = CHDataWidth-2;

      always_comb begin
        flat_data_in[g_4] = {noc4_data_in[g_i][DMADataWidth-1] & (~|beats[g_i]), noc4_data_in[g_i][DMADataWidth-2] & (&beats[g_i]), noc4_data_in[g_i][(DMADataWidth - SEG * beats[g_i] - 3) -: SEG]};
        flat_data_in[g_6] = {noc6_data_in[g_i][DMADataWidth-1] & (~|beats[g_i+TILES]), noc6_data_in[g_i][DMADataWidth-2] & (&beats[g_i+TILES]), noc6_data_in[g_i][(DMADataWidth - SEG * beats[g_i+TILES] - 3) -: SEG]};
//        flat_data_in[g_4] = (beats[g_i] == '0) ? noc4_data_in[g_i][DMADataWidth-1 -: CHDataWidth] :
//          {2'b00, noc4_data_in[g_i][(DMADataWidth - SEG * beats[g_i] - 3)  -: SEG]};
//        flat_data_in[g_6] = (beats[g_i+TILES] == '0) ? noc6_data_in[g_i][DMADataWidth-1 -: CHDataWidth] :
//          {2'b00, noc6_data_in[g_i][(DMADataWidth - SEG * beats[g_i+TILES] - 3) -: SEG]};
        if (in_valid_head[g_4]) begin
          flat_data_in[g_4].header.info.tile  = tile[g_4];
          flat_data_in[g_4].header.info.plane = plane[g_4];
        end
        if (in_valid_head[g_6]) begin
          flat_data_in[g_6].header.info.tile  = tile[g_6];
          flat_data_in[g_6].header.info.plane = plane[g_6];
        end
      end
    // No Serializer
    end else begin
      assign serialized_rd_flit[g_i] = '0;
      assign serialized_rd_flit[g_i+TILES] = '0;
      assign beats[g_i] = '0;
      assign beats[g_i+TILES] = '0;

      always_comb begin
        flat_data_in[g_4] = noc4_data_in[g_i];
        flat_data_in[g_6] = noc6_data_in[g_i];
        if (in_valid_flit[g_4]) begin
          if (noc4_data_in[g_i][DMADataWidth-1]) begin
            flat_data_in[g_4].header.info.tile   = tile[g_4];  // order: tile 0, 1, 2, 3; 0, 1, 2, 3
            flat_data_in[g_4].header.info.plane  = plane[g_4]; // order: plane 0, 0, 0, 0; 1, 1, 1, 1; 2, 2, 2, 2;
          end
        end
        if (in_valid_flit[g_6]) begin
          if (noc6_data_in[g_i][DMADataWidth-1]) begin
            flat_data_in[g_6].header.info.tile   = tile[g_6];  // order: tile 0, 1, 2, 3; 0, 1, 2, 3
            flat_data_in[g_6].header.info.plane  = plane[g_6]; // order: plane 0, 0, 0, 0; 1, 1, 1, 1; 2, 2, 2, 2;
          end
        end
      end

      assign in_valid_head[g_4] = flat_data_in[g_4].header.preamble.head && in_valid_flit[g_4];
      assign in_valid_head[g_6] = flat_data_in[g_6].header.preamble.head && in_valid_flit[g_6];
      assign in_valid_tail[g_4] = flat_data_in[g_4].header.preamble.tail && in_valid_flit[g_4];
      assign in_valid_tail[g_6] = flat_data_in[g_6].header.preamble.tail && in_valid_flit[g_6];
      assign noc4_stop_out[g_i] = ~rd_flit_or[g_4] & in_valid_flit[g_4];
      assign noc6_stop_out[g_i] = ~rd_flit_or[g_6] & in_valid_flit[g_6];
    end

    assign in_valid_flit[g_4] = ~noc4_data_void_in[g_i];
    assign in_valid_flit[g_6] = ~noc6_data_void_in[g_i];
    assign request_input[g_4] = input_switch[g_4] & in_valid_head[g_4];
    assign request_input[g_6] = input_switch[g_6] & in_valid_head[g_6];

    always_comb begin
      rd_flit_or[g_4] = 1'b0;
      rd_flit_or[g_6] = 1'b0;
      for (int i = 0; i < W; i++) begin
        rd_flit_or[g_4] = rd_flit_or[g_4] | rd_flit[i][g_4];
        rd_flit_or[g_6] = rd_flit_or[g_6] | rd_flit[i][g_6];
      end
    end
  end//for g_i

  // Bypass wiring
  parameter int unsigned BYPASS_IDX = TxP-1;
  assign flat_data_in[BYPASS_IDX] = bypass_data_in;
  assign in_valid_flit[BYPASS_IDX] = ~bypass_data_void_in;
  assign in_valid_head[BYPASS_IDX] = flat_data_in[BYPASS_IDX].header.preamble.head && in_valid_flit[BYPASS_IDX];
  assign in_valid_tail[BYPASS_IDX] = flat_data_in[BYPASS_IDX].header.preamble.tail && in_valid_flit[BYPASS_IDX];
  assign bypass_stop_out = ~rd_flit_or[BYPASS_IDX] & in_valid_flit[BYPASS_IDX];
  assign request_input[BYPASS_IDX] = input_switch[BYPASS_IDX] & in_valid_head[BYPASS_IDX];

  always_comb begin
    rd_flit_or[BYPASS_IDX] = 1'b0;
    for (int i = 0; i < W; i++) begin
      rd_flit_or[BYPASS_IDX] = rd_flit_or[BYPASS_IDX] | rd_flit[i][BYPASS_IDX];
    end
  end

  for (g_i = 0; g_i < W; g_i++) begin
    assign credit_evt[g_i] = d2d_credit_in[g_i];

    always_ff @(posedge d2d_clk_in) begin
      if (rst_d2d) begin
        state[g_i] <= state_reset;
        startup_credit_cnt[g_i] <= '0;
        d2d_rdy[g_i] <= 1'b0;
      end else begin
        if (state[g_i] == state_reset) begin
          state[g_i] <= state_ack;
        end
        if (state[g_i] == state_ack) begin
          if (startup_credit_cnt[g_i] == STARTUP_PULSES-1) begin
            d2d_rdy[g_i] <= 1'b0;
            startup_credit_cnt[g_i] <= '0;
            state[g_i] <= state_ready;  // for now, reset -> ready. Future, will have training
          end else begin
            d2d_rdy[g_i] <= 1'b1;
            if (credit_evt[g_i]) begin
              startup_credit_cnt[g_i] <= startup_credit_cnt[g_i] + 1'b1;
            end
          end
        end
      end
    end 

    inferred_async_fifo #(
      .g_data_width(CHDataWidth),
      .g_size(D2D_FIFO_DEPTH)
    ) u_async_fifo (
      .rst_wr_n_i(rstn_fifo_clk),
      .clk_wr_i(clk),
      .we_i(d2d_snd_wrreq[g_i]),
      .d_i(data_out_crossbar[g_i]),
      .wr_full_o(d2d_snd_full[g_i]),
      .rst_rd_n_i(rstn_fifo_d2d),
      .clk_rd_i(d2d_clk_in),
      .rd_i(d2d_snd_rdreq[g_i]),
      .q_o(d2d_snd_data_out[g_i]),
      .rd_empty_o(d2d_snd_empty[g_i])
    );

    assign d2d_snd_rdreq[g_i] = ((credits[g_i] == 0) ? 1'b0 : ~d2d_snd_empty[g_i]) && (state[g_i] == state_ready);
    assign d2d_valid_out[g_i] = d2d_snd_rdreq[g_i] || d2d_rdy[g_i];
    assign d2d_stop_out[g_i] = d2d_snd_full[g_i];
    assign d2d_snd_wrreq[g_i] = out_valid_flit[g_i] && no_backpressure[g_i];
    assign request_channel[g_i] = channel_switch[g_i] && no_backpressure[g_i];
    assign no_backpressure[g_i] = ~d2d_stop_out[g_i];

    always_ff @(posedge d2d_clk_in) begin
      if (rst_d2d) begin
        credits[g_i] <= 2*D2D_QUEUE_DEPTH;
      end else begin
        assert (!((state[g_i] == state_ready) && credit_evt[g_i] && (credits[g_i] == 2*D2D_QUEUE_DEPTH)))
          else $fatal(1, "d2d_tx credit overflow: channel %0d received a credit event in state_ready while credits == %0d", g_i, 2*D2D_QUEUE_DEPTH);
        if (!credit_evt[g_i] && d2d_snd_rdreq[g_i] && (credits[g_i] != '0)) begin
          credits[g_i] <= credits[g_i] - 1;
        end else if (credit_evt[g_i] && !d2d_snd_rdreq[g_i] && (credits[g_i] != 2*D2D_QUEUE_DEPTH)) begin
          credits[g_i] <= credits[g_i] + 1;
        end
      end
    end

    assign out_valid_flit[g_i] = final_routing_table_valid[g_i] ? in_valid_flit[final_routing_table[g_i]] : 1'b0;

    always_comb begin
      rd_flit[g_i] = '0;
      data_out_crossbar[g_i] = flat_data_in[final_routing_table[g_i]];

      if (final_routing_table_valid[g_i]) begin
        rd_flit[g_i][final_routing_table[g_i]] = no_backpressure[g_i];
      end
    end
  end

  always_comb begin
    d2d_link_ready = 1'b1;
    for (int i = 0; i < W; i++) begin
      d2d_link_ready &= (state[i] == state_ready);
    end
  end

  if (TxP > 24) begin
    d2d_arbiter_30 #(
      .CHANNELS(TxP)
    )  d2d_arbiter_i (
      .clk(clk),
      .rst(rst_clk),
      .enable(|request_channel),
      .request(request_input),
      .grant_valid_other_arbiter(grant_valid_channel),
      .grant_index(grant_index_i),
      .grant_valid(grant_valid_input)
    );
  end else begin
    d2d_arbiter_24 #(
      .CHANNELS(TxP)
    )  d2d_arbiter_i (
      .clk(clk),
      .rst(rst_clk),
      .enable(|request_channel),
      .request(request_input),
      .grant_valid_other_arbiter(grant_valid_channel),
      .grant_index(grant_index_i),
      .grant_valid(grant_valid_input)
    );
  end

  if (W == 2) begin
    d2d_arbiter_2 #(
      .CHANNELS(W)
    )  d2d_arbiter_c (
      .clk(clk),
      .rst(rst_clk),
      .enable(|request_input),
      .request(request_channel),
      .grant_valid_other_arbiter(grant_valid_input),
      .grant_index(grant_index_c),
      .grant_valid(grant_valid_channel)
    );
  end else if (W <= 4) begin
    d2d_arbiter_4 #(
      .CHANNELS(W)
    )  d2d_arbiter_c (
      .clk(clk),
      .rst(rst_clk),
      .enable(|request_input),
      .request(request_channel),
      .grant_valid_other_arbiter(grant_valid_input),
      .grant_index(grant_index_c),
      .grant_valid(grant_valid_channel)
    );
  end else begin
    d2d_arbiter_9 #(
      .CHANNELS(W)
    )  d2d_arbiter_c (
      .clk(clk),
      .rst(rst_clk),
      .enable(|request_input),
      .request(request_channel),
      .grant_valid_other_arbiter(grant_valid_input),
      .grant_index(grant_index_c),
      .grant_valid(grant_valid_channel)
    );
  end

  always_ff @(posedge clk) begin
    if (rst_clk) begin
      routing_table <= '{default: '0};
      routing_table_valid <= '{default: 1'b0};
      input_switch <= '{default: 1'b1};
      channel_switch <= '{default: 1'b1};
    end else begin
      if (grant_valid_channel & grant_valid_input) begin
        if (~in_valid_tail[grant_index_i]) begin
          routing_table[grant_index_c] <= grant_index_i;
          routing_table_valid[grant_index_c] <= 1'b1;
          input_switch[grant_index_i] <= 1'b0;
          channel_switch[grant_index_c] <= 1'b0;
        end
      end
      for (int j = 0; j < W; j++) begin
        if (routing_table_valid[j] & ~in_valid_head[routing_table[j]] & in_valid_tail[routing_table[j]] & no_backpressure[j]) begin
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
