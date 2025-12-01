//
// Created with the ESP Memory Generator
//
// Copyright (c) 2011-2024 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
//
// @author Paolo Mantovani <paolo@cs.columbia.edu>
//

`timescale  1 ps / 1 ps

module dummy_plm(
    CLK,
    CE0,
    A0,
    D0,
    WE0,
    WEM0,
    CE1,
    A1,
    D1,
    WE1,
    WEM1,
    CE2,
    A2,
    D2,
    WE2,
    WEM2,
    CE3,
    A3,
    D3,
    WE3,
    WEM3,
    CE4,
    A4,
    D4,
    WE4,
    WEM4,
    CE5,
    A5,
    D5,
    WE5,
    WEM5,
    CE6,
    A6,
    D6,
    WE6,
    WEM6,
    CE7,
    A7,
    D7,
    WE7,
    WEM7,
    CE8,
    A8,
    Q8,
    CE9,
    A9,
    Q9,
    CE10,
    A10,
    Q10,
    CE11,
    A11,
    Q11,
    CE12,
    A12,
    Q12,
    CE13,
    A13,
    Q13,
    CE14,
    A14,
    Q14,
    CE15,
    A15,
    Q15
  );
  input CLK;
  input CE0;
  input [8:0] A0;
  input [63:0] D0;
  input WE0;
  input [63:0] WEM0;
  input CE1;
  input [8:0] A1;
  input [63:0] D1;
  input WE1;
  input [63:0] WEM1;
  input CE2;
  input [8:0] A2;
  input [63:0] D2;
  input WE2;
  input [63:0] WEM2;
  input CE3;
  input [8:0] A3;
  input [63:0] D3;
  input WE3;
  input [63:0] WEM3;
  input CE4;
  input [8:0] A4;
  input [63:0] D4;
  input WE4;
  input [63:0] WEM4;
  input CE5;
  input [8:0] A5;
  input [63:0] D5;
  input WE5;
  input [63:0] WEM5;
  input CE6;
  input [8:0] A6;
  input [63:0] D6;
  input WE6;
  input [63:0] WEM6;
  input CE7;
  input [8:0] A7;
  input [63:0] D7;
  input WE7;
  input [63:0] WEM7;
  input CE8;
  input [8:0] A8;
  output [63:0] Q8;
  input CE9;
  input [8:0] A9;
  output [63:0] Q9;
  input CE10;
  input [8:0] A10;
  output [63:0] Q10;
  input CE11;
  input [8:0] A11;
  output [63:0] Q11;
  input CE12;
  input [8:0] A12;
  output [63:0] Q12;
  input CE13;
  input [8:0] A13;
  output [63:0] Q13;
  input CE14;
  input [8:0] A14;
  output [63:0] Q14;
  input CE15;
  input [8:0] A15;
  output [63:0] Q15;
  genvar d, h, v, hh;

  reg               bank_CE  [0:0][7:0][0:0][3:0][0:0];
  reg         [9:0] bank_A   [0:0][7:0][0:0][3:0][0:0];
  reg        [15:0] bank_D   [0:0][7:0][0:0][3:0][0:0];
  reg               bank_WE  [0:0][7:0][0:0][3:0][0:0];
  reg        [15:0] bank_WEM [0:0][7:0][0:0][3:0][0:0];
  wire       [15:0] bank_Q   [0:0][7:0][0:0][3:0][0:0];
  wire        [0:0] ctrld    [15:8];
  wire        [2:0] ctrlh    [15:0];
  wire        [0:0] ctrlv    [15:0];
  reg         [0:0] seld     [15:8];
  reg         [2:0] selh     [15:8];
  reg         [0:0] selv     [15:8];
// synthesis translate_off
// synopsys translate_off
  integer check_bank_access [0:0][7:0][0:0][3:0][0:0];

  task check_access;
    input integer iface;
    input integer d;
    input integer h;
    input integer v;
    input integer hh;
    input integer p;
  begin
    if ((check_bank_access[d][h][v][hh][p] != -1) &&
        (check_bank_access[d][h][v][hh][p] != iface)) begin
      $display("ASSERTION FAILED in %m: port conflict on bank", h, "h", v, "v", hh, "hh", " for port", p, " involving interfaces", check_bank_access[d][h][v][hh][p], iface);
      $finish;
    end
    else begin
      check_bank_access[d][h][v][hh][p] = iface;
    end
  end
  endtask
// synopsys translate_on
// synthesis translate_on

  assign ctrld[8] = 0;
  assign ctrld[9] = 0;
  assign ctrld[10] = 0;
  assign ctrld[11] = 0;
  assign ctrld[12] = 0;
  assign ctrld[13] = 0;
  assign ctrld[14] = 0;
  assign ctrld[15] = 0;
  assign ctrlh[0] = A0[2:0];
  assign ctrlh[1] = A1[2:0];
  assign ctrlh[2] = A2[2:0];
  assign ctrlh[3] = A3[2:0];
  assign ctrlh[4] = A4[2:0];
  assign ctrlh[5] = A5[2:0];
  assign ctrlh[6] = A6[2:0];
  assign ctrlh[7] = A7[2:0];
  assign ctrlh[8] = A8[2:0];
  assign ctrlh[9] = A9[2:0];
  assign ctrlh[10] = A10[2:0];
  assign ctrlh[11] = A11[2:0];
  assign ctrlh[12] = A12[2:0];
  assign ctrlh[13] = A13[2:0];
  assign ctrlh[14] = A14[2:0];
  assign ctrlh[15] = A15[2:0];
  assign ctrlv[0] = 0;
  assign ctrlv[1] = 0;
  assign ctrlv[2] = 0;
  assign ctrlv[3] = 0;
  assign ctrlv[4] = 0;
  assign ctrlv[5] = 0;
  assign ctrlv[6] = 0;
  assign ctrlv[7] = 0;
  assign ctrlv[8] = 0;
  assign ctrlv[9] = 0;
  assign ctrlv[10] = 0;
  assign ctrlv[11] = 0;
  assign ctrlv[12] = 0;
  assign ctrlv[13] = 0;
  assign ctrlv[14] = 0;
  assign ctrlv[15] = 0;

  always @(posedge CLK) begin
    seld[8] <= ctrld[8];
    selh[8] <= ctrlh[8];
    selv[8] <= ctrlv[8];
    seld[9] <= ctrld[9];
    selh[9] <= ctrlh[9];
    selv[9] <= ctrlv[9];
    seld[10] <= ctrld[10];
    selh[10] <= ctrlh[10];
    selv[10] <= ctrlv[10];
    seld[11] <= ctrld[11];
    selh[11] <= ctrlh[11];
    selv[11] <= ctrlv[11];
    seld[12] <= ctrld[12];
    selh[12] <= ctrlh[12];
    selv[12] <= ctrlv[12];
    seld[13] <= ctrld[13];
    selh[13] <= ctrlh[13];
    selv[13] <= ctrlv[13];
    seld[14] <= ctrld[14];
    selh[14] <= ctrlh[14];
    selv[14] <= ctrlv[14];
    seld[15] <= ctrld[15];
    selh[15] <= ctrlh[15];
    selv[15] <= ctrlv[15];
  end

  generate
  for (h = 0; h < 8; h = h + 1) begin : gen_ctrl_hbanks
    for (v = 0; v < 1; v = v + 1) begin : gen_ctrl_vbanks
      for (hh = 0; hh < 4; hh = hh + 1) begin : gen_ctrl_hhbanks

        always @(*) begin : handle_ops

// synthesis translate_off
// synopsys translate_off
          // Prevent assertions to trigger with false positive
          # 1
// synopsys translate_on
// synthesis translate_on

          /** Default **/
// synthesis translate_off
// synopsys translate_off
          check_bank_access[0][h][v][hh][0] = -1;
// synopsys translate_on
// synthesis translate_on
          bank_CE[0][h][v][hh][0]  = 0;
          bank_A[0][h][v][hh][0]   = 0;
          bank_D[0][h][v][hh][0]   = 0;
          bank_WE[0][h][v][hh][0]  = 0;
          bank_WEM[0][h][v][hh][0] = 0;

          /** Handle 8w:0r **/
          // Duplicated bank set 0
            if (ctrlh[0] == h && ctrlv[0] == v && CE0 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(0, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE0;
                bank_A[0][h][v][hh][0]   = A0[8:3];
              if (hh != 3) begin
                bank_D[0][h][v][hh][0]   = D0[16 * (hh + 1) - 1:16 * hh];
                bank_WEM[0][h][v][hh][0] = WEM0[16 * (hh + 1) - 1:16 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D0[15 + 16 * hh:16 * hh];
                bank_WEM[0][h][v][hh][0] = WEM0[15 + 16 * hh:16 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE0;
            end
            if (ctrlh[1] == h && ctrlv[1] == v && CE1 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(1, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE1;
                bank_A[0][h][v][hh][0]   = A1[8:3];
              if (hh != 3) begin
                bank_D[0][h][v][hh][0]   = D1[16 * (hh + 1) - 1:16 * hh];
                bank_WEM[0][h][v][hh][0] = WEM1[16 * (hh + 1) - 1:16 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D1[15 + 16 * hh:16 * hh];
                bank_WEM[0][h][v][hh][0] = WEM1[15 + 16 * hh:16 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE1;
            end
            if (ctrlh[2] == h && ctrlv[2] == v && CE2 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(2, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE2;
                bank_A[0][h][v][hh][0]   = A2[8:3];
              if (hh != 3) begin
                bank_D[0][h][v][hh][0]   = D2[16 * (hh + 1) - 1:16 * hh];
                bank_WEM[0][h][v][hh][0] = WEM2[16 * (hh + 1) - 1:16 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D2[15 + 16 * hh:16 * hh];
                bank_WEM[0][h][v][hh][0] = WEM2[15 + 16 * hh:16 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE2;
            end
            if (ctrlh[3] == h && ctrlv[3] == v && CE3 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(3, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE3;
                bank_A[0][h][v][hh][0]   = A3[8:3];
              if (hh != 3) begin
                bank_D[0][h][v][hh][0]   = D3[16 * (hh + 1) - 1:16 * hh];
                bank_WEM[0][h][v][hh][0] = WEM3[16 * (hh + 1) - 1:16 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D3[15 + 16 * hh:16 * hh];
                bank_WEM[0][h][v][hh][0] = WEM3[15 + 16 * hh:16 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE3;
            end
            if (ctrlh[4] == h && ctrlv[4] == v && CE4 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(4, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE4;
                bank_A[0][h][v][hh][0]   = A4[8:3];
              if (hh != 3) begin
                bank_D[0][h][v][hh][0]   = D4[16 * (hh + 1) - 1:16 * hh];
                bank_WEM[0][h][v][hh][0] = WEM4[16 * (hh + 1) - 1:16 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D4[15 + 16 * hh:16 * hh];
                bank_WEM[0][h][v][hh][0] = WEM4[15 + 16 * hh:16 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE4;
            end
            if (ctrlh[5] == h && ctrlv[5] == v && CE5 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(5, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE5;
                bank_A[0][h][v][hh][0]   = A5[8:3];
              if (hh != 3) begin
                bank_D[0][h][v][hh][0]   = D5[16 * (hh + 1) - 1:16 * hh];
                bank_WEM[0][h][v][hh][0] = WEM5[16 * (hh + 1) - 1:16 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D5[15 + 16 * hh:16 * hh];
                bank_WEM[0][h][v][hh][0] = WEM5[15 + 16 * hh:16 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE5;
            end
            if (ctrlh[6] == h && ctrlv[6] == v && CE6 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(6, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE6;
                bank_A[0][h][v][hh][0]   = A6[8:3];
              if (hh != 3) begin
                bank_D[0][h][v][hh][0]   = D6[16 * (hh + 1) - 1:16 * hh];
                bank_WEM[0][h][v][hh][0] = WEM6[16 * (hh + 1) - 1:16 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D6[15 + 16 * hh:16 * hh];
                bank_WEM[0][h][v][hh][0] = WEM6[15 + 16 * hh:16 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE6;
            end
            if (ctrlh[7] == h && ctrlv[7] == v && CE7 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(7, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE7;
                bank_A[0][h][v][hh][0]   = A7[8:3];
              if (hh != 3) begin
                bank_D[0][h][v][hh][0]   = D7[16 * (hh + 1) - 1:16 * hh];
                bank_WEM[0][h][v][hh][0] = WEM7[16 * (hh + 1) - 1:16 * hh];
              end
              else begin
                bank_D[0][h][v][hh][0]   = D7[15 + 16 * hh:16 * hh];
                bank_WEM[0][h][v][hh][0] = WEM7[15 + 16 * hh:16 * hh];
              end
                bank_WE[0][h][v][hh][0]  = WE7;
            end

          /** Handle 0w:8r **/
          // Always choose duplicated bank set 0
            if (ctrlh[8] == h && ctrlv[8] == v && CE8 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(8, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE8;
                bank_A[0][h][v][hh][0]   = A8[8:3];
            end
            if (ctrlh[9] == h && ctrlv[9] == v && CE9 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(9, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE9;
                bank_A[0][h][v][hh][0]   = A9[8:3];
            end
            if (ctrlh[10] == h && ctrlv[10] == v && CE10 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(10, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE10;
                bank_A[0][h][v][hh][0]   = A10[8:3];
            end
            if (ctrlh[11] == h && ctrlv[11] == v && CE11 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(11, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE11;
                bank_A[0][h][v][hh][0]   = A11[8:3];
            end
            if (ctrlh[12] == h && ctrlv[12] == v && CE12 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(12, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE12;
                bank_A[0][h][v][hh][0]   = A12[8:3];
            end
            if (ctrlh[13] == h && ctrlv[13] == v && CE13 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(13, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE13;
                bank_A[0][h][v][hh][0]   = A13[8:3];
            end
            if (ctrlh[14] == h && ctrlv[14] == v && CE14 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(14, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE14;
                bank_A[0][h][v][hh][0]   = A14[8:3];
            end
            if (ctrlh[15] == h && ctrlv[15] == v && CE15 == 1'b1) begin
// synthesis translate_off
// synopsys translate_off
              check_access(15, 0, h, v, hh, 0);
// synopsys translate_on
// synthesis translate_on
                bank_CE[0][h][v][hh][0]  = CE15;
                bank_A[0][h][v][hh][0]   = A15[8:3];
            end

        end

      end
    end
  end
  endgenerate

  generate
  for (hh = 0; hh < 4; hh = hh + 1) begin : gen_q_assign_hhbanks
    if (hh == 3 && (hh + 1) * 16 > 64) begin : gen_q_assign_hhbanks_last_8 
       assign Q8[63:16 * hh] = bank_Q[seld[8]][selh[8]][selv[8]][hh][0][15:0];
    end else begin : gen_q_assign_hhbanks_others_8 
      assign Q8[16 * (hh + 1) - 1:16 * hh] = bank_Q[seld[8]][selh[8]][selv[8]][hh][0];
    end
    if (hh == 3 && (hh + 1) * 16 > 64) begin : gen_q_assign_hhbanks_last_9 
       assign Q9[63:16 * hh] = bank_Q[seld[9]][selh[9]][selv[9]][hh][0][15:0];
    end else begin : gen_q_assign_hhbanks_others_9 
      assign Q9[16 * (hh + 1) - 1:16 * hh] = bank_Q[seld[9]][selh[9]][selv[9]][hh][0];
    end
    if (hh == 3 && (hh + 1) * 16 > 64) begin : gen_q_assign_hhbanks_last_10 
       assign Q10[63:16 * hh] = bank_Q[seld[10]][selh[10]][selv[10]][hh][0][15:0];
    end else begin : gen_q_assign_hhbanks_others_10 
      assign Q10[16 * (hh + 1) - 1:16 * hh] = bank_Q[seld[10]][selh[10]][selv[10]][hh][0];
    end
    if (hh == 3 && (hh + 1) * 16 > 64) begin : gen_q_assign_hhbanks_last_11 
       assign Q11[63:16 * hh] = bank_Q[seld[11]][selh[11]][selv[11]][hh][0][15:0];
    end else begin : gen_q_assign_hhbanks_others_11 
      assign Q11[16 * (hh + 1) - 1:16 * hh] = bank_Q[seld[11]][selh[11]][selv[11]][hh][0];
    end
    if (hh == 3 && (hh + 1) * 16 > 64) begin : gen_q_assign_hhbanks_last_12 
       assign Q12[63:16 * hh] = bank_Q[seld[12]][selh[12]][selv[12]][hh][0][15:0];
    end else begin : gen_q_assign_hhbanks_others_12 
      assign Q12[16 * (hh + 1) - 1:16 * hh] = bank_Q[seld[12]][selh[12]][selv[12]][hh][0];
    end
    if (hh == 3 && (hh + 1) * 16 > 64) begin : gen_q_assign_hhbanks_last_13 
       assign Q13[63:16 * hh] = bank_Q[seld[13]][selh[13]][selv[13]][hh][0][15:0];
    end else begin : gen_q_assign_hhbanks_others_13 
      assign Q13[16 * (hh + 1) - 1:16 * hh] = bank_Q[seld[13]][selh[13]][selv[13]][hh][0];
    end
    if (hh == 3 && (hh + 1) * 16 > 64) begin : gen_q_assign_hhbanks_last_14 
       assign Q14[63:16 * hh] = bank_Q[seld[14]][selh[14]][selv[14]][hh][0][15:0];
    end else begin : gen_q_assign_hhbanks_others_14 
      assign Q14[16 * (hh + 1) - 1:16 * hh] = bank_Q[seld[14]][selh[14]][selv[14]][hh][0];
    end
    if (hh == 3 && (hh + 1) * 16 > 64) begin : gen_q_assign_hhbanks_last_15 
       assign Q15[63:16 * hh] = bank_Q[seld[15]][selh[15]][selv[15]][hh][0][15:0];
    end else begin : gen_q_assign_hhbanks_others_15 
      assign Q15[16 * (hh + 1) - 1:16 * hh] = bank_Q[seld[15]][selh[15]][selv[15]][hh][0];
    end
  end
  endgenerate

  generate
  for (d = 0; d < 1; d = d + 1) begin : gen_wires_dbanks
    for (h = 0; h < 8; h = h + 1) begin : gen_wires_hbanks
      for (v = 0; v < 1; v = v + 1) begin : gen_wires_vbanks
        for (hh = 0; hh < 4; hh = hh + 1) begin : gen_wires_hhbanks

          SRAM_1024x16 bank_i(
              .CLK0(CLK),
              .CE0(bank_CE[d][h][v][hh][0]),
              .A0(bank_A[d][h][v][hh][0]),
              .D0(bank_D[d][h][v][hh][0]),
              .WE0(bank_WE[d][h][v][hh][0]),
              .WEM0(bank_WEM[d][h][v][hh][0]),
              .Q0(bank_Q[d][h][v][hh][0])
            );

        end
      end
    end
  end
  endgenerate

endmodule
