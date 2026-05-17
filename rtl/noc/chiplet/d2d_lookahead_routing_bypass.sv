module d2d_lookahead_routing_bypass #(
  parameter logic [3:0] max_dim,
  parameter noc::chip_xy_t chip,
  parameter logic [1:0] d2d_position //0:N, 1:S, 2:W, 3:E
) (
   input logic clk,
   input noc::chip_xy_t destination_chip,
   input noc::xy_t destination,
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
  endgenerate

  assign next_routing = (chip_routing[4]) ? local_routing : chip_routing;
  assign routing_lock = ~chip_routing[4];

endmodule
