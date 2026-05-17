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
