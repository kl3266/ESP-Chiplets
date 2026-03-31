-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

------------------------------------------------------------------------------
--  ESP - proFPGA - XCVU19P chiplets
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.grlib_config.all;
use work.amba.all;
use work.stdlib.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.uart.all;
use work.misc.all;
use work.net.all;
library unisim;
-- pragma translate_off
use work.sim.all;
-- pragma translate_on
use unisim.VCOMPONENTS.all;
use work.monitor_pkg.all;
use work.sldacc.all;
use work.tile.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.coretypes.all;
use work.config.all;
use work.esp_global.all;
use work.socmap.all;
use work.tiles_pkg.all;

entity top_satellite is
  generic (
    SIMULATION : boolean := false;
    BOARD_NUM  : integer := 0
    );
  port (
    -- MMI64 interface:
    profpga_clk0_p    : in    std_ulogic;  -- 100 MHz clock
    profpga_clk0_n    : in    std_ulogic;  -- 100 MHz clock
    profpga_sync0_p   : in    std_ulogic;
    profpga_sync0_n   : in    std_ulogic;
    dmbi_h2f          : in    std_logic_vector(19 downto 0);
    dmbi_f2h          : out   std_logic_vector(19 downto 0);
    -- Main ESP clock
    esp_clk_p         : in    std_ulogic;  -- 100 MHz clock
    esp_clk_n         : in    std_ulogic;  -- 100 MHz clock
    d2d_clk_p         : in    std_ulogic;  -- 160 MHz D2D clock
    d2d_clk_n         : in    std_ulogic;  -- 160 MHz D2D clock
    -- IO Cables
    c0_cable_clk_p      : out     std_logic; -- TX Clock
    c0_cable_clk_n      : out     std_logic;
    c0_cable_clk_p_rcv  : in      std_logic; -- RX Clock
    c0_cable_clk_n_rcv  : in      std_logic;
    c0_cable_io_data    : inout   std_logic_vector(135 downto 0);

    c1_cable_clk_p      : out     std_logic; -- TX Clock
    c1_cable_clk_n      : out     std_logic;
    c1_cable_clk_p_rcv  : in      std_logic; -- RX Clock
    c1_cable_clk_n_rcv  : in      std_logic;
    c1_cable_io_data    : inout   std_logic_vector(135 downto 0);
    -- DDR4
    reset             : in    std_ulogic;

    c0_sys_clk_p      : in    std_logic;   -- 125 MHz clock
    c0_sys_clk_n      : in    std_logic;   -- 125 MHz clock
    c0_ddr4_act_n     : out   std_logic;
    c0_ddr4_adr       : out   std_logic_vector(16 downto 0);
    c0_ddr4_ba        : out   std_logic_vector(1 downto 0);
    c0_ddr4_bg        : out   std_logic_vector(1 downto 0);
    c0_ddr4_cke       : out   std_logic_vector(1 downto 0);
    c0_ddr4_odt       : out   std_logic_vector(1 downto 0);
    c0_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
    c0_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
    c0_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
    c0_ddr4_reset_n   : out   std_logic;
    c0_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
    c0_ddr4_dq        : inout std_logic_vector(71 downto 0);
    c0_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
    c0_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
    c0_calib_complete : out   std_logic;
    c0_diagnostic_led : out   std_ulogic;
    LED_RED    : out std_ulogic;
    LED_GREEN  : out std_ulogic;
    LED_BLUE   : out std_ulogic;
    LED_YELLOW : out std_ulogic
    );
end;


architecture rtl of top_satellite is
  function select_d2d_rx_mmcm_phase (
    board_num : integer;
    phase_board0 : real;
    phase_board1 : real;
    phase_board2 : real;
    phase_board3 : real
  ) return real is
  begin
    case board_num is
      when 0 =>
        return phase_board0;
      when 1 =>
        return phase_board1;
      when 2 =>
        return phase_board2;
      when others =>
        return phase_board3;
    end case;
  end function select_d2d_rx_mmcm_phase;

  constant D2D_RX_MMCM_CLKIN_PERIOD_NS : real := 6.250;
  constant D2D_RX_MMCM_REF_JITTER1_UI  : real := 0.050;
  constant D2D_RX_MMCM_PHASE_DEG_BOARD0_C0 : real := -78.750;
  constant D2D_RX_MMCM_PHASE_DEG_BOARD0_C1 : real := -56.250;
  constant D2D_RX_MMCM_PHASE_DEG_BOARD1_C0 : real := 39.375;
  constant D2D_RX_MMCM_PHASE_DEG_BOARD1_C1 : real := 33.750;
  constant D2D_RX_MMCM_PHASE_DEG_BOARD2_C0 : real := 39.375;
  constant D2D_RX_MMCM_PHASE_DEG_BOARD2_C1 : real := 39.375;
  constant D2D_RX_MMCM_PHASE_DEG_BOARD3_C0 : real := 39.375;
  constant D2D_RX_MMCM_PHASE_DEG_BOARD3_C1 : real := 39.375;
  constant D2D_RX_MMCM_PHASE_DEG_C0 : real :=
    select_d2d_rx_mmcm_phase(
      BOARD_NUM,
      D2D_RX_MMCM_PHASE_DEG_BOARD0_C0,
      D2D_RX_MMCM_PHASE_DEG_BOARD1_C0,
      D2D_RX_MMCM_PHASE_DEG_BOARD2_C0,
      D2D_RX_MMCM_PHASE_DEG_BOARD3_C0
    );
  constant D2D_RX_MMCM_PHASE_DEG_C1 : real :=
    select_d2d_rx_mmcm_phase(
      BOARD_NUM,
      D2D_RX_MMCM_PHASE_DEG_BOARD0_C1,
      D2D_RX_MMCM_PHASE_DEG_BOARD1_C1,
      D2D_RX_MMCM_PHASE_DEG_BOARD2_C1,
      D2D_RX_MMCM_PHASE_DEG_BOARD3_C1
    );
  constant ISOLATE_BOARD0_D2D    : boolean := false; -- temporary debug mode: board0 D2D links tied off

  component ahb2mig_ebddr4r5 is
    generic (
      hindex : integer;
      haddr  : integer;
      hmask  : integer
      );
    port (
      c0_sys_clk_p     : in    std_logic;
      c0_sys_clk_n     : in    std_logic;
      c0_ddr4_act_n    : out   std_logic;
      c0_ddr4_adr      : out   std_logic_vector(16 downto 0);
      c0_ddr4_ba       : out   std_logic_vector(1 downto 0);
      c0_ddr4_bg       : out   std_logic_vector(1 downto 0);
      c0_ddr4_cke      : out   std_logic_vector(1 downto 0);
      c0_ddr4_odt      : out   std_logic_vector(1 downto 0);
      c0_ddr4_cs_n     : out   std_logic_vector(1 downto 0);
      c0_ddr4_ck_t     : out   std_logic_vector(0 downto 0);
      c0_ddr4_ck_c     : out   std_logic_vector(0 downto 0);
      c0_ddr4_reset_n  : out   std_logic;
      c0_ddr4_dm_dbi_n : inout std_logic_vector(8 downto 0);
      c0_ddr4_dq       : inout std_logic_vector(71 downto 0);
      c0_ddr4_dqs_c    : inout std_logic_vector(8 downto 0);
      c0_ddr4_dqs_t    : inout std_logic_vector(8 downto 0);
      ahbso            : out   ahb_slv_out_type;
      ahbsi            : in    ahb_slv_in_type;
      calib_done       : out   std_logic;
      rst_n_syn        : in    std_logic;
      rst_n_async      : in    std_logic;
      clk_amba         : in    std_logic;
      ui_clk           : out   std_logic;
      ui_clk_sync_rst  : out   std_logic);
  end component ahb2mig_ebddr4r5;

  component bypass_router
    generic (
      flow_control : integer; -- 0 = AN; 1 = CB
      width        : integer;
      depth        : integer;
      ports        : std_logic_vector(3 downto 0); -- N, S, W, E
      DEST_SIZE    : integer
    );
    port (
      clk : in std_ulogic;
      rst : in std_ulogic;
      CONST_local_chip_x : in chip_yx;
      CONST_local_chip_y : in chip_yx;

      data_n_in : in std_logic_vector(width-1 downto 0);
      data_s_in : in std_logic_vector(width-1 downto 0);
      data_w_in : in std_logic_vector(width-1 downto 0);
      data_e_in : in std_logic_vector(width-1 downto 0);

      data_void_in : in std_logic_vector(3 downto 0);
      stop_in      : in std_logic_vector(3 downto 0);

      data_n_out : out std_logic_vector(width-1 downto 0);
      data_s_out : out std_logic_vector(width-1 downto 0);
      data_w_out : out std_logic_vector(width-1 downto 0);
      data_e_out : out std_logic_vector(width-1 downto 0);

      data_void_out : out std_logic_vector(3 downto 0);
      stop_out      : out std_logic_vector(3 downto 0)
    );
  end component bypass_router;

  component cdc_gray_pulse is
    generic (
      N : integer := 4
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

  function set_ddr_index (
    constant n : integer range 0 to 7)
    return integer is
  begin
    if n > (MEM_ID_RANGE_MSB) then
      return MEM_ID_RANGE_MSB;
    else
      return n;
    end if;
  end set_ddr_index;

  constant this_ddr_index : attribute_vector(0 to 7) := (
    0 => set_ddr_index(0),
    1 => set_ddr_index(1),
    2 => set_ddr_index(2),
    3 => set_ddr_index(3),
    4 => set_ddr_index(4),
    5 => set_ddr_index(5),
    6 => set_ddr_index(6),
    7 => set_ddr_index(7)
    );

-- Switches
  signal sel0, sel1, sel2, sel3, sel4 : std_ulogic;

-- clock and reset
  signal clkm, clkm_1, clkm_2, clkm_3                   : std_ulogic := '0';
  signal clkm_4, clkm_5, clkm_6, clkm_7                 : std_ulogic := '0';
  signal clkm_sync_rst, clkm_sync_rst_1                 : std_ulogic;
  signal clkm_sync_rst_2, clkm_sync_rst_3               : std_ulogic;
  signal clkm_sync_rst_4, clkm_sync_rst_5               : std_ulogic;
  signal clkm_sync_rst_6, clkm_sync_rst_7               : std_ulogic;
  signal rstn, rstraw, rstraw_1, rstraw_2, rstraw_3 : std_ulogic;
  signal d2d_rstn, d2d_rst  : std_ulogic;
  signal d2d_rstn_c0, d2d_rst_c0, d2d_rstn_c1, d2d_rst_c1 : std_ulogic;
  signal rstraw_4, rstraw_5, rstraw_6, rstraw_7         : std_ulogic;
  signal lock, rst, rst_pad                             : std_ulogic;
  signal migrstn, migrstn_1, migrstn_2, migrstn_3       : std_logic;
  signal migrstn_4, migrstn_5, migrstn_6, migrstn_7     : std_logic;
  signal cgi                                            : clkgen_in_type;
  signal cgo                                            : clkgen_out_type;

---mig signals
  constant led_pending_max    : unsigned(11 downto 0) := (others => '1');
  signal c0_calib_done        : std_ulogic;
  signal c0_diagnostic_toggle : std_ulogic;
  signal led_blue_count       : unsigned(26 downto 0) := (others => '0');
  signal led_blue_pending     : unsigned(11 downto 0) := (others => '0');
  signal led_blue_phase_prev  : std_ulogic := '0';
  signal led_blue_started     : std_ulogic := '0';
  signal led_blue_dbg         : std_ulogic;
  signal led_blue_pad         : std_ulogic;
  signal led_red_count        : unsigned(26 downto 0) := (others => '0');
  signal led_red_pending      : unsigned(11 downto 0) := (others => '0');
  signal led_red_phase_prev   : std_ulogic := '0';
  signal led_red_started      : std_ulogic := '0';
  signal led_red_dbg          : std_ulogic;
  signal led_red_pad          : std_ulogic;
  signal led_yellow_count     : unsigned(26 downto 0) := (others => '0');
  signal led_yellow_pending   : unsigned(11 downto 0) := (others => '0');
  signal led_yellow_phase_prev : std_ulogic := '0';
  signal led_yellow_started   : std_ulogic := '0';
  signal led_yellow_dbg       : std_ulogic;
  signal led_yellow_pad       : std_ulogic;
  signal led_green_count      : unsigned(26 downto 0) := (others => '0');
  signal led_green_pending    : unsigned(11 downto 0) := (others => '0');
  signal led_green_phase_prev : std_ulogic := '0';
  signal led_green_started    : std_ulogic := '0';
  signal led_green_dbg        : std_ulogic;
  signal led_green_pad        : std_ulogic;
  signal c0_rx_link_ready_sel : std_ulogic := '0';
  signal c1_rx_link_ready_sel : std_ulogic := '0';
  signal c0_credit_back_evt   : std_ulogic := '0';
  signal c1_credit_back_evt   : std_ulogic := '0';

-- Ethernet signals
  signal ethi : eth_in_type;
  signal etho : eth_out_type;

-- Tiles

-- UART
  signal uart_rxd_int  : std_logic;       -- UART1_RX (u1i.rxd)
  -- signal uart_txd_int  : std_logic;       -- UART1_TX (u1o.txd)
  signal uart_ctsn_int : std_logic;       -- UART1_RTSN (u1i.ctsn)
  signal uart_rtsn_int : std_logic;       -- UART1_RTSN (u1o.rtsn)

constant MAX_NMEM_TILES : integer := 8;
-- Memory controller DDR4
  signal ddr_ahbsi : ahb_slv_in_vector_type(0 to MAX_NMEM_TILES - 1);
  signal ddr_ahbso : ahb_slv_out_vector_type(0 to MAX_NMEM_TILES - 1);

-- Ethernet
constant CPU_FREQ : integer := 100000;  -- cpu frequency in KHz

  function set_d2d (
    constant BOARD_NUM : integer range 0 to 3;
    constant LOC       : integer range 0 to 3
    )
    return integer is
    begin
    -- if (BOARD_NUM = 0) and ISOLATE_BOARD0_D2D then
    --   return 0;
    -- end if;

    if BOARD_NUM = 0 then
      if LOC = 0 then
        return 0;
      elsif LOC = 1 then  -- 1 = S
        if CFG_CHIPLET_ROWS > 1 then return WIRES_PER_CONNECTION; else return 0; end if;
      elsif LOC = 2 then
        return 0;
      else  -- 3 = E
        if CFG_CHIPLET_COLS > 1 then return WIRES_PER_CONNECTION; else return 0; end if;
      end if;
    elsif BOARD_NUM = 1 then
      if LOC = 0 then
        return 0;
      elsif LOC = 1 then  -- 1 = S
        if CFG_CHIPLET_ROWS > 1 then return WIRES_PER_CONNECTION; else return 0; end if;
      elsif LOC = 2 then  -- W
        if CFG_CHIPLET_COLS > 1 then return WIRES_PER_CONNECTION; else return 0; end if;
      else  -- 3 = E
        return 0;
      end if;
    elsif BOARD_NUM = 2 then
      if LOC = 0 then  -- N
        if CFG_CHIPLET_ROWS > 1 then return WIRES_PER_CONNECTION; else return 0; end if;
      elsif LOC = 1 then  -- 1 = S
        return 0;
      elsif LOC = 2 then
        return 0;
      else  -- 3 = E
        if CFG_CHIPLET_COLS > 1 then return WIRES_PER_CONNECTION; else return 0; end if;
      end if;
    else
      if LOC = 0 then  -- N
        if CFG_CHIPLET_ROWS > 1 then return WIRES_PER_CONNECTION; else return 0; end if;
      elsif LOC = 1 then  -- 1 = S
        return 0;
      elsif LOC = 2 then  -- W
        if CFG_CHIPLET_COLS > 1 then return WIRES_PER_CONNECTION; else return 0; end if;
      else  -- 3 = E
        return 0;
      end if;
    end if;
  end set_d2d;

  constant D2D_CHANNELS_N : integer := set_d2d(BOARD_NUM, 0);
  constant D2D_CHANNELS_S : integer := set_d2d(BOARD_NUM, 1);
  constant D2D_CHANNELS_W : integer := set_d2d(BOARD_NUM, 2);
  constant D2D_CHANNELS_E : integer := set_d2d(BOARD_NUM, 3);
  constant C1_IS_NORTH    : boolean := (BOARD_NUM = 2) or (BOARD_NUM = 3);
  constant C0_IS_WEST     : boolean := (BOARD_NUM = 1) or (BOARD_NUM = 3);
  constant ROW : integer := BOARD_NUM / CFG_CHIPLET_COLS;
  constant COL : integer := BOARD_NUM mod CFG_CHIPLET_COLS;
  constant C0_LINK_ACTIVE : boolean := (D2D_CHANNELS_W > 0) or (D2D_CHANNELS_E > 0);
  constant C1_LINK_ACTIVE : boolean := (D2D_CHANNELS_N > 0) or (D2D_CHANNELS_S > 0);
  constant C0_TX_ON_UPPER_PINS : boolean := (BOARD_NUM = 0) or (BOARD_NUM = 2);
  constant C1_TX_ON_UPPER_PINS : boolean := (BOARD_NUM = 0) or (BOARD_NUM = 1);
  constant LOCAL_CHIP_Y_CONST : chip_yx := chip_yx'(std_logic_vector(to_unsigned(ROW, CHIP_YX_WIDTH)));
  constant LOCAL_CHIP_X_CONST : chip_yx := chip_yx'(std_logic_vector(to_unsigned(COL, CHIP_YX_WIDTH)));
  constant MAX_DIM_X_CONST : local_yx := std_logic_vector(to_unsigned(CFG_XLEN(BOARD_NUM), YX_WIDTH));
  constant MAX_DIM_Y_CONST : local_yx := std_logic_vector(to_unsigned(CFG_YLEN(BOARD_NUM), YX_WIDTH));

  function b2sl(b : boolean) return std_logic is
  begin
    if b then
      return '1';
    else
      return '0';
    end if;
  end function;

  constant bypass_ports : std_logic_vector(3 downto 0) := b2sl(D2D_CHANNELS_E > 0) &
                                                           b2sl(D2D_CHANNELS_W > 0) &
                                                           b2sl(D2D_CHANNELS_S > 0) &
                                                           b2sl(D2D_CHANNELS_N > 0);

  signal chiplet_data_n_in    : coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
  signal chiplet_credit_in_n  : std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
  signal chiplet_valid_in_n   : std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);

  signal chiplet_data_s_in    : coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
  signal chiplet_credit_in_s  : std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
  signal chiplet_valid_in_s   : std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);

  signal chiplet_data_w_in    : coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
  signal chiplet_credit_in_w  : std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
  signal chiplet_valid_in_w   : std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);

  signal chiplet_data_e_in    : coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
  signal chiplet_credit_in_e  : std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
  signal chiplet_valid_in_e   : std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);

  signal chiplet_data_n_out   : coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
  signal chiplet_credit_out_n : std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
  signal chiplet_valid_out_n  : std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);

  signal chiplet_data_s_out   : coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
  signal chiplet_credit_out_s : std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
  signal chiplet_valid_out_s  : std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);

  signal chiplet_data_w_out   : coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
  signal chiplet_credit_out_w : std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
  signal chiplet_valid_out_w  : std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);

  signal chiplet_data_e_out   : coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
  signal chiplet_credit_out_e : std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
  signal chiplet_valid_out_e  : std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
  signal c0_d2d_link_ready        : std_logic;
  signal c1_d2d_link_ready        : std_logic;

  -- NoC --> D2D TX N
  signal d2d_noc1_data_in_n        :  coh_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_data_in_n        :  coh_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_data_in_n        :  coh_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_data_in_n        :  dma_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_data_in_n        :  misc_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_data_in_n        :  dma_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);

  signal d2d_noc1_data_void_in_n   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_data_void_in_n   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_data_void_in_n   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_data_void_in_n   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_data_void_in_n   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_data_void_in_n   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);

  -- D2D TX --> NoC N flow control
  signal d2d_noc1_stop_out_n       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_stop_out_n       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_stop_out_n       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_stop_out_n       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_stop_out_n       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_stop_out_n       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);

  -- NoC --> D2D TX S
  signal d2d_noc1_data_in_s        :  coh_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_data_in_s        :  coh_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_data_in_s        :  coh_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_data_in_s        :  dma_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_data_in_s        :  misc_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_data_in_s        :  dma_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);

  signal d2d_noc1_data_void_in_s   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_data_void_in_s   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_data_void_in_s   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_data_void_in_s   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_data_void_in_s   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_data_void_in_s   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);

  -- D2D TX --> NoC S flow control
  signal d2d_noc1_stop_out_s       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_stop_out_s       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_stop_out_s       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_stop_out_s       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_stop_out_s       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_stop_out_s       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);

  -- NoC --> D2D TX E
  signal d2d_noc1_data_in_e        :  coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_data_in_e        :  coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_data_in_e        :  coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_data_in_e        :  dma_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_data_in_e        :  misc_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_data_in_e        :  dma_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);

  signal d2d_noc1_data_void_in_e   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_data_void_in_e   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_data_void_in_e   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_data_void_in_e   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_data_void_in_e   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_data_void_in_e   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);

  -- D2D TX --> NoC E flow control
  signal d2d_noc1_stop_out_e       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_stop_out_e       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_stop_out_e       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_stop_out_e       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_stop_out_e       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_stop_out_e       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);

  -- NoC --> D2D TX W
  signal d2d_noc1_data_in_w        :  coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_data_in_w        :  coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_data_in_w        :  coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_data_in_w        :  dma_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_data_in_w        :  misc_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_data_in_w        :  dma_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);

  signal d2d_noc1_data_void_in_w   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_data_void_in_w   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_data_void_in_w   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_data_void_in_w   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_data_void_in_w   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_data_void_in_w   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);

  -- D2D TX --> NoC W flow control
  signal d2d_noc1_stop_out_w       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_stop_out_w       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_stop_out_w       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_stop_out_w       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_stop_out_w       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_stop_out_w       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);

  -- D2D RX --> NoC N
  signal d2d_noc1_data_out_n        :  coh_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_data_out_n        :  coh_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_data_out_n        :  coh_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_data_out_n        :  dma_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_data_out_n        :  misc_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_data_out_n        :  dma_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);

  signal d2d_noc1_data_void_out_n   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_data_void_out_n   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_data_void_out_n   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_data_void_out_n   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_data_void_out_n   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_data_void_out_n   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);

  -- NoC --> D2D RX N flow control
  signal d2d_noc1_stop_in_n       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_stop_in_n       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_stop_in_n       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_stop_in_n       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_stop_in_n       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_stop_in_n       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);

  -- D2D RX --> NoC S
  signal d2d_noc1_data_out_s        :  coh_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_data_out_s        :  coh_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_data_out_s        :  coh_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_data_out_s        :  dma_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_data_out_s        :  misc_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_data_out_s        :  dma_noc_flit_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);

  signal d2d_noc1_data_void_out_s   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_data_void_out_s   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_data_void_out_s   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_data_void_out_s   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_data_void_out_s   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_data_void_out_s   :  std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);

  -- NoC --> D2D RX S flow control
  signal d2d_noc1_stop_in_s       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_stop_in_s       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_stop_in_s       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_stop_in_s       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_stop_in_s       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_stop_in_s       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);

  -- D2D RX --> NoC E
  signal d2d_noc1_data_out_e        :  coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_data_out_e        :  coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_data_out_e        :  coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_data_out_e        :  dma_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_data_out_e        :  misc_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_data_out_e        :  dma_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);

  signal d2d_noc1_data_void_out_e   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_data_void_out_e   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_data_void_out_e   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_data_void_out_e   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_data_void_out_e   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_data_void_out_e   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);

  -- NoC --> D2D RX E flow control
  signal d2d_noc1_stop_in_e       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_stop_in_e       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_stop_in_e       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_stop_in_e       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_stop_in_e       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_stop_in_e       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);

  -- D2D RX --> NoC W
  signal d2d_noc1_data_out_w        :  coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_data_out_w        :  coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_data_out_w        :  coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_data_out_w        :  dma_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_data_out_w        :  misc_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_data_out_w        :  dma_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);

  signal d2d_noc1_data_void_out_w   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_data_void_out_w   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_data_void_out_w   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_data_void_out_w   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_data_void_out_w   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_data_void_out_w   :  std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);

  -- NoC --> D2D RX W flow control
  signal d2d_noc1_stop_in_w       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc2_stop_in_w       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc3_stop_in_w       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc4_stop_in_w       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc5_stop_in_w       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
  signal d2d_noc6_stop_in_w       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);

  signal bypass_data_out             : coh_noc_flit_vector(3 downto 0); -- 0:N, 1:S, 2:W, 3:E
  signal bypass_data_void_out        : std_logic_vector(3 downto 0);
  signal bypass_stop_in              : std_logic_vector(3 downto 0);
  signal bypass_data_in              : coh_noc_flit_vector(3 downto 0);
  signal bypass_data_void_in         : std_logic_vector(3 downto 0);
  signal bypass_stop_out             : std_logic_vector(3 downto 0);


  signal eth0_apbi   : apb_slv_in_type;
  signal eth0_apbo   : apb_slv_out_type;
  signal sgmii0_apbi : apb_slv_in_type;

  signal sgmii0_apbo : apb_slv_out_type;
  signal eth0_ahbmi  : ahb_mst_in_type;
  signal eth0_ahbmo  : ahb_mst_out_type;
  signal edcl_ahbmo  : ahb_mst_out_type;
-- CPU flags
  signal cpuerr : std_ulogic;

-- NOC
  signal chip_rstn  : std_ulogic := '0';
  signal chip_rst : std_ulogic;
  signal d2d_ready_c0, d2d_ready_c1 : std_ulogic;
  signal d2d_ready_sync_c0, d2d_ready_sync_c1 : std_ulogic := '0';
  signal d2d_ready_sync_c0_1, d2d_ready_sync_c1_1 : std_ulogic := '0';
  signal d2d_startup_done : std_ulogic := '0';
  signal sys_clk        : std_logic_vector(0 to MAX_NMEM_TILES - 1);
  signal esp_clk        : std_ulogic;
  signal chip_refclk    : std_ulogic;

  attribute keep : boolean;
  attribute keep of clkm        : signal is true;
  -- attribute keep of clkm_1      : signal is true;
  -- attribute keep of clkm_2      : signal is true;
  -- attribute keep of clkm_3      : signal is true;
  -- attribute keep of clkm_4      : signal is true;
  -- attribute keep of clkm_5      : signal is true;
  -- attribute keep of clkm_6      : signal is true;
  attribute keep of chip_refclk : signal is true;

-- MMI64
  signal user_rstn      : std_ulogic;
  signal mon_ddr        : monitor_ddr_vector(0 to MEM_ID_RANGE_MSB);  -- MEM_ID_RANGE_MSB = total number of mem tiles in the chiplet setup
  signal mon_ddr_reg    : monitor_ddr_vector(0 to MEM_ID_RANGE_MSB);
  signal mon_noc        : monitor_noc_matrix(1 to 6, 0 to CFG_CHIPLET_TILES(BOARD_NUM)-1);
  signal mon_noc_actual : monitor_noc_matrix(0 to 1, 0 to CFG_CHIPLET_TILES(BOARD_NUM)-1);
  signal mon_mem        : monitor_mem_vector(0 to CFG_NMEM_TILE_CHIPLET(BOARD_NUM) + CFG_NSLM_TILE_CHIPLET(BOARD_NUM) + CFG_NSLMDDR_TILE_CHIPLET(BOARD_NUM) - 1);
  signal mon_mem_reg    : monitor_mem_vector(0 to CFG_NMEM_TILE_CHIPLET(BOARD_NUM) + CFG_NSLM_TILE_CHIPLET(BOARD_NUM) + CFG_NSLMDDR_TILE_CHIPLET(BOARD_NUM) - 1);
  signal mon_l2         : monitor_cache_vector(0 to relu(CFG_NL2_CHIPLET(BOARD_NUM) - 1));
  signal mon_llc        : monitor_cache_vector(0 to relu(CFG_NLLC_CHIPLET(BOARD_NUM) - 1));
  signal mon_acc        : monitor_acc_vector(0 to relu(CFG_NACC_TILE_CHIPLET(BOARD_NUM)-1));
  signal mon_dvfs       : monitor_dvfs_vector(0 to CFG_CHIPLET_TILES(BOARD_NUM)-1);

  signal c0_d2d_data_tx    : std_logic_vector(67 downto 0);
  signal c1_d2d_data_tx    : std_logic_vector(67 downto 0);
  signal c0_d2d_data_rx_pipe    : std_logic_vector(67 downto 0);
  signal c1_d2d_data_rx_pipe    : std_logic_vector(67 downto 0);
  signal c0_d2d_data_tx_io  : std_logic_vector(67 downto 0);
  signal c1_d2d_data_tx_io  : std_logic_vector(67 downto 0);
  signal c0_rx_head_prev    : std_logic_vector(67 downto 0) := (others => '0');
  signal c1_rx_head_prev    : std_logic_vector(67 downto 0) := (others => '0');

  
  signal cable_clk_rcv_raw_0    : std_ulogic;
  signal cable_clk_rcv_core_0   : std_ulogic;
  signal d2d_rx_mmcm_locked0    : std_ulogic;
  signal c0_rx_run              : std_ulogic;
  signal c0_rx_core_run         : std_ulogic;
  
  signal cable_clk_rcv_raw_1    : std_ulogic;
  signal cable_clk_rcv_core_1   : std_ulogic;
  signal d2d_rx_mmcm_locked1    : std_ulogic;
  signal c1_rx_run              : std_ulogic;
  signal c1_rx_core_run         : std_ulogic;
  
  signal d2d_clk_ibufds : std_ulogic;
  signal d2d_clk_int    : std_ulogic;
  signal d2d_rstn_c0_d2d : std_ulogic := '0';
  signal d2d_rstn_c1_d2d : std_ulogic := '0';
  signal d2d_rst_c0_d2d_ff1, d2d_rst_c0_d2d_ff2 : std_ulogic := '1';
  signal d2d_rst_c1_d2d_ff1, d2d_rst_c1_d2d_ff2 : std_ulogic := '1';
  
  signal d2d_clk_n_in_int : std_ulogic;
  signal d2d_clk_s_in_int : std_ulogic;
  signal d2d_clk_w_in_int : std_ulogic;
  signal d2d_clk_e_in_int : std_ulogic;
  signal d2d_tx_link_ready_n : std_logic;
  signal d2d_tx_link_ready_s : std_logic;
  signal d2d_tx_link_ready_e : std_logic;
  signal d2d_tx_link_ready_w : std_logic;
  signal d2d_rx_link_ready_n  : std_logic;
  signal d2d_rx_link_ready_s  : std_logic;
  signal d2d_rx_link_ready_e  : std_logic;
  signal d2d_rx_link_ready_w  : std_logic;
  
  -- Lossless credit CDC using shared Gray event counters.
  constant CREDIT_CDC_CNT_W : integer := 5;
  
  signal c0_credit_in_evt_pulse_d2d, c1_credit_in_evt_pulse_d2d : std_logic := '0';
  
  signal chiplet_credit_out_n_evt_pulse_d2d, chiplet_credit_out_s_evt_pulse_d2d : std_logic := '0';
  signal chiplet_credit_out_w_evt_pulse_d2d, chiplet_credit_out_e_evt_pulse_d2d : std_logic := '0';
                                      
  attribute ASYNC_REG : string;
  attribute SHREG_EXTRACT : string;
  attribute ASYNC_REG of d2d_ready_sync_c0_1 : signal is "TRUE";
  attribute ASYNC_REG of d2d_ready_sync_c0   : signal is "TRUE";
  attribute ASYNC_REG of d2d_ready_sync_c1_1 : signal is "TRUE";
  attribute ASYNC_REG of d2d_ready_sync_c1   : signal is "TRUE";
  attribute ASYNC_REG of d2d_rst_c0_d2d_ff1  : signal is "TRUE";
  attribute ASYNC_REG of d2d_rst_c0_d2d_ff2  : signal is "TRUE";
  attribute ASYNC_REG of d2d_rst_c1_d2d_ff1  : signal is "TRUE";
  attribute ASYNC_REG of d2d_rst_c1_d2d_ff2  : signal is "TRUE";
  attribute SHREG_EXTRACT of d2d_ready_sync_c0_1 : signal is "NO";
  attribute SHREG_EXTRACT of d2d_ready_sync_c0   : signal is "NO";
  attribute SHREG_EXTRACT of d2d_ready_sync_c1_1 : signal is "NO";
  attribute SHREG_EXTRACT of d2d_ready_sync_c1   : signal is "NO";
  attribute SHREG_EXTRACT of d2d_rst_c0_d2d_ff1  : signal is "NO";
  attribute SHREG_EXTRACT of d2d_rst_c0_d2d_ff2  : signal is "NO";
  attribute SHREG_EXTRACT of d2d_rst_c1_d2d_ff1  : signal is "NO";
  attribute SHREG_EXTRACT of d2d_rst_c1_d2d_ff2  : signal is "NO";

begin

  d2d_rst_c0_d2d_sync : process (d2d_clk_int, d2d_rst_c0)
  begin
    if d2d_rst_c0 = '1' then
      d2d_rst_c0_d2d_ff1 <= '1';
      d2d_rst_c0_d2d_ff2 <= '1';
    elsif rising_edge(d2d_clk_int) then
      d2d_rst_c0_d2d_ff1 <= '0';
      d2d_rst_c0_d2d_ff2 <= d2d_rst_c0_d2d_ff1;
    end if;
  end process d2d_rst_c0_d2d_sync;

  d2d_rst_c1_d2d_sync : process (d2d_clk_int, d2d_rst_c1)
  begin
    if d2d_rst_c1 = '1' then
      d2d_rst_c1_d2d_ff1 <= '1';
      d2d_rst_c1_d2d_ff2 <= '1';
    elsif rising_edge(d2d_clk_int) then
      d2d_rst_c1_d2d_ff1 <= '0';
      d2d_rst_c1_d2d_ff2 <= d2d_rst_c1_d2d_ff1;
    end if;
  end process d2d_rst_c1_d2d_sync;

  d2d_rstn_c0_d2d <= not d2d_rst_c0_d2d_ff2;
  d2d_rstn_c1_d2d <= not d2d_rst_c1_d2d_ff2;

  c0_cable_frontend_i : entity work.d2d_cable_frontend
    generic map (
      CLKIN_PERIOD_NS  => D2D_RX_MMCM_CLKIN_PERIOD_NS,
      REF_JITTER1_UI   => D2D_RX_MMCM_REF_JITTER1_UI,
      PHASE_DEG        => D2D_RX_MMCM_PHASE_DEG_C0,
      CREDIT_CDC_N     => 3,
      TX_ON_UPPER_PINS => C0_TX_ON_UPPER_PINS,
      LINK_ACTIVE      => C0_LINK_ACTIVE
    )
    port map (
      d2d_clk_int             => d2d_clk_int,
      d2d_rst                 => d2d_rst_c0,
      d2d_rstn                => d2d_rstn_c0,
      d2d_rstn_d2d            => d2d_rstn_c0_d2d,
      cable_clk_p             => c0_cable_clk_p,
      cable_clk_n             => c0_cable_clk_n,
      cable_clk_p_rcv         => c0_cable_clk_p_rcv,
      cable_clk_n_rcv         => c0_cable_clk_n_rcv,
      cable_io_data           => c0_cable_io_data,
      d2d_data_tx             => c0_d2d_data_tx,
      d2d_data_tx_io_dbg      => c0_d2d_data_tx_io,
      d2d_data_rx_pipe        => c0_d2d_data_rx_pipe,
      cable_clk_rcv_raw       => cable_clk_rcv_raw_0,
      cable_clk_rcv_core      => cable_clk_rcv_core_0,
      d2d_rx_mmcm_locked      => d2d_rx_mmcm_locked0,
      rx_run                  => c0_rx_run,
      rx_core_run             => c0_rx_core_run,
      credit_in_evt_pulse_d2d => c0_credit_in_evt_pulse_d2d
    );

  c1_cable_frontend_i : entity work.d2d_cable_frontend
    generic map (
      CLKIN_PERIOD_NS  => D2D_RX_MMCM_CLKIN_PERIOD_NS,
      REF_JITTER1_UI   => D2D_RX_MMCM_REF_JITTER1_UI,
      PHASE_DEG        => D2D_RX_MMCM_PHASE_DEG_C1,
      CREDIT_CDC_N     => 3,
      TX_ON_UPPER_PINS => C1_TX_ON_UPPER_PINS,
      LINK_ACTIVE      => C1_LINK_ACTIVE
    )
    port map (
      d2d_clk_int             => d2d_clk_int,
      d2d_rst                 => d2d_rst_c1,
      d2d_rstn                => d2d_rstn_c1,
      d2d_rstn_d2d            => d2d_rstn_c1_d2d,
      cable_clk_p             => c1_cable_clk_p,
      cable_clk_n             => c1_cable_clk_n,
      cable_clk_p_rcv         => c1_cable_clk_p_rcv,
      cable_clk_n_rcv         => c1_cable_clk_n_rcv,
      cable_io_data           => c1_cable_io_data,
      d2d_data_tx             => c1_d2d_data_tx,
      d2d_data_tx_io_dbg      => c1_d2d_data_tx_io,
      d2d_data_rx_pipe        => c1_d2d_data_rx_pipe,
      cable_clk_rcv_raw       => cable_clk_rcv_raw_1,
      cable_clk_rcv_core      => cable_clk_rcv_core_1,
      d2d_rx_mmcm_locked      => d2d_rx_mmcm_locked1,
      rx_run                  => c1_rx_run,
      rx_core_run             => c1_rx_core_run,
      credit_in_evt_pulse_d2d => c1_credit_in_evt_pulse_d2d
    );

  gen_chiplet_credit_out_n_cdc : if D2D_CHANNELS_N > 0 generate
  begin
    chiplet_credit_out_n_cdc_i : cdc_gray_pulse
      generic map (
        N => CREDIT_CDC_CNT_W
      )
      port map (
        src_clk   => sys_clk(0),
        dst_clk   => d2d_clk_int,
        src_rstn  => d2d_rstn_c1,
        dst_rstn  => d2d_rstn_c1_d2d,
        src_pulse => chiplet_credit_out_n(0),
        dst_pulse => chiplet_credit_out_n_evt_pulse_d2d
      );
  end generate gen_chiplet_credit_out_n_cdc;

  no_chiplet_credit_out_n_cdc : if D2D_CHANNELS_N = 0 generate
  begin
    chiplet_credit_out_n_evt_pulse_d2d <= '0';
  end generate no_chiplet_credit_out_n_cdc;

  gen_chiplet_credit_out_s_cdc : if D2D_CHANNELS_S > 0 generate
  begin
    chiplet_credit_out_s_cdc_i : cdc_gray_pulse
      generic map (
        N => CREDIT_CDC_CNT_W
      )
      port map (
        src_clk   => sys_clk(0),
        dst_clk   => d2d_clk_int,
        src_rstn  => d2d_rstn_c1,
        dst_rstn  => d2d_rstn_c1_d2d,
        src_pulse => chiplet_credit_out_s(0),
        dst_pulse => chiplet_credit_out_s_evt_pulse_d2d
      );
  end generate gen_chiplet_credit_out_s_cdc;

  no_chiplet_credit_out_s_cdc : if D2D_CHANNELS_S = 0 generate
  begin
    chiplet_credit_out_s_evt_pulse_d2d <= '0';
  end generate no_chiplet_credit_out_s_cdc;

  gen_chiplet_credit_out_w_cdc : if D2D_CHANNELS_W > 0 generate
  begin
    chiplet_credit_out_w_cdc_i : cdc_gray_pulse
      generic map (
        N => CREDIT_CDC_CNT_W
      )
      port map (
        src_clk   => sys_clk(0),
        dst_clk   => d2d_clk_int,
        src_rstn  => d2d_rstn_c0,
        dst_rstn  => d2d_rstn_c0_d2d,
        src_pulse => chiplet_credit_out_w(0),
        dst_pulse => chiplet_credit_out_w_evt_pulse_d2d
      );
  end generate gen_chiplet_credit_out_w_cdc;

  no_chiplet_credit_out_w_cdc : if D2D_CHANNELS_W = 0 generate
  begin
    chiplet_credit_out_w_evt_pulse_d2d <= '0';
  end generate no_chiplet_credit_out_w_cdc;

  gen_chiplet_credit_out_e_cdc : if D2D_CHANNELS_E > 0 generate
  begin
    chiplet_credit_out_e_cdc_i : cdc_gray_pulse
      generic map (
        N => CREDIT_CDC_CNT_W
      )
      port map (
        src_clk   => sys_clk(0),
        dst_clk   => d2d_clk_int,
        src_rstn  => d2d_rstn_c0,
        dst_rstn  => d2d_rstn_c0_d2d,
        src_pulse => chiplet_credit_out_e(0),
        dst_pulse => chiplet_credit_out_e_evt_pulse_d2d
      );
  end generate gen_chiplet_credit_out_e_cdc;

  no_chiplet_credit_out_e_cdc : if D2D_CHANNELS_E = 0 generate
  begin
    chiplet_credit_out_e_evt_pulse_d2d <= '0';
  end generate no_chiplet_credit_out_e_cdc;

  c0_diagnostic_toggle <= d2d_startup_done;
  c0_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c0_diagnostic_led, c0_diagnostic_toggle);

-------------------------------------------------------------------------------
-- Leds -----------------------------------------------------------------------
-------------------------------------------------------------------------------

  c0_rx_link_ready_sel <= d2d_rx_link_ready_w when C0_IS_WEST else d2d_rx_link_ready_e;
  c1_rx_link_ready_sel <= d2d_rx_link_ready_n when C1_IS_NORTH else d2d_rx_link_ready_s;

  c0_credit_back_evt <= chiplet_credit_out_w_evt_pulse_d2d when C0_IS_WEST else
                        chiplet_credit_out_e_evt_pulse_d2d;
  c1_credit_back_evt <= chiplet_credit_out_n_evt_pulse_d2d when C1_IS_NORTH else
                        chiplet_credit_out_s_evt_pulse_d2d;

  led_blue_phase : process (cable_clk_rcv_core_0)
  begin
    if rising_edge(cable_clk_rcv_core_0) then
      if c0_rx_core_run = '0' then
        led_blue_count <= (others => '0');
        led_blue_phase_prev <= '0';
      else
        led_blue_phase_prev <= led_blue_count(26);
        led_blue_count <= led_blue_count + 1;
      end if;
    end if;
  end process led_blue_phase;

  led_blue_pending_q : process (cable_clk_rcv_core_0)
    variable next_led_blue_pending : unsigned(led_blue_pending'range);
    variable next_led_blue_started : std_ulogic;
    variable c0_rx_head_level : std_ulogic;
  begin
    if rising_edge(cable_clk_rcv_core_0) then
      if c0_rx_core_run = '0' then
        led_blue_pending <= (others => '0');
        led_blue_started <= '0';
        c0_rx_head_prev <= (others => '0');
      else
        next_led_blue_pending := led_blue_pending;
        next_led_blue_started := led_blue_started;
        c0_rx_head_level := '0';
        if c0_rx_link_ready_sel = '1' and c0_d2d_data_rx_pipe(67) = '1' and c0_d2d_data_rx_pipe(65) = '1' then
          c0_rx_head_level := '1';
        end if;

        -- Count a sampled head word once even if capture phase causes it to
        -- persist for multiple recovered-clock cycles.
        if c0_rx_head_level = '1' and c0_d2d_data_rx_pipe /= c0_rx_head_prev and next_led_blue_pending /= led_pending_max then
          next_led_blue_pending := next_led_blue_pending + 1;
        end if;

        if next_led_blue_pending = 0 then
          next_led_blue_started := '0';
        elsif led_blue_phase_prev = '0' and led_blue_count(26) = '1' then
          next_led_blue_started := '1';
        elsif led_blue_phase_prev = '1' and led_blue_count(26) = '0' and next_led_blue_started = '1' then
          next_led_blue_pending := next_led_blue_pending - 1;
          if next_led_blue_pending = 0 then
            next_led_blue_started := '0';
          end if;
        end if;

        led_blue_pending <= next_led_blue_pending;
        led_blue_started <= next_led_blue_started;
        if c0_rx_head_level = '1' then
          c0_rx_head_prev <= c0_d2d_data_rx_pipe;
        else
          c0_rx_head_prev <= (others => '0');
        end if;
      end if;
    end if;
  end process led_blue_pending_q;
  led_blue_dbg <= led_blue_count(26) when led_blue_pending /= 0 and led_blue_started = '1' else '0';

  led_red_phase : process (d2d_clk_int)
  begin
    if rising_edge(d2d_clk_int) then
      if d2d_rstn_c0_d2d = '0' then
        led_red_count <= (others => '0');
        led_red_phase_prev <= '0';
      else
        led_red_phase_prev <= led_red_count(26);
        led_red_count <= led_red_count + 1;
      end if;
    end if;
  end process led_red_phase;

  led_red_pending_q : process (d2d_clk_int)
    variable next_led_red_pending : unsigned(led_red_pending'range);
    variable next_led_red_started : std_ulogic;
  begin
    if rising_edge(d2d_clk_int) then
      if d2d_rstn_c0_d2d = '0' then
        led_red_pending <= (others => '0');
        led_red_started <= '0';
      else
        next_led_red_pending := led_red_pending;
        next_led_red_started := led_red_started;
        if c0_credit_back_evt = '1' and next_led_red_pending /= led_pending_max then
          next_led_red_pending := next_led_red_pending + 1;
        end if;

        if next_led_red_pending = 0 then
          next_led_red_started := '0';
        elsif led_red_phase_prev = '0' and led_red_count(26) = '1' then
          next_led_red_started := '1';
        elsif led_red_phase_prev = '1' and led_red_count(26) = '0' and next_led_red_started = '1' then
          next_led_red_pending := next_led_red_pending - 1;
          if next_led_red_pending = 0 then
            next_led_red_started := '0';
          end if;
        end if;

        led_red_pending <= next_led_red_pending;
        led_red_started <= next_led_red_started;
      end if;
    end if;
  end process led_red_pending_q;
  led_red_dbg <= led_red_count(26) when led_red_pending /= 0 and led_red_started = '1' else '0';

  led_yellow_phase : process (cable_clk_rcv_core_1)
  begin
    if rising_edge(cable_clk_rcv_core_1) then
      if c1_rx_core_run = '0' then
        led_yellow_count <= (others => '0');
        led_yellow_phase_prev <= '0';
      else
        led_yellow_phase_prev <= led_yellow_count(26);
        led_yellow_count <= led_yellow_count + 1;
      end if;
    end if;
  end process led_yellow_phase;

  led_yellow_pending_q : process (cable_clk_rcv_core_1)
    variable next_led_yellow_pending : unsigned(led_yellow_pending'range);
    variable next_led_yellow_started : std_ulogic;
    variable c1_rx_head_level : std_ulogic;
  begin
    if rising_edge(cable_clk_rcv_core_1) then
      if c1_rx_core_run = '0' then
        led_yellow_pending <= (others => '0');
        led_yellow_started <= '0';
        c1_rx_head_prev <= (others => '0');
      else
        next_led_yellow_pending := led_yellow_pending;
        next_led_yellow_started := led_yellow_started;
        c1_rx_head_level := '0';
        if c1_rx_link_ready_sel = '1' and c1_d2d_data_rx_pipe(67) = '1' and c1_d2d_data_rx_pipe(65) = '1' then
          c1_rx_head_level := '1';
        end if;

        -- Count a sampled head word once even if capture phase causes it to
        -- persist for multiple recovered-clock cycles.
        if c1_rx_head_level = '1' and c1_d2d_data_rx_pipe /= c1_rx_head_prev and next_led_yellow_pending /= led_pending_max then
          next_led_yellow_pending := next_led_yellow_pending + 1;
        end if;

        if next_led_yellow_pending = 0 then
          next_led_yellow_started := '0';
        elsif led_yellow_phase_prev = '0' and led_yellow_count(26) = '1' then
          next_led_yellow_started := '1';
        elsif led_yellow_phase_prev = '1' and led_yellow_count(26) = '0' and next_led_yellow_started = '1' then
          next_led_yellow_pending := next_led_yellow_pending - 1;
          if next_led_yellow_pending = 0 then
            next_led_yellow_started := '0';
          end if;
        end if;

        led_yellow_pending <= next_led_yellow_pending;
        led_yellow_started <= next_led_yellow_started;
        if c1_rx_head_level = '1' then
          c1_rx_head_prev <= c1_d2d_data_rx_pipe;
        else
          c1_rx_head_prev <= (others => '0');
        end if;
      end if;
    end if;
  end process led_yellow_pending_q;
  led_yellow_dbg <= led_yellow_count(26) when led_yellow_pending /= 0 and led_yellow_started = '1' else '0';

  led_green_phase : process (d2d_clk_int)
  begin
    if rising_edge(d2d_clk_int) then
      if d2d_rstn_c1_d2d = '0' then
        led_green_count <= (others => '0');
        led_green_phase_prev <= '0';
      else
        led_green_phase_prev <= led_green_count(26);
        led_green_count <= led_green_count + 1;
      end if;
    end if;
  end process led_green_phase;

  led_green_pending_q : process (d2d_clk_int)
    variable next_led_green_pending : unsigned(led_green_pending'range);
    variable next_led_green_started : std_ulogic;
  begin
    if rising_edge(d2d_clk_int) then
      if d2d_rstn_c1_d2d = '0' then
        led_green_pending <= (others => '0');
        led_green_started <= '0';
      else
        next_led_green_pending := led_green_pending;
        next_led_green_started := led_green_started;
        if c1_credit_back_evt = '1' and next_led_green_pending /= led_pending_max then
          next_led_green_pending := next_led_green_pending + 1;
        end if;

        if next_led_green_pending = 0 then
          next_led_green_started := '0';
        elsif led_green_phase_prev = '0' and led_green_count(26) = '1' then
          next_led_green_started := '1';
        elsif led_green_phase_prev = '1' and led_green_count(26) = '0' and next_led_green_started = '1' then
          next_led_green_pending := next_led_green_pending - 1;
          if next_led_green_pending = 0 then
            next_led_green_started := '0';
          end if;
        end if;

        led_green_pending <= next_led_green_pending;
        led_green_started <= next_led_green_started;
      end if;
    end if;
  end process led_green_pending_q;
  led_green_dbg <= led_green_count(26) when led_green_pending /= 0 and led_green_started = '1' else '0';
  led_blue_pad <= not led_blue_dbg;
  led_red_pad <= not led_red_dbg;
  led_yellow_pad <= not led_yellow_dbg;
  led_green_pad <= not led_green_dbg;

  -- From memory controllers' PLLs
  -- lock_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v) port map (LED_GREEN, lock);
  -- Front-panel LEDs are treated like the main top: drive them active-low so
  -- they are dark when idle and blink visibly once events are queued.
  lock_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v) port map (LED_GREEN, led_green_pad);

  -- From CPU 0 (on chip)
  -- cpuerr_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v) port map (LED_RED, cpuerr);
  cpuerr_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v) port map (LED_RED, led_red_pad);
  --pragma translate_off
  process(clkm, rstn)
  begin  -- process
    if rstn = '1' then
      assert cpuerr = '0' report "Program Completed!" severity failure;
    end if;
  end process;
  --pragma translate_on

  -- From DDR controller (on FPGA)
  calib0_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c0_calib_complete, c0_calib_done);

  -- led3_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v) port map (LED_BLUE, '0');
  led3_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v) port map (LED_BLUE, led_blue_pad);

  -- led4_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v) port map (LED_YELLOW, '0');
  led4_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v) port map (LED_YELLOW, led_yellow_pad);

-------------------------------------------------------------------------------
-- Switches -------------------------------------------------------------------
-------------------------------------------------------------------------------

  --sw0_pad : iopad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --  port map (switch(0), '0', '1', sel0);
  --sw1_pad : iopad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --  port map (switch(1), '0', '1', sel1);
  --sw2_pad : iopad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --  port map (switch(2), '0', '1', sel2);
  --sw3_pad : iopad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --  port map (switch(3), '0', '1', sel3);
  --sw4_pad : iopad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --  port map (switch(4), '0', '1', sel4);
  sel0 <= '1';
  sel1 <= '0';
  sel2 <= '0';
  sel3 <= '0';
  sel4 <= '0';

-------------------------------------------------------------------------------
-- Buttons --------------------------------------------------------------------
-------------------------------------------------------------------------------

  --pio_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --  port map (button(i-4), gpioi.din(i));

----------------------------------------------------------------------
--- FPGA Reset and Clock generation  ---------------------------------
----------------------------------------------------------------------

  cgi.pllctrl <= "00";
  cgi.pllrst <= rstraw;
  lock <= c0_calib_done and cgo.clklock;
  reset_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (reset, rst);

  rst0      : rstgen                    -- D2D reset generator
    generic map (acthigh => 1, syncin => 0)
    port map (rst, clkm, lock, d2d_rstn_c1, open);
  rst1      : rstgen                    -- D2D reset generator
    generic map (acthigh => 1, syncin => 0)
    port map (d2d_rst_c1, clkm, d2d_ready_sync_c1, d2d_rstn_c0, open);

  d2d_rst <= not d2d_rstn_c0;
  d2d_rst_c1 <= not d2d_rstn_c1;
  d2d_rst_c0 <= not d2d_rstn_c0;
  c1_d2d_link_ready <= (d2d_tx_link_ready_n and d2d_rx_link_ready_n) when C1_IS_NORTH else
                       (d2d_tx_link_ready_s and d2d_rx_link_ready_s);
  c0_d2d_link_ready <= (d2d_tx_link_ready_w and d2d_rx_link_ready_w) when C0_IS_WEST else
                       (d2d_tx_link_ready_e and d2d_rx_link_ready_e);

  d2d_ready_c0 <= '1' when ISOLATE_BOARD0_D2D else
               '1' when (D2D_CHANNELS_E = 0 and D2D_CHANNELS_W = 0) else
               c0_d2d_link_ready;
  d2d_ready_c1 <= '1' when ISOLATE_BOARD0_D2D else
               '1' when (D2D_CHANNELS_N = 0 and D2D_CHANNELS_S = 0) else
               c1_d2d_link_ready;

  -- Release the rest of the system only after the D2D clocks are up under
  -- the original reset timing.
  d2d_startup_sync_c0 : process (clkm, d2d_rstn_c0)
  begin
    if d2d_rstn_c0 = '0' then
      d2d_ready_sync_c0_1 <= '0';
      d2d_ready_sync_c0   <= '0';
      d2d_startup_done <= '0';
    elsif rising_edge(clkm) then
      d2d_ready_sync_c0_1 <= d2d_ready_c0;
      d2d_ready_sync_c0   <= d2d_ready_sync_c0_1;
      if d2d_ready_sync_c0 = '1' and d2d_ready_sync_c1 = '1' then
        d2d_startup_done <= '1';
      end if;
    end if;
  end process d2d_startup_sync_c0;
  d2d_startup_sync_c1 : process (clkm, d2d_rstn_c1)
  begin
    if d2d_rstn_c1 = '0' then
      d2d_ready_sync_c1_1 <= '0';
      d2d_ready_sync_c1   <= '0';
    elsif rising_edge(clkm) then
      d2d_ready_sync_c1_1 <= d2d_ready_c1;
      d2d_ready_sync_c1   <= d2d_ready_sync_c1_1;
    end if;
  end process d2d_startup_sync_c1;

  delayed_rst0 : rstgen
    generic map (acthigh => 1, syncin => 0)
    port map (d2d_rst_c0, clkm, d2d_startup_done, rstn, open);

  mig_rst0 : rstgen                         -- reset generator
    generic map (acthigh => 1)
    port map (rst, clkm, lock, migrstn, rstraw);

  esp_clk_buf : ibufgds
    generic map(
      IBUF_LOW_PWR => FALSE
      )
    port map (
      I  => esp_clk_p,
      IB => esp_clk_n,
      O  => esp_clk
      );

  esp_clkgen : clkgen
    generic map (CFG_FABTECH, 8, 8, 0, 0, 0, 0, 0, CPU_FREQ)
    port map (esp_clk, esp_clk, chip_refclk, open, open, open, open, cgi, cgo, open, open, open);

  d2d_clk_buf : IBUFDS
    generic map (
      IBUF_LOW_PWR => FALSE
    )
    port map (
      I  => d2d_clk_p,
      IB => d2d_clk_n,
      O  => d2d_clk_ibufds
    );

  d2d_clk_global_buf : BUFG
    port map (
      I => d2d_clk_ibufds,
      O => d2d_clk_int
    );

-----------------------------------------------------------------------------
-- UART pads
-----------------------------------------------------------------------------
  uart_rxd_int  <= '1';
  uart_ctsn_int <= '1';

----------------------------------------------------------------------
---  DDR4 memory controller ------------------------------------------
----------------------------------------------------------------------

  gen_mig : if (SIMULATION /= true) generate
    ddrc0 : ahb2mig_ebddr4r5
      generic map (
        hindex => 0,
        haddr  => ddr_haddr(this_ddr_index(0)),
        hmask  => ddr_hmask(this_ddr_index(0)))
      port map (
        c0_sys_clk_p     => c0_sys_clk_p,
        c0_sys_clk_n     => c0_sys_clk_n,
        c0_ddr4_act_n    => c0_ddr4_act_n,
        c0_ddr4_adr      => c0_ddr4_adr,
        c0_ddr4_ba       => c0_ddr4_ba,
        c0_ddr4_bg       => c0_ddr4_bg,
        c0_ddr4_cke      => c0_ddr4_cke,
        c0_ddr4_odt      => c0_ddr4_odt,
        c0_ddr4_cs_n     => c0_ddr4_cs_n,
        c0_ddr4_ck_t     => c0_ddr4_ck_t,
        c0_ddr4_ck_c     => c0_ddr4_ck_c,
        c0_ddr4_reset_n  => c0_ddr4_reset_n,
        c0_ddr4_dm_dbi_n => c0_ddr4_dm_dbi_n,
        c0_ddr4_dq       => c0_ddr4_dq,
        c0_ddr4_dqs_c    => c0_ddr4_dqs_c,
        c0_ddr4_dqs_t    => c0_ddr4_dqs_t,
        ahbso            => ddr_ahbso(0),
        ahbsi            => ddr_ahbsi(0),
        calib_done       => c0_calib_done,
        rst_n_syn        => migrstn,
        rst_n_async      => rstraw,
        clk_amba         => clkm,
        ui_clk           => clkm,
        ui_clk_sync_rst  => clkm_sync_rst
        );
  end generate gen_mig;

  ahb_termination : for i in 1 to MAX_NMEM_TILES-1 generate
    ddr_ahbso(i) <= ahbs_none; 
  end generate ahb_termination;

  gen_mig_model : if (SIMULATION = true) generate
    -- pragma translate_off

    mig_ahbram : ahbram_sim
      generic map (
        hindex => 0,
        tech   => 0,
        kbytes => 100,
        pipe   => 0,
        maccsz => AHBDW,
        fname  => "ram.srec"
        )
      port map(
        rst   => rstn,
        clk   => clkm,
        haddr => ddr_haddr(this_ddr_index(0)),
        hmask => ddr_hmask(this_ddr_index(0)),
        ahbsi => ddr_ahbsi(0),
        ahbso => ddr_ahbso(0)
        );

    c0_ddr4_act_n    <= '1';
    c0_ddr4_adr      <= (others => '0');
    c0_ddr4_ba       <= (others => '0');
    c0_ddr4_bg       <= (others => '0');
    c0_ddr4_cke      <= (others => '0');
    c0_ddr4_odt      <= (others => '0');
    c0_ddr4_cs_n     <= (others => '0');
    c0_ddr4_ck_t     <= (others => '0');
    c0_ddr4_ck_c     <= (others => '0');
    c0_ddr4_reset_n  <= '1';
    c0_ddr4_dm_dbi_n <= (others => 'Z');
    c0_ddr4_dq       <= (others => 'Z');
    c0_ddr4_dqs_c    <= (others => 'Z');
    c0_ddr4_dqs_t    <= (others => 'Z');
    c0_calib_done <= '1';
    clkm          <= not clkm        after 3.2 ns;
  -- pragma translate_on
  end generate gen_mig_model;

-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------
  ethi.edclsepahb <= '1';
  -- no_eth0 : if ((SIMULATION = true or CFG_GRETH = 0) and BOARD_NUM = 0) or BOARD_NUM /= 0 generate
    eth0_apbo    <= apb_none;
   eth0_ahbmo   <= ahbm_none;
   edcl_ahbmo   <= ahbm_none;
    etho.mdio_o  <= '0';
    etho.mdio_oe <= '0';
    etho.txd     <= (others => '0');
    etho.tx_en   <= '0';
    etho.tx_er   <= '0';
    etho.mdc     <= '0';
  -- end generate no_eth0;
  sgmii0_apbo <= apb_none;

-----------------------------------------------------------------------------
-- CHIP
-----------------------------------------------------------------------------
  chip_rstn       <= rstn;
  chip_rst        <= not rstn;
  sys_clk(0)      <= clkm;

  -- Leave DDR slot 0 connected to the single satellite DDR controller/model.
  -- Tie off only upper unused slots.
  set_upper_sat_ahbsi : for i in MEM_ID_RANGE_MSB + 1 to MAX_NMEM_TILES-1 generate
      ddr_ahbsi(i) <= ahbs_in_none;
  end generate set_upper_sat_ahbsi;

  -- D2D cable mapping:
  -- c1 cable maps to N on boards 2/3 and S on boards 0/1.
  -- c0 cable maps to W on boards 1/3 and E on boards 0/2.
  d2d_cable_direction_map_i : entity work.d2d_cable_direction_map
    generic map (
      C0_IS_WEST    => C0_IS_WEST,
      C1_IS_NORTH   => C1_IS_NORTH,
      ISOLATE_LINKS => false
    )
    port map (
      c0_d2d_data_rx_pipe                => c0_d2d_data_rx_pipe,
      c1_d2d_data_rx_pipe                => c1_d2d_data_rx_pipe,
      c0_credit_in_evt_pulse_d2d         => c0_credit_in_evt_pulse_d2d,
      c1_credit_in_evt_pulse_d2d         => c1_credit_in_evt_pulse_d2d,
      cable_clk_rcv_core_0               => cable_clk_rcv_core_0,
      cable_clk_rcv_core_1               => cable_clk_rcv_core_1,
      chiplet_data_n_in                  => chiplet_data_n_in,
      chiplet_credit_in_n                => chiplet_credit_in_n,
      chiplet_valid_in_n                 => chiplet_valid_in_n,
      chiplet_data_s_in                  => chiplet_data_s_in,
      chiplet_credit_in_s                => chiplet_credit_in_s,
      chiplet_valid_in_s                 => chiplet_valid_in_s,
      chiplet_data_w_in                  => chiplet_data_w_in,
      chiplet_credit_in_w                => chiplet_credit_in_w,
      chiplet_valid_in_w                 => chiplet_valid_in_w,
      chiplet_data_e_in                  => chiplet_data_e_in,
      chiplet_credit_in_e                => chiplet_credit_in_e,
      chiplet_valid_in_e                 => chiplet_valid_in_e,
      chiplet_data_n_out                 => chiplet_data_n_out,
      chiplet_valid_out_n                => chiplet_valid_out_n,
      chiplet_data_s_out                 => chiplet_data_s_out,
      chiplet_valid_out_s                => chiplet_valid_out_s,
      chiplet_data_w_out                 => chiplet_data_w_out,
      chiplet_valid_out_w                => chiplet_valid_out_w,
      chiplet_data_e_out                 => chiplet_data_e_out,
      chiplet_valid_out_e                => chiplet_valid_out_e,
      chiplet_credit_out_n_evt_pulse_d2d => chiplet_credit_out_n_evt_pulse_d2d,
      chiplet_credit_out_s_evt_pulse_d2d => chiplet_credit_out_s_evt_pulse_d2d,
      chiplet_credit_out_w_evt_pulse_d2d => chiplet_credit_out_w_evt_pulse_d2d,
      chiplet_credit_out_e_evt_pulse_d2d => chiplet_credit_out_e_evt_pulse_d2d,
      c0_d2d_data_tx                     => c0_d2d_data_tx,
      c1_d2d_data_tx                     => c1_d2d_data_tx,
      d2d_clk_n_in_int                   => d2d_clk_n_in_int,
      d2d_clk_s_in_int                   => d2d_clk_s_in_int,
      d2d_clk_w_in_int                   => d2d_clk_w_in_int,
      d2d_clk_e_in_int                   => d2d_clk_e_in_int
    );

  d2d_link_n_i : entity work.d2d_direction_link
    generic map (
      CHANNELS     => D2D_CHANNELS_N,
      TILES        => CFG_XLEN(BOARD_NUM),
      D2D_POSITION => "00",
      LOCAL_CHIP_Y => LOCAL_CHIP_Y_CONST,
      LOCAL_CHIP_X => LOCAL_CHIP_X_CONST,
      MAX_DIM      => MAX_DIM_Y_CONST
    )
    port map (
      clk                 => sys_clk(0),
      rst                 => d2d_rst_c1,
      d2d_rst             => d2d_rst_c1,
      d2d_clk_tx_in       => d2d_clk_int,
      d2d_clk_rx_in       => d2d_clk_n_in_int,
      chiplet_data_in     => chiplet_data_n_in,
      chiplet_credit_in   => chiplet_credit_in_n,
      chiplet_valid_in    => chiplet_valid_in_n,
      chiplet_data_out    => chiplet_data_n_out,
      chiplet_credit_out  => chiplet_credit_out_n,
      chiplet_valid_out   => chiplet_valid_out_n,
      tx_link_ready       => d2d_tx_link_ready_n,
      rx_link_ready       => d2d_rx_link_ready_n,
      noc1_data_in        => d2d_noc1_data_in_n,
      noc2_data_in        => d2d_noc2_data_in_n,
      noc3_data_in        => d2d_noc3_data_in_n,
      noc4_data_in        => d2d_noc4_data_in_n,
      noc5_data_in        => d2d_noc5_data_in_n,
      noc6_data_in        => d2d_noc6_data_in_n,
      noc1_data_void_in   => d2d_noc1_data_void_in_n,
      noc2_data_void_in   => d2d_noc2_data_void_in_n,
      noc3_data_void_in   => d2d_noc3_data_void_in_n,
      noc4_data_void_in   => d2d_noc4_data_void_in_n,
      noc5_data_void_in   => d2d_noc5_data_void_in_n,
      noc6_data_void_in   => d2d_noc6_data_void_in_n,
      bypass_data_in      => bypass_data_out(0),
      bypass_data_void_in => bypass_data_void_out(0),
      noc1_stop_out       => d2d_noc1_stop_out_n,
      noc2_stop_out       => d2d_noc2_stop_out_n,
      noc3_stop_out       => d2d_noc3_stop_out_n,
      noc4_stop_out       => d2d_noc4_stop_out_n,
      noc5_stop_out       => d2d_noc5_stop_out_n,
      noc6_stop_out       => d2d_noc6_stop_out_n,
      bypass_stop_out     => bypass_stop_in(0),
      noc1_data_out       => d2d_noc1_data_out_n,
      noc2_data_out       => d2d_noc2_data_out_n,
      noc3_data_out       => d2d_noc3_data_out_n,
      noc4_data_out       => d2d_noc4_data_out_n,
      noc5_data_out       => d2d_noc5_data_out_n,
      noc6_data_out       => d2d_noc6_data_out_n,
      noc1_data_void_out  => d2d_noc1_data_void_out_n,
      noc2_data_void_out  => d2d_noc2_data_void_out_n,
      noc3_data_void_out  => d2d_noc3_data_void_out_n,
      noc4_data_void_out  => d2d_noc4_data_void_out_n,
      noc5_data_void_out  => d2d_noc5_data_void_out_n,
      noc6_data_void_out  => d2d_noc6_data_void_out_n,
      bypass_data_out     => bypass_data_in(0),
      bypass_data_void_out => bypass_data_void_in(0),
      noc1_stop_in        => d2d_noc1_stop_in_n,
      noc2_stop_in        => d2d_noc2_stop_in_n,
      noc3_stop_in        => d2d_noc3_stop_in_n,
      noc4_stop_in        => d2d_noc4_stop_in_n,
      noc5_stop_in        => d2d_noc5_stop_in_n,
      noc6_stop_in        => d2d_noc6_stop_in_n,
      bypass_stop_in      => bypass_stop_out(0)
    );

  d2d_link_s_i : entity work.d2d_direction_link
    generic map (
      CHANNELS     => D2D_CHANNELS_S,
      TILES        => CFG_XLEN(BOARD_NUM),
      D2D_POSITION => "01",
      LOCAL_CHIP_Y => LOCAL_CHIP_Y_CONST,
      LOCAL_CHIP_X => LOCAL_CHIP_X_CONST,
      MAX_DIM      => MAX_DIM_Y_CONST
    )
    port map (
      clk                 => sys_clk(0),
      rst                 => d2d_rst_c1,
      d2d_rst             => d2d_rst_c1,
      d2d_clk_tx_in       => d2d_clk_int,
      d2d_clk_rx_in       => d2d_clk_s_in_int,
      chiplet_data_in     => chiplet_data_s_in,
      chiplet_credit_in   => chiplet_credit_in_s,
      chiplet_valid_in    => chiplet_valid_in_s,
      chiplet_data_out    => chiplet_data_s_out,
      chiplet_credit_out  => chiplet_credit_out_s,
      chiplet_valid_out   => chiplet_valid_out_s,
      tx_link_ready       => d2d_tx_link_ready_s,
      rx_link_ready       => d2d_rx_link_ready_s,
      noc1_data_in        => d2d_noc1_data_in_s,
      noc2_data_in        => d2d_noc2_data_in_s,
      noc3_data_in        => d2d_noc3_data_in_s,
      noc4_data_in        => d2d_noc4_data_in_s,
      noc5_data_in        => d2d_noc5_data_in_s,
      noc6_data_in        => d2d_noc6_data_in_s,
      noc1_data_void_in   => d2d_noc1_data_void_in_s,
      noc2_data_void_in   => d2d_noc2_data_void_in_s,
      noc3_data_void_in   => d2d_noc3_data_void_in_s,
      noc4_data_void_in   => d2d_noc4_data_void_in_s,
      noc5_data_void_in   => d2d_noc5_data_void_in_s,
      noc6_data_void_in   => d2d_noc6_data_void_in_s,
      bypass_data_in      => bypass_data_out(1),
      bypass_data_void_in => bypass_data_void_out(1),
      noc1_stop_out       => d2d_noc1_stop_out_s,
      noc2_stop_out       => d2d_noc2_stop_out_s,
      noc3_stop_out       => d2d_noc3_stop_out_s,
      noc4_stop_out       => d2d_noc4_stop_out_s,
      noc5_stop_out       => d2d_noc5_stop_out_s,
      noc6_stop_out       => d2d_noc6_stop_out_s,
      bypass_stop_out     => bypass_stop_in(1),
      noc1_data_out       => d2d_noc1_data_out_s,
      noc2_data_out       => d2d_noc2_data_out_s,
      noc3_data_out       => d2d_noc3_data_out_s,
      noc4_data_out       => d2d_noc4_data_out_s,
      noc5_data_out       => d2d_noc5_data_out_s,
      noc6_data_out       => d2d_noc6_data_out_s,
      noc1_data_void_out  => d2d_noc1_data_void_out_s,
      noc2_data_void_out  => d2d_noc2_data_void_out_s,
      noc3_data_void_out  => d2d_noc3_data_void_out_s,
      noc4_data_void_out  => d2d_noc4_data_void_out_s,
      noc5_data_void_out  => d2d_noc5_data_void_out_s,
      noc6_data_void_out  => d2d_noc6_data_void_out_s,
      bypass_data_out     => bypass_data_in(1),
      bypass_data_void_out => bypass_data_void_in(1),
      noc1_stop_in        => d2d_noc1_stop_in_s,
      noc2_stop_in        => d2d_noc2_stop_in_s,
      noc3_stop_in        => d2d_noc3_stop_in_s,
      noc4_stop_in        => d2d_noc4_stop_in_s,
      noc5_stop_in        => d2d_noc5_stop_in_s,
      noc6_stop_in        => d2d_noc6_stop_in_s,
      bypass_stop_in      => bypass_stop_out(1)
    );

  d2d_link_e_i : entity work.d2d_direction_link
    generic map (
      CHANNELS     => D2D_CHANNELS_E,
      TILES        => CFG_YLEN(BOARD_NUM),
      D2D_POSITION => "11",
      LOCAL_CHIP_Y => LOCAL_CHIP_Y_CONST,
      LOCAL_CHIP_X => LOCAL_CHIP_X_CONST,
      MAX_DIM      => MAX_DIM_X_CONST
    )
    port map (
      clk                 => sys_clk(0),
      rst                 => d2d_rst_c0,
      d2d_rst             => d2d_rst_c0,
      d2d_clk_tx_in       => d2d_clk_int,
      d2d_clk_rx_in       => d2d_clk_e_in_int,
      chiplet_data_in     => chiplet_data_e_in,
      chiplet_credit_in   => chiplet_credit_in_e,
      chiplet_valid_in    => chiplet_valid_in_e,
      chiplet_data_out    => chiplet_data_e_out,
      chiplet_credit_out  => chiplet_credit_out_e,
      chiplet_valid_out   => chiplet_valid_out_e,
      tx_link_ready       => d2d_tx_link_ready_e,
      rx_link_ready       => d2d_rx_link_ready_e,
      noc1_data_in        => d2d_noc1_data_in_e,
      noc2_data_in        => d2d_noc2_data_in_e,
      noc3_data_in        => d2d_noc3_data_in_e,
      noc4_data_in        => d2d_noc4_data_in_e,
      noc5_data_in        => d2d_noc5_data_in_e,
      noc6_data_in        => d2d_noc6_data_in_e,
      noc1_data_void_in   => d2d_noc1_data_void_in_e,
      noc2_data_void_in   => d2d_noc2_data_void_in_e,
      noc3_data_void_in   => d2d_noc3_data_void_in_e,
      noc4_data_void_in   => d2d_noc4_data_void_in_e,
      noc5_data_void_in   => d2d_noc5_data_void_in_e,
      noc6_data_void_in   => d2d_noc6_data_void_in_e,
      bypass_data_in      => bypass_data_out(3),
      bypass_data_void_in => bypass_data_void_out(3),
      noc1_stop_out       => d2d_noc1_stop_out_e,
      noc2_stop_out       => d2d_noc2_stop_out_e,
      noc3_stop_out       => d2d_noc3_stop_out_e,
      noc4_stop_out       => d2d_noc4_stop_out_e,
      noc5_stop_out       => d2d_noc5_stop_out_e,
      noc6_stop_out       => d2d_noc6_stop_out_e,
      bypass_stop_out     => bypass_stop_in(3),
      noc1_data_out       => d2d_noc1_data_out_e,
      noc2_data_out       => d2d_noc2_data_out_e,
      noc3_data_out       => d2d_noc3_data_out_e,
      noc4_data_out       => d2d_noc4_data_out_e,
      noc5_data_out       => d2d_noc5_data_out_e,
      noc6_data_out       => d2d_noc6_data_out_e,
      noc1_data_void_out  => d2d_noc1_data_void_out_e,
      noc2_data_void_out  => d2d_noc2_data_void_out_e,
      noc3_data_void_out  => d2d_noc3_data_void_out_e,
      noc4_data_void_out  => d2d_noc4_data_void_out_e,
      noc5_data_void_out  => d2d_noc5_data_void_out_e,
      noc6_data_void_out  => d2d_noc6_data_void_out_e,
      bypass_data_out     => bypass_data_in(3),
      bypass_data_void_out => bypass_data_void_in(3),
      noc1_stop_in        => d2d_noc1_stop_in_e,
      noc2_stop_in        => d2d_noc2_stop_in_e,
      noc3_stop_in        => d2d_noc3_stop_in_e,
      noc4_stop_in        => d2d_noc4_stop_in_e,
      noc5_stop_in        => d2d_noc5_stop_in_e,
      noc6_stop_in        => d2d_noc6_stop_in_e,
      bypass_stop_in      => bypass_stop_out(3)
    );

  d2d_link_w_i : entity work.d2d_direction_link
    generic map (
      CHANNELS     => D2D_CHANNELS_W,
      TILES        => CFG_YLEN(BOARD_NUM),
      D2D_POSITION => "10",
      LOCAL_CHIP_Y => LOCAL_CHIP_Y_CONST,
      LOCAL_CHIP_X => LOCAL_CHIP_X_CONST,
      MAX_DIM      => MAX_DIM_X_CONST
    )
    port map (
      clk                 => sys_clk(0),
      rst                 => d2d_rst_c0,
      d2d_rst             => d2d_rst_c0,
      d2d_clk_tx_in       => d2d_clk_int,
      d2d_clk_rx_in       => d2d_clk_w_in_int,
      chiplet_data_in     => chiplet_data_w_in,
      chiplet_credit_in   => chiplet_credit_in_w,
      chiplet_valid_in    => chiplet_valid_in_w,
      chiplet_data_out    => chiplet_data_w_out,
      chiplet_credit_out  => chiplet_credit_out_w,
      chiplet_valid_out   => chiplet_valid_out_w,
      tx_link_ready       => d2d_tx_link_ready_w,
      rx_link_ready       => d2d_rx_link_ready_w,
      noc1_data_in        => d2d_noc1_data_in_w,
      noc2_data_in        => d2d_noc2_data_in_w,
      noc3_data_in        => d2d_noc3_data_in_w,
      noc4_data_in        => d2d_noc4_data_in_w,
      noc5_data_in        => d2d_noc5_data_in_w,
      noc6_data_in        => d2d_noc6_data_in_w,
      noc1_data_void_in   => d2d_noc1_data_void_in_w,
      noc2_data_void_in   => d2d_noc2_data_void_in_w,
      noc3_data_void_in   => d2d_noc3_data_void_in_w,
      noc4_data_void_in   => d2d_noc4_data_void_in_w,
      noc5_data_void_in   => d2d_noc5_data_void_in_w,
      noc6_data_void_in   => d2d_noc6_data_void_in_w,
      bypass_data_in      => bypass_data_out(2),
      bypass_data_void_in => bypass_data_void_out(2),
      noc1_stop_out       => d2d_noc1_stop_out_w,
      noc2_stop_out       => d2d_noc2_stop_out_w,
      noc3_stop_out       => d2d_noc3_stop_out_w,
      noc4_stop_out       => d2d_noc4_stop_out_w,
      noc5_stop_out       => d2d_noc5_stop_out_w,
      noc6_stop_out       => d2d_noc6_stop_out_w,
      bypass_stop_out     => bypass_stop_in(2),
      noc1_data_out       => d2d_noc1_data_out_w,
      noc2_data_out       => d2d_noc2_data_out_w,
      noc3_data_out       => d2d_noc3_data_out_w,
      noc4_data_out       => d2d_noc4_data_out_w,
      noc5_data_out       => d2d_noc5_data_out_w,
      noc6_data_out       => d2d_noc6_data_out_w,
      noc1_data_void_out  => d2d_noc1_data_void_out_w,
      noc2_data_void_out  => d2d_noc2_data_void_out_w,
      noc3_data_void_out  => d2d_noc3_data_void_out_w,
      noc4_data_void_out  => d2d_noc4_data_void_out_w,
      noc5_data_void_out  => d2d_noc5_data_void_out_w,
      noc6_data_void_out  => d2d_noc6_data_void_out_w,
      bypass_data_out     => bypass_data_in(2),
      bypass_data_void_out => bypass_data_void_in(2),
      noc1_stop_in        => d2d_noc1_stop_in_w,
      noc2_stop_in        => d2d_noc2_stop_in_w,
      noc3_stop_in        => d2d_noc3_stop_in_w,
      noc4_stop_in        => d2d_noc4_stop_in_w,
      noc5_stop_in        => d2d_noc5_stop_in_w,
      noc6_stop_in        => d2d_noc6_stop_in_w,
      bypass_stop_in      => bypass_stop_out(2)
    );

  bypass_router_i : bypass_router
    generic map (
      flow_control                => 0,
      width                       => COH_NOC_FLIT_SIZE,
      depth                       => 4,
      ports                       => bypass_ports,
      DEST_SIZE                   => 1)
    port map (
      clk                         => sys_clk(0),
      rst                         => chip_rst,
      CONST_local_chip_x          => chip_yx'(std_logic_vector(to_unsigned(COL, CHIP_YX_WIDTH))),
      CONST_local_chip_y          => chip_yx'(std_logic_vector(to_unsigned(ROW, CHIP_YX_WIDTH))),
      data_n_in                   => bypass_data_in(0),
      data_s_in                   => bypass_data_in(1),
      data_w_in                   => bypass_data_in(2),
      data_e_in                   => bypass_data_in(3),
      data_void_in                => bypass_data_void_in,
      stop_in                     => bypass_stop_in,
      data_n_out                  => bypass_data_out(0),
      data_s_out                  => bypass_data_out(1),
      data_w_out                  => bypass_data_out(2),
      data_e_out                  => bypass_data_out(3),
      data_void_out               => bypass_data_void_out,
      stop_out                    => bypass_stop_out
    );

  esp_chiplet_1 : esp_chiplet
    generic map (
      SIMULATION => SIMULATION,
      D2D_CHANNELS_N  => D2D_CHANNELS_N,
      D2D_CHANNELS_S  => D2D_CHANNELS_S,
      D2D_CHANNELS_W  => D2D_CHANNELS_W,
      D2D_CHANNELS_E  => D2D_CHANNELS_E,
      X_TILES         => CFG_XLEN(BOARD_NUM),
      Y_TILES         => CFG_YLEN(BOARD_NUM),
      BOARD_NUM       => BOARD_NUM
    )
    port map (
      rst         => chip_rstn,
      sys_clk     => sys_clk(0 to MEM_ID_RANGE_MSB),
      refclk      => chip_refclk,
      uart_rxd    => uart_rxd_int,
      uart_txd    => open,  -- not driving uart_txd since it's an output from the chiplet
      uart_ctsn   => uart_ctsn_int,
      uart_rtsn   => uart_rtsn_int,
      cpuerr      => cpuerr,
      ddr_ahbsi   => ddr_ahbsi(0 to MEM_ID_RANGE_MSB),
      ddr_ahbso   => ddr_ahbso(0 to MEM_ID_RANGE_MSB),
      eth0_apbi   => open,
      eth0_apbo   => apb_none,
      edcl_ahbmo  => edcl_ahbmo,
      sgmii0_apbi => open,
      sgmii0_apbo => sgmii0_apbo,
      eth0_ahbmi  => open,
      eth0_ahbmo  => eth0_ahbmo,
      dvi_apbi    => open,
      dvi_apbo    => apb_none,
      dvi_ahbmi   => open,
      dvi_ahbmo   => ahbm_none,
      -- Monitor signals
      mon_noc     => mon_noc,
      mon_acc     => mon_acc,
      mon_mem     => mon_mem,
      mon_l2      => mon_l2,
      mon_llc     => mon_llc,
      mon_dvfs    => mon_dvfs,

      -- D2D
      -- RX
      d2d_noc1_data_in_n  => d2d_noc1_data_out_n,
      d2d_noc2_data_in_n  => d2d_noc2_data_out_n,
      d2d_noc3_data_in_n  => d2d_noc3_data_out_n,
      d2d_noc4_data_in_n  => d2d_noc4_data_out_n,
      d2d_noc5_data_in_n  => d2d_noc5_data_out_n,
      d2d_noc6_data_in_n  => d2d_noc6_data_out_n,

      d2d_noc1_data_void_in_n => d2d_noc1_data_void_out_n,
      d2d_noc2_data_void_in_n => d2d_noc2_data_void_out_n,
      d2d_noc3_data_void_in_n => d2d_noc3_data_void_out_n,
      d2d_noc4_data_void_in_n => d2d_noc4_data_void_out_n,
      d2d_noc5_data_void_in_n => d2d_noc5_data_void_out_n,
      d2d_noc6_data_void_in_n => d2d_noc6_data_void_out_n,

      d2d_noc1_stop_out_n  => d2d_noc1_stop_in_n,
      d2d_noc2_stop_out_n  => d2d_noc2_stop_in_n,
      d2d_noc3_stop_out_n  => d2d_noc3_stop_in_n,
      d2d_noc4_stop_out_n  => d2d_noc4_stop_in_n,
      d2d_noc5_stop_out_n  => d2d_noc5_stop_in_n,
      d2d_noc6_stop_out_n  => d2d_noc6_stop_in_n,

      d2d_noc1_data_in_s  => d2d_noc1_data_out_s,
      d2d_noc2_data_in_s  => d2d_noc2_data_out_s,
      d2d_noc3_data_in_s  => d2d_noc3_data_out_s,
      d2d_noc4_data_in_s  => d2d_noc4_data_out_s,
      d2d_noc5_data_in_s  => d2d_noc5_data_out_s,
      d2d_noc6_data_in_s  => d2d_noc6_data_out_s,

      d2d_noc1_data_void_in_s => d2d_noc1_data_void_out_s,
      d2d_noc2_data_void_in_s => d2d_noc2_data_void_out_s,
      d2d_noc3_data_void_in_s => d2d_noc3_data_void_out_s,
      d2d_noc4_data_void_in_s => d2d_noc4_data_void_out_s,
      d2d_noc5_data_void_in_s => d2d_noc5_data_void_out_s,
      d2d_noc6_data_void_in_s => d2d_noc6_data_void_out_s,

      d2d_noc1_stop_out_s  => d2d_noc1_stop_in_s,
      d2d_noc2_stop_out_s  => d2d_noc2_stop_in_s,
      d2d_noc3_stop_out_s  => d2d_noc3_stop_in_s,
      d2d_noc4_stop_out_s  => d2d_noc4_stop_in_s,
      d2d_noc5_stop_out_s  => d2d_noc5_stop_in_s,
      d2d_noc6_stop_out_s  => d2d_noc6_stop_in_s,

      d2d_noc1_data_in_e  => d2d_noc1_data_out_e,
      d2d_noc2_data_in_e  => d2d_noc2_data_out_e,
      d2d_noc3_data_in_e  => d2d_noc3_data_out_e,
      d2d_noc4_data_in_e  => d2d_noc4_data_out_e,
      d2d_noc5_data_in_e  => d2d_noc5_data_out_e,
      d2d_noc6_data_in_e  => d2d_noc6_data_out_e,

      d2d_noc1_data_void_in_e => d2d_noc1_data_void_out_e,
      d2d_noc2_data_void_in_e => d2d_noc2_data_void_out_e,
      d2d_noc3_data_void_in_e => d2d_noc3_data_void_out_e,
      d2d_noc4_data_void_in_e => d2d_noc4_data_void_out_e,
      d2d_noc5_data_void_in_e => d2d_noc5_data_void_out_e,
      d2d_noc6_data_void_in_e => d2d_noc6_data_void_out_e,

      d2d_noc1_stop_out_e  => d2d_noc1_stop_in_e,
      d2d_noc2_stop_out_e  => d2d_noc2_stop_in_e,
      d2d_noc3_stop_out_e  => d2d_noc3_stop_in_e,
      d2d_noc4_stop_out_e  => d2d_noc4_stop_in_e,
      d2d_noc5_stop_out_e  => d2d_noc5_stop_in_e,
      d2d_noc6_stop_out_e  => d2d_noc6_stop_in_e,

      d2d_noc1_data_in_w  => d2d_noc1_data_out_w,
      d2d_noc2_data_in_w  => d2d_noc2_data_out_w,
      d2d_noc3_data_in_w  => d2d_noc3_data_out_w,
      d2d_noc4_data_in_w  => d2d_noc4_data_out_w,
      d2d_noc5_data_in_w  => d2d_noc5_data_out_w,
      d2d_noc6_data_in_w  => d2d_noc6_data_out_w,

      d2d_noc1_data_void_in_w => d2d_noc1_data_void_out_w,
      d2d_noc2_data_void_in_w => d2d_noc2_data_void_out_w,
      d2d_noc3_data_void_in_w => d2d_noc3_data_void_out_w,
      d2d_noc4_data_void_in_w => d2d_noc4_data_void_out_w,
      d2d_noc5_data_void_in_w => d2d_noc5_data_void_out_w,
      d2d_noc6_data_void_in_w => d2d_noc6_data_void_out_w,

      d2d_noc1_stop_out_w  => d2d_noc1_stop_in_w,
      d2d_noc2_stop_out_w  => d2d_noc2_stop_in_w,
      d2d_noc3_stop_out_w  => d2d_noc3_stop_in_w,
      d2d_noc4_stop_out_w  => d2d_noc4_stop_in_w,
      d2d_noc5_stop_out_w  => d2d_noc5_stop_in_w,
      d2d_noc6_stop_out_w  => d2d_noc6_stop_in_w,

      -- TX
      d2d_noc1_data_out_n => d2d_noc1_data_in_n,
      d2d_noc2_data_out_n => d2d_noc2_data_in_n,
      d2d_noc3_data_out_n => d2d_noc3_data_in_n,
      d2d_noc4_data_out_n => d2d_noc4_data_in_n,
      d2d_noc5_data_out_n => d2d_noc5_data_in_n,
      d2d_noc6_data_out_n => d2d_noc6_data_in_n,

      d2d_noc1_data_void_out_n => d2d_noc1_data_void_in_n,
      d2d_noc2_data_void_out_n => d2d_noc2_data_void_in_n,
      d2d_noc3_data_void_out_n => d2d_noc3_data_void_in_n,
      d2d_noc4_data_void_out_n => d2d_noc4_data_void_in_n,
      d2d_noc5_data_void_out_n => d2d_noc5_data_void_in_n,
      d2d_noc6_data_void_out_n => d2d_noc6_data_void_in_n,

      d2d_noc1_stop_in_n => d2d_noc1_stop_out_n,
      d2d_noc2_stop_in_n => d2d_noc2_stop_out_n,
      d2d_noc3_stop_in_n => d2d_noc3_stop_out_n,
      d2d_noc4_stop_in_n => d2d_noc4_stop_out_n,
      d2d_noc5_stop_in_n => d2d_noc5_stop_out_n,
      d2d_noc6_stop_in_n => d2d_noc6_stop_out_n,

      d2d_noc1_data_out_s => d2d_noc1_data_in_s,
      d2d_noc2_data_out_s => d2d_noc2_data_in_s,
      d2d_noc3_data_out_s => d2d_noc3_data_in_s,
      d2d_noc4_data_out_s => d2d_noc4_data_in_s,
      d2d_noc5_data_out_s => d2d_noc5_data_in_s,
      d2d_noc6_data_out_s => d2d_noc6_data_in_s,

      d2d_noc1_data_void_out_s => d2d_noc1_data_void_in_s,
      d2d_noc2_data_void_out_s => d2d_noc2_data_void_in_s,
      d2d_noc3_data_void_out_s => d2d_noc3_data_void_in_s,
      d2d_noc4_data_void_out_s => d2d_noc4_data_void_in_s,
      d2d_noc5_data_void_out_s => d2d_noc5_data_void_in_s,
      d2d_noc6_data_void_out_s => d2d_noc6_data_void_in_s,

      d2d_noc1_stop_in_s => d2d_noc1_stop_out_s,
      d2d_noc2_stop_in_s => d2d_noc2_stop_out_s,
      d2d_noc3_stop_in_s => d2d_noc3_stop_out_s,
      d2d_noc4_stop_in_s => d2d_noc4_stop_out_s,
      d2d_noc5_stop_in_s => d2d_noc5_stop_out_s,
      d2d_noc6_stop_in_s => d2d_noc6_stop_out_s,

      d2d_noc1_data_out_e => d2d_noc1_data_in_e,
      d2d_noc2_data_out_e => d2d_noc2_data_in_e,
      d2d_noc3_data_out_e => d2d_noc3_data_in_e,
      d2d_noc4_data_out_e => d2d_noc4_data_in_e,
      d2d_noc5_data_out_e => d2d_noc5_data_in_e,
      d2d_noc6_data_out_e => d2d_noc6_data_in_e,

      d2d_noc1_data_void_out_e => d2d_noc1_data_void_in_e,
      d2d_noc2_data_void_out_e => d2d_noc2_data_void_in_e,
      d2d_noc3_data_void_out_e => d2d_noc3_data_void_in_e,
      d2d_noc4_data_void_out_e => d2d_noc4_data_void_in_e,
      d2d_noc5_data_void_out_e => d2d_noc5_data_void_in_e,
      d2d_noc6_data_void_out_e => d2d_noc6_data_void_in_e,

      d2d_noc1_stop_in_e => d2d_noc1_stop_out_e,
      d2d_noc2_stop_in_e => d2d_noc2_stop_out_e,
      d2d_noc3_stop_in_e => d2d_noc3_stop_out_e,
      d2d_noc4_stop_in_e => d2d_noc4_stop_out_e,
      d2d_noc5_stop_in_e => d2d_noc5_stop_out_e,
      d2d_noc6_stop_in_e => d2d_noc6_stop_out_e,

      d2d_noc1_data_out_w => d2d_noc1_data_in_w,
      d2d_noc2_data_out_w => d2d_noc2_data_in_w,
      d2d_noc3_data_out_w => d2d_noc3_data_in_w,
      d2d_noc4_data_out_w => d2d_noc4_data_in_w,
      d2d_noc5_data_out_w => d2d_noc5_data_in_w,
      d2d_noc6_data_out_w => d2d_noc6_data_in_w,

      d2d_noc1_data_void_out_w => d2d_noc1_data_void_in_w,
      d2d_noc2_data_void_out_w => d2d_noc2_data_void_in_w,
      d2d_noc3_data_void_out_w => d2d_noc3_data_void_in_w,
      d2d_noc4_data_void_out_w => d2d_noc4_data_void_in_w,
      d2d_noc5_data_void_out_w => d2d_noc5_data_void_in_w,
      d2d_noc6_data_void_out_w => d2d_noc6_data_void_in_w,

      d2d_noc1_stop_in_w => d2d_noc1_stop_out_w,
      d2d_noc2_stop_in_w => d2d_noc2_stop_out_w,
      d2d_noc3_stop_in_w => d2d_noc3_stop_out_w,
      d2d_noc4_stop_in_w => d2d_noc4_stop_out_w,
      d2d_noc5_stop_in_w => d2d_noc5_stop_out_w,
      d2d_noc6_stop_in_w => d2d_noc6_stop_out_w
    );


  profpga_mmi64_gen : if CFG_MON_DDR_EN + CFG_MON_NOC_INJECT_EN + CFG_MON_NOC_QUEUES_EN + CFG_MON_ACC_EN + CFG_MON_DVFS_EN /= 0 generate
    -- MMI64
    user_rstn <= rstn;
    
    gen_mon_ddr : for i in 0 to MEM_ID_RANGE_MSB generate
        mon_ddr(i).clk <= sys_clk(i);
        detect_ddr_access : process (ddr_ahbsi)
        begin  -- process detect_mem_access
          mon_ddr(i).word_transfer <= '0';

          if ((ddr_ahbsi(i).haddr(31 downto 20) xor conv_std_logic_vector(ddr_haddr(i), 12))
              and conv_std_logic_vector(ddr_hmask(i), 12)) = zero32(31 downto 20) then
            if ddr_ahbsi(i).hready = '1' and ddr_ahbsi(i).htrans /= HTRANS_IDLE then
              mon_ddr(i).word_transfer <= '1';
            end if;
          end if;
        end process detect_ddr_access;
    end generate gen_mon_ddr;
    
    gen_mon_regs : for i in 0 to CFG_NMEM_TILE_CHIPLET(BOARD_NUM) + CFG_NSLM_TILE_CHIPLET(BOARD_NUM) + CFG_NSLMDDR_TILE_CHIPLET(BOARD_NUM) - 1 generate
        mon_mem_reg(i).clk <= mon_mem(i).clk;
        mon_mem_reg_gen : process(mon_mem(i).clk, rstn) 
        begin 
            if rstn = '0' then 
                mon_mem_reg(i).coherent_req <= '0';
                mon_mem_reg(i).coherent_fwd <= '0';
                mon_mem_reg(i).coherent_rsp_rcv <= '0';
                mon_mem_reg(i).coherent_rsp_snd <= '0';
                mon_mem_reg(i).dma_req <= '0';
                mon_mem_reg(i).dma_rsp <= '0';
                mon_mem_reg(i).coherent_dma_req <= '0';
                mon_mem_reg(i).coherent_dma_rsp <= '0';
            elsif mon_mem(i).clk'event and mon_mem(i).clk = '1' then 
                mon_mem_reg(i).coherent_req <= mon_mem(i).coherent_req;
                mon_mem_reg(i).coherent_fwd <= mon_mem(i).coherent_fwd;
                mon_mem_reg(i).coherent_rsp_rcv <= mon_mem(i).coherent_rsp_rcv;
                mon_mem_reg(i).coherent_rsp_snd <= mon_mem(i).coherent_rsp_snd;
                mon_mem_reg(i).dma_req <= mon_mem(i).dma_req;
                mon_mem_reg(i).dma_rsp <= mon_mem(i).dma_rsp;
                mon_mem_reg(i).coherent_dma_req <= mon_mem(i).coherent_dma_req;
                mon_mem_reg(i).coherent_dma_rsp <= mon_mem(i).coherent_dma_rsp;
            end if;
        end process mon_mem_reg_gen;
   
        mon_ddr_reg(i).clk <= mon_ddr(i).clk;
        mon_ddr_reg_gen : process(mon_ddr(i).clk, rstn)
        begin 
            if rstn = '0' then 
                mon_ddr_reg(i).word_transfer <= '0';
            elsif mon_ddr(i).clk'event and mon_ddr(i).clk = '1' then 
                mon_ddr_reg(i).word_transfer <= mon_ddr(i).word_transfer;
            end if;
        end process mon_ddr_reg_gen;
        
    end generate gen_mon_regs; 
    
    mon_noc_map_gen : for i in 0 to CFG_CHIPLET_TILES(BOARD_NUM)-1 generate
      --mon_noc_actual(0,i) <= mon_noc(1,i);
      --mon_noc_actual(1,i) <= mon_noc(3,i);
      mon_noc_actual(0, i) <= mon_noc(4, i);
      --mon_noc_actual(3,i) <= mon_noc(5,i);
      mon_noc_actual(1, i) <= mon_noc(6, i);
    end generate mon_noc_map_gen;

    monitor_1 : monitor
      generic map (
        memtech                => CFG_FABTECH,
        mmi64_width            => 32,
        ddrs_num               => CFG_NMEM_TILE_CHIPLET(BOARD_NUM),
        slms_num               => CFG_NSLM_TILE_CHIPLET(BOARD_NUM) + CFG_NSLMDDR_TILE_CHIPLET(BOARD_NUM),
        nocs_num               => 2,
        tiles_num              => CFG_CHIPLET_TILES(BOARD_NUM),
        accelerators_num       => CFG_NACC_TILE_CHIPLET(BOARD_NUM),
        l2_num                 => CFG_NL2_CHIPLET(BOARD_NUM),
        llc_num                => CFG_NLLC_CHIPLET(BOARD_NUM),
        mon_ddr_en             => CFG_MON_DDR_EN,
        mon_mem_en             => CFG_MON_MEM_EN,
        mon_noc_tile_inject_en => CFG_MON_NOC_INJECT_EN,
        mon_noc_queues_full_en => CFG_MON_NOC_QUEUES_EN,
        mon_acc_en             => CFG_MON_ACC_EN,
        mon_l2_en              => CFG_MON_L2_EN,
        mon_llc_en             => CFG_MON_LLC_EN,
        mon_dvfs_en            => CFG_MON_DVFS_EN)
      port map (
        profpga_clk0_p  => profpga_clk0_p,
        profpga_clk0_n  => profpga_clk0_n,
        profpga_sync0_p => profpga_sync0_p,
        profpga_sync0_n => profpga_sync0_n,
        dmbi_h2f        => dmbi_h2f,
        dmbi_f2h        => dmbi_f2h,
        user_rstn       => user_rstn,
        mon_ddr         => mon_ddr_reg,
        mon_mem         => mon_mem_reg,
        mon_noc         => mon_noc_actual,
        mon_acc         => mon_acc,
        mon_l2          => mon_l2,
        mon_llc         => mon_llc,
        mon_dvfs        => mon_dvfs);

  end generate profpga_mmi64_gen;

  no_profpga_mmi64_gen : if CFG_MON_DDR_EN + CFG_MON_NOC_INJECT_EN + CFG_MON_NOC_QUEUES_EN + CFG_MON_ACC_EN + CFG_MON_DVFS_EN = 0 generate
    dmbi_f2h <= (others => '0');
  end generate no_profpga_mmi64_gen;

end;
