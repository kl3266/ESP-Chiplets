// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
// Date        : Mon Dec  1 16:09:53 2025
// Host        : haagendazs running 64-bit Red Hat Enterprise Linux release 8.10 (Ootpa)
// Command     : write_verilog -cell inst_0 -force
//               /home/kevin/nov_submission/esp/accelerators/stratus_hls/dummy_stratus/hw/hls-work-inferred/bdw_work/modules/dummy/BASIC_DMA64/v_gates/dummy_Add_4U_9_4.v
// Design      : dummy_Add_4U_9_4
// Purpose     : This is a Verilog netlist of the current design or from a specific cell of the design. The output is an
//               IEEE 1364-2001 compliant Verilog HDL file that contains netlist information obtained from the input
//               design files.
// Device      : xc7v2000tflg1925-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* STRUCTURAL_NETLIST = "yes" *)
module dummy_Add_4U_9_4
   (in1,
    out1);
  input [3:0]in1;
  output [3:0]out1;

  wire [3:0]in1;
  wire [3:0]out1;

  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT1 #(
    .INIT(2'h1)) 
    \out1[0]_INST_0 
       (.I0(in1[0]),
        .O(out1[0]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \out1[1]_INST_0 
       (.I0(in1[0]),
        .I1(in1[1]),
        .O(out1[1]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \out1[2]_INST_0 
       (.I0(in1[1]),
        .I1(in1[0]),
        .I2(in1[2]),
        .O(out1[2]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h7F80)) 
    \out1[3]_INST_0 
       (.I0(in1[1]),
        .I1(in1[0]),
        .I2(in1[2]),
        .I3(in1[3]),
        .O(out1[3]));
endmodule

