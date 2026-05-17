module d2d_dma_deserializer #(
    parameter int unsigned CHDataWidth = 132,
    parameter int unsigned DMADataWidth = 258
  )
(
  input  logic clk,
  input  logic rst,
  input  logic [CHDataWidth-1:0] data_in,
  input  logic data_void_in,
  output logic stop_out,
  output logic [DMADataWidth-1:0] data_out,
  output logic data_void_out,
  input  logic stop_in
);

  localparam int DmaReservedWidth =
      DMADataWidth - $bits(noc::preamble_t) - 3*$bits(noc::xy_t) - $bits(noc::message_t) -
      $bits(noc::tile_t) - $bits(noc::plane_t) - $bits(noc::routing_lock_t) -
      3*$bits(noc::chip_xy_t) - $bits(noc::direction_t) - $bits(noc::mcast_t) - $bits(noc::pkt_type_t);
  localparam int unsigned PackedBeatWidth = 132;
  localparam int unsigned PackedPayloadWidth = 128;
  localparam int unsigned PayloadBits = DMADataWidth - 2;
  localparam int unsigned SerialBeats = PayloadBits / PackedPayloadWidth;
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

  dma_flit_t assembled_flit, next_flit;
  logic [BeatWidth-1:0] beat;
  logic out_valid;
  logic accept_in, accept_out, last_beat;
  logic [PackedPayloadWidth-1:0] beat_payload;

  initial begin
    if (CHDataWidth != PackedBeatWidth) begin
      $error("d2d_dma_deserializer expects CHDataWidth == 132");
    end
    if ((PayloadBits % PackedPayloadWidth) != 0) begin
      $error("d2d_dma_deserializer expects DMA payload bits to be a multiple of 128");
    end
  end

  assign accept_out = out_valid && !stop_in;
  assign stop_out = out_valid && stop_in;
  assign accept_in = !data_void_in && !stop_out;
  assign last_beat = (beat == BeatWidth'(SerialBeats - 1));
  assign data_out = assembled_flit.flit;
  assign data_void_out = !out_valid;
  assign beat_payload = {data_in[129:66], data_in[63:0]};

  always_comb begin
    int payload_hi;

    next_flit = assembled_flit;
    if (beat == '0) begin
      next_flit = '0;
      next_flit.header.preamble.head = data_in[CHDataWidth-1];
    end

    // Match the old dma_last_flit reconstruction: first beat seeds the header,
    // every accepted beat then drops a contiguous 128-bit payload slice below it.
    payload_hi = DMADataWidth - 3 - (int'(beat) * PackedPayloadWidth);
    next_flit.flit[payload_hi -: PackedPayloadWidth] = beat_payload;

    if (last_beat) begin
      next_flit.header.preamble.tail = data_in[130];
    end
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      assembled_flit <= '0;
      beat <= '0;
      out_valid <= 1'b0;
    end else begin
      if (accept_out) begin
        out_valid <= 1'b0;
      end

      if (accept_in) begin
        assembled_flit <= next_flit;
        if (last_beat) begin
          beat <= '0;
          out_valid <= 1'b1;
        end else begin
          beat <= beat + 1'b1;
        end
      end
    end
  end

endmodule
