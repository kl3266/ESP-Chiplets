`timescale 1ns/1ps

module d2d_arbiter_30 #(
    parameter int CHANNELS = 96 // Must be multiple of 6 (e.g. 30, 36, 96)
)(
    input  logic                    clk,
    input  logic                    rst,
    input  logic                    enable,
    input  logic [CHANNELS-1:0]     request,
    input  logic                    grant_valid_other_arbiter,
    output logic [$clog2(CHANNELS)-1:0] grant_index,
    output logic                    grant_valid
);

    localparam int W = $clog2(CHANNELS);

    // -------------------------------------------------------------------------
    // 1. TILE PARAMETERS (Fixed at 6)
    // -------------------------------------------------------------------------
    localparam int SIGNALS_PER_TILE = 6;
    localparam int NUM_TILES        = CHANNELS / SIGNALS_PER_TILE;
    localparam int W_TILE           = (NUM_TILES > 1) ? $clog2(NUM_TILES) : 1;
    localparam int W_LOCAL          = 3; // $clog2(6) is 3 bits

    // -------------------------------------------------------------------------
    // 2. GLOBAL MASKING (Arithmetic Carry-Chain)
    // -------------------------------------------------------------------------
    // Even with tile grouping, a global mask is the most efficient way to
    // handle the specific Round-Robin pointer logic.
    logic [CHANNELS-1:0] ptr_oh, mask, req_gated, masked_req;
    logic [W-1:0]        ptr;

    assign req_gated  = enable ? request : '0;
    assign ptr_oh     = CHANNELS'(1'b1) << ptr;
    assign mask       = ~(ptr_oh - 1'b1);
    assign masked_req = req_gated & mask;

    // -------------------------------------------------------------------------
    // 3. TILE-ALIGNED HIERARCHICAL ENCODER
    // -------------------------------------------------------------------------
    logic [W-1:0] idx_masked, idx_raw;
    logic         valid_masked, valid_raw;

    function automatic void tile_arbiter(
        input  logic [CHANNELS-1:0] req_in,
        output logic                v_out,
        output logic [W-1:0]        idx_out
    );
        logic [NUM_TILES-1:0]              tile_valid;
        logic [NUM_TILES-1:0][W_LOCAL-1:0] tile_local_idx;
        logic [W_TILE-1:0]                 winning_tile_id;
        logic [W-1:0] base_addr;

        // STAGE 1: INTRA-TILE ARBITRATION
        // Each iteration handles exactly one SoC Tile (6 signals).
        // This keeps routing local to the tile logic.
        for (int t = 0; t < NUM_TILES; t++) begin
            tile_valid[t]     = 1'b0;
            tile_local_idx[t] = '0;
            
            // Check the 6 signals in this tile.
            // Fits into 1 LUT6 or small ASIC cluster.
            for (int s = 0; s < SIGNALS_PER_TILE; s++) begin
                if (req_in[t*6 + s]) begin
                    tile_valid[t]     = 1'b1;
                    tile_local_idx[t] = s[W_LOCAL-1:0];
                    break; 
                end
            end
        end

        // STAGE 2: INTER-TILE ARBITRATION (Root)
        v_out           = 1'b0;
        winning_tile_id = '0;
        
        for (int k = 0; k < NUM_TILES; k++) begin
            if (tile_valid[k]) begin
                v_out           = 1'b1;
                winning_tile_id = k[W_TILE-1:0];
                break;
            end
        end

        // STAGE 3: INDEX RECONSTRUCTION (Optimization)
        // Instead of "winning_tile_id * 6", we assume the synthesis tool
        // creates a small ROM/Mux for the Base Address.
        // Index = Base_Addr_of_Tile + Local_Index
        
        // Note: We use an intermediate variable to help synthesis optimization
        base_addr = winning_tile_id * 6; 
        
        idx_out = base_addr + tile_local_idx[winning_tile_id];

    endfunction

    // Instantiate Logic
    always_comb begin
      tile_arbiter(masked_req, valid_masked, idx_masked);
      tile_arbiter(req_gated,  valid_raw,    idx_raw);
    end

    // -------------------------------------------------------------------------
    // 4. OUTPUT & POINTER UPDATE
    // -------------------------------------------------------------------------
    assign grant_valid = valid_masked | valid_raw;
    assign grant_index = valid_masked ? idx_masked : idx_raw;

    always_ff @(posedge clk) begin
        if (rst) begin
            ptr <= '0;
        end else if (grant_valid && grant_valid_other_arbiter) begin
            if (grant_index == CHANNELS - 1)
                ptr <= '0;
            else
                ptr <= grant_index + 1'b1;
        end
    end

endmodule
