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
