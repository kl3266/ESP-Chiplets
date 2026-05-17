// Compute next YX positional routing for a 3D mesh NoC
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

module bypass_lookahead_routing_multicast_mask #(
  parameter integer W = 3,
  parameter logic [1:0] PORT_ID = 0,
  parameter noc::chip_xy_t chip = '0
) (
  input noc::chip_xy_t chip_destination,
  input noc::chip_xy_t chip_destination_mask,
  input noc::pkt_type_t uni_or_mcast, // 0 unicast; 1 mcast. Use this for 64b unicast bc need to use chip_destination_mask for reserved
  output noc::mcast_t next_mcast_type,
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
		localparam coord_t next_y = coord_t'(chip.y) - coord_t'(1);
		coord_t min_y;
		coord_t mask_y;
		logic match_y;

	    assign mask_y = uni_or_mcast ? chip_destination_mask.y : '0; // mcast : unicast

	    always_comb begin
	      	next_routing = '0;

			min_y   = chip_destination.y & ~mask_y;
			match_y = coord_match(next_y, chip_destination.y, mask_y);

			next_routing.go_north = next_y > min_y;
			next_routing.go_local = match_y;
			next_mcast_type = 1'b0;
		end
	end
	else if (PORT_ID == 2'd1) begin
		localparam coord_t next_y = coord_t'(chip.y) + coord_t'(1);
		coord_t mask_y;
		logic match_y;

		assign mask_y = uni_or_mcast ? chip_destination_mask.y : '0; // mcast : unicast

		always_comb begin
			next_routing = '0;

			match_y = coord_match(next_y, chip_destination.y, mask_y);

			next_routing.go_south = next_y < chip_destination.y;
			next_routing.go_local = match_y;
			next_mcast_type = 1'b0;
		end
	end
	else if (PORT_ID == 2'd2) begin
		localparam coord_t next_x = coord_t'(chip.x) - coord_t'(1);
		localparam coord_t next_y = coord_t'(chip.y);
		coord_t min_x;
		coord_t min_y;
		coord_t mask_y, mask_x;
		logic match_x, match_y;

		assign mask_y = uni_or_mcast ? chip_destination_mask.y : '0; // mcast : unicast
		assign mask_x = uni_or_mcast ? chip_destination_mask.x : '0; // mcast : unicast

      	always_comb begin
			next_routing = '0;

			min_x = chip_destination.x & ~mask_x;
			min_y = chip_destination.y & ~mask_y;

			match_x = coord_match(next_x, chip_destination.x, mask_x);
			match_y = coord_match(next_y, chip_destination.y, mask_y);

			next_routing.go_west = next_x > min_x;

	        if (match_x) begin
	          	if (next_y > min_y) begin
	            	next_routing.go_north = 1'b1;
	          	end
	          	if (next_y < chip_destination.y) begin
	            	next_routing.go_south = 1'b1;
	          	end
          		if (match_y) begin
            		next_routing.go_local = 1'b1;
          		end
        	end
	        next_mcast_type = 1'b0;
		end
	end
    else begin
		localparam coord_t next_x = coord_t'(chip.x) + coord_t'(1);
		localparam coord_t next_y = coord_t'(chip.y);
		coord_t min_y;
		coord_t mask_y, mask_x;
		logic match_x, match_y;

		assign mask_y = uni_or_mcast ? chip_destination_mask.y : '0; // mcast : unicast
		assign mask_x = uni_or_mcast ? chip_destination_mask.x : '0; // mcast : unicast

		always_comb begin
			next_routing = '0;

			min_y = chip_destination.y & ~mask_y;

			match_x = coord_match(next_x, chip_destination.x, mask_x);
			match_y = coord_match(next_y, chip_destination.y, mask_y);

			next_routing.go_east = next_x < chip_destination.x;

			if (match_x) begin
				if (next_y > min_y) begin
					next_routing.go_north = 1'b1;
				end
				if (next_y < chip_destination.y) begin
					next_routing.go_south = 1'b1;
				end
				if (match_y) begin
					next_routing.go_local = 1'b1;
				end
			end
			next_mcast_type = 1'b0;
		end
	end
	endgenerate
endmodule
