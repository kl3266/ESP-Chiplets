// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
// Date        : Mon Dec  1 16:09:43 2025
// Host        : haagendazs running 64-bit Red Hat Enterprise Linux release 8.10 (Ootpa)
// Command     : write_verilog -cell inst_15 -force
//               /home/kevin/nov_submission/esp/accelerators/stratus_hls/dummy_stratus/hw/hls-work-inferred/bdw_work/modules/dummy/BASIC_DMA64/v_gates/dummy_N_Mux_32_2_0_4.v
// Design      : dummy_N_Mux_32_2_0_4
// Purpose     : This is a Verilog netlist of the current design or from a specific cell of the design. The output is an
//               IEEE 1364-2001 compliant Verilog HDL file that contains netlist information obtained from the input
//               design files.
// Device      : xc7v2000tflg1925-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* STRUCTURAL_NETLIST = "yes" *)
module dummy_N_Mux_32_2_0_4
   (in2,
    ctrl1,
    out1);
  input [31:0]in2;
  input ctrl1;
  output [31:0]out1;

  wire ctrl1;
  wire [31:0]in2;
  wire [31:0]out1;

  (* SOFT_HLUTNM = "soft_lutpair47" *) 
  LUT2 #(
    .INIT(4'h4)) 
    \out1[0]_INST_0 
       (.I0(ctrl1),
        .I1(in2[0]),
        .O(out1[0]));
  (* SOFT_HLUTNM = "soft_lutpair43" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \out1[10]_INST_0 
       (.I0(in2[10]),
        .I1(ctrl1),
        .O(out1[10]));
  (* SOFT_HLUTNM = "soft_lutpair42" *) 
  LUT2 #(
    .INIT(4'h4)) 
    \out1[11]_INST_0 
       (.I0(ctrl1),
        .I1(in2[11]),
        .O(out1[11]));
  (* SOFT_HLUTNM = "soft_lutpair42" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \out1[12]_INST_0 
       (.I0(in2[12]),
        .I1(ctrl1),
        .O(out1[12]));
  (* SOFT_HLUTNM = "soft_lutpair41" *) 
  LUT2 #(
    .INIT(4'h4)) 
    \out1[13]_INST_0 
       (.I0(ctrl1),
        .I1(in2[13]),
        .O(out1[13]));
  (* SOFT_HLUTNM = "soft_lutpair41" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \out1[14]_INST_0 
       (.I0(in2[14]),
        .I1(ctrl1),
        .O(out1[14]));
  (* SOFT_HLUTNM = "soft_lutpair40" *) 
  LUT2 #(
    .INIT(4'h4)) 
    \out1[15]_INST_0 
       (.I0(ctrl1),
        .I1(in2[15]),
        .O(out1[15]));
  (* SOFT_HLUTNM = "soft_lutpair40" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \out1[16]_INST_0 
       (.I0(in2[16]),
        .I1(ctrl1),
        .O(out1[16]));
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
  LUT2 #(
    .INIT(4'h4)) 
    \out1[17]_INST_0 
       (.I0(ctrl1),
        .I1(in2[17]),
        .O(out1[17]));
  (* SOFT_HLUTNM = "soft_lutpair39" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \out1[18]_INST_0 
       (.I0(in2[18]),
        .I1(ctrl1),
        .O(out1[18]));
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT2 #(
    .INIT(4'h4)) 
    \out1[19]_INST_0 
       (.I0(ctrl1),
        .I1(in2[19]),
        .O(out1[19]));
  (* SOFT_HLUTNM = "soft_lutpair47" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \out1[1]_INST_0 
       (.I0(in2[1]),
        .I1(ctrl1),
        .O(out1[1]));
  (* SOFT_HLUTNM = "soft_lutpair38" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \out1[20]_INST_0 
       (.I0(in2[20]),
        .I1(ctrl1),
        .O(out1[20]));
  (* SOFT_HLUTNM = "soft_lutpair37" *) 
  LUT2 #(
    .INIT(4'h4)) 
    \out1[21]_INST_0 
       (.I0(ctrl1),
        .I1(in2[21]),
        .O(out1[21]));
  (* SOFT_HLUTNM = "soft_lutpair37" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \out1[22]_INST_0 
       (.I0(in2[22]),
        .I1(ctrl1),
        .O(out1[22]));
  (* SOFT_HLUTNM = "soft_lutpair36" *) 
  LUT2 #(
    .INIT(4'h4)) 
    \out1[23]_INST_0 
       (.I0(ctrl1),
        .I1(in2[23]),
        .O(out1[23]));
  (* SOFT_HLUTNM = "soft_lutpair36" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \out1[24]_INST_0 
       (.I0(in2[24]),
        .I1(ctrl1),
        .O(out1[24]));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT2 #(
    .INIT(4'h4)) 
    \out1[25]_INST_0 
       (.I0(ctrl1),
        .I1(in2[25]),
        .O(out1[25]));
  (* SOFT_HLUTNM = "soft_lutpair35" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \out1[26]_INST_0 
       (.I0(in2[26]),
        .I1(ctrl1),
        .O(out1[26]));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT2 #(
    .INIT(4'h4)) 
    \out1[27]_INST_0 
       (.I0(ctrl1),
        .I1(in2[27]),
        .O(out1[27]));
  (* SOFT_HLUTNM = "soft_lutpair34" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \out1[28]_INST_0 
       (.I0(in2[28]),
        .I1(ctrl1),
        .O(out1[28]));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT2 #(
    .INIT(4'h4)) 
    \out1[29]_INST_0 
       (.I0(ctrl1),
        .I1(in2[29]),
        .O(out1[29]));
  (* SOFT_HLUTNM = "soft_lutpair46" *) 
  LUT2 #(
    .INIT(4'h4)) 
    \out1[2]_INST_0 
       (.I0(ctrl1),
        .I1(in2[2]),
        .O(out1[2]));
  (* SOFT_HLUTNM = "soft_lutpair33" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \out1[30]_INST_0 
       (.I0(in2[30]),
        .I1(ctrl1),
        .O(out1[30]));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT2 #(
    .INIT(4'h4)) 
    \out1[31]_INST_0 
       (.I0(ctrl1),
        .I1(in2[31]),
        .O(out1[31]));
  (* SOFT_HLUTNM = "soft_lutpair46" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \out1[3]_INST_0 
       (.I0(in2[3]),
        .I1(ctrl1),
        .O(out1[3]));
  (* SOFT_HLUTNM = "soft_lutpair45" *) 
  LUT2 #(
    .INIT(4'h4)) 
    \out1[4]_INST_0 
       (.I0(ctrl1),
        .I1(in2[4]),
        .O(out1[4]));
  (* SOFT_HLUTNM = "soft_lutpair45" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \out1[5]_INST_0 
       (.I0(in2[5]),
        .I1(ctrl1),
        .O(out1[5]));
  (* SOFT_HLUTNM = "soft_lutpair44" *) 
  LUT2 #(
    .INIT(4'h4)) 
    \out1[6]_INST_0 
       (.I0(ctrl1),
        .I1(in2[6]),
        .O(out1[6]));
  (* SOFT_HLUTNM = "soft_lutpair44" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \out1[7]_INST_0 
       (.I0(in2[7]),
        .I1(ctrl1),
        .O(out1[7]));
  (* SOFT_HLUTNM = "soft_lutpair43" *) 
  LUT2 #(
    .INIT(4'h4)) 
    \out1[8]_INST_0 
       (.I0(ctrl1),
        .I1(in2[8]),
        .O(out1[8]));
  (* SOFT_HLUTNM = "soft_lutpair32" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \out1[9]_INST_0 
       (.I0(ctrl1),
        .I1(in2[9]),
        .O(out1[9]));
endmodule
