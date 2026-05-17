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

module d2d_lookahead_local_routing #(
  parameter logic [3:0] max_dim,
  parameter logic [1:0] d2d_position //0:N, 1:S, 2:W, 3:E
) (
    input noc::xy_t destination,
    input noc::xy_t destination_mask,
    input noc::pkt_type_t uni_or_mcast,
    output noc::routing_lock_t routing_lock,
    output noc::direction_t next_routing,
    output noc::mcast_t next_mcast_type
  );

  logic match_destination;

  generate
    if (d2d_position == 2'b00) begin  // either L/S
      logic [noc::yWidth-1:0] mask_y, edge_y;
      assign mask_y = uni_or_mcast ? destination_mask.y : '0;
      assign edge_y = '0;
      assign match_destination = (((edge_y ^ destination.y) & ~mask_y) == '0);
      always_comb begin
        next_routing = '0;
        next_routing.go_local = match_destination;
        next_routing.go_south = edge_y < destination.y;  // dest.y is set to max_y
      end
    end else if (d2d_position == 2'b01) begin // either L/N
      logic [noc::yWidth-1:0] mask_y, min_y, edge_y;
      assign mask_y = uni_or_mcast ? destination_mask.y : '0;
      assign min_y = destination.y & ~mask_y;
      assign edge_y = noc::yWidth'(max_dim - 1'b1);
      assign match_destination = (((edge_y ^ destination.y) & ~mask_y) == '0);
      always_comb begin
        next_routing = '0;
        next_routing.go_local = match_destination;
        next_routing.go_north = edge_y > min_y;
      end
    end else if (d2d_position == 2'b10) begin // either L/E
      logic [noc::xWidth-1:0] mask_x,edge_x;
      assign mask_x = uni_or_mcast ? destination_mask.x : '0;
      assign edge_x = '0;
      assign match_destination = (((edge_x ^ destination.x) & ~mask_x) == '0);
      always_comb begin
        next_routing = '0;
        next_routing.go_local = match_destination;
        next_routing.go_east = edge_x < destination.x;  // dest.x is set to max_x
      end
    end else if (d2d_position == 2'b11) begin // either L/W
      logic [noc::xWidth-1:0] mask_x, min_x, edge_x;
      assign mask_x = uni_or_mcast ? destination_mask.x : '0;
      assign min_x = destination.x & ~mask_x;
      assign edge_x = noc::xWidth'(max_dim - 1'b1);
      assign match_destination = (((edge_x ^ destination.x) & ~mask_x) == '0);
      always_comb begin
        next_routing = '0;
        next_routing.go_local = match_destination;
        next_routing.go_west = edge_x > min_x;
      end
    end
  endgenerate
  assign routing_lock = 1'b0;
  // D2D local delivery converts chip multicast into on-chip BRCP.
  assign next_mcast_type = uni_or_mcast;
endmodule
