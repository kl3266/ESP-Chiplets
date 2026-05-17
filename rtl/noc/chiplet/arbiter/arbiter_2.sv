module arbiter_2 (
  input  logic       clk,
  input  logic       rst,
  input  logic [1:0] request,
  input  logic       forwarding_head,
  input  logic       forwarding_tail,
  output logic [1:0] grant,
  output logic       grant_valid
);

  logic ptr;
  logic grant_locked;

  assign grant_valid = |request && ~grant_locked;

  // 1. COMBINATIONAL LOGIC
  assign grant[0] = ptr ? (!request[1] && request[0]) : request[0];
  assign grant[1] = ptr ? request[1] : (request[1] && !request[0]);

  // 2. POINTER UPDATE
  always_ff @(posedge clk) begin
    if (rst) begin
      ptr <= 1'b0;
      grant_locked <= 1'b0;
    end else begin
      if (forwarding_head) begin
        ptr <= grant[0];
      end

      if (forwarding_head && !forwarding_tail) begin
        grant_locked <= 1'b1;
      end else if (forwarding_tail) begin
        grant_locked <= 1'b0;
      end
    end
  end
endmodule
