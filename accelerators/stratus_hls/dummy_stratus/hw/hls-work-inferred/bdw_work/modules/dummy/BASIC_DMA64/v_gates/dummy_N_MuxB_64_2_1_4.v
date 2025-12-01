// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
// Date        : Mon Dec  1 16:09:42 2025
// Host        : haagendazs running 64-bit Red Hat Enterprise Linux release 8.10 (Ootpa)
// Command     : write_verilog -cell inst_12 -force
//               /home/kevin/nov_submission/esp/accelerators/stratus_hls/dummy_stratus/hw/hls-work-inferred/bdw_work/modules/dummy/BASIC_DMA64/v_gates/dummy_N_MuxB_64_2_1_4.v
// Design      : dummy_N_MuxB_64_2_1_4
// Purpose     : This is a Verilog netlist of the current design or from a specific cell of the design. The output is an
//               IEEE 1364-2001 compliant Verilog HDL file that contains netlist information obtained from the input
//               design files.
// Device      : xc7v2000tflg1925-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* STRUCTURAL_NETLIST = "yes" *)
module dummy_N_MuxB_64_2_1_4
   (in3,
    in2,
    ctrl1,
    out1);
  input [63:0]in3;
  input [63:0]in2;
  input ctrl1;
  output [63:0]out1;

  wire ctrl1;
  wire [63:0]in2;
  wire [63:0]in3;
  wire [63:0]out1;

  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[0]_INST_0 
       (.I0(in2[0]),
        .I1(ctrl1),
        .I2(in3[0]),
        .O(out1[0]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[10]_INST_0 
       (.I0(in2[10]),
        .I1(ctrl1),
        .I2(in3[10]),
        .O(out1[10]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[11]_INST_0 
       (.I0(ctrl1),
        .I1(in2[11]),
        .I2(in3[11]),
        .O(out1[11]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[12]_INST_0 
       (.I0(in2[12]),
        .I1(ctrl1),
        .I2(in3[12]),
        .O(out1[12]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[13]_INST_0 
       (.I0(ctrl1),
        .I1(in2[13]),
        .I2(in3[13]),
        .O(out1[13]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[14]_INST_0 
       (.I0(in2[14]),
        .I1(ctrl1),
        .I2(in3[14]),
        .O(out1[14]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[15]_INST_0 
       (.I0(ctrl1),
        .I1(in2[15]),
        .I2(in3[15]),
        .O(out1[15]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[16]_INST_0 
       (.I0(in2[16]),
        .I1(ctrl1),
        .I2(in3[16]),
        .O(out1[16]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[17]_INST_0 
       (.I0(ctrl1),
        .I1(in2[17]),
        .I2(in3[17]),
        .O(out1[17]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[18]_INST_0 
       (.I0(in2[18]),
        .I1(ctrl1),
        .I2(in3[18]),
        .O(out1[18]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[19]_INST_0 
       (.I0(ctrl1),
        .I1(in2[19]),
        .I2(in3[19]),
        .O(out1[19]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[1]_INST_0 
       (.I0(ctrl1),
        .I1(in2[1]),
        .I2(in3[1]),
        .O(out1[1]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[20]_INST_0 
       (.I0(in2[20]),
        .I1(ctrl1),
        .I2(in3[20]),
        .O(out1[20]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[21]_INST_0 
       (.I0(ctrl1),
        .I1(in2[21]),
        .I2(in3[21]),
        .O(out1[21]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[22]_INST_0 
       (.I0(in2[22]),
        .I1(ctrl1),
        .I2(in3[22]),
        .O(out1[22]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[23]_INST_0 
       (.I0(ctrl1),
        .I1(in2[23]),
        .I2(in3[23]),
        .O(out1[23]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[24]_INST_0 
       (.I0(in2[24]),
        .I1(ctrl1),
        .I2(in3[24]),
        .O(out1[24]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[25]_INST_0 
       (.I0(ctrl1),
        .I1(in2[25]),
        .I2(in3[25]),
        .O(out1[25]));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[26]_INST_0 
       (.I0(in2[26]),
        .I1(ctrl1),
        .I2(in3[26]),
        .O(out1[26]));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[27]_INST_0 
       (.I0(ctrl1),
        .I1(in2[27]),
        .I2(in3[27]),
        .O(out1[27]));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[28]_INST_0 
       (.I0(in2[28]),
        .I1(ctrl1),
        .I2(in3[28]),
        .O(out1[28]));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[29]_INST_0 
       (.I0(ctrl1),
        .I1(in2[29]),
        .I2(in3[29]),
        .O(out1[29]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[2]_INST_0 
       (.I0(in2[2]),
        .I1(ctrl1),
        .I2(in3[2]),
        .O(out1[2]));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[30]_INST_0 
       (.I0(in2[30]),
        .I1(ctrl1),
        .I2(in3[30]),
        .O(out1[30]));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[31]_INST_0 
       (.I0(ctrl1),
        .I1(in2[31]),
        .I2(in3[31]),
        .O(out1[31]));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[32]_INST_0 
       (.I0(in2[32]),
        .I1(ctrl1),
        .I2(in3[32]),
        .O(out1[32]));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[33]_INST_0 
       (.I0(ctrl1),
        .I1(in2[33]),
        .I2(in3[33]),
        .O(out1[33]));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[34]_INST_0 
       (.I0(in2[34]),
        .I1(ctrl1),
        .I2(in3[34]),
        .O(out1[34]));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[35]_INST_0 
       (.I0(ctrl1),
        .I1(in2[35]),
        .I2(in3[35]),
        .O(out1[35]));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[36]_INST_0 
       (.I0(in2[36]),
        .I1(ctrl1),
        .I2(in3[36]),
        .O(out1[36]));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[37]_INST_0 
       (.I0(ctrl1),
        .I1(in2[37]),
        .I2(in3[37]),
        .O(out1[37]));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[38]_INST_0 
       (.I0(in2[38]),
        .I1(ctrl1),
        .I2(in3[38]),
        .O(out1[38]));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[39]_INST_0 
       (.I0(ctrl1),
        .I1(in2[39]),
        .I2(in3[39]),
        .O(out1[39]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[3]_INST_0 
       (.I0(ctrl1),
        .I1(in2[3]),
        .I2(in3[3]),
        .O(out1[3]));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[40]_INST_0 
       (.I0(in2[40]),
        .I1(ctrl1),
        .I2(in3[40]),
        .O(out1[40]));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[41]_INST_0 
       (.I0(ctrl1),
        .I1(in2[41]),
        .I2(in3[41]),
        .O(out1[41]));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[42]_INST_0 
       (.I0(in2[42]),
        .I1(ctrl1),
        .I2(in3[42]),
        .O(out1[42]));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[43]_INST_0 
       (.I0(ctrl1),
        .I1(in2[43]),
        .I2(in3[43]),
        .O(out1[43]));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[44]_INST_0 
       (.I0(in2[44]),
        .I1(ctrl1),
        .I2(in3[44]),
        .O(out1[44]));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[45]_INST_0 
       (.I0(ctrl1),
        .I1(in2[45]),
        .I2(in3[45]),
        .O(out1[45]));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[46]_INST_0 
       (.I0(in2[46]),
        .I1(ctrl1),
        .I2(in3[46]),
        .O(out1[46]));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[47]_INST_0 
       (.I0(ctrl1),
        .I1(in2[47]),
        .I2(in3[47]),
        .O(out1[47]));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[48]_INST_0 
       (.I0(in2[48]),
        .I1(ctrl1),
        .I2(in3[48]),
        .O(out1[48]));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[49]_INST_0 
       (.I0(ctrl1),
        .I1(in2[49]),
        .I2(in3[49]),
        .O(out1[49]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[4]_INST_0 
       (.I0(in2[4]),
        .I1(ctrl1),
        .I2(in3[4]),
        .O(out1[4]));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[50]_INST_0 
       (.I0(in2[50]),
        .I1(ctrl1),
        .I2(in3[50]),
        .O(out1[50]));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[51]_INST_0 
       (.I0(ctrl1),
        .I1(in2[51]),
        .I2(in3[51]),
        .O(out1[51]));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[52]_INST_0 
       (.I0(in2[52]),
        .I1(ctrl1),
        .I2(in3[52]),
        .O(out1[52]));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[53]_INST_0 
       (.I0(ctrl1),
        .I1(in2[53]),
        .I2(in3[53]),
        .O(out1[53]));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[54]_INST_0 
       (.I0(in2[54]),
        .I1(ctrl1),
        .I2(in3[54]),
        .O(out1[54]));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[55]_INST_0 
       (.I0(ctrl1),
        .I1(in2[55]),
        .I2(in3[55]),
        .O(out1[55]));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[56]_INST_0 
       (.I0(in2[56]),
        .I1(ctrl1),
        .I2(in3[56]),
        .O(out1[56]));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[57]_INST_0 
       (.I0(ctrl1),
        .I1(in2[57]),
        .I2(in3[57]),
        .O(out1[57]));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[58]_INST_0 
       (.I0(in2[58]),
        .I1(ctrl1),
        .I2(in3[58]),
        .O(out1[58]));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[59]_INST_0 
       (.I0(ctrl1),
        .I1(in2[59]),
        .I2(in3[59]),
        .O(out1[59]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[5]_INST_0 
       (.I0(ctrl1),
        .I1(in2[5]),
        .I2(in3[5]),
        .O(out1[5]));
  (* SOFT_HLUTNM = "soft_lutpair30" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[60]_INST_0 
       (.I0(in2[60]),
        .I1(ctrl1),
        .I2(in3[60]),
        .O(out1[60]));
  (* SOFT_HLUTNM = "soft_lutpair30" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[61]_INST_0 
       (.I0(ctrl1),
        .I1(in2[61]),
        .I2(in3[61]),
        .O(out1[61]));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[62]_INST_0 
       (.I0(in2[62]),
        .I1(ctrl1),
        .I2(in3[62]),
        .O(out1[62]));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[63]_INST_0 
       (.I0(ctrl1),
        .I1(in2[63]),
        .I2(in3[63]),
        .O(out1[63]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[6]_INST_0 
       (.I0(in2[6]),
        .I1(ctrl1),
        .I2(in3[6]),
        .O(out1[6]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[7]_INST_0 
       (.I0(ctrl1),
        .I1(in2[7]),
        .I2(in3[7]),
        .O(out1[7]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[8]_INST_0 
       (.I0(in2[8]),
        .I1(ctrl1),
        .I2(in3[8]),
        .O(out1[8]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[9]_INST_0 
       (.I0(ctrl1),
        .I1(in2[9]),
        .I2(in3[9]),
        .O(out1[9]));
endmodule
