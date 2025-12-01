// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
// Date        : Mon Dec  1 16:11:27 2025
// Host        : haagendazs running 64-bit Red Hat Enterprise Linux release 8.10 (Ootpa)
// Command     : write_verilog -cell inst_3 -force
//               /home/kevin/nov_submission/esp/accelerators/stratus_hls/dummy_stratus/hw/hls-work-inferred/bdw_work/modules/dummy/BASIC_DMA256/v_gates/dummy_N_MuxB_256_2_1_4.v
// Design      : dummy_N_MuxB_256_2_1_4
// Purpose     : This is a Verilog netlist of the current design or from a specific cell of the design. The output is an
//               IEEE 1364-2001 compliant Verilog HDL file that contains netlist information obtained from the input
//               design files.
// Device      : xc7v2000tflg1925-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* STRUCTURAL_NETLIST = "yes" *)
module dummy_N_MuxB_256_2_1_4
   (in3,
    in2,
    ctrl1,
    out1);
  input [255:0]in3;
  input [255:0]in2;
  input ctrl1;
  output [255:0]out1;

  wire ctrl1;
  wire [255:0]in2;
  wire [255:0]in3;
  wire [255:0]out1;

  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[0]_INST_0 
       (.I0(in2[0]),
        .I1(ctrl1),
        .I2(in3[0]),
        .O(out1[0]));
  (* SOFT_HLUTNM = "soft_lutpair53" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[100]_INST_0 
       (.I0(in2[100]),
        .I1(ctrl1),
        .I2(in3[100]),
        .O(out1[100]));
  (* SOFT_HLUTNM = "soft_lutpair53" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[101]_INST_0 
       (.I0(ctrl1),
        .I1(in2[101]),
        .I2(in3[101]),
        .O(out1[101]));
  (* SOFT_HLUTNM = "soft_lutpair54" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[102]_INST_0 
       (.I0(in2[102]),
        .I1(ctrl1),
        .I2(in3[102]),
        .O(out1[102]));
  (* SOFT_HLUTNM = "soft_lutpair54" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[103]_INST_0 
       (.I0(ctrl1),
        .I1(in2[103]),
        .I2(in3[103]),
        .O(out1[103]));
  (* SOFT_HLUTNM = "soft_lutpair55" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[104]_INST_0 
       (.I0(in2[104]),
        .I1(ctrl1),
        .I2(in3[104]),
        .O(out1[104]));
  (* SOFT_HLUTNM = "soft_lutpair55" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[105]_INST_0 
       (.I0(ctrl1),
        .I1(in2[105]),
        .I2(in3[105]),
        .O(out1[105]));
  (* SOFT_HLUTNM = "soft_lutpair56" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[106]_INST_0 
       (.I0(in2[106]),
        .I1(ctrl1),
        .I2(in3[106]),
        .O(out1[106]));
  (* SOFT_HLUTNM = "soft_lutpair56" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[107]_INST_0 
       (.I0(ctrl1),
        .I1(in2[107]),
        .I2(in3[107]),
        .O(out1[107]));
  (* SOFT_HLUTNM = "soft_lutpair57" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[108]_INST_0 
       (.I0(in2[108]),
        .I1(ctrl1),
        .I2(in3[108]),
        .O(out1[108]));
  (* SOFT_HLUTNM = "soft_lutpair57" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[109]_INST_0 
       (.I0(ctrl1),
        .I1(in2[109]),
        .I2(in3[109]),
        .O(out1[109]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[10]_INST_0 
       (.I0(in2[10]),
        .I1(ctrl1),
        .I2(in3[10]),
        .O(out1[10]));
  (* SOFT_HLUTNM = "soft_lutpair58" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[110]_INST_0 
       (.I0(in2[110]),
        .I1(ctrl1),
        .I2(in3[110]),
        .O(out1[110]));
  (* SOFT_HLUTNM = "soft_lutpair58" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[111]_INST_0 
       (.I0(ctrl1),
        .I1(in2[111]),
        .I2(in3[111]),
        .O(out1[111]));
  (* SOFT_HLUTNM = "soft_lutpair59" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[112]_INST_0 
       (.I0(in2[112]),
        .I1(ctrl1),
        .I2(in3[112]),
        .O(out1[112]));
  (* SOFT_HLUTNM = "soft_lutpair59" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[113]_INST_0 
       (.I0(ctrl1),
        .I1(in2[113]),
        .I2(in3[113]),
        .O(out1[113]));
  (* SOFT_HLUTNM = "soft_lutpair60" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[114]_INST_0 
       (.I0(in2[114]),
        .I1(ctrl1),
        .I2(in3[114]),
        .O(out1[114]));
  (* SOFT_HLUTNM = "soft_lutpair60" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[115]_INST_0 
       (.I0(ctrl1),
        .I1(in2[115]),
        .I2(in3[115]),
        .O(out1[115]));
  (* SOFT_HLUTNM = "soft_lutpair61" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[116]_INST_0 
       (.I0(in2[116]),
        .I1(ctrl1),
        .I2(in3[116]),
        .O(out1[116]));
  (* SOFT_HLUTNM = "soft_lutpair61" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[117]_INST_0 
       (.I0(ctrl1),
        .I1(in2[117]),
        .I2(in3[117]),
        .O(out1[117]));
  (* SOFT_HLUTNM = "soft_lutpair62" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[118]_INST_0 
       (.I0(in2[118]),
        .I1(ctrl1),
        .I2(in3[118]),
        .O(out1[118]));
  (* SOFT_HLUTNM = "soft_lutpair62" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[119]_INST_0 
       (.I0(ctrl1),
        .I1(in2[119]),
        .I2(in3[119]),
        .O(out1[119]));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[11]_INST_0 
       (.I0(ctrl1),
        .I1(in2[11]),
        .I2(in3[11]),
        .O(out1[11]));
  (* SOFT_HLUTNM = "soft_lutpair63" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[120]_INST_0 
       (.I0(in2[120]),
        .I1(ctrl1),
        .I2(in3[120]),
        .O(out1[120]));
  (* SOFT_HLUTNM = "soft_lutpair63" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[121]_INST_0 
       (.I0(ctrl1),
        .I1(in2[121]),
        .I2(in3[121]),
        .O(out1[121]));
  (* SOFT_HLUTNM = "soft_lutpair64" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[122]_INST_0 
       (.I0(in2[122]),
        .I1(ctrl1),
        .I2(in3[122]),
        .O(out1[122]));
  (* SOFT_HLUTNM = "soft_lutpair64" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[123]_INST_0 
       (.I0(ctrl1),
        .I1(in2[123]),
        .I2(in3[123]),
        .O(out1[123]));
  (* SOFT_HLUTNM = "soft_lutpair65" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[124]_INST_0 
       (.I0(in2[124]),
        .I1(ctrl1),
        .I2(in3[124]),
        .O(out1[124]));
  (* SOFT_HLUTNM = "soft_lutpair65" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[125]_INST_0 
       (.I0(ctrl1),
        .I1(in2[125]),
        .I2(in3[125]),
        .O(out1[125]));
  (* SOFT_HLUTNM = "soft_lutpair66" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[126]_INST_0 
       (.I0(in2[126]),
        .I1(ctrl1),
        .I2(in3[126]),
        .O(out1[126]));
  (* SOFT_HLUTNM = "soft_lutpair66" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[127]_INST_0 
       (.I0(ctrl1),
        .I1(in2[127]),
        .I2(in3[127]),
        .O(out1[127]));
  (* SOFT_HLUTNM = "soft_lutpair67" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[128]_INST_0 
       (.I0(in2[128]),
        .I1(ctrl1),
        .I2(in3[128]),
        .O(out1[128]));
  (* SOFT_HLUTNM = "soft_lutpair67" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[129]_INST_0 
       (.I0(ctrl1),
        .I1(in2[129]),
        .I2(in3[129]),
        .O(out1[129]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[12]_INST_0 
       (.I0(in2[12]),
        .I1(ctrl1),
        .I2(in3[12]),
        .O(out1[12]));
  (* SOFT_HLUTNM = "soft_lutpair68" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[130]_INST_0 
       (.I0(in2[130]),
        .I1(ctrl1),
        .I2(in3[130]),
        .O(out1[130]));
  (* SOFT_HLUTNM = "soft_lutpair68" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[131]_INST_0 
       (.I0(ctrl1),
        .I1(in2[131]),
        .I2(in3[131]),
        .O(out1[131]));
  (* SOFT_HLUTNM = "soft_lutpair69" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[132]_INST_0 
       (.I0(in2[132]),
        .I1(ctrl1),
        .I2(in3[132]),
        .O(out1[132]));
  (* SOFT_HLUTNM = "soft_lutpair69" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[133]_INST_0 
       (.I0(ctrl1),
        .I1(in2[133]),
        .I2(in3[133]),
        .O(out1[133]));
  (* SOFT_HLUTNM = "soft_lutpair70" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[134]_INST_0 
       (.I0(in2[134]),
        .I1(ctrl1),
        .I2(in3[134]),
        .O(out1[134]));
  (* SOFT_HLUTNM = "soft_lutpair70" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[135]_INST_0 
       (.I0(ctrl1),
        .I1(in2[135]),
        .I2(in3[135]),
        .O(out1[135]));
  (* SOFT_HLUTNM = "soft_lutpair71" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[136]_INST_0 
       (.I0(in2[136]),
        .I1(ctrl1),
        .I2(in3[136]),
        .O(out1[136]));
  (* SOFT_HLUTNM = "soft_lutpair71" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[137]_INST_0 
       (.I0(ctrl1),
        .I1(in2[137]),
        .I2(in3[137]),
        .O(out1[137]));
  (* SOFT_HLUTNM = "soft_lutpair72" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[138]_INST_0 
       (.I0(in2[138]),
        .I1(ctrl1),
        .I2(in3[138]),
        .O(out1[138]));
  (* SOFT_HLUTNM = "soft_lutpair72" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[139]_INST_0 
       (.I0(ctrl1),
        .I1(in2[139]),
        .I2(in3[139]),
        .O(out1[139]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[13]_INST_0 
       (.I0(ctrl1),
        .I1(in2[13]),
        .I2(in3[13]),
        .O(out1[13]));
  (* SOFT_HLUTNM = "soft_lutpair73" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[140]_INST_0 
       (.I0(in2[140]),
        .I1(ctrl1),
        .I2(in3[140]),
        .O(out1[140]));
  (* SOFT_HLUTNM = "soft_lutpair73" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[141]_INST_0 
       (.I0(ctrl1),
        .I1(in2[141]),
        .I2(in3[141]),
        .O(out1[141]));
  (* SOFT_HLUTNM = "soft_lutpair74" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[142]_INST_0 
       (.I0(in2[142]),
        .I1(ctrl1),
        .I2(in3[142]),
        .O(out1[142]));
  (* SOFT_HLUTNM = "soft_lutpair74" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[143]_INST_0 
       (.I0(ctrl1),
        .I1(in2[143]),
        .I2(in3[143]),
        .O(out1[143]));
  (* SOFT_HLUTNM = "soft_lutpair75" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[144]_INST_0 
       (.I0(in2[144]),
        .I1(ctrl1),
        .I2(in3[144]),
        .O(out1[144]));
  (* SOFT_HLUTNM = "soft_lutpair75" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[145]_INST_0 
       (.I0(ctrl1),
        .I1(in2[145]),
        .I2(in3[145]),
        .O(out1[145]));
  (* SOFT_HLUTNM = "soft_lutpair76" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[146]_INST_0 
       (.I0(in2[146]),
        .I1(ctrl1),
        .I2(in3[146]),
        .O(out1[146]));
  (* SOFT_HLUTNM = "soft_lutpair76" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[147]_INST_0 
       (.I0(ctrl1),
        .I1(in2[147]),
        .I2(in3[147]),
        .O(out1[147]));
  (* SOFT_HLUTNM = "soft_lutpair77" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[148]_INST_0 
       (.I0(in2[148]),
        .I1(ctrl1),
        .I2(in3[148]),
        .O(out1[148]));
  (* SOFT_HLUTNM = "soft_lutpair77" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[149]_INST_0 
       (.I0(ctrl1),
        .I1(in2[149]),
        .I2(in3[149]),
        .O(out1[149]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[14]_INST_0 
       (.I0(in2[14]),
        .I1(ctrl1),
        .I2(in3[14]),
        .O(out1[14]));
  (* SOFT_HLUTNM = "soft_lutpair78" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[150]_INST_0 
       (.I0(in2[150]),
        .I1(ctrl1),
        .I2(in3[150]),
        .O(out1[150]));
  (* SOFT_HLUTNM = "soft_lutpair78" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[151]_INST_0 
       (.I0(ctrl1),
        .I1(in2[151]),
        .I2(in3[151]),
        .O(out1[151]));
  (* SOFT_HLUTNM = "soft_lutpair79" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[152]_INST_0 
       (.I0(in2[152]),
        .I1(ctrl1),
        .I2(in3[152]),
        .O(out1[152]));
  (* SOFT_HLUTNM = "soft_lutpair79" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[153]_INST_0 
       (.I0(ctrl1),
        .I1(in2[153]),
        .I2(in3[153]),
        .O(out1[153]));
  (* SOFT_HLUTNM = "soft_lutpair80" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[154]_INST_0 
       (.I0(in2[154]),
        .I1(ctrl1),
        .I2(in3[154]),
        .O(out1[154]));
  (* SOFT_HLUTNM = "soft_lutpair80" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[155]_INST_0 
       (.I0(ctrl1),
        .I1(in2[155]),
        .I2(in3[155]),
        .O(out1[155]));
  (* SOFT_HLUTNM = "soft_lutpair81" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[156]_INST_0 
       (.I0(in2[156]),
        .I1(ctrl1),
        .I2(in3[156]),
        .O(out1[156]));
  (* SOFT_HLUTNM = "soft_lutpair81" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[157]_INST_0 
       (.I0(ctrl1),
        .I1(in2[157]),
        .I2(in3[157]),
        .O(out1[157]));
  (* SOFT_HLUTNM = "soft_lutpair82" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[158]_INST_0 
       (.I0(in2[158]),
        .I1(ctrl1),
        .I2(in3[158]),
        .O(out1[158]));
  (* SOFT_HLUTNM = "soft_lutpair82" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[159]_INST_0 
       (.I0(ctrl1),
        .I1(in2[159]),
        .I2(in3[159]),
        .O(out1[159]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[15]_INST_0 
       (.I0(ctrl1),
        .I1(in2[15]),
        .I2(in3[15]),
        .O(out1[15]));
  (* SOFT_HLUTNM = "soft_lutpair83" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[160]_INST_0 
       (.I0(in2[160]),
        .I1(ctrl1),
        .I2(in3[160]),
        .O(out1[160]));
  (* SOFT_HLUTNM = "soft_lutpair83" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[161]_INST_0 
       (.I0(ctrl1),
        .I1(in2[161]),
        .I2(in3[161]),
        .O(out1[161]));
  (* SOFT_HLUTNM = "soft_lutpair84" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[162]_INST_0 
       (.I0(in2[162]),
        .I1(ctrl1),
        .I2(in3[162]),
        .O(out1[162]));
  (* SOFT_HLUTNM = "soft_lutpair84" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[163]_INST_0 
       (.I0(ctrl1),
        .I1(in2[163]),
        .I2(in3[163]),
        .O(out1[163]));
  (* SOFT_HLUTNM = "soft_lutpair85" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[164]_INST_0 
       (.I0(in2[164]),
        .I1(ctrl1),
        .I2(in3[164]),
        .O(out1[164]));
  (* SOFT_HLUTNM = "soft_lutpair85" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[165]_INST_0 
       (.I0(ctrl1),
        .I1(in2[165]),
        .I2(in3[165]),
        .O(out1[165]));
  (* SOFT_HLUTNM = "soft_lutpair86" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[166]_INST_0 
       (.I0(in2[166]),
        .I1(ctrl1),
        .I2(in3[166]),
        .O(out1[166]));
  (* SOFT_HLUTNM = "soft_lutpair86" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[167]_INST_0 
       (.I0(ctrl1),
        .I1(in2[167]),
        .I2(in3[167]),
        .O(out1[167]));
  (* SOFT_HLUTNM = "soft_lutpair87" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[168]_INST_0 
       (.I0(in2[168]),
        .I1(ctrl1),
        .I2(in3[168]),
        .O(out1[168]));
  (* SOFT_HLUTNM = "soft_lutpair87" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[169]_INST_0 
       (.I0(ctrl1),
        .I1(in2[169]),
        .I2(in3[169]),
        .O(out1[169]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[16]_INST_0 
       (.I0(in2[16]),
        .I1(ctrl1),
        .I2(in3[16]),
        .O(out1[16]));
  (* SOFT_HLUTNM = "soft_lutpair88" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[170]_INST_0 
       (.I0(in2[170]),
        .I1(ctrl1),
        .I2(in3[170]),
        .O(out1[170]));
  (* SOFT_HLUTNM = "soft_lutpair88" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[171]_INST_0 
       (.I0(ctrl1),
        .I1(in2[171]),
        .I2(in3[171]),
        .O(out1[171]));
  (* SOFT_HLUTNM = "soft_lutpair89" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[172]_INST_0 
       (.I0(in2[172]),
        .I1(ctrl1),
        .I2(in3[172]),
        .O(out1[172]));
  (* SOFT_HLUTNM = "soft_lutpair89" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[173]_INST_0 
       (.I0(ctrl1),
        .I1(in2[173]),
        .I2(in3[173]),
        .O(out1[173]));
  (* SOFT_HLUTNM = "soft_lutpair90" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[174]_INST_0 
       (.I0(in2[174]),
        .I1(ctrl1),
        .I2(in3[174]),
        .O(out1[174]));
  (* SOFT_HLUTNM = "soft_lutpair90" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[175]_INST_0 
       (.I0(ctrl1),
        .I1(in2[175]),
        .I2(in3[175]),
        .O(out1[175]));
  (* SOFT_HLUTNM = "soft_lutpair91" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[176]_INST_0 
       (.I0(in2[176]),
        .I1(ctrl1),
        .I2(in3[176]),
        .O(out1[176]));
  (* SOFT_HLUTNM = "soft_lutpair91" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[177]_INST_0 
       (.I0(ctrl1),
        .I1(in2[177]),
        .I2(in3[177]),
        .O(out1[177]));
  (* SOFT_HLUTNM = "soft_lutpair92" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[178]_INST_0 
       (.I0(in2[178]),
        .I1(ctrl1),
        .I2(in3[178]),
        .O(out1[178]));
  (* SOFT_HLUTNM = "soft_lutpair92" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[179]_INST_0 
       (.I0(ctrl1),
        .I1(in2[179]),
        .I2(in3[179]),
        .O(out1[179]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[17]_INST_0 
       (.I0(ctrl1),
        .I1(in2[17]),
        .I2(in3[17]),
        .O(out1[17]));
  (* SOFT_HLUTNM = "soft_lutpair93" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[180]_INST_0 
       (.I0(in2[180]),
        .I1(ctrl1),
        .I2(in3[180]),
        .O(out1[180]));
  (* SOFT_HLUTNM = "soft_lutpair93" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[181]_INST_0 
       (.I0(ctrl1),
        .I1(in2[181]),
        .I2(in3[181]),
        .O(out1[181]));
  (* SOFT_HLUTNM = "soft_lutpair94" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[182]_INST_0 
       (.I0(in2[182]),
        .I1(ctrl1),
        .I2(in3[182]),
        .O(out1[182]));
  (* SOFT_HLUTNM = "soft_lutpair94" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[183]_INST_0 
       (.I0(ctrl1),
        .I1(in2[183]),
        .I2(in3[183]),
        .O(out1[183]));
  (* SOFT_HLUTNM = "soft_lutpair95" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[184]_INST_0 
       (.I0(in2[184]),
        .I1(ctrl1),
        .I2(in3[184]),
        .O(out1[184]));
  (* SOFT_HLUTNM = "soft_lutpair95" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[185]_INST_0 
       (.I0(ctrl1),
        .I1(in2[185]),
        .I2(in3[185]),
        .O(out1[185]));
  (* SOFT_HLUTNM = "soft_lutpair96" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[186]_INST_0 
       (.I0(in2[186]),
        .I1(ctrl1),
        .I2(in3[186]),
        .O(out1[186]));
  (* SOFT_HLUTNM = "soft_lutpair96" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[187]_INST_0 
       (.I0(ctrl1),
        .I1(in2[187]),
        .I2(in3[187]),
        .O(out1[187]));
  (* SOFT_HLUTNM = "soft_lutpair97" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[188]_INST_0 
       (.I0(in2[188]),
        .I1(ctrl1),
        .I2(in3[188]),
        .O(out1[188]));
  (* SOFT_HLUTNM = "soft_lutpair97" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[189]_INST_0 
       (.I0(ctrl1),
        .I1(in2[189]),
        .I2(in3[189]),
        .O(out1[189]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[18]_INST_0 
       (.I0(in2[18]),
        .I1(ctrl1),
        .I2(in3[18]),
        .O(out1[18]));
  (* SOFT_HLUTNM = "soft_lutpair98" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[190]_INST_0 
       (.I0(in2[190]),
        .I1(ctrl1),
        .I2(in3[190]),
        .O(out1[190]));
  (* SOFT_HLUTNM = "soft_lutpair98" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[191]_INST_0 
       (.I0(ctrl1),
        .I1(in2[191]),
        .I2(in3[191]),
        .O(out1[191]));
  (* SOFT_HLUTNM = "soft_lutpair99" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[192]_INST_0 
       (.I0(in2[192]),
        .I1(ctrl1),
        .I2(in3[192]),
        .O(out1[192]));
  (* SOFT_HLUTNM = "soft_lutpair99" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[193]_INST_0 
       (.I0(ctrl1),
        .I1(in2[193]),
        .I2(in3[193]),
        .O(out1[193]));
  (* SOFT_HLUTNM = "soft_lutpair100" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[194]_INST_0 
       (.I0(in2[194]),
        .I1(ctrl1),
        .I2(in3[194]),
        .O(out1[194]));
  (* SOFT_HLUTNM = "soft_lutpair100" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[195]_INST_0 
       (.I0(ctrl1),
        .I1(in2[195]),
        .I2(in3[195]),
        .O(out1[195]));
  (* SOFT_HLUTNM = "soft_lutpair101" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[196]_INST_0 
       (.I0(in2[196]),
        .I1(ctrl1),
        .I2(in3[196]),
        .O(out1[196]));
  (* SOFT_HLUTNM = "soft_lutpair101" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[197]_INST_0 
       (.I0(ctrl1),
        .I1(in2[197]),
        .I2(in3[197]),
        .O(out1[197]));
  (* SOFT_HLUTNM = "soft_lutpair102" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[198]_INST_0 
       (.I0(in2[198]),
        .I1(ctrl1),
        .I2(in3[198]),
        .O(out1[198]));
  (* SOFT_HLUTNM = "soft_lutpair102" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[199]_INST_0 
       (.I0(ctrl1),
        .I1(in2[199]),
        .I2(in3[199]),
        .O(out1[199]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[19]_INST_0 
       (.I0(ctrl1),
        .I1(in2[19]),
        .I2(in3[19]),
        .O(out1[19]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[1]_INST_0 
       (.I0(ctrl1),
        .I1(in2[1]),
        .I2(in3[1]),
        .O(out1[1]));
  (* SOFT_HLUTNM = "soft_lutpair103" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[200]_INST_0 
       (.I0(in2[200]),
        .I1(ctrl1),
        .I2(in3[200]),
        .O(out1[200]));
  (* SOFT_HLUTNM = "soft_lutpair103" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[201]_INST_0 
       (.I0(ctrl1),
        .I1(in2[201]),
        .I2(in3[201]),
        .O(out1[201]));
  (* SOFT_HLUTNM = "soft_lutpair104" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[202]_INST_0 
       (.I0(in2[202]),
        .I1(ctrl1),
        .I2(in3[202]),
        .O(out1[202]));
  (* SOFT_HLUTNM = "soft_lutpair104" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[203]_INST_0 
       (.I0(ctrl1),
        .I1(in2[203]),
        .I2(in3[203]),
        .O(out1[203]));
  (* SOFT_HLUTNM = "soft_lutpair105" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[204]_INST_0 
       (.I0(in2[204]),
        .I1(ctrl1),
        .I2(in3[204]),
        .O(out1[204]));
  (* SOFT_HLUTNM = "soft_lutpair105" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[205]_INST_0 
       (.I0(ctrl1),
        .I1(in2[205]),
        .I2(in3[205]),
        .O(out1[205]));
  (* SOFT_HLUTNM = "soft_lutpair106" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[206]_INST_0 
       (.I0(in2[206]),
        .I1(ctrl1),
        .I2(in3[206]),
        .O(out1[206]));
  (* SOFT_HLUTNM = "soft_lutpair106" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[207]_INST_0 
       (.I0(ctrl1),
        .I1(in2[207]),
        .I2(in3[207]),
        .O(out1[207]));
  (* SOFT_HLUTNM = "soft_lutpair107" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[208]_INST_0 
       (.I0(in2[208]),
        .I1(ctrl1),
        .I2(in3[208]),
        .O(out1[208]));
  (* SOFT_HLUTNM = "soft_lutpair107" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[209]_INST_0 
       (.I0(ctrl1),
        .I1(in2[209]),
        .I2(in3[209]),
        .O(out1[209]));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[20]_INST_0 
       (.I0(in2[20]),
        .I1(ctrl1),
        .I2(in3[20]),
        .O(out1[20]));
  (* SOFT_HLUTNM = "soft_lutpair108" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[210]_INST_0 
       (.I0(in2[210]),
        .I1(ctrl1),
        .I2(in3[210]),
        .O(out1[210]));
  (* SOFT_HLUTNM = "soft_lutpair108" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[211]_INST_0 
       (.I0(ctrl1),
        .I1(in2[211]),
        .I2(in3[211]),
        .O(out1[211]));
  (* SOFT_HLUTNM = "soft_lutpair109" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[212]_INST_0 
       (.I0(in2[212]),
        .I1(ctrl1),
        .I2(in3[212]),
        .O(out1[212]));
  (* SOFT_HLUTNM = "soft_lutpair109" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[213]_INST_0 
       (.I0(ctrl1),
        .I1(in2[213]),
        .I2(in3[213]),
        .O(out1[213]));
  (* SOFT_HLUTNM = "soft_lutpair110" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[214]_INST_0 
       (.I0(in2[214]),
        .I1(ctrl1),
        .I2(in3[214]),
        .O(out1[214]));
  (* SOFT_HLUTNM = "soft_lutpair110" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[215]_INST_0 
       (.I0(ctrl1),
        .I1(in2[215]),
        .I2(in3[215]),
        .O(out1[215]));
  (* SOFT_HLUTNM = "soft_lutpair111" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[216]_INST_0 
       (.I0(in2[216]),
        .I1(ctrl1),
        .I2(in3[216]),
        .O(out1[216]));
  (* SOFT_HLUTNM = "soft_lutpair111" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[217]_INST_0 
       (.I0(ctrl1),
        .I1(in2[217]),
        .I2(in3[217]),
        .O(out1[217]));
  (* SOFT_HLUTNM = "soft_lutpair112" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[218]_INST_0 
       (.I0(in2[218]),
        .I1(ctrl1),
        .I2(in3[218]),
        .O(out1[218]));
  (* SOFT_HLUTNM = "soft_lutpair112" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[219]_INST_0 
       (.I0(ctrl1),
        .I1(in2[219]),
        .I2(in3[219]),
        .O(out1[219]));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[21]_INST_0 
       (.I0(ctrl1),
        .I1(in2[21]),
        .I2(in3[21]),
        .O(out1[21]));
  (* SOFT_HLUTNM = "soft_lutpair113" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[220]_INST_0 
       (.I0(in2[220]),
        .I1(ctrl1),
        .I2(in3[220]),
        .O(out1[220]));
  (* SOFT_HLUTNM = "soft_lutpair113" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[221]_INST_0 
       (.I0(ctrl1),
        .I1(in2[221]),
        .I2(in3[221]),
        .O(out1[221]));
  (* SOFT_HLUTNM = "soft_lutpair114" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[222]_INST_0 
       (.I0(in2[222]),
        .I1(ctrl1),
        .I2(in3[222]),
        .O(out1[222]));
  (* SOFT_HLUTNM = "soft_lutpair114" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[223]_INST_0 
       (.I0(ctrl1),
        .I1(in2[223]),
        .I2(in3[223]),
        .O(out1[223]));
  (* SOFT_HLUTNM = "soft_lutpair115" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[224]_INST_0 
       (.I0(in2[224]),
        .I1(ctrl1),
        .I2(in3[224]),
        .O(out1[224]));
  (* SOFT_HLUTNM = "soft_lutpair115" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[225]_INST_0 
       (.I0(ctrl1),
        .I1(in2[225]),
        .I2(in3[225]),
        .O(out1[225]));
  (* SOFT_HLUTNM = "soft_lutpair116" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[226]_INST_0 
       (.I0(in2[226]),
        .I1(ctrl1),
        .I2(in3[226]),
        .O(out1[226]));
  (* SOFT_HLUTNM = "soft_lutpair116" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[227]_INST_0 
       (.I0(ctrl1),
        .I1(in2[227]),
        .I2(in3[227]),
        .O(out1[227]));
  (* SOFT_HLUTNM = "soft_lutpair117" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[228]_INST_0 
       (.I0(in2[228]),
        .I1(ctrl1),
        .I2(in3[228]),
        .O(out1[228]));
  (* SOFT_HLUTNM = "soft_lutpair117" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[229]_INST_0 
       (.I0(ctrl1),
        .I1(in2[229]),
        .I2(in3[229]),
        .O(out1[229]));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[22]_INST_0 
       (.I0(in2[22]),
        .I1(ctrl1),
        .I2(in3[22]),
        .O(out1[22]));
  (* SOFT_HLUTNM = "soft_lutpair118" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[230]_INST_0 
       (.I0(in2[230]),
        .I1(ctrl1),
        .I2(in3[230]),
        .O(out1[230]));
  (* SOFT_HLUTNM = "soft_lutpair118" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[231]_INST_0 
       (.I0(ctrl1),
        .I1(in2[231]),
        .I2(in3[231]),
        .O(out1[231]));
  (* SOFT_HLUTNM = "soft_lutpair119" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[232]_INST_0 
       (.I0(in2[232]),
        .I1(ctrl1),
        .I2(in3[232]),
        .O(out1[232]));
  (* SOFT_HLUTNM = "soft_lutpair119" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[233]_INST_0 
       (.I0(ctrl1),
        .I1(in2[233]),
        .I2(in3[233]),
        .O(out1[233]));
  (* SOFT_HLUTNM = "soft_lutpair120" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[234]_INST_0 
       (.I0(in2[234]),
        .I1(ctrl1),
        .I2(in3[234]),
        .O(out1[234]));
  (* SOFT_HLUTNM = "soft_lutpair120" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[235]_INST_0 
       (.I0(ctrl1),
        .I1(in2[235]),
        .I2(in3[235]),
        .O(out1[235]));
  (* SOFT_HLUTNM = "soft_lutpair121" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[236]_INST_0 
       (.I0(in2[236]),
        .I1(ctrl1),
        .I2(in3[236]),
        .O(out1[236]));
  (* SOFT_HLUTNM = "soft_lutpair121" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[237]_INST_0 
       (.I0(ctrl1),
        .I1(in2[237]),
        .I2(in3[237]),
        .O(out1[237]));
  (* SOFT_HLUTNM = "soft_lutpair122" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[238]_INST_0 
       (.I0(in2[238]),
        .I1(ctrl1),
        .I2(in3[238]),
        .O(out1[238]));
  (* SOFT_HLUTNM = "soft_lutpair122" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[239]_INST_0 
       (.I0(ctrl1),
        .I1(in2[239]),
        .I2(in3[239]),
        .O(out1[239]));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[23]_INST_0 
       (.I0(ctrl1),
        .I1(in2[23]),
        .I2(in3[23]),
        .O(out1[23]));
  (* SOFT_HLUTNM = "soft_lutpair123" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[240]_INST_0 
       (.I0(in2[240]),
        .I1(ctrl1),
        .I2(in3[240]),
        .O(out1[240]));
  (* SOFT_HLUTNM = "soft_lutpair123" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[241]_INST_0 
       (.I0(ctrl1),
        .I1(in2[241]),
        .I2(in3[241]),
        .O(out1[241]));
  (* SOFT_HLUTNM = "soft_lutpair124" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[242]_INST_0 
       (.I0(in2[242]),
        .I1(ctrl1),
        .I2(in3[242]),
        .O(out1[242]));
  (* SOFT_HLUTNM = "soft_lutpair124" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[243]_INST_0 
       (.I0(ctrl1),
        .I1(in2[243]),
        .I2(in3[243]),
        .O(out1[243]));
  (* SOFT_HLUTNM = "soft_lutpair125" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[244]_INST_0 
       (.I0(in2[244]),
        .I1(ctrl1),
        .I2(in3[244]),
        .O(out1[244]));
  (* SOFT_HLUTNM = "soft_lutpair125" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[245]_INST_0 
       (.I0(ctrl1),
        .I1(in2[245]),
        .I2(in3[245]),
        .O(out1[245]));
  (* SOFT_HLUTNM = "soft_lutpair126" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[246]_INST_0 
       (.I0(in2[246]),
        .I1(ctrl1),
        .I2(in3[246]),
        .O(out1[246]));
  (* SOFT_HLUTNM = "soft_lutpair126" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[247]_INST_0 
       (.I0(ctrl1),
        .I1(in2[247]),
        .I2(in3[247]),
        .O(out1[247]));
  (* SOFT_HLUTNM = "soft_lutpair127" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[248]_INST_0 
       (.I0(in2[248]),
        .I1(ctrl1),
        .I2(in3[248]),
        .O(out1[248]));
  (* SOFT_HLUTNM = "soft_lutpair127" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[249]_INST_0 
       (.I0(ctrl1),
        .I1(in2[249]),
        .I2(in3[249]),
        .O(out1[249]));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[24]_INST_0 
       (.I0(in2[24]),
        .I1(ctrl1),
        .I2(in3[24]),
        .O(out1[24]));
  (* SOFT_HLUTNM = "soft_lutpair128" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[250]_INST_0 
       (.I0(in2[250]),
        .I1(ctrl1),
        .I2(in3[250]),
        .O(out1[250]));
  (* SOFT_HLUTNM = "soft_lutpair128" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[251]_INST_0 
       (.I0(ctrl1),
        .I1(in2[251]),
        .I2(in3[251]),
        .O(out1[251]));
  (* SOFT_HLUTNM = "soft_lutpair129" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[252]_INST_0 
       (.I0(in2[252]),
        .I1(ctrl1),
        .I2(in3[252]),
        .O(out1[252]));
  (* SOFT_HLUTNM = "soft_lutpair129" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[253]_INST_0 
       (.I0(ctrl1),
        .I1(in2[253]),
        .I2(in3[253]),
        .O(out1[253]));
  (* SOFT_HLUTNM = "soft_lutpair130" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[254]_INST_0 
       (.I0(in2[254]),
        .I1(ctrl1),
        .I2(in3[254]),
        .O(out1[254]));
  (* SOFT_HLUTNM = "soft_lutpair130" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[255]_INST_0 
       (.I0(ctrl1),
        .I1(in2[255]),
        .I2(in3[255]),
        .O(out1[255]));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[25]_INST_0 
       (.I0(ctrl1),
        .I1(in2[25]),
        .I2(in3[25]),
        .O(out1[25]));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[26]_INST_0 
       (.I0(in2[26]),
        .I1(ctrl1),
        .I2(in3[26]),
        .O(out1[26]));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[27]_INST_0 
       (.I0(ctrl1),
        .I1(in2[27]),
        .I2(in3[27]),
        .O(out1[27]));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[28]_INST_0 
       (.I0(in2[28]),
        .I1(ctrl1),
        .I2(in3[28]),
        .O(out1[28]));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[29]_INST_0 
       (.I0(ctrl1),
        .I1(in2[29]),
        .I2(in3[29]),
        .O(out1[29]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[2]_INST_0 
       (.I0(in2[2]),
        .I1(ctrl1),
        .I2(in3[2]),
        .O(out1[2]));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[30]_INST_0 
       (.I0(in2[30]),
        .I1(ctrl1),
        .I2(in3[30]),
        .O(out1[30]));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[31]_INST_0 
       (.I0(ctrl1),
        .I1(in2[31]),
        .I2(in3[31]),
        .O(out1[31]));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[32]_INST_0 
       (.I0(in2[32]),
        .I1(ctrl1),
        .I2(in3[32]),
        .O(out1[32]));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[33]_INST_0 
       (.I0(ctrl1),
        .I1(in2[33]),
        .I2(in3[33]),
        .O(out1[33]));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[34]_INST_0 
       (.I0(in2[34]),
        .I1(ctrl1),
        .I2(in3[34]),
        .O(out1[34]));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[35]_INST_0 
       (.I0(ctrl1),
        .I1(in2[35]),
        .I2(in3[35]),
        .O(out1[35]));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[36]_INST_0 
       (.I0(in2[36]),
        .I1(ctrl1),
        .I2(in3[36]),
        .O(out1[36]));
  (* SOFT_HLUTNM = "soft_lutpair21" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[37]_INST_0 
       (.I0(ctrl1),
        .I1(in2[37]),
        .I2(in3[37]),
        .O(out1[37]));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[38]_INST_0 
       (.I0(in2[38]),
        .I1(ctrl1),
        .I2(in3[38]),
        .O(out1[38]));
  (* SOFT_HLUTNM = "soft_lutpair22" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[39]_INST_0 
       (.I0(ctrl1),
        .I1(in2[39]),
        .I2(in3[39]),
        .O(out1[39]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[3]_INST_0 
       (.I0(ctrl1),
        .I1(in2[3]),
        .I2(in3[3]),
        .O(out1[3]));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[40]_INST_0 
       (.I0(in2[40]),
        .I1(ctrl1),
        .I2(in3[40]),
        .O(out1[40]));
  (* SOFT_HLUTNM = "soft_lutpair23" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[41]_INST_0 
       (.I0(ctrl1),
        .I1(in2[41]),
        .I2(in3[41]),
        .O(out1[41]));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[42]_INST_0 
       (.I0(in2[42]),
        .I1(ctrl1),
        .I2(in3[42]),
        .O(out1[42]));
  (* SOFT_HLUTNM = "soft_lutpair24" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[43]_INST_0 
       (.I0(ctrl1),
        .I1(in2[43]),
        .I2(in3[43]),
        .O(out1[43]));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[44]_INST_0 
       (.I0(in2[44]),
        .I1(ctrl1),
        .I2(in3[44]),
        .O(out1[44]));
  (* SOFT_HLUTNM = "soft_lutpair25" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[45]_INST_0 
       (.I0(ctrl1),
        .I1(in2[45]),
        .I2(in3[45]),
        .O(out1[45]));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[46]_INST_0 
       (.I0(in2[46]),
        .I1(ctrl1),
        .I2(in3[46]),
        .O(out1[46]));
  (* SOFT_HLUTNM = "soft_lutpair26" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[47]_INST_0 
       (.I0(ctrl1),
        .I1(in2[47]),
        .I2(in3[47]),
        .O(out1[47]));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[48]_INST_0 
       (.I0(in2[48]),
        .I1(ctrl1),
        .I2(in3[48]),
        .O(out1[48]));
  (* SOFT_HLUTNM = "soft_lutpair27" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[49]_INST_0 
       (.I0(ctrl1),
        .I1(in2[49]),
        .I2(in3[49]),
        .O(out1[49]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[4]_INST_0 
       (.I0(in2[4]),
        .I1(ctrl1),
        .I2(in3[4]),
        .O(out1[4]));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[50]_INST_0 
       (.I0(in2[50]),
        .I1(ctrl1),
        .I2(in3[50]),
        .O(out1[50]));
  (* SOFT_HLUTNM = "soft_lutpair28" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[51]_INST_0 
       (.I0(ctrl1),
        .I1(in2[51]),
        .I2(in3[51]),
        .O(out1[51]));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[52]_INST_0 
       (.I0(in2[52]),
        .I1(ctrl1),
        .I2(in3[52]),
        .O(out1[52]));
  (* SOFT_HLUTNM = "soft_lutpair29" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[53]_INST_0 
       (.I0(ctrl1),
        .I1(in2[53]),
        .I2(in3[53]),
        .O(out1[53]));
  (* SOFT_HLUTNM = "soft_lutpair30" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[54]_INST_0 
       (.I0(in2[54]),
        .I1(ctrl1),
        .I2(in3[54]),
        .O(out1[54]));
  (* SOFT_HLUTNM = "soft_lutpair30" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[55]_INST_0 
       (.I0(ctrl1),
        .I1(in2[55]),
        .I2(in3[55]),
        .O(out1[55]));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[56]_INST_0 
       (.I0(in2[56]),
        .I1(ctrl1),
        .I2(in3[56]),
        .O(out1[56]));
  (* SOFT_HLUTNM = "soft_lutpair31" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[57]_INST_0 
       (.I0(ctrl1),
        .I1(in2[57]),
        .I2(in3[57]),
        .O(out1[57]));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[58]_INST_0 
       (.I0(in2[58]),
        .I1(ctrl1),
        .I2(in3[58]),
        .O(out1[58]));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[59]_INST_0 
       (.I0(ctrl1),
        .I1(in2[59]),
        .I2(in3[59]),
        .O(out1[59]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[5]_INST_0 
       (.I0(ctrl1),
        .I1(in2[5]),
        .I2(in3[5]),
        .O(out1[5]));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[60]_INST_0 
       (.I0(in2[60]),
        .I1(ctrl1),
        .I2(in3[60]),
        .O(out1[60]));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[61]_INST_0 
       (.I0(ctrl1),
        .I1(in2[61]),
        .I2(in3[61]),
        .O(out1[61]));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[62]_INST_0 
       (.I0(in2[62]),
        .I1(ctrl1),
        .I2(in3[62]),
        .O(out1[62]));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[63]_INST_0 
       (.I0(ctrl1),
        .I1(in2[63]),
        .I2(in3[63]),
        .O(out1[63]));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[64]_INST_0 
       (.I0(in2[64]),
        .I1(ctrl1),
        .I2(in3[64]),
        .O(out1[64]));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[65]_INST_0 
       (.I0(ctrl1),
        .I1(in2[65]),
        .I2(in3[65]),
        .O(out1[65]));
  (* SOFT_HLUTNM = "soft_lutpair36" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[66]_INST_0 
       (.I0(in2[66]),
        .I1(ctrl1),
        .I2(in3[66]),
        .O(out1[66]));
  (* SOFT_HLUTNM = "soft_lutpair36" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[67]_INST_0 
       (.I0(ctrl1),
        .I1(in2[67]),
        .I2(in3[67]),
        .O(out1[67]));
  (* SOFT_HLUTNM = "soft_lutpair37" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[68]_INST_0 
       (.I0(in2[68]),
        .I1(ctrl1),
        .I2(in3[68]),
        .O(out1[68]));
  (* SOFT_HLUTNM = "soft_lutpair37" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[69]_INST_0 
       (.I0(ctrl1),
        .I1(in2[69]),
        .I2(in3[69]),
        .O(out1[69]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[6]_INST_0 
       (.I0(in2[6]),
        .I1(ctrl1),
        .I2(in3[6]),
        .O(out1[6]));
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[70]_INST_0 
       (.I0(in2[70]),
        .I1(ctrl1),
        .I2(in3[70]),
        .O(out1[70]));
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[71]_INST_0 
       (.I0(ctrl1),
        .I1(in2[71]),
        .I2(in3[71]),
        .O(out1[71]));
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[72]_INST_0 
       (.I0(in2[72]),
        .I1(ctrl1),
        .I2(in3[72]),
        .O(out1[72]));
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[73]_INST_0 
       (.I0(ctrl1),
        .I1(in2[73]),
        .I2(in3[73]),
        .O(out1[73]));
  (* SOFT_HLUTNM = "soft_lutpair40" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[74]_INST_0 
       (.I0(in2[74]),
        .I1(ctrl1),
        .I2(in3[74]),
        .O(out1[74]));
  (* SOFT_HLUTNM = "soft_lutpair40" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[75]_INST_0 
       (.I0(ctrl1),
        .I1(in2[75]),
        .I2(in3[75]),
        .O(out1[75]));
  (* SOFT_HLUTNM = "soft_lutpair41" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[76]_INST_0 
       (.I0(in2[76]),
        .I1(ctrl1),
        .I2(in3[76]),
        .O(out1[76]));
  (* SOFT_HLUTNM = "soft_lutpair41" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[77]_INST_0 
       (.I0(ctrl1),
        .I1(in2[77]),
        .I2(in3[77]),
        .O(out1[77]));
  (* SOFT_HLUTNM = "soft_lutpair42" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[78]_INST_0 
       (.I0(in2[78]),
        .I1(ctrl1),
        .I2(in3[78]),
        .O(out1[78]));
  (* SOFT_HLUTNM = "soft_lutpair42" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[79]_INST_0 
       (.I0(ctrl1),
        .I1(in2[79]),
        .I2(in3[79]),
        .O(out1[79]));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[7]_INST_0 
       (.I0(ctrl1),
        .I1(in2[7]),
        .I2(in3[7]),
        .O(out1[7]));
  (* SOFT_HLUTNM = "soft_lutpair43" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[80]_INST_0 
       (.I0(in2[80]),
        .I1(ctrl1),
        .I2(in3[80]),
        .O(out1[80]));
  (* SOFT_HLUTNM = "soft_lutpair43" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[81]_INST_0 
       (.I0(ctrl1),
        .I1(in2[81]),
        .I2(in3[81]),
        .O(out1[81]));
  (* SOFT_HLUTNM = "soft_lutpair44" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[82]_INST_0 
       (.I0(in2[82]),
        .I1(ctrl1),
        .I2(in3[82]),
        .O(out1[82]));
  (* SOFT_HLUTNM = "soft_lutpair44" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[83]_INST_0 
       (.I0(ctrl1),
        .I1(in2[83]),
        .I2(in3[83]),
        .O(out1[83]));
  (* SOFT_HLUTNM = "soft_lutpair45" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[84]_INST_0 
       (.I0(in2[84]),
        .I1(ctrl1),
        .I2(in3[84]),
        .O(out1[84]));
  (* SOFT_HLUTNM = "soft_lutpair45" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[85]_INST_0 
       (.I0(ctrl1),
        .I1(in2[85]),
        .I2(in3[85]),
        .O(out1[85]));
  (* SOFT_HLUTNM = "soft_lutpair46" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[86]_INST_0 
       (.I0(in2[86]),
        .I1(ctrl1),
        .I2(in3[86]),
        .O(out1[86]));
  (* SOFT_HLUTNM = "soft_lutpair46" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[87]_INST_0 
       (.I0(ctrl1),
        .I1(in2[87]),
        .I2(in3[87]),
        .O(out1[87]));
  (* SOFT_HLUTNM = "soft_lutpair47" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[88]_INST_0 
       (.I0(in2[88]),
        .I1(ctrl1),
        .I2(in3[88]),
        .O(out1[88]));
  (* SOFT_HLUTNM = "soft_lutpair47" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[89]_INST_0 
       (.I0(ctrl1),
        .I1(in2[89]),
        .I2(in3[89]),
        .O(out1[89]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[8]_INST_0 
       (.I0(in2[8]),
        .I1(ctrl1),
        .I2(in3[8]),
        .O(out1[8]));
  (* SOFT_HLUTNM = "soft_lutpair48" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[90]_INST_0 
       (.I0(in2[90]),
        .I1(ctrl1),
        .I2(in3[90]),
        .O(out1[90]));
  (* SOFT_HLUTNM = "soft_lutpair48" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[91]_INST_0 
       (.I0(ctrl1),
        .I1(in2[91]),
        .I2(in3[91]),
        .O(out1[91]));
  (* SOFT_HLUTNM = "soft_lutpair49" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[92]_INST_0 
       (.I0(in2[92]),
        .I1(ctrl1),
        .I2(in3[92]),
        .O(out1[92]));
  (* SOFT_HLUTNM = "soft_lutpair49" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[93]_INST_0 
       (.I0(ctrl1),
        .I1(in2[93]),
        .I2(in3[93]),
        .O(out1[93]));
  (* SOFT_HLUTNM = "soft_lutpair50" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[94]_INST_0 
       (.I0(in2[94]),
        .I1(ctrl1),
        .I2(in3[94]),
        .O(out1[94]));
  (* SOFT_HLUTNM = "soft_lutpair50" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[95]_INST_0 
       (.I0(ctrl1),
        .I1(in2[95]),
        .I2(in3[95]),
        .O(out1[95]));
  (* SOFT_HLUTNM = "soft_lutpair51" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[96]_INST_0 
       (.I0(in2[96]),
        .I1(ctrl1),
        .I2(in3[96]),
        .O(out1[96]));
  (* SOFT_HLUTNM = "soft_lutpair51" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[97]_INST_0 
       (.I0(ctrl1),
        .I1(in2[97]),
        .I2(in3[97]),
        .O(out1[97]));
  (* SOFT_HLUTNM = "soft_lutpair52" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \out1[98]_INST_0 
       (.I0(in2[98]),
        .I1(ctrl1),
        .I2(in3[98]),
        .O(out1[98]));
  (* SOFT_HLUTNM = "soft_lutpair52" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[99]_INST_0 
       (.I0(ctrl1),
        .I1(in2[99]),
        .I2(in3[99]),
        .O(out1[99]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \out1[9]_INST_0 
       (.I0(ctrl1),
        .I1(in2[9]),
        .I2(in3[9]),
        .O(out1[9]));
endmodule
