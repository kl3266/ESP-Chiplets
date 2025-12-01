module mux_2(out,sel,in0,in1);
output reg out;
input [0:0] sel;
input in0;
input in1;
always @(*) case (sel)
    0: out <= in0;
    1: out <= in1;
endcase
endmodule
