// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
// Date        : Mon Dec  1 16:09:38 2025
// Host        : haagendazs running 64-bit Red Hat Enterprise Linux release 8.10 (Ootpa)
// Command     : write_verilog -cell inst_4 -force
//               /home/kevin/nov_submission/esp/accelerators/stratus_hls/dummy_stratus/hw/hls-work-inferred/bdw_work/modules/dummy/BASIC_DMA64/v_gates/dummy_N_Muxb_1_2_3_4.v
// Design      : dummy_N_Muxb_1_2_3_4
// Purpose     : This is a Verilog netlist of the current design or from a specific cell of the design. The output is an
//               IEEE 1364-2001 compliant Verilog HDL file that contains netlist information obtained from the input
//               design files.
// Device      : xc7v2000tflg1925-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* STRUCTURAL_NETLIST = "yes" *)
module dummy_N_Muxb_1_2_3_4
   (in3,
    in2,
    ctrl1,
    out1);
  input in3;
  input in2;
  input ctrl1;
  output out1;

  wire ctrl1;
  wire in2;
  wire in3;
  wire out1;

  LUT3 #(
    .INIT(8'hB8)) 
    out1_INST_0
       (.I0(in2),
        .I1(ctrl1),
        .I2(in3),
        .O(out1));
endmodule
