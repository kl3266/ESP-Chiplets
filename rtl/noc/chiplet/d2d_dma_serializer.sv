module d2d_dma_serializer #(
    parameter int unsigned CHDataWidth = 66,
    parameter int unsigned DMADataWidth = 258,
    parameter int unsigned TILE_ID = 0,
    parameter int unsigned PLANE_ID = 3
  )
(
  input  logic clk,
  input  logic rst,
  input  logic [DMADataWidth-1:0] data_in,
  input  logic data_void_in,
  output logic stop_out,
  output logic [CHDataWidth-1:0] data_out,
  output logic data_void_out,
  input  logic stop_in
);

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
  localparam int unsigned DdrPackedBeatWidth = 132;
  localparam int unsigned DdrPackedPayloadWidth = 128;
  localparam int unsigned PackedChunks =
      ((CHDataWidth % DdrPackedBeatWidth) == 0) ? (CHDataWidth / DdrPackedBeatWidth) : 0;
  localparam bit UseDdrPackedBeat = (PackedChunks != 0);
  localparam int unsigned SegmentWidth =
      UseDdrPackedBeat ? (PackedChunks * DdrPackedPayloadWidth) : (CHDataWidth - 2);
  localparam int unsigned PayloadBits = DMADataWidth - 2;
  localparam int unsigned SerialBeats = (PayloadBits + SegmentWidth - 1) / SegmentWidth;
  localparam int unsigned BeatWidth = (SerialBeats > 1) ? $clog2(SerialBeats) : 1;

  typedef struct packed {
    noc::xy_t source;
    noc::xy_t destination;
    noc::message_t message;
    noc::tile_t tile;
    noc::plane_t plane;
    noc::routing_lock_t routing_lock;
    noc::chip_xy_t source_chip;
    noc::chip_xy_t destination_chip;
    noc::pkt_type_t uni_or_mcast;
    noc::mcast_t mcast_type;
    noc::xy_t destination_mask;
    logic [ChReservedWidth-1:0] reserved;
    noc::chip_xy_t destination_chip_mask;
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
    noc::pkt_type_t uni_or_mcast;
    noc::mcast_t mcast_type;
    noc::xy_t destination_mask;
    logic [DmaReservedWidth-1:0] reserved;
    noc::chip_xy_t destination_chip_mask;
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

  dma_flit_t in_flit;
  ch_flit_t out_flit;
  logic [BeatWidth-1:0] beat;
  logic [SegmentWidth-1:0] segment;
  logic accept_beat, last_beat;

  function automatic noc::chip_xy_t dma_destination_chip_mask(
      input logic [DMADataWidth-1:0] flit
  );
    return flit[DMADataWidth-DestinationChipMaskPreWidth-1 -: $bits(noc::chip_xy_t)];
  endfunction

  function automatic logic [CHDataWidth-1:0] set_ch_destination_chip_mask(
      input logic [CHDataWidth-1:0] flit,
      input noc::chip_xy_t mask
  );
    logic [CHDataWidth-1:0] flit_tmp;
    begin
      flit_tmp = flit;
      flit_tmp[CHDataWidth-DestinationChipMaskPreWidth-1 -: $bits(noc::chip_xy_t)] = mask;
      return flit_tmp;
    end
  endfunction

  assign in_flit.flit = data_in;
  assign accept_beat = !data_void_in && !stop_in;
  assign last_beat = (beat == BeatWidth'(SerialBeats - 1));

  initial begin
    if (UseDdrPackedBeat && ((PayloadBits % SegmentWidth) != 0)) begin
      $error("d2d_dma_serializer expects DMA payload bits to be a multiple of %0d when CHDataWidth is packed into 132-bit DDR chunks",
             SegmentWidth);
    end
  end

  always_comb begin
    segment = '0;
    out_flit = '0;

    if (UseDdrPackedBeat) begin
      for (int chunk = 0; chunk < PackedChunks; chunk++) begin
        int chunk_hi;

        chunk_hi = (PayloadBits - 1) - (int'(beat) * SegmentWidth) -
                   (chunk * DdrPackedPayloadWidth);
        out_flit.flit[CHDataWidth-1-(chunk*DdrPackedBeatWidth) -: DdrPackedBeatWidth] = {
            in_flit.header.preamble.head && (beat == '0),
            in_flit.header.preamble.tail && last_beat,
            data_in[chunk_hi -: 64],
            2'b00,
            data_in[(chunk_hi - 64) -: 64]
        };
      end
    end else begin
      for (int bit_idx = 0; bit_idx < SegmentWidth; bit_idx++) begin
        int src_bit;
        src_bit = (PayloadBits - 1) - (int'(beat) * SegmentWidth) - bit_idx;
        if (src_bit >= 0) begin
          segment[SegmentWidth-1-bit_idx] = data_in[src_bit];
        end
      end
      out_flit.flit = {in_flit.header.preamble.head && (beat == '0),
                       in_flit.header.preamble.tail && last_beat,
                       segment};
    end

    if (!data_void_in && in_flit.header.preamble.head && (beat == '0)) begin
	      out_flit.header.info.tile = noc::tile_t'(TILE_ID);
	      out_flit.header.info.plane = noc::plane_t'(PLANE_ID);
	      out_flit.header.info.routing_lock = 1'b0;
	      out_flit.flit = set_ch_destination_chip_mask(out_flit.flit,
	                                                   dma_destination_chip_mask(data_in));
	      out_flit.header.routing = in_flit.header.routing;
	    end
  end

  assign data_out = out_flit.flit;
  assign data_void_out = data_void_in;
  assign stop_out = !data_void_in && !(accept_beat && last_beat);

  always_ff @(posedge clk) begin
    if (rst) begin
      beat <= '0;
    end else if (data_void_in) begin
      beat <= '0;
    end else if (accept_beat) begin
      if (last_beat) begin
        beat <= '0;
      end else begin
        beat <= beat + 1'b1;
      end
    end
  end

endmodule
