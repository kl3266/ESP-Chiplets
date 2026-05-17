module d2d_rx_tree_fpga #(
  parameter logic [1:0] d2d_position, // 0: N, 1: S, 2: W, 3: E
  parameter noc::chip_xy_t chip_coordinates,
  parameter logic [3:0] max_dim,
  parameter int unsigned RXCHANNELS = 2,
  parameter int unsigned TILES = 3,
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
  // d2d_rcv_data_in[g_i][2*CHDataWidth-1:CHDataWidth] is the posedge half.
  // d2d_rcv_data_in[g_i][CHDataWidth-1:0] is the negedge half.
  input   logic                       d2d_clk_in,
  input   logic [2*CHDataWidth-1:0]   d2d_rcv_data_in [RXCHANNELS-1:0],
  input   logic [1:0]                 d2d_valid_in [RXCHANNELS-1:0],
  output  logic                       d2d_link_ready,

  // D2D Rx --> D2D Tx
  output  logic [1:0]                 d2d_credit_out [RXCHANNELS-1:0],

  // Bypass Lane
  output  logic [CHDataWidth-1:0]     cmbypass_data_out,
  output  logic                       cmbypass_data_void_out,
  input   logic                       cmbypass_stop_in,
  output  logic [2*CHDataWidth-1:0]   dmabypass_data_out,
  output  logic                       dmabypass_data_void_out,
  input   logic                       dmabypass_stop_in,

  // D2D --> NoC
  output  logic [COHDataWidth-1:0]    noc1_data_out [TILES-1:0],
  output  logic [COHDataWidth-1:0]    noc2_data_out [TILES-1:0],
  output  logic [COHDataWidth-1:0]    noc3_data_out [TILES-1:0],
  output  logic [DMADataWidth-1:0]    noc4_data_out [TILES-1:0],
  output  logic [MISCDataWidth-1:0]   noc5_data_out [TILES-1:0],
  output  logic [DMADataWidth-1:0]    noc6_data_out [TILES-1:0],
  output  logic                       noc1_data_void_out [TILES-1:0],
  output  logic                       noc2_data_void_out [TILES-1:0],
  output  logic                       noc3_data_void_out [TILES-1:0],
  output  logic                       noc4_data_void_out [TILES-1:0],
  output  logic                       noc5_data_void_out [TILES-1:0],
  output  logic                       noc6_data_void_out [TILES-1:0],

  // NoC --> D2D
  input   logic                       noc1_stop_in [TILES-1:0],
  input   logic                       noc2_stop_in [TILES-1:0],
  input   logic                       noc3_stop_in [TILES-1:0],
  input   logic                       noc4_stop_in [TILES-1:0],
  input   logic                       noc5_stop_in [TILES-1:0],
  input   logic                       noc6_stop_in [TILES-1:0]
);

  localparam int unsigned LaneCount = 2 * RXCHANNELS;
  localparam int unsigned TreeCHDataWidth = 2 * CHDataWidth;
  localparam int unsigned D2D_QUEUE_DEPTH = 8;
  localparam int unsigned D2D_FIFO_DEPTH = 4 * D2D_QUEUE_DEPTH;
  localparam int unsigned STARTUP_PULSES = 4;
  localparam int unsigned StartupCountWidth = $clog2(STARTUP_PULSES + 1);

  typedef enum logic [1:0] {
    state_reset,
    state_ack,
    state_train,
    state_ready
  } rx_state_t;

  logic fifo_rst;
  logic rst_clk;
  logic rst_d2d_pos;
  logic rstn_fifo_clk;
  logic rstn_fifo_d2d_pos;
  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic fifo_rst_clk_sync_ff1 = 1'b1;
  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic fifo_rst_clk_sync_ff2 = 1'b1;
  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic fifo_rst_d2d_pos_sync_ff1 = 1'b1;
  (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic fifo_rst_d2d_pos_sync_ff2 = 1'b1;

  logic [CHDataWidth-1:0] d2d_rcv_half_data_out [LaneCount-1:0];
  logic d2d_rcv_wrreq [LaneCount-1:0];
  logic d2d_rcv_empty [LaneCount-1:0];
  logic d2d_rcv_rdreq [LaneCount-1:0];
  logic d2d_ack [LaneCount-1:0];
  logic d2d_pulse [LaneCount-1:0];
  logic [StartupCountWidth-1:0] startup_credit_cnt [LaneCount-1:0];
  rx_state_t rx_state [LaneCount-1:0];

  logic [TreeCHDataWidth-1:0] tree_data_in [RXCHANNELS-1:0];
  logic [1:0] tree_data_void_in [RXCHANNELS-1:0];
  logic [1:0] tree_stop_out [RXCHANNELS-1:0];
  logic [1:0] tree_read_out [RXCHANNELS-1:0];

  initial begin
    if (COHDataWidth != CHDataWidth) begin
      $error("d2d_rx_tree_fpga expects COHDataWidth == CHDataWidth");
    end
    if (MISCDataWidth != CHDataWidth) begin
      $error("d2d_rx_tree_fpga expects MISCDataWidth == CHDataWidth");
    end
    if (RXCHANNELS < 1) begin
      $error("d2d_rx_tree_fpga expects RXCHANNELS >= 1");
    end
    if (FlowControl !== 1'b0 && FlowControl !== 1'b1) begin
      $error("d2d_rx_tree_fpga FlowControl must be 0 or 1");
    end
  end

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

  assign rst_clk = fifo_rst_clk_sync_ff2;
  assign rst_d2d_pos = fifo_rst_d2d_pos_sync_ff2;
  assign rstn_fifo_clk = ~rst_clk;
  assign rstn_fifo_d2d_pos = ~rst_d2d_pos;

  generate
	    for (genvar ch = 0; ch < RXCHANNELS; ch++) begin : gen_d2d_channels
	      localparam int unsigned NEG_LANE = 2 * ch;
	      localparam int unsigned POS_LANE = NEG_LANE + 1;

	      always_ff @(posedge d2d_clk_in) begin
        if (rst_d2d_pos) begin
          rx_state[POS_LANE] <= state_reset;
          startup_credit_cnt[POS_LANE] <= '0;
          d2d_ack[POS_LANE] <= 1'b0;
        end else begin
          d2d_ack[POS_LANE] <= 1'b0;
          unique case (rx_state[POS_LANE])
            state_reset: begin
              startup_credit_cnt[POS_LANE] <= '0;
              if (d2d_valid_in[ch][1]) begin
                rx_state[POS_LANE] <= state_ack;
              end
            end
            state_ack: begin
              if (startup_credit_cnt[POS_LANE] == STARTUP_PULSES-1) begin
                if (!d2d_valid_in[ch][1]) begin
                  startup_credit_cnt[POS_LANE] <= '0;
                  rx_state[POS_LANE] <= state_ready;
                end
              end else begin
                d2d_ack[POS_LANE] <= 1'b1;
                startup_credit_cnt[POS_LANE] <= startup_credit_cnt[POS_LANE] + 1'b1;
              end
            end
            default: begin
              startup_credit_cnt[POS_LANE] <= '0;
              rx_state[POS_LANE] <= state_ready;
            end
          endcase
        end
      end

      always_ff @(posedge d2d_clk_in) begin
        if (rst_d2d_pos) begin
          rx_state[NEG_LANE] <= state_reset;
          startup_credit_cnt[NEG_LANE] <= '0;
          d2d_ack[NEG_LANE] <= 1'b0;
        end else begin
          d2d_ack[NEG_LANE] <= 1'b0;
          unique case (rx_state[NEG_LANE])
            state_reset: begin
              startup_credit_cnt[NEG_LANE] <= '0;
              if (d2d_valid_in[ch][0]) begin
                rx_state[NEG_LANE] <= state_ack;
              end
            end
            state_ack: begin
              if (startup_credit_cnt[NEG_LANE] == STARTUP_PULSES-1) begin
                if (!d2d_valid_in[ch][0]) begin
                  startup_credit_cnt[NEG_LANE] <= '0;
                  rx_state[NEG_LANE] <= state_ready;
                end
              end else begin
                d2d_ack[NEG_LANE] <= 1'b1;
                startup_credit_cnt[NEG_LANE] <= startup_credit_cnt[NEG_LANE] + 1'b1;
              end
            end
            default: begin
              startup_credit_cnt[NEG_LANE] <= '0;
              rx_state[NEG_LANE] <= state_ready;
            end
          endcase
        end
      end

      cdc_gray_pulse #(
        .N($clog2(D2D_FIFO_DEPTH))
      ) pos_credit_cdc_i (
        .src_clk(d2d_clk_in),
        .dst_clk(clk),
        .src_rstn(rstn_fifo_d2d_pos),
        .dst_rstn(rstn_fifo_clk),
        .src_pulse(d2d_ack[POS_LANE]),
        .dst_pulse(d2d_pulse[POS_LANE])
      );

      cdc_gray_pulse #(
        .N($clog2(D2D_FIFO_DEPTH))
      ) neg_credit_cdc_i (
        .src_clk(d2d_clk_in),
        .dst_clk(clk),
        .src_rstn(rstn_fifo_d2d_pos),
        .dst_rstn(rstn_fifo_clk),
        .src_pulse(d2d_ack[NEG_LANE]),
        .dst_pulse(d2d_pulse[NEG_LANE])
      );

      d2d_async_fifo #(
        .g_data_width(CHDataWidth),
        .g_size(D2D_FIFO_DEPTH)
      ) u_async_fifo_pos (
        .rst_wr_n_i(rstn_fifo_d2d_pos),
        .clk_wr_i(d2d_clk_in),
        .we_i(d2d_rcv_wrreq[POS_LANE]),
        .d_i(d2d_rcv_data_in[ch][2*CHDataWidth-1:CHDataWidth]),
        .wr_full_o(),
        .rst_rd_n_i(rstn_fifo_clk),
        .clk_rd_i(clk),
        .rd_i(d2d_rcv_rdreq[POS_LANE]),
        .q_o(d2d_rcv_half_data_out[POS_LANE]),
        .rd_empty_o(d2d_rcv_empty[POS_LANE])
      );

      d2d_async_fifo #(
        .g_data_width(CHDataWidth),
        .g_size(D2D_FIFO_DEPTH)
      ) u_async_fifo_neg (
        .rst_wr_n_i(rstn_fifo_d2d_pos),
        .clk_wr_i(d2d_clk_in),
        .we_i(d2d_rcv_wrreq[NEG_LANE]),
        .d_i(d2d_rcv_data_in[ch][CHDataWidth-1:0]),
        .wr_full_o(),
        .rst_rd_n_i(rstn_fifo_clk),
        .clk_rd_i(clk),
        .rd_i(d2d_rcv_rdreq[NEG_LANE]),
        .q_o(d2d_rcv_half_data_out[NEG_LANE]),
        .rd_empty_o(d2d_rcv_empty[NEG_LANE])
      );

      assign d2d_rcv_wrreq[POS_LANE] = d2d_valid_in[ch][1] && (rx_state[POS_LANE] == state_ready);
      assign d2d_rcv_wrreq[NEG_LANE] = d2d_valid_in[ch][0] && (rx_state[NEG_LANE] == state_ready);

      assign tree_data_in[ch] = {d2d_rcv_half_data_out[POS_LANE], d2d_rcv_half_data_out[NEG_LANE]};
      assign tree_data_void_in[ch] = {d2d_rcv_empty[POS_LANE], d2d_rcv_empty[NEG_LANE]};
      assign d2d_rcv_rdreq[POS_LANE] = tree_read_out[ch][1];
      assign d2d_rcv_rdreq[NEG_LANE] = tree_read_out[ch][0];
      assign d2d_credit_out[ch][1] = d2d_rcv_rdreq[POS_LANE] || d2d_pulse[POS_LANE];
      assign d2d_credit_out[ch][0] = d2d_rcv_rdreq[NEG_LANE] || d2d_pulse[NEG_LANE];
    end
  endgenerate

  always_comb begin
    d2d_link_ready = 1'b1;
    for (int lane = 0; lane < LaneCount; lane++) begin
      d2d_link_ready &= (rx_state[lane] == state_ready);
    end
  end

  d2d_rx_tree #(
    .d2d_position(d2d_position),
    .chip_coordinates(chip_coordinates),
    .max_dim(max_dim),
    .RXCHANNELS(RXCHANNELS),
    .T(TILES),
    .CMDataWidth(CHDataWidth),
    .DMADataWidth(DMADataWidth),
    .CHDataWidth(TreeCHDataWidth)
  ) d2d_rx_tree_i (
    .clk(clk),
    .rst(rst_clk),
    .d2d_rcv_data_in(tree_data_in),
    .d2d_data_void_in(tree_data_void_in),
    .d2d_stop_out(tree_stop_out),
    .d2d_read_out(tree_read_out),
    .noc1_data_out(noc1_data_out),
    .noc2_data_out(noc2_data_out),
    .noc3_data_out(noc3_data_out),
    .noc4_data_out(noc4_data_out),
    .noc5_data_out(noc5_data_out),
    .noc6_data_out(noc6_data_out),
    .noc1_data_void_out(noc1_data_void_out),
    .noc2_data_void_out(noc2_data_void_out),
    .noc3_data_void_out(noc3_data_void_out),
    .noc4_data_void_out(noc4_data_void_out),
    .noc5_data_void_out(noc5_data_void_out),
    .noc6_data_void_out(noc6_data_void_out),
    .noc1_stop_in(noc1_stop_in),
    .noc2_stop_in(noc2_stop_in),
    .noc3_stop_in(noc3_stop_in),
    .noc4_stop_in(noc4_stop_in),
    .noc5_stop_in(noc5_stop_in),
    .noc6_stop_in(noc6_stop_in),
    .cmbypass_data_out(cmbypass_data_out),
    .cmbypass_data_void_out(cmbypass_data_void_out),
    .cmbypass_stop_in(cmbypass_stop_in),
    .dmabypass_data_out(dmabypass_data_out),
    .dmabypass_data_void_out(dmabypass_data_void_out),
    .dmabypass_stop_in(dmabypass_stop_in)
  );

endmodule
