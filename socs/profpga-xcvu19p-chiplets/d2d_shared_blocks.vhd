-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.esp_global.all;
use work.misc.all;
use work.nocpackage.all;

package d2d_delay_pkg is
  subtype d2d_delay_vector_t is attribute_vector(0 to 67);

  constant D2D_DELAY_REFCLK_MHZ : real := 400.0;

  function get_d2d_tx_odelay_ps(
    board_num : integer;
    cable_num : integer
  ) return d2d_delay_vector_t;
  function get_d2d_rx_idelay_ps(
    board_num : integer;
    cable_num : integer
  ) return d2d_delay_vector_t;
end package d2d_delay_pkg;

package body d2d_delay_pkg is
  constant ZERO_D2D_DELAY_PS : d2d_delay_vector_t := (others => 0);

  constant BOARD0_C0_TX_ODELAY_PS : d2d_delay_vector_t := (144, 224, 133, 170, 167, 111, 44, 118, 64, 121, 95, 40, 60, 129, 65, 129, 104, 212, 1, 75, 98, 48, 80, 129, 23, 85, 38, 107, 87, 194, 42, 115, 105, 213, 131, 90, 100, 176, 115, 166, 46, 126, 294, 368, 347, 453, 367, 313, 336, 370, 322, 400, 290, 370, 196, 270, 298, 407, 254, 348, 202, 280, 262, 311, 183, 251, 255, 321);
  constant BOARD0_C1_TX_ODELAY_PS : d2d_delay_vector_t := (238, 189, 582, 627, 567, 645, 494, 568, 563, 622, 589, 529, 526, 596, 520, 588, 567, 675, 412, 486, 533, 482, 503, 554, 486, 563, 468, 536, 516, 623, 489, 563, 570, 680, 499, 571, 544, 591, 552, 504, 539, 611, 281, 355, 360, 466, 378, 317, 344, 393, 329, 407, 267, 349, 79, 155, 180, 288, 133, 201, 203, 153, 211, 262, 220, 286, 252, 316);
  constant BOARD1_C0_TX_ODELAY_PS : d2d_delay_vector_t := (120, 108, 182, 216, 182, 230, 142, 264, 150, 260, 208, 248, 270, 352, 288, 210, 206, 324, 234, 216, 284, 338, 290, 342, 168, 232, 286, 406, 240, 350, 262, 306, 226, 286, 198, 306, 164, 272, 330, 312, 150, 204, 270, 314, 228, 278, 204, 278, 226, 284, 118, 238, 210, 334, 180, 290, 172, 154, 304, 284, 0, 108, 140, 114, 108, 216, 120, 176);
  constant BOARD1_C1_TX_ODELAY_PS : d2d_delay_vector_t := (328, 310, 342, 384, 340, 394, 250, 358, 322, 378, 358, 328, 298, 344, 290, 356, 310, 430, 170, 278, 304, 282, 264, 312, 260, 312, 240, 306, 260, 380, 248, 356, 316, 438, 272, 342, 306, 350, 324, 306, 314, 362, 358, 466, 424, 542, 468, 436, 424, 470, 422, 476, 358, 438, 158, 268, 246, 366, 226, 292, 294, 274, 292, 340, 310, 374, 0, 62);
  constant BOARD2_C0_TX_ODELAY_PS : d2d_delay_vector_t := (172, 156, 116, 166, 142, 184, 24, 132, 32, 82, 108, 86, 16, 76, 42, 106, 62, 184, 24, 132, 122, 102, 98, 146, 66, 108, 46, 100, 92, 212, 0, 108, 90, 206, 70, 126, 96, 148, 94, 142, 118, 86, 174, 280, 200, 320, 216, 270, 170, 234, 260, 242, 218, 266, 116, 226, 144, 266, 120, 182, 106, 168, 118, 166, 126, 192, 222, 286);
  constant BOARD2_C1_TX_ODELAY_PS : d2d_delay_vector_t := (90, 208, 178, 238, 190, 242, 198, 318, 154, 264, 120, 194, 194, 286, 162, 184, 152, 272, 208, 188, 250, 294, 270, 326, 158, 216, 268, 388, 204, 314, 88, 136, 118, 194, 88, 198, 36, 144, 304, 258, 118, 170, 142, 190, 252, 308, 64, 134, 132, 182, 4, 126, 128, 246, 100, 206, 116, 162, 182, 164, 22, 130, 0, 54, 72, 182, 48, 32);
  constant BOARD3_C0_TX_ODELAY_PS : d2d_delay_vector_t := (90, 142, 84, 140, 86, 140, 132, 252, 94, 202, 200, 246, 164, 194, 194, 192, 174, 294, 180, 160, 184, 232, 184, 236, 112, 176, 180, 300, 140, 248, 192, 250, 150, 218, 164, 270, 6, 116, 226, 206, 124, 176, 216, 246, 138, 220, 100, 150, 74, 140, 86, 206, 94, 216, 170, 278, 92, 140, 236, 238, 0, 108, 118, 160, 32, 140, 148, 132);
  constant BOARD3_C1_TX_ODELAY_PS : d2d_delay_vector_t := (90, 208, 178, 238, 190, 242, 198, 318, 154, 264, 120, 194, 194, 286, 162, 184, 152, 272, 208, 188, 250, 294, 270, 326, 158, 216, 268, 388, 204, 314, 88, 136, 118, 194, 88, 198, 36, 144, 304, 258, 118, 170, 142, 190, 252, 308, 64, 134, 132, 182, 4, 126, 128, 246, 100, 206, 116, 162, 182, 164, 22, 130, 0, 54, 72, 182, 48, 32);
  -- RX values come from the routed per-pin IDELAY extraction.
  constant BOARD0_C0_RX_IDELAY_PS : d2d_delay_vector_t := (13, 19, 103, 64, 94, 135, 59, 90, 64, 66, 88, 89, 84, 82, 84, 75, 90, 89, 97, 96, 83, 113, 118, 116, 97, 91, 104, 135, 137, 137, 119, 112, 138, 138, 134, 136, 137, 137, 66, 96, 74, 105, 99, 101, 124, 120, 118, 115, 95, 106, 38, 68, 128, 124, 68, 69, 125, 123, 59, 58, 56, 55, 0, 30, 52, 53, 53, 49);
  constant BOARD0_C1_RX_IDELAY_PS : d2d_delay_vector_t := (32, 30, 233, 210, 166, 33, 24, 54, 55, 54, 64, 64, 51, 45, 40, 46, 52, 62, 17, 16, 12, 42, 21, 27, 33, 36, 30, 60, 59, 58, 44, 51, 58, 60, 58, 55, 57, 50, 110, 141, 0, 29, 166, 166, 26, 23, 168, 167, 168, 167, 171, 201, 7, 15, 211, 211, 35, 33, 212, 209, 213, 211, 137, 166, 190, 190, 184, 179);
  constant BOARD1_C0_RX_IDELAY_PS : d2d_delay_vector_t := (89, 85, 53, 54, 36, 66, 92, 91, 41, 37, 41, 42, 35, 32, 39, 37, 77, 68, 44, 42, 0, 30, 66, 66, 58, 58, 45, 42, 20, 49, 46, 46, 166, 162, 164, 163, 50, 47, 50, 57, 67, 65, 138, 139, 60, 62, 55, 55, 165, 166, 165, 155, 160, 167, 136, 137, 134, 164, 115, 121, 130, 139, 126, 125, 150, 151, 84, 114);
  constant BOARD1_C1_RX_IDELAY_PS : d2d_delay_vector_t := (32, 30, 233, 210, 166, 33, 24, 54, 55, 54, 64, 64, 51, 45, 40, 46, 52, 62, 17, 16, 12, 42, 21, 27, 33, 36, 30, 60, 59, 58, 44, 51, 58, 60, 58, 55, 57, 50, 110, 141, 0, 29, 166, 166, 26, 23, 168, 167, 168, 167, 171, 201, 7, 15, 211, 211, 35, 33, 212, 209, 213, 211, 137, 166, 190, 190, 184, 179);
  constant BOARD2_C0_RX_IDELAY_PS : d2d_delay_vector_t := (43, 17, 69, 68, 54, 69, 44, 74, 72, 73, 73, 74, 49, 50, 48, 50, 76, 74, 94, 94, 79, 108, 93, 95, 106, 103, 67, 97, 97, 97, 87, 96, 98, 98, 97, 96, 98, 97, 0, 31, 82, 112, 54, 55, 102, 105, 55, 56, 56, 55, 13, 43, 114, 103, 68, 68, 104, 113, 52, 50, 68, 67, 18, 47, 50, 50, 69, 65);
  constant BOARD2_C1_RX_IDELAY_PS : d2d_delay_vector_t := (86, 85, 50, 51, 0, 30, 62, 60, 41, 40, 59, 64, 76, 83, 76, 88, 32, 40, 66, 65, 49, 79, 44, 40, 46, 48, 66, 56, 12, 43, 86, 86, 53, 52, 72, 71, 62, 61, 53, 49, 46, 50, 93, 93, 33, 37, 53, 54, 58, 58, 53, 51, 76, 75, 91, 93, 30, 61, 75, 75, 69, 68, 113, 112, 90, 92, 39, 69);
  constant BOARD3_C0_RX_IDELAY_PS : d2d_delay_vector_t := (84, 80, 40, 42, 33, 62, 83, 82, 43, 40, 25, 24, 44, 39, 42, 37, 67, 66, 49, 48, 12, 42, 57, 57, 41, 42, 17, 21, 0, 30, 56, 56, 117, 118, 109, 110, 57, 56, 48, 40, 56, 54, 82, 83, 55, 52, 54, 53, 119, 118, 105, 106, 118, 116, 131, 132, 87, 116, 62, 67, 81, 80, 117, 116, 120, 120, 58, 89);
  constant BOARD3_C1_RX_IDELAY_PS : d2d_delay_vector_t := (86, 85, 50, 51, 0, 30, 62, 60, 41, 40, 59, 64, 76, 83, 76, 88, 32, 40, 66, 65, 49, 79, 44, 40, 46, 48, 66, 56, 12, 43, 86, 86, 53, 52, 72, 71, 62, 61, 53, 49, 46, 50, 93, 93, 33, 37, 53, 54, 58, 58, 53, 51, 76, 75, 91, 93, 30, 61, 75, 75, 69, 68, 113, 112, 90, 92, 39, 69);

  function get_d2d_tx_odelay_ps(
    board_num : integer;
    cable_num : integer
  ) return d2d_delay_vector_t is
  begin
    return ZERO_D2D_DELAY_PS;
  end function get_d2d_tx_odelay_ps;
  function get_d2d_rx_idelay_ps(
    board_num : integer;
    cable_num : integer
  ) return d2d_delay_vector_t is
  begin
    return ZERO_D2D_DELAY_PS;
  end function get_d2d_rx_idelay_ps;
  -- function get_d2d_tx_odelay_ps(
  --   board_num : integer;
  --   cable_num : integer
  -- ) return d2d_delay_vector_t is
  -- begin
  --   case board_num is
  --     when 0 =>
  --       if cable_num = 0 then
  --         return BOARD0_C0_TX_ODELAY_PS;
  --       elsif cable_num = 1 then
  --         return BOARD0_C1_TX_ODELAY_PS;
  --       end if;
  --     when 1 =>
  --       if cable_num = 0 then
  --         return BOARD1_C0_TX_ODELAY_PS;
  --       elsif cable_num = 1 then
  --         return BOARD1_C1_TX_ODELAY_PS;
  --       end if;
  --     when 2 =>
  --       if cable_num = 0 then
  --         return BOARD2_C0_TX_ODELAY_PS;
  --       elsif cable_num = 1 then
  --         return BOARD2_C1_TX_ODELAY_PS;
  --       end if;
  --     when 3 =>
  --       if cable_num = 0 then
  --         return BOARD3_C0_TX_ODELAY_PS;
  --       elsif cable_num = 1 then
  --         return BOARD3_C1_TX_ODELAY_PS;
  --       end if;
  --     when others =>
  --       null;
  --   end case;

  --   return ZERO_D2D_DELAY_PS;
  -- end function get_d2d_tx_odelay_ps;

  -- function get_d2d_rx_idelay_ps(
  --   board_num : integer;
  --   cable_num : integer
  -- ) return d2d_delay_vector_t is
  -- begin
  --   case board_num is
  --     when 0 =>
  --       if cable_num = 0 then
  --         return BOARD0_C0_RX_IDELAY_PS;
  --       elsif cable_num = 1 then
  --         return BOARD0_C1_RX_IDELAY_PS;
  --       end if;
  --     when 1 =>
  --       if cable_num = 0 then
  --         return BOARD1_C0_RX_IDELAY_PS;
  --       elsif cable_num = 1 then
  --         return BOARD1_C1_RX_IDELAY_PS;
  --       end if;
  --     when 2 =>
  --       if cable_num = 0 then
  --         return BOARD2_C0_RX_IDELAY_PS;
  --       elsif cable_num = 1 then
  --         return BOARD2_C1_RX_IDELAY_PS;
  --       end if;
  --     when 3 =>
  --       if cable_num = 0 then
  --         return BOARD3_C0_RX_IDELAY_PS;
  --       elsif cable_num = 1 then
  --         return BOARD3_C1_RX_IDELAY_PS;
  --       end if;
  --     when others =>
  --       null;
  --   end case;

  --   return ZERO_D2D_DELAY_PS;
  -- end function get_d2d_rx_idelay_ps;
end package body d2d_delay_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.esp_global.all;
use work.misc.all;
use work.nocpackage.all;
use work.d2d_delay_pkg.all;

library unisim;
use unisim.VCOMPONENTS.all;

entity d2d_cable_frontend is
  generic (
    CLKIN_PERIOD_NS   : real;
    REF_JITTER1_UI    : real;
    RX_PHASE_DEG      : real;
    TX_PHASE_DEG      : real := 0.0;
    TX_DATA_PHASE_OFFSET_DEG : real := 56.25;
    RX_MMCM_RESET_RELEASE_CYCLES : positive range 1 to 16 := 16;
    CREDIT_CDC_N      : integer := 3;
    TX_ON_UPPER_PINS  : boolean := true;
    LINK_ACTIVE       : boolean := true;
    TX_ODELAY_PS      : d2d_delay_vector_t := (others => 0);
    RX_IDELAY_PS      : d2d_delay_vector_t := (others => 0)
  );
  port (
    d2d_clk_int               : in    std_ulogic;
    d2d_rst                   : in    std_ulogic;
    d2d_rstn                  : in    std_ulogic;
    d2d_rstn_d2d              : in    std_ulogic;
    delayctrl_rdy             : in    std_ulogic;
    cable_clk_p               : out   std_logic;
    cable_clk_n               : out   std_logic;
    cable_clk_p_rcv           : in    std_logic;
    cable_clk_n_rcv           : in    std_logic;
    cable_io_data             : inout std_logic_vector(135 downto 0);
    d2d_data_tx               : in    std_logic_vector(135 downto 0);
    d2d_data_rx_pipe          : out   std_logic_vector(135 downto 0);
    cable_clk_rcv_raw         : out   std_ulogic;
    cable_clk_rcv_core        : out   std_ulogic;
    d2d_tx_mmcm_locked        : out   std_ulogic;
    d2d_rx_mmcm_locked        : out   std_ulogic;
    credit_in_evt_pulse_d2d   : out   std_logic_vector(1 downto 0)
  );
end entity d2d_cable_frontend;

architecture rtl of d2d_cable_frontend is
  component cdc_gray_pulse is
    generic (
      N           : integer := 4;
      SRC_NEGEDGE : integer := 0;
      DST_NEGEDGE : integer := 0
    );
    port (
      src_clk   : in  std_logic;
      dst_clk   : in  std_logic;
      src_rstn  : in  std_logic;
      dst_rstn  : in  std_logic;
      src_pulse : in  std_logic;
      dst_pulse : out std_logic
    );
  end component cdc_gray_pulse;

  signal d2d_data_tx_pipe_i   : std_logic_vector(135 downto 0) := (others => '0');
  signal d2d_data_tx_oddr_i   : std_logic_vector(67 downto 0);
  signal d2d_data_tx_io_i     : std_logic_vector(67 downto 0);
  signal d2d_data_rx_io_i     : std_logic_vector(67 downto 0);
  signal d2d_data_rx_idelay_i : std_logic_vector(67 downto 0);
  signal d2d_data_rx_iddr_i   : std_logic_vector(135 downto 0);
  signal d2d_data_rx_pipe_i   : std_logic_vector(135 downto 0) := (others => '0');
  signal cable_clk_fwd_int    : std_ulogic;
  signal d2d_tx_mmcm_clkfb_out : std_ulogic;
  signal d2d_tx_mmcm_clkfb_in  : std_ulogic;
  signal d2d_tx_mmcm_clk_out   : std_ulogic;
  signal d2d_tx_mmcm_clk_fwd   : std_ulogic;
  signal d2d_tx_mmcm_locked_i  : std_ulogic;
  signal cable_clk_rcv_raw_i  : std_ulogic;
  signal cable_clk_rcv_global : std_ulogic;
  signal cable_clk_rcv_core_i : std_ulogic;
  signal d2d_rx_mmcm_clkfb_out : std_ulogic;
  signal d2d_rx_mmcm_clkfb_in  : std_ulogic;
  signal d2d_rx_mmcm_clk_out   : std_ulogic;
  signal d2d_rx_mmcm_rst_i     : std_ulogic := '1';
  signal d2d_rx_mmcm_locked_i  : std_ulogic;
  signal rx_mmcm_reset_release_count_i : unsigned(3 downto 0) := (others => '0');
  signal rx_run_i : std_ulogic := '0';
  signal credit_in_evt_rstn_pos : std_logic;

  -- attribute IOB : string;
  attribute DONT_TOUCH : string;
  attribute SHREG_EXTRACT : string;
  -- attribute IOB of d2d_data_tx_io_i : signal is "TRUE";
  attribute SHREG_EXTRACT of d2d_data_rx_pipe_i : signal is "NO";
  attribute SHREG_EXTRACT of d2d_data_tx_pipe_i : signal is "NO";
  attribute DONT_TOUCH of inst_bufgce_cap : label is "TRUE";
  attribute DONT_TOUCH of inst_bufgce_core : label is "TRUE";
begin
  credit_in_evt_rstn_pos <= d2d_rstn and d2d_rx_mmcm_locked_i and delayctrl_rdy;
  rx_run_i <= d2d_rstn and d2d_rx_mmcm_locked_i and delayctrl_rdy;

  d2d_data_rx_pipe <= d2d_data_rx_pipe_i;
  cable_clk_rcv_raw <= cable_clk_rcv_raw_i;
  cable_clk_rcv_core <= cable_clk_rcv_core_i;
  d2d_tx_mmcm_locked <= d2d_tx_mmcm_locked_i;
  d2d_rx_mmcm_locked <= d2d_rx_mmcm_locked_i;
  -- (TX MMCM bypass removed: inst_mmcm_tx drives d2d_tx_mmcm_clk_fwd and d2d_tx_mmcm_locked_i)

  gen_rx_mmcm_reset_active : if LINK_ACTIVE generate
    -- Hold the RX MMCM in reset until the forwarded raw clock has shown
    -- real activity on the pin. Deassertion then happens synchronous to
    -- cable_clk_rcv_raw_i, which is what clocks the RX MMCM itself.
    rx_mmcm_reset_release : process (cable_clk_rcv_raw_i, d2d_rst)
    begin
      if d2d_rst = '1' then
        d2d_rx_mmcm_rst_i <= '1';
        rx_mmcm_reset_release_count_i <= (others => '0');
      elsif rising_edge(cable_clk_rcv_raw_i) then
        if rx_mmcm_reset_release_count_i = to_unsigned(RX_MMCM_RESET_RELEASE_CYCLES - 1, rx_mmcm_reset_release_count_i'length) then
          d2d_rx_mmcm_rst_i <= '0';
        else
          d2d_rx_mmcm_rst_i <= '1';
          rx_mmcm_reset_release_count_i <= rx_mmcm_reset_release_count_i + 1;
        end if;
      end if;
    end process rx_mmcm_reset_release;
  end generate gen_rx_mmcm_reset_active;

  no_rx_mmcm_reset_active : if not LINK_ACTIVE generate
    d2d_rx_mmcm_rst_i <= d2d_rst;
  end generate no_rx_mmcm_reset_active;

  gen_tx_upper_pins : if TX_ON_UPPER_PINS generate
    gen_bufs : for i in 0 to 67 generate
      tx_iobuf : IOBUF
        port map (
          O  => open,
          IO => cable_io_data(i + 68),
          I  => d2d_data_tx_io_i(i),
          T  => '0'
        );
      rx_iobuf : IOBUF
        port map (
          O  => d2d_data_rx_io_i(i),
          IO => cable_io_data(i),
          I  => '0',
          T  => '1'
        );
    end generate gen_bufs;
  end generate gen_tx_upper_pins;

  gen_tx_lower_pins : if not TX_ON_UPPER_PINS generate
    gen_bufs : for i in 0 to 67 generate
      tx_iobuf : IOBUF
        port map (
          O  => open,
          IO => cable_io_data(i),
          I  => d2d_data_tx_io_i(i),
          T  => '0'
        );
      rx_iobuf : IOBUF
        port map (
          O  => d2d_data_rx_io_i(i),
          IO => cable_io_data(i + 68),
          I  => '0',
          T  => '1'
        );
    end generate gen_bufs;
  end generate gen_tx_lower_pins;

  inst_oddr_clk_fwd : ODDRE1
    generic map (
      IS_C_INVERTED   => '0',
      IS_D1_INVERTED  => '0',
      IS_D2_INVERTED  => '0',
      SIM_DEVICE      => "ULTRASCALE_PLUS",
      SRVAL           => '0'
    )
    port map (
      Q  => cable_clk_fwd_int,
      C  => d2d_tx_mmcm_clk_fwd,
      D1 => '1',
      D2 => '0',
      SR => '0'
    );

  gen_tx_ddr_regs : for i in 0 to 67 generate
    inst_oddr_data : ODDRE1
      generic map (
        IS_C_INVERTED   => '0',
        IS_D1_INVERTED  => '0',
        IS_D2_INVERTED  => '0',
        SIM_DEVICE      => "ULTRASCALE_PLUS",
        SRVAL           => '0'
      )
      port map (
        Q  => d2d_data_tx_oddr_i(i),
        C  => d2d_tx_mmcm_clk_fwd,
        D1 => d2d_data_tx_pipe_i(i + 68),
        D2 => d2d_data_tx_pipe_i(i),
        SR => '0'
      );

    inst_odelay_data : ODELAYE3
      generic map (
        CASCADE          => "NONE",
        DELAY_FORMAT     => "TIME",
        DELAY_TYPE       => "FIXED",
        DELAY_VALUE      => TX_ODELAY_PS(i),
        IS_CLK_INVERTED  => '0',
        IS_RST_INVERTED  => '0',
        REFCLK_FREQUENCY => D2D_DELAY_REFCLK_MHZ,
        SIM_DEVICE       => "ULTRASCALE_PLUS",
        UPDATE_MODE      => "ASYNC"
      )
      port map (
        CASC_OUT    => open,
        CNTVALUEOUT => open,
        DATAOUT     => d2d_data_tx_io_i(i),
        CASC_IN     => '0',
        CASC_RETURN => '0',
        CE          => '0',
        CLK         => '0',
        CNTVALUEIN  => (others => '0'),
        EN_VTC      => '1',
        INC         => '0',
        LOAD        => '0',
        ODATAIN     => d2d_data_tx_oddr_i(i),
        -- FIXED delay uses DELAY_VALUE directly; keep reset pinned low.
        RST         => '0'
      );
  end generate gen_tx_ddr_regs;

  d2d_tx_pipe_regs : process (d2d_clk_int)
  begin
    if rising_edge(d2d_clk_int) then
      if d2d_rstn_d2d = '0' or d2d_rx_mmcm_locked_i = '0' or d2d_tx_mmcm_locked_i = '0' or delayctrl_rdy = '0' then
        d2d_data_tx_pipe_i <= (others => '0');
      else
        d2d_data_tx_pipe_i <= d2d_data_tx;
      end if;
    end if;
  end process d2d_tx_pipe_regs;

  inst_mmcm_tx : MMCME4_ADV
    generic map (
      BANDWIDTH            => "LOW",
      COMPENSATION         => "ZHOLD",
      DIVCLK_DIVIDE        => 1,
      CLKFBOUT_MULT_F      => 8.000,
      CLKFBOUT_PHASE       => 0.000,
      CLKOUT0_DIVIDE_F     => 8.000,
      CLKOUT0_DUTY_CYCLE   => 0.500,
      CLKOUT0_PHASE        => TX_PHASE_DEG,
      -- CLKOUT1_DIVIDE       => 8,
      -- CLKOUT1_DUTY_CYCLE   => 0.500,
      -- CLKOUT1_PHASE        => TX_DATA_PHASE_OFFSET_DEG,
      CLKIN1_PERIOD        => CLKIN_PERIOD_NS,
      REF_JITTER1          => REF_JITTER1_UI,
      CLKFBOUT_USE_FINE_PS => "FALSE",
      CLKOUT0_USE_FINE_PS  => "FALSE",
      CLKOUT1_USE_FINE_PS  => "FALSE",
      STARTUP_WAIT         => "FALSE"
    )
    port map (
      CLKIN1   => d2d_clk_int,
      CLKIN2   => '0',
      CLKINSEL => '1',
      RST      => d2d_rst,
      PWRDWN   => '0',
      CLKFBOUT => d2d_tx_mmcm_clkfb_out,
      CLKFBIN  => d2d_tx_mmcm_clkfb_in,
      CLKOUT0  => d2d_tx_mmcm_clk_out,
      LOCKED   => d2d_tx_mmcm_locked_i,
      DADDR    => (others => '0'),
      DCLK     => '0',
      DEN      => '0',
      DI       => (others => '0'),
      DWE      => '0',
      PSCLK    => '0',
      PSEN     => '0',
      PSINCDEC => '0',
      CDDCREQ  => '0'
    );
  
  inst_bufg_tx_fb : BUFG
    port map (
      I => d2d_tx_mmcm_clkfb_out,
      O => d2d_tx_mmcm_clkfb_in
    );
  
  inst_bufgce_tx_fwd : BUFGCE
    port map (
      I  => d2d_tx_mmcm_clk_out,
      CE => d2d_tx_mmcm_locked_i,
      O  => d2d_tx_mmcm_clk_fwd
    );

  inst_obufds_clk : OBUFDS
    generic map (
      IOSTANDARD => "LVDS"
    )
    port map (
      I  => cable_clk_fwd_int,
      O  => cable_clk_p,
      OB => cable_clk_n
    );

  inst_ibufds_rcv : IBUFDS
    generic map (
      DIFF_TERM    => TRUE,
      IBUF_LOW_PWR => FALSE,
      IOSTANDARD   => "LVDS"
    )
    port map (
      I  => cable_clk_p_rcv,
      IB => cable_clk_n_rcv,
      O  => cable_clk_rcv_raw_i
    );

  inst_mmcm_rcv : MMCME4_ADV
    generic map (
      BANDWIDTH            => "LOW",
      COMPENSATION         => "ZHOLD",
      DIVCLK_DIVIDE        => 1,
      CLKFBOUT_MULT_F      => 8.000,
      CLKFBOUT_PHASE       => 0.000,
      CLKOUT0_DIVIDE_F     => 8.000,
      CLKOUT0_DUTY_CYCLE   => 0.500,
      CLKOUT0_PHASE        => RX_PHASE_DEG,
      CLKIN1_PERIOD        => CLKIN_PERIOD_NS,
      REF_JITTER1          => REF_JITTER1_UI,
      CLKFBOUT_USE_FINE_PS => "FALSE",
      CLKOUT0_USE_FINE_PS  => "FALSE",
      STARTUP_WAIT         => "FALSE"
    )
    port map (
      CLKIN1   => cable_clk_rcv_raw_i,
      CLKIN2   => '0',
      CLKINSEL => '1',
      RST      => d2d_rx_mmcm_rst_i,
      PWRDWN   => '0',
      CLKFBOUT => d2d_rx_mmcm_clkfb_out,
      CLKFBIN  => d2d_rx_mmcm_clkfb_in,
      CLKOUT0  => d2d_rx_mmcm_clk_out,
      LOCKED   => d2d_rx_mmcm_locked_i,
      DADDR    => (others => '0'),
      DCLK     => '0',
      DEN      => '0',
      DI       => (others => '0'),
      DWE      => '0',
      PSCLK    => '0',
      PSEN     => '0',
      PSINCDEC => '0',
      CDDCREQ  => '0'
    );

  inst_bufg_fb : BUFG
    port map (
      I => d2d_rx_mmcm_clkfb_out,
      O => d2d_rx_mmcm_clkfb_in
    );

  inst_bufgce_cap : BUFGCE
    port map (
      I  => d2d_rx_mmcm_clk_out,
      CE => '1',
      O  => cable_clk_rcv_global
    );

  inst_bufgce_core : BUFGCE
    port map (
      I  => d2d_rx_mmcm_clk_out,
      CE => '1',
      O  => cable_clk_rcv_core_i
    );

  gen_rx_ddr_regs : for i in 0 to 67 generate
    inst_idelay_data : IDELAYE3
      generic map (
        CASCADE          => "NONE",
        DELAY_FORMAT     => "TIME",
        -- Use the dedicated I/O-side input path into IDELAYE3. DATAIN forces
        -- Vivado to treat the source as fabric logic, which can create long
        -- routed nets from the pad buffer into the delay element.
        DELAY_SRC        => "IDATAIN",
        DELAY_TYPE       => "FIXED",
        DELAY_VALUE      => RX_IDELAY_PS(i),
        IS_CLK_INVERTED  => '0',
        IS_RST_INVERTED  => '0',
        REFCLK_FREQUENCY => D2D_DELAY_REFCLK_MHZ,
        SIM_DEVICE       => "ULTRASCALE_PLUS",
        UPDATE_MODE      => "ASYNC"
      )
      port map (
        CASC_OUT    => open,
        CNTVALUEOUT => open,
        DATAOUT     => d2d_data_rx_idelay_i(i),
        CASC_IN     => '0',
        CASC_RETURN => '0',
        CE          => '0',
        CLK         => '0',
        CNTVALUEIN  => (others => '0'),
        DATAIN      => '0',
        EN_VTC      => '1',
        IDATAIN     => d2d_data_rx_io_i(i),
        INC         => '0',
        LOAD        => '0',
        -- FIXED delay uses DELAY_VALUE directly; keep reset pinned low.
        RST         => '0'
      );

    inst_iddr_data : IDDRE1
      generic map (
        DDR_CLK_EDGE  => "SAME_EDGE",
        IS_CB_INVERTED => '1',
        IS_C_INVERTED  => '0'
      )
      port map (
        Q1 => d2d_data_rx_iddr_i(i),
        Q2 => d2d_data_rx_iddr_i(i+68),
        C  => cable_clk_rcv_global,
        CB => cable_clk_rcv_global,
        D  => d2d_data_rx_idelay_i(i),
        R  => '0'
      );
  end generate gen_rx_ddr_regs;

  rx_core_pipe_regs_p : process (cable_clk_rcv_core_i)
  begin
    if rising_edge(cable_clk_rcv_core_i) then
      if d2d_rx_mmcm_locked_i = '0' or delayctrl_rdy = '0' or rx_run_i = '0' then
        d2d_data_rx_pipe_i <= (others => '0');
      else
        d2d_data_rx_pipe_i <= d2d_data_rx_iddr_i;
      end if;
    end if;
  end process rx_core_pipe_regs_p;

  gen_credit_in_cdc : if LINK_ACTIVE generate
  begin
    gen_credit_lane : for lane in 0 to 1 generate
      constant CREDIT_BIT : integer := 66 + 68*lane;
    begin
      credit_in_cdc_i : cdc_gray_pulse
        generic map (
          N           => CREDIT_CDC_N,
          SRC_NEGEDGE => 0,
          DST_NEGEDGE => 0
        )
        port map (
          src_clk   => cable_clk_rcv_core_i,
          dst_clk   => d2d_clk_int,
          src_rstn  => credit_in_evt_rstn_pos,
          dst_rstn  => d2d_rstn_d2d,
          src_pulse => d2d_data_rx_pipe_i(CREDIT_BIT),
          dst_pulse => credit_in_evt_pulse_d2d(lane)
        );
    end generate gen_credit_lane;
  end generate gen_credit_in_cdc;

  no_credit_in_cdc : if not LINK_ACTIVE generate
  begin
    credit_in_evt_pulse_d2d <= (others => '0');
  end generate no_credit_in_cdc;
end architecture rtl;

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.nocpackage.all;

entity d2d_cable_direction_map is
  generic (
    C0_IS_WEST   : boolean;
    C1_IS_NORTH  : boolean;
    ISOLATE_LINKS : boolean := false
  );
  port (
    c0_d2d_data_rx_pipe              : in  std_logic_vector(135 downto 0);
    c1_d2d_data_rx_pipe              : in  std_logic_vector(135 downto 0);
    c0_credit_in_evt_pulse_d2d       : in  std_logic_vector(1 downto 0);
    c1_credit_in_evt_pulse_d2d       : in  std_logic_vector(1 downto 0);
    cable_clk_rcv_core_0             : in  std_ulogic;
    cable_clk_rcv_core_1             : in  std_ulogic;
    chiplet_data_n_in                : out coh_noc_flit_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_in_n              : out std_logic_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_in_n               : out std_logic_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_s_in                : out coh_noc_flit_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_in_s              : out std_logic_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_in_s               : out std_logic_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_w_in                : out coh_noc_flit_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_in_w              : out std_logic_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_in_w               : out std_logic_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_e_in                : out coh_noc_flit_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_in_e              : out std_logic_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_in_e               : out std_logic_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_n_out               : in  coh_noc_flit_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_out_n              : in  std_logic_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_s_out               : in  coh_noc_flit_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_out_s              : in  std_logic_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_w_out               : in  coh_noc_flit_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_out_w              : in  std_logic_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_e_out               : in  coh_noc_flit_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_out_e              : in  std_logic_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_out_n_evt_pulse_d2d : in std_logic_vector(1 downto 0);
    chiplet_credit_out_s_evt_pulse_d2d : in std_logic_vector(1 downto 0);
    chiplet_credit_out_w_evt_pulse_d2d : in std_logic_vector(1 downto 0);
    chiplet_credit_out_e_evt_pulse_d2d : in std_logic_vector(1 downto 0);
    c0_d2d_data_tx                   : out std_logic_vector(135 downto 0);
    c1_d2d_data_tx                   : out std_logic_vector(135 downto 0);
    d2d_clk_n_in_int                 : out std_ulogic;
    d2d_clk_s_in_int                 : out std_ulogic;
    d2d_clk_w_in_int                 : out std_ulogic;
    d2d_clk_e_in_int                 : out std_ulogic
  );
end entity d2d_cable_direction_map;

architecture rtl of d2d_cable_direction_map is
begin
  gen_isolated : if ISOLATE_LINKS generate
    zero_loop : for i in 0 to WIRES_PER_CONNECTION-1 generate
      chiplet_data_n_in(2*i) <= (others => '0');
      chiplet_data_n_in(2*i+1) <= (others => '0');
      chiplet_credit_in_n(2*i) <= '0';
      chiplet_credit_in_n(2*i+1) <= '0';
      chiplet_valid_in_n(2*i) <= '0';
      chiplet_valid_in_n(2*i+1) <= '0';
      chiplet_data_s_in(2*i) <= (others => '0');
      chiplet_data_s_in(2*i+1) <= (others => '0');
      chiplet_credit_in_s(2*i) <= '0';
      chiplet_credit_in_s(2*i+1) <= '0';
      chiplet_valid_in_s(2*i) <= '0';
      chiplet_valid_in_s(2*i+1) <= '0';
      chiplet_data_w_in(2*i) <= (others => '0');
      chiplet_data_w_in(2*i+1) <= (others => '0');
      chiplet_credit_in_w(2*i) <= '0';
      chiplet_credit_in_w(2*i+1) <= '0';
      chiplet_valid_in_w(2*i) <= '0';
      chiplet_valid_in_w(2*i+1) <= '0';
      chiplet_data_e_in(2*i) <= (others => '0');
      chiplet_data_e_in(2*i+1) <= (others => '0');
      chiplet_credit_in_e(2*i) <= '0';
      chiplet_credit_in_e(2*i+1) <= '0';
      chiplet_valid_in_e(2*i) <= '0';
      chiplet_valid_in_e(2*i+1) <= '0';
    end generate zero_loop;

    c0_d2d_data_tx <= (others => '0');
    c1_d2d_data_tx <= (others => '0');
    d2d_clk_n_in_int <= '0';
    d2d_clk_s_in_int <= '0';
    d2d_clk_w_in_int <= '0';
    d2d_clk_e_in_int <= '0';
  end generate gen_isolated;

  gen_connected : if not ISOLATE_LINKS generate
    lane_map : for i in 0 to WIRES_PER_CONNECTION-1 generate
      active_lane : if i = 0 generate
        chiplet_data_n_in(2*i) <= c1_d2d_data_rx_pipe(65 downto 0) when C1_IS_NORTH else (others => '0');
        chiplet_credit_in_n(2*i) <= c1_credit_in_evt_pulse_d2d(0) when C1_IS_NORTH else '0';
        chiplet_valid_in_n(2*i) <= c1_d2d_data_rx_pipe(67) when C1_IS_NORTH else '0';
        chiplet_data_n_in(2*i+1) <= c1_d2d_data_rx_pipe(133 downto 68) when C1_IS_NORTH else (others => '0');
        chiplet_credit_in_n(2*i+1) <= c1_credit_in_evt_pulse_d2d(1) when C1_IS_NORTH else '0';
        chiplet_valid_in_n(2*i+1) <= c1_d2d_data_rx_pipe(135) when C1_IS_NORTH else '0';

        chiplet_data_s_in(2*i) <= c1_d2d_data_rx_pipe(65 downto 0) when not C1_IS_NORTH else (others => '0');
        chiplet_credit_in_s(2*i) <= c1_credit_in_evt_pulse_d2d(0) when not C1_IS_NORTH else '0';
        chiplet_valid_in_s(2*i) <= c1_d2d_data_rx_pipe(67) when not C1_IS_NORTH else '0';
        chiplet_data_s_in(2*i+1) <= c1_d2d_data_rx_pipe(133 downto 68) when not C1_IS_NORTH else (others => '0');
        chiplet_credit_in_s(2*i+1) <= c1_credit_in_evt_pulse_d2d(1) when not C1_IS_NORTH else '0';
        chiplet_valid_in_s(2*i+1) <= c1_d2d_data_rx_pipe(135) when not C1_IS_NORTH else '0';

        chiplet_data_w_in(2*i) <= c0_d2d_data_rx_pipe(65 downto 0) when C0_IS_WEST else (others => '0');
        chiplet_credit_in_w(2*i) <= c0_credit_in_evt_pulse_d2d(0) when C0_IS_WEST else '0';
        chiplet_valid_in_w(2*i) <= c0_d2d_data_rx_pipe(67) when C0_IS_WEST else '0';
        chiplet_data_w_in(2*i+1) <= c0_d2d_data_rx_pipe(133 downto 68) when C0_IS_WEST else (others => '0');
        chiplet_credit_in_w(2*i+1) <= c0_credit_in_evt_pulse_d2d(1) when C0_IS_WEST else '0';
        chiplet_valid_in_w(2*i+1) <= c0_d2d_data_rx_pipe(135) when C0_IS_WEST else '0';

        chiplet_data_e_in(2*i) <= c0_d2d_data_rx_pipe(65 downto 0) when not C0_IS_WEST else (others => '0');
        chiplet_credit_in_e(2*i) <= c0_credit_in_evt_pulse_d2d(0) when not C0_IS_WEST else '0';
        chiplet_valid_in_e(2*i) <= c0_d2d_data_rx_pipe(67) when not C0_IS_WEST else '0';
        chiplet_data_e_in(2*i+1) <= c0_d2d_data_rx_pipe(133 downto 68) when not C0_IS_WEST else (others => '0');
        chiplet_credit_in_e(2*i+1) <= c0_credit_in_evt_pulse_d2d(1) when not C0_IS_WEST else '0';
        chiplet_valid_in_e(2*i+1) <= c0_d2d_data_rx_pipe(135) when not C0_IS_WEST else '0';

        c1_d2d_data_tx(65 downto 0) <= chiplet_data_n_out(2*i) when C1_IS_NORTH else chiplet_data_s_out(2*i);
        c1_d2d_data_tx(66) <= chiplet_credit_out_n_evt_pulse_d2d(0) when C1_IS_NORTH else chiplet_credit_out_s_evt_pulse_d2d(0);
        c1_d2d_data_tx(67) <= chiplet_valid_out_n(2*i) when C1_IS_NORTH else chiplet_valid_out_s(2*i);
        c1_d2d_data_tx(133 downto 68) <= chiplet_data_n_out(2*i+1) when C1_IS_NORTH else chiplet_data_s_out(2*i+1);
        c1_d2d_data_tx(134) <= chiplet_credit_out_n_evt_pulse_d2d(1) when C1_IS_NORTH else chiplet_credit_out_s_evt_pulse_d2d(1);
        c1_d2d_data_tx(135) <= chiplet_valid_out_n(2*i+1) when C1_IS_NORTH else chiplet_valid_out_s(2*i+1);

        c0_d2d_data_tx(65 downto 0) <= chiplet_data_w_out(2*i) when C0_IS_WEST else chiplet_data_e_out(2*i);
        c0_d2d_data_tx(66) <= chiplet_credit_out_w_evt_pulse_d2d(0) when C0_IS_WEST else chiplet_credit_out_e_evt_pulse_d2d(0);
        c0_d2d_data_tx(67) <= chiplet_valid_out_w(2*i) when C0_IS_WEST else chiplet_valid_out_e(2*i);
        c0_d2d_data_tx(133 downto 68) <= chiplet_data_w_out(2*i+1) when C0_IS_WEST else chiplet_data_e_out(2*i+1);
        c0_d2d_data_tx(134) <= chiplet_credit_out_w_evt_pulse_d2d(1) when C0_IS_WEST else chiplet_credit_out_e_evt_pulse_d2d(1);
        c0_d2d_data_tx(135) <= chiplet_valid_out_w(2*i+1) when C0_IS_WEST else chiplet_valid_out_e(2*i+1);
      end generate active_lane;

      unused_lane : if i > 0 generate
        chiplet_data_n_in(2*i) <= (others => '0');
        chiplet_data_n_in(2*i+1) <= (others => '0');
        chiplet_credit_in_n(2*i) <= '0';
        chiplet_credit_in_n(2*i+1) <= '0';
        chiplet_valid_in_n(2*i) <= '0';
        chiplet_valid_in_n(2*i+1) <= '0';
        chiplet_data_s_in(2*i) <= (others => '0');
        chiplet_data_s_in(2*i+1) <= (others => '0');
        chiplet_credit_in_s(2*i) <= '0';
        chiplet_credit_in_s(2*i+1) <= '0';
        chiplet_valid_in_s(2*i) <= '0';
        chiplet_valid_in_s(2*i+1) <= '0';
        chiplet_data_w_in(2*i) <= (others => '0');
        chiplet_data_w_in(2*i+1) <= (others => '0');
        chiplet_credit_in_w(2*i) <= '0';
        chiplet_credit_in_w(2*i+1) <= '0';
        chiplet_valid_in_w(2*i) <= '0';
        chiplet_valid_in_w(2*i+1) <= '0';
        chiplet_data_e_in(2*i) <= (others => '0');
        chiplet_data_e_in(2*i+1) <= (others => '0');
        chiplet_credit_in_e(2*i) <= '0';
        chiplet_credit_in_e(2*i+1) <= '0';
        chiplet_valid_in_e(2*i) <= '0';
        chiplet_valid_in_e(2*i+1) <= '0';
      end generate unused_lane;
    end generate lane_map;

    d2d_clk_n_in_int <= cable_clk_rcv_core_1 when C1_IS_NORTH else '0';
    d2d_clk_s_in_int <= cable_clk_rcv_core_1 when not C1_IS_NORTH else '0';
    d2d_clk_w_in_int <= cable_clk_rcv_core_0 when C0_IS_WEST else '0';
    d2d_clk_e_in_int <= cable_clk_rcv_core_0 when not C0_IS_WEST else '0';
  end generate gen_connected;
end architecture rtl;

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.nocpackage.all;

entity d2d_direction_link is
  generic (
    CHANNELS      : integer;
    TILES         : integer;
    D2D_POSITION  : std_logic_vector(1 downto 0);
    LOCAL_CHIP_Y  : chip_yx;
    LOCAL_CHIP_X  : chip_yx;
    MAX_DIM       : local_yx
  );
  port (
    clk                 : in  std_ulogic;
    rst                 : in  std_ulogic;
    d2d_rst             : in  std_ulogic;
    d2d_clk_tx_in       : in  std_ulogic;
    d2d_clk_rx_in       : in  std_ulogic;
    chiplet_data_in     : in  coh_noc_flit_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_in   : in  std_logic_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_in    : in  std_logic_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_out    : out coh_noc_flit_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_out  : out std_logic_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_out   : out std_logic_vector(2*WIRES_PER_CONNECTION-1 downto 0);
    tx_link_ready       : out std_logic;
    rx_link_ready       : out std_logic;
    noc1_data_in        : in  coh_noc_flit_vector(TILES-1 downto 0);
    noc2_data_in        : in  coh_noc_flit_vector(TILES-1 downto 0);
    noc3_data_in        : in  coh_noc_flit_vector(TILES-1 downto 0);
    noc4_data_in        : in  dma_noc_flit_vector(TILES-1 downto 0);
    noc5_data_in        : in  misc_noc_flit_vector(TILES-1 downto 0);
    noc6_data_in        : in  dma_noc_flit_vector(TILES-1 downto 0);
    noc1_data_void_in   : in  std_logic_vector(TILES-1 downto 0);
    noc2_data_void_in   : in  std_logic_vector(TILES-1 downto 0);
    noc3_data_void_in   : in  std_logic_vector(TILES-1 downto 0);
    noc4_data_void_in   : in  std_logic_vector(TILES-1 downto 0);
    noc5_data_void_in   : in  std_logic_vector(TILES-1 downto 0);
    noc6_data_void_in   : in  std_logic_vector(TILES-1 downto 0);
    bypass_data_in      : in  coh_noc_flit_type;
    dmabypass_data_in   : in  std_logic_vector((2*COH_NOC_FLIT_SIZE)-1 downto 0);
    bypass_data_void_in : in  std_logic;
    dmabypass_data_void_in : in  std_logic;
    noc1_stop_out       : out std_logic_vector(TILES-1 downto 0);
    noc2_stop_out       : out std_logic_vector(TILES-1 downto 0);
    noc3_stop_out       : out std_logic_vector(TILES-1 downto 0);
    noc4_stop_out       : out std_logic_vector(TILES-1 downto 0);
    noc5_stop_out       : out std_logic_vector(TILES-1 downto 0);
    noc6_stop_out       : out std_logic_vector(TILES-1 downto 0);
    bypass_stop_out     : out std_logic;
    dmabypass_stop_out  : out std_logic;
    noc1_data_out       : out coh_noc_flit_vector(TILES-1 downto 0);
    noc2_data_out       : out coh_noc_flit_vector(TILES-1 downto 0);
    noc3_data_out       : out coh_noc_flit_vector(TILES-1 downto 0);
    noc4_data_out       : out dma_noc_flit_vector(TILES-1 downto 0);
    noc5_data_out       : out misc_noc_flit_vector(TILES-1 downto 0);
    noc6_data_out       : out dma_noc_flit_vector(TILES-1 downto 0);
    noc1_data_void_out  : out std_logic_vector(TILES-1 downto 0);
    noc2_data_void_out  : out std_logic_vector(TILES-1 downto 0);
    noc3_data_void_out  : out std_logic_vector(TILES-1 downto 0);
    noc4_data_void_out  : out std_logic_vector(TILES-1 downto 0);
    noc5_data_void_out  : out std_logic_vector(TILES-1 downto 0);
    noc6_data_void_out  : out std_logic_vector(TILES-1 downto 0);
    bypass_data_out     : out coh_noc_flit_type;
    dmabypass_data_out  : out std_logic_vector((2*COH_NOC_FLIT_SIZE)-1 downto 0);
    bypass_data_void_out : out std_logic;
    dmabypass_data_void_out : out std_logic;
    noc1_stop_in        : in  std_logic_vector(TILES-1 downto 0);
    noc2_stop_in        : in  std_logic_vector(TILES-1 downto 0);
    noc3_stop_in        : in  std_logic_vector(TILES-1 downto 0);
    noc4_stop_in        : in  std_logic_vector(TILES-1 downto 0);
    noc5_stop_in        : in  std_logic_vector(TILES-1 downto 0);
    noc6_stop_in        : in  std_logic_vector(TILES-1 downto 0);
    bypass_stop_in      : in  std_logic;
    dmabypass_stop_in   : in  std_logic
  );
end entity d2d_direction_link;

architecture rtl of d2d_direction_link is
  component d2d_tx_top is
    generic (
      TXCHANNELS   : integer;
      TILES        : integer;
      flow_control : integer;
      chwidth      : integer;
      cohwidth     : integer;
      miscwidth    : integer;
      dmawidth     : integer;
      d2d_position   : std_logic_vector(1 downto 0);
      local_chip_y   : chip_yx;
      local_chip_x   : chip_yx
    );
    port (
      clk                 : in  std_ulogic;
      rst                 : in  std_ulogic;
      d2d_rst             : in  std_ulogic;
      d2d_clk_in          : in  std_ulogic;
      d2d_snd_data_out    : out coh_noc_flit_vector(2*TXCHANNELS-1 downto 0);
      d2d_valid_out       : out std_logic_vector(2*TXCHANNELS-1 downto 0);
      d2d_link_ready      : out std_logic;
      d2d_credit_in       : in  std_logic_vector(2*TXCHANNELS-1 downto 0);
      noc1_data_in        : in  coh_noc_flit_vector(TILES-1 downto 0);
      noc2_data_in        : in  coh_noc_flit_vector(TILES-1 downto 0);
      noc3_data_in        : in  coh_noc_flit_vector(TILES-1 downto 0);
      noc4_data_in        : in  dma_noc_flit_vector(TILES-1 downto 0);
      noc5_data_in        : in  misc_noc_flit_vector(TILES-1 downto 0);
      noc6_data_in        : in  dma_noc_flit_vector(TILES-1 downto 0);
      bypass_data_in      : in  coh_noc_flit_type;
      dmabypass_data_in   : in  std_logic_vector((2*chwidth)-1 downto 0);
      noc1_data_void_in   : in  std_logic_vector(TILES-1 downto 0);
      noc2_data_void_in   : in  std_logic_vector(TILES-1 downto 0);
      noc3_data_void_in   : in  std_logic_vector(TILES-1 downto 0);
      noc4_data_void_in   : in  std_logic_vector(TILES-1 downto 0);
      noc5_data_void_in   : in  std_logic_vector(TILES-1 downto 0);
      noc6_data_void_in   : in  std_logic_vector(TILES-1 downto 0);
      bypass_data_void_in : in  std_logic;
      dmabypass_data_void_in : in  std_logic;
      noc1_stop_out       : out std_logic_vector(TILES-1 downto 0);
      noc2_stop_out       : out std_logic_vector(TILES-1 downto 0);
      noc3_stop_out       : out std_logic_vector(TILES-1 downto 0);
      noc4_stop_out       : out std_logic_vector(TILES-1 downto 0);
      noc5_stop_out       : out std_logic_vector(TILES-1 downto 0);
      noc6_stop_out       : out std_logic_vector(TILES-1 downto 0);
      bypass_stop_out     : out std_logic;
      dmabypass_stop_out  : out std_logic
    );
  end component d2d_tx_top;

  component d2d_rx_top is
    generic (
      d2d_position   : std_logic_vector(1 downto 0);
      local_chip_y   : chip_yx;
      local_chip_x   : chip_yx;
      max_dim        : local_yx;
      RXCHANNELS     : integer;
      TILES          : integer;
      flow_control   : integer;
      chwidth        : integer;
      cohwidth       : integer;
      miscwidth      : integer;
      dmawidth       : integer
    );
    port (
      clk                 : in  std_ulogic;
      rst                 : in  std_ulogic;
      d2d_rst             : in  std_ulogic;
      d2d_clk_in          : in  std_ulogic;
      d2d_rcv_data_in     : in  coh_noc_flit_vector(2*RXCHANNELS-1 downto 0);
      d2d_valid_in        : in  std_logic_vector(2*RXCHANNELS-1 downto 0);
      d2d_link_ready      : out std_logic;
      d2d_credit_out      : out std_logic_vector(2*RXCHANNELS-1 downto 0);
      noc1_data_out       : out coh_noc_flit_vector(TILES-1 downto 0);
      noc2_data_out       : out coh_noc_flit_vector(TILES-1 downto 0);
      noc3_data_out       : out coh_noc_flit_vector(TILES-1 downto 0);
      noc4_data_out       : out dma_noc_flit_vector(TILES-1 downto 0);
      noc5_data_out       : out misc_noc_flit_vector(TILES-1 downto 0);
      noc6_data_out       : out dma_noc_flit_vector(TILES-1 downto 0);
      bypass_data_out     : out coh_noc_flit_type;
      dmabypass_data_out  : out std_logic_vector((2*chwidth)-1 downto 0);
      noc1_data_void_out  : out std_logic_vector(TILES-1 downto 0);
      noc2_data_void_out  : out std_logic_vector(TILES-1 downto 0);
      noc3_data_void_out  : out std_logic_vector(TILES-1 downto 0);
      noc4_data_void_out  : out std_logic_vector(TILES-1 downto 0);
      noc5_data_void_out  : out std_logic_vector(TILES-1 downto 0);
      noc6_data_void_out  : out std_logic_vector(TILES-1 downto 0);
      bypass_data_void_out : out std_logic;
      dmabypass_data_void_out : out std_logic;
      noc1_stop_in        : in std_logic_vector(TILES-1 downto 0);
      noc2_stop_in        : in std_logic_vector(TILES-1 downto 0);
      noc3_stop_in        : in std_logic_vector(TILES-1 downto 0);
      noc4_stop_in        : in std_logic_vector(TILES-1 downto 0);
      noc5_stop_in        : in std_logic_vector(TILES-1 downto 0);
      noc6_stop_in        : in std_logic_vector(TILES-1 downto 0);
      bypass_stop_in      : in std_logic;
      dmabypass_stop_in   : in std_logic
    );
  end component d2d_rx_top;
begin
  gen_link_present : if CHANNELS > 0 generate
  begin
    assert CHANNELS <= WIRES_PER_CONNECTION
      report "d2d_direction_link expects CHANNELS to fit inside WIRES_PER_CONNECTION"
      severity failure;

    d2d_tx_i : d2d_tx_top
      generic map (
        TXCHANNELS   => CHANNELS,
        TILES        => TILES,
        flow_control => 0,
        chwidth      => COH_NOC_FLIT_SIZE,
        cohwidth     => COH_NOC_FLIT_SIZE,
        miscwidth    => MISC_NOC_FLIT_SIZE,
        dmawidth     => DMA_NOC_FLIT_SIZE,
        d2d_position => D2D_POSITION,
        local_chip_y => LOCAL_CHIP_Y,
        local_chip_x => LOCAL_CHIP_X
      )
      port map (
        clk                 => clk,
        rst                 => rst,
        d2d_rst             => d2d_rst,
        d2d_clk_in          => d2d_clk_tx_in,
        d2d_snd_data_out    => chiplet_data_out(2*CHANNELS-1 downto 0),
        d2d_valid_out       => chiplet_valid_out(2*CHANNELS-1 downto 0),
        d2d_link_ready      => tx_link_ready,
        d2d_credit_in       => chiplet_credit_in(2*CHANNELS-1 downto 0),
        noc1_data_in        => noc1_data_in,
        noc2_data_in        => noc2_data_in,
        noc3_data_in        => noc3_data_in,
        noc4_data_in        => noc4_data_in,
        noc5_data_in        => noc5_data_in,
        noc6_data_in        => noc6_data_in,
        bypass_data_in      => bypass_data_in,
        dmabypass_data_in   => dmabypass_data_in,
        noc1_data_void_in   => noc1_data_void_in,
        noc2_data_void_in   => noc2_data_void_in,
        noc3_data_void_in   => noc3_data_void_in,
        noc4_data_void_in   => noc4_data_void_in,
        noc5_data_void_in   => noc5_data_void_in,
        noc6_data_void_in   => noc6_data_void_in,
        bypass_data_void_in => bypass_data_void_in,
        dmabypass_data_void_in => dmabypass_data_void_in,
        noc1_stop_out       => noc1_stop_out,
        noc2_stop_out       => noc2_stop_out,
        noc3_stop_out       => noc3_stop_out,
        noc4_stop_out       => noc4_stop_out,
        noc5_stop_out       => noc5_stop_out,
        noc6_stop_out       => noc6_stop_out,
        bypass_stop_out     => bypass_stop_out,
        dmabypass_stop_out  => dmabypass_stop_out
      );

    d2d_rx_i : d2d_rx_top
      generic map (
        d2d_position => D2D_POSITION,
        local_chip_y => LOCAL_CHIP_Y,
        local_chip_x => LOCAL_CHIP_X,
        max_dim      => MAX_DIM,
        RXCHANNELS   => CHANNELS,
        TILES        => TILES,
        flow_control => 0,
        chwidth      => COH_NOC_FLIT_SIZE,
        cohwidth     => COH_NOC_FLIT_SIZE,
        miscwidth    => MISC_NOC_FLIT_SIZE,
        dmawidth     => DMA_NOC_FLIT_SIZE
      )
      port map (
        clk                  => clk,
        rst                  => rst,
        d2d_rst              => d2d_rst,
        d2d_clk_in           => d2d_clk_rx_in,
        d2d_rcv_data_in      => chiplet_data_in(2*CHANNELS-1 downto 0),
        d2d_valid_in         => chiplet_valid_in(2*CHANNELS-1 downto 0),
        d2d_link_ready       => rx_link_ready,
        d2d_credit_out       => chiplet_credit_out(2*CHANNELS-1 downto 0),
        noc1_data_out        => noc1_data_out,
        noc2_data_out        => noc2_data_out,
        noc3_data_out        => noc3_data_out,
        noc4_data_out        => noc4_data_out,
        noc5_data_out        => noc5_data_out,
        noc6_data_out        => noc6_data_out,
        bypass_data_out      => bypass_data_out,
        dmabypass_data_out   => dmabypass_data_out,
        noc1_data_void_out   => noc1_data_void_out,
        noc2_data_void_out   => noc2_data_void_out,
        noc3_data_void_out   => noc3_data_void_out,
        noc4_data_void_out   => noc4_data_void_out,
        noc5_data_void_out   => noc5_data_void_out,
        noc6_data_void_out   => noc6_data_void_out,
        bypass_data_void_out => bypass_data_void_out,
        dmabypass_data_void_out => dmabypass_data_void_out,
        noc1_stop_in         => noc1_stop_in,
        noc2_stop_in         => noc2_stop_in,
        noc3_stop_in         => noc3_stop_in,
        noc4_stop_in         => noc4_stop_in,
        noc5_stop_in         => noc5_stop_in,
        noc6_stop_in         => noc6_stop_in,
        bypass_stop_in       => bypass_stop_in,
        dmabypass_stop_in    => dmabypass_stop_in
      );
  end generate gen_link_present;

  gen_link_absent : if CHANNELS = 0 generate
  begin
    chiplet_data_out <= (others => (others => '0'));
    chiplet_valid_out <= (others => '0');
    chiplet_credit_out <= (others => '0');
    bypass_data_out <= (others => '0');
    dmabypass_data_out <= (others => '0');
    bypass_data_void_out <= '1';
    dmabypass_data_void_out <= '1';
    bypass_stop_out <= '1';
    dmabypass_stop_out <= '1';
    noc1_data_out <= (others => (others => '0'));
    noc2_data_out <= (others => (others => '0'));
    noc3_data_out <= (others => (others => '0'));
    noc4_data_out <= (others => (others => '0'));
    noc5_data_out <= (others => (others => '0'));
    noc6_data_out <= (others => (others => '0'));
    noc1_data_void_out <= (others => '1');
    noc2_data_void_out <= (others => '1');
    noc3_data_void_out <= (others => '1');
    noc4_data_void_out <= (others => '1');
    noc5_data_void_out <= (others => '1');
    noc6_data_void_out <= (others => '1');
    noc1_stop_out <= (others => '0');
    noc2_stop_out <= (others => '0');
    noc3_stop_out <= (others => '0');
    noc4_stop_out <= (others => '0');
    noc5_stop_out <= (others => '0');
    noc6_stop_out <= (others => '0');
    tx_link_ready <= '1';
    rx_link_ready <= '1';
  end generate gen_link_absent;
end architecture rtl;
