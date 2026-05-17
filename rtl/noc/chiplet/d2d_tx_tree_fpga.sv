module d2d_tx_tree_fpga #(
  parameter int unsigned TXCHANNELS   = 2,
  parameter int unsigned TILES        = 3,
  parameter bit FlowControl = 1'b0,
  parameter int unsigned CHDataWidth = 66,
  parameter int unsigned COHDataWidth = 66,
  parameter int unsigned MISCDataWidth = 66,
  parameter int unsigned DMADataWidth = 130,
  parameter logic [1:0] d2d_position = 2'b00,
  parameter noc::chip_xy_t chip_coordinates
)(
  input   logic clk,
  input   logic rst,
  input   logic d2d_rst,
  input   logic d2d_clk_in,

  // D2D Tx --> D2D Rx
  // d2d_snd_data_out[g_i][2*CHDataWidth-1:CHDataWidth] is the posedge half.
  // d2d_snd_data_out[g_i][CHDataWidth-1:0] is the negedge half.
  output  logic [2*CHDataWidth-1:0] d2d_snd_data_out [TXCHANNELS-1:0],
  output  logic [1:0]               d2d_valid_out [TXCHANNELS-1:0],
  output  logic                     d2d_link_ready,

  // D2D Rx --> D2D Tx
  input   logic [1:0]               d2d_credit_in [TXCHANNELS-1:0],

  // NoC    --> D2D
  input   logic [COHDataWidth-1:0]  noc1_data_in [TILES-1:0],
  input   logic [COHDataWidth-1:0]  noc2_data_in [TILES-1:0],
  input   logic [COHDataWidth-1:0]  noc3_data_in [TILES-1:0],
  input   logic [DMADataWidth-1:0]  noc4_data_in [TILES-1:0],
  input   logic [MISCDataWidth-1:0] noc5_data_in [TILES-1:0],
  input   logic [DMADataWidth-1:0]  noc6_data_in [TILES-1:0],
  input   logic [CHDataWidth-1:0]   cmbypass_data_in,
  input   logic [2*CHDataWidth-1:0] dmabypass_data_in,
  input   logic [TILES-1:0]         noc1_data_void_in,
  input   logic [TILES-1:0]         noc2_data_void_in,
  input   logic [TILES-1:0]         noc3_data_void_in,
  input   logic [TILES-1:0]         noc4_data_void_in,
  input   logic [TILES-1:0]         noc5_data_void_in,
  input   logic [TILES-1:0]         noc6_data_void_in,
  input   logic                     cmbypass_data_void_in,
  input   logic                     dmabypass_data_void_in,

  // D2D    --> NoC
  output  logic [TILES-1:0]         noc1_stop_out,
  output  logic [TILES-1:0]         noc2_stop_out,
  output  logic [TILES-1:0]         noc3_stop_out,
  output  logic [TILES-1:0]         noc4_stop_out,
  output  logic [TILES-1:0]         noc5_stop_out,
  output  logic [TILES-1:0]         noc6_stop_out,
  output  logic                     cmbypass_stop_out,
  output  logic                     dmabypass_stop_out
);

  localparam int unsigned LaneCount = 2 * TXCHANNELS;
  localparam int unsigned D2D_QUEUE_DEPTH = 8;
  localparam int unsigned D2D_FIFO_DEPTH = 4 * D2D_QUEUE_DEPTH;
  localparam int unsigned CreditWidth = $clog2(D2D_FIFO_DEPTH + 1);
  localparam int unsigned TreeCHDataWidth = LaneCount * CHDataWidth;
  localparam int unsigned STARTUP_PULSES = 4;
  localparam int unsigned StartupCountWidth = $clog2(STARTUP_PULSES + 1);
  localparam int unsigned PreambleWidth = $bits(noc::preamble_t);
  localparam int unsigned DmaBeatPayloadWidth = 2 * (CHDataWidth - PreambleWidth);
  localparam int unsigned DmaPayloadWidth = DMADataWidth - PreambleWidth;
  localparam int ReservedWidth =
      CHDataWidth - $bits(noc::preamble_t) - 3*$bits(noc::xy_t) - $bits(noc::message_t) -
      $bits(noc::tile_t) - $bits(noc::plane_t) - $bits(noc::routing_lock_t) -
      3*$bits(noc::chip_xy_t) - $bits(noc::direction_t) - $bits(noc::mcast_t) - $bits(noc::pkt_type_t);

  typedef enum logic [2:0] {
    state_reset,
    state_ack,
    state_train,
    state_ready
  } d2d_state_t;

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
    logic [CHDataWidth-1:0] flit;
  } flit_t;

  // logic d2d_clk_n;
  logic fifo_rst;
  logic rst_clk;
  logic rst_d2d_pos;
  logic rst_d2d_neg;
  logic rstn_fifo_clk;
  logic rstn_fifo_d2d_pos;
  logic rstn_fifo_d2d_neg;
  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic fifo_rst_clk_sync_ff1 = 1'b1;
  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic fifo_rst_clk_sync_ff2 = 1'b1;
  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic fifo_rst_d2d_pos_sync_ff1 = 1'b1;
  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic fifo_rst_d2d_pos_sync_ff2 = 1'b1;
  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic fifo_rst_d2d_neg_sync_ff1 = 1'b1;
  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic fifo_rst_d2d_neg_sync_ff2 = 1'b1;

  logic [TreeCHDataWidth-1:0] tree_data_out;
  logic [LaneCount-1:0] tree_data_void_out;
  logic [LaneCount-1:0] tree_stop_in;
  logic [CHDataWidth-1:0] tree_lane_data [LaneCount-1:0];
  logic noc1_data_void_tree [TILES-1:0];
  logic noc2_data_void_tree [TILES-1:0];
  logic noc3_data_void_tree [TILES-1:0];
  logic noc4_data_void_tree [TILES-1:0];
  logic noc5_data_void_tree [TILES-1:0];
  logic noc6_data_void_tree [TILES-1:0];
  logic noc1_stop_tree [TILES-1:0];
  logic noc2_stop_tree [TILES-1:0];
  logic noc3_stop_tree [TILES-1:0];
  logic noc4_stop_tree [TILES-1:0];
  logic noc5_stop_tree [TILES-1:0];
  logic noc6_stop_tree [TILES-1:0];

  logic d2d_snd_wrreq [LaneCount-1:0];
  logic d2d_snd_full [LaneCount-1:0];
  logic d2d_snd_rdreq [LaneCount-1:0];
  logic d2d_snd_empty [LaneCount-1:0];
  logic [CHDataWidth-1:0] d2d_fifo_q [LaneCount-1:0];
  logic d2d_rdy [LaneCount-1:0];
  logic [StartupCountWidth-1:0] startup_credit_cnt [LaneCount-1:0];
  logic d2d_credit_in_int [LaneCount-1:0];
  d2d_state_t state [LaneCount-1:0];
  logic cm_packet_active [LaneCount-1:0];
  logic dma_packet_active [TXCHANNELS-1:0];
  logic tree_dma_packet_active [TXCHANNELS-1:0];

  typedef logic [CreditWidth-1:0] credits_t [LaneCount-1:0];
  credits_t credits;

  function automatic logic is_cm_plane(input noc::plane_t plane);
    return !plane[2];
  endfunction

  initial begin
    if (COHDataWidth != CHDataWidth) begin
      $error("d2d_tx_tree_fpga expects COHDataWidth == CHDataWidth");
    end
    if (MISCDataWidth != CHDataWidth) begin
      $error("d2d_tx_tree_fpga expects MISCDataWidth == CHDataWidth");
    end
    if (TXCHANNELS < 1) begin
      $error("d2d_tx_tree_fpga expects TXCHANNELS >= 1");
    end
    if ((DmaPayloadWidth % DmaBeatPayloadWidth) != 0) begin
      $error("d2d_tx_tree_fpga expects DMA payload bits to be an integer multiple of %0d",
             DmaBeatPayloadWidth);
    end
  end

  // assign d2d_clk_n = ~d2d_clk_in;
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
      fifo_rst_d2d_pos_sync_ff1 <= 1'b1;
      fifo_rst_d2d_pos_sync_ff2 <= 1'b1;
    end else begin
      fifo_rst_d2d_pos_sync_ff1 <= 1'b0;
      fifo_rst_d2d_pos_sync_ff2 <= fifo_rst_d2d_pos_sync_ff1;
    end
  end

  always_ff @(posedge d2d_clk_in or posedge fifo_rst) begin
    if (fifo_rst) begin
      fifo_rst_d2d_neg_sync_ff1 <= 1'b1;
      fifo_rst_d2d_neg_sync_ff2 <= 1'b1;
    end else begin
      fifo_rst_d2d_neg_sync_ff1 <= 1'b0;
      fifo_rst_d2d_neg_sync_ff2 <= fifo_rst_d2d_neg_sync_ff1;
    end
  end

  assign rst_clk = fifo_rst_clk_sync_ff2;
  assign rst_d2d_pos = fifo_rst_d2d_pos_sync_ff2;
  assign rst_d2d_neg = fifo_rst_d2d_neg_sync_ff2;
  assign rstn_fifo_clk = ~rst_clk;
  assign rstn_fifo_d2d_pos = ~rst_d2d_pos;
  assign rstn_fifo_d2d_neg = ~rst_d2d_neg;

  generate
    for (genvar g_i = 0; g_i < TXCHANNELS; g_i++) begin : gen_tree_channels
      localparam int unsigned NEG_LANE = 2 * g_i;
      localparam int unsigned POS_LANE = NEG_LANE + 1;
      flit_t tree_top_flit;
      logic tree_top_valid;
      logic tree_dma_present;
      logic tree_pair_has_space;
      logic tree_dma_pair_write;

      assign tree_lane_data[POS_LANE] = tree_data_out[(POS_LANE+1)*CHDataWidth-1 -: CHDataWidth];
      assign tree_lane_data[NEG_LANE] = tree_data_out[(NEG_LANE+1)*CHDataWidth-1 -: CHDataWidth];
      assign tree_top_flit.flit = tree_lane_data[POS_LANE];
      assign tree_top_valid = !tree_data_void_out[POS_LANE];
      assign tree_dma_present =
          tree_dma_packet_active[g_i] ||
          (tree_top_valid &&
           tree_top_flit.header.preamble.head &&
           !is_cm_plane(tree_top_flit.header.info.plane));
      assign tree_pair_has_space = !d2d_snd_full[POS_LANE] && !d2d_snd_full[NEG_LANE];
      assign tree_dma_pair_write =
          tree_dma_present &&
          tree_pair_has_space &&
          !tree_data_void_out[POS_LANE] &&
          !tree_data_void_out[NEG_LANE];

      assign tree_stop_in[POS_LANE] = tree_dma_present ? !tree_pair_has_space : d2d_snd_full[POS_LANE];
      assign tree_stop_in[NEG_LANE] = tree_dma_present ? !tree_pair_has_space : d2d_snd_full[NEG_LANE];
      assign d2d_snd_wrreq[POS_LANE] =
          tree_dma_present ? tree_dma_pair_write : (~tree_data_void_out[POS_LANE] && ~d2d_snd_full[POS_LANE]);
      assign d2d_snd_wrreq[NEG_LANE] =
          tree_dma_present ? tree_dma_pair_write : (~tree_data_void_out[NEG_LANE] && ~d2d_snd_full[NEG_LANE]);

      always_ff @(posedge clk) begin
        if (rst_clk) begin
          tree_dma_packet_active[g_i] <= 1'b0;
        end else if (tree_dma_pair_write) begin
          tree_dma_packet_active[g_i] <= !tree_top_flit.header.preamble.tail;
        end
      end
    end

    for (genvar tile = 0; tile < TILES; tile++) begin : gen_tree_port_adapters
      assign noc1_data_void_tree[tile] = noc1_data_void_in[tile];
      assign noc2_data_void_tree[tile] = noc2_data_void_in[tile];
      assign noc3_data_void_tree[tile] = noc3_data_void_in[tile];
      assign noc4_data_void_tree[tile] = noc4_data_void_in[tile];
      assign noc5_data_void_tree[tile] = noc5_data_void_in[tile];
      assign noc6_data_void_tree[tile] = noc6_data_void_in[tile];

      assign noc1_stop_out[tile] = noc1_stop_tree[tile];
      assign noc2_stop_out[tile] = noc2_stop_tree[tile];
      assign noc3_stop_out[tile] = noc3_stop_tree[tile];
      assign noc4_stop_out[tile] = noc4_stop_tree[tile];
      assign noc5_stop_out[tile] = noc5_stop_tree[tile];
      assign noc6_stop_out[tile] = noc6_stop_tree[tile];
    end
  endgenerate

  generate
    for (genvar g_i = 0; g_i < TXCHANNELS; g_i++) begin : gen_d2d_channels
      localparam int unsigned NEG_LANE = 2 * g_i;
      localparam int unsigned POS_LANE = NEG_LANE + 1;

      assign d2d_credit_in_int[POS_LANE] = d2d_credit_in[g_i][1];
      assign d2d_credit_in_int[NEG_LANE] = d2d_credit_in[g_i][0];
      assign d2d_snd_rdreq[POS_LANE] = (credits[POS_LANE] == '0) ? 1'b0 :
                                       (!d2d_snd_empty[POS_LANE] &&
                                        (state[POS_LANE] == state_ready));
      assign d2d_snd_rdreq[NEG_LANE] = (credits[NEG_LANE] == '0) ? 1'b0 :
                                       (!d2d_snd_empty[NEG_LANE] &&
                                        (state[NEG_LANE] == state_ready));
      assign d2d_valid_out[g_i][1] = d2d_snd_rdreq[POS_LANE] || d2d_rdy[POS_LANE];
      assign d2d_valid_out[g_i][0] = d2d_snd_rdreq[NEG_LANE] || d2d_rdy[NEG_LANE];
      assign d2d_snd_data_out[g_i] = {d2d_fifo_q[POS_LANE], d2d_fifo_q[NEG_LANE]};

      // D2D Handshake for POS_LANE
      always_ff @(posedge d2d_clk_in) begin
        if (rst_d2d_pos) begin
          state[POS_LANE] <= state_reset;
          startup_credit_cnt[POS_LANE] <= '0;
          d2d_rdy[POS_LANE] <= 1'b0;
        end else begin
          if (state[POS_LANE] == state_reset) begin
            state[POS_LANE] <= state_ack;
          end
          if (state[POS_LANE] == state_ack) begin
            if (startup_credit_cnt[POS_LANE] == STARTUP_PULSES-1) begin
              d2d_rdy[POS_LANE] <= 1'b0;
              startup_credit_cnt[POS_LANE] <= '0;
              state[POS_LANE] <= state_ready;
            end else begin
              d2d_rdy[POS_LANE] <= 1'b1;
              if (d2d_credit_in_int[POS_LANE]) begin
                startup_credit_cnt[POS_LANE] <= startup_credit_cnt[POS_LANE] + 1'b1;
              end
            end
          end
        end
      end

      // D2D Handshake for NEG_LANE
      always_ff @(posedge d2d_clk_in) begin
        if (rst_d2d_neg) begin
          state[NEG_LANE] <= state_reset;
          startup_credit_cnt[NEG_LANE] <= '0;
          d2d_rdy[NEG_LANE] <= 1'b0;
        end else begin
          if (state[NEG_LANE] == state_reset) begin
            state[NEG_LANE] <= state_ack;
          end
          if (state[NEG_LANE] == state_ack) begin
            if (startup_credit_cnt[NEG_LANE] == STARTUP_PULSES-1) begin
              d2d_rdy[NEG_LANE] <= 1'b0;
              startup_credit_cnt[NEG_LANE] <= '0;
              state[NEG_LANE] <= state_ready;
            end else begin
              d2d_rdy[NEG_LANE] <= 1'b1;
              if (d2d_credit_in_int[NEG_LANE]) begin
                startup_credit_cnt[NEG_LANE] <= startup_credit_cnt[NEG_LANE] + 1'b1;
              end
            end
          end
        end
      end

      // D2D Credit for POS_LANE
      always_ff @(posedge d2d_clk_in) begin
        if (rst_d2d_pos) begin
          credits[POS_LANE] <= D2D_FIFO_DEPTH;
        end else begin
          assert (!((state[POS_LANE] == state_ready) && d2d_credit_in_int[POS_LANE] &&
                    (credits[POS_LANE] == D2D_FIFO_DEPTH)))
            else $fatal(1,
                        "d2d_tx_tree_fpga credit overflow: lane %0d received a credit event in state_ready while credits == %0d",
                        POS_LANE,
                        D2D_FIFO_DEPTH);
          if (!d2d_credit_in_int[POS_LANE] && d2d_snd_rdreq[POS_LANE] &&
              (credits[POS_LANE] != '0)) begin
            credits[POS_LANE] <= credits[POS_LANE] - 1'b1;
          end else if (d2d_credit_in_int[POS_LANE] && !d2d_snd_rdreq[POS_LANE] &&
                       (credits[POS_LANE] != D2D_FIFO_DEPTH)) begin
            credits[POS_LANE] <= credits[POS_LANE] + 1'b1;
          end
        end
      end

      // D2D Credit for NEG_LANE
      always_ff @(posedge d2d_clk_in) begin
        if (rst_d2d_neg) begin
          credits[NEG_LANE] <= D2D_FIFO_DEPTH;
        end else begin
          assert (!((state[NEG_LANE] == state_ready) && d2d_credit_in_int[NEG_LANE] &&
                    (credits[NEG_LANE] == D2D_FIFO_DEPTH)))
            else $fatal(1,
                        "d2d_tx_tree_fpga credit overflow: lane %0d received a credit event in state_ready while credits == %0d",
                        NEG_LANE,
                        D2D_FIFO_DEPTH);
          if (!d2d_credit_in_int[NEG_LANE] && d2d_snd_rdreq[NEG_LANE] &&
              (credits[NEG_LANE] != '0)) begin
            credits[NEG_LANE] <= credits[NEG_LANE] - 1'b1;
          end else if (d2d_credit_in_int[NEG_LANE] && !d2d_snd_rdreq[NEG_LANE] &&
                       (credits[NEG_LANE] != D2D_FIFO_DEPTH)) begin
            credits[NEG_LANE] <= credits[NEG_LANE] + 1'b1;
          end
        end
      end

      d2d_async_fifo #(
        .g_data_width(CHDataWidth),
        .g_size(D2D_FIFO_DEPTH)
      ) u_async_fifo_pos (
        .rst_wr_n_i(rstn_fifo_clk),
        .clk_wr_i(clk),
        .we_i(d2d_snd_wrreq[POS_LANE]),
        .d_i(tree_lane_data[POS_LANE]),
        .wr_full_o(d2d_snd_full[POS_LANE]),
        .rst_rd_n_i(rstn_fifo_d2d_pos),
        .clk_rd_i(d2d_clk_in),
        .rd_i(d2d_snd_rdreq[POS_LANE]),
        .q_o(d2d_fifo_q[POS_LANE]),
        .rd_empty_o(d2d_snd_empty[POS_LANE])
      );

      d2d_async_fifo #(
        .g_data_width(CHDataWidth),
        .g_size(D2D_FIFO_DEPTH)
      ) u_async_fifo_neg (
        .rst_wr_n_i(rstn_fifo_clk),
        .clk_wr_i(clk),
        .we_i(d2d_snd_wrreq[NEG_LANE]),
        .d_i(tree_lane_data[NEG_LANE]),
        .wr_full_o(d2d_snd_full[NEG_LANE]),
        .rst_rd_n_i(rstn_fifo_d2d_neg),
        .clk_rd_i(d2d_clk_in),
        .rd_i(d2d_snd_rdreq[NEG_LANE]),
        .q_o(d2d_fifo_q[NEG_LANE]),
        .rd_empty_o(d2d_snd_empty[NEG_LANE])
      );
    end
  endgenerate

  always_comb begin
    d2d_link_ready = 1'b1;
    for (int lane = 0; lane < LaneCount; lane++) begin
      d2d_link_ready &= (state[lane] == state_ready);
    end
  end

  d2d_tx_tree #(
    .T(TILES),
    .CMDataWidth(CHDataWidth),
    .DMADataWidth(DMADataWidth),
    .RATE(2),
    .CLK_RATIO(TXCHANNELS),
    .CHDataWidth(TreeCHDataWidth),
    .d2d_position(d2d_position),
    .chip_coordinates(chip_coordinates)
  ) d2d_tree_i (
    .clk(clk),
    .rst(rst_clk),
    .noc1_data_in(noc1_data_in),
    .noc2_data_in(noc2_data_in),
    .noc3_data_in(noc3_data_in),
    .noc4_data_in(noc4_data_in),
    .noc5_data_in(noc5_data_in),
    .noc6_data_in(noc6_data_in),
    .noc1_data_void_in(noc1_data_void_tree),
    .noc2_data_void_in(noc2_data_void_tree),
    .noc3_data_void_in(noc3_data_void_tree),
    .noc4_data_void_in(noc4_data_void_tree),
    .noc5_data_void_in(noc5_data_void_tree),
    .noc6_data_void_in(noc6_data_void_tree),
    .cmbypass_data_in(cmbypass_data_in),
    .cmbypass_data_void_in(cmbypass_data_void_in),
    .dmabypass_data_in(dmabypass_data_in),
    .dmabypass_data_void_in(dmabypass_data_void_in),
    .noc1_stop_out(noc1_stop_tree),
    .noc2_stop_out(noc2_stop_tree),
    .noc3_stop_out(noc3_stop_tree),
    .noc4_stop_out(noc4_stop_tree),
    .noc5_stop_out(noc5_stop_tree),
    .noc6_stop_out(noc6_stop_tree),
    .cmbypass_stop_out(cmbypass_stop_out),
    .dmabypass_stop_out(dmabypass_stop_out),
    .data_out(tree_data_out),
    .data_void_out(tree_data_void_out),
    .stop_in(tree_stop_in)
  );

endmodule
