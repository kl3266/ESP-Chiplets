module regr_ac(
	input  A,   
	input CLR,   
	input CLK,   
	output reg Z
);
   always @(posedge CLK or negedge CLR) begin
      if (!CLR) Z <= 1'B0;
      else Z <= (A);
   end
endmodule