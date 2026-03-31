// Compute next YX positional routing for a 3D mesh NoC
//
// This module determines the next routing direction (lookahead) for the current flit.
// First the coordinates of the next hop are determined based on the routing direction
// encoded in the header flit. Next, the routing direction is updated based on the
// coordinates of the destination router.
// Packets are routed first west or east (X axis), then north or south (Y axis).
// The YX positional routing is proven to be deadlock free.
//
// There is no delay from inputs destination and current_routing to output next_routing.
// Conversely, to improve timing, the local position input is sampled, thus there is a one-cycle
// delay from input position to output next_routing. Note, however, that position is supposed to be
// a static input after initialization, because it encodes the position of the router on the mesh.
//
// Interface
//
// * Inputs
// - clk: clock.
// - position: static input that encodes the x,y coordinates of the router on the mesh.
// - destination: x,y coordinates of the destination router.
// - current_routing: one-hot encoded routing direction for the current hop.
//
// * Outputs
// - next_routing: one-hot encoded routing direction for the next hop.
//

module lookahead_routing_multicast #(
  parameter integer DEST_SIZE = 6,
  parameter logic [1:0] PORT_ID = 0
) (
   input logic clk,
   input noc::xy_t position,
   input noc::xy_t [0:DEST_SIZE-1] destination,
   input logic [DEST_SIZE-1:0] val,
   output noc::direction_t next_routing
   );

  noc::direction_t routing_paths [DEST_SIZE-1:0];
  logic [DEST_SIZE-1:0] routing_bit_0, routing_bit_1, routing_bit_2, routing_bit_3, routing_bit_4;
  noc::xy_t next_position;

  generate
    if (PORT_ID == 2'd0) begin : CALC_NEXT_POS_N // North Port
      always_ff @(posedge clk) begin
        next_position.x <= position.x;
        next_position.y <= position.y - 1'b1;
      end
    end else if (PORT_ID == 2'd1) begin : CALC_NEXT_POS_S // South Port
      always_ff @(posedge clk) begin
        next_position.x <= position.x;
        next_position.y <= position.y + 1'b1;
      end
    end else if (PORT_ID == 2'd2) begin : CALC_NEXT_POS_W // West Port
      always_ff @(posedge clk) begin
        next_position.x <= position.x - 1'b1;
        next_position.y <= position.y;
      end
    end else begin : CALC_NEXT_POS_E // East Port
      always_ff @(posedge clk) begin
        next_position.x <= position.x + 1'b1;
        next_position.y <= position.y;
      end
    end
  endgenerate

  generate
    genvar i;
    if (PORT_ID == 2'd0) begin
      for (i = 0; i < DEST_SIZE; i++) begin
        assign routing_bit_0[i] = val[i] && (next_position.y > destination[i].y);
        assign routing_bit_1[i] = 1'b0;
        assign routing_bit_2[i] = 1'b0;
        assign routing_bit_3[i] = 1'b0;
        assign routing_bit_4[i] = val[i] && (next_position.y == destination[i].y);
      end
    end else if (PORT_ID == 2'd1) begin
      for (i = 0; i < DEST_SIZE; i++) begin
        assign routing_bit_0[i] = 1'b0;
        assign routing_bit_1[i] = val[i] && (next_position.y < destination[i].y);
        assign routing_bit_2[i] = 1'b0;
        assign routing_bit_3[i] = 1'b0;
        assign routing_bit_4[i] = val[i] && (next_position.y == destination[i].y);
      end
    end else if (PORT_ID == 2'd2) begin
      for (i = 0; i < DEST_SIZE; i++) begin
        logic match_x, match_y;
        assign match_x = (next_position.x == destination[i].x);
        assign match_y = (next_position.y == destination[i].y);
        assign routing_bit_2[i] = val[i] && (next_position.x > destination[i].x);
        assign routing_bit_0[i] = val[i] && match_x && (next_position.y > destination[i].y);
        assign routing_bit_1[i] = val[i] && match_x && (next_position.y < destination[i].y);
        assign routing_bit_3[i] = 1'b0;
        assign routing_bit_4[i] = val[i] && match_x && match_y;
      end
    end else if (PORT_ID == 2'd3) begin
      for (i = 0; i < DEST_SIZE; i++) begin
        logic match_x, match_y;
        assign match_x = (next_position.x == destination[i].x);
        assign match_y = (next_position.y == destination[i].y);
        assign routing_bit_3[i] = val[i] && (next_position.x < destination[i].x);
        assign routing_bit_0[i] = val[i] && match_x && (next_position.y > destination[i].y);
        assign routing_bit_1[i] = val[i] && match_x && (next_position.y < destination[i].y);
        assign routing_bit_2[i] = 1'b0;
        assign routing_bit_4[i] = val[i] && match_x && match_y;
      end
    end
  endgenerate

  assign next_routing = { |routing_bit_4, |routing_bit_3, |routing_bit_2, |routing_bit_1, |routing_bit_0 };
endmodule

module lookahead_routing_multicast_mask #(
    parameter integer W = 4,
    parameter logic [1:0] PORT_ID = 0
) (
  input logic clk,
  input noc::xy_t position,
  input noc::xy_t destination,
  input noc::xy_t destination_mask,
  output noc::direction_t next_routing
);
//  noc::xy_t next_position;
//  logic [W-1:0] max_x, max_y;
//  logic match_x;
//  //noc::direction_t dir_comb;
//  logic out_north, out_south, out_east, out_west, out_local;
//
//  generate
//    if (PORT_ID == 2'd0) begin : CALC_NEXT_POS_N // North Port
//      always_ff @(posedge clk) begin
//        next_position.x <= position.x;
//        next_position.y <= position.y - 1'b1;
//      end
//    end else if (PORT_ID == 2'd1) begin : CALC_NEXT_POS_S // South Port
//      always_ff @(posedge clk) begin
//        next_position.x <= position.x;
//        next_position.y <= position.y + 1'b1;
//      end
//    end else if (PORT_ID == 2'd2) begin : CALC_NEXT_POS_W // West Port
//      always_ff @(posedge clk) begin
//        next_position.x <= position.x - 1'b1;
//        next_position.y <= position.y;
//      end
//    end else begin : CALC_NEXT_POS_E // East Port
//      always_ff @(posedge clk) begin
//        next_position.x <= position.x + 1'b1;
//        next_position.y <= position.y;
//      end
//    end
//  endgenerate
//
//  localparam bit IS_EAST = (PORT_ID == noc::kEastPort[1:0]);
//  localparam bit IS_WEST = (PORT_ID == noc::kWestPort[1:0]);
//  localparam bit IS_SOUTH = (PORT_ID == noc::kSouthPort[1:0]);
//  localparam bit IS_NORTH = (PORT_ID == noc::kNorthPort[1:0]);
//  
//  localparam bit IS_X_PHASE = IS_EAST || IS_WEST;
//
//  always_comb begin
//    //dir_comb = '0;
//    out_north = '0;
//    out_south = '0;
//    out_west = '0;
//    out_east = '0;
//    out_local = '0;
//
//    max_x = destination.x | destination_mask.x;
//    max_y = destination.y | destination_mask.y;
//    match_x = ((next_position.x ^ destination.x) & ~destination_mask.x ) == '0;
//
//    if (IS_X_PHASE) begin
//      if ((next_position.x > destination.x) && IS_EAST) begin
//        out_west = 1'b1;
//      end
//      if ((next_position.x < max_x) && IS_WEST) begin
//        out_east = 1'b1;
//      end
//    end
//    if (match_x || !IS_X_PHASE) begin
//      if ((next_position.y > destination.y) && IS_SOUTH) begin
//        out_north = 1'b1;
//      end
//      if ((next_position.y < max_y) && IS_NORTH) begin
//        out_south = 1'b1;
//      end
//      if ( ((next_position.y ^ destination.y) & ~destination_mask.y) == '0) begin
//        out_local = 1'b1;
//      end
//    end
//  end
//
//  assign next_routing.go_north = out_north;
//  assign next_routing.go_south = out_south;
//  assign next_routing.go_east  = out_east;
//  assign next_routing.go_west  = out_west;
//  assign next_routing.go_local = out_local;
//
endmodule
