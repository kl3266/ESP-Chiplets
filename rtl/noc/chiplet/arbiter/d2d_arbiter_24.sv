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
