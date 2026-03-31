module d2d_async_fifo #(
  parameter int unsigned g_data_width = 32,
  parameter int unsigned g_size       = 8
) (
  input  logic                    rst_wr_n_i,
  input  logic                    clk_wr_i,
  input  logic                    we_i,
  input  logic [g_data_width-1:0] d_i,
  output logic                    wr_full_o,

  input  logic                    rst_rd_n_i,
  input  logic                    clk_rd_i,
  input  logic                    rd_i,
  output logic [g_data_width-1:0] q_o,
  output logic                    rd_empty_o
);

  logic rst_i;
  logic full_int;
  logic empty_int;
  logic prog_full_int;
  logic data_valid_int;
  logic wr_rst_busy;
  logic rd_rst_busy;

  initial begin
    if (g_size < 2) begin
      $error("d2d_async_fifo: g_size must be >= 2");
    end
    if ((g_size & (g_size - 1)) != 0) begin
      $error("d2d_async_fifo: g_size must be a power of two for Gray-pointer flag generation");
    end
  end

  assign rst_i = ~rst_wr_n_i | ~rst_rd_n_i;

`ifdef SYNTHESIS
// `define D2D_USE_XPM_FIFO
`elsif XILINX_FPGA
// `define D2D_USE_XPM_FIFO
`endif

`ifdef D2D_USE_XPM_FIFO
  xpm_fifo_async #(
    .FIFO_MEMORY_TYPE   ( "auto"         ),
    .FIFO_WRITE_DEPTH   ( g_size         ),
    .RELATED_CLOCKS     ( 0              ),
    .WRITE_DATA_WIDTH   ( g_data_width   ),
    .READ_DATA_WIDTH    ( g_data_width   ),
    .READ_MODE          ( "fwft"         ),
    .FIFO_READ_LATENCY  ( 0              ),
    .FULL_RESET_VALUE   ( 0              ),
    .CDC_SYNC_STAGES    ( 3              ),
    .DOUT_RESET_VALUE   ( "0"            ),
    .ECC_MODE           ( "no_ecc"       ),
    .SIM_ASSERT_CHK     ( 0              ),
    .USE_ADV_FEATURES   ( "1002"         ),
    .WAKEUP_TIME        ( 0              ),
    .WR_DATA_COUNT_WIDTH( 1              ),
    .RD_DATA_COUNT_WIDTH( 1              ),
    .PROG_FULL_THRESH   ( g_size / 2     ),
    .PROG_EMPTY_THRESH  ( 10             )
  ) i_xpm_fifo_async (
    .sleep          ( 1'b0      ),
    .rst            ( rst_i     ),
    .wr_clk         ( clk_wr_i  ),
    .wr_en          ( we_i      ),
    .din            ( d_i       ),
    .full           ( full_int  ),
    .prog_full      ( prog_full_int ),
    .wr_data_count  (           ),
    .overflow       (           ),
    .wr_rst_busy    ( wr_rst_busy ),
    .almost_full    (           ),
    .wr_ack         (           ),
    .rd_clk         ( clk_rd_i  ),
    .rd_en          ( rd_i      ),
    .dout           ( q_o       ),
    .empty          ( empty_int ),
    .prog_empty     (           ),
    .rd_data_count  (           ),
    .underflow      (           ),
    .rd_rst_busy    ( rd_rst_busy ),
    .almost_empty   (           ),
    .data_valid     ( data_valid_int ),
    .injectsbiterr  ( 1'b0      ),
    .injectdbiterr  ( 1'b0      ),
    .sbiterr        (           ),
    .dbiterr        (           )
  );

  assign wr_full_o  = prog_full_int | full_int | wr_rst_busy;
  assign rd_empty_o = ~data_valid_int | rd_rst_busy;
`else
  inferred_async_fifo #(
    .g_data_width ( g_data_width ),
    .g_size       ( g_size       )
  ) i_sim_fifo (
    .rst_wr_n_i ( rst_wr_n_i ),
    .clk_wr_i   ( clk_wr_i   ),
    .we_i       ( we_i       ),
    .d_i        ( d_i        ),
    .wr_full_o  ( wr_full_o  ),
    .rst_rd_n_i ( rst_rd_n_i ),
    .clk_rd_i   ( clk_rd_i   ),
    .rd_i       ( rd_i       ),
    .q_o        ( q_o        ),
    .rd_empty_o ( rd_empty_o )
  );
`endif
`undef D2D_USE_XPM_FIFO

endmodule
