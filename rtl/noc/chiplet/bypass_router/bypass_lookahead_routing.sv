// Compute next YX positional routing for a 2D mesh NoC
//
// This module determines the next routing direction (lookahead) for the current flit.
// First the coordinates of the next hop are determined based on the routing direction
// encoded in the header flit. Next, the routing direction is updated based on the
// coordinates of the destination router.
// Packets are routed first west or east (X axis), then north or south (Y axis).
// The YX positional routing is proven to be deadlock free.
//
// There is no sequential delay from destination/chip parameters to output next_routing.
//
// Interface
//
// * Inputs
// - destination: x,y coordinates of the destination router.
//
// * Outputs
// - next_routing: one-hot encoded routing direction for the next hop.
//

module bypass_lookahead_routing
  #(
    parameter integer PORT_ID = 0,
    parameter noc::chip_xy_t chip = '0
  ) (
   input noc::chip_xy_t chip_destination,
   output noc::direction_t next_routing
   );

  localparam noc::chip_xy_t next_position =
    (PORT_ID == 0) ? noc::chip_xy_t'{y: chip.y - 1'b1, x: chip.x} :
    (PORT_ID == 1) ? noc::chip_xy_t'{y: chip.y + 1'b1, x: chip.x} :
    (PORT_ID == 2) ? noc::chip_xy_t'{y: chip.y, x: chip.x - 1'b1} :
                     noc::chip_xy_t'{y: chip.y, x: chip.x + 1'b1};

  noc::direction_t routing;
  generate
    if (PORT_ID == 0) begin
      always_comb begin
        routing = '0;
        if (next_position.y > chip_destination.y) begin
          routing.go_north = 1'b1;
        end
        if (next_position.y == chip_destination.y) begin
          routing.go_local = 1'b1;
        end
      end
    end else if (PORT_ID == 1) begin
      always_comb begin
        routing = '0;
        if (next_position.y < chip_destination.y) begin
          routing.go_south = 1'b1;
        end
        if (next_position.y == chip_destination.y) begin
          routing.go_local = 1'b1;
        end
      end
    end else if (PORT_ID == 2) begin
      always_comb begin
        routing = '0;
        if (next_position.x > chip_destination.x) begin
          routing.go_west = 1'b1;
        end
        if (next_position.x == chip_destination.x) begin
          if (next_position.y > chip_destination.y) begin
            routing.go_north = 1'b1;
          end
          if (next_position.y < chip_destination.y) begin
            routing.go_south = 1'b1;
          end
          if (next_position.y == chip_destination.y) begin
            routing.go_local = 1'b1;
          end
        end
      end
    end else if (PORT_ID ==3) begin
      always_comb begin
        routing = '0;
        if (next_position.x < chip_destination.x) begin
          routing.go_east = 1'b1;
        end
        if (next_position.x == chip_destination.x) begin
          if (next_position.y > chip_destination.y) begin
            routing.go_north = 1'b1;
          end
          if (next_position.y < chip_destination.y) begin
            routing.go_south = 1'b1;
          end
          if (next_position.y == chip_destination.y) begin
            routing.go_local = 1'b1;
          end
        end
      end
    end
  endgenerate

  assign next_routing = routing;

endmodule
