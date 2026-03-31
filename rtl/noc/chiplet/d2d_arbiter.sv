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

module d2d_arbiter_24 #(
    parameter int CHANNELS = 24 // 9 < N <= 24
)(
    input  logic                                   clk,
    input  logic                                   rst,
    input  logic                                   enable,
    input  logic [CHANNELS-1:0]                    request,
    input  logic                                   grant_valid_other_arbiter,
    output logic [$clog2(CHANNELS)-1:0]            grant_index,
    output logic                                   grant_valid
);
  
  localparam integer unsigned W = $clog2(CHANNELS);
  
  logic [W-1:0] ptr, idx_masked, idx_raw;
  logic [CHANNELS-1:0] req_gated, ptr_oh, mask, masked_req;
  logic valid_masked, valid_raw;

  assign req_gated = enable ? request : '0;
  assign ptr_oh = CHANNELS'(1'b1) << ptr;
  assign mask = ~(ptr_oh - 1'b1);
  assign masked_req = req_gated & mask;

  always_comb begin
    valid_masked = 1'b0;
    idx_masked = '0;
    for (int i = 0; i < CHANNELS; i++) begin
      if (masked_req[i]) begin
        valid_masked = 1'b1;
        idx_masked = i[W-1:0];
        break;
      end
    end
  end
  
  always_comb begin
    valid_raw = 1'b0;
    idx_raw = '0;
    for (int i = 0; i < CHANNELS; i++) begin
      if (req_gated[i]) begin
        valid_raw = 1'b1;
        idx_raw = i[W-1:0];
        break;
      end
    end
  end
  
  assign grant_valid = valid_masked | valid_raw;
  assign grant_index = valid_masked ? idx_masked : idx_raw;
  
  
  always_ff @(posedge clk) begin
    if (rst) begin
      ptr <= '0;
    end else begin
      if (grant_valid && grant_valid_other_arbiter) begin
        if (grant_index == CHANNELS - 1) begin
          ptr <= '0;
        end else begin
          ptr <= grant_index + 1'b1;
        end
      end
    end
  end
  
endmodule

module d2d_arbiter_9 #( // 4 < CHANNELS <= 9
    parameter int CHANNELS = 2 
)(
    input  logic                                   clk,
    input  logic                                   rst,
    input  logic                                   enable,
    input  logic [CHANNELS-1:0]                    request,
    input  logic                                   grant_valid_other_arbiter,
    output logic [$clog2(CHANNELS)-1:0]            grant_index,
    output logic                                   grant_valid
);
  
  localparam integer unsigned W = $clog2(CHANNELS);
  
  logic [W-1:0] ptr;
  logic [CHANNELS-1:0] req_gated, masked_req, mask;
  
  assign req_gated = enable ? request : '0;
  
  always_comb begin
    for (int i = 0; i < CHANNELS; i++) begin
      mask[i] = (i[W-1:0] >= ptr);
    end
  end
  
  assign masked_req = req_gated & mask;
  
  always_comb begin
    grant_valid = 1'b0;
    grant_index = '0;
    for (int i = 0; i < CHANNELS; i++) begin
      if (masked_req[i]) begin
        grant_valid = 1'b1;
        grant_index = i[W-1:0];
        break;
      end
    end
    if (!grant_valid) begin
      for (int i=0; i<CHANNELS; i++) begin
        if (req_gated[i]) begin
          grant_valid = 1'b1;
          grant_index = i[W-1:0];
          break;
        end
      end
    end
  end
  
  always_ff @(posedge clk) begin
    if (rst) begin
      ptr <= '0;
    end else begin
      if (grant_valid && grant_valid_other_arbiter) begin
        if (grant_index == CHANNELS - 1) begin
          ptr <= '0;
        end else begin
          ptr <= grant_index + 1'b1;
        end
      end
    end
  end
  
endmodule

module d2d_arbiter_4 #( // 2 < CHANNELS <= 4
    parameter int CHANNELS = 4
)(
    input  logic                                   clk,
    input  logic                                   rst,
    input  logic                                   enable,
    input  logic [CHANNELS-1:0]                    request,
    input  logic                                   grant_valid_other_arbiter,
    output logic [$clog2(CHANNELS)-1:0]            grant_index,
    output logic                                   grant_valid
);
  
  localparam integer unsigned W = (CHANNELS > 1) ? $clog2(CHANNELS) : 1;
  
  logic [W-1:0] ptr;
  logic [CHANNELS-1:0] req_gated, mask, req_masked;
  logic [W-1:0] idx_raw, idx_masked;
  logic valid_raw, valid_masked;

  assign req_gated = enable ? request : '0;
  assign mask = {CHANNELS{1'b1}} << ptr;
  assign req_masked = req_gated & mask;

  always_comb begin
    valid_masked = 1'b0;
    idx_masked = '0;
    valid_raw = 1'b0;
    idx_raw = '0;

    for (int i = 0; i < CHANNELS; i++) begin
      if (req_masked[i]) begin
        valid_masked = 1'b1;
        idx_masked = i[W-1:0];
        break;
      end
    end
    for (int i = 0; i < CHANNELS; i++) begin
      if (req_gated[i]) begin
        valid_raw = 1'b1;
        idx_raw = i[W-1:0];
        break;
      end
    end
  end

  assign grant_valid = (valid_masked) ? 1'b1 : valid_raw;
  assign grant_index = (valid_masked) ? idx_masked : idx_raw;

  always_ff @(posedge clk) begin
    if (rst) begin
      ptr <= '0;
    end else begin
      if (grant_valid && grant_valid_other_arbiter) begin
        if (grant_index == CHANNELS - 1) begin
          ptr <= '0;
        end else begin
          ptr <= grant_index + 1'b1;
        end
      end
    end
  end
  
endmodule

module d2d_arbiter_2 #(
  CHANNELS = 2
)  (
    input  logic       clk,
    input  logic       rst,
    input  logic       enable,
    input  logic [1:0] request,
    input  logic       grant_valid_other_arbiter, // Backpressure/Handshake
    output logic       grant_index, // 1 bit is sufficient for 2 channels
    output logic       grant_valid
);

    logic       ptr;
    logic [1:0] req_gated;

    assign req_gated = enable ? request : 2'b00;

    // 1. COMBINATIONAL LOGIC
    always_comb begin
        grant_valid = |req_gated; // Reduction OR

        // Boolean optimization for 2-channel Round Robin
        if (ptr == 1'b0) begin
            // Priority 0 -> 1. If 0 is req, pick 0. Else pick 1.
            grant_index = ~req_gated[0]; 
        end else begin
            // Priority 1 -> 0. If 1 is req, pick 1. Else pick 0.
            grant_index = req_gated[1];
        end
    end

    // 2. POINTER UPDATE
    always_ff @(posedge clk) begin
        if (rst) begin
            ptr <= 1'b0;
        end else if (grant_valid && grant_valid_other_arbiter) begin
            // Swap priority to the one that wasn't just served
            ptr <= ~grant_index; 
        end
    end
    
    // Optional: Safety Assertion
    // Ensure we don't grant an index that isn't requesting (unless valid is low)
    // psL_no_spurious_grant: assert property (
    //    @(posedge clk) disable iff (rst) 
    //    grant_valid |-> req_gated[grant_index]
    // );

endmodule
