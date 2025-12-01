module RegTop (
input [7:0] A,
input SYNC_SET,
input EN,
input RST,
input CLR,
input SET,
input CLK,
output [7:0] Z);
regr     regr1(A[0], CLK, Z[0]);
regr_ac     regr_ac1(A[1], CLR, CLK, Z[1]);
regr_as_ac     regr_as_ac1(A[2], CLR, SET, CLK, Z[2]);
regr_sc     regr_sc1(A[3], RST, CLK, Z[3]);
regr_sc_ac     regr_sc_ac1(A[4], RST, CLR, CLK, Z[4]);
regr_ss_as_ac     regr_ss_as_ac1(A[5], SYNC_SET, CLR, SET, CLK, Z[5]);
regr_en_as_ac     regr_en_as_ac1(A[6], EN, CLR, SET, CLK, Z[6]);
regr_en_ss_sc_as_ac     regr_en_ss_sc_as_ac1(A[7], SYNC_SET, EN, RST, CLR, SET, CLK, Z[7]);

endmodule