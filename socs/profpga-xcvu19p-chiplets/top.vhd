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
use work.svga_pkg.all;
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

entity top is
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

    c1_sys_clk_p      : in    std_logic;   -- 125 MHz clock
    c1_sys_clk_n      : in    std_logic;   -- 125 MHz clock
    c1_ddr4_act_n     : out   std_logic;
    c1_ddr4_adr       : out   std_logic_vector(16 downto 0);
    c1_ddr4_ba        : out   std_logic_vector(1 downto 0);
    c1_ddr4_bg        : out   std_logic_vector(1 downto 0);
    c1_ddr4_cke       : out   std_logic_vector(1 downto 0);
    c1_ddr4_odt       : out   std_logic_vector(1 downto 0);
    c1_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
    c1_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
    c1_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
    c1_ddr4_reset_n   : out   std_logic;
    c1_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
    c1_ddr4_dq        : inout std_logic_vector(71 downto 0);
    c1_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
    c1_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
    c1_calib_complete : out   std_logic;
    c1_diagnostic_led : out   std_ulogic;

    c2_sys_clk_p      : in    std_logic;   -- 125 MHz clock
    c2_sys_clk_n      : in    std_logic;   -- 125 MHz clock
    c2_ddr4_act_n     : out   std_logic;
    c2_ddr4_adr       : out   std_logic_vector(16 downto 0);
    c2_ddr4_ba        : out   std_logic_vector(1 downto 0);
    c2_ddr4_bg        : out   std_logic_vector(1 downto 0);
    c2_ddr4_cke       : out   std_logic_vector(1 downto 0);
    c2_ddr4_odt       : out   std_logic_vector(1 downto 0);
    c2_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
    c2_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
    c2_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
    c2_ddr4_reset_n   : out   std_logic;
    c2_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
    c2_ddr4_dq        : inout std_logic_vector(71 downto 0);
    c2_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
    c2_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
    c2_calib_complete : out   std_logic;
    c2_diagnostic_led : out   std_ulogic;

    c3_sys_clk_p      : in    std_logic;   -- 125 MHz clock
    c3_sys_clk_n      : in    std_logic;   -- 125 MHz clock
    c3_ddr4_act_n     : out   std_logic;
    c3_ddr4_adr       : out   std_logic_vector(16 downto 0);
    c3_ddr4_ba        : out   std_logic_vector(1 downto 0);
    c3_ddr4_bg        : out   std_logic_vector(1 downto 0);
    c3_ddr4_cke       : out   std_logic_vector(1 downto 0);
    c3_ddr4_odt       : out   std_logic_vector(1 downto 0);
    c3_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
    c3_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
    c3_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
    c3_ddr4_reset_n   : out   std_logic;
    c3_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
    c3_ddr4_dq        : inout std_logic_vector(71 downto 0);
    c3_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
    c3_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
    c3_calib_complete : out   std_logic;
    c3_diagnostic_led : out   std_ulogic;

    c4_sys_clk_p      : in    std_logic;   -- 125 MHz clock
    c4_sys_clk_n      : in    std_logic;   -- 125 MHz clock
    c4_ddr4_act_n     : out   std_logic;
    c4_ddr4_adr       : out   std_logic_vector(16 downto 0);
    c4_ddr4_ba        : out   std_logic_vector(1 downto 0);
    c4_ddr4_bg        : out   std_logic_vector(1 downto 0);
    c4_ddr4_cke       : out   std_logic_vector(1 downto 0);
    c4_ddr4_odt       : out   std_logic_vector(1 downto 0);
    c4_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
    c4_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
    c4_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
    c4_ddr4_reset_n   : out   std_logic;
    c4_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
    c4_ddr4_dq        : inout std_logic_vector(71 downto 0);
    c4_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
    c4_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
    c4_calib_complete : out   std_logic;
    c4_diagnostic_led : out   std_ulogic;

    c5_sys_clk_p      : in    std_logic;   -- 125 MHz clock
    c5_sys_clk_n      : in    std_logic;   -- 125 MHz clock
    c5_ddr4_act_n     : out   std_logic;
    c5_ddr4_adr       : out   std_logic_vector(16 downto 0);
    c5_ddr4_ba        : out   std_logic_vector(1 downto 0);
    c5_ddr4_bg        : out   std_logic_vector(1 downto 0);
    c5_ddr4_cke       : out   std_logic_vector(1 downto 0);
    c5_ddr4_odt       : out   std_logic_vector(1 downto 0);
    c5_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
    c5_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
    c5_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
    c5_ddr4_reset_n   : out   std_logic;
    c5_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
    c5_ddr4_dq        : inout std_logic_vector(71 downto 0);
    c5_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
    c5_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
    c5_calib_complete : out   std_logic;
    c5_diagnostic_led : out   std_ulogic;

    c6_sys_clk_p      : in    std_logic;   -- 125 MHz clock
    c6_sys_clk_n      : in    std_logic;   -- 125 MHz clock
    c6_ddr4_act_n     : out   std_logic;
    c6_ddr4_adr       : out   std_logic_vector(16 downto 0);
    c6_ddr4_ba        : out   std_logic_vector(1 downto 0);
    c6_ddr4_bg        : out   std_logic_vector(1 downto 0);
    c6_ddr4_cke       : out   std_logic_vector(1 downto 0);
    c6_ddr4_odt       : out   std_logic_vector(1 downto 0);
    c6_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
    c6_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
    c6_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
    c6_ddr4_reset_n   : out   std_logic;
    c6_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
    c6_ddr4_dq        : inout std_logic_vector(71 downto 0);
    c6_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
    c6_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
    c6_calib_complete : out   std_logic;
    c6_diagnostic_led : out   std_ulogic;

--    c7_sys_clk_p      : in    std_logic;   -- 125 MHz clock
--    c7_sys_clk_n      : in    std_logic;   -- 125 MHz clock
--    c7_ddr4_act_n     : out   std_logic;
--    c7_ddr4_adr       : out   std_logic_vector(16 downto 0);
--    c7_ddr4_ba        : out   std_logic_vector(1 downto 0);
--    c7_ddr4_bg        : out   std_logic_vector(1 downto 0);
--    c7_ddr4_cke       : out   std_logic_vector(1 downto 0);
--    c7_ddr4_odt       : out   std_logic_vector(1 downto 0);
--    c7_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
--    c7_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
--    c7_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
--    c7_ddr4_reset_n   : out   std_logic;
--    c7_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
--    c7_ddr4_dq        : inout std_logic_vector(71 downto 0);
--    c7_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
--    c7_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
--    c7_calib_complete : out   std_logic;
--    c7_diagnostic_led : out   std_ulogic;
    -- UART
    uart_rxd          : in    std_ulogic;
    uart_txd          : out   std_ulogic;
    uart_ctsn         : in    std_ulogic;
    uart_rtsn         : out   std_ulogic;
    -- Ethernet signals
    reset_o2          : out   std_ulogic;
    etx_clk           : in    std_ulogic;
    erx_clk           : in    std_ulogic;
    erxd              : in    std_logic_vector(3 downto 0);
    erx_dv            : in    std_ulogic;
    erx_er            : in    std_ulogic;
    erx_col           : in    std_ulogic;
    erx_crs           : in    std_ulogic;
    etxd              : out   std_logic_vector(3 downto 0);
    etx_en            : out   std_ulogic;
    etx_er            : out   std_ulogic;
    emdc              : out   std_ulogic;
    emdio             : inout std_logic;
    -- DVI
    --tft_nhpd          : in    std_ulogic;  -- Hot plug
    --tft_clk_p         : out   std_ulogic;
    --tft_clk_n         : out   std_ulogic;
    --tft_data          : out   std_logic_vector(23 downto 0);
    --tft_hsync         : out   std_ulogic;
    --tft_vsync         : out   std_ulogic;
    --tft_de            : out   std_ulogic;
    --tft_dken          : out   std_ulogic;
    --tft_ctl1_a1_dk1   : out   std_ulogic;
    --tft_ctl2_a2_dk2   : out   std_ulogic;
    --tft_a3_dk3        : out   std_ulogic;
    --tft_isel          : out   std_ulogic;
    --tft_bsel          : out   std_logic;
    --tft_dsel          : out   std_logic;
    --tft_edge          : out   std_ulogic;
    --tft_npd           : out   std_ulogic;

    LED_RED    : out std_ulogic;
    LED_GREEN  : out std_ulogic;
    LED_BLUE   : out std_ulogic;
    LED_YELLOW : out std_ulogic
    );
end;


architecture rtl of top is
  constant D2D_RX_MMCM_CLKIN_PERIOD_NS : real := 6.250;
  constant D2D_RX_MMCM_REF_JITTER1_UI  : real := 0.050;
  constant D2D_RX_MMCM_PHASE_DEG_C0    : real := 45.000;
  constant D2D_RX_MMCM_PHASE_DEG_C1    : real := 33.750;
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

  component bypass_router is
    generic (
      flow_control        : integer;
      width               : integer;
      depth               : integer;
      ports               : std_logic_vector(3 downto 0);
      DEST_SIZE           : integer
    );
    port (
      clk                 : in  std_logic;
      rst                 : in  std_logic;
      CONST_local_chip_x  : in std_logic_vector(CHIP_YX_WIDTH-1 downto 0);
      CONST_local_chip_y  : in std_logic_vector(CHIP_YX_WIDTH-1 downto 0);

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
  signal d2d_rstn, d2d_rst, d2d_rst_c0, d2d_rst_c1, d2d_rstn_c0, d2d_rstn_c1  : std_ulogic;
  signal rstraw_4, rstraw_5, rstraw_6, rstraw_7         : std_ulogic;
  signal lock, rst, rst_pad                             : std_ulogic;
  signal satellite_rst                                  : std_ulogic := '1';
  signal satellite_rst_count                           : std_logic_vector(7 downto 0) := (others => '0');
  signal migrstn, migrstn_1, migrstn_2, migrstn_3       : std_logic;
  signal migrstn_4, migrstn_5, migrstn_6, migrstn_7     : std_logic;
  signal cgi                                            : clkgen_in_type;
  signal cgo, cgo_d2d                                   : clkgen_out_type;

---mig signals
  constant diagnostic_pending_max : unsigned(11 downto 0) := (others => '1');
  signal c0_calib_done        : std_ulogic;
  signal c0_diagnostic_count  : unsigned(26 downto 0) := (others => '0');
  signal c0_diagnostic_pending : unsigned(11 downto 0) := (others => '0');
  signal c0_diagnostic_phase_prev : std_ulogic := '0';
  signal c0_diagnostic_started : std_ulogic := '0';
  signal c0_diagnostic_toggle : std_ulogic;
  signal c1_calib_done        : std_ulogic;
  signal c1_diagnostic_count  : unsigned(26 downto 0) := (others => '0');
  signal c1_diagnostic_pending : unsigned(11 downto 0) := (others => '0');
  signal c1_diagnostic_phase_prev : std_ulogic := '0';
  signal c1_diagnostic_started : std_ulogic := '0';
  signal c1_diagnostic_toggle : std_ulogic;
  signal c2_calib_done        : std_ulogic;
  signal c2_diagnostic_count  : unsigned(26 downto 0) := (others => '0');
  signal c2_diagnostic_pending : unsigned(11 downto 0) := (others => '0');
  signal c2_diagnostic_phase_prev : std_ulogic := '0';
  signal c2_diagnostic_started : std_ulogic := '0';
  signal c2_diagnostic_toggle : std_ulogic;
  signal c3_calib_done        : std_ulogic;
  signal c3_diagnostic_count  : unsigned(26 downto 0) := (others => '0');
  signal c3_diagnostic_pending : unsigned(11 downto 0) := (others => '0');
  signal c3_diagnostic_phase_prev : std_ulogic := '0';
  signal c3_diagnostic_started : std_ulogic := '0';
  signal c3_diagnostic_toggle : std_ulogic;
  signal c4_calib_done        : std_ulogic;
  signal c4_diagnostic_count  : unsigned(26 downto 0) := (others => '0');
  signal c4_diagnostic_toggle : std_ulogic;
  signal c5_calib_done        : std_ulogic;
  signal c5_diagnostic_count  : unsigned(26 downto 0) := (others => '0');
  signal c5_diagnostic_toggle : std_ulogic;
  signal c6_calib_done        : std_ulogic;
  signal c6_diagnostic_count  : std_logic_vector(26 downto 0);
  signal c6_diagnostic_toggle : std_ulogic;
--  signal c7_calib_done        : std_ulogic;
--  signal c7_diagnostic_count  : std_logic_vector(26 downto 0);
--  signal c7_diagnostic_toggle : std_ulogic;
  signal front_panel_blink_count : std_logic_vector(26 downto 0);
  signal front_panel_blink       : std_ulogic;
  signal front_led_blue_dbg      : std_ulogic;
  signal front_led_yellow_dbg    : std_ulogic;

-- Ethernet signals
  signal ethi : eth_in_type;
  signal etho : eth_out_type;

-- Tiles

-- UART
  signal uart_rxd_int  : std_logic;       -- UART1_RX (u1i.rxd)
  signal uart_txd_int  : std_logic;       -- UART1_TX (u1o.txd)
  signal uart_ctsn_int : std_logic;       -- UART1_RTSN (u1i.ctsn)
  signal uart_rtsn_int : std_logic;       -- UART1_RTSN (u1o.rtsn)

constant MAX_NMEM_TILES : integer := 8;
-- Memory controller DDR4
  signal ddr_ahbsi : ahb_slv_in_vector_type(0 to MAX_NMEM_TILES - 1);
  signal ddr_ahbso : ahb_slv_out_vector_type(0 to MAX_NMEM_TILES - 1);

-- Ethernet
constant CPU_FREQ : integer := 100000;  -- cpu frequency in KHz
  signal eth0_apbi   : apb_slv_in_type;
  signal eth0_apbo   : apb_slv_out_type;
  signal sgmii0_apbi : apb_slv_in_type;

  signal sgmii0_apbo : apb_slv_out_type;
  signal eth0_ahbmi  : ahb_mst_in_type;
  signal eth0_ahbmo  : ahb_mst_out_type;
  signal edcl_ahbmo  : ahb_mst_out_type;


-- D2D
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
  constant C0_LINK_ACTIVE : boolean := ((D2D_CHANNELS_W > 0) or (D2D_CHANNELS_E > 0)) and (not ISOLATE_BOARD0_D2D);
  constant C1_LINK_ACTIVE : boolean := ((D2D_CHANNELS_N > 0) or (D2D_CHANNELS_S > 0)) and (not ISOLATE_BOARD0_D2D);
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


-- DVI

  component svga2tfp410
    generic (
      tech : integer);
    port (
      clk         : in  std_ulogic;
      rstn        : in  std_ulogic;
      vgaclk_fb   : in  std_ulogic;
      vgao        : in  apbvga_out_type;
      vgaclk      : out std_ulogic;
      idck_p      : out std_ulogic;
      idck_n      : out std_ulogic;
      data        : out std_logic_vector(23 downto 0);
      hsync       : out std_ulogic;
      vsync       : out std_ulogic;
      de          : out std_ulogic;
      dken        : out std_ulogic;
      ctl1_a1_dk1 : out std_ulogic;
      ctl2_a2_dk2 : out std_ulogic;
      a3_dk3      : out std_ulogic;
      isel        : out std_ulogic;
      bsel        : out std_ulogic;
      dsel        : out std_ulogic;
      edge        : out std_ulogic;
      npd         : out std_ulogic);
  end component;

  signal dvi_apbi  : apb_slv_in_type;
  signal dvi_apbo  : apb_slv_out_type;
  signal dvi_ahbmi : ahb_mst_in_type;
  signal dvi_ahbmo : ahb_mst_out_type;

  signal dvi_nhpd        : std_ulogic;
  signal dvi_data        : std_logic_vector(23 downto 0);
  signal dvi_hsync       : std_ulogic;
  signal dvi_vsync       : std_ulogic;
  signal dvi_de          : std_ulogic;
  signal dvi_dken        : std_ulogic;
  signal dvi_ctl1_a1_dk1 : std_ulogic;
  signal dvi_ctl2_a2_dk2 : std_ulogic;
  signal dvi_a3_dk3      : std_ulogic;
  signal dvi_isel        : std_ulogic;
  signal dvi_bsel        : std_ulogic;
  signal dvi_dsel        : std_ulogic;
  signal dvi_edge        : std_ulogic;
  signal dvi_npd         : std_ulogic;

  signal vgao                       : apbvga_out_type;
  signal clkvga, clkvga_p, clkvga_n : std_ulogic;

  attribute syn_keep               : boolean;
  attribute syn_preserve           : boolean;
  attribute syn_keep of clkvga     : signal is true;
  attribute syn_preserve of clkvga : signal is true;
  attribute keep                   : boolean;
  attribute keep of clkvga         : signal is true;

-- CPU flags
  signal cpuerr : std_ulogic;

-- NOC
  signal chip_rstn, chip_rst  : std_ulogic;
  signal d2d_rx_clocks_locked : std_ulogic;
  signal d2d_ready_c0, d2d_ready_c1   : std_ulogic;
  signal d2d_ready_sync_c0, d2d_ready_sync_c1 : std_ulogic := '0';
  signal d2d_ready_sync_c0_1, d2d_ready_sync_c1_1 : std_ulogic := '0';
  signal d2d_startup_done : std_ulogic := '0';
  signal sys_clk        : std_logic_vector(0 to MAX_NMEM_TILES - 1);
  signal esp_clk        : std_ulogic;
  signal chip_refclk    : std_ulogic;

  attribute keep of clkm        : signal is true;
  attribute keep of clkm_1      : signal is true;
  attribute keep of clkm_2      : signal is true;
  attribute keep of clkm_3      : signal is true;
  attribute keep of clkm_4      : signal is true;
  attribute keep of clkm_5      : signal is true;
  attribute keep of clkm_6      : signal is true;
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
  constant CREDIT_CDC_CNT_W : integer := 6;
  
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

  gen_main_board : if BOARD_NUM = 0 generate
    c0_diagnostic_phase : process (cable_clk_rcv_core_0)
    begin
      if rising_edge(cable_clk_rcv_core_0) then
        if c0_rx_core_run = '0' then
          c0_diagnostic_count <= (others => '0');
          c0_diagnostic_phase_prev <= '0';
        else
          c0_diagnostic_phase_prev <= c0_diagnostic_count(26);
          c0_diagnostic_count <= c0_diagnostic_count + 1;
        end if;
      end if;
    end process c0_diagnostic_phase;

    c0_diagnostic_pending_q : process (cable_clk_rcv_core_0)
      variable next_c0_pending : unsigned(c0_diagnostic_pending'range);
      variable next_c0_started : std_ulogic;
    begin
      if rising_edge(cable_clk_rcv_core_0) then
        if c0_rx_core_run = '0' then
          c0_diagnostic_pending <= (others => '0');
          c0_diagnostic_started <= '0';
        else
          next_c0_pending := c0_diagnostic_pending;
          next_c0_started := c0_diagnostic_started;
          if c0_d2d_data_rx_pipe(66) = '1' and next_c0_pending /= diagnostic_pending_max then
            next_c0_pending := next_c0_pending + 1;
          end if;

          if next_c0_pending = 0 then
            next_c0_started := '0';
          elsif c0_diagnostic_phase_prev = '0' and c0_diagnostic_count(26) = '1' then
            next_c0_started := '1';
          elsif c0_diagnostic_phase_prev = '1' and c0_diagnostic_count(26) = '0' and next_c0_started = '1' then
            next_c0_pending := next_c0_pending - 1;
            if next_c0_pending = 0 then
              next_c0_started := '0';
            end if;
          end if;

          c0_diagnostic_pending <= next_c0_pending;
          c0_diagnostic_started <= next_c0_started;
        end if;
      end if;
    end process c0_diagnostic_pending_q;
    c0_diagnostic_toggle <= c0_diagnostic_count(26) when c0_diagnostic_pending /= 0 and c0_diagnostic_started = '1' else '0';
    c0_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c0_diagnostic_led, c0_diagnostic_toggle);
  
    c1_diagnostic_phase : process (d2d_clk_int)
    begin
      if rising_edge(d2d_clk_int) then
        if d2d_rstn_c0_d2d = '0' then
          c1_diagnostic_count <= (others => '0');
          c1_diagnostic_phase_prev <= '0';
        else
          c1_diagnostic_phase_prev <= c1_diagnostic_count(26);
          c1_diagnostic_count <= c1_diagnostic_count + 1;
        end if;
      end if;
    end process c1_diagnostic_phase;

    c1_diagnostic_pending_q : process (d2d_clk_int)
      variable next_c1_pending : unsigned(c1_diagnostic_pending'range);
      variable next_c1_started : std_ulogic;
    begin
      if rising_edge(d2d_clk_int) then
        if d2d_rstn_c0_d2d = '0' then
          c1_diagnostic_pending <= (others => '0');
          c1_diagnostic_started <= '0';
        else
          next_c1_pending := c1_diagnostic_pending;
          next_c1_started := c1_diagnostic_started;
          if c0_d2d_data_tx_io(65) = '1' and c0_d2d_data_tx_io(67) = '1' and next_c1_pending /= diagnostic_pending_max then
            next_c1_pending := next_c1_pending + 1;
          end if;

          if next_c1_pending = 0 then
            next_c1_started := '0';
          elsif c1_diagnostic_phase_prev = '0' and c1_diagnostic_count(26) = '1' then
            next_c1_started := '1';
          elsif c1_diagnostic_phase_prev = '1' and c1_diagnostic_count(26) = '0' and next_c1_started = '1' then
            next_c1_pending := next_c1_pending - 1;
            if next_c1_pending = 0 then
              next_c1_started := '0';
            end if;
          end if;

          c1_diagnostic_pending <= next_c1_pending;
          c1_diagnostic_started <= next_c1_started;
        end if;
      end if;
    end process c1_diagnostic_pending_q;
    c1_diagnostic_toggle <= c1_diagnostic_count(26) when c1_diagnostic_pending /= 0 and c1_diagnostic_started = '1' else '0';
    c1_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c1_diagnostic_led, c1_diagnostic_toggle);
  
    c2_diagnostic_phase : process (d2d_clk_int)
    begin
      if rising_edge(d2d_clk_int) then
        if d2d_rstn_c1_d2d = '0' then
          c2_diagnostic_count <= (others => '0');
          c2_diagnostic_phase_prev <= '0';
        else
          c2_diagnostic_phase_prev <= c2_diagnostic_count(26);
          c2_diagnostic_count <= c2_diagnostic_count + 1;
        end if;
      end if;
    end process c2_diagnostic_phase;

    c2_diagnostic_pending_q : process (d2d_clk_int)
      variable next_c2_pending : unsigned(c2_diagnostic_pending'range);
      variable next_c2_started : std_ulogic;
    begin
      if rising_edge(d2d_clk_int) then
        if d2d_rstn_c1_d2d = '0' then
          c2_diagnostic_pending <= (others => '0');
          c2_diagnostic_started <= '0';
        else
          next_c2_pending := c2_diagnostic_pending;
          next_c2_started := c2_diagnostic_started;
          if c1_credit_in_evt_pulse_d2d = '1' and next_c2_pending /= diagnostic_pending_max then
            next_c2_pending := next_c2_pending + 1;
          end if;

          if next_c2_pending = 0 then
            next_c2_started := '0';
          elsif c2_diagnostic_phase_prev = '0' and c2_diagnostic_count(26) = '1' then
            next_c2_started := '1';
          elsif c2_diagnostic_phase_prev = '1' and c2_diagnostic_count(26) = '0' and next_c2_started = '1' then
            next_c2_pending := next_c2_pending - 1;
            if next_c2_pending = 0 then
              next_c2_started := '0';
            end if;
          end if;

          c2_diagnostic_pending <= next_c2_pending;
          c2_diagnostic_started <= next_c2_started;
        end if;
      end if;
    end process c2_diagnostic_pending_q;
    c2_diagnostic_toggle <= c2_diagnostic_count(26) when c2_diagnostic_pending /= 0 and c2_diagnostic_started = '1' else '0';
    c2_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c2_diagnostic_led, c2_diagnostic_toggle);
  
    c3_diagnostic_phase : process (d2d_clk_int)
    begin
      if rising_edge(d2d_clk_int) then
        if d2d_rstn_c1_d2d = '0' then
          c3_diagnostic_count <= (others => '0');
          c3_diagnostic_phase_prev <= '0';
        else
          c3_diagnostic_phase_prev <= c3_diagnostic_count(26);
          c3_diagnostic_count <= c3_diagnostic_count + 1;
        end if;
      end if;
    end process c3_diagnostic_phase;

    c3_diagnostic_pending_q : process (d2d_clk_int)
      variable next_c3_pending : unsigned(c3_diagnostic_pending'range);
      variable next_c3_started : std_ulogic;
    begin
      if rising_edge(d2d_clk_int) then
        if d2d_rstn_c1_d2d = '0' then
          c3_diagnostic_pending <= (others => '0');
          c3_diagnostic_started <= '0';
        else
          next_c3_pending := c3_diagnostic_pending;
          next_c3_started := c3_diagnostic_started;
          if c1_d2d_data_tx_io(65) = '1' and c1_d2d_data_tx_io(67) = '1' and next_c3_pending /= diagnostic_pending_max then
            next_c3_pending := next_c3_pending + 1;
          end if;

          if next_c3_pending = 0 then
            next_c3_started := '0';
          elsif c3_diagnostic_phase_prev = '0' and c3_diagnostic_count(26) = '1' then
            next_c3_started := '1';
          elsif c3_diagnostic_phase_prev = '1' and c3_diagnostic_count(26) = '0' and next_c3_started = '1' then
            next_c3_pending := next_c3_pending - 1;
            if next_c3_pending = 0 then
              next_c3_started := '0';
            end if;
          end if;

          c3_diagnostic_pending <= next_c3_pending;
          c3_diagnostic_started <= next_c3_started;
        end if;
      end if;
    end process c3_diagnostic_pending_q;
    c3_diagnostic_toggle <= c3_diagnostic_count(26) when c3_diagnostic_pending /= 0 and c3_diagnostic_started = '1' else '0';
    c3_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c3_diagnostic_led, c3_diagnostic_toggle);
  
    c4_diagnostic : process (cable_clk_rcv_core_0)
    begin
      if rising_edge(cable_clk_rcv_core_0) then
        if c0_rx_core_run = '0' then
          c4_diagnostic_count <= (others => '0');
        else
          c4_diagnostic_count <= c4_diagnostic_count + 1;
        end if;
      end if;
    end process c4_diagnostic;
    c4_diagnostic_toggle <= c4_diagnostic_count(26);
    c4_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c4_diagnostic_led, c4_diagnostic_toggle);
  
    c5_diagnostic : process (cable_clk_rcv_core_1)
    begin
      if rising_edge(cable_clk_rcv_core_1) then
        if c1_rx_core_run = '0' then
          c5_diagnostic_count <= (others => '0');
        else
          c5_diagnostic_count <= c5_diagnostic_count + 1;
        end if;
      end if;
    end process c5_diagnostic;
    c5_diagnostic_toggle <= c5_diagnostic_count(26);
    c5_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c5_diagnostic_led, c5_diagnostic_toggle);
  
    c6_diagnostic : process (cable_clk_rcv_raw_0, rst)
    begin  -- process c6_diagnostic
      if rst = '1' then           -- asynchronous reset (active high)
        c6_diagnostic_count <= (others => '0');
      elsif cable_clk_rcv_raw_0'event and cable_clk_rcv_raw_0 = '1' then  -- rising clock edge
        c6_diagnostic_count <= c6_diagnostic_count + 1;
      end if;
    end process c6_diagnostic;
    c6_diagnostic_toggle <= c6_diagnostic_count(26);
    c6_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c6_diagnostic_led, c6_diagnostic_toggle);
  
--  c7_diagnostic : process (clkm_7, clkm_sync_rst_7)
--  begin  -- process c7_diagnostic
--    if clkm_sync_rst_7 = '1' then           -- asynchronous reset (active high)
--      c7_diagnostic_count <= (others => '0');
--    elsif clkm_7'event and clkm_7 = '1' then  -- rising clock edge
--      c7_diagnostic_count <= c7_diagnostic_count + 1;
--    end if;
--  end process c7_diagnostic;
--  c7_diagnostic_toggle <= c7_diagnostic_count(26);
--  c7_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c7_diagnostic_led, c7_diagnostic_toggle);
end generate gen_main_board;

-------------------------------------------------------------------------------
-- Leds -----------------------------------------------------------------------
-------------------------------------------------------------------------------

  front_panel_blink_gen : process (clkm, rst)
  begin
    if rst = '1' then
      front_panel_blink_count <= (others => '0');
    elsif clkm'event and clkm = '1' then
      front_panel_blink_count <= front_panel_blink_count + 1;
    end if;
  end process front_panel_blink_gen;

  front_panel_blink <= front_panel_blink_count(26);


  -- From memory controllers' PLLs
  lock_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v) port map (LED_GREEN, lock);

  -- From CPU 0 (on chip)
  cpuerr_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v) port map (LED_RED, cpuerr);
  --pragma translate_off
  process(clkm, rstn)
  begin  -- process
    if rstn = '1' then
      assert cpuerr = '0' report "Program Completed!" severity failure;
    end if;
  end process;
  --pragma translate_on

  gen_main_board_1 : if BOARD_NUM = 0 generate
    -- From DDR controller (on FPGA)
    calib0_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c0_calib_complete, c0_calib_done);
    calib1_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c1_calib_complete, c1_calib_done);
    calib2_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c2_calib_complete, c2_calib_done);
    calib3_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c3_calib_complete, c3_calib_done);
    calib4_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c4_calib_complete, c4_calib_done);
    calib5_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c5_calib_complete, c5_calib_done);
    calib6_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c6_calib_complete, c6_calib_done);
    --calib7_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c7_calib_complete, c7_calib_done);
  end generate gen_main_board_1;


  -- Encode D2D status as blinking LEDs so the indication is still readable
  -- even if the board LEDs are wired active-low.
  led3_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v) port map (LED_BLUE, front_led_blue_dbg);

  led4_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v) port map (LED_YELLOW, front_led_yellow_dbg);

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

  lock <= c0_calib_done and c1_calib_done and c2_calib_done and c3_calib_done and c4_calib_done
          and c5_calib_done and c6_calib_done and cgo.clklock;

  reset_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (reset, rst);

  rst_c0      : rstgen                    -- C1 (Vertical) D2D reset generator
    generic map (acthigh => 1, syncin => 0)
    port map (rst, clkm, lock, d2d_rstn_c1, open);
  rst_c1      : rstgen                    -- C0 (Horizontal) D2D reset generator
    generic map (acthigh => 1, syncin => 0)
    port map (d2d_rst_c1, clkm, d2d_ready_sync_c1, d2d_rstn_c0, open);
  
  d2d_rst_c0 <= not d2d_rstn_c0;
  d2d_rst_c1 <= not d2d_rstn_c1;
  d2d_rst <= not d2d_rstn_c0;
  d2d_rx_clocks_locked <= d2d_rx_mmcm_locked0 and d2d_rx_mmcm_locked1;
  c1_d2d_link_ready <= (d2d_tx_link_ready_n and d2d_rx_link_ready_n) when C1_IS_NORTH else
                       (d2d_tx_link_ready_s and d2d_rx_link_ready_s);
  c0_d2d_link_ready <= (d2d_tx_link_ready_w and d2d_rx_link_ready_w) when C0_IS_WEST else
                       (d2d_tx_link_ready_e and d2d_rx_link_ready_e);
  front_led_blue_dbg <= (d2d_rx_clocks_locked and front_panel_blink);
  front_led_yellow_dbg <= (d2d_startup_done and front_panel_blink);

  d2d_ready_c0 <= '1' when (BOARD_NUM = 0 and ISOLATE_BOARD0_D2D) else
                  '1' when (D2D_CHANNELS_E = 0 and D2D_CHANNELS_W = 0) else
                  c0_d2d_link_ready;
  d2d_ready_c1 <= '1' when (BOARD_NUM = 0 and ISOLATE_BOARD0_D2D) else
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
  mig_rst1 : rstgen                         -- reset generator
    generic map (acthigh => 1)
    port map (rst, clkm_1, lock, migrstn_1, rstraw_1);
  mig_rst2 : rstgen                         -- reset generator
    generic map (acthigh => 1)
    port map (rst, clkm_2, lock, migrstn_2, rstraw_2);
  mig_rst3 : rstgen                         -- reset generator
    generic map (acthigh => 1)
    port map (rst, clkm_3, lock, migrstn_3, rstraw_3);
  mig_rst4 : rstgen                         -- reset generator
    generic map (acthigh => 1)
    port map (rst, clkm_4, lock, migrstn_4, rstraw_4);
  mig_rst5 : rstgen                         -- reset generator
    generic map (acthigh => 1)
    port map (rst, clkm_5, lock, migrstn_5, rstraw_5);
  mig_rst6 : rstgen                         -- reset generator
    generic map (acthigh => 1)
    port map (rst, clkm_6, lock, migrstn_6, rstraw_6);
--  mig_rst7 : rstgen                         -- reset generator
--    generic map (acthigh => 1)
--    port map (rst, clkm_7, lock, migrstn_7, rstraw_7);

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
  uart_rxd_pad  : inpad  generic map (level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_rxd, uart_rxd_int);
  uart_txd_pad  : outpad generic map (level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_txd, uart_txd_int);
  uart_ctsn_pad : inpad  generic map (level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_ctsn, uart_ctsn_int);
  uart_rtsn_pad : outpad generic map (level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_rtsn, uart_rtsn_int);

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

    ddrc1 : ahb2mig_ebddr4r5
      generic map (
        hindex => 0,
        haddr  => ddr_haddr(this_ddr_index(1)),
        hmask  => ddr_hmask(this_ddr_index(1)))
      port map (
        c0_sys_clk_p     => c1_sys_clk_p,
        c0_sys_clk_n     => c1_sys_clk_n,
        c0_ddr4_act_n    => c1_ddr4_act_n,
        c0_ddr4_adr      => c1_ddr4_adr,
        c0_ddr4_ba       => c1_ddr4_ba,
        c0_ddr4_bg       => c1_ddr4_bg,
        c0_ddr4_cke      => c1_ddr4_cke,
        c0_ddr4_odt      => c1_ddr4_odt,
        c0_ddr4_cs_n     => c1_ddr4_cs_n,
        c0_ddr4_ck_t     => c1_ddr4_ck_t,
        c0_ddr4_ck_c     => c1_ddr4_ck_c,
        c0_ddr4_reset_n  => c1_ddr4_reset_n,
        c0_ddr4_dm_dbi_n => c1_ddr4_dm_dbi_n,
        c0_ddr4_dq       => c1_ddr4_dq,
        c0_ddr4_dqs_c    => c1_ddr4_dqs_c,
        c0_ddr4_dqs_t    => c1_ddr4_dqs_t,
        ahbso            => ddr_ahbso(1),
        ahbsi            => ddr_ahbsi(1),
        calib_done       => c1_calib_done,
        rst_n_syn        => migrstn_1,
        rst_n_async      => rstraw_1,
        clk_amba         => clkm_1,
        ui_clk           => clkm_1,
        ui_clk_sync_rst  => clkm_sync_rst_1
        );

    ddrc2 : ahb2mig_ebddr4r5
      generic map (
        hindex => 0,
        haddr  => ddr_haddr(this_ddr_index(2)),
        hmask  => ddr_hmask(this_ddr_index(2)))
      port map (
        c0_sys_clk_p     => c2_sys_clk_p,
        c0_sys_clk_n     => c2_sys_clk_n,
        c0_ddr4_act_n    => c2_ddr4_act_n,
        c0_ddr4_adr      => c2_ddr4_adr,
        c0_ddr4_ba       => c2_ddr4_ba,
        c0_ddr4_bg       => c2_ddr4_bg,
        c0_ddr4_cke      => c2_ddr4_cke,
        c0_ddr4_odt      => c2_ddr4_odt,
        c0_ddr4_cs_n     => c2_ddr4_cs_n,
        c0_ddr4_ck_t     => c2_ddr4_ck_t,
        c0_ddr4_ck_c     => c2_ddr4_ck_c,
        c0_ddr4_reset_n  => c2_ddr4_reset_n,
        c0_ddr4_dm_dbi_n => c2_ddr4_dm_dbi_n,
        c0_ddr4_dq       => c2_ddr4_dq,
        c0_ddr4_dqs_c    => c2_ddr4_dqs_c,
        c0_ddr4_dqs_t    => c2_ddr4_dqs_t,
        ahbso            => ddr_ahbso(2),
        ahbsi            => ddr_ahbsi(2),
        calib_done       => c2_calib_done,
        rst_n_syn        => migrstn_2,
        rst_n_async      => rstraw_2,
        clk_amba         => clkm_2,
        ui_clk           => clkm_2,
        ui_clk_sync_rst  => clkm_sync_rst_2
        );

    ddrc3 : ahb2mig_ebddr4r5
      generic map (
        hindex => 0,
        haddr  => ddr_haddr(this_ddr_index(3)),
        hmask  => ddr_hmask(this_ddr_index(3)))
      port map (
        c0_sys_clk_p     => c3_sys_clk_p,
        c0_sys_clk_n     => c3_sys_clk_n,
        c0_ddr4_act_n    => c3_ddr4_act_n,
        c0_ddr4_adr      => c3_ddr4_adr,
        c0_ddr4_ba       => c3_ddr4_ba,
        c0_ddr4_bg       => c3_ddr4_bg,
        c0_ddr4_cke      => c3_ddr4_cke,
        c0_ddr4_odt      => c3_ddr4_odt,
        c0_ddr4_cs_n     => c3_ddr4_cs_n,
        c0_ddr4_ck_t     => c3_ddr4_ck_t,
        c0_ddr4_ck_c     => c3_ddr4_ck_c,
        c0_ddr4_reset_n  => c3_ddr4_reset_n,
        c0_ddr4_dm_dbi_n => c3_ddr4_dm_dbi_n,
        c0_ddr4_dq       => c3_ddr4_dq,
        c0_ddr4_dqs_c    => c3_ddr4_dqs_c,
        c0_ddr4_dqs_t    => c3_ddr4_dqs_t,
        ahbso            => ddr_ahbso(3),
        ahbsi            => ddr_ahbsi(3),
        calib_done       => c3_calib_done,
        rst_n_syn        => migrstn_3,
        rst_n_async      => rstraw_3,
        clk_amba         => clkm_3,
        ui_clk           => clkm_3,
        ui_clk_sync_rst  => clkm_sync_rst_3
        );

    ddrc4 : ahb2mig_ebddr4r5
      generic map (
        hindex => 0,
        haddr  => ddr_haddr(this_ddr_index(4)),
        hmask  => ddr_hmask(this_ddr_index(4)))
      port map (
        c0_sys_clk_p     => c4_sys_clk_p,
        c0_sys_clk_n     => c4_sys_clk_n,
        c0_ddr4_act_n    => c4_ddr4_act_n,
        c0_ddr4_adr      => c4_ddr4_adr,
        c0_ddr4_ba       => c4_ddr4_ba,
        c0_ddr4_bg       => c4_ddr4_bg,
        c0_ddr4_cke      => c4_ddr4_cke,
        c0_ddr4_odt      => c4_ddr4_odt,
        c0_ddr4_cs_n     => c4_ddr4_cs_n,
        c0_ddr4_ck_t     => c4_ddr4_ck_t,
        c0_ddr4_ck_c     => c4_ddr4_ck_c,
        c0_ddr4_reset_n  => c4_ddr4_reset_n,
        c0_ddr4_dm_dbi_n => c4_ddr4_dm_dbi_n,
        c0_ddr4_dq       => c4_ddr4_dq,
        c0_ddr4_dqs_c    => c4_ddr4_dqs_c,
        c0_ddr4_dqs_t    => c4_ddr4_dqs_t,
        ahbso            => ddr_ahbso(4),
        ahbsi            => ddr_ahbsi(4),
        calib_done       => c4_calib_done,
        rst_n_syn        => migrstn_4,
        rst_n_async      => rstraw_4,
        clk_amba         => clkm_4,
        ui_clk           => clkm_4,
        ui_clk_sync_rst  => clkm_sync_rst_4
        );

    ddrc5 : ahb2mig_ebddr4r5
      generic map (
        hindex => 0,
        haddr  => ddr_haddr(this_ddr_index(5)),
        hmask  => ddr_hmask(this_ddr_index(5)))
      port map (
        c0_sys_clk_p     => c5_sys_clk_p,
        c0_sys_clk_n     => c5_sys_clk_n,
        c0_ddr4_act_n    => c5_ddr4_act_n,
        c0_ddr4_adr      => c5_ddr4_adr,
        c0_ddr4_ba       => c5_ddr4_ba,
        c0_ddr4_bg       => c5_ddr4_bg,
        c0_ddr4_cke      => c5_ddr4_cke,
        c0_ddr4_odt      => c5_ddr4_odt,
        c0_ddr4_cs_n     => c5_ddr4_cs_n,
        c0_ddr4_ck_t     => c5_ddr4_ck_t,
        c0_ddr4_ck_c     => c5_ddr4_ck_c,
        c0_ddr4_reset_n  => c5_ddr4_reset_n,
        c0_ddr4_dm_dbi_n => c5_ddr4_dm_dbi_n,
        c0_ddr4_dq       => c5_ddr4_dq,
        c0_ddr4_dqs_c    => c5_ddr4_dqs_c,
        c0_ddr4_dqs_t    => c5_ddr4_dqs_t,
        ahbso            => ddr_ahbso(5),
        ahbsi            => ddr_ahbsi(5),
        calib_done       => c5_calib_done,
        rst_n_syn        => migrstn_5,
        rst_n_async      => rstraw_5,
        clk_amba         => clkm_5,
        ui_clk           => clkm_5,
        ui_clk_sync_rst  => clkm_sync_rst_5
        );

    ddrc6 : ahb2mig_ebddr4r5
      generic map (
        hindex => 0,
        haddr  => ddr_haddr(this_ddr_index(6)),
        hmask  => ddr_hmask(this_ddr_index(6)))
      port map (
        c0_sys_clk_p     => c6_sys_clk_p,
        c0_sys_clk_n     => c6_sys_clk_n,
        c0_ddr4_act_n    => c6_ddr4_act_n,
        c0_ddr4_adr      => c6_ddr4_adr,
        c0_ddr4_ba       => c6_ddr4_ba,
        c0_ddr4_bg       => c6_ddr4_bg,
        c0_ddr4_cke      => c6_ddr4_cke,
        c0_ddr4_odt      => c6_ddr4_odt,
        c0_ddr4_cs_n     => c6_ddr4_cs_n,
        c0_ddr4_ck_t     => c6_ddr4_ck_t,
        c0_ddr4_ck_c     => c6_ddr4_ck_c,
        c0_ddr4_reset_n  => c6_ddr4_reset_n,
        c0_ddr4_dm_dbi_n => c6_ddr4_dm_dbi_n,
        c0_ddr4_dq       => c6_ddr4_dq,
        c0_ddr4_dqs_c    => c6_ddr4_dqs_c,
        c0_ddr4_dqs_t    => c6_ddr4_dqs_t,
        ahbso            => ddr_ahbso(6),
        ahbsi            => ddr_ahbsi(6),
        calib_done       => c6_calib_done,
        rst_n_syn        => migrstn_6,
        rst_n_async      => rstraw_6,
        clk_amba         => clkm_6,
        ui_clk           => clkm_6,
        ui_clk_sync_rst  => clkm_sync_rst_6
        );

--    ddrc7 : ahb2mig_ebddr4r5
--      generic map (
--        hindex => 0,
--        haddr  => ddr_haddr(this_ddr_index(7)),
--        hmask  => ddr_hmask(this_ddr_index(7)))
--      port map (
--        c0_sys_clk_p     => c7_sys_clk_p,
--        c0_sys_clk_n     => c7_sys_clk_n,
--        c0_ddr4_act_n    => c7_ddr4_act_n,
--        c0_ddr4_adr      => c7_ddr4_adr,
--        c0_ddr4_ba       => c7_ddr4_ba,
--        c0_ddr4_bg       => c7_ddr4_bg,
--        c0_ddr4_cke      => c7_ddr4_cke,
--        c0_ddr4_odt      => c7_ddr4_odt,
--        c0_ddr4_cs_n     => c7_ddr4_cs_n,
--        c0_ddr4_ck_t     => c7_ddr4_ck_t,
--        c0_ddr4_ck_c     => c7_ddr4_ck_c,
--        c0_ddr4_reset_n  => c7_ddr4_reset_n,
--        c0_ddr4_dm_dbi_n => c7_ddr4_dm_dbi_n,
--        c0_ddr4_dq       => c7_ddr4_dq,
--        c0_ddr4_dqs_c    => c7_ddr4_dqs_c,
--        c0_ddr4_dqs_t    => c7_ddr4_dqs_t,
--        ahbso            => ddr_ahbso(7),
--        ahbsi            => ddr_ahbsi(7),
--        calib_done       => c7_calib_done,
--        rst_n_syn        => migrstn_7,
--        rst_n_async      => rstraw_7,
--        clk_amba         => clkm_7,
--        ui_clk           => clkm_7,
--        ui_clk_sync_rst  => clkm_sync_rst_7
--        );
  end generate gen_mig;
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

    mig_ahbram1 : ahbram_sim
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
        haddr => ddr_haddr(this_ddr_index(1)),
        hmask => ddr_hmask(this_ddr_index(1)),
        ahbsi => ddr_ahbsi(1),
        ahbso => ddr_ahbso(1)
        );

    mig_ahbram2 : ahbram_sim
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
        haddr => ddr_haddr(this_ddr_index(2)),
        hmask => ddr_hmask(this_ddr_index(2)),
        ahbsi => ddr_ahbsi(2),
        ahbso => ddr_ahbso(2)
        );

    mig_ahbram3 : ahbram_sim
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
        haddr => ddr_haddr(this_ddr_index(3)),
        hmask => ddr_hmask(this_ddr_index(3)),
        ahbsi => ddr_ahbsi(3),
        ahbso => ddr_ahbso(3)
        );

    mig_ahbram4 : ahbram_sim
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
        haddr => ddr_haddr(this_ddr_index(4)),
        hmask => ddr_hmask(this_ddr_index(4)),
        ahbsi => ddr_ahbsi(4),
        ahbso => ddr_ahbso(4)
        );

    mig_ahbram5 : ahbram_sim
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
        haddr => ddr_haddr(this_ddr_index(5)),
        hmask => ddr_hmask(this_ddr_index(5)),
        ahbsi => ddr_ahbsi(5),
        ahbso => ddr_ahbso(5)
        );

    mig_ahbram6 : ahbram_sim
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
        haddr => ddr_haddr(this_ddr_index(6)),
        hmask => ddr_hmask(this_ddr_index(6)),
        ahbsi => ddr_ahbsi(6),
        ahbso => ddr_ahbso(6)
        );

    mig_ahbram7 : ahbram_sim
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
        haddr => ddr_haddr(this_ddr_index(7)),
        hmask => ddr_hmask(this_ddr_index(7)),
        ahbsi => ddr_ahbsi(7),
        ahbso => ddr_ahbso(7)
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

    c1_ddr4_act_n    <= '1';
    c1_ddr4_adr      <= (others => '0');
    c1_ddr4_ba       <= (others => '0');
    c1_ddr4_bg       <= (others => '0');
    c1_ddr4_cke      <= (others => '0');
    c1_ddr4_odt      <= (others => '0');
    c1_ddr4_cs_n     <= (others => '0');
    c1_ddr4_ck_t     <= (others => '0');
    c1_ddr4_ck_c     <= (others => '0');
    c1_ddr4_reset_n  <= '1';
    c1_ddr4_dm_dbi_n <= (others => 'Z');
    c1_ddr4_dq       <= (others => 'Z');
    c1_ddr4_dqs_c    <= (others => 'Z');
    c1_ddr4_dqs_t    <= (others => 'Z');
    c1_calib_done <= '1';
    clkm_1          <= not clkm_1        after 3.2 ns;

    c2_ddr4_act_n    <= '1';
    c2_ddr4_adr      <= (others => '0');
    c2_ddr4_ba       <= (others => '0');
    c2_ddr4_bg       <= (others => '0');
    c2_ddr4_cke      <= (others => '0');
    c2_ddr4_odt      <= (others => '0');
    c2_ddr4_cs_n     <= (others => '0');
    c2_ddr4_ck_t     <= (others => '0');
    c2_ddr4_ck_c     <= (others => '0');
    c2_ddr4_reset_n  <= '1';
    c2_ddr4_dm_dbi_n <= (others => 'Z');
    c2_ddr4_dq       <= (others => 'Z');
    c2_ddr4_dqs_c    <= (others => 'Z');
    c2_ddr4_dqs_t    <= (others => 'Z');
    c2_calib_done <= '1';
    clkm_2          <= not clkm_2        after 3.2 ns;

    c3_ddr4_act_n    <= '1';
    c3_ddr4_adr      <= (others => '0');
    c3_ddr4_ba       <= (others => '0');
    c3_ddr4_bg       <= (others => '0');
    c3_ddr4_cke      <= (others => '0');
    c3_ddr4_odt      <= (others => '0');
    c3_ddr4_cs_n     <= (others => '0');
    c3_ddr4_ck_t     <= (others => '0');
    c3_ddr4_ck_c     <= (others => '0');
    c3_ddr4_reset_n  <= '1';
    c3_ddr4_dm_dbi_n <= (others => 'Z');
    c3_ddr4_dq       <= (others => 'Z');
    c3_ddr4_dqs_c    <= (others => 'Z');
    c3_ddr4_dqs_t    <= (others => 'Z');
    c3_calib_done <= '1';
    clkm_3          <= not clkm_3        after 3.2 ns;

    c4_ddr4_act_n    <= '1';
    c4_ddr4_adr      <= (others => '0');
    c4_ddr4_ba       <= (others => '0');
    c4_ddr4_bg       <= (others => '0');
    c4_ddr4_cke      <= (others => '0');
    c4_ddr4_odt      <= (others => '0');
    c4_ddr4_cs_n     <= (others => '0');
    c4_ddr4_ck_t     <= (others => '0');
    c4_ddr4_ck_c     <= (others => '0');
    c4_ddr4_reset_n  <= '1';
    c4_ddr4_dm_dbi_n <= (others => 'Z');
    c4_ddr4_dq       <= (others => 'Z');
    c4_ddr4_dqs_c    <= (others => 'Z');
    c4_ddr4_dqs_t    <= (others => 'Z');
    c4_calib_done <= '1';
    clkm_4          <= not clkm_4        after 3.2 ns;

    c5_ddr4_act_n    <= '1';
    c5_ddr4_adr      <= (others => '0');
    c5_ddr4_ba       <= (others => '0');
    c5_ddr4_bg       <= (others => '0');
    c5_ddr4_cke      <= (others => '0');
    c5_ddr4_odt      <= (others => '0');
    c5_ddr4_cs_n     <= (others => '0');
    c5_ddr4_ck_t     <= (others => '0');
    c5_ddr4_ck_c     <= (others => '0');
    c5_ddr4_reset_n  <= '1';
    c5_ddr4_dm_dbi_n <= (others => 'Z');
    c5_ddr4_dq       <= (others => 'Z');
    c5_ddr4_dqs_c    <= (others => 'Z');
    c5_ddr4_dqs_t    <= (others => 'Z');
    c5_calib_done <= '1';
    clkm_5          <= not clkm_5        after 3.2 ns;

    c6_ddr4_act_n    <= '1';
    c6_ddr4_adr      <= (others => '0');
    c6_ddr4_ba       <= (others => '0');
    c6_ddr4_bg       <= (others => '0');
    c6_ddr4_cke      <= (others => '0');
    c6_ddr4_odt      <= (others => '0');
    c6_ddr4_cs_n     <= (others => '0');
    c6_ddr4_ck_t     <= (others => '0');
    c6_ddr4_ck_c     <= (others => '0');
    c6_ddr4_reset_n  <= '1';
    c6_ddr4_dm_dbi_n <= (others => 'Z');
    c6_ddr4_dq       <= (others => 'Z');
    c6_ddr4_dqs_c    <= (others => 'Z');
    c6_ddr4_dqs_t    <= (others => 'Z');
    c6_calib_done <= '1';
    clkm_6          <= not clkm_6        after 3.2 ns;

--    c7_ddr4_act_n    <= '1';
--    c7_ddr4_adr      <= (others => '0');
--    c7_ddr4_ba       <= (others => '0');
--    c7_ddr4_bg       <= (others => '0');
--    c7_ddr4_cke      <= (others => '0');
--    c7_ddr4_odt      <= (others => '0');
--    c7_ddr4_cs_n     <= (others => '0');
--    c7_ddr4_ck_t     <= (others => '0');
--    c7_ddr4_ck_c     <= (others => '0');
--    c7_ddr4_reset_n  <= '1';
--    c7_ddr4_dm_dbi_n <= (others => 'Z');
--    c7_ddr4_dq       <= (others => 'Z');
--    c7_ddr4_dqs_c    <= (others => 'Z');
--    c7_ddr4_dqs_t    <= (others => 'Z');
--    c7_calib_done <= '1';
--    clkm_7          <= not clkm_7        after 7.2 ns;

  -- pragma translate_on
  end generate gen_mig_model;

-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------

  reset_o2 <= d2d_rstn_c1;
  eth0 : if SIMULATION = false and CFG_GRETH = 1 generate  -- Gaisler ethernet MAC
    e1 : grethm
      generic map(
        hindex      => CFG_AHB_JTAG,
        ehindex     => CFG_AHB_JTAG + 1,
        pindex      => 6,
        paddr       => 16#800#,
        pmask       => 16#f00#,
        pirq        => 12,
        little_end  => GLOB_CPU_RISCV * CFG_L2_DISABLE,
        memtech     => CFG_FABTECH,
        enable_mdio => 1,
        fifosize    => CFG_ETH_FIFO,
        nsync       => 1, -- KL changed from 1 to 2 for stability
        edcl        => CFG_DSU_ETH,
        edclbufsz   => CFG_ETH_BUF,
        macaddrh    => CFG_ETH_ENM,
        macaddrl    => CFG_ETH_ENL,
        phyrstadr   => 1, -- KL changed from 1 to 0
        ipaddrh     => CFG_ETH_IPM,
        ipaddrl     => CFG_ETH_IPL,
        giga        => CFG_GRETH1G,
        edclsepahbg => 1)
      port map(
        rst    => rstn,
        clk    => chip_refclk,
        mdcscaler => CPU_FREQ/1000,
        ahbmi  => eth0_ahbmi,
        ahbmo  => eth0_ahbmo,
        eahbmo => edcl_ahbmo,
        apbi   => eth0_apbi,
        apbo   => eth0_apbo,
        ethi   => ethi,
        etho   => etho);
  end generate;

  ethi.edclsepahb <= '1';

  -- eth pads
  eth0_inpads : if CFG_GRETH = 1 generate
    etxc_pad : clkpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v, arch => 2)
      port map (etx_clk, ethi.tx_clk);
    erxc_pad : clkpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v, arch => 2)
      port map (erx_clk, ethi.rx_clk);
    erxd_pad : inpadv generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v, width => 4)
      port map (erxd, ethi.rxd(3 downto 0));
    erxdv_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
      port map (erx_dv, ethi.rx_dv);
    erxer_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
      port map (erx_er, ethi.rx_er);
    erxco_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
      port map (erx_col, ethi.rx_col);
    erxcr_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
      port map (erx_crs, ethi.rx_crs);
  end generate eth0_inpads;

  emdio_pad : iopad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (emdio, etho.mdio_o, etho.mdio_oe, ethi.mdio_i);
  etxd_pad : outpadv generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v, width => 4)
    port map (etxd, etho.txd(3 downto 0));
  etxen_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (etx_en, etho.tx_en);
  etxer_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (etx_er, etho.tx_er);
  emdc_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (emdc, etho.mdc);

  no_eth0 : if (SIMULATION = true or CFG_GRETH = 0) generate
    eth0_apbo    <= apb_none;
   eth0_ahbmo   <= ahbm_none;
   edcl_ahbmo   <= ahbm_none;
    etho.mdio_o  <= '0';
    etho.mdio_oe <= '0';
    etho.txd     <= (others => '0');
    etho.tx_en   <= '0';
    etho.tx_er   <= '0';
    etho.mdc     <= '0';
  end generate no_eth0;

  sgmii0_apbo <= apb_none;

-----------------------------------------------------------------------------
-- DVI
-----------------------------------------------------------------------------

  svga : if CFG_SVGA_ENABLE /= 0 generate
    svga0 : svgactrl generic map(
      memtech  => CFG_FABTECH,
      pindex   => 5,
      paddr    => 6,
      hindex   => 0,
      clk0     => 25000,
      clk1     => 25000,
      clk2     => 25000,
      clk3     => 25000,
      burstlen => 6,
      ahbaccsz => CFG_AHBDW)
      port map(
        rst     => rstn,
        clk     => chip_refclk,
        vgaclk  => clkvga,
        apbi    => dvi_apbi,
        apbo    => dvi_apbo,
        vgao    => vgao,
        ahbi    => dvi_ahbmi,
        ahbo    => dvi_ahbmo,
        clk_sel => open);

    dvi0 : svga2tfp410
      generic map (
        tech => CFG_FABTECH)
      port map (
        clk         => chip_refclk,
        rstn        => rstn,
        vgao        => vgao,
        vgaclk_fb   => clkvga,
        vgaclk      => clkvga,
        idck_p      => clkvga_p,
        idck_n      => clkvga_n,
        data        => dvi_data,
        hsync       => dvi_hsync,
        vsync       => dvi_vsync,
        de          => dvi_de,
        dken        => dvi_dken,
        ctl1_a1_dk1 => dvi_ctl1_a1_dk1,
        ctl2_a2_dk2 => dvi_ctl2_a2_dk2,
        a3_dk3      => dvi_a3_dk3,
        isel        => dvi_isel,
        bsel        => dvi_bsel,
        dsel        => dvi_dsel,
        edge        => dvi_edge,
        npd         => dvi_npd);

  end generate;

  novga : if (CFG_SVGA_ENABLE = 0) generate
    dvi_apbo        <= apb_none;
    dvi_ahbmo       <= ahbm_none;
    dvi_data        <= (others => '0');
    clkvga_p        <= '0';
    clkvga_n        <= '0';
    dvi_hsync       <= '0';
    dvi_vsync       <= '0';
    dvi_de          <= '0';
    dvi_dken        <= '0';
    dvi_ctl1_a1_dk1 <= '0';
    dvi_ctl2_a2_dk2 <= '0';
    dvi_a3_dk3      <= '0';
    dvi_isel        <= '0';
    dvi_bsel        <= '0';
    dvi_dsel        <= '0';
    dvi_edge        <= '0';
    dvi_npd         <= '0';
  end generate;

--  tft_nhpd_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
--    port map (tft_nhpd, dvi_nhpd);
--
--  tft_clkp_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
--    port map (tft_clk_p, clkvga_p);
--  tft_clkn_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
--    port map (tft_clk_n, clkvga_n);
--
--  tft_data_pad : outpadv generic map (width => 24, tech => CFG_FABTECH, level => cmos, voltage => x18v)
--    port map (tft_data, dvi_data);
--  tft_hsync_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
--    port map (tft_hsync, dvi_hsync);
--  tft_vsync_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
--    port map (tft_vsync, dvi_vsync);
--  tft_de_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
--    port map (tft_de, dvi_de);
--
--  tft_dken_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
--    port map (tft_dken, dvi_dken);
--  tft_ctl1_a1_dk1_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
--    port map (tft_ctl1_a1_dk1, dvi_ctl1_a1_dk1);
--  tft_ctl2_a2_dk2_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
--    port map (tft_ctl2_a2_dk2, dvi_ctl2_a2_dk2);
--  tft_a3_dk3_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
--    port map (tft_a3_dk3, dvi_a3_dk3);
--
--  tft_isel_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
--    port map (tft_isel, dvi_isel);
--  tft_bsel_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
--    port map (tft_bsel, dvi_bsel);
--  tft_dsel_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
--    port map (tft_dsel, dvi_dsel);
--  tft_edge_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
--    port map (tft_edge, dvi_edge);
--  tft_npd_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
--    port map (tft_npd, dvi_npd);

-----------------------------------------------------------------------------
-- CHIP
-----------------------------------------------------------------------------
  chip_rstn      <= rstn;
  chip_rst       <= not rstn;
  sys_clk(0)     <= clkm;
  sys_clk(1)     <= clkm_1;
  sys_clk(2)     <= clkm_2;
  sys_clk(3)     <= clkm_3;
  sys_clk(4)     <= clkm_4;
  sys_clk(5)     <= clkm_5;
  sys_clk(6)     <= clkm_6;
  --  sys_clk(7)     <= clkm_7;

  set_upper_ahbsi : for i in CFG_NMEM_TILE_CHIPLET(BOARD_NUM) to MAX_NMEM_TILES-1 generate
      ddr_ahbsi(i) <= ahbs_in_none;
  end generate set_upper_ahbsi;

  -- D2D cable mapping:
  -- c1 cable maps to N on boards 2/3 and S on boards 0/1.
  -- c0 cable maps to W on boards 1/3 and E on boards 0/2.
  d2d_cable_direction_map_i : entity work.d2d_cable_direction_map
    generic map (
      C0_IS_WEST    => C0_IS_WEST,
      C1_IS_NORTH   => C1_IS_NORTH,
      ISOLATE_LINKS => ISOLATE_BOARD0_D2D
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
      uart_txd    => uart_txd_int,
      uart_ctsn   => uart_ctsn_int,
      uart_rtsn   => uart_rtsn_int,
      cpuerr      => cpuerr,
      ddr_ahbsi   => ddr_ahbsi(0 to MEM_ID_RANGE_MSB),
      ddr_ahbso   => ddr_ahbso(0 to MEM_ID_RANGE_MSB),
      eth0_apbi   => eth0_apbi,
      eth0_apbo   => eth0_apbo,
      edcl_ahbmo  => edcl_ahbmo,
      sgmii0_apbi => sgmii0_apbi,
      sgmii0_apbo => sgmii0_apbo,
      eth0_ahbmi  => eth0_ahbmi,
      eth0_ahbmo  => eth0_ahbmo,
      dvi_apbi    => dvi_apbi,
      dvi_apbo    => dvi_apbo,
      dvi_ahbmi   => dvi_ahbmi,
      dvi_ahbmo   => dvi_ahbmo,
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
