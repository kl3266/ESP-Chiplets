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

module lookahead_routing_multicast_mask #(
  parameter integer W = 4,
  parameter logic [1:0] PORT_ID = 0
) (
  input logic clk,
  input noc::xy_t position,
  input noc::xy_t destination,
  input noc::xy_t destination_mask,
  input noc::mcast_routing_lock_t mcast_routing_lock,
  input noc::mcast_t mcast_type,  // 0 - tree; 1 - brcp
  // input noc::pkt_type_t uni_or_mcast, // 1 - multicast; 0 - unicast
  input noc::routing_lock_t routing_lock, // 1 - disable on-chip routing checks; 0 - enable on-chip routing checks
  output noc::mcast_routing_lock_t next_mcast_routing_lock, // necessary for XY turns
  output noc::direction_t next_routing
);

  typedef logic [W-1:0] coord_t;

  function automatic logic coord_match;
    input coord_t value;
    input coord_t dest;
    input coord_t mask;
    begin
      coord_match = (((value ^ dest) & ~mask) == '0);
    end
  endfunction
  
  generate
    if (PORT_ID == 2'd0) begin
      coord_t next_y;
      coord_t min_y;
      logic match_y;

      always_ff @(posedge clk) begin
        next_y <= position.y - coord_t'(1);
      end

      always_comb begin
        next_routing = '0;
        next_mcast_routing_lock = '0;

        min_y   = destination.y & ~destination_mask.y;
        match_y = coord_match(next_y, destination.y, destination_mask.y);

        next_mcast_routing_lock[0] = mcast_routing_lock[0];

        next_routing.go_north = mcast_routing_lock[0] | (next_y > min_y);
        next_routing.go_local = (~routing_lock) & match_y;
      end
    end
    else if (PORT_ID == 2'd1) begin
      coord_t next_y;
      coord_t max_y;
      logic match_y;

      always_ff @(posedge clk) begin
        next_y <= position.y + coord_t'(1);
      end

      assign max_y = destination.y;

      always_comb begin
        next_routing = '0;
        next_mcast_routing_lock = '0;

        match_y = coord_match(next_y, destination.y, destination_mask.y);

        next_mcast_routing_lock[1] = mcast_routing_lock[1];

        next_routing.go_south = mcast_routing_lock[1] | (next_y < max_y);
        next_routing.go_local = (~routing_lock) & match_y;
      end
    end
    else if (PORT_ID == 2'd2) begin
      coord_t next_x, next_y;
      coord_t min_x;
      coord_t min_y, max_y;
      logic match_x, match_y;

      always_ff @(posedge clk) begin
        next_x <= position.x - coord_t'(1);
        next_y <= position.y;
      end

      assign max_y = destination.y;

      always_comb begin
        next_routing = '0;
        next_mcast_routing_lock = '0;

        min_x = destination.x & ~destination_mask.x;
        min_y = destination.y & ~destination_mask.y;

        match_x = coord_match(next_x, destination.x, destination_mask.x);
        match_y = coord_match(next_y, destination.y, destination_mask.y);

        next_mcast_routing_lock[2] = mcast_routing_lock[2];

        next_routing.go_west = mcast_routing_lock[2] | (next_x > min_x);

        if (match_x) begin
          if (next_y > min_y) begin
            next_routing.go_north = ~(mcast_type | routing_lock);
          end
          if (next_y < max_y) begin
            next_routing.go_south = ~(mcast_type | routing_lock);
          end
          if (match_y) begin
            next_routing.go_local = ~routing_lock;
          end
        end
      end
    end
    else begin
      coord_t next_x, next_y;
      coord_t min_x, max_x;
      coord_t min_y, max_y;
      logic match_x, match_y;

      always_ff @(posedge clk) begin
        next_x <= position.x + coord_t'(1);
        next_y <= position.y;
      end

      assign max_y = destination.y;
      assign max_x = destination.x;

      always_comb begin
        next_routing = '0;
        next_mcast_routing_lock = '0;

        min_x = destination.x & ~destination_mask.x;
        min_y = destination.y & ~destination_mask.y;

        match_x = coord_match(next_x, destination.x, destination_mask.x);
        match_y = coord_match(next_y, destination.y, destination_mask.y);

        next_mcast_routing_lock[3] = mcast_routing_lock[3];

        next_routing.go_east = mcast_routing_lock[3] | (next_x < max_x);

        if (match_x) begin
          if (next_y > min_y) begin
            next_routing.go_north = ~(mcast_type | routing_lock);
          end
          if (next_y < max_y) begin
            next_routing.go_south = ~(mcast_type | routing_lock);
          end
          if (match_y) begin
            next_routing.go_local = ~routing_lock;
          end
        end
      end
    end
  endgenerate
endmodule
