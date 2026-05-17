module d2d_tx_tree #(
    parameter int unsigned T = 8,
    parameter int unsigned CMDataWidth = 66,
    parameter int unsigned DMADataWidth = 258,
    parameter int unsigned RATE = 2, // 2 = DDR; 1 = SDR
    parameter int unsigned CLK_RATIO = 1, // d2d_clk / noc_clk
    parameter int unsigned CHDataWidth = RATE*CLK_RATIO*CMDataWidth,
    parameter logic [1:0] d2d_position,
    parameter noc::chip_xy_t chip_coordinates 

  )
(
  input  logic clk,
  input  logic rst,
  input  logic [CMDataWidth-1:0] noc1_data_in [T-1:0],
  input  logic [CMDataWidth-1:0] noc2_data_in [T-1:0],
  input  logic [CMDataWidth-1:0] noc3_data_in [T-1:0],
  input  logic [DMADataWidth-1:0] noc4_data_in [T-1:0],
  input  logic [CMDataWidth-1:0] noc5_data_in [T-1:0],
  input  logic [DMADataWidth-1:0] noc6_data_in [T-1:0],
  input  logic noc1_data_void_in [T-1:0],
  input  logic noc2_data_void_in [T-1:0],
  input  logic noc3_data_void_in [T-1:0],
  input  logic noc4_data_void_in [T-1:0],
  input  logic noc5_data_void_in [T-1:0],
  input  logic noc6_data_void_in [T-1:0],
  input  logic [CMDataWidth-1:0] cmbypass_data_in,
  input  logic cmbypass_data_void_in,
  input  logic [2*CMDataWidth-1:0] dmabypass_data_in,
  input  logic dmabypass_data_void_in,
  output logic noc1_stop_out [T-1:0],
  output logic noc2_stop_out [T-1:0],
  output logic noc3_stop_out [T-1:0],
  output logic noc4_stop_out [T-1:0],
  output logic noc5_stop_out [T-1:0],
  output logic noc6_stop_out [T-1:0],
  output logic cmbypass_stop_out,
  output logic dmabypass_stop_out,
  output logic [CHDataWidth-1:0] data_out,
  output logic [(CHDataWidth / CMDataWidth)-1:0] data_void_out,
  input  logic [(CHDataWidth / CMDataWidth)-1:0] stop_in
);

  localparam int unsigned CM_STREAMS = CHDataWidth / CMDataWidth;
  localparam int unsigned DMA_BEAT_WIDTH = 2 * CMDataWidth;
  localparam int unsigned DMA_STREAMS = CHDataWidth / DMA_BEAT_WIDTH;
  localparam int unsigned DMA_INPUTS = T;
  localparam int unsigned CM_CHANNELS = CM_STREAMS / 2;
  localparam int unsigned PreambleWidth = $bits(noc::preamble_t);
  localparam int unsigned CmPayloadWidth = CMDataWidth - PreambleWidth;
  localparam int unsigned DmaBeatPayloadWidth = 2 * CmPayloadWidth;
  localparam int unsigned DmaPayloadWidth = DMADataWidth - PreambleWidth;

  localparam int CmReservedWidth =
      CMDataWidth - $bits(noc::preamble_t) - 3*$bits(noc::xy_t) - $bits(noc::message_t) -
      $bits(noc::tile_t) - $bits(noc::plane_t) - $bits(noc::routing_lock_t) -
      3*$bits(noc::chip_xy_t) - $bits(noc::direction_t) - $bits(noc::mcast_t) - $bits(noc::pkt_type_t);

  typedef struct packed {
    noc::xy_t source;
    noc::xy_t destination;
    noc::message_t message;
    noc::tile_t tile;
    noc::plane_t plane;
    noc::routing_lock_t routing_lock;
    noc::chip_xy_t source_chip;
    noc::chip_xy_t destination_chip;
    noc::pkt_type_t uni_or_mcast;  // 0 - unicast; 1 - mcast; for D2D RX use
    noc::mcast_t mcast_type;    // 0 - tree; 1 - brcp
    noc::xy_t destination_mask; // unicast -- all 0
    logic [CmReservedWidth-1:0] reserved;
    noc::chip_xy_t destination_chip_mask; // use this field and 2 bits of reserved for unicast reserved bits; KL address D2D RX & bypass router routing to accommodate this
  } cm_packet_info_t;

  typedef struct packed {
    noc::preamble_t preamble;
    cm_packet_info_t info;
    noc::direction_t routing;
  } cm_header_t;

  typedef union packed {
    cm_header_t header;
    logic [CMDataWidth-1:0] flit;
  } cm_flit_t;

  function automatic int unsigned next_level_count(
      input int unsigned current_count,
      input int unsigned target_count
  );
    int unsigned next_count;
    begin
      if (current_count <= target_count) begin
        next_count = current_count;
      end else begin
        next_count = (current_count + 3) / 4;
        if (next_count < target_count) begin
          next_count = target_count;
        end
      end
      return next_count;
    end
  endfunction

  function automatic int unsigned level_count(
      input int unsigned source_count,
      input int unsigned level,
      input int unsigned target_count
  );
    int unsigned count;
    begin
      count = source_count;
      for (int l = 0; l < level; l++) begin
        count = next_level_count(count, target_count);
      end
      return count;
    end
  endfunction

  function automatic int unsigned calc_reduce_levels(
      input int unsigned source_count,
      input int unsigned target_count
  );
    int unsigned count;
    int unsigned levels;
    begin
      count = source_count;
      levels = 0;
      while (count > target_count) begin
        count = next_level_count(count, target_count);
        levels++;
      end
      return levels;
    end
  endfunction

  function automatic int unsigned group_size(
      input int unsigned current_count,
      input int unsigned next_count,
      input int unsigned node
  );
    int unsigned base_size;
    int unsigned remainder;
    begin
      base_size = current_count / next_count;
      remainder = current_count % next_count;
      return base_size + ((node < remainder) ? 1 : 0);
    end
  endfunction

  function automatic int unsigned group_start(
      input int unsigned current_count,
      input int unsigned next_count,
      input int unsigned node
  );
    int unsigned base_size;
    int unsigned remainder;
    begin
      base_size = current_count / next_count;
      remainder = current_count % next_count;
      return (node * base_size) + ((node < remainder) ? node : remainder);
    end
  endfunction

  localparam int unsigned DMA_ROOTS = (DMA_INPUTS < DMA_STREAMS) ? DMA_INPUTS : DMA_STREAMS;
  localparam int unsigned DMA_REDUCE_LEVELS = calc_reduce_levels(DMA_INPUTS, DMA_ROOTS);

  logic [CMDataWidth-1:0] cm_tile_data [T-1:0];
  logic cm_tile_void [T-1:0];
  logic cm_tile_stop [T-1:0];
  logic [CMDataWidth-1:0] cm_group_top_data [CM_CHANNELS-1:0];
  logic cm_group_top_void [CM_CHANNELS-1:0];
  logic [CMDataWidth-1:0] cm_group_bot_data [CM_CHANNELS-1:0];
  logic cm_group_bot_void [CM_CHANNELS-1:0];

  logic [DMA_BEAT_WIDTH-1:0] dma_stage_data [0:DMA_REDUCE_LEVELS][DMA_INPUTS-1:0];
  logic dma_stage_void [0:DMA_REDUCE_LEVELS][DMA_INPUTS-1:0];
  logic dma_stage_stop [0:DMA_REDUCE_LEVELS][DMA_INPUTS-1:0];
  logic [DMA_BEAT_WIDTH-1:0] dma_final_data [DMA_STREAMS-1:0];
  logic dma_final_void [DMA_STREAMS-1:0];
  logic [CHDataWidth-1:0] cm_tree_data_out_int;
  logic [CHDataWidth-1:0] cm_data_out_int;
  logic [CHDataWidth-1:0] dma_tree_data_out_int;
  logic [CHDataWidth-1:0] dma_data_out_int;
  logic [CM_STREAMS-1:0] cm_tree_void_out_int;
  logic [CM_STREAMS-1:0] cm_void_out_int;
  logic [CM_STREAMS-1:0] dma_tree_void_out_int;
  logic [CM_STREAMS-1:0] dma_void_out_int;
  logic [CM_STREAMS-1:0] cm_tree_stop_out;
  logic [CM_STREAMS-1:0] cm_root_stop_out;
  logic dma_root_stop_out;
  logic dma_tree_stop_out;
  logic [CHDataWidth-1:0] dmabypass_data_out_int;
  logic [CM_STREAMS-1:0] dmabypass_void_out_int;
  logic [CHDataWidth-1:0] root_data_out;
  logic [CM_STREAMS-1:0] root_data_void_out;

  function automatic noc::direction_t tx_next_chip_routing(
      input noc::chip_xy_t destination_chip,
      input noc::chip_xy_t destination_chip_mask,
      input noc::pkt_type_t uni_or_mcast
  );
    noc::chip_xy_t effective_mask;
    noc::chip_xy_t next_chip;
    logic match_x;
    logic match_y;
    begin
      effective_mask = uni_or_mcast ? destination_chip_mask : '0;

      next_chip = chip_coordinates;
      if (d2d_position == 2'b00) begin
        next_chip.y = chip_coordinates.y - 1'b1;
      end else if (d2d_position == 2'b01) begin
        next_chip.y = chip_coordinates.y + 1'b1;
      end else if (d2d_position == 2'b10) begin
        next_chip.x = chip_coordinates.x - 1'b1;
      end else begin
        next_chip.x = chip_coordinates.x + 1'b1;
      end

      match_x = (((next_chip.x ^ destination_chip.x) & ~effective_mask.x) == '0);
      match_y = (((next_chip.y ^ destination_chip.y) & ~effective_mask.y) == '0);

      tx_next_chip_routing = '0;
      tx_next_chip_routing.go_local =
          (d2d_position < 2) ? match_y : (match_x && match_y);
    end
  endfunction

  initial begin
    if ((CHDataWidth % CMDataWidth) != 0) begin
      $error("d2d_tree expects CHDataWidth to be an integer multiple of CMDataWidth");
    end
    if ((CHDataWidth % DMA_BEAT_WIDTH) != 0) begin
      $error("d2d_tree expects CHDataWidth to be an integer multiple of 2*CMDataWidth");
    end
    if ((DmaPayloadWidth % DmaBeatPayloadWidth) != 0) begin
      $error("d2d_tree expects DMA payload bits to be an integer multiple of %0d",
             DmaBeatPayloadWidth);
    end
    if (CHDataWidth < (2 * CMDataWidth)) begin
      $error("d2d_tree expects CHDataWidth >= 2*CMDataWidth for the DMA bypass lane");
    end
    if ((T < 2) || (T > 16)) begin
      $error("d2d_tree currently expects 2 <= T <= 16");
    end
    if (CM_STREAMS < 2) begin
      $error("d2d_tree expects at least two CM streams for TOP/BOT CM selection");
    end
    if ((CM_STREAMS % 2) != 0) begin
      $error("d2d_tree expects an even number of CM streams");
    end
    if (T < CM_CHANNELS) begin
      $error("d2d_tree expects at least one tile per CM channel group");
    end
    if (CM_STREAMS != 2) begin
      $error("cm_3to2_arbiter_max_throughput wiring expects CM_STREAMS == 2");
    end
  end

  genvar g_i;
  generate
    // First collapse the per-tile CM planes locally, then choose one TOP and
    // one BOT winner per physical channel group.
    for (g_i = 0; g_i < T; g_i++) begin : gen_cm_leaf_routers
      localparam int unsigned TILE_ID = g_i;
      logic [CMDataWidth-1:0] leaf_data_in [3:0];
      logic leaf_data_void_in [3:0];
      logic leaf_stop_out [3:0];
      logic [CMDataWidth-1:0] leaf_router_data;
      logic leaf_router_void;
      logic leaf_router_stop;
      cm_flit_t leaf_flit_in [3:0];

      always_comb begin
        leaf_flit_in[0].flit = noc1_data_in[g_i];
        leaf_flit_in[1].flit = noc2_data_in[g_i];
        leaf_flit_in[2].flit = noc3_data_in[g_i];
        leaf_flit_in[3].flit = noc5_data_in[g_i];

        if (!noc1_data_void_in[g_i] && leaf_flit_in[0].header.preamble.head) begin
          leaf_flit_in[0].header.info.tile = noc::tile_t'(TILE_ID);
          leaf_flit_in[0].header.info.plane = noc::plane_t'(0);
          leaf_flit_in[0].header.info.routing_lock = 1'b0;
        end
        if (!noc2_data_void_in[g_i] && leaf_flit_in[1].header.preamble.head) begin
          leaf_flit_in[1].header.info.tile = noc::tile_t'(TILE_ID);
          leaf_flit_in[1].header.info.plane = noc::plane_t'(1);
          leaf_flit_in[1].header.info.routing_lock = 1'b0;
        end
        if (!noc3_data_void_in[g_i] && leaf_flit_in[2].header.preamble.head) begin
          leaf_flit_in[2].header.info.tile = noc::tile_t'(TILE_ID);
          leaf_flit_in[2].header.info.plane = noc::plane_t'(2);
          leaf_flit_in[2].header.info.routing_lock = 1'b0;
        end
        if (!noc5_data_void_in[g_i] && leaf_flit_in[3].header.preamble.head) begin
          leaf_flit_in[3].header.info.tile = noc::tile_t'(TILE_ID);
          leaf_flit_in[3].header.info.plane = noc::plane_t'(3);
          leaf_flit_in[3].header.info.routing_lock = 1'b0;
        end
      end

      assign leaf_data_in[0] = leaf_flit_in[0].flit;
      assign leaf_data_in[1] = leaf_flit_in[1].flit;
      assign leaf_data_in[2] = leaf_flit_in[2].flit;
      assign leaf_data_in[3] = leaf_flit_in[3].flit;
      assign leaf_data_void_in[0] = noc1_data_void_in[g_i];
      assign leaf_data_void_in[1] = noc2_data_void_in[g_i];
      assign leaf_data_void_in[2] = noc3_data_void_in[g_i];
      assign leaf_data_void_in[3] = noc5_data_void_in[g_i];

      assign noc1_stop_out[g_i] = leaf_stop_out[0];
      assign noc2_stop_out[g_i] = leaf_stop_out[1];
      assign noc3_stop_out[g_i] = leaf_stop_out[2];
      assign noc5_stop_out[g_i] = leaf_stop_out[3];

      d2d_mux #(
        .N(4),
        .DataWidth(CMDataWidth),
        .P_DMA(1'b0),
        .FIRST_STAGE(1'b0)
      ) cm_leaf_router_i (
        .clk(clk),
        .rst(rst),
        .noc_data_in(leaf_data_in),
        .noc_data_void_in(leaf_data_void_in),
        .noc_stop_out(leaf_stop_out),
        .data_out(leaf_router_data),
        .data_void_out(leaf_router_void),
        .stop_in(leaf_router_stop)
      );

      relay_station #(
        .width(CMDataWidth)
      ) cm_leaf_relay_i (
        .clk(clk),
        .rst(rst),
        .data_in(leaf_router_data),
        .data_void_in(leaf_router_void),
        .stop_in(cm_tile_stop[g_i]),
        .data_out(cm_tile_data[g_i]),
        .data_void_out(cm_tile_void[g_i]),
        .stop_out(leaf_router_stop)
      );
    end

    for (g_i = 0; g_i < T; g_i++) begin : gen_dma_leaf_routers
      localparam int unsigned TILE_ID = g_i;
      logic [DMA_BEAT_WIDTH-1:0] dma_leaf_data_in [1:0];
      logic dma_leaf_data_void_in [1:0];
      logic dma_leaf_stop_out [1:0];
      logic [DMA_BEAT_WIDTH-1:0] dma_leaf_router_data;
      logic dma_leaf_router_void;
      logic dma_leaf_router_stop;

      d2d_dma_serializer #(
        .CHDataWidth(DMA_BEAT_WIDTH),
        .DMADataWidth(DMADataWidth),
        .TILE_ID(TILE_ID),
        .PLANE_ID(4)
      ) noc4_serializer_i (
        .clk(clk),
        .rst(rst),
        .data_in(noc4_data_in[g_i]),
        .data_void_in(noc4_data_void_in[g_i]),
        .stop_out(noc4_stop_out[g_i]),
        .data_out(dma_leaf_data_in[0]),
        .data_void_out(dma_leaf_data_void_in[0]),
        .stop_in(dma_leaf_stop_out[0])
      );

      d2d_dma_serializer #(
        .CHDataWidth(DMA_BEAT_WIDTH),
        .DMADataWidth(DMADataWidth),
        .TILE_ID(TILE_ID),
        .PLANE_ID(5)
      ) noc6_serializer_i (
        .clk(clk),
        .rst(rst),
        .data_in(noc6_data_in[g_i]),
        .data_void_in(noc6_data_void_in[g_i]),
        .stop_out(noc6_stop_out[g_i]),
        .data_out(dma_leaf_data_in[1]),
        .data_void_out(dma_leaf_data_void_in[1]),
        .stop_in(dma_leaf_stop_out[1])
      );

      d2d_mux #(
        .N(2),
        .DataWidth(DMA_BEAT_WIDTH),
        .P_DMA(1'b0),
        .FIRST_STAGE(1'b0)
      ) dma_leaf_router_i (
        .clk(clk),
        .rst(rst),
        .noc_data_in(dma_leaf_data_in),
        .noc_data_void_in(dma_leaf_data_void_in),
        .noc_stop_out(dma_leaf_stop_out),
        .data_out(dma_leaf_router_data),
        .data_void_out(dma_leaf_router_void),
        .stop_in(dma_leaf_router_stop)
      );

      relay_station #(
        .width(DMA_BEAT_WIDTH)
      ) dma_leaf_relay_i (
        .clk(clk),
        .rst(rst),
        .data_in(dma_leaf_router_data),
        .data_void_in(dma_leaf_router_void),
        .stop_in(dma_stage_stop[0][g_i]),
        .data_out(dma_stage_data[0][g_i]),
        .data_void_out(dma_stage_void[0][g_i]),
        .stop_out(dma_leaf_router_stop)
      );
    end

    for (genvar ch = 0; ch < CM_CHANNELS; ch++) begin : gen_cm_channel_groups
      localparam int unsigned GROUP_START = group_start(T, CM_CHANNELS, ch);
      localparam int unsigned GROUP_SIZE = group_size(T, CM_CHANNELS, ch);
      localparam int unsigned TOP_COUNT = GROUP_SIZE / 2;
      localparam int unsigned BOT_START = GROUP_START + TOP_COUNT;
      localparam int unsigned BOT_COUNT = GROUP_SIZE - TOP_COUNT;
      localparam int unsigned TOP_LANE = 2 * ch + 1;
      localparam int unsigned BOT_LANE = 2 * ch;
      if (GROUP_SIZE == 1) begin : gen_singleton_group
        assign cm_group_top_data[ch] = cm_tile_data[GROUP_START];
        assign cm_group_top_void[ch] = cm_tile_void[GROUP_START];
        assign cm_tile_stop[GROUP_START] = cm_tree_stop_out[TOP_LANE];
        assign cm_group_bot_data[ch] = '0;
        assign cm_group_bot_void[ch] = 1'b1;
      end else begin : gen_split_group
        logic [CMDataWidth-1:0] top_reduce_data_in [TOP_COUNT-1:0];
        logic top_reduce_void_in [TOP_COUNT-1:0];
        logic top_reduce_stop_out [TOP_COUNT-1:0];
        logic [CMDataWidth-1:0] bot_reduce_data_in [BOT_COUNT-1:0];
        logic bot_reduce_void_in [BOT_COUNT-1:0];
        logic bot_reduce_stop_out [BOT_COUNT-1:0];

        for (genvar idx = 0; idx < TOP_COUNT; idx++) begin : gen_top_inputs
          localparam int unsigned TILE_IDX = GROUP_START + idx;
          assign top_reduce_data_in[idx] = cm_tile_data[TILE_IDX];
          assign top_reduce_void_in[idx] = cm_tile_void[TILE_IDX];
          assign cm_tile_stop[TILE_IDX] = top_reduce_stop_out[idx];
        end

        for (genvar idx = 0; idx < BOT_COUNT; idx++) begin : gen_bot_inputs
          localparam int unsigned TILE_IDX = BOT_START + idx;
          assign bot_reduce_data_in[idx] = cm_tile_data[TILE_IDX];
          assign bot_reduce_void_in[idx] = cm_tile_void[TILE_IDX];
          assign cm_tile_stop[TILE_IDX] = bot_reduce_stop_out[idx];
        end

        d2d_quaternary_reduce_tree #(
          .N(TOP_COUNT),
          .DataWidth(CMDataWidth),
          .P_DMA(1'b0)
        ) cm_top_reduce_i (
          .clk(clk),
          .rst(rst),
          .noc_data_in(top_reduce_data_in),
          .noc_data_void_in(top_reduce_void_in),
          .noc_stop_out(top_reduce_stop_out),
          .data_out(cm_group_top_data[ch]),
          .data_void_out(cm_group_top_void[ch]),
          .stop_in(cm_tree_stop_out[TOP_LANE])
        );

        d2d_quaternary_reduce_tree #(
          .N(BOT_COUNT),
          .DataWidth(CMDataWidth),
          .P_DMA(1'b0)
        ) cm_bot_reduce_i (
          .clk(clk),
          .rst(rst),
          .noc_data_in(bot_reduce_data_in),
          .noc_data_void_in(bot_reduce_void_in),
          .noc_stop_out(bot_reduce_stop_out),
          .data_out(cm_group_bot_data[ch]),
          .data_void_out(cm_group_bot_void[ch]),
          .stop_in(cm_tree_stop_out[BOT_LANE])
        );
      end
    end

    for (genvar level = 1; level <= DMA_REDUCE_LEVELS; level++) begin : gen_dma_reduce_levels
      localparam int unsigned CUR_COUNT = level_count(DMA_INPUTS, level - 1, DMA_STREAMS);
      localparam int unsigned NEXT_COUNT = level_count(DMA_INPUTS, level, DMA_STREAMS);

      for (genvar node = 0; node < NEXT_COUNT; node++) begin : gen_dma_reduce_nodes
        localparam int unsigned ARITY = group_size(CUR_COUNT, NEXT_COUNT, node);
        localparam int unsigned START = group_start(CUR_COUNT, NEXT_COUNT, node);

        if (ARITY == 1) begin : gen_passthrough
          assign dma_stage_data[level][node] = dma_stage_data[level-1][START];
          assign dma_stage_void[level][node] = dma_stage_void[level-1][START];
          assign dma_stage_stop[level-1][START] = dma_stage_stop[level][node];
        end else begin : gen_router
          logic [DMA_BEAT_WIDTH-1:0] reduce_data_in [ARITY-1:0];
          logic reduce_data_void_in [ARITY-1:0];
          logic reduce_stop_out [ARITY-1:0];
          logic [DMA_BEAT_WIDTH-1:0] reduce_router_data;
          logic reduce_router_void;
          logic reduce_router_stop;

          for (genvar port = 0; port < ARITY; port++) begin : gen_router_ports
            assign reduce_data_in[port] = dma_stage_data[level-1][START + port];
            assign reduce_data_void_in[port] = dma_stage_void[level-1][START + port];
            assign dma_stage_stop[level-1][START + port] = reduce_stop_out[port];
          end

          d2d_mux #(
            .N(ARITY),
            .DataWidth(DMA_BEAT_WIDTH),
            .P_DMA(1'b0),
            .FIRST_STAGE(1'b0)
          ) dma_reduce_router_i (
            .clk(clk),
            .rst(rst),
            .noc_data_in(reduce_data_in),
            .noc_data_void_in(reduce_data_void_in),
            .noc_stop_out(reduce_stop_out),
            .data_out(reduce_router_data),
            .data_void_out(reduce_router_void),
            .stop_in(reduce_router_stop)
          );

          relay_station #(
            .width(DMA_BEAT_WIDTH)
          ) dma_reduce_relay_i (
            .clk(clk),
            .rst(rst),
            .data_in(reduce_router_data),
            .data_void_in(reduce_router_void),
            .stop_in(dma_stage_stop[level][node]),
            .data_out(dma_stage_data[level][node]),
            .data_void_out(dma_stage_void[level][node]),
            .stop_out(reduce_router_stop)
          );
        end
      end
    end

    for (g_i = 0; g_i < DMA_STREAMS; g_i++) begin : gen_dma_root_output
      if (g_i < DMA_ROOTS) begin : gen_connected_root
        assign dma_final_data[g_i] = dma_stage_data[DMA_REDUCE_LEVELS][g_i];
        assign dma_final_void[g_i] = dma_stage_void[DMA_REDUCE_LEVELS][g_i];
        assign dma_stage_stop[DMA_REDUCE_LEVELS][g_i] = dma_tree_stop_out;
      end else begin : gen_padded_root
        assign dma_final_data[g_i] = '0;
        assign dma_final_void[g_i] = 1'b1;
      end
    end
  endgenerate

  always_comb begin
    cm_tree_data_out_int = '0;
    cm_tree_void_out_int = '1;

    for (int ch = 0; ch < CM_CHANNELS; ch++) begin
      int unsigned top_lane;
      int unsigned bot_lane;

      top_lane = 2 * ch + 1;
      bot_lane = 2 * ch;

      cm_tree_data_out_int[(top_lane+1)*CMDataWidth-1 -: CMDataWidth] =
          cm_group_top_void[ch] ? '0 : cm_group_top_data[ch];
      cm_tree_void_out_int[top_lane] = cm_group_top_void[ch];

      cm_tree_data_out_int[(bot_lane+1)*CMDataWidth-1 -: CMDataWidth] =
          cm_group_bot_void[ch] ? '0 : cm_group_bot_data[ch];
      cm_tree_void_out_int[bot_lane] = cm_group_bot_void[ch];
    end
  end

  always_comb begin
    dma_tree_data_out_int = '0;
    dma_tree_void_out_int = '1;

    for (int i = 0; i < DMA_STREAMS; i++) begin
      dma_tree_data_out_int[CHDataWidth-1-i*DMA_BEAT_WIDTH -: DMA_BEAT_WIDTH] =
          dma_final_void[i] ? '0 : dma_final_data[i];
      dma_tree_void_out_int[CM_STREAMS-1-(i*2) -: 2] = {2{dma_final_void[i]}};
    end
  end

  always_comb begin
    dmabypass_data_out_int = '0;
    dmabypass_void_out_int = '1;

    dmabypass_data_out_int[(2*CMDataWidth)-1:0] = dmabypass_data_in;
    dmabypass_void_out_int[1:0] = {2{dmabypass_data_void_in}};
  end

  cm_3to2_arbiter_max_throughput #(
    .CMDataWidth(CMDataWidth)
  ) d2d_tree_cm_bypass_arbiter_i (
    .clk(clk),
    .rst(rst),
    .ch0_data_in(cm_tree_data_out_int[CMDataWidth-1:0]),
    .ch0_void_in(cm_tree_void_out_int[0]),
    .ch0_stop_out(cm_tree_stop_out[0]),
    .ch1_data_in(cm_tree_data_out_int[2*CMDataWidth-1:CMDataWidth]),
    .ch1_void_in(cm_tree_void_out_int[1]),
    .ch1_stop_out(cm_tree_stop_out[1]),
    .ch2_data_in(cmbypass_data_in),
    .ch2_void_in(cmbypass_data_void_in),
    .ch2_stop_out(cmbypass_stop_out),
    .stop0_in(cm_root_stop_out[0]),
    .data0_out(cm_data_out_int[CMDataWidth-1:0]),
    .data0_void_out(cm_void_out_int[0]),
    .stop1_in(cm_root_stop_out[1]),
    .data1_out(cm_data_out_int[2*CMDataWidth-1:CMDataWidth]),
    .data1_void_out(cm_void_out_int[1])
  );

  d2d_tree_root_2dma_arbiter #(
    .CHDataWidth(CHDataWidth),
    .CMDataWidth(CMDataWidth),
    .DMA_LANES_PER_FLIT(2)
  ) d2d_tree_dma_bypass_arbiter_i (
    .clk(clk),
    .rst(rst),
    .dma0_data_in(dmabypass_data_out_int),
    .dma0_data_void_in(dmabypass_void_out_int),
    .dma1_data_in(dma_tree_data_out_int),
    .dma1_data_void_in(dma_tree_void_out_int),
    .stop_in({CM_STREAMS{dma_root_stop_out}}),
    .dma0_stop_out(dmabypass_stop_out),
    .dma1_stop_out(dma_tree_stop_out),
    .data_out(dma_data_out_int),
    .data_void_out(dma_void_out_int)
  );

  d2d_tree_root_arbiter #(
    .CHDataWidth(CHDataWidth),
    .CMDataWidth(CMDataWidth),
    .DMA_LANES_PER_FLIT(2)
  ) d2d_tree_root_arbiter_i (
    .clk(clk),
    .rst(rst),
    .cm_data_in(cm_data_out_int),
    .cm_data_void_in(cm_void_out_int),
    .dma_data_in(dma_data_out_int),
    .dma_data_void_in(dma_void_out_int),
    .stop_in(stop_in),
    .cm_stop_out(cm_root_stop_out),
    .dma_stop_out(dma_root_stop_out),
    .data_out(root_data_out),
    .data_void_out(root_data_void_out)
  );

  always_comb begin
    data_out = root_data_out;
    data_void_out = root_data_void_out;

    for (int unsigned group = 0; group < DMA_STREAMS; group++) begin
      int unsigned bot_lane;
      int unsigned top_lane;
      int unsigned bot_base;
      int unsigned top_base;
      cm_flit_t bot_flit;
      cm_flit_t top_flit;
      logic bot_valid;
      logic top_valid;
      logic top_is_dma_head;

      bot_lane = 2 * group;
      top_lane = bot_lane + 1;
      bot_base = bot_lane * CMDataWidth;
      top_base = top_lane * CMDataWidth;

      bot_flit.flit = root_data_out[bot_base +: CMDataWidth];
      top_flit.flit = root_data_out[top_base +: CMDataWidth];
      bot_valid = !root_data_void_out[bot_lane];
      top_valid = !root_data_void_out[top_lane];
      top_is_dma_head =
          top_valid &&
          top_flit.header.preamble.head &&
          top_flit.header.info.plane[2];

      if (top_is_dma_head) begin
        data_out[bot_base +: $bits(noc::direction_t)] =
            tx_next_chip_routing(top_flit.header.info.destination_chip,
                                 top_flit.header.info.destination_chip_mask,
                                 top_flit.header.info.uni_or_mcast);
      end else begin
        if (top_valid &&
            top_flit.header.preamble.head &&
            !top_flit.header.info.plane[2]) begin
          data_out[top_base +: $bits(noc::direction_t)] =
              tx_next_chip_routing(top_flit.header.info.destination_chip,
                                   top_flit.header.info.destination_chip_mask,
                                   top_flit.header.info.uni_or_mcast);
        end

        if (bot_valid &&
            bot_flit.header.preamble.head &&
            !bot_flit.header.info.plane[2]) begin
          data_out[bot_base +: $bits(noc::direction_t)] =
              tx_next_chip_routing(bot_flit.header.info.destination_chip,
                                   bot_flit.header.info.destination_chip_mask,
                                   bot_flit.header.info.uni_or_mcast);
        end
      end
    end
  end

endmodule
