// Compute next YX positional routing for a 2D mesh NoC
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

// Comppute next routing after going through the D2D interface

module d2d_lookahead_routing #(
  parameter logic [3:0] max_dim,
//  parameter int unsigned TILES,
  parameter noc::chip_xy_t chip,
  parameter logic [1:0] d2d_position //0:N, 1:S, 2:W, 3:E
) (
   input logic clk,
   input noc::chip_xy_t destination_chip,
   input noc::xy_t destination,
   input noc::tile_t assigned_tile,
   output noc::routing_lock_t routing_lock,
   output noc::direction_t next_routing
   );

  function automatic noc::direction_t chip_routing(
    input noc::chip_xy_t current_chip_position,
    input noc::chip_xy_t destination_chip);
    // Compute next routing: go East/West first, then North/South
    noc::direction_t west, east, north, south;
    west = current_chip_position.x > destination_chip.x ?
           // 00100 : 11011
           noc::goWest : ~noc::goWest;
    east = current_chip_position.x < destination_chip.x ?
           // 01000 : 10111
           noc::goEast : ~noc::goEast;
    north = current_chip_position.y > destination_chip.y ?
            // 01101 : 11110
            noc::goNorth | noc::goWest | noc::goEast : ~noc::goNorth;
    south = current_chip_position.y < destination_chip.y ?
            // 01110 : 11101
            noc::goSouth | noc::goWest | noc::goEast : ~noc::goSouth;
    // Result is go_local when none of the above is true
    chip_routing = west & east & north & south;
  endfunction

  function automatic noc::direction_t routing(
    input noc::xy_t next_position,
    input noc::xy_t destination);
    // Compute next routing: go East/West first, then North/South
    noc::direction_t west, east, north, south;
    west = next_position.x > destination.x ?
           // 00100 : 11011
           noc::goWest : ~noc::goWest;
    east = next_position.x < destination.x ?
           // 01000 : 10111
           noc::goEast : ~noc::goEast;
    north = next_position.y > destination.y ?
            // 01101 : 11110
            noc::goNorth | noc::goWest | noc::goEast : ~noc::goNorth;
    south = next_position.y < destination.y ?
            // 01110 : 11101
            noc::goSouth | noc::goWest | noc::goEast : ~noc::goSouth;
    // Result is go_local when none of the above is true
    routing = west & east & north & south;
  endfunction

  noc::xy_t next_position_d;

  generate
//    if (d2d_position == 2'b00) begin // D2D is at South
//       assign next_position_d.x = assigned_tile; // assigned tile number
//       assign next_position_d.y = y_dim - 1'b1; // Southern-most y coordinate
//    end else if (d2d_position == 2'b01) begin // D2D is at North
//       assign next_position_d.x = assigned_tile; // assigned tile number.
//       assign next_position_d.y = '0;
//    end else if (d2d_position == 2'b10) begin  // D2D is at West
//       assign next_position_d.x = '0;
//       assign next_position_d.y = assigned_tile; // assigned tile number
//    end else begin                        // D2D is at East
//       assign next_position_d.x = x_dim - 1'b1; // Eastern-most x-coordinate
//       assign next_position_d.y = assigned_tile; // assigned tile number
//    end
    if (d2d_position == 2'b00) begin // D2D is at North
       assign next_position_d.x = assigned_tile; // assigned tile number
       assign next_position_d.y = '0; // Northern-most y coordinate
    end else if (d2d_position == 2'b01) begin // D2D is at South
       assign next_position_d.x = assigned_tile; // assigned tile number.
       assign next_position_d.y = max_dim - 1'b1; // Southern-most y-coordinate
    end else if (d2d_position == 2'b10) begin  // D2D is at West
       assign next_position_d.x = '0; // Western-most x coordinate
       assign next_position_d.y = assigned_tile; // assigned tile number
    end else begin                        // D2D is at East
       assign next_position_d.x = max_dim - 1'b1; // Eastern-most x-coordinate
       assign next_position_d.y = assigned_tile; // assigned tile number
    end

    endgenerate

  noc::direction_t next_routing_chip_temp, next_routing_temp;

  assign next_routing_chip_temp = chip_routing(chip, destination_chip);
  assign next_routing_temp = routing(next_position_d, destination);
  assign next_routing = (next_routing_chip_temp[4]) ? next_routing_temp : next_routing_chip_temp;
  assign routing_lock = ~next_routing_chip_temp[4];

endmodule
