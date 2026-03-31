module d2d_rx_wrapper
  #(
    parameter logic [1:0] d2d_position, // 0: N, 1: S, 2: W, 3: E
    parameter logic [2:0] local_chip_y,
    parameter logic [2:0] local_chip_x,
    parameter logic [3:0] max_dim,
    //parameter logic [3:0] x_dim,
    parameter int unsigned RXCHANNELS   = 4,
    parameter int unsigned TILES        = 3,
    parameter bit FlowControl = 1'b0,
    parameter int unsigned CHDataWidth = 66,
    parameter int unsigned COHDataWidth = 66,
    parameter int unsigned MISCDataWidth = 66,
    parameter int unsigned DMADataWidth = 130
  )
  (
   input  logic clk,
   input  logic rst,
   input  logic d2d_rst,

   // D2D Tx --> D2D Rx
   input logic                                d2d_clk_in,
   input logic [RXCHANNELS*CHDataWidth-1:0]   d2d_rcv_data_in,
   input logic [RXCHANNELS-1:0]               d2d_valid_in,
   output logic                               d2d_link_ready,

   // D2D Rx --> D2D Tx
   output logic [RXCHANNELS-1:0]              d2d_credit_out,

   // D2D --> NoC
   output logic [TILES*COHDataWidth-1:0]      noc1_data_out,
   output logic [TILES*COHDataWidth-1:0]      noc2_data_out,
   output logic [TILES*COHDataWidth-1:0]      noc3_data_out,    
   output logic [TILES*DMADataWidth-1:0]      noc4_data_out,    
   output logic [TILES*MISCDataWidth-1:0]     noc5_data_out,    
   output logic [TILES*DMADataWidth-1:0]      noc6_data_out,
   output logic [CHDataWidth-1:0]             bypass_data_out,

   output logic [TILES-1:0]                   noc1_data_void_out,
   output logic [TILES-1:0]                   noc2_data_void_out,
   output logic [TILES-1:0]                   noc3_data_void_out,
   output logic [TILES-1:0]                   noc4_data_void_out,
   output logic [TILES-1:0]                   noc5_data_void_out,
   output logic [TILES-1:0]                   noc6_data_void_out,
   output logic                               bypass_data_void_out,

   // NoC --> D2D
   input  logic [TILES-1:0]                   noc1_stop_in,
   input  logic [TILES-1:0]                   noc2_stop_in,
   input  logic [TILES-1:0]                   noc3_stop_in,  
   input  logic [TILES-1:0]                   noc4_stop_in,  
   input  logic [TILES-1:0]                   noc5_stop_in,  
   input  logic [TILES-1:0]                   noc6_stop_in,
   input  logic                               bypass_stop_in
 );

  logic [CHDataWidth-1:0]   d2d_rcv_data_in_arr [RXCHANNELS-1:0];
  logic [COHDataWidth-1:0]  noc1_data_out_arr [TILES-1:0];
  logic [COHDataWidth-1:0]  noc2_data_out_arr [TILES-1:0];
  logic [COHDataWidth-1:0]  noc3_data_out_arr [TILES-1:0];
  logic [DMADataWidth-1:0]  noc4_data_out_arr [TILES-1:0];
  logic [MISCDataWidth-1:0] noc5_data_out_arr [TILES-1:0];
  logic [DMADataWidth-1:0]  noc6_data_out_arr [TILES-1:0];

  genvar ch;
  generate
    for (ch = 0; ch < RXCHANNELS; ch++) begin
      assign d2d_rcv_data_in_arr[ch] = d2d_rcv_data_in[ch*CHDataWidth +: CHDataWidth];
    end
  endgenerate

  genvar idx;
  generate
    for (idx = 0; idx < TILES; idx++) begin
      assign noc1_data_out[idx*COHDataWidth +: COHDataWidth] = noc1_data_out_arr[idx];
      assign noc2_data_out[idx*COHDataWidth +: COHDataWidth] = noc2_data_out_arr[idx];
      assign noc3_data_out[idx*COHDataWidth +: COHDataWidth] = noc3_data_out_arr[idx];
      assign noc4_data_out[idx*DMADataWidth +: DMADataWidth] = noc4_data_out_arr[idx];
      assign noc5_data_out[idx*MISCDataWidth +: MISCDataWidth] = noc5_data_out_arr[idx];
      assign noc6_data_out[idx*DMADataWidth +: DMADataWidth] = noc6_data_out_arr[idx];
    end
  endgenerate

  localparam noc::chip_xy_t chip_coordinates = '{
    y: local_chip_y, 
    x: local_chip_x
  };
  d2d_rx
  #(
    .d2d_position(d2d_position),
    .chip_coordinates(chip_coordinates),
    .max_dim(max_dim),
    //.x_dim(x_dim),
    .RXCHANNELS(RXCHANNELS),
    .TILES(TILES),
    .FlowControl(FlowControl),
    .CHDataWidth(CHDataWidth),
    .COHDataWidth(COHDataWidth),
    .MISCDataWidth(MISCDataWidth),
    .DMADataWidth(DMADataWidth)
  ) d2d_rx_impl_i
  (
    .clk(clk),
    .rst(rst),
    .d2d_rst(d2d_rst),
    .d2d_clk_in(d2d_clk_in),
    .d2d_rcv_data_in(d2d_rcv_data_in_arr),
    .d2d_valid_in(d2d_valid_in),
    .d2d_link_ready(d2d_link_ready),
    .d2d_credit_out(d2d_credit_out),
    .noc1_data_out(noc1_data_out_arr),
    .noc2_data_out(noc2_data_out_arr),
    .noc3_data_out(noc3_data_out_arr),
    .noc4_data_out(noc4_data_out_arr),
    .noc5_data_out(noc5_data_out_arr),
    .noc6_data_out(noc6_data_out_arr),
    .bypass_data_out(bypass_data_out),
    .noc1_data_void_out(noc1_data_void_out),
    .noc2_data_void_out(noc2_data_void_out),    
    .noc3_data_void_out(noc3_data_void_out),    
    .noc4_data_void_out(noc4_data_void_out),
    .noc5_data_void_out(noc5_data_void_out),
    .noc6_data_void_out(noc6_data_void_out),
    .bypass_data_void_out(bypass_data_void_out),
    .noc1_stop_in(noc1_stop_in),
    .noc2_stop_in(noc2_stop_in),
    .noc3_stop_in(noc3_stop_in),
    .noc4_stop_in(noc4_stop_in),
    .noc5_stop_in(noc5_stop_in),
    .noc6_stop_in(noc6_stop_in),
    .bypass_stop_in(bypass_stop_in)
  );
endmodule
