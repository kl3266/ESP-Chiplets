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
