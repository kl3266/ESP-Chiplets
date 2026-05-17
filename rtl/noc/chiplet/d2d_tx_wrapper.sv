module d2d_tx_wrapper
  #(
    parameter int unsigned TXCHANNELS   = 4,
    parameter int unsigned TILES        = 3,
    parameter bit FlowControl = 1'b0,
    parameter int unsigned CHDataWidth = 66,
    parameter int unsigned COHDataWidth = 66,
    parameter int unsigned MISCDataWidth = 66,
    parameter int unsigned DMADataWidth = 130,
    parameter logic [1:0] d2d_position = 2'b00,
    parameter logic [2:0] local_chip_y = 3'b000,
    parameter logic [2:0] local_chip_x = 3'b000
    )
  (
    input  logic clk,
    input  logic rst,
    input  logic d2d_rst,
    input  logic d2d_clk_in,

    // D2D Tx --> D2D Rx
    // Flat DDR half-lane view: lane 2*i is negedge, lane 2*i+1 is posedge.
    output logic [2*TXCHANNELS*CHDataWidth-1:0] d2d_snd_data_out,
    output logic [2*TXCHANNELS-1:0]             d2d_valid_out,
    output logic                                d2d_link_ready,

    // D2D Rx --> D2D Tx
    // Flat DDR half-lane credit return aligned with d2d_snd_data_out.
    input  logic [2*TXCHANNELS-1:0]             d2d_credit_in,

    // NoC --> D2D
    input  logic [TILES*COHDataWidth-1:0]       noc1_data_in,
    input  logic [TILES*COHDataWidth-1:0]       noc2_data_in,
    input  logic [TILES*COHDataWidth-1:0]       noc3_data_in,
    input  logic [TILES*DMADataWidth-1:0]       noc4_data_in,
    input  logic [TILES*MISCDataWidth-1:0]      noc5_data_in,
    input  logic [TILES*DMADataWidth-1:0]       noc6_data_in,
    input  logic [CHDataWidth-1:0]              bypass_data_in,
    input  logic [2*CHDataWidth-1:0]            dmabypass_data_in,
     
    input  logic [TILES-1:0]                    noc1_data_void_in,
    input  logic [TILES-1:0]                    noc2_data_void_in,
    input  logic [TILES-1:0]                    noc3_data_void_in,
    input  logic [TILES-1:0]                    noc4_data_void_in,
    input  logic [TILES-1:0]                    noc5_data_void_in,
    input  logic [TILES-1:0]                    noc6_data_void_in,
    input  logic                                bypass_data_void_in,
    input  logic                                dmabypass_data_void_in,

    // D2D --> NoC
    output logic [TILES-1:0]                    noc1_stop_out,
    output logic [TILES-1:0]                    noc2_stop_out,
    output logic [TILES-1:0]                    noc3_stop_out,
    output logic [TILES-1:0]                    noc4_stop_out,
    output logic [TILES-1:0]                    noc5_stop_out,
    output logic [TILES-1:0]                    noc6_stop_out,
    output logic                                bypass_stop_out,
    output logic                                dmabypass_stop_out
    );

  localparam noc::chip_xy_t chip_coordinates = '{
    y: local_chip_y,
    x: local_chip_x
  };
  logic [2*CHDataWidth-1:0] d2d_snd_data_out_arr [TXCHANNELS-1:0];
  logic [1:0]               d2d_valid_out_arr [TXCHANNELS-1:0];
  logic [1:0]               d2d_credit_in_arr [TXCHANNELS-1:0];
  logic [COHDataWidth-1:0]  noc1_data_in_arr [TILES-1:0];
  logic [COHDataWidth-1:0]  noc2_data_in_arr [TILES-1:0];
  logic [COHDataWidth-1:0]  noc3_data_in_arr [TILES-1:0];
  logic [DMADataWidth-1:0]  noc4_data_in_arr [TILES-1:0];
  logic [MISCDataWidth-1:0] noc5_data_in_arr [TILES-1:0];
  logic [DMADataWidth-1:0]  noc6_data_in_arr [TILES-1:0];
  genvar ch;
  generate
    for (ch = 0; ch < TXCHANNELS; ch++) begin : gen_d2d_lanes
      localparam int unsigned NEG_LANE = 2 * ch;
      localparam int unsigned POS_LANE = NEG_LANE + 1;

      assign d2d_snd_data_out[NEG_LANE*CHDataWidth +: CHDataWidth] =
          d2d_snd_data_out_arr[ch][CHDataWidth-1:0];
      assign d2d_snd_data_out[POS_LANE*CHDataWidth +: CHDataWidth] =
          d2d_snd_data_out_arr[ch][2*CHDataWidth-1 -: CHDataWidth];
      assign d2d_valid_out[NEG_LANE] = d2d_valid_out_arr[ch][0];
      assign d2d_valid_out[POS_LANE] = d2d_valid_out_arr[ch][1];
      assign d2d_credit_in_arr[ch][0] = d2d_credit_in[NEG_LANE];
      assign d2d_credit_in_arr[ch][1] = d2d_credit_in[POS_LANE];
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

  d2d_tx_tree_fpga
  #(
    .TXCHANNELS(TXCHANNELS),
    .TILES(TILES),
    .FlowControl(FlowControl),
    .CHDataWidth(CHDataWidth),
    .COHDataWidth(COHDataWidth),
    .MISCDataWidth(MISCDataWidth),
    .DMADataWidth(DMADataWidth),
    .d2d_position(d2d_position),
    .chip_coordinates(chip_coordinates)
  ) d2d_tx_impl_i
  (
    .clk(clk),
    .rst(rst),
    .d2d_rst(d2d_rst),
    .d2d_clk_in(d2d_clk_in),
    .d2d_snd_data_out(d2d_snd_data_out_arr),
    .d2d_valid_out(d2d_valid_out_arr),
    .d2d_link_ready(d2d_link_ready),
    .d2d_credit_in(d2d_credit_in_arr),
    .noc1_data_in(noc1_data_in_arr),
    .noc2_data_in(noc2_data_in_arr),
    .noc3_data_in(noc3_data_in_arr),   
    .noc4_data_in(noc4_data_in_arr),  
    .noc5_data_in(noc5_data_in_arr), 
    .noc6_data_in(noc6_data_in_arr), 
    .cmbypass_data_in(bypass_data_in),
    .dmabypass_data_in(dmabypass_data_in),
    .noc1_data_void_in(noc1_data_void_in),
    .noc2_data_void_in(noc2_data_void_in),
    .noc3_data_void_in(noc3_data_void_in),   
    .noc4_data_void_in(noc4_data_void_in),
    .noc5_data_void_in(noc5_data_void_in),
    .noc6_data_void_in(noc6_data_void_in),
    .cmbypass_data_void_in(bypass_data_void_in),
    .dmabypass_data_void_in(dmabypass_data_void_in),
    .noc1_stop_out(noc1_stop_out),
    .noc2_stop_out(noc2_stop_out),
    .noc3_stop_out(noc3_stop_out),
    .noc4_stop_out(noc4_stop_out),
    .noc5_stop_out(noc5_stop_out),
    .noc6_stop_out(noc6_stop_out),
    .cmbypass_stop_out(bypass_stop_out),
    .dmabypass_stop_out(dmabypass_stop_out)
  );
endmodule
