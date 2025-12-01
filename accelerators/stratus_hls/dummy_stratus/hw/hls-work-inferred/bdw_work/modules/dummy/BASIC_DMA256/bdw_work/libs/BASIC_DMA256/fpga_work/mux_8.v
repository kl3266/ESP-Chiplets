module mux_8(out,sel,in0,in1,in2,in3,in4,in5,in6,in7);
output reg out;
input [2:0] sel;
input in0;
input in1;
input in2;
input in3;
input in4;
input in5;
input in6;
input in7;
always @(*) case (sel)
    0: out <= in0;
    1: out <= in1;
    2: out <= in2;
    3: out <= in3;
    4: out <= in4;
    5: out <= in5;
    6: out <= in6;
    7: out <= in7;
endcase
endmodule
