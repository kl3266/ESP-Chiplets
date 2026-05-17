module bypass_lookahead_router_wrapper
  #(
    parameter bit FlowControl = noc::kFlowControlAckNack,
    parameter int unsigned Width = 64,
    parameter bit [3:0] Ports = noc::AllPorts,
    parameter int unsigned DEST_SIZE = 1,
    parameter int unsigned QUEUE_SIZE = 4,
    parameter int unsigned LOCAL_CHIP_X = 0,
    parameter int unsigned LOCAL_CHIP_Y = 0
    )
  (
   input  logic clk,
   input  logic rst,
   // Input ports
   input  logic [Width-1:0] data_n_in,
   input  logic [Width-1:0] data_s_in,
   input  logic [Width-1:0] data_w_in,
   input  logic [Width-1:0] data_e_in,
   input  logic [3:0] data_void_in,
   output logic [3:0] stop_out,
   // Output ports
   output logic [Width-1:0] data_n_out,
   output logic [Width-1:0] data_s_out,
   output logic [Width-1:0] data_w_out,
   output logic [Width-1:0] data_e_out,
   output logic [3:0] data_void_out,
   input  logic [3:0] stop_in
   );

  typedef logic [noc::chip_xWidth-1:0] chip_x_t;
  typedef logic [noc::chip_yWidth-1:0] chip_y_t;

  localparam noc::chip_xy_t chip = '{
    y: chip_y_t'(LOCAL_CHIP_Y),
    x: chip_x_t'(LOCAL_CHIP_X)
  };

  localparam bit UseMaskRouter = (DEST_SIZE > 1) || (Width > 66);

  generate
    if (!UseMaskRouter) begin
      bypass_lookahead_router
        #(
          .FlowControl(FlowControl),
          .DataWidth(Width - $bits(noc::preamble_t)),
          .Ports(Ports),
          .QUEUE_SIZE(QUEUE_SIZE),
          .chip(chip)
          ) bypass_router_impl_i
          (
           .clk,
           .rst(rst),
           .data_n_in,
           .data_s_in,
           .data_w_in,
           .data_e_in,
           .data_void_in,
           .stop_out,
           .data_n_out,
           .data_s_out,
           .data_w_out,
           .data_e_out,
           .data_void_out,
           .stop_in
           );
    end else begin
      bypass_lookahead_router_multicast_mask
        #(
          .FlowControl(FlowControl),
          .DataWidth(Width - $bits(noc::preamble_t)),
          .Ports(Ports),
          .QUEUE_SIZE(QUEUE_SIZE),
          .chip(chip)
         ) bypass_mcast_router_impl_i
          (
           .clk,
           .rst(rst),
           .data_n_in,
           .data_s_in,
           .data_w_in,
           .data_e_in,
           .data_void_in,
           .stop_out,
           .data_n_out,
           .data_s_out,
           .data_w_out,
           .data_e_out,
           .data_void_out,
           .stop_in
           );
    end
  endgenerate

endmodule
