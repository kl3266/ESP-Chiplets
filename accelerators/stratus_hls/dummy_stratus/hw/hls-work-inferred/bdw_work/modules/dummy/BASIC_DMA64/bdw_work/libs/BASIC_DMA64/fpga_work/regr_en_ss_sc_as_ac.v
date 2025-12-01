module regr_en_ss_sc_as_ac(
	input  A,   
	input SYNC_SET,     
	input EN,   
	input RST,   
	input CLR,   
	input SET,   
	input CLK,   
	output reg Z
);
   always @(posedge CLK or negedge CLR or negedge SET) begin
      if (!CLR) Z <= 1'B0;
      else if (!SET) Z <= 1'B1;
      else if (EN) Z <= (A|{1{SYNC_SET}})&{1{RST}};
   end
endmodule