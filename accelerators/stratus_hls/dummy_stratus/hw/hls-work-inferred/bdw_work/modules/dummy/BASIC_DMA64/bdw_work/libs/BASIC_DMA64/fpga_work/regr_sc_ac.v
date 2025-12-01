module regr_sc_ac(
	input  A,   
	input RST,   
	input CLR,   
	input CLK,   
	output reg Z
);
   always @(posedge CLK or negedge CLR) begin
      if (!CLR) Z <= 1'B0;
      else Z <= (A&{1{RST}});
   end
endmodule