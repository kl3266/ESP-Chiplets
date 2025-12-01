// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
// Date        : Mon Dec  1 16:12:10 2025
// Host        : haagendazs running 64-bit Red Hat Enterprise Linux release 8.10 (Ootpa)
// Command     : write_verilog -cell inst_0 -force
//               /home/kevin/nov_submission/esp/accelerators/stratus_hls/dummy_stratus/hw/hls-work-inferred/bdw_work/modules/dummy/BASIC_DMA512/v_gates/dummy_Add_32Sx4U_32S_4.v
// Design      : dummy_Add_32Sx4U_32S_4
// Purpose     : This is a Verilog netlist of the current design or from a specific cell of the design. The output is an
//               IEEE 1364-2001 compliant Verilog HDL file that contains netlist information obtained from the input
//               design files.
// Device      : xc7v2000tflg1925-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* STRUCTURAL_NETLIST = "yes" *)
module dummy_Add_32Sx4U_32S_4
   (in2,
    in1,
    out1);
  input [31:0]in2;
  input [3:0]in1;
  output [31:0]out1;

  wire \<const0> ;
  wire [3:0]in1;
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
  wire \out1[12]_INST_0_n_0 ;
  wire \out1[12]_INST_0_n_1 ;
  wire \out1[12]_INST_0_n_2 ;
  wire \out1[12]_INST_0_n_3 ;
  wire \out1[16]_INST_0_n_0 ;
  wire \out1[16]_INST_0_n_1 ;
  wire \out1[16]_INST_0_n_2 ;
  wire \out1[16]_INST_0_n_3 ;
  wire \out1[20]_INST_0_n_0 ;
  wire \out1[20]_INST_0_n_1 ;
  wire \out1[20]_INST_0_n_2 ;
  wire \out1[20]_INST_0_n_3 ;
  wire \out1[24]_INST_0_n_0 ;
  wire \out1[24]_INST_0_n_1 ;
  wire \out1[24]_INST_0_n_2 ;
  wire \out1[24]_INST_0_n_3 ;
  wire \out1[28]_INST_0_n_1 ;
  wire \out1[28]_INST_0_n_2 ;
  wire \out1[28]_INST_0_n_3 ;
  wire \out1[4]_INST_0_n_0 ;
  wire \out1[4]_INST_0_n_1 ;
  wire \out1[4]_INST_0_n_2 ;
  wire \out1[4]_INST_0_n_3 ;
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
        .DI({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .O(out1[15:12]),
        .S(in2[15:12]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \out1[16]_INST_0 
       (.CI(\out1[12]_INST_0_n_0 ),
        .CO({\out1[16]_INST_0_n_0 ,\out1[16]_INST_0_n_1 ,\out1[16]_INST_0_n_2 ,\out1[16]_INST_0_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .O(out1[19:16]),
        .S(in2[19:16]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \out1[20]_INST_0 
       (.CI(\out1[16]_INST_0_n_0 ),
        .CO({\out1[20]_INST_0_n_0 ,\out1[20]_INST_0_n_1 ,\out1[20]_INST_0_n_2 ,\out1[20]_INST_0_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .O(out1[23:20]),
        .S(in2[23:20]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \out1[24]_INST_0 
       (.CI(\out1[20]_INST_0_n_0 ),
        .CO({\out1[24]_INST_0_n_0 ,\out1[24]_INST_0_n_1 ,\out1[24]_INST_0_n_2 ,\out1[24]_INST_0_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .O(out1[27:24]),
        .S(in2[27:24]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \out1[28]_INST_0 
       (.CI(\out1[24]_INST_0_n_0 ),
        .CO({\out1[28]_INST_0_n_1 ,\out1[28]_INST_0_n_2 ,\out1[28]_INST_0_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .O(out1[31:28]),
        .S(in2[31:28]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \out1[4]_INST_0 
       (.CI(\out1[0]_INST_0_n_0 ),
        .CO({\out1[4]_INST_0_n_0 ,\out1[4]_INST_0_n_1 ,\out1[4]_INST_0_n_2 ,\out1[4]_INST_0_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .O(out1[7:4]),
        .S(in2[7:4]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \out1[8]_INST_0 
       (.CI(\out1[4]_INST_0_n_0 ),
        .CO({\out1[8]_INST_0_n_0 ,\out1[8]_INST_0_n_1 ,\out1[8]_INST_0_n_2 ,\out1[8]_INST_0_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .O(out1[11:8]),
        .S(in2[11:8]));
endmodule

