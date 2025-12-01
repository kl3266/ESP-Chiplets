module regr(
	input  A,   
	input CLK,   
	output reg Z
);
   always @(posedge CLK) begin
      Z <= (A);
   end
endmodule