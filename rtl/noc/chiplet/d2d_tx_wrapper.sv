module d2d_tx_wrapper
  #(
    parameter int unsigned TXCHANNELS   = 4,
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
    input  logic d2d_clk_in,

    // D2D Tx --> D2D Rx
    output logic [TXCHANNELS*CHDataWidth-1:0]   d2d_snd_data_out,
    output logic [TXCHANNELS-1:0]               d2d_valid_out,

    // D2D Rx --> D2D Tx
    input  logic [TXCHANNELS-1:0]               d2d_credit_in,

    // NoC --> D2D
    input  logic [TILES*COHDataWidth-1:0]       noc1_data_in,
    input  logic [TILES*COHDataWidth-1:0]       noc2_data_in,
    input  logic [TILES*COHDataWidth-1:0]       noc3_data_in,
    input  logic [TILES*DMADataWidth-1:0]       noc4_data_in,
    input  logic [TILES*MISCDataWidth-1:0]      noc5_data_in,
    input  logic [TILES*DMADataWidth-1:0]       noc6_data_in,
     
    input  logic [TILES-1:0]                    noc1_data_void_in,
    input  logic [TILES-1:0]                    noc2_data_void_in,
    input  logic [TILES-1:0]                    noc3_data_void_in,
    input  logic [TILES-1:0]                    noc4_data_void_in,
    input  logic [TILES-1:0]                    noc5_data_void_in,
    input  logic [TILES-1:0]                    noc6_data_void_in,

    // D2D --> NoC
    output logic [TILES-1:0]                    noc1_stop_out,
    output logic [TILES-1:0]                    noc2_stop_out,
    output logic [TILES-1:0]                    noc3_stop_out,
    output logic [TILES-1:0]                    noc4_stop_out,
    output logic [TILES-1:0]                    noc5_stop_out,
    output logic [TILES-1:0]                    noc6_stop_out
    );

  logic [CHDataWidth-1:0]   d2d_snd_data_out_arr [TXCHANNELS-1:0];
  logic [COHDataWidth-1:0]  noc1_data_in_arr [TILES-1:0];
  logic [COHDataWidth-1:0]  noc2_data_in_arr [TILES-1:0];
  logic [COHDataWidth-1:0]  noc3_data_in_arr [TILES-1:0];
  logic [DMADataWidth-1:0]  noc4_data_in_arr [TILES-1:0];
  logic [MISCDataWidth-1:0] noc5_data_in_arr [TILES-1:0];
  logic [DMADataWidth-1:0]  noc6_data_in_arr [TILES-1:0];

  genvar ch;
  generate
    for (ch = 0; ch < TXCHANNELS; ch++) begin
      assign d2d_snd_data_out[ch*CHDataWidth +: CHDataWidth] = d2d_snd_data_out_arr[ch];
    end
  endgenerate

  genvar idx;
  generate
    for (idx = 0; idx < TILES; idx++) begin
      assign noc1_data_in_arr[idx] = noc1_data_in[idx*COHDataWidth +: COHDataWidth];
      assign noc2_data_in_arr[idx] = noc2_data_in[idx*COHDataWidth +: COHDataWidth];
      assign noc3_data_in_arr[idx] = noc3_data_in[idx*COHDataWidth +: COHDataWidth];
      assign noc4_data_in_arr[idx] = noc4_data_in[idx*DMADataWidth +: DMADataWidth];
      assign noc5_data_in_arr[idx] = noc5_data_in[idx*MISCDataWidth +: MISCDataWidth];
      assign noc6_data_in_arr[idx] = noc6_data_in[idx*DMADataWidth +: DMADataWidth];
    end
  endgenerate
  
  d2d_tx
  #(
    .TXCHANNELS(TXCHANNELS),
    .TILES(TILES),
    .FlowControl(FlowControl),
    .CHDataWidth(CHDataWidth),
    .COHDataWidth(COHDataWidth),
    .MISCDataWidth(MISCDataWidth),
    .DMADataWidth(DMADataWidth)
  ) d2d_tx_impl_i
  (
    .clk(clk),
    .rst(rst),
    .d2d_clk_in(d2d_clk_in),
    .d2d_snd_data_out(d2d_snd_data_out_arr),
    .d2d_valid_out(d2d_valid_out),
    .d2d_credit_in(d2d_credit_in),
    .noc1_data_in(noc1_data_in_arr),
    .noc2_data_in(noc2_data_in_arr),
    .noc3_data_in(noc3_data_in_arr),   
    .noc4_data_in(noc4_data_in_arr),  
    .noc5_data_in(noc5_data_in_arr), 
    .noc6_data_in(noc6_data_in_arr), 
    .noc1_data_void_in(noc1_data_void_in),
    .noc2_data_void_in(noc2_data_void_in),
    .noc3_data_void_in(noc3_data_void_in),   
    .noc4_data_void_in(noc4_data_void_in),
    .noc5_data_void_in(noc5_data_void_in),
    .noc6_data_void_in(noc6_data_void_in),
    .noc1_stop_out(noc1_stop_out),
    .noc2_stop_out(noc2_stop_out),
    .noc3_stop_out(noc3_stop_out),
    .noc4_stop_out(noc4_stop_out),
    .noc5_stop_out(noc5_stop_out),
    .noc6_stop_out(noc6_stop_out)
  );
endmodule
