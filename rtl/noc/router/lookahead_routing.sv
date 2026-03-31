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

module lookahead_routing
  #(
    parameter integer PORT_ID = 0
  ) (
   input logic clk,
   input noc::xy_t position,
   input noc::xy_t destination,
   input noc::routing_lock_t routing_lock,
   output noc::direction_t next_routing
   );

  localparam logic [4:0] port = 5'b00001 << PORT_ID;
  noc::direction_t routing;
  generate
    if (PORT_ID == 0) begin
      always_comb begin
        routing = '0;
        if (next_position.y > destination.y) begin
          routing = 5'b00001;
        end
        if (next_position.y == destination.y) begin
          routing = 5'b10000;
        end
      end
    end else if (PORT_ID == 1) begin
      always_comb begin
        routing = '0;
        if (next_position.y < destination.y) begin
          routing = 5'b00010;
        end
        if (next_position.y == destination.y) begin
          routing = 5'b10000;
        end
      end
    end else if (PORT_ID == 2) begin
      always_comb begin
        routing = '0;
        if (next_position.x > destination.x) begin
          routing = 5'b00100;
        end
        if (next_position.x == destination.x) begin
          if (next_position.y > destination.y) begin
            routing = 5'b00001;
          end
          if (next_position.y < destination.y) begin
            routing = 5'b00010;
          end
          if (next_position.y == destination.y) begin
            routing = 5'b10000;
          end
        end
      end
    end else if (PORT_ID ==3) begin
      always_comb begin
        routing = '0;
        if (next_position.x < destination.x) begin
          routing = 5'b01000;
        end
        if (next_position.x == destination.x) begin
          if (next_position.y > destination.y) begin
            routing = 5'b00001;
          end
          if (next_position.y < destination.y) begin
            routing = 5'b00010;
          end
          if (next_position.y == destination.y) begin
            routing = 5'b10000;
          end
        end
      end
    end
  endgenerate

  noc::xy_t next_position;

  generate
    if (PORT_ID == 0) begin : CALC_NEXT_POS_N // North Port
      always_ff @(posedge clk) begin
        next_position.x <= position.x;
        next_position.y <= position.y - 1'b1;
      end
    end else if (PORT_ID == 1) begin : CALC_NEXT_POS_S // South Port
      always_ff @(posedge clk) begin
        next_position.x <= position.x;
        next_position.y <= position.y + 1'b1;
      end
    end else if (PORT_ID == 2) begin : CALC_NEXT_POS_W // West Port
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

  assign next_routing = routing_lock ? port : routing;

endmodule
