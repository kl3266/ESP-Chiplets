module d2d_quaternary_reduce_tree #(
    parameter int unsigned N = 4,
    parameter int unsigned DataWidth = 66,
    parameter bit P_DMA = 1'b0
  )
(
  input  logic clk,
  input  logic rst,
  input  logic [DataWidth-1:0] noc_data_in [N-1:0],
  input  logic noc_data_void_in [N-1:0],
  output logic noc_stop_out [N-1:0],
  output logic [DataWidth-1:0] data_out,
  output logic data_void_out,
  input  logic stop_in
);

  function automatic int unsigned next_level_count( // how many nodes in the next level of the tree given the current level?
      input int unsigned current_count
  );
    begin
      if (current_count <= 1) begin
        return current_count;
      end
      return (current_count + 3) / 4; // ceil(current_count / 4)
    end
  endfunction

  function automatic int unsigned level_count(  // how many nodes at a given level of the tree?
      input int unsigned source_count,
      input int unsigned level
  );
    int unsigned count;
    begin
      count = source_count;
      for (int l = 0; l < level; l++) begin
        count = next_level_count(count);  // recursively calculate the number of nodes at the given level
      end
      return count;
    end
  endfunction

  function automatic int unsigned calc_reduce_levels( // how many levels of the tree are needed to reduce the given number of sources down to 1?
      input int unsigned source_count
  );
    int unsigned count;
    int unsigned levels;
    begin
      count = source_count;
      levels = 0;
      while (count > 1) begin
        count = next_level_count(count);
        levels++;
      end
      return levels;
    end
  endfunction

  function automatic int unsigned group_size( // how many nodes from the current level are grouped together to feed into a single node at the next level?
      input int unsigned current_count,
      input int unsigned next_count,
      input int unsigned node
  );
    int unsigned base_size;
    int unsigned remainder;
    begin
      base_size = current_count / next_count; // distribute the nodes as evenly as possible across the next level, giving the first 'remainder' nodes an extra input if the division isn't even
      remainder = current_count % next_count; // the first 'remainder' nodes get an extra input
      return base_size + ((node < remainder) ? 1 : 0);  // if node < remainder, it gets one of the 'extra' nodes, otherwise it just gets the base size
    end
  endfunction

  function automatic int unsigned group_start(  // which node at the current level is the first one that feeds into the given node at the next level?
      input int unsigned current_count,
      input int unsigned next_count,
      input int unsigned node
  );
    int unsigned base_size;
    int unsigned remainder;
    begin
      base_size = current_count / next_count;
      remainder = current_count % next_count;
      return (node * base_size) + ((node < remainder) ? node : remainder);
    end
  endfunction

  localparam int unsigned LEVELS = calc_reduce_levels(N);

  logic [DataWidth-1:0] router_data [0:LEVELS][N-1:0];
  logic router_void [0:LEVELS][N-1:0];
  logic router_stop [0:LEVELS][N-1:0];
  logic [DataWidth-1:0] stage_data [0:LEVELS][N-1:0];
  logic stage_void [0:LEVELS][N-1:0];
  logic stage_stop [0:LEVELS][N-1:0];

  generate
    for (genvar in_idx = 0; in_idx < N; in_idx++) begin : gen_inputs
      assign stage_data[0][in_idx] = noc_data_in[in_idx];
      assign stage_void[0][in_idx] = noc_data_void_in[in_idx];
      assign noc_stop_out[in_idx] = stage_stop[0][in_idx];
    end

    if (LEVELS == 0) begin : gen_passthrough
      assign data_out = stage_data[0][0];
      assign data_void_out = stage_void[0][0];
      assign stage_stop[0][0] = stop_in;
    end else begin : gen_reduce_levels
      for (genvar level = 1; level <= LEVELS; level++) begin : gen_levels
        localparam int unsigned CUR_COUNT = level_count(N, level - 1);
        localparam int unsigned NEXT_COUNT = level_count(N, level);

        for (genvar node = 0; node < NEXT_COUNT; node++) begin : gen_nodes
          localparam int unsigned ARITY = group_size(CUR_COUNT, NEXT_COUNT, node);
          localparam int unsigned START = group_start(CUR_COUNT, NEXT_COUNT, node);

          if (ARITY == 1) begin : gen_passthrough
            assign router_data[level][node] = stage_data[level-1][START];
            assign router_void[level][node] = stage_void[level-1][START];
            assign stage_stop[level-1][START] = router_stop[level][node];
          end else begin : gen_mux
            logic [DataWidth-1:0] merge_data_in [ARITY-1:0];
            logic merge_data_void_in [ARITY-1:0];
            logic merge_stop_out [ARITY-1:0];

            for (genvar port = 0; port < ARITY; port++) begin : gen_ports
              assign merge_data_in[port] = stage_data[level-1][START + port];
              assign merge_data_void_in[port] = stage_void[level-1][START + port];
              assign stage_stop[level-1][START + port] = merge_stop_out[port];
            end

            d2d_mux #(
              .N(ARITY),
              .DataWidth(DataWidth),
              .P_DMA(P_DMA),
              .FIRST_STAGE(1'b0)
            ) merge_router_i (
              .clk(clk),
              .rst(rst),
              .noc_data_in(merge_data_in),
              .noc_data_void_in(merge_data_void_in),
              .noc_stop_out(merge_stop_out),
              .data_out(router_data[level][node]),
              .data_void_out(router_void[level][node]),
              .stop_in(router_stop[level][node])
            );
          end

          if (ARITY > 1) begin : gen_relay
            relay_station #(
              .width(DataWidth)
            ) relay_station_i (
              .clk(clk),
              .rst(rst),
              .data_in(router_data[level][node]),
              .data_void_in(router_void[level][node]),
              .stop_in(stage_stop[level][node]),
              .data_out(stage_data[level][node]),
              .data_void_out(stage_void[level][node]),
              .stop_out(router_stop[level][node])
            );
          end else begin : gen_direct
            assign stage_data[level][node] = router_data[level][node];
            assign stage_void[level][node] = router_void[level][node];
            assign router_stop[level][node] = stage_stop[level][node];
          end
        end
      end

      assign data_out = stage_data[LEVELS][0];
      assign data_void_out = stage_void[LEVELS][0];
      assign stage_stop[LEVELS][0] = stop_in;
    end
  endgenerate

  initial begin
    if ((N < 1) || (N > 16)) begin
      $error("d2d_quaternary_reduce_tree expects 1 <= N <= 16");
    end
  end

endmodule
