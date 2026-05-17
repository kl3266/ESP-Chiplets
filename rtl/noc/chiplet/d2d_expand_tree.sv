module d2d_expand_tree #(
    parameter int unsigned LeafCount = 8,
    parameter int unsigned DataWidth = 66,
    parameter int unsigned TileIndexWidth = (LeafCount > 1) ? $clog2(LeafCount) : 1,
    parameter bit USE_TARGET_MASK = 1'b0,
    parameter bit RELAY_EVERY_LEVEL = 1'b0,
    parameter bit RELAY_LEVEL0 = 1'b0,
    parameter bit RELAY_INCLUDE_LAST_LEVEL = 1'b0
  )
(
  input  logic clk,
  input  logic rst,
  input  logic [DataWidth-1:0] data_in,
  input  logic data_void_in,
  output logic stop_out,
  input  logic [TileIndexWidth-1:0] target_tile_in,
  input  logic [LeafCount-1:0] target_mask_in,
  output logic [DataWidth-1:0] noc_data_out [LeafCount-1:0],
  output logic noc_data_void_out [LeafCount-1:0],
  input  logic noc_stop_in [LeafCount-1:0]
);

  function automatic int unsigned calc_reduce_levels(
      input int unsigned source_count,
      input int unsigned target_count
  );
    int unsigned count;
    int unsigned levels;
    begin
      count = target_count;
      levels = 0;
      while (count < source_count) begin
        count = count * 4;
        if (count > source_count) begin
          count = source_count;
        end
        levels++;
      end
      return levels;
    end
  endfunction

  function automatic int unsigned group_size(
      input int unsigned current_count,
      input int unsigned next_count,
      input int unsigned node
  );
    int unsigned base_size;
    int unsigned remainder;
    begin
      base_size = current_count / next_count;
      remainder = current_count % next_count;
      return base_size + ((node < remainder) ? 1 : 0);
    end
  endfunction

  function automatic int unsigned group_start(
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

  function automatic int unsigned expand_level_count(
      input int unsigned leaf_count,
      input int unsigned level
  );
    int unsigned count;
    begin
      count = 1;
      for (int l = 0; l < level; l++) begin
        count = count * 4;
        if (count > leaf_count) begin
          count = leaf_count;
        end
      end
      return count;
    end
  endfunction

  function automatic int unsigned node_leaf_start(
      input int unsigned leaf_count,
      input int unsigned expand_levels,
      input int unsigned level,
      input int unsigned node
  );
    int unsigned cur_node;
    begin
      cur_node = node;
      for (int l = level; l < expand_levels; l++) begin
        int unsigned cur_count;
        int unsigned next_count;

        cur_count = expand_level_count(leaf_count, l);
        next_count = expand_level_count(leaf_count, l + 1);
        cur_node = group_start(next_count, cur_count, cur_node);
      end
      return cur_node;
    end
  endfunction

  function automatic int unsigned node_leaf_count(
      input int unsigned leaf_count,
      input int unsigned expand_levels,
      input int unsigned level,
      input int unsigned node
  );
    int unsigned cur_count;
    int unsigned start_idx;
    int unsigned next_start_idx;
    begin
      cur_count = expand_level_count(leaf_count, level);
      start_idx = node_leaf_start(leaf_count, expand_levels, level, node);
      if ((node + 1) < cur_count) begin
        next_start_idx = node_leaf_start(leaf_count, expand_levels, level, node + 1);
      end else begin
        next_start_idx = leaf_count;
      end
      return next_start_idx - start_idx;
    end
  endfunction

  localparam int unsigned LEVELS = calc_reduce_levels(LeafCount, 1);

  logic [DataWidth-1:0] router_data [0:LEVELS][LeafCount-1:0];
  logic router_void [0:LEVELS][LeafCount-1:0];
  logic router_stop [0:LEVELS][LeafCount-1:0];
  logic [DataWidth-1:0] stage_data [0:LEVELS][LeafCount-1:0];
  logic stage_void [0:LEVELS][LeafCount-1:0];
  logic stage_stop [0:LEVELS][LeafCount-1:0];

  generate
    if (LEVELS == 0) begin : gen_passthrough
      logic route_selected;

      assign route_selected = USE_TARGET_MASK ? target_mask_in[0] : (target_tile_in == '0);
      assign noc_data_out[0] = route_selected ? data_in : '0;
      assign noc_data_void_out[0] = route_selected ? data_void_in : 1'b1;
      assign stop_out = route_selected && !data_void_in && noc_stop_in[0];
    end else begin : gen_expand_levels
      assign stage_data[0][0] = data_in;
      assign stage_void[0][0] = data_void_in;
      assign stop_out = stage_stop[0][0];

      for (genvar level = 0; level < LEVELS; level++) begin : gen_levels
        localparam int unsigned CUR_COUNT = expand_level_count(LeafCount, level);
        localparam int unsigned NEXT_COUNT = expand_level_count(LeafCount, level + 1);

        for (genvar node = 0; node < CUR_COUNT; node++) begin : gen_nodes
          localparam int unsigned ARITY = group_size(NEXT_COUNT, CUR_COUNT, node);
          localparam int unsigned START = group_start(NEXT_COUNT, CUR_COUNT, node);
          logic [ARITY-1:0] route_in;
          logic [DataWidth-1:0] node_data_out [ARITY-1:0];
          logic node_void_out [ARITY-1:0];
          logic node_stop_in [ARITY-1:0];

          always_comb begin
            route_in = '0;
            for (int port = 0; port < ARITY; port++) begin
              int child_node;
              int child_start;
              int child_size;

              child_node = START + port;
              child_start = node_leaf_start(LeafCount, LEVELS, level + 1, child_node);
              child_size = node_leaf_count(LeafCount, LEVELS, level + 1, child_node);
              if (USE_TARGET_MASK) begin
                for (int leaf = child_start; leaf < (child_start + child_size); leaf++) begin
                  route_in[port] |= target_mask_in[leaf];
                end
              end else begin
                if ((int'(target_tile_in) >= child_start) &&
                    (int'(target_tile_in) < (child_start + child_size))) begin
                  route_in[port] = 1'b1;
                end
              end
            end
          end

          for (genvar port = 0; port < ARITY; port++) begin : gen_ports
            assign router_data[level+1][START + port] = node_data_out[port];
            assign router_void[level+1][START + port] = node_void_out[port];
            assign node_stop_in[port] = router_stop[level+1][START + port];
          end

          if (ARITY == 1) begin : gen_single_output
            assign node_data_out[0] = route_in[0] ? stage_data[level][node] : '0;
            assign node_void_out[0] = route_in[0] ? stage_void[level][node] : 1'b1;
            assign stage_stop[level][node] = route_in[0] ? node_stop_in[0] : 1'b0;
          end else begin : gen_demux
            d2d_demux #(
              .N(ARITY),
              .DataWidth(DataWidth)
            ) expand_demux_i (
              .clk(clk),
              .rst(rst),
              .data_in(stage_data[level][node]),
              .data_void_in(stage_void[level][node]),
              .stop_out(stage_stop[level][node]),
              .route_in(route_in),
              .noc_data_out(node_data_out),
              .noc_data_void_out(node_void_out),
              .noc_stop_in(node_stop_in)
            );
          end
        end
      end

      for (genvar level = 1; level <= LEVELS; level++) begin : gen_stage_outputs
        localparam int unsigned NODE_COUNT = expand_level_count(LeafCount, level);
        localparam bit LEVEL_PARITY = (((level - 1) % 2) != 0);
        localparam bit INSERT_RELAY =
            RELAY_EVERY_LEVEL ||
            ((RELAY_LEVEL0 ^ LEVEL_PARITY) &&
             (RELAY_INCLUDE_LAST_LEVEL || (level != LEVELS)));

        for (genvar node = 0; node < NODE_COUNT; node++) begin : gen_stage_nodes
          if (INSERT_RELAY) begin : gen_relay
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

      for (genvar tile = 0; tile < LeafCount; tile++) begin : gen_outputs
        assign noc_data_out[tile] = stage_data[LEVELS][tile];
        assign noc_data_void_out[tile] = stage_void[LEVELS][tile];
        assign stage_stop[LEVELS][tile] = noc_stop_in[tile];
      end
    end
  endgenerate

endmodule
