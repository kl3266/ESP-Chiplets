module regr_sc(
	input  A,   
	input RST,   
	input CLK,   
	output reg Z
);
   always @(posedge CLK) begin
      Z <= (A&{1{RST}});
   end
endmodule