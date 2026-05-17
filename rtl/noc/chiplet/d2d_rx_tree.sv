module d2d_rx_tree #(
    parameter logic [1:0] d2d_position, // 0: N, 1: S, 2: W, 3: E
    parameter noc::chip_xy_t chip_coordinates,
    parameter logic [3:0] max_dim = '0,
    parameter int unsigned RXCHANNELS = 2,
    parameter int unsigned T = 8,
    parameter int unsigned CMDataWidth = 66,
    parameter int unsigned DMADataWidth = 258,
    parameter int unsigned CHDataWidth = 2 * CMDataWidth
  )
(
  input  logic clk,
  input  logic rst,
  input  logic [CHDataWidth-1:0] d2d_rcv_data_in [RXCHANNELS-1:0],
  input  logic [1:0] d2d_data_void_in [RXCHANNELS-1:0],
  output logic [1:0] d2d_stop_out [RXCHANNELS-1:0],
  output logic [1:0] d2d_read_out [RXCHANNELS-1:0],

  output logic [CMDataWidth-1:0] noc1_data_out [T-1:0],
  output logic [CMDataWidth-1:0] noc2_data_out [T-1:0],
  output logic [CMDataWidth-1:0] noc3_data_out [T-1:0],
  output logic [DMADataWidth-1:0] noc4_data_out [T-1:0],
  output logic [CMDataWidth-1:0] noc5_data_out [T-1:0],
  output logic [DMADataWidth-1:0] noc6_data_out [T-1:0],
  output logic noc1_data_void_out [T-1:0],
  output logic noc2_data_void_out [T-1:0],
  output logic noc3_data_void_out [T-1:0],
  output logic noc4_data_void_out [T-1:0],
  output logic noc5_data_void_out [T-1:0],
  output logic noc6_data_void_out [T-1:0],
  input  logic noc1_stop_in [T-1:0],
  input  logic noc2_stop_in [T-1:0],
  input  logic noc3_stop_in [T-1:0],
  input  logic noc4_stop_in [T-1:0],
  input  logic noc5_stop_in [T-1:0],
  input  logic noc6_stop_in [T-1:0],

  output logic [CMDataWidth-1:0] cmbypass_data_out,
  output logic cmbypass_data_void_out,
  input  logic cmbypass_stop_in,
  output logic [CHDataWidth-1:0] dmabypass_data_out,
  output logic dmabypass_data_void_out,
  input  logic dmabypass_stop_in
);

  localparam int unsigned CM_LANES = 2 * RXCHANNELS;
  localparam int unsigned TileIndexWidth = (T > 1) ? $clog2(T) : 1;
  localparam int ReservedWidth =
      CMDataWidth - $bits(noc::preamble_t) - 2*$bits(noc::xy_t) - $bits(noc::message_t) -
      $bits(noc::tile_t) - $bits(noc::plane_t) - $bits(noc::routing_lock_t) -
      2*$bits(noc::chip_xy_t) - $bits(noc::direction_t) - $bits(noc::mcast_t) -
      $bits(noc::pkt_type_t) - $bits(noc::xy_t) - $bits(noc::chip_xy_t);
  localparam int ChReservedWidth =
      CHDataWidth - $bits(noc::preamble_t) - 2*$bits(noc::xy_t) - $bits(noc::message_t) -
      $bits(noc::tile_t) - $bits(noc::plane_t) - $bits(noc::routing_lock_t) -
      2*$bits(noc::chip_xy_t) - $bits(noc::direction_t) - $bits(noc::mcast_t) -
      $bits(noc::pkt_type_t) - $bits(noc::xy_t) - $bits(noc::chip_xy_t);
  localparam int DmaReservedWidth =
      DMADataWidth - $bits(noc::preamble_t) - 2*$bits(noc::xy_t) - $bits(noc::message_t) -
      $bits(noc::tile_t) - $bits(noc::plane_t) - $bits(noc::routing_lock_t) -
      2*$bits(noc::chip_xy_t) - $bits(noc::direction_t) - $bits(noc::mcast_t) -
      $bits(noc::pkt_type_t) - $bits(noc::xy_t) - $bits(noc::chip_xy_t);
  localparam int unsigned ReservedPreChipMaskWidth = 2;
  localparam int unsigned DestinationChipMaskPreWidth =
      $bits(noc::preamble_t) + 2*$bits(noc::xy_t) + $bits(noc::message_t) +
      $bits(noc::tile_t) + $bits(noc::plane_t) + $bits(noc::routing_lock_t) +
      2*$bits(noc::chip_xy_t) + $bits(noc::pkt_type_t) + $bits(noc::mcast_t) +
      $bits(noc::xy_t) + ReservedPreChipMaskWidth;
  localparam int unsigned DMASerializedBeatPayloadWidth = CHDataWidth - 4;
  localparam int unsigned DMASerialBeats =
      (DMADataWidth - $bits(noc::preamble_t)) / DMASerializedBeatPayloadWidth;
  localparam int unsigned DMABeatWidth = (DMASerialBeats > 1) ? $clog2(DMASerialBeats) : 1;

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
    logic [ReservedWidth-1:0] reserved;
    noc::chip_xy_t destination_chip_mask; // use this field and 2 bits of reserved for unicast reserved bits; KL address D2D RX & bypass router routing to accommodate this
  } packet_info_t;

  typedef struct packed {
    noc::preamble_t preamble;
    packet_info_t info;
    noc::direction_t routing;
  } header_t;

  typedef union packed {
    header_t header;
    logic [CMDataWidth-1:0] flit;
  } cm_flit_t;

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
    logic [ChReservedWidth-1:0] reserved;
    noc::chip_xy_t destination_chip_mask; // use this field and 2 bits of reserved for unicast reserved bits; KL address D2D RX & bypass router routing to accommodate this
	  } ch_packet_info_t;

  typedef struct packed {
    noc::preamble_t preamble;
    ch_packet_info_t info;
    noc::direction_t routing;
  } ch_header_t;

  typedef union packed {
    ch_header_t header;
    logic [CHDataWidth-1:0] flit;
  } ch_flit_t;

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
    logic [DmaReservedWidth-1:0] reserved;
    noc::chip_xy_t destination_chip_mask; // use this field and 2 bits of reserved for unicast reserved bits; KL address D2D RX & bypass router routing to accommodate this
	  } dma_packet_info_t;

  typedef struct packed {
    noc::preamble_t preamble;
    dma_packet_info_t info;
    noc::direction_t routing;
  } dma_header_t;

  typedef union packed {
    dma_header_t header;
    logic [DMADataWidth-1:0] flit;
  } dma_flit_t;

  initial begin
    if ($bits(header_t) != CMDataWidth) begin
      $fatal(2'd2, "header_t width (%0d) must match CMDataWidth (%0d)",
             $bits(header_t), CMDataWidth);
    end
    if ($bits(ch_header_t) != CHDataWidth) begin
      $fatal(2'd2, "ch_header_t width (%0d) must match CHDataWidth (%0d)",
             $bits(ch_header_t), CHDataWidth);
    end
    if ($bits(dma_header_t) != DMADataWidth) begin
      $fatal(2'd2, "dma_header_t width (%0d) must match DMADataWidth (%0d)",
             $bits(dma_header_t), DMADataWidth);
    end
  end

  function automatic logic [CMDataWidth-1:0] rewrite_cm_head_flit(
      input logic [CMDataWidth-1:0] flit_in,
      input noc::routing_lock_t routing_lock,
      input noc::direction_t next_routing,
      input noc::mcast_t next_mcast_type,
      input logic clear_tile
  );
    cm_flit_t flit_tmp;
    begin
      flit_tmp.flit = flit_in;
      flit_tmp.header.info.routing_lock = routing_lock;
      flit_tmp.header.info.mcast_type = next_mcast_type;
      if (clear_tile) begin
        flit_tmp.header.info.tile = '0;
      end
      flit_tmp.header.routing = next_routing;
      return flit_tmp.flit;
    end
  endfunction

  function automatic logic [CHDataWidth-1:0] rewrite_ch_head_flit(
      input logic [CHDataWidth-1:0] flit_in,
      input noc::routing_lock_t routing_lock,
      input noc::direction_t next_routing,
      input noc::mcast_t next_mcast_type,
      input logic clear_tile
  );
    ch_flit_t flit_tmp;
    begin
      flit_tmp.flit = flit_in;
      flit_tmp.header.info.routing_lock = routing_lock;
      flit_tmp.header.info.mcast_type = next_mcast_type;
      if (clear_tile) begin
        flit_tmp.header.info.tile = '0;
      end
      flit_tmp.header.routing = next_routing;
      return flit_tmp.flit;
    end
  endfunction

  function automatic logic [CHDataWidth-1:0] rewrite_dma_head_first_beat(
      input logic [CHDataWidth-1:0] flit_in,
      input noc::routing_lock_t routing_lock,
      input noc::direction_t next_routing,
      input noc::mcast_t next_mcast_type,
      input logic clear_tile
  );
    ch_flit_t flit_tmp;
    begin
      flit_tmp.flit = flit_in;
      flit_tmp.header.info.routing_lock = routing_lock;
      flit_tmp.header.info.mcast_type = next_mcast_type;
      if (clear_tile) begin
        flit_tmp.header.info.tile = '0;
      end
      flit_tmp.header.routing = next_routing;
      return flit_tmp.flit;
    end
  endfunction

  function automatic logic [CHDataWidth-1:0] rewrite_dma_head_last_beat(
      input logic [CHDataWidth-1:0] flit_in,
      input noc::direction_t next_routing
  );
    logic [CHDataWidth-1:0] flit_tmp;
    begin
      flit_tmp = flit_in;
      // The final serialized head beat reconstructs the DMA routing field into
      // the low payload bits after the 132-bit DDR beat is deserialized.
      flit_tmp[$bits(noc::direction_t)-1:0] = next_routing;
      return flit_tmp;
    end
  endfunction

  function automatic noc::chip_xy_t ch_destination_chip_mask(
      input logic [CHDataWidth-1:0] flit
  );
    return flit[CHDataWidth-DestinationChipMaskPreWidth-1 -: $bits(noc::chip_xy_t)];
  endfunction

  function automatic logic chip_bypass_route_needed(
      input noc::chip_xy_t destination_chip,
      input noc::chip_xy_t destination_chip_mask,
      input noc::pkt_type_t uni_or_mcast
  );
    noc::chip_xy_t effective_mask;
    noc::chip_xy_t min_chip;
    begin
      effective_mask = uni_or_mcast ? destination_chip_mask : '0;
      min_chip.x = destination_chip.x & ~effective_mask.x;
      min_chip.y = destination_chip.y & ~effective_mask.y;

      if (d2d_position == 2'b00) begin
        return chip_coordinates.y < destination_chip.y;
      end else if (d2d_position == 2'b01) begin
        return chip_coordinates.y > min_chip.y;
      end else if (d2d_position == 2'b10) begin
        return (chip_coordinates.x < destination_chip.x) ||
               (chip_coordinates.y < destination_chip.y) ||
               (chip_coordinates.y > min_chip.y);
      end else begin
        return (chip_coordinates.x > min_chip.x) ||
               (chip_coordinates.y < destination_chip.y) ||
               (chip_coordinates.y > min_chip.y);
      end
    end
  endfunction

  function automatic logic [TileIndexWidth-1:0] target_tile(input noc::xy_t destination);
    if (d2d_position < 2) begin
      return TileIndexWidth'(destination.x);
    end
    return TileIndexWidth'(destination.y);
  endfunction

  function automatic logic [noc::xWidth-1:0] destination_axis(input noc::xy_t destination);
    if (d2d_position < 2) begin
      return destination.x;
    end
    return destination.y;
  endfunction

  function automatic logic tile_matches_axis(
      input int unsigned tile,
      input logic [noc::xWidth-1:0] allow0,
      input logic [noc::xWidth-1:0] allow1
  );
    logic [noc::xWidth-1:0] tile_coord;
    logic [noc::xWidth-1:0] bit_match;
    begin
      tile_coord = tile;
      for (int unsigned bit_idx = 0; bit_idx < noc::xWidth; bit_idx++) begin
        bit_match[bit_idx] = tile_coord[bit_idx] ? allow1[bit_idx] : allow0[bit_idx];
      end
      return &bit_match;
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

  function automatic int unsigned min_u(
      input int unsigned a,
      input int unsigned b
  );
    return (a < b) ? a : b;
  endfunction

  function automatic int unsigned max_u(
      input int unsigned a,
      input int unsigned b
  );
    return (a > b) ? a : b;
  endfunction

  function automatic int unsigned ceil_div(
      input int unsigned value,
      input int unsigned divisor
  );
    return (value + divisor - 1) / divisor;
  endfunction

  localparam int unsigned CM_SEGMENTS = min_u(T, max_u(RXCHANNELS, ceil_div(T, 4)));
  localparam int unsigned DMA_SEGMENTS = CM_SEGMENTS;
  localparam int unsigned CM_TIPS = CM_SEGMENTS + 1;
  localparam int unsigned DMA_TIPS = DMA_SEGMENTS + 1;
  localparam int unsigned CM_BYPASS_TIP = CM_SEGMENTS;
  localparam int unsigned DMA_BYPASS_TIP = DMA_SEGMENTS;
  localparam int unsigned CMTipIndexWidth = (CM_TIPS > 1) ? $clog2(CM_TIPS) : 1;

  function automatic logic [CM_TIPS-1:0] cm_tip_mask_from_index(
      input logic [CMTipIndexWidth-1:0] tip_index
  );
    logic [CM_TIPS-1:0] tip_mask;
    begin
      tip_mask = '0;
      for (int unsigned tip = 0; tip < CM_TIPS; tip++) begin
        tip_mask[tip] = (tip_index == CMTipIndexWidth'(tip));
      end
      return tip_mask;
    end
  endfunction

  function automatic logic [DMA_SEGMENTS-1:0] dma_segment_mask_from_destination(
      input noc::xy_t destination,
      input noc::xy_t destination_mask
  );
    logic [DMA_SEGMENTS-1:0] segment_mask;
    logic [noc::xWidth-1:0] destination_coord;
    logic [noc::xWidth-1:0] mask_coord;
    logic [noc::xWidth-1:0] allow0;
    logic [noc::xWidth-1:0] allow1;
    int unsigned seg_start;
    int unsigned seg_size;
    begin
      destination_coord = destination_axis(destination);
      mask_coord = destination_axis(destination_mask);
      allow0 = mask_coord | ~destination_coord;
      allow1 = mask_coord | destination_coord;
      segment_mask = '0;
      for (int unsigned seg = 0; seg < DMA_SEGMENTS; seg++) begin
        seg_start = group_start(T, DMA_SEGMENTS, seg);
        seg_size = group_size(T, DMA_SEGMENTS, seg);
        for (int unsigned tile = 0; tile < seg_size; tile++) begin
          segment_mask[seg] |= tile_matches_axis(seg_start + tile, allow0, allow1);
        end
      end
      return segment_mask;
    end
  endfunction

  function automatic int unsigned segment_index_for_tile(
      input logic [TileIndexWidth-1:0] tile,
      input int unsigned segment_count
  );
    int unsigned tile_idx;
    begin
      tile_idx = int'(tile);
      for (int unsigned seg = 0; seg < segment_count; seg++) begin
        int unsigned seg_start;
        int unsigned seg_size;

        seg_start = group_start(T, segment_count, seg);
        seg_size = group_size(T, segment_count, seg);
        if (tile_idx < (seg_start + seg_size)) begin
          return seg;
        end
      end
      return segment_count - 1;
    end
  endfunction

  function automatic logic [TileIndexWidth-1:0] segment_local_tile(
      input logic [TileIndexWidth-1:0] tile,
      input int unsigned segment_count,
      input int unsigned segment
  );
    int unsigned seg_start;
    begin
      seg_start = group_start(T, segment_count, segment);
      return TileIndexWidth'(int'(tile) - seg_start);
    end
  endfunction

  // Root classification and root-local vs. bypass steering.
  logic [CMDataWidth-1:0] cm_input_data [CM_LANES-1:0];
  logic cm_input_void [CM_LANES-1:0];
  cm_flit_t cm_input_flit [CM_LANES-1:0];
  ch_flit_t dma_input_flit [RXCHANNELS-1:0];

  logic dma_bundle_is_dma [RXCHANNELS-1:0];
  logic dma_packet_active [RXCHANNELS-1:0];
  logic dma_input_void [RXCHANNELS-1:0];
  logic cm_packet_active [CM_LANES-1:0];
  logic cm_head_valid [CM_LANES-1:0];
  logic dma_head_valid [RXCHANNELS-1:0];
  logic [CMDataWidth-1:0] cm_routed_input_data [CM_LANES-1:0];
  logic [CHDataWidth-1:0] dma_routed_input_data [RXCHANNELS-1:0];
  logic cm_top_local_routing_lock [RXCHANNELS-1:0];
  logic cm_bot_local_routing_lock [RXCHANNELS-1:0];
  noc::direction_t cm_top_local_next_routing [RXCHANNELS-1:0];
  noc::direction_t cm_bot_local_next_routing [RXCHANNELS-1:0];
  noc::mcast_t cm_top_local_next_mcast_type [RXCHANNELS-1:0];
  noc::mcast_t cm_bot_local_next_mcast_type [RXCHANNELS-1:0];
  logic cm_routable [CM_LANES-1:0];
  logic dma_routable [RXCHANNELS-1:0];
  logic [CM_TIPS-1:0] cm_saved_tip_mask [CM_LANES-1:0];
  logic [DMA_TIPS-1:0] dma_saved_tip_mask [RXCHANNELS-1:0];
  logic [CM_TIPS-1:0] cm_tip_target_mask_eff [CM_LANES-1:0];
  logic [DMA_TIPS-1:0] dma_tip_target_mask_eff [RXCHANNELS-1:0];
  logic [DMA_SEGMENTS-1:0] dma_tip_segment_mask_eff [RXCHANNELS-1:0];
  logic dma_bypass_selected_eff [RXCHANNELS-1:0];
  logic cm_is_local_head [CM_LANES-1:0];
  logic cm_has_bypass_head [CM_LANES-1:0];
  logic dma_is_local_head [RXCHANNELS-1:0];
  logic dma_has_bypass_head [RXCHANNELS-1:0];

  logic cm_select_stop [CM_LANES-1:0];
  logic cm_tip_select_stop [CM_LANES-1:0];
  logic cm_reservation_stop [CM_LANES-1:0];
  logic cm_head_accepted [CM_LANES-1:0];
  logic cm_tail_accepted [CM_LANES-1:0];
  logic dma_select_stop [RXCHANNELS-1:0];
  logic dma_tip_select_stop [RXCHANNELS-1:0];
  logic dma_head_accepted [RXCHANNELS-1:0];
  logic dma_tail_accepted [RXCHANNELS-1:0];
  logic dma_reservation_stop [RXCHANNELS-1:0];

  logic [CMDataWidth-1:0] cm_tip_data [CM_LANES-1:0][CM_TIPS-1:0];
  logic cm_tip_void [CM_LANES-1:0][CM_TIPS-1:0];
  logic cm_tip_stop [CM_LANES-1:0][CM_TIPS-1:0];

  logic [CHDataWidth-1:0] dma_tip_data [RXCHANNELS-1:0][DMA_TIPS-1:0];
  logic dma_tip_void [RXCHANNELS-1:0][DMA_TIPS-1:0];
  logic dma_tip_stop [RXCHANNELS-1:0][DMA_TIPS-1:0];

  // Local tree outputs after the CM/DMA segment expand trees.
  logic [CMDataWidth-1:0] cm_tile_data [T-1:0];
  logic cm_tile_void [T-1:0];
  logic cm_tile_stop [T-1:0];

  logic [CHDataWidth-1:0] dma_tile_data [T-1:0];
  logic dma_tile_void [T-1:0];
  logic dma_tile_stop [T-1:0];
  logic noc4_data_void_raw [T-1:0];
  logic noc6_data_void_raw [T-1:0];

  // Bypass outputs after the shared reduction trees.
  logic [CM_LANES-1:0] cm_bypass_valid_mask;
  logic [CMDataWidth-1:0] cmbypass_data_raw;
  logic cmbypass_data_void_raw;
  logic cmbypass_relay_stop;
  logic [RXCHANNELS-1:0] dma_bypass_valid_mask;
  logic [CHDataWidth-1:0] dmabypass_data_raw;
  logic dmabypass_data_void_raw;
  logic dmabypass_relay_stop;
  cm_flit_t cmbypass_flit;
  logic [CMDataWidth-1:0] cmbypass_data_routed;
  logic cmbypass_routing_lock;
  noc::direction_t cmbypass_next_routing;
  noc::mcast_t cmbypass_next_mcast_type;
  ch_flit_t dmabypass_flit;
  logic [CHDataWidth-1:0] dmabypass_data_routed;
  logic dmabypass_routing_lock;
  logic dmabypass_header_route_pending;
  logic dmabypass_last_serial_beat;
  logic dmabypass_rewrite_last_head_beat;
  logic dmabypass_accepted;
  logic [DMABeatWidth-1:0] dmabypass_serial_beat;
  noc::direction_t dmabypass_next_routing;
  noc::direction_t dmabypass_saved_next_routing;
  noc::mcast_t dmabypass_next_mcast_type;

  initial begin
    if (CHDataWidth != (2 * CMDataWidth)) begin
      $error("d2d_rx_tree expects CHDataWidth == 2*CMDataWidth");
    end
    if (CHDataWidth != 132) begin
      $error("d2d_rx_tree currently expects CHDataWidth == 132");
    end
    if (max_dim == '0) begin
      $error("d2d_rx_tree expects max_dim to be set");
    end
    if ((T < 2) || (T > 16)) begin
      $error("d2d_rx_tree currently expects 2 <= T <= 16");
    end
    if ((DMADataWidth - 2) % (CHDataWidth - 4) != 0) begin
      $error("d2d_rx_tree expects DMA payload bits to be an integer multiple of 128");
    end
    if (RXCHANNELS > 16) begin
      $error("d2d_rx_tree expects RXCHANNELS <= 16");
    end
    if (CM_LANES > 16) begin
      $error("d2d_rx_tree expects 2*RXCHANNELS <= 16");
    end
  end

  d2d_tip_reservation #(
    .SOURCES(CM_LANES),
    .TIPS(CM_TIPS)
  ) cm_tip_reservation_i (
    .clk(clk),
    .rst(rst),
    .routable(cm_routable),
    .head_valid(cm_head_valid),
    .packet_active(cm_packet_active),
    .tip_target_mask(cm_tip_target_mask_eff),
    .head_accepted(cm_head_accepted),
    .tail_accepted(cm_tail_accepted),
    .reservation_stop(cm_reservation_stop)
  );

  d2d_tip_reservation #(
    .SOURCES(RXCHANNELS),
    .TIPS(DMA_TIPS)
  ) dma_tip_reservation_i (
    .clk(clk),
    .rst(rst),
    .routable(dma_routable),
    .head_valid(dma_head_valid),
    .packet_active(dma_packet_active),
    .tip_target_mask(dma_tip_target_mask_eff),
    .head_accepted(dma_head_accepted),
    .tail_accepted(dma_tail_accepted),
    .reservation_stop(dma_reservation_stop)
  );

  generate
    for (genvar ch = 0; ch < RXCHANNELS; ch++) begin : gen_input_split
      localparam int unsigned BOT = 2 * ch;
      localparam int unsigned TOP = BOT + 1;
      logic [CHDataWidth-1:0] dma_bundle_data;
      logic cm_top_accepted;
      logic cm_bot_accepted;
      logic dma_accepted;
      logic top_valid;
      logic bot_valid;
      logic top_is_dma_head;
      logic bot_is_dma_payload;
      logic dma_start;
      logic dma_continue;
      logic present_dma_bundle;
      logic top_present;
      logic bot_present;
      logic top_take;
      logic bot_take;
      logic dma_header_route_pending;
      logic dma_last_serial_beat;
      logic dma_rewrite_last_head_beat;
      logic [DMABeatWidth-1:0] dma_serial_beat;
      noc::direction_t dma_saved_next_routing;
      logic top_local_route_use_dma;
      noc::xy_t top_local_route_destination;
      noc::xy_t top_local_route_destination_mask;
      noc::pkt_type_t top_local_route_uni_or_mcast;

      assign cm_input_data[TOP] = d2d_rcv_data_in[ch][CHDataWidth-1 -: CMDataWidth];
      assign cm_input_data[BOT] = d2d_rcv_data_in[ch][CMDataWidth-1:0];
      assign cm_input_flit[TOP].flit = cm_input_data[TOP];
      assign cm_input_flit[BOT].flit = cm_input_data[BOT];
      assign dma_bundle_data = {cm_input_data[TOP], cm_input_data[BOT]};
      assign dma_input_flit[ch].flit = dma_bundle_data;
      assign top_valid = !d2d_data_void_in[ch][1];
      assign bot_valid = !d2d_data_void_in[ch][0];
      assign top_is_dma_head =
          top_valid &&
          dma_input_flit[ch].header.preamble.head &&
          dma_input_flit[ch].header.info.plane[2];
      assign bot_is_dma_payload =
          bot_valid &&
          !cm_packet_active[BOT] &&
          (cm_input_flit[BOT].header.preamble == '0);
      assign dma_start = !dma_packet_active[ch] && top_is_dma_head && bot_is_dma_payload;
      assign dma_continue = dma_packet_active[ch] && top_valid && bot_valid;
      assign present_dma_bundle = dma_start || dma_continue;
      assign top_present =
          present_dma_bundle ||
          (!dma_packet_active[ch] && top_valid && !top_is_dma_head);
      assign bot_present =
          present_dma_bundle ||
          (!dma_packet_active[ch] && bot_valid && !bot_is_dma_payload);
      assign cm_input_void[TOP] = !top_present;
      assign cm_input_void[BOT] = !bot_present;

      assign top_local_route_use_dma = dma_head_valid[ch] && dma_is_local_head[ch];
      assign top_local_route_destination =
          top_local_route_use_dma ?
          dma_input_flit[ch].header.info.destination :
          cm_input_flit[TOP].header.info.destination;
      assign top_local_route_destination_mask =
          top_local_route_use_dma ?
          dma_input_flit[ch].header.info.destination_mask :
          cm_input_flit[TOP].header.info.destination_mask;
      assign top_local_route_uni_or_mcast =
          top_local_route_use_dma ?
          dma_input_flit[ch].header.info.uni_or_mcast :
          cm_input_flit[TOP].header.info.uni_or_mcast;

      d2d_lookahead_local_routing #(
        .max_dim(max_dim),
        .d2d_position(d2d_position)
      ) top_local_lookahead_routing_i (
        .destination(top_local_route_destination),
        .destination_mask(top_local_route_destination_mask),
        .uni_or_mcast(top_local_route_uni_or_mcast),
        .routing_lock(cm_top_local_routing_lock[ch]),
        .next_routing(cm_top_local_next_routing[ch]),
        .next_mcast_type(cm_top_local_next_mcast_type[ch])
      );

      d2d_lookahead_local_routing #(
        .max_dim(max_dim),
        .d2d_position(d2d_position)
      ) bot_local_lookahead_routing_i (
        .destination(cm_input_flit[BOT].header.info.destination),
        .destination_mask(cm_input_flit[BOT].header.info.destination_mask),
        .uni_or_mcast(cm_input_flit[BOT].header.info.uni_or_mcast),
        .routing_lock(cm_bot_local_routing_lock[ch]),
        .next_routing(cm_bot_local_next_routing[ch]),
        .next_mcast_type(cm_bot_local_next_mcast_type[ch])
      );

      // A DMA beat is consumed as a paired TOP/BOT bundle. Lone DMA halves stay
      // parked at the FIFO head while independent CM halves can still drain.
      assign dma_bundle_is_dma[ch] = present_dma_bundle;
      assign dma_input_void[ch] = !present_dma_bundle;

      assign cm_head_valid[TOP] =
          !cm_input_void[TOP] &&
          !dma_bundle_is_dma[ch] &&
          cm_input_flit[TOP].header.preamble.head;
      assign cm_head_valid[BOT] =
          !cm_input_void[BOT] &&
          !dma_bundle_is_dma[ch] &&
          cm_input_flit[BOT].header.preamble.head;
      assign dma_head_valid[ch] =
          !dma_input_void[ch] &&
          dma_input_flit[ch].header.preamble.head;
      assign cm_is_local_head[TOP] =
          cm_head_valid[TOP] &&
          cm_input_flit[TOP].header.routing.go_local;
      assign cm_is_local_head[BOT] =
          cm_head_valid[BOT] &&
          cm_input_flit[BOT].header.routing.go_local;
      // Continue on the bypass path when the packet's chip destination range
      // extends past the current chiplet in this D2D direction.
      assign cm_has_bypass_head[TOP] =
          cm_head_valid[TOP] &&
          chip_bypass_route_needed(
              cm_input_flit[TOP].header.info.destination_chip,
              cm_input_flit[TOP].header.info.destination_chip_mask,
              cm_input_flit[TOP].header.info.uni_or_mcast);
      assign cm_has_bypass_head[BOT] =
          cm_head_valid[BOT] &&
          chip_bypass_route_needed(
              cm_input_flit[BOT].header.info.destination_chip,
              cm_input_flit[BOT].header.info.destination_chip_mask,
              cm_input_flit[BOT].header.info.uni_or_mcast);
      assign dma_is_local_head[ch] =
          dma_head_valid[ch] &&
          dma_input_flit[ch].header.routing.go_local;
      assign dma_has_bypass_head[ch] =
          dma_head_valid[ch] &&
          chip_bypass_route_needed(
              dma_input_flit[ch].header.info.destination_chip,
              ch_destination_chip_mask(dma_bundle_data),
              dma_input_flit[ch].header.info.uni_or_mcast);
      assign cm_routed_input_data[TOP] =
          (cm_head_valid[TOP] && cm_is_local_head[TOP]) ?
          rewrite_cm_head_flit(cm_input_data[TOP],
                               cm_top_local_routing_lock[ch],
                               cm_top_local_next_routing[ch],
                               cm_top_local_next_mcast_type[ch],
                               1'b1) :
          cm_input_data[TOP];
      assign cm_routed_input_data[BOT] =
          (cm_head_valid[BOT] && cm_is_local_head[BOT]) ?
          rewrite_cm_head_flit(cm_input_data[BOT],
                               cm_bot_local_routing_lock[ch],
                               cm_bot_local_next_routing[ch],
                               cm_bot_local_next_mcast_type[ch],
                               1'b1) :
          cm_input_data[BOT];
      assign dma_last_serial_beat =
          (dma_serial_beat == DMABeatWidth'(DMASerialBeats - 1));
      assign dma_rewrite_last_head_beat =
          dma_header_route_pending && dma_last_serial_beat;
      assign dma_routed_input_data[ch] =
          (dma_head_valid[ch] && dma_is_local_head[ch]) ?
          ((DMASerialBeats == 1) ?
           rewrite_ch_head_flit(dma_bundle_data,
                                cm_top_local_routing_lock[ch],
                                cm_top_local_next_routing[ch],
                                cm_top_local_next_mcast_type[ch],
                                1'b0) :
           rewrite_dma_head_first_beat(dma_bundle_data,
                                       cm_top_local_routing_lock[ch],
                                       cm_top_local_next_routing[ch],
                                       cm_top_local_next_mcast_type[ch],
                                       1'b0)) :
          (dma_rewrite_last_head_beat ?
           rewrite_dma_head_last_beat(dma_bundle_data, dma_saved_next_routing) :
           dma_bundle_data);

      assign cm_routable[TOP] =
          !cm_input_void[TOP] &&
          !dma_bundle_is_dma[ch] &&
          (cm_packet_active[TOP] || cm_head_valid[TOP]);
      assign cm_routable[BOT] =
          !cm_input_void[BOT] &&
          !dma_bundle_is_dma[ch] &&
          (cm_packet_active[BOT] || cm_head_valid[BOT]);
      assign dma_routable[ch] =
          !dma_input_void[ch] &&
          (dma_packet_active[ch] || dma_head_valid[ch]);

      // Chip multicast can request local delivery and bypass continuation at once.
      assign cm_tip_target_mask_eff[TOP] =
          cm_packet_active[TOP] ? cm_saved_tip_mask[TOP] :
          ((cm_is_local_head[TOP] ?
            cm_tip_mask_from_index(CMTipIndexWidth'(segment_index_for_tile(
                target_tile(cm_input_flit[TOP].header.info.destination), CM_SEGMENTS))) :
            '0) |
           (cm_has_bypass_head[TOP] ?
            cm_tip_mask_from_index(CMTipIndexWidth'(CM_BYPASS_TIP)) :
            '0));
      assign cm_tip_target_mask_eff[BOT] =
          cm_packet_active[BOT] ? cm_saved_tip_mask[BOT] :
          ((cm_is_local_head[BOT] ?
            cm_tip_mask_from_index(CMTipIndexWidth'(segment_index_for_tile(
                target_tile(cm_input_flit[BOT].header.info.destination), CM_SEGMENTS))) :
            '0) |
           (cm_has_bypass_head[BOT] ?
            cm_tip_mask_from_index(CMTipIndexWidth'(CM_BYPASS_TIP)) :
            '0));
      assign dma_tip_segment_mask_eff[ch] =
          dma_is_local_head[ch] ?
          dma_segment_mask_from_destination(
              dma_input_flit[ch].header.info.destination,
              dma_input_flit[ch].header.info.destination_mask) :
          '0;
      assign dma_bypass_selected_eff[ch] = dma_has_bypass_head[ch];
      assign dma_tip_target_mask_eff[ch] =
          dma_packet_active[ch] ? dma_saved_tip_mask[ch] :
          {dma_bypass_selected_eff[ch], dma_tip_segment_mask_eff[ch]};
      assign dma_select_stop[ch] =
          dma_tip_select_stop[ch] |
          dma_reservation_stop[ch];

      assign cm_top_accepted = cm_routable[TOP] && !cm_select_stop[TOP];
      assign cm_bot_accepted = cm_routable[BOT] && !cm_select_stop[BOT];
      assign cm_head_accepted[TOP] =
          cm_top_accepted && cm_input_flit[TOP].header.preamble.head;
      assign cm_tail_accepted[TOP] =
          cm_top_accepted && cm_input_flit[TOP].header.preamble.tail;
      assign cm_head_accepted[BOT] =
          cm_bot_accepted && cm_input_flit[BOT].header.preamble.head;
      assign cm_tail_accepted[BOT] =
          cm_bot_accepted && cm_input_flit[BOT].header.preamble.tail;
      assign dma_accepted = dma_routable[ch] && !dma_select_stop[ch];
      assign dma_head_accepted[ch] =
          dma_accepted && dma_input_flit[ch].header.preamble.head;
      assign dma_tail_accepted[ch] =
          dma_accepted && dma_input_flit[ch].header.preamble.tail;
      assign top_take = dma_bundle_is_dma[ch] ? dma_accepted : cm_top_accepted;
      assign bot_take = dma_bundle_is_dma[ch] ? dma_accepted : cm_bot_accepted;
      assign d2d_read_out[ch] = {top_take, bot_take};

      assign d2d_stop_out[ch][1] =
          top_valid && !top_take;
      assign d2d_stop_out[ch][0] =
          bot_valid && !bot_take;

      always_ff @(posedge clk) begin
        if (rst) begin
          cm_packet_active[TOP] <= 1'b0;
          cm_packet_active[BOT] <= 1'b0;
          cm_saved_tip_mask[TOP] <= '0;
          cm_saved_tip_mask[BOT] <= '0;
          dma_packet_active[ch] <= 1'b0;
          dma_saved_tip_mask[ch] <= '0;
          dma_header_route_pending <= 1'b0;
          dma_serial_beat <= '0;
          dma_saved_next_routing <= '0;
        end else begin
          if (cm_top_accepted) begin
            if (cm_input_flit[TOP].header.preamble.head) begin
              cm_saved_tip_mask[TOP] <= cm_tip_target_mask_eff[TOP];
            end
            cm_packet_active[TOP] <= !cm_input_flit[TOP].header.preamble.tail;
          end else if (dma_accepted) begin
            // DMA consumed TOP while a CM packet was in flight; clear stale CM state.
            cm_packet_active[TOP] <= 1'b0;
          end

          if (cm_bot_accepted) begin
            if (cm_input_flit[BOT].header.preamble.head) begin
              cm_saved_tip_mask[BOT] <= cm_tip_target_mask_eff[BOT];
            end
            cm_packet_active[BOT] <= !cm_input_flit[BOT].header.preamble.tail;
          end else if (dma_accepted) begin
            // DMA consumed BOT while a CM packet was in flight; clear stale CM state.
            cm_packet_active[BOT] <= 1'b0;
          end

          if (dma_accepted) begin
            if (dma_input_flit[ch].header.preamble.head) begin
              dma_saved_tip_mask[ch] <= dma_tip_target_mask_eff[ch];
              if (dma_is_local_head[ch]) begin
                dma_saved_next_routing <= cm_top_local_next_routing[ch];
                dma_header_route_pending <= (DMASerialBeats > 1);
              end else begin
                dma_saved_next_routing <= '0;
                dma_header_route_pending <= 1'b0;
              end
            end else if (dma_rewrite_last_head_beat) begin
              dma_header_route_pending <= 1'b0;
            end

            if (dma_last_serial_beat) begin
              dma_serial_beat <= '0;
            end else begin
              dma_serial_beat <= dma_serial_beat + 1'b1;
            end
            dma_packet_active[ch] <= !dma_input_flit[ch].header.preamble.tail;
          end
        end
      end
    end
  endgenerate

// There are two separate mechanisms:

// 1. d2d_*_tip_reservation decides which RX input is allowed to own a tip for a packet.
// 2. The tip relay/expand path decides whether that owned tip can accept a flit this cycle.
// The reservation module does not physically mux data into the tip. The actual connection is made in gen_*_tip_select.

// For CM, each lane broadcasts its data to every logical tip:

  generate
    for (genvar lane = 0; lane < CM_LANES; lane++) begin : gen_cm_tip_select
      logic cm_tip_input_valid;
      logic cm_tip_route_valid;
      logic [CM_TIPS-1:0] cm_tip_stop_mask;

      assign cm_tip_input_valid =
          cm_routable[lane] && !cm_reservation_stop[lane];  // routable and not filtered by tip_reservation
      assign cm_tip_route_valid = |cm_tip_target_mask_eff[lane];
      assign cm_tip_select_stop[lane] =
          cm_tip_input_valid &&
          (!cm_tip_route_valid || (|cm_tip_stop_mask));
      assign cm_select_stop[lane] =
          cm_reservation_stop[lane] | cm_tip_select_stop[lane];

      for (genvar tip = 0; tip < CM_TIPS; tip++) begin : gen_cm_tip_outputs
        assign cm_tip_data[lane][tip] =
            (tip == CM_BYPASS_TIP) ? cm_input_data[lane] : cm_routed_input_data[lane];
        assign cm_tip_void[lane][tip] =
            !(cm_tip_input_valid &&
              cm_tip_route_valid &&
              !cm_tip_select_stop[lane] &&
              cm_tip_target_mask_eff[lane][tip]);
        assign cm_tip_stop_mask[tip] =
            cm_tip_target_mask_eff[lane][tip] && cm_tip_stop[lane][tip];
      end
    end

    for (genvar seg = 0; seg < CM_SEGMENTS; seg++) begin : gen_cm_segments
      localparam int unsigned SEG_START = group_start(T, CM_SEGMENTS, seg);
      localparam int unsigned SEG_SIZE = group_size(T, CM_SEGMENTS, seg);
      logic [CMDataWidth-1:0] cm_segment_data_raw;
      logic cm_segment_void_raw;
      logic cm_segment_relay_stop;
      logic [CMDataWidth-1:0] cm_segment_data;
      logic cm_segment_void;
      logic cm_segment_stop;
      logic [CM_LANES-1:0] cm_segment_valid_mask;
      logic [TileIndexWidth-1:0] cm_segment_saved_target_tile;
      logic [TileIndexWidth-1:0] cm_segment_target_tile_eff;
      logic [CMDataWidth-1:0] cm_segment_tile_data [SEG_SIZE-1:0];
      logic cm_segment_tile_void [SEG_SIZE-1:0];
      logic cm_segment_tile_stop [SEG_SIZE-1:0];
      cm_flit_t cm_segment_flit;

      for (genvar lane = 0; lane < CM_LANES; lane++) begin : gen_segment_inputs
        assign cm_segment_valid_mask[lane] = !cm_tip_void[lane][seg];
        assign cm_tip_stop[lane][seg] = cm_segment_relay_stop;
      end

      always_comb begin
        cm_segment_data_raw = '0;
        cm_segment_void_raw = 1'b1;

        for (int unsigned lane = 0; lane < CM_LANES; lane++) begin
          cm_segment_data_raw |= cm_tip_data[lane][seg] &
                                 {CMDataWidth{!cm_tip_void[lane][seg]}};
          cm_segment_void_raw &= cm_tip_void[lane][seg];
        end
      end

`ifndef SYNTHESIS
      assert property (@(posedge clk) disable iff (rst)
        $onehot0(cm_segment_valid_mask));
`endif

      relay_station #(
        .width(CMDataWidth)
      ) cm_segment_relay_i (
        .clk(clk),
        .rst(rst),
        .data_in(cm_segment_data_raw),
        .data_void_in(cm_segment_void_raw),
        .stop_in(cm_segment_stop),
        .data_out(cm_segment_data),
        .data_void_out(cm_segment_void),
        .stop_out(cm_segment_relay_stop)
      );

      assign cm_segment_flit.flit = cm_segment_data;
      assign cm_segment_target_tile_eff =
          (!cm_segment_void && cm_segment_flit.header.preamble.head) ?
          segment_local_tile(target_tile(cm_segment_flit.header.info.destination), CM_SEGMENTS, seg) :
          cm_segment_saved_target_tile;

      always_ff @(posedge clk) begin
        if (rst) begin
          cm_segment_saved_target_tile <= '0;
        end else if (!cm_segment_void && !cm_segment_stop && cm_segment_flit.header.preamble.head) begin
          cm_segment_saved_target_tile <=
              segment_local_tile(target_tile(cm_segment_flit.header.info.destination), CM_SEGMENTS, seg);
        end
      end

      d2d_expand_tree #(
        .LeafCount(SEG_SIZE),
        .DataWidth(CMDataWidth),
        .TileIndexWidth(TileIndexWidth),
        .RELAY_EVERY_LEVEL(1'b1),
        .RELAY_LEVEL0(1'b0),
        .RELAY_INCLUDE_LAST_LEVEL(1'b1)
      ) cm_segment_expand_i (
        .clk(clk),
        .rst(rst),
        .data_in(cm_segment_data),
        .data_void_in(cm_segment_void),
        .stop_out(cm_segment_stop),
        .target_tile_in(cm_segment_target_tile_eff),
        .target_mask_in('0),
        .noc_data_out(cm_segment_tile_data),
        .noc_data_void_out(cm_segment_tile_void),
        .noc_stop_in(cm_segment_tile_stop)
      );

      for (genvar tile = 0; tile < SEG_SIZE; tile++) begin : gen_segment_outputs
        localparam int unsigned GLOBAL_TILE = SEG_START + tile;
        assign cm_tile_data[GLOBAL_TILE] = cm_segment_tile_data[tile];
        assign cm_tile_void[GLOBAL_TILE] = cm_segment_tile_void[tile];
        assign cm_segment_tile_stop[tile] = cm_tile_stop[GLOBAL_TILE];
      end
    end

	    for (genvar root = 0; root < RXCHANNELS; root++) begin : gen_dma_tip_select
	      logic dma_tip_input_valid;
	      logic dma_tip_route_valid;
	      logic [DMA_TIPS-1:0] dma_tip_stop_mask;

	      assign dma_tip_input_valid =
	          dma_routable[root] && !dma_reservation_stop[root];
	      assign dma_tip_route_valid = |dma_tip_target_mask_eff[root];
	      assign dma_tip_select_stop[root] =
	          dma_tip_input_valid &&
	          (!dma_tip_route_valid || (|dma_tip_stop_mask));

      for (genvar tip = 0; tip < DMA_TIPS; tip++) begin : gen_dma_tip_outputs
        assign dma_tip_data[root][tip] =
            (tip == DMA_BYPASS_TIP) ? dma_input_flit[root].flit : dma_routed_input_data[root];
        assign dma_tip_void[root][tip] =
            !(dma_tip_input_valid &&
              dma_tip_route_valid &&
              !dma_tip_select_stop[root] &&
              dma_tip_target_mask_eff[root][tip]);
        assign dma_tip_stop_mask[tip] =
            dma_tip_target_mask_eff[root][tip] && dma_tip_stop[root][tip];
      end
    end

    for (genvar seg = 0; seg < DMA_SEGMENTS; seg++) begin : gen_dma_segments
      localparam int unsigned SEG_START = group_start(T, DMA_SEGMENTS, seg);
      localparam int unsigned SEG_SIZE = group_size(T, DMA_SEGMENTS, seg);
      logic [CHDataWidth-1:0] dma_segment_data_raw;
      logic dma_segment_void_raw;
      logic dma_segment_relay_stop;
      logic [CHDataWidth-1:0] dma_segment_data;
      logic dma_segment_void;
      logic dma_segment_stop;
      logic [RXCHANNELS-1:0] dma_segment_valid_mask;
      logic [CHDataWidth-1:0] dma_segment_data_routed;
      logic [SEG_SIZE-1:0] dma_segment_saved_target_mask;
      logic [SEG_SIZE-1:0] dma_segment_target_mask_eff;
      logic [CHDataWidth-1:0] dma_segment_tile_data [SEG_SIZE-1:0];
      logic dma_segment_tile_void [SEG_SIZE-1:0];
      logic dma_segment_tile_stop [SEG_SIZE-1:0];
      ch_flit_t dma_segment_flit;
      logic dma_segment_accepted;

      for (genvar root = 0; root < RXCHANNELS; root++) begin : gen_segment_inputs
        assign dma_segment_valid_mask[root] = !dma_tip_void[root][seg];
        assign dma_tip_stop[root][seg] = dma_segment_relay_stop;
      end

      always_comb begin
        dma_segment_data_raw = '0;
        dma_segment_void_raw = 1'b1;

        for (int unsigned root = 0; root < RXCHANNELS; root++) begin
          dma_segment_data_raw |= dma_tip_data[root][seg] &
                                  {CHDataWidth{!dma_tip_void[root][seg]}};
          dma_segment_void_raw &= dma_tip_void[root][seg];
        end
      end

`ifndef SYNTHESIS
      assert property (@(posedge clk) disable iff (rst)
        $onehot0(dma_segment_valid_mask));
`endif

      relay_station #(
        .width(CHDataWidth)
      ) dma_segment_relay_i (
        .clk(clk),
        .rst(rst),
        .data_in(dma_segment_data_raw),
        .data_void_in(dma_segment_void_raw),
        .stop_in(dma_segment_stop),
        .data_out(dma_segment_data),
        .data_void_out(dma_segment_void),
        .stop_out(dma_segment_relay_stop)
      );

      assign dma_segment_flit.flit = dma_segment_data;
      assign dma_segment_accepted = !dma_segment_void && !dma_segment_stop;

      assign dma_segment_data_routed =
          (!dma_segment_void && dma_segment_flit.header.preamble.head) ?
          ((DMASerialBeats == 1) ?
           rewrite_ch_head_flit(dma_segment_data,
                                dma_segment_flit.header.info.routing_lock,
                                dma_segment_flit.header.routing,
                                dma_segment_flit.header.info.mcast_type,
                                1'b1) :
           rewrite_dma_head_first_beat(dma_segment_data,
                                       dma_segment_flit.header.info.routing_lock,
                                       dma_segment_flit.header.routing,
                                       dma_segment_flit.header.info.mcast_type,
                                       1'b1)) :
          dma_segment_data;

      always_comb begin
        logic [noc::xWidth-1:0] destination_coord;
        logic [noc::xWidth-1:0] mask_coord;
        logic [noc::xWidth-1:0] allow0;
        logic [noc::xWidth-1:0] allow1;

        dma_segment_target_mask_eff = dma_segment_saved_target_mask;
        if (!dma_segment_void && dma_segment_flit.header.preamble.head) begin
          destination_coord = destination_axis(dma_segment_flit.header.info.destination);
          mask_coord = destination_axis(dma_segment_flit.header.info.destination_mask);
          allow0 = mask_coord | ~destination_coord;
          allow1 = mask_coord | destination_coord;
          for (int unsigned tile = 0; tile < SEG_SIZE; tile++) begin
            dma_segment_target_mask_eff[tile] =
                tile_matches_axis(SEG_START + tile, allow0, allow1);
          end
        end
      end

      always_ff @(posedge clk) begin
        if (rst) begin
          dma_segment_saved_target_mask <= '0;
        end else if (dma_segment_accepted) begin
          if (dma_segment_flit.header.preamble.head) begin
            dma_segment_saved_target_mask <= dma_segment_target_mask_eff;
          end
        end
      end

      d2d_expand_tree #(
        .LeafCount(SEG_SIZE),
        .DataWidth(CHDataWidth),
        .TileIndexWidth(TileIndexWidth),
        .USE_TARGET_MASK(1'b1),
        .RELAY_EVERY_LEVEL(1'b1),
        .RELAY_LEVEL0(1'b0),
        .RELAY_INCLUDE_LAST_LEVEL(1'b1)
      ) dma_segment_expand_i (
        .clk(clk),
        .rst(rst),
        .data_in(dma_segment_data_routed),
        .data_void_in(dma_segment_void),
        .stop_out(dma_segment_stop),
        .target_tile_in({TileIndexWidth{1'b0}}),
        .target_mask_in(dma_segment_target_mask_eff),
        .noc_data_out(dma_segment_tile_data),
        .noc_data_void_out(dma_segment_tile_void),
        .noc_stop_in(dma_segment_tile_stop)
      );

      for (genvar tile = 0; tile < SEG_SIZE; tile++) begin : gen_segment_outputs
        localparam int unsigned GLOBAL_TILE = SEG_START + tile;
        assign dma_tile_data[GLOBAL_TILE] = dma_segment_tile_data[tile];
        assign dma_tile_void[GLOBAL_TILE] = dma_segment_tile_void[tile];
        assign dma_segment_tile_stop[tile] = dma_tile_stop[GLOBAL_TILE];
      end
    end
  endgenerate

  generate
    for (genvar tile = 0; tile < T; tile++) begin : gen_cm_leaf_routers
      logic [3:0] cm_leaf_route;
      logic [CMDataWidth-1:0] cm_leaf_data_out [3:0];
      logic cm_leaf_void_out [3:0];
      logic cm_leaf_demux_stop_in [3:0];
      cm_flit_t cm_leaf_flit;

      assign cm_leaf_flit.flit = cm_tile_data[tile];

      always_comb begin
        cm_leaf_route = '0;
        if (!cm_tile_void[tile] && cm_leaf_flit.header.preamble.head) begin
          unique case (cm_leaf_flit.header.info.plane)
            noc::plane_t'(0): cm_leaf_route = 4'b0001;
            noc::plane_t'(1): cm_leaf_route = 4'b0010;
            noc::plane_t'(2): cm_leaf_route = 4'b0100;
            noc::plane_t'(3): cm_leaf_route = 4'b1000;
            default: cm_leaf_route = '0;
          endcase
        end
      end

      d2d_demux #(
        .N(4),
        .DataWidth(CMDataWidth)
      ) cm_leaf_demux_i (
        .clk(clk),
        .rst(rst),
        .data_in(cm_tile_data[tile]),
        .data_void_in(cm_tile_void[tile]),
        .stop_out(cm_tile_stop[tile]),
        .route_in(cm_leaf_route),
        .noc_data_out(cm_leaf_data_out),
        .noc_data_void_out(cm_leaf_void_out),
        .noc_stop_in(cm_leaf_demux_stop_in)
      );

      for (genvar plane = 0; plane < 4; plane++) begin : gen_plane_outputs
        if (plane == 0) begin : gen_noc1_out
          assign noc1_data_out[tile] = cm_leaf_data_out[plane];
          assign noc1_data_void_out[tile] = cm_leaf_void_out[plane];
          assign cm_leaf_demux_stop_in[plane] = noc1_stop_in[tile];
        end else if (plane == 1) begin : gen_noc2_out
          assign noc2_data_out[tile] = cm_leaf_data_out[plane];
          assign noc2_data_void_out[tile] = cm_leaf_void_out[plane];
          assign cm_leaf_demux_stop_in[plane] = noc2_stop_in[tile];
        end else if (plane == 2) begin : gen_noc3_out
          assign noc3_data_out[tile] = cm_leaf_data_out[plane];
          assign noc3_data_void_out[tile] = cm_leaf_void_out[plane];
          assign cm_leaf_demux_stop_in[plane] = noc3_stop_in[tile];
        end else begin : gen_noc5_out
          assign noc5_data_out[tile] = cm_leaf_data_out[plane];
          assign noc5_data_void_out[tile] = cm_leaf_void_out[plane];
          assign cm_leaf_demux_stop_in[plane] = noc5_stop_in[tile];
        end
      end
    end

    for (genvar tile = 0; tile < T; tile++) begin : gen_dma_leaf_merges
      logic [1:0] dma_leaf_route;
      logic [CHDataWidth-1:0] dma_leaf_data_out [1:0];
      logic dma_leaf_void_out [1:0];
      logic dma_leaf_demux_stop_in [1:0];
      logic dma_leaf_deser_void_in [1:0];
      logic dma_leaf_deser_stop [1:0];
      ch_flit_t dma_leaf_flit;

      assign dma_leaf_flit.flit = dma_tile_data[tile];
      assign dma_leaf_demux_stop_in[0] = dma_leaf_deser_stop[0];
      assign dma_leaf_demux_stop_in[1] = dma_leaf_deser_stop[1];
      assign dma_leaf_deser_void_in[0] = dma_leaf_void_out[0];
      assign dma_leaf_deser_void_in[1] = dma_leaf_void_out[1];

      always_comb begin
        dma_leaf_route = '0;
        if (!dma_tile_void[tile] && dma_leaf_flit.header.preamble.head) begin
          unique case (dma_leaf_flit.header.info.plane)
            noc::plane_t'(4): dma_leaf_route = 2'b01;
            noc::plane_t'(5): dma_leaf_route = 2'b10;
            default: dma_leaf_route = '0;
          endcase
        end
      end

      d2d_demux #(
        .N(2),
        .DataWidth(CHDataWidth)
      ) dma_leaf_demux_i (
        .clk(clk),
        .rst(rst),
        .data_in(dma_tile_data[tile]),
        .data_void_in(dma_tile_void[tile]),
        .stop_out(dma_tile_stop[tile]),
        .route_in(dma_leaf_route),
        .noc_data_out(dma_leaf_data_out),
        .noc_data_void_out(dma_leaf_void_out),
        .noc_stop_in(dma_leaf_demux_stop_in)
      );

      d2d_dma_deserializer #(
        .CHDataWidth(CHDataWidth),
        .DMADataWidth(DMADataWidth)
      ) noc4_deserializer_i (
        .clk(clk),
        .rst(rst),
        .data_in(dma_leaf_data_out[0]),
        .data_void_in(dma_leaf_deser_void_in[0]),
	        .stop_out(dma_leaf_deser_stop[0]),
	        .data_out(noc4_data_out[tile]),
	        .data_void_out(noc4_data_void_raw[tile]),
	        .stop_in(noc4_stop_in[tile])
	      );

      d2d_dma_deserializer #(
        .CHDataWidth(CHDataWidth),
        .DMADataWidth(DMADataWidth)
      ) noc6_deserializer_i (
        .clk(clk),
        .rst(rst),
        .data_in(dma_leaf_data_out[1]),
        .data_void_in(dma_leaf_deser_void_in[1]),
	        .stop_out(dma_leaf_deser_stop[1]),
	        .data_out(noc6_data_out[tile]),
	        .data_void_out(noc6_data_void_raw[tile]),
	        .stop_in(noc6_stop_in[tile])
	      );

      assign noc4_data_void_out[tile] = noc4_data_void_raw[tile];
      assign noc6_data_void_out[tile] = noc6_data_void_raw[tile];
    end

    for (genvar lane = 0; lane < CM_LANES; lane++) begin : gen_cm_bypass_tip_inputs
      assign cm_bypass_valid_mask[lane] = !cm_tip_void[lane][CM_BYPASS_TIP];
      assign cm_tip_stop[lane][CM_BYPASS_TIP] = cmbypass_relay_stop;
    end

    for (genvar root = 0; root < RXCHANNELS; root++) begin : gen_dma_bypass_tip_inputs
      assign dma_bypass_valid_mask[root] = !dma_tip_void[root][DMA_BYPASS_TIP];
      assign dma_tip_stop[root][DMA_BYPASS_TIP] = dmabypass_relay_stop;
    end
  endgenerate

  always_comb begin
    cmbypass_data_raw = '0;
    cmbypass_data_void_raw = 1'b1;

    for (int unsigned lane = 0; lane < CM_LANES; lane++) begin
      cmbypass_data_raw |= cm_tip_data[lane][CM_BYPASS_TIP] &
                           {CMDataWidth{!cm_tip_void[lane][CM_BYPASS_TIP]}};
      cmbypass_data_void_raw &= cm_tip_void[lane][CM_BYPASS_TIP];
    end
  end

`ifndef SYNTHESIS
  assert property (@(posedge clk) disable iff (rst)
    $onehot0(cm_bypass_valid_mask));
`endif

  assign cmbypass_flit.flit = cmbypass_data_raw;

  d2d_lookahead_bypass_routing #(
    .chip(chip_coordinates),
    .d2d_position(d2d_position)
  ) cm_bypass_lookahead_routing_i (
    .destination_chip(cmbypass_flit.header.info.destination_chip),
    .destination_chip_mask(cmbypass_flit.header.info.destination_chip_mask),
    .uni_or_mcast(cmbypass_flit.header.info.uni_or_mcast),
    .routing_lock(cmbypass_routing_lock),
    .next_routing(cmbypass_next_routing),
    .next_mcast_type(cmbypass_next_mcast_type)
  );

  assign cmbypass_data_routed =
      (!cmbypass_data_void_raw && cmbypass_flit.header.preamble.head) ?
      rewrite_cm_head_flit(cmbypass_data_raw,
                           cmbypass_routing_lock,
                           cmbypass_next_routing,
                           cmbypass_next_mcast_type,
                           1'b0) :
      cmbypass_data_raw;

  relay_station #(
    .width(CMDataWidth)
  ) cmbypass_relay_i (
    .clk(clk),
    .rst(rst),
    .data_in(cmbypass_data_routed),
    .data_void_in(cmbypass_data_void_raw),
    .stop_in(cmbypass_stop_in),
    .data_out(cmbypass_data_out),
    .data_void_out(cmbypass_data_void_out),
    .stop_out(cmbypass_relay_stop)
  );

  always_comb begin
    dmabypass_data_raw = '0;
    dmabypass_data_void_raw = 1'b1;

    for (int unsigned root = 0; root < RXCHANNELS; root++) begin
      dmabypass_data_raw |= dma_tip_data[root][DMA_BYPASS_TIP] &
                            {CHDataWidth{!dma_tip_void[root][DMA_BYPASS_TIP]}};
      dmabypass_data_void_raw &= dma_tip_void[root][DMA_BYPASS_TIP];
    end
  end

`ifndef SYNTHESIS
  assert property (@(posedge clk) disable iff (rst)
    $onehot0(dma_bypass_valid_mask));
`endif

  assign dmabypass_flit.flit = dmabypass_data_raw;
  assign dmabypass_last_serial_beat =
      (dmabypass_serial_beat == DMABeatWidth'(DMASerialBeats - 1));
  assign dmabypass_rewrite_last_head_beat =
      dmabypass_header_route_pending && dmabypass_last_serial_beat;
  assign dmabypass_accepted = !dmabypass_data_void_raw && !dmabypass_relay_stop;

  d2d_lookahead_bypass_routing #(
    .chip(chip_coordinates),
    .d2d_position(d2d_position)
  ) dma_bypass_lookahead_routing_i (
    .destination_chip(dmabypass_flit.header.info.destination_chip),
    .destination_chip_mask(ch_destination_chip_mask(dmabypass_data_raw)),
    .uni_or_mcast(dmabypass_flit.header.info.uni_or_mcast),
    .routing_lock(dmabypass_routing_lock),
    .next_routing(dmabypass_next_routing),
    .next_mcast_type(dmabypass_next_mcast_type)
  );

  assign dmabypass_data_routed =
      (!dmabypass_data_void_raw && dmabypass_flit.header.preamble.head) ?
      ((DMASerialBeats == 1) ?
       rewrite_ch_head_flit(dmabypass_data_raw,
                            dmabypass_routing_lock,
                            dmabypass_next_routing,
                            dmabypass_next_mcast_type,
                            1'b0) :
       rewrite_dma_head_first_beat(dmabypass_data_raw,
                                   dmabypass_routing_lock,
                                   dmabypass_next_routing,
                                   dmabypass_next_mcast_type,
                                   1'b0)) :
      (dmabypass_rewrite_last_head_beat ?
       rewrite_dma_head_last_beat(dmabypass_data_raw, dmabypass_saved_next_routing) :
       dmabypass_data_raw);

  always_ff @(posedge clk) begin
    if (rst) begin
      dmabypass_header_route_pending <= 1'b0;
      dmabypass_serial_beat <= '0;
      dmabypass_saved_next_routing <= '0;
    end else if (dmabypass_accepted) begin
      if (dmabypass_flit.header.preamble.head) begin
        dmabypass_saved_next_routing <= dmabypass_next_routing;
        dmabypass_header_route_pending <= (DMASerialBeats > 1);
      end else if (dmabypass_rewrite_last_head_beat) begin
        dmabypass_header_route_pending <= 1'b0;
      end

      if (dmabypass_last_serial_beat) begin
        dmabypass_serial_beat <= '0;
      end else begin
        dmabypass_serial_beat <= dmabypass_serial_beat + 1'b1;
      end
    end
  end

  relay_station #(
    .width(CHDataWidth)
  ) dmabypass_relay_i (
    .clk(clk),
    .rst(rst),
    .data_in(dmabypass_data_routed),
    .data_void_in(dmabypass_data_void_raw),
    .stop_in(dmabypass_stop_in),
    .data_out(dmabypass_data_out),
    .data_void_out(dmabypass_data_void_out),
    .stop_out(dmabypass_relay_stop)
  );

endmodule
