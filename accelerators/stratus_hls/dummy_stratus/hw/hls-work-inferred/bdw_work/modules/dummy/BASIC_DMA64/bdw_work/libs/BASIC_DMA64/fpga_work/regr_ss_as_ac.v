module regr_ss_as_ac(
	input  A,   
	input RST,   
	input CLR,   
	input SET,   
	input CLK,   
	output reg Z
);
   always @(posedge CLK or negedge CLR or negedge SET) begin
      if (!CLR) Z <= 1'B0;
      else if (!SET) Z <= 1'B1;
      else Z <= (A&{1{RST}});
   end
endmodule