// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
// Date        : Mon Dec  1 16:11:27 2025
// Host        : haagendazs running 64-bit Red Hat Enterprise Linux release 8.10 (Ootpa)
// Command     : write_verilog -cell inst_2 -force
//               /home/kevin/nov_submission/esp/accelerators/stratus_hls/dummy_stratus/hw/hls-work-inferred/bdw_work/modules/dummy/BASIC_DMA256/v_gates/dummy_Add_9Ux2U_9U_4.v
// Design      : dummy_Add_9Ux2U_9U_4
// Purpose     : This is a Verilog netlist of the current design or from a specific cell of the design. The output is an
//               IEEE 1364-2001 compliant Verilog HDL file that contains netlist information obtained from the input
//               design files.
// Device      : xc7v2000tflg1925-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* STRUCTURAL_NETLIST = "yes" *)
module dummy_Add_9Ux2U_9U_4
   (in2,
    in1,
    out1);
  input [8:0]in2;
  input [1:0]in1;
  output [8:0]out1;

  wire [1:0]in1;
  wire [8:0]in2;
  wire [8:0]out1;
  wire \out1[8]_INST_0_i_1_n_0 ;

  LUT2 #(
    .INIT(4'h6)) 
    \out1[0]_INST_0 
       (.I0(in2[0]),
        .I1(in1[0]),
        .O(out1[0]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'h9666)) 
    \out1[1]_INST_0 
       (.I0(in1[1]),
        .I1(in2[1]),
        .I2(in2[0]),
        .I3(in1[0]),
        .O(out1[1]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h1777E888)) 
    \out1[2]_INST_0 
       (.I0(in1[1]),
        .I1(in2[1]),
        .I2(in2[0]),
        .I3(in1[0]),
        .I4(in2[2]),
        .O(out1[2]));
  LUT6 #(
    .INIT(64'h077FFFFFF8800000)) 
    \out1[3]_INST_0 
       (.I0(in1[0]),
        .I1(in2[0]),
        .I2(in2[1]),
        .I3(in1[1]),
        .I4(in2[2]),
        .I5(in2[3]),
        .O(out1[3]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \out1[4]_INST_0 
       (.I0(\out1[8]_INST_0_i_1_n_0 ),
        .I1(in2[4]),
        .O(out1[4]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \out1[5]_INST_0 
       (.I0(\out1[8]_INST_0_i_1_n_0 ),
        .I1(in2[4]),
        .I2(in2[5]),
        .O(out1[5]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h7F80)) 
    \out1[6]_INST_0 
       (.I0(in2[5]),
        .I1(\out1[8]_INST_0_i_1_n_0 ),
        .I2(in2[4]),
        .I3(in2[6]),
        .O(out1[6]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h7FFF8000)) 
    \out1[7]_INST_0 
       (.I0(in2[5]),
        .I1(\out1[8]_INST_0_i_1_n_0 ),
        .I2(in2[4]),
        .I3(in2[6]),
        .I4(in2[7]),
        .O(out1[7]));
  LUT6 #(
    .INIT(64'h7FFFFFFF80000000)) 
    \out1[8]_INST_0 
       (.I0(in2[6]),
        .I1(in2[4]),
        .I2(\out1[8]_INST_0_i_1_n_0 ),
        .I3(in2[5]),
        .I4(in2[7]),
        .I5(in2[8]),
        .O(out1[8]));
  LUT6 #(
    .INIT(64'hAA80800000000000)) 
    \out1[8]_INST_0_i_1 
       (.I0(in2[3]),
        .I1(in1[0]),
        .I2(in2[0]),
        .I3(in2[1]),
        .I4(in1[1]),
        .I5(in2[2]),
        .O(\out1[8]_INST_0_i_1_n_0 ));
endmodule
