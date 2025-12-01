// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
// Date        : Mon Dec  1 16:10:39 2025
// Host        : haagendazs running 64-bit Red Hat Enterprise Linux release 8.10 (Ootpa)
// Command     : write_verilog -cell inst_3 -force
//               /home/kevin/nov_submission/esp/accelerators/stratus_hls/dummy_stratus/hw/hls-work-inferred/bdw_work/modules/dummy/BASIC_DMA128/v_gates/dummy_N_MuxB_128_2_1_4.v
// Design      : dummy_N_MuxB_128_2_1_4
// Purpose     : This is a Verilog netlist of the current design or from a specific cell of the design. The output is an
//               IEEE 1364-2001 compliant Verilog HDL file that contains netlist information obtained from the input
//               design files.
// Device      : xc7v2000tflg1925-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* STRUCTURAL_NETLIST = "yes" *)
module dummy_N_MuxB_128_2_1_4
   (in3,
    in2,
    ctrl1,
    out1);
  input [127:0]in3;
  input [127:0]in2;
  input ctrl1;
  output [127:0]out1;

  wire ctrl1;
  wire [127:0]in2;
  wire [127:0]in3;
  wire [127:0]out1;

  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[0]_INST_0 
       (.I0(in2[0]),
        .I1(ctrl1),
        .I2(in3[0]),
        .O(out1[0]));
  (* SOFT_HLUTNM = "soft_lutpair54" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[100]_INST_0 
       (.I0(in2[100]),
        .I1(ctrl1),
        .I2(in3[100]),
        .O(out1[100]));
  (* SOFT_HLUTNM = "soft_lutpair54" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[101]_INST_0 
       (.I0(ctrl1),
        .I1(in2[101]),
        .I2(in3[101]),
        .O(out1[101]));
  (* SOFT_HLUTNM = "soft_lutpair55" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[102]_INST_0 
       (.I0(in2[102]),
        .I1(ctrl1),
        .I2(in3[102]),
        .O(out1[102]));
  (* SOFT_HLUTNM = "soft_lutpair55" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[103]_INST_0 
       (.I0(ctrl1),
        .I1(in2[103]),
        .I2(in3[103]),
        .O(out1[103]));
  (* SOFT_HLUTNM = "soft_lutpair56" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[104]_INST_0 
       (.I0(in2[104]),
        .I1(ctrl1),
        .I2(in3[104]),
        .O(out1[104]));
  (* SOFT_HLUTNM = "soft_lutpair56" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[105]_INST_0 
       (.I0(ctrl1),
        .I1(in2[105]),
        .I2(in3[105]),
        .O(out1[105]));
  (* SOFT_HLUTNM = "soft_lutpair57" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[106]_INST_0 
       (.I0(in2[106]),
        .I1(ctrl1),
        .I2(in3[106]),
        .O(out1[106]));
  (* SOFT_HLUTNM = "soft_lutpair57" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[107]_INST_0 
       (.I0(ctrl1),
        .I1(in2[107]),
        .I2(in3[107]),
        .O(out1[107]));
  (* SOFT_HLUTNM = "soft_lutpair58" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[108]_INST_0 
       (.I0(in2[108]),
        .I1(ctrl1),
        .I2(in3[108]),
        .O(out1[108]));
  (* SOFT_HLUTNM = "soft_lutpair58" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[109]_INST_0 
       (.I0(ctrl1),
        .I1(in2[109]),
        .I2(in3[109]),
        .O(out1[109]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[10]_INST_0 
       (.I0(in2[10]),
        .I1(ctrl1),
        .I2(in3[10]),
        .O(out1[10]));
  (* SOFT_HLUTNM = "soft_lutpair59" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[110]_INST_0 
       (.I0(in2[110]),
        .I1(ctrl1),
        .I2(in3[110]),
        .O(out1[110]));
  (* SOFT_HLUTNM = "soft_lutpair59" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[111]_INST_0 
       (.I0(ctrl1),
        .I1(in2[111]),
        .I2(in3[111]),
        .O(out1[111]));
  (* SOFT_HLUTNM = "soft_lutpair60" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[112]_INST_0 
       (.I0(in2[112]),
        .I1(ctrl1),
        .I2(in3[112]),
        .O(out1[112]));
  (* SOFT_HLUTNM = "soft_lutpair60" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[113]_INST_0 
       (.I0(ctrl1),
        .I1(in2[113]),
        .I2(in3[113]),
        .O(out1[113]));
  (* SOFT_HLUTNM = "soft_lutpair61" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[114]_INST_0 
       (.I0(in2[114]),
        .I1(ctrl1),
        .I2(in3[114]),
        .O(out1[114]));
  (* SOFT_HLUTNM = "soft_lutpair61" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[115]_INST_0 
       (.I0(ctrl1),
        .I1(in2[115]),
        .I2(in3[115]),
        .O(out1[115]));
  (* SOFT_HLUTNM = "soft_lutpair62" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[116]_INST_0 
       (.I0(in2[116]),
        .I1(ctrl1),
        .I2(in3[116]),
        .O(out1[116]));
  (* SOFT_HLUTNM = "soft_lutpair62" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[117]_INST_0 
       (.I0(ctrl1),
        .I1(in2[117]),
        .I2(in3[117]),
        .O(out1[117]));
  (* SOFT_HLUTNM = "soft_lutpair63" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[118]_INST_0 
       (.I0(in2[118]),
        .I1(ctrl1),
        .I2(in3[118]),
        .O(out1[118]));
  (* SOFT_HLUTNM = "soft_lutpair63" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[119]_INST_0 
       (.I0(ctrl1),
        .I1(in2[119]),
        .I2(in3[119]),
        .O(out1[119]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[11]_INST_0 
       (.I0(ctrl1),
        .I1(in2[11]),
        .I2(in3[11]),
        .O(out1[11]));
  (* SOFT_HLUTNM = "soft_lutpair64" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[120]_INST_0 
       (.I0(in2[120]),
        .I1(ctrl1),
        .I2(in3[120]),
        .O(out1[120]));
  (* SOFT_HLUTNM = "soft_lutpair64" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[121]_INST_0 
       (.I0(ctrl1),
        .I1(in2[121]),
        .I2(in3[121]),
        .O(out1[121]));
  (* SOFT_HLUTNM = "soft_lutpair65" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[122]_INST_0 
       (.I0(in2[122]),
        .I1(ctrl1),
        .I2(in3[122]),
        .O(out1[122]));
  (* SOFT_HLUTNM = "soft_lutpair65" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[123]_INST_0 
       (.I0(ctrl1),
        .I1(in2[123]),
        .I2(in3[123]),
        .O(out1[123]));
  (* SOFT_HLUTNM = "soft_lutpair66" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[124]_INST_0 
       (.I0(in2[124]),
        .I1(ctrl1),
        .I2(in3[124]),
        .O(out1[124]));
  (* SOFT_HLUTNM = "soft_lutpair66" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[125]_INST_0 
       (.I0(ctrl1),
        .I1(in2[125]),
        .I2(in3[125]),
        .O(out1[125]));
  (* SOFT_HLUTNM = "soft_lutpair67" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[126]_INST_0 
       (.I0(in2[126]),
        .I1(ctrl1),
        .I2(in3[126]),
        .O(out1[126]));
  (* SOFT_HLUTNM = "soft_lutpair67" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[127]_INST_0 
       (.I0(ctrl1),
        .I1(in2[127]),
        .I2(in3[127]),
        .O(out1[127]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[12]_INST_0 
       (.I0(in2[12]),
        .I1(ctrl1),
        .I2(in3[12]),
        .O(out1[12]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[13]_INST_0 
       (.I0(ctrl1),
        .I1(in2[13]),
        .I2(in3[13]),
        .O(out1[13]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[14]_INST_0 
       (.I0(in2[14]),
        .I1(ctrl1),
        .I2(in3[14]),
        .O(out1[14]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[15]_INST_0 
       (.I0(ctrl1),
        .I1(in2[15]),
        .I2(in3[15]),
        .O(out1[15]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[16]_INST_0 
       (.I0(in2[16]),
        .I1(ctrl1),
        .I2(in3[16]),
        .O(out1[16]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[17]_INST_0 
       (.I0(ctrl1),
        .I1(in2[17]),
        .I2(in3[17]),
        .O(out1[17]));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[18]_INST_0 
       (.I0(in2[18]),
        .I1(ctrl1),
        .I2(in3[18]),
        .O(out1[18]));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[19]_INST_0 
       (.I0(ctrl1),
        .I1(in2[19]),
        .I2(in3[19]),
        .O(out1[19]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[1]_INST_0 
       (.I0(ctrl1),
        .I1(in2[1]),
        .I2(in3[1]),
        .O(out1[1]));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[20]_INST_0 
       (.I0(in2[20]),
        .I1(ctrl1),
        .I2(in3[20]),
        .O(out1[20]));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[21]_INST_0 
       (.I0(ctrl1),
        .I1(in2[21]),
        .I2(in3[21]),
        .O(out1[21]));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[22]_INST_0 
       (.I0(in2[22]),
        .I1(ctrl1),
        .I2(in3[22]),
        .O(out1[22]));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[23]_INST_0 
       (.I0(ctrl1),
        .I1(in2[23]),
        .I2(in3[23]),
        .O(out1[23]));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[24]_INST_0 
       (.I0(in2[24]),
        .I1(ctrl1),
        .I2(in3[24]),
        .O(out1[24]));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[25]_INST_0 
       (.I0(ctrl1),
        .I1(in2[25]),
        .I2(in3[25]),
        .O(out1[25]));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[26]_INST_0 
       (.I0(in2[26]),
        .I1(ctrl1),
        .I2(in3[26]),
        .O(out1[26]));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[27]_INST_0 
       (.I0(ctrl1),
        .I1(in2[27]),
        .I2(in3[27]),
        .O(out1[27]));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[28]_INST_0 
       (.I0(in2[28]),
        .I1(ctrl1),
        .I2(in3[28]),
        .O(out1[28]));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[29]_INST_0 
       (.I0(ctrl1),
        .I1(in2[29]),
        .I2(in3[29]),
        .O(out1[29]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[2]_INST_0 
       (.I0(in2[2]),
        .I1(ctrl1),
        .I2(in3[2]),
        .O(out1[2]));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[30]_INST_0 
       (.I0(in2[30]),
        .I1(ctrl1),
        .I2(in3[30]),
        .O(out1[30]));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[31]_INST_0 
       (.I0(ctrl1),
        .I1(in2[31]),
        .I2(in3[31]),
        .O(out1[31]));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[32]_INST_0 
       (.I0(in2[32]),
        .I1(ctrl1),
        .I2(in3[32]),
        .O(out1[32]));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[33]_INST_0 
       (.I0(ctrl1),
        .I1(in2[33]),
        .I2(in3[33]),
        .O(out1[33]));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[34]_INST_0 
       (.I0(in2[34]),
        .I1(ctrl1),
        .I2(in3[34]),
        .O(out1[34]));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[35]_INST_0 
       (.I0(ctrl1),
        .I1(in2[35]),
        .I2(in3[35]),
        .O(out1[35]));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[36]_INST_0 
       (.I0(in2[36]),
        .I1(ctrl1),
        .I2(in3[36]),
        .O(out1[36]));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[37]_INST_0 
       (.I0(ctrl1),
        .I1(in2[37]),
        .I2(in3[37]),
        .O(out1[37]));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[38]_INST_0 
       (.I0(in2[38]),
        .I1(ctrl1),
        .I2(in3[38]),
        .O(out1[38]));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[39]_INST_0 
       (.I0(ctrl1),
        .I1(in2[39]),
        .I2(in3[39]),
        .O(out1[39]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[3]_INST_0 
       (.I0(ctrl1),
        .I1(in2[3]),
        .I2(in3[3]),
        .O(out1[3]));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[40]_INST_0 
       (.I0(in2[40]),
        .I1(ctrl1),
        .I2(in3[40]),
        .O(out1[40]));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[41]_INST_0 
       (.I0(ctrl1),
        .I1(in2[41]),
        .I2(in3[41]),
        .O(out1[41]));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[42]_INST_0 
       (.I0(in2[42]),
        .I1(ctrl1),
        .I2(in3[42]),
        .O(out1[42]));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[43]_INST_0 
       (.I0(ctrl1),
        .I1(in2[43]),
        .I2(in3[43]),
        .O(out1[43]));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[44]_INST_0 
       (.I0(in2[44]),
        .I1(ctrl1),
        .I2(in3[44]),
        .O(out1[44]));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[45]_INST_0 
       (.I0(ctrl1),
        .I1(in2[45]),
        .I2(in3[45]),
        .O(out1[45]));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[46]_INST_0 
       (.I0(in2[46]),
        .I1(ctrl1),
        .I2(in3[46]),
        .O(out1[46]));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[47]_INST_0 
       (.I0(ctrl1),
        .I1(in2[47]),
        .I2(in3[47]),
        .O(out1[47]));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[48]_INST_0 
       (.I0(in2[48]),
        .I1(ctrl1),
        .I2(in3[48]),
        .O(out1[48]));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[49]_INST_0 
       (.I0(ctrl1),
        .I1(in2[49]),
        .I2(in3[49]),
        .O(out1[49]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[4]_INST_0 
       (.I0(in2[4]),
        .I1(ctrl1),
        .I2(in3[4]),
        .O(out1[4]));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[50]_INST_0 
       (.I0(in2[50]),
        .I1(ctrl1),
        .I2(in3[50]),
        .O(out1[50]));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[51]_INST_0 
       (.I0(ctrl1),
        .I1(in2[51]),
        .I2(in3[51]),
        .O(out1[51]));
  (* SOFT_HLUTNM = "soft_lutpair30" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[52]_INST_0 
       (.I0(in2[52]),
        .I1(ctrl1),
        .I2(in3[52]),
        .O(out1[52]));
  (* SOFT_HLUTNM = "soft_lutpair30" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[53]_INST_0 
       (.I0(ctrl1),
        .I1(in2[53]),
        .I2(in3[53]),
        .O(out1[53]));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[54]_INST_0 
       (.I0(in2[54]),
        .I1(ctrl1),
        .I2(in3[54]),
        .O(out1[54]));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[55]_INST_0 
       (.I0(ctrl1),
        .I1(in2[55]),
        .I2(in3[55]),
        .O(out1[55]));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[56]_INST_0 
       (.I0(in2[56]),
        .I1(ctrl1),
        .I2(in3[56]),
        .O(out1[56]));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[57]_INST_0 
       (.I0(ctrl1),
        .I1(in2[57]),
        .I2(in3[57]),
        .O(out1[57]));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[58]_INST_0 
       (.I0(in2[58]),
        .I1(ctrl1),
        .I2(in3[58]),
        .O(out1[58]));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[59]_INST_0 
       (.I0(ctrl1),
        .I1(in2[59]),
        .I2(in3[59]),
        .O(out1[59]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[5]_INST_0 
       (.I0(ctrl1),
        .I1(in2[5]),
        .I2(in3[5]),
        .O(out1[5]));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[60]_INST_0 
       (.I0(in2[60]),
        .I1(ctrl1),
        .I2(in3[60]),
        .O(out1[60]));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[61]_INST_0 
       (.I0(ctrl1),
        .I1(in2[61]),
        .I2(in3[61]),
        .O(out1[61]));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[62]_INST_0 
       (.I0(in2[62]),
        .I1(ctrl1),
        .I2(in3[62]),
        .O(out1[62]));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[63]_INST_0 
       (.I0(ctrl1),
        .I1(in2[63]),
        .I2(in3[63]),
        .O(out1[63]));
  (* SOFT_HLUTNM = "soft_lutpair36" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[64]_INST_0 
       (.I0(in2[64]),
        .I1(ctrl1),
        .I2(in3[64]),
        .O(out1[64]));
  (* SOFT_HLUTNM = "soft_lutpair36" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[65]_INST_0 
       (.I0(ctrl1),
        .I1(in2[65]),
        .I2(in3[65]),
        .O(out1[65]));
  (* SOFT_HLUTNM = "soft_lutpair37" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[66]_INST_0 
       (.I0(in2[66]),
        .I1(ctrl1),
        .I2(in3[66]),
        .O(out1[66]));
  (* SOFT_HLUTNM = "soft_lutpair37" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[67]_INST_0 
       (.I0(ctrl1),
        .I1(in2[67]),
        .I2(in3[67]),
        .O(out1[67]));
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[68]_INST_0 
       (.I0(in2[68]),
        .I1(ctrl1),
        .I2(in3[68]),
        .O(out1[68]));
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[69]_INST_0 
       (.I0(ctrl1),
        .I1(in2[69]),
        .I2(in3[69]),
        .O(out1[69]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[6]_INST_0 
       (.I0(in2[6]),
        .I1(ctrl1),
        .I2(in3[6]),
        .O(out1[6]));
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[70]_INST_0 
       (.I0(in2[70]),
        .I1(ctrl1),
        .I2(in3[70]),
        .O(out1[70]));
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[71]_INST_0 
       (.I0(ctrl1),
        .I1(in2[71]),
        .I2(in3[71]),
        .O(out1[71]));
  (* SOFT_HLUTNM = "soft_lutpair40" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[72]_INST_0 
       (.I0(in2[72]),
        .I1(ctrl1),
        .I2(in3[72]),
        .O(out1[72]));
  (* SOFT_HLUTNM = "soft_lutpair40" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[73]_INST_0 
       (.I0(ctrl1),
        .I1(in2[73]),
        .I2(in3[73]),
        .O(out1[73]));
  (* SOFT_HLUTNM = "soft_lutpair41" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[74]_INST_0 
       (.I0(in2[74]),
        .I1(ctrl1),
        .I2(in3[74]),
        .O(out1[74]));
  (* SOFT_HLUTNM = "soft_lutpair41" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[75]_INST_0 
       (.I0(ctrl1),
        .I1(in2[75]),
        .I2(in3[75]),
        .O(out1[75]));
  (* SOFT_HLUTNM = "soft_lutpair42" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[76]_INST_0 
       (.I0(in2[76]),
        .I1(ctrl1),
        .I2(in3[76]),
        .O(out1[76]));
  (* SOFT_HLUTNM = "soft_lutpair42" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[77]_INST_0 
       (.I0(ctrl1),
        .I1(in2[77]),
        .I2(in3[77]),
        .O(out1[77]));
  (* SOFT_HLUTNM = "soft_lutpair43" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[78]_INST_0 
       (.I0(in2[78]),
        .I1(ctrl1),
        .I2(in3[78]),
        .O(out1[78]));
  (* SOFT_HLUTNM = "soft_lutpair43" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[79]_INST_0 
       (.I0(ctrl1),
        .I1(in2[79]),
        .I2(in3[79]),
        .O(out1[79]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[7]_INST_0 
       (.I0(ctrl1),
        .I1(in2[7]),
        .I2(in3[7]),
        .O(out1[7]));
  (* SOFT_HLUTNM = "soft_lutpair44" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[80]_INST_0 
       (.I0(in2[80]),
        .I1(ctrl1),
        .I2(in3[80]),
        .O(out1[80]));
  (* SOFT_HLUTNM = "soft_lutpair44" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[81]_INST_0 
       (.I0(ctrl1),
        .I1(in2[81]),
        .I2(in3[81]),
        .O(out1[81]));
  (* SOFT_HLUTNM = "soft_lutpair45" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[82]_INST_0 
       (.I0(in2[82]),
        .I1(ctrl1),
        .I2(in3[82]),
        .O(out1[82]));
  (* SOFT_HLUTNM = "soft_lutpair45" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[83]_INST_0 
       (.I0(ctrl1),
        .I1(in2[83]),
        .I2(in3[83]),
        .O(out1[83]));
  (* SOFT_HLUTNM = "soft_lutpair46" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[84]_INST_0 
       (.I0(in2[84]),
        .I1(ctrl1),
        .I2(in3[84]),
        .O(out1[84]));
  (* SOFT_HLUTNM = "soft_lutpair46" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[85]_INST_0 
       (.I0(ctrl1),
        .I1(in2[85]),
        .I2(in3[85]),
        .O(out1[85]));
  (* SOFT_HLUTNM = "soft_lutpair47" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[86]_INST_0 
       (.I0(in2[86]),
        .I1(ctrl1),
        .I2(in3[86]),
        .O(out1[86]));
  (* SOFT_HLUTNM = "soft_lutpair47" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[87]_INST_0 
       (.I0(ctrl1),
        .I1(in2[87]),
        .I2(in3[87]),
        .O(out1[87]));
  (* SOFT_HLUTNM = "soft_lutpair48" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[88]_INST_0 
       (.I0(in2[88]),
        .I1(ctrl1),
        .I2(in3[88]),
        .O(out1[88]));
  (* SOFT_HLUTNM = "soft_lutpair48" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[89]_INST_0 
       (.I0(ctrl1),
        .I1(in2[89]),
        .I2(in3[89]),
        .O(out1[89]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[8]_INST_0 
       (.I0(in2[8]),
        .I1(ctrl1),
        .I2(in3[8]),
        .O(out1[8]));
  (* SOFT_HLUTNM = "soft_lutpair49" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[90]_INST_0 
       (.I0(in2[90]),
        .I1(ctrl1),
        .I2(in3[90]),
        .O(out1[90]));
  (* SOFT_HLUTNM = "soft_lutpair49" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[91]_INST_0 
       (.I0(ctrl1),
        .I1(in2[91]),
        .I2(in3[91]),
        .O(out1[91]));
  (* SOFT_HLUTNM = "soft_lutpair50" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[92]_INST_0 
       (.I0(in2[92]),
        .I1(ctrl1),
        .I2(in3[92]),
        .O(out1[92]));
  (* SOFT_HLUTNM = "soft_lutpair50" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[93]_INST_0 
       (.I0(ctrl1),
        .I1(in2[93]),
        .I2(in3[93]),
        .O(out1[93]));
  (* SOFT_HLUTNM = "soft_lutpair51" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[94]_INST_0 
       (.I0(in2[94]),
        .I1(ctrl1),
        .I2(in3[94]),
        .O(out1[94]));
  (* SOFT_HLUTNM = "soft_lutpair51" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[95]_INST_0 
       (.I0(ctrl1),
        .I1(in2[95]),
        .I2(in3[95]),
        .O(out1[95]));
  (* SOFT_HLUTNM = "soft_lutpair52" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[96]_INST_0 
       (.I0(in2[96]),
        .I1(ctrl1),
        .I2(in3[96]),
        .O(out1[96]));
  (* SOFT_HLUTNM = "soft_lutpair52" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[97]_INST_0 
       (.I0(ctrl1),
        .I1(in2[97]),
        .I2(in3[97]),
        .O(out1[97]));
  (* SOFT_HLUTNM = "soft_lutpair53" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[98]_INST_0 
       (.I0(in2[98]),
        .I1(ctrl1),
        .I2(in3[98]),
        .O(out1[98]));
  (* SOFT_HLUTNM = "soft_lutpair53" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[99]_INST_0 
       (.I0(ctrl1),
        .I1(in2[99]),
        .I2(in3[99]),
        .O(out1[99]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[9]_INST_0 
       (.I0(ctrl1),
        .I1(in2[9]),
        .I2(in3[9]),
        .O(out1[9]));
endmodule

