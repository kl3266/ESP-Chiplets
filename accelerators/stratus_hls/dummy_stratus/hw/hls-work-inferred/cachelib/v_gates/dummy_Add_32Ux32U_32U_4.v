// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
// Date        : Mon Dec  1 16:09:43 2025
// Host        : haagendazs running 64-bit Red Hat Enterprise Linux release 8.10 (Ootpa)
// Command     : write_verilog -cell inst_14 -force
//               /home/kevin/nov_submission/esp/accelerators/stratus_hls/dummy_stratus/hw/hls-work-inferred/bdw_work/modules/dummy/BASIC_DMA64/v_gates/dummy_Add_32Ux32U_32U_4.v
// Design      : dummy_Add_32Ux32U_32U_4
// Purpose     : This is a Verilog netlist of the current design or from a specific cell of the design. The output is an
//               IEEE 1364-2001 compliant Verilog HDL file that contains netlist information obtained from the input
//               design files.
// Device      : xc7v2000tflg1925-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* STRUCTURAL_NETLIST = "yes" *)
module dummy_Add_32Ux32U_32U_4
   (in2,
    in1,
    out1);
  input [31:0]in2;
  input [31:0]in1;
  output [31:0]out1;

  wire \<const0> ;
  wire [31:0]in1;
  wire [31:0]in2;
  wire [31:0]out1;
  wire \out1[0]_INST_0_i_1_n_0 ;
  wire \out1[0]_INST_0_i_2_n_0 ;
  wire \out1[0]_INST_0_i_3_n_0 ;
  wire \out1[0]_INST_0_i_4_n_0 ;
  wire \out1[0]_INST_0_n_0 ;
  wire \out1[0]_INST_0_n_1 ;
  wire \out1[0]_INST_0_n_2 ;
  wire \out1[0]_INST_0_n_3 ;
  wire \out1[12]_INST_0_i_1_n_0 ;
  wire \out1[12]_INST_0_i_2_n_0 ;
  wire \out1[12]_INST_0_i_3_n_0 ;
  wire \out1[12]_INST_0_i_4_n_0 ;
  wire \out1[12]_INST_0_n_0 ;
  wire \out1[12]_INST_0_n_1 ;
  wire \out1[12]_INST_0_n_2 ;
  wire \out1[12]_INST_0_n_3 ;
  wire \out1[16]_INST_0_i_1_n_0 ;
  wire \out1[16]_INST_0_i_2_n_0 ;
  wire \out1[16]_INST_0_i_3_n_0 ;
  wire \out1[16]_INST_0_i_4_n_0 ;
  wire \out1[16]_INST_0_n_0 ;
  wire \out1[16]_INST_0_n_1 ;
  wire \out1[16]_INST_0_n_2 ;
  wire \out1[16]_INST_0_n_3 ;
  wire \out1[20]_INST_0_i_1_n_0 ;
  wire \out1[20]_INST_0_i_2_n_0 ;
  wire \out1[20]_INST_0_i_3_n_0 ;
  wire \out1[20]_INST_0_i_4_n_0 ;
  wire \out1[20]_INST_0_n_0 ;
  wire \out1[20]_INST_0_n_1 ;
  wire \out1[20]_INST_0_n_2 ;
  wire \out1[20]_INST_0_n_3 ;
  wire \out1[24]_INST_0_i_1_n_0 ;
  wire \out1[24]_INST_0_i_2_n_0 ;
  wire \out1[24]_INST_0_i_3_n_0 ;
  wire \out1[24]_INST_0_i_4_n_0 ;
  wire \out1[24]_INST_0_n_0 ;
  wire \out1[24]_INST_0_n_1 ;
  wire \out1[24]_INST_0_n_2 ;
  wire \out1[24]_INST_0_n_3 ;
  wire \out1[28]_INST_0_i_1_n_0 ;
  wire \out1[28]_INST_0_i_2_n_0 ;
  wire \out1[28]_INST_0_i_3_n_0 ;
  wire \out1[28]_INST_0_i_4_n_0 ;
  wire \out1[28]_INST_0_n_1 ;
  wire \out1[28]_INST_0_n_2 ;
  wire \out1[28]_INST_0_n_3 ;
  wire \out1[4]_INST_0_i_1_n_0 ;
  wire \out1[4]_INST_0_i_2_n_0 ;
  wire \out1[4]_INST_0_i_3_n_0 ;
  wire \out1[4]_INST_0_i_4_n_0 ;
  wire \out1[4]_INST_0_n_0 ;
  wire \out1[4]_INST_0_n_1 ;
  wire \out1[4]_INST_0_n_2 ;
  wire \out1[4]_INST_0_n_3 ;
  wire \out1[8]_INST_0_i_1_n_0 ;
  wire \out1[8]_INST_0_i_2_n_0 ;
  wire \out1[8]_INST_0_i_3_n_0 ;
  wire \out1[8]_INST_0_i_4_n_0 ;
  wire \out1[8]_INST_0_n_0 ;
  wire \out1[8]_INST_0_n_1 ;
  wire \out1[8]_INST_0_n_2 ;
  wire \out1[8]_INST_0_n_3 ;

  GND GND
       (.G(\<const0> ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \out1[0]_INST_0 
       (.CI(\<const0> ),
        .CO({\out1[0]_INST_0_n_0 ,\out1[0]_INST_0_n_1 ,\out1[0]_INST_0_n_2 ,\out1[0]_INST_0_n_3 }),
        .CYINIT(\<const0> ),
        .DI(in2[3:0]),
        .O(out1[3:0]),
        .S({\out1[0]_INST_0_i_1_n_0 ,\out1[0]_INST_0_i_2_n_0 ,\out1[0]_INST_0_i_3_n_0 ,\out1[0]_INST_0_i_4_n_0 }));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[0]_INST_0_i_1 
       (.I0(in2[3]),
        .I1(in1[3]),
        .O(\out1[0]_INST_0_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[0]_INST_0_i_2 
       (.I0(in2[2]),
        .I1(in1[2]),
        .O(\out1[0]_INST_0_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[0]_INST_0_i_3 
       (.I0(in2[1]),
        .I1(in1[1]),
        .O(\out1[0]_INST_0_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[0]_INST_0_i_4 
       (.I0(in2[0]),
        .I1(in1[0]),
        .O(\out1[0]_INST_0_i_4_n_0 ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \out1[12]_INST_0 
       (.CI(\out1[8]_INST_0_n_0 ),
        .CO({\out1[12]_INST_0_n_0 ,\out1[12]_INST_0_n_1 ,\out1[12]_INST_0_n_2 ,\out1[12]_INST_0_n_3 }),
        .CYINIT(\<const0> ),
        .DI(in2[15:12]),
        .O(out1[15:12]),
        .S({\out1[12]_INST_0_i_1_n_0 ,\out1[12]_INST_0_i_2_n_0 ,\out1[12]_INST_0_i_3_n_0 ,\out1[12]_INST_0_i_4_n_0 }));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[12]_INST_0_i_1 
       (.I0(in2[15]),
        .I1(in1[15]),
        .O(\out1[12]_INST_0_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[12]_INST_0_i_2 
       (.I0(in2[14]),
        .I1(in1[14]),
        .O(\out1[12]_INST_0_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[12]_INST_0_i_3 
       (.I0(in2[13]),
        .I1(in1[13]),
        .O(\out1[12]_INST_0_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[12]_INST_0_i_4 
       (.I0(in2[12]),
        .I1(in1[12]),
        .O(\out1[12]_INST_0_i_4_n_0 ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \out1[16]_INST_0 
       (.CI(\out1[12]_INST_0_n_0 ),
        .CO({\out1[16]_INST_0_n_0 ,\out1[16]_INST_0_n_1 ,\out1[16]_INST_0_n_2 ,\out1[16]_INST_0_n_3 }),
        .CYINIT(\<const0> ),
        .DI(in2[19:16]),
        .O(out1[19:16]),
        .S({\out1[16]_INST_0_i_1_n_0 ,\out1[16]_INST_0_i_2_n_0 ,\out1[16]_INST_0_i_3_n_0 ,\out1[16]_INST_0_i_4_n_0 }));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[16]_INST_0_i_1 
       (.I0(in2[19]),
        .I1(in1[19]),
        .O(\out1[16]_INST_0_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[16]_INST_0_i_2 
       (.I0(in2[18]),
        .I1(in1[18]),
        .O(\out1[16]_INST_0_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[16]_INST_0_i_3 
       (.I0(in2[17]),
        .I1(in1[17]),
        .O(\out1[16]_INST_0_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[16]_INST_0_i_4 
       (.I0(in2[16]),
        .I1(in1[16]),
        .O(\out1[16]_INST_0_i_4_n_0 ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \out1[20]_INST_0 
       (.CI(\out1[16]_INST_0_n_0 ),
        .CO({\out1[20]_INST_0_n_0 ,\out1[20]_INST_0_n_1 ,\out1[20]_INST_0_n_2 ,\out1[20]_INST_0_n_3 }),
        .CYINIT(\<const0> ),
        .DI(in2[23:20]),
        .O(out1[23:20]),
        .S({\out1[20]_INST_0_i_1_n_0 ,\out1[20]_INST_0_i_2_n_0 ,\out1[20]_INST_0_i_3_n_0 ,\out1[20]_INST_0_i_4_n_0 }));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[20]_INST_0_i_1 
       (.I0(in2[23]),
        .I1(in1[23]),
        .O(\out1[20]_INST_0_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[20]_INST_0_i_2 
       (.I0(in2[22]),
        .I1(in1[22]),
        .O(\out1[20]_INST_0_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[20]_INST_0_i_3 
       (.I0(in2[21]),
        .I1(in1[21]),
        .O(\out1[20]_INST_0_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[20]_INST_0_i_4 
       (.I0(in2[20]),
        .I1(in1[20]),
        .O(\out1[20]_INST_0_i_4_n_0 ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \out1[24]_INST_0 
       (.CI(\out1[20]_INST_0_n_0 ),
        .CO({\out1[24]_INST_0_n_0 ,\out1[24]_INST_0_n_1 ,\out1[24]_INST_0_n_2 ,\out1[24]_INST_0_n_3 }),
        .CYINIT(\<const0> ),
        .DI(in2[27:24]),
        .O(out1[27:24]),
        .S({\out1[24]_INST_0_i_1_n_0 ,\out1[24]_INST_0_i_2_n_0 ,\out1[24]_INST_0_i_3_n_0 ,\out1[24]_INST_0_i_4_n_0 }));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[24]_INST_0_i_1 
       (.I0(in2[27]),
        .I1(in1[27]),
        .O(\out1[24]_INST_0_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[24]_INST_0_i_2 
       (.I0(in2[26]),
        .I1(in1[26]),
        .O(\out1[24]_INST_0_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[24]_INST_0_i_3 
       (.I0(in2[25]),
        .I1(in1[25]),
        .O(\out1[24]_INST_0_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[24]_INST_0_i_4 
       (.I0(in2[24]),
        .I1(in1[24]),
        .O(\out1[24]_INST_0_i_4_n_0 ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \out1[28]_INST_0 
       (.CI(\out1[24]_INST_0_n_0 ),
        .CO({\out1[28]_INST_0_n_1 ,\out1[28]_INST_0_n_2 ,\out1[28]_INST_0_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,in2[30:28]}),
        .O(out1[31:28]),
        .S({\out1[28]_INST_0_i_1_n_0 ,\out1[28]_INST_0_i_2_n_0 ,\out1[28]_INST_0_i_3_n_0 ,\out1[28]_INST_0_i_4_n_0 }));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[28]_INST_0_i_1 
       (.I0(in2[31]),
        .I1(in1[31]),
        .O(\out1[28]_INST_0_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[28]_INST_0_i_2 
       (.I0(in2[30]),
        .I1(in1[30]),
        .O(\out1[28]_INST_0_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[28]_INST_0_i_3 
       (.I0(in2[29]),
        .I1(in1[29]),
        .O(\out1[28]_INST_0_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[28]_INST_0_i_4 
       (.I0(in2[28]),
        .I1(in1[28]),
        .O(\out1[28]_INST_0_i_4_n_0 ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \out1[4]_INST_0 
       (.CI(\out1[0]_INST_0_n_0 ),
        .CO({\out1[4]_INST_0_n_0 ,\out1[4]_INST_0_n_1 ,\out1[4]_INST_0_n_2 ,\out1[4]_INST_0_n_3 }),
        .CYINIT(\<const0> ),
        .DI(in2[7:4]),
        .O(out1[7:4]),
        .S({\out1[4]_INST_0_i_1_n_0 ,\out1[4]_INST_0_i_2_n_0 ,\out1[4]_INST_0_i_3_n_0 ,\out1[4]_INST_0_i_4_n_0 }));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[4]_INST_0_i_1 
       (.I0(in2[7]),
        .I1(in1[7]),
        .O(\out1[4]_INST_0_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[4]_INST_0_i_2 
       (.I0(in2[6]),
        .I1(in1[6]),
        .O(\out1[4]_INST_0_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[4]_INST_0_i_3 
       (.I0(in2[5]),
        .I1(in1[5]),
        .O(\out1[4]_INST_0_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[4]_INST_0_i_4 
       (.I0(in2[4]),
        .I1(in1[4]),
        .O(\out1[4]_INST_0_i_4_n_0 ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \out1[8]_INST_0 
       (.CI(\out1[4]_INST_0_n_0 ),
        .CO({\out1[8]_INST_0_n_0 ,\out1[8]_INST_0_n_1 ,\out1[8]_INST_0_n_2 ,\out1[8]_INST_0_n_3 }),
        .CYINIT(\<const0> ),
        .DI(in2[11:8]),
        .O(out1[11:8]),
        .S({\out1[8]_INST_0_i_1_n_0 ,\out1[8]_INST_0_i_2_n_0 ,\out1[8]_INST_0_i_3_n_0 ,\out1[8]_INST_0_i_4_n_0 }));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[8]_INST_0_i_1 
       (.I0(in2[11]),
        .I1(in1[11]),
        .O(\out1[8]_INST_0_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[8]_INST_0_i_2 
       (.I0(in2[10]),
        .I1(in1[10]),
        .O(\out1[8]_INST_0_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[8]_INST_0_i_3 
       (.I0(in2[9]),
        .I1(in1[9]),
        .O(\out1[8]_INST_0_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \out1[8]_INST_0_i_4 
       (.I0(in2[8]),
        .I1(in1[8]),
        .O(\out1[8]_INST_0_i_4_n_0 ));
endmodule

