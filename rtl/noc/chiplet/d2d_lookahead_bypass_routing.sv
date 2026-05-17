module d2d_lookahead_bypass_routing #(
  parameter noc::chip_xy_t chip,
  parameter logic [1:0] d2d_position //0:N, 1:S, 2:W, 3:E
) (
   input noc::chip_xy_t destination_chip,
   input noc::chip_xy_t destination_chip_mask,
   input noc::pkt_type_t uni_or_mcast,
   output noc::routing_lock_t routing_lock,
   output noc::direction_t next_routing,
   output noc::mcast_t next_mcast_type
   );

  logic [noc::chip_xWidth-1:0] chip_mask_x, chip_min_x;
  logic [noc::chip_yWidth-1:0] chip_mask_y, chip_min_y;
  logic chip_match_x, chip_match_y;

  assign chip_mask_x = uni_or_mcast ? destination_chip_mask.x : '0;
  assign chip_mask_y = uni_or_mcast ? destination_chip_mask.y : '0;
  assign chip_min_x = destination_chip.x & ~chip_mask_x;
  assign chip_min_y = destination_chip.y & ~chip_mask_y;
  assign chip_match_x = (((chip.x ^ destination_chip.x) & ~chip_mask_x) == '0);
  assign chip_match_y = (((chip.y ^ destination_chip.y) & ~chip_mask_y) == '0);

  generate
  // Compute next routing: go East/West first, then North/South
  if (d2d_position == 2'b00) begin  // we have bypass_lookahead_routing to compute everything for us so only basic routing is needed
    always_comb begin
      next_routing = '0;
      next_routing.go_south = chip.y < destination_chip.y;
    end
  end else if (d2d_position == 2'b01) begin
    always_comb begin
      next_routing = '0;
      next_routing.go_north = chip.y > chip_min_y;
    end
  end else if (d2d_position == 2'b10) begin
    always_comb begin // 3 possible directions: E, N, S
      next_routing = '0;
      if (chip.x < destination_chip.x) begin  // dest_chip_x = max_x
        next_routing[3] = 1'b1;
      end
      if (chip_match_x) begin
        if (chip.y < destination_chip.y) begin  // dest_chip_y = max_y
          next_routing[1] = 1'b1;
        end
        if (chip.y > chip_min_y) begin
          next_routing[0] = 1'b1;
        end
      end
    end
  end else if (d2d_position == 2'b11) begin
    always_comb begin
      next_routing = '0;
      if (chip.x > chip_min_x) begin
        next_routing[2] = 1'b1;
      end
      if (chip_match_x) begin
        if (chip.y < destination_chip.y) begin  // dest_chip_y = max_y
          next_routing[1] = 1'b1;
        end
        if (chip.y > chip_min_y) begin
          next_routing[0] = 1'b1;
        end
      end
    end
  end
  endgenerate
  assign routing_lock = ~(chip_match_x && chip_match_y);
  assign next_mcast_type = 1'b0;
endmodule
