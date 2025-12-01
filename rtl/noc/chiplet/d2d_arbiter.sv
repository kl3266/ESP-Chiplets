`timescale 1ns/1ps

module d2d_arbiter #(
    parameter int CHANNELS = 2 
)(
    input  logic                                   clk,
    input  logic                                   rst,
    input  logic [CHANNELS-1:0]                    request,
    input  logic                                   grant_valid_other_arbiter,
    output logic [$clog2(CHANNELS)-1:0]            grant_index,
    output logic                                   grant_valid
);

localparam integer unsigned W = $clog2(CHANNELS);
localparam logic [W:0] CH = (W+1)'(CHANNELS);

logic [W-1:0] ptr, idx;
logic [CHANNELS-1:0] req_rot;
logic [W:0] sum, sum_minus;

always_ff @(posedge clk) begin
  if (rst) begin
    ptr <= '0;
  end else begin
    if (grant_valid && grant_valid_other_arbiter) begin
      ptr <= (grant_index == CHANNELS-1) ? '0 : grant_index + 1'b1;
    end
  end
end

assign req_rot = (request >> ptr) | (request << (CHANNELS-ptr));
assign sum_minus = sum - CH;
assign sum = {1'b0, ptr} + {1'b0, idx};
assign grant_index = (sum >= CH) ? sum_minus[W-1:0] : sum[W-1:0];

always_comb begin
  grant_valid = 1'b0;
  idx = '0;
  for (int i = 0; i < CHANNELS; i++) begin
    if (!grant_valid && req_rot[i]) begin
      grant_valid = 1'b1;
      idx = i[W-1:0];
    end
  end
end
endmodule
