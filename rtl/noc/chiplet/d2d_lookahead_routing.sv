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
//   input noc::tile_t assigned_tile,
   output noc::routing_lock_t routing_lock,
   output noc::direction_t next_routing
   );

   noc::direction_t chip_routing, local_routing;
   generate
    // Compute next routing: go East/West first, then North/South
    if (d2d_position == 2'b00) begin
      always_comb begin
        chip_routing = '0;
        if (chip.y < destination_chip.y) begin
          chip_routing = 5'b00010;
        end
        if (chip.y == destination_chip.y) begin
          chip_routing = 5'b10000;
        end
      end
    end else if (d2d_position == 2'b01) begin
      always_comb begin
        chip_routing = '0;
        if (chip.y > destination_chip.y) begin
          chip_routing = 5'b00001;
        end
        if (chip.y == destination_chip.y) begin
          chip_routing = 5'b10000;
        end
      end
    end else if (d2d_position == 2'b10) begin
      always_comb begin
        chip_routing = '0;
        if (chip.x < destination_chip.x) begin
          chip_routing = 5'b01000;
        end
        if (chip.x == destination_chip.x) begin
          if (chip.y < destination_chip.y) begin
            chip_routing = 5'b00010;
          end
          if (chip.y > destination_chip.y) begin
            chip_routing = 5'b00001;
          end
          if (chip.y == destination_chip.y) begin
            chip_routing = 5'b10000;
          end
        end
      end
    end else if (d2d_position == 2'b11) begin
      always_comb begin
        chip_routing = '0;
        if (chip.x > destination_chip.x) begin
          chip_routing = 5'b00100;
        end
        if (chip.x == destination_chip.x) begin
          if (chip.y < destination_chip.y) begin
            chip_routing = 5'b00010;
          end
          if (chip.y > destination_chip.y) begin
            chip_routing = 5'b00001;
          end
          if (chip.y == destination_chip.y) begin
            chip_routing = 5'b10000;
          end
        end
      end
    end
  endgenerate
//      if (current_chip_position.x
//    noc::direction_t west, east, north, south;
//    west = current_chip_position.x > destination_chip.x ?
//           // 00100 : 11011
//           noc::goWest : ~noc::goWest;
//    east = current_chip_position.x < destination_chip.x ?
//           // 01000 : 10111
//           noc::goEast : ~noc::goEast;
//    north = current_chip_position.y > destination_chip.y ?
//            // 01101 : 11110
//            noc::goNorth | noc::goWest | noc::goEast : ~noc::goNorth;
//    south = current_chip_position.y < destination_chip.y ?
//            // 01110 : 11101
//            noc::goSouth | noc::goWest | noc::goEast : ~noc::goSouth;
//    // Result is go_local when none of the above is true
//    chip_routing = west & east & north & south;
  generate
    if (d2d_position == 2'b00) begin  // either L/S
      assign local_routing = (destination.y == '0) ? 5'b10000 : 5'b00010;
    end else if (d2d_position == 2'b01) begin // either L/N
      assign local_routing = (destination.y == (max_dim - 1'b1)) ? 5'b10000 : 5'b00001;
    end else if (d2d_position == 2'b10) begin // either L/E
      assign local_routing = (destination.x == '0) ? 5'b10000 : 5'b01000;
    end else if (d2d_position == 2'b11) begin // either L/W
      assign local_routing = (destination.x == (max_dim - 1'b1)) ? 5'b10000 : 5'b00100;
    end
//    // Compute next routing: go East/West first, then North/South
//    noc::direction_t west, east, north, south;
//    west = next_position.x > destination.x ?
//           // 00100 : 11011
//           noc::goWest : ~noc::goWest;
//    east = next_position.x < destination.x ?
//           // 01000 : 10111
//           noc::goEast : ~noc::goEast;
//    north = next_position.y > destination.y ?
//            // 01101 : 11110
//            noc::goNorth | noc::goWest | noc::goEast : ~noc::goNorth;
//    south = next_position.y < destination.y ?
//            // 01110 : 11101
//            noc::goSouth | noc::goWest | noc::goEast : ~noc::goSouth;
//    // Result is go_local when none of the above is true
//    routing = west & east & north & south;
  endgenerate

//  noc::xy_t next_position_d;

//  generate
//    if (d2d_position == 2'b00) begin // D2D is at North
//       assign next_position_d.x = assigned_tile; // assigned tile number
//       assign next_position_d.y = '0; // Northern-most y coordinate
//    end else if (d2d_position == 2'b01) begin // D2D is at South
//       assign next_position_d.x = assigned_tile; // assigned tile number.
//       assign next_position_d.y = max_dim - 1'b1; // Southern-most y-coordinate
//    end else if (d2d_position == 2'b10) begin  // D2D is at West
//       assign next_position_d.x = '0; // Western-most x coordinate
//       assign next_position_d.y = assigned_tile; // assigned tile number
//    end else begin                        // D2D is at East
//       assign next_position_d.x = max_dim - 1'b1; // Eastern-most x-coordinate
//       assign next_position_d.y = assigned_tile; // assigned tile number
//    end
//  endgenerate

  assign next_routing = (chip_routing[4]) ? local_routing : chip_routing;
  assign routing_lock = ~chip_routing[4];

endmodule
