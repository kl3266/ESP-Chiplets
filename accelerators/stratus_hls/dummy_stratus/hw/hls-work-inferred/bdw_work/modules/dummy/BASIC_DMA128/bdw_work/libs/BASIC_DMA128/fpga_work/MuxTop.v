module MuxTop(in2,in8,in16,in32,in64, sel2, sel8, sel16, sel32, sel64, out2, out8, out16, out32, out64);

input [1:0] in2;
input [7:0] in8;
input [15:0] in16;
input [31:0] in32;
input [63:0] in64;
input [0:0] sel2;
input [2:0] sel8;
input [3:0] sel16;
input [4:0] sel32;
input [5:0] sel64;
output out2, out8, out16, out32, out64;

mux_2 inst_2 (.out(out2), .sel(sel2), .in0(in2[0]), .in1(in2[1]));
mux_8 inst_8 (.out(out8), .sel(sel8), .in0(in8[0]), .in1(in8[1]), .in2(in8[2]), .in3(in8[3]), .in4(in8[4]), .in5(in8[5]), .in6(in8[6]), .in7(in8[7]));
mux_16 inst_16 (.out(out16), .sel(sel16), .in0(in16[0]), .in1(in16[1]), .in2(in16[2]), .in3(in16[3]), .in4(in16[4]), .in5(in16[5]), .in6(in16[6]), .in7(in16[7]), .in8(in16[8]), .in9(in16[9]), .in10(in16[10]), .in11(in16[11]), .in12(in16[12]), .in13(in16[13]), .in14(in16[14]), .in15(in16[15]));
mux_32 inst_32 (.out(out32), .sel(sel32), .in0(in32[0]), .in1(in32[1]), .in2(in32[2]), .in3(in32[3]), .in4(in32[4]), .in5(in32[5]), .in6(in32[6]), .in7(in32[7]), .in8(in32[8]), .in9(in32[9]), .in10(in32[10]), .in11(in32[11]), .in12(in32[12]), .in13(in32[13]), .in14(in32[14]), .in15(in32[15]), .in16(in32[16]), .in17(in32[17]), .in18(in32[18]), .in19(in32[19]), .in20(in32[20]), .in21(in32[21]), .in22(in32[22]), .in23(in32[23]), .in24(in32[24]), .in25(in32[25]), .in26(in32[26]), .in27(in32[27]), .in28(in32[28]), .in29(in32[29]), .in30(in32[30]), .in31(in32[31]));
mux_64 inst_64 (.out(out64), .sel(sel64), .in0(in64[0]), .in1(in64[1]), .in2(in64[2]), .in3(in64[3]), .in4(in64[4]), .in5(in64[5]), .in6(in64[6]), .in7(in64[7]), .in8(in64[8]), .in9(in64[9]), .in10(in64[10]), .in11(in64[11]), .in12(in64[12]), .in13(in64[13]), .in14(in64[14]), .in15(in64[15]), .in16(in64[16]), .in17(in64[17]), .in18(in64[18]), .in19(in64[19]), .in20(in64[20]), .in21(in64[21]), .in22(in64[22]), .in23(in64[23]), .in24(in64[24]), .in25(in64[25]), .in26(in64[26]), .in27(in64[27]), .in28(in64[28]), .in29(in64[29]), .in30(in64[30]), .in31(in64[31]), .in32(in64[32]), .in33(in64[33]), .in34(in64[34]), .in35(in64[35]), .in36(in64[36]), .in37(in64[37]), .in38(in64[38]), .in39(in64[39]), .in40(in64[40]), .in41(in64[41]), .in42(in64[42]), .in43(in64[43]), .in44(in64[44]), .in45(in64[45]), .in46(in64[46]), .in47(in64[47]), .in48(in64[48]), .in49(in64[49]), .in50(in64[50]), .in51(in64[51]), .in52(in64[52]), .in53(in64[53]), .in54(in64[54]), .in55(in64[55]), .in56(in64[56]), .in57(in64[57]), .in58(in64[58]), .in59(in64[59]), .in60(in64[60]), .in61(in64[61]), .in62(in64[62]), .in63(in64[63]));
endmodule