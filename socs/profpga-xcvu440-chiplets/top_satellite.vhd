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
    -- D2D Reference Clock
    d2d_clk_p         : in    std_ulogic;
    d2d_clk_n         : in    std_ulogic;
    -- IO Cables
    c0_cable_clk_p      : out     std_logic; -- TX Clock
    c0_cable_clk_n      : out     std_logic;
    c0_cable_clk_p_rcv  : in      std_logic; -- RX Clock
    c0_cable_clk_n_rcv  : in      std_logic;
    c0_cable_io_data    : inout   std_logic_vector(135 downto 0);

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

--     c1_sys_clk_p      : in    std_logic;   -- 125 MHz clock
--     c1_sys_clk_n      : in    std_logic;   -- 125 MHz clock
--     c1_ddr4_act_n     : out   std_logic;
--     c1_ddr4_adr       : out   std_logic_vector(16 downto 0);
--     c1_ddr4_ba        : out   std_logic_vector(1 downto 0);
--     c1_ddr4_bg        : out   std_logic_vector(1 downto 0);
--     c1_ddr4_cke       : out   std_logic_vector(1 downto 0);
--     c1_ddr4_odt       : out   std_logic_vector(1 downto 0);
--     c1_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
--     c1_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
--     c1_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
--     c1_ddr4_reset_n   : out   std_logic;
--     c1_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
--     c1_ddr4_dq        : inout std_logic_vector(71 downto 0);
--     c1_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
--     c1_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
--     c1_calib_complete : out   std_logic;
--     c1_diagnostic_led : out   std_ulogic;

--     c2_sys_clk_p      : in    std_logic;   -- 125 MHz clock
--     c2_sys_clk_n      : in    std_logic;   -- 125 MHz clock
--     c2_ddr4_act_n     : out   std_logic;
--     c2_ddr4_adr       : out   std_logic_vector(16 downto 0);
--     c2_ddr4_ba        : out   std_logic_vector(1 downto 0);
--     c2_ddr4_bg        : out   std_logic_vector(1 downto 0);
--     c2_ddr4_cke       : out   std_logic_vector(1 downto 0);
--     c2_ddr4_odt       : out   std_logic_vector(1 downto 0);
--     c2_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
--     c2_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
--     c2_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
--     c2_ddr4_reset_n   : out   std_logic;
--     c2_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
--     c2_ddr4_dq        : inout std_logic_vector(71 downto 0);
--     c2_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
--     c2_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
--     c2_calib_complete : out   std_logic;
--     c2_diagnostic_led : out   std_ulogic;

--     c3_sys_clk_p      : in    std_logic;   -- 125 MHz clock
--     c3_sys_clk_n      : in    std_logic;   -- 125 MHz clock
--     c3_ddr4_act_n     : out   std_logic;
--     c3_ddr4_adr       : out   std_logic_vector(16 downto 0);
--     c3_ddr4_ba        : out   std_logic_vector(1 downto 0);
--     c3_ddr4_bg        : out   std_logic_vector(1 downto 0);
--     c3_ddr4_cke       : out   std_logic_vector(1 downto 0);
--     c3_ddr4_odt       : out   std_logic_vector(1 downto 0);
--     c3_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
--     c3_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
--     c3_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
--     c3_ddr4_reset_n   : out   std_logic;
--     c3_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
--     c3_ddr4_dq        : inout std_logic_vector(71 downto 0);
--     c3_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
--     c3_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
--     c3_calib_complete : out   std_logic;
--     c3_diagnostic_led : out   std_ulogic;

--     c4_sys_clk_p      : in    std_logic;   -- 125 MHz clock
--     c4_sys_clk_n      : in    std_logic;   -- 125 MHz clock
--     c4_ddr4_act_n     : out   std_logic;
--     c4_ddr4_adr       : out   std_logic_vector(16 downto 0);
--     c4_ddr4_ba        : out   std_logic_vector(1 downto 0);
--     c4_ddr4_bg        : out   std_logic_vector(1 downto 0);
--     c4_ddr4_cke       : out   std_logic_vector(1 downto 0);
--     c4_ddr4_odt       : out   std_logic_vector(1 downto 0);
--     c4_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
--     c4_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
--     c4_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
--     c4_ddr4_reset_n   : out   std_logic;
--     c4_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
--     c4_ddr4_dq        : inout std_logic_vector(71 downto 0);
--     c4_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
--     c4_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
--     c4_calib_complete : out   std_logic;
--     c4_diagnostic_led : out   std_ulogic;

--     c5_sys_clk_p      : in    std_logic;   -- 125 MHz clock
--     c5_sys_clk_n      : in    std_logic;   -- 125 MHz clock
--     c5_ddr4_act_n     : out   std_logic;
--     c5_ddr4_adr       : out   std_logic_vector(16 downto 0);
--     c5_ddr4_ba        : out   std_logic_vector(1 downto 0);
--     c5_ddr4_bg        : out   std_logic_vector(1 downto 0);
--     c5_ddr4_cke       : out   std_logic_vector(1 downto 0);
--     c5_ddr4_odt       : out   std_logic_vector(1 downto 0);
--     c5_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
--     c5_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
--     c5_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
--     c5_ddr4_reset_n   : out   std_logic;
--     c5_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
--     c5_ddr4_dq        : inout std_logic_vector(71 downto 0);
--     c5_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
--     c5_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
--     c5_calib_complete : out   std_logic;
--     c5_diagnostic_led : out   std_ulogic;

--     c6_sys_clk_p      : in    std_logic;   -- 125 MHz clock
--     c6_sys_clk_n      : in    std_logic;   -- 125 MHz clock
--     c6_ddr4_act_n     : out   std_logic;
--     c6_ddr4_adr       : out   std_logic_vector(16 downto 0);
--     c6_ddr4_ba        : out   std_logic_vector(1 downto 0);
--     c6_ddr4_bg        : out   std_logic_vector(1 downto 0);
--     c6_ddr4_cke       : out   std_logic_vector(1 downto 0);
--     c6_ddr4_odt       : out   std_logic_vector(1 downto 0);
--     c6_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
--     c6_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
--     c6_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
--     c6_ddr4_reset_n   : out   std_logic;
--     c6_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
--     c6_ddr4_dq        : inout std_logic_vector(71 downto 0);
--     c6_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
--     c6_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
--     c6_calib_complete : out   std_logic;
--     c6_diagnostic_led : out   std_ulogic;

-- --    c7_sys_clk_p      : in    std_logic;   -- 125 MHz clock
-- --    c7_sys_clk_n      : in    std_logic;   -- 125 MHz clock
-- --    c7_ddr4_act_n     : out   std_logic;
-- --    c7_ddr4_adr       : out   std_logic_vector(16 downto 0);
-- --    c7_ddr4_ba        : out   std_logic_vector(1 downto 0);
-- --    c7_ddr4_bg        : out   std_logic_vector(1 downto 0);
-- --    c7_ddr4_cke       : out   std_logic_vector(1 downto 0);
-- --    c7_ddr4_odt       : out   std_logic_vector(1 downto 0);
-- --    c7_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
-- --    c7_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
-- --    c7_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
-- --    c7_ddr4_reset_n   : out   std_logic;
-- --    c7_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
-- --    c7_ddr4_dq        : inout std_logic_vector(71 downto 0);
-- --    c7_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
-- --    c7_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
-- --    c7_calib_complete : out   std_logic;
-- --    c7_diagnostic_led : out   std_ulogic;
    -- UART
    UART_RXD          : in    std_ulogic;
    UART_TXD          : out   std_ulogic;
    UART_CTS_B        : in    std_ulogic;
    UART_RTS_B        : out   std_ulogic;
--     -- Ethernet signals
--     reset_o2          : out   std_ulogic;
--     etx_clk           : in    std_ulogic;
--     erx_clk           : in    std_ulogic;
--     erxd              : in    std_logic_vector(3 downto 0);
--     erx_dv            : in    std_ulogic;
--     erx_er            : in    std_ulogic;
--     erx_col           : in    std_ulogic;
--     erx_crs           : in    std_ulogic;
--     etxd              : out   std_logic_vector(3 downto 0);
--     etx_en            : out   std_ulogic;
--     etx_er            : out   std_ulogic;
--     emdc              : out   std_ulogic;
--     emdio             : inout std_logic;
--     -- DVI
--     --tft_nhpd          : in    std_ulogic;  -- Hot plug
--     --tft_clk_p         : out   std_ulogic;
--     --tft_clk_n         : out   std_ulogic;
--     --tft_data          : out   std_logic_vector(23 downto 0);
--     --tft_hsync         : out   std_ulogic;
--     --tft_vsync         : out   std_ulogic;
--     --tft_de            : out   std_ulogic;
--     --tft_dken          : out   std_ulogic;
--     --tft_ctl1_a1_dk1   : out   std_ulogic;
--     --tft_ctl2_a2_dk2   : out   std_ulogic;
--     --tft_a3_dk3        : out   std_ulogic;
--     --tft_isel          : out   std_ulogic;
--     --tft_bsel          : out   std_logic;
--     --tft_dsel          : out   std_logic;
--     --tft_edge          : out   std_ulogic;
--     --tft_npd           : out   std_ulogic;

    LED_RED    : out std_ulogic;
    LED_GREEN  : out std_ulogic;
    LED_BLUE   : out std_ulogic;
    LED_YELLOW : out std_ulogic
    );
end;


architecture rtl of top_satellite is
  constant D2D_RX_MMCM_PHASE_DEG_C0 : real := -22.500; -- RX capture phase for cable 0 (degrees) w.r.t. D2D RX data
  constant D2D_RX_MMCM_CLKIN_PERIOD_NS : real := 12.800; -- set to external D2D clock period
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

  component d2d_tx_top is
    generic (
      TXCHANNELS    : integer;
      TILES         : integer;
      flow_control  : integer;  --0 = AN; 1 = CB
      chwidth       : integer;
      cohwidth      : integer;
      miscwidth     : integer;
      dmawidth      : integer
    );
    port (
      clk                 : in  std_ulogic;
      rst                 : in  std_ulogic;
      d2d_clk_in          : in  std_ulogic;

      -- D2D Tx --> D2D Rx
      d2d_snd_data_out    : out coh_noc_flit_vector(TXCHANNELS-1 downto 0);
      d2d_valid_out       : out std_logic_vector(TXCHANNELS-1 downto 0);
      d2d_link_ready      : out std_logic;

      -- D2D Rx --> D2D Tx
      d2d_credit_in       : in  std_logic_vector(TXCHANNELS-1 downto 0);

      -- NoC --> D2D
      noc1_data_in        : in  coh_noc_flit_vector(TILES-1 downto 0);
      noc2_data_in        : in  coh_noc_flit_vector(TILES-1 downto 0);
      noc3_data_in        : in  coh_noc_flit_vector(TILES-1 downto 0);
      noc4_data_in        : in  dma_noc_flit_vector(TILES-1 downto 0);
      noc5_data_in        : in  misc_noc_flit_vector(TILES-1 downto 0);
      noc6_data_in        : in  dma_noc_flit_vector(TILES-1 downto 0);
      bypass_data_in      : in  coh_noc_flit_type;

      noc1_data_void_in   : in  std_logic_vector(TILES-1 downto 0);
      noc2_data_void_in   : in  std_logic_vector(TILES-1 downto 0);
      noc3_data_void_in   : in  std_logic_vector(TILES-1 downto 0);
      noc4_data_void_in   : in  std_logic_vector(TILES-1 downto 0);
      noc5_data_void_in   : in  std_logic_vector(TILES-1 downto 0);
      noc6_data_void_in   : in  std_logic_vector(TILES-1 downto 0);
      bypass_data_void_in : in  std_logic;

      -- D2D --> NoC
      noc1_stop_out       : out std_logic_vector(TILES-1 downto 0);
      noc2_stop_out       : out std_logic_vector(TILES-1 downto 0);
      noc3_stop_out       : out std_logic_vector(TILES-1 downto 0);
      noc4_stop_out       : out std_logic_vector(TILES-1 downto 0);
      noc5_stop_out       : out std_logic_vector(TILES-1 downto 0);
      noc6_stop_out       : out std_logic_vector(TILES-1 downto 0);
      bypass_stop_out     : out std_logic
    );
  end component d2d_tx_top;

  component d2d_rx_top is
    generic (
      d2d_position      : std_logic_vector(1 downto 0); -- 0 N; 1 S; 2 E; 3 W
      local_chip_y      : chip_yx;
      local_chip_x      : chip_yx;
      max_dim           : local_yx;
      RXCHANNELS        : integer;
      TILES             : integer;
      flow_control      : integer;
      chwidth           : integer;
      cohwidth          : integer;
      miscwidth         : integer;
      dmawidth          : integer
    );
    port (
      clk               : in  std_ulogic;
      rst               : in  std_ulogic;

      -- D2D Tx --> D2D Rx
      d2d_clk_in        : in  std_ulogic;
      d2d_rcv_data_in   : in  coh_noc_flit_vector(RXCHANNELS-1 downto 0);
      d2d_valid_in      : in  std_logic_vector(RXCHANNELS-1 downto 0);
      d2d_link_ready    : out std_logic;

      -- D2D Rx --> D2D Tx
      d2d_credit_out    : out std_logic_vector(RXCHANNELS-1 downto 0);

      -- D2D --> NoC
      noc1_data_out     : out coh_noc_flit_vector(TILES-1 downto 0);
      noc2_data_out     : out coh_noc_flit_vector(TILES-1 downto 0);
      noc3_data_out     : out coh_noc_flit_vector(TILES-1 downto 0);
      noc4_data_out     : out dma_noc_flit_vector(TILES-1 downto 0);
      noc5_data_out     : out misc_noc_flit_vector(TILES-1 downto 0);
      noc6_data_out     : out dma_noc_flit_vector(TILES-1 downto 0);
      bypass_data_out   : out coh_noc_flit_type;

      noc1_data_void_out  : out std_logic_vector(TILES-1 downto 0);
      noc2_data_void_out  : out std_logic_vector(TILES-1 downto 0);
      noc3_data_void_out  : out std_logic_vector(TILES-1 downto 0);
      noc4_data_void_out  : out std_logic_vector(TILES-1 downto 0);
      noc5_data_void_out  : out std_logic_vector(TILES-1 downto 0);
      noc6_data_void_out  : out std_logic_vector(TILES-1 downto 0);
      bypass_data_void_out : out std_logic;

      -- NoC --> D2D
      noc1_stop_in      : in std_logic_vector(TILES-1 downto 0);
      noc2_stop_in      : in std_logic_vector(TILES-1 downto 0);
      noc3_stop_in      : in std_logic_vector(TILES-1 downto 0);
      noc4_stop_in      : in std_logic_vector(TILES-1 downto 0);
      noc5_stop_in      : in std_logic_vector(TILES-1 downto 0);
      noc6_stop_in      : in std_logic_vector(TILES-1 downto 0);
      bypass_stop_in    : in std_logic
    );
  end component d2d_rx_top;

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

-- clock and reset
  signal clkm                                           : std_ulogic := '0';
  signal clkm_sync_rst                                  : std_ulogic;
  signal d2d_rstn, rstn, rstraw                         : std_ulogic;
  signal d2d_rst  : std_ulogic;
  signal lock, rst                                      : std_ulogic;
  -- signal satellite_rst                                  : std_ulogic := '1';
  -- signal satellite_rst_count                           : std_logic_vector(7 downto 0) := (others => '0');
  signal migrstn                                        : std_logic;
  signal cgi                                            : clkgen_in_type;
  signal cgo                                            : clkgen_out_type;
  constant led_pending_max                             : unsigned(11 downto 0) := (others => '1');

---mig signals
  signal c0_calib_done        : std_ulogic;
  signal c0_diagnostic_count  : std_logic_vector(26 downto 0);
  signal c0_diagnostic_toggle : std_ulogic;
  signal led_green_count      : unsigned(26 downto 0) := (others => '0');
  signal led_green_pending    : unsigned(11 downto 0) := (others => '0');
  signal led_green_dbg        : std_ulogic := '0';
  signal led_green_phase_prev : std_ulogic := '0';
  signal led_yellow_count     : unsigned(26 downto 0) := (others => '0');
  signal led_yellow_dbg       : std_ulogic := '0';
  signal led_red_pending      : unsigned(11 downto 0) := (others => '0');
  signal led_red_dbg          : std_ulogic := '0';
  signal led_red_phase_prev   : std_ulogic := '0';
  -- signal c1_calib_done        : std_ulogic;
  -- signal c1_diagnostic_count  : std_logic_vector(26 downto 0);
  -- signal c1_diagnostic_toggle : std_ulogic;
  -- signal c2_calib_done        : std_ulogic;
  -- signal c2_diagnostic_count  : std_logic_vector(26 downto 0);
  -- signal c2_diagnostic_toggle : std_ulogic;
  -- signal c3_calib_done        : std_ulogic;
  -- signal c3_diagnostic_count  : std_logic_vector(26 downto 0);
  -- signal c3_diagnostic_toggle : std_ulogic;

-- Ethernet signals
  signal ethi : eth_in_type;
  signal etho : eth_out_type;

-- Tiles

-- UART
  signal uart_rxd_int  : std_logic;       -- UART1_RX (u1i.rxd)
  -- signal uart_txd_int  : std_logic;       -- UART1_TX (u1o.txd)
  signal uart_ctsn_int : std_logic;       -- UART1_RTSN (u1i.ctsn)
  signal uart_rtsn_int : std_logic;       -- UART1_RTSN (u1o.rtsn)

constant MAX_NMEM_TILES : integer := 4;
-- Memory controller DDR4
  signal ddr_ahbsi : ahb_slv_in_vector_type(0 to MAX_NMEM_TILES - 1);
  signal ddr_ahbso : ahb_slv_out_vector_type(0 to MAX_NMEM_TILES - 1);

-- Ethernet
constant CPU_FREQ : integer := 78125;  -- cpu frequency in KHz

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
        return 0;
      elsif LOC = 2 then
        return 0;
      else  -- 3 = E
        return WIRES_PER_CONNECTION;
      end if;
    elsif BOARD_NUM = 1 then
      if LOC = 0 then
        return 0;
      elsif LOC = 1 then  -- 1 = S
        return 0;
      elsif LOC = 2 then
        return WIRES_PER_CONNECTION;
      else  -- 3 = E
        return 0;
      end if;
    elsif BOARD_NUM = 2 then
      if LOC = 0 then
        return 0;
      elsif LOC = 1 then  -- 1 = S
        return 0;
      elsif LOC = 2 then
        return 0;
      else  -- 3 = E
        return WIRES_PER_CONNECTION;
      end if;
    else
      if LOC = 0 then
        return 0;
      elsif LOC = 1 then  -- 1 = S
        return 0;
      elsif LOC = 2 then
        return WIRES_PER_CONNECTION;
      else  -- 3 = E
        return 0;
      end if;
    end if;
  end set_d2d;

  constant D2D_CHANNELS_N : integer := set_d2d(BOARD_NUM, 0);
  constant D2D_CHANNELS_S : integer := set_d2d(BOARD_NUM, 1);
  constant D2D_CHANNELS_W : integer := set_d2d(BOARD_NUM, 2);
  constant D2D_CHANNELS_E : integer := set_d2d(BOARD_NUM, 3);
  constant C0_IS_WEST     : boolean := (BOARD_NUM = 1) or (BOARD_NUM = 3);
  constant ROW : integer := BOARD_NUM / CFG_CHIPLET_COLS;
  constant COL : integer := BOARD_NUM mod CFG_CHIPLET_COLS;

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
  signal chip_rst       : std_ulogic;
  signal chip_rst_inv   : std_ulogic;
  signal d2d_ready      : std_ulogic;
  signal d2d_ready_sync : std_ulogic := '0';
  signal d2d_ready_sync_1 : std_ulogic := '0';
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
  -- signal c1_d2d_data_tx    : std_logic_vector(67 downto 0);
  signal c0_d2d_data_tx_io  : std_logic_vector(67 downto 0);
  -- signal c1_d2d_data_tx_io  : std_logic_vector(67 downto 0);
  signal c0_d2d_data_rx_io  : std_logic_vector(67 downto 0);
  -- signal c1_d2d_data_rx_io  : std_logic_vector(67 downto 0);
  signal c0_d2d_data_rx_iob : std_logic_vector(67 downto 0) := (others => '0');
  -- signal c1_d2d_data_rx_iob : std_logic_vector(67 downto 0) := (others => '0');

  attribute IOB : string;
  attribute IOB of c0_d2d_data_tx_io : signal is "TRUE";
  -- attribute IOB of c1_d2d_data_tx_io : signal is "TRUE";
  attribute IOB of c0_d2d_data_rx_iob : signal is "TRUE";
  -- attribute IOB of c1_d2d_data_rx_iob : signal is "TRUE";

  -- signal c1_tx_clk_int, c1_rx_clk_int : std_logic;
  -- signal c0_tx_clk_int, c0_rx_clk_int : std_logic;
  signal cable_clk_fwd_int_0  : std_ulogic;
  -- signal cable_clk_fwd_int_1  : std_ulogic;
  
  signal cable_clk_rcv_raw_0    : std_ulogic;
  signal cable_clk_rcv_global_0 : std_ulogic;
  signal d2d_rx_mmcm_clkfb_out0, d2d_rx_mmcm_clkfb_in0, d2d_rx_mmcm_clk_out0, d2d_rx_mmcm_locked0 : std_ulogic;
  
  -- signal cable_clk_rcv_raw_1    : std_ulogic;
  -- signal cable_clk_rcv_global_1 : std_ulogic;
  -- signal d2d_rx_mmcm_clkfb_out1, d2d_rx_mmcm_clkfb_in1, d2d_rx_mmcm_clk_out1, d2d_rx_mmcm_locked1 : std_ulogic;

  signal d2d_clk_int    : std_ulogic;

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


  -- Lossless credit CDC using Gray event counters.
  constant CREDIT_CDC_CNT_W : integer := 5;
  subtype credit_cnt_t is unsigned(CREDIT_CDC_CNT_W-1 downto 0);
  subtype credit_pend_t is unsigned(CREDIT_CDC_CNT_W downto 0);

  signal c0_credit_in_sync_pulse : std_logic := '0';
  signal chiplet_credit_out_n_sync_pulse, chiplet_credit_out_s_sync_pulse : std_logic_vector(WIRES_PER_CONNECTION-1 downto 0) := (others => '0');
  signal chiplet_credit_out_w_sync_pulse, chiplet_credit_out_e_sync_pulse : std_logic_vector(WIRES_PER_CONNECTION-1 downto 0) := (others => '0');

  signal c0_credit_in_evt_bin_src : credit_cnt_t := (others => '0');
  signal c0_credit_in_evt_gray_src : credit_cnt_t;
  signal c0_credit_in_evt_gray_ff1, c0_credit_in_evt_gray_ff2 : credit_cnt_t := (others => '0');
  signal c0_credit_in_evt_bin_sync : credit_cnt_t;
  signal c0_credit_in_evt_bin_seen : credit_cnt_t := (others => '0');
  signal c0_credit_in_pending : credit_pend_t := (others => '0');

  signal chiplet_credit_out_n_inc, chiplet_credit_out_s_inc : credit_cnt_t;
  signal chiplet_credit_out_w_inc, chiplet_credit_out_e_inc : credit_cnt_t;
  signal chiplet_credit_out_n_pulse_scalar, chiplet_credit_out_s_pulse_scalar : std_logic := '0';
  signal chiplet_credit_out_w_pulse_scalar, chiplet_credit_out_e_pulse_scalar : std_logic := '0';

  signal chiplet_credit_out_n_evt_bin_src, chiplet_credit_out_s_evt_bin_src : credit_cnt_t := (others => '0');
  signal chiplet_credit_out_w_evt_bin_src, chiplet_credit_out_e_evt_bin_src : credit_cnt_t := (others => '0');
  signal chiplet_credit_out_n_evt_gray_src, chiplet_credit_out_s_evt_gray_src : credit_cnt_t;
  signal chiplet_credit_out_w_evt_gray_src, chiplet_credit_out_e_evt_gray_src : credit_cnt_t;
  signal chiplet_credit_out_n_evt_gray_ff1, chiplet_credit_out_s_evt_gray_ff1 : credit_cnt_t := (others => '0');
  signal chiplet_credit_out_w_evt_gray_ff1, chiplet_credit_out_e_evt_gray_ff1 : credit_cnt_t := (others => '0');
  signal chiplet_credit_out_n_evt_gray_ff2, chiplet_credit_out_s_evt_gray_ff2 : credit_cnt_t := (others => '0');
  signal chiplet_credit_out_w_evt_gray_ff2, chiplet_credit_out_e_evt_gray_ff2 : credit_cnt_t := (others => '0');
  signal chiplet_credit_out_n_evt_bin_sync, chiplet_credit_out_s_evt_bin_sync : credit_cnt_t;
  signal chiplet_credit_out_w_evt_bin_sync, chiplet_credit_out_e_evt_bin_sync : credit_cnt_t;
  signal chiplet_credit_out_n_evt_bin_seen, chiplet_credit_out_s_evt_bin_seen : credit_cnt_t := (others => '0');
  signal chiplet_credit_out_w_evt_bin_seen, chiplet_credit_out_e_evt_bin_seen : credit_cnt_t := (others => '0');
  signal chiplet_credit_out_n_pending, chiplet_credit_out_s_pending : credit_pend_t := (others => '0');
  signal chiplet_credit_out_w_pending, chiplet_credit_out_e_pending : credit_pend_t := (others => '0');

  function slv_popcount(v : std_logic_vector) return credit_cnt_t is
    variable c : credit_cnt_t := (others => '0');
  begin
    for i in v'range loop
      if v(i) = '1' then
        c := c + 1;
      end if;
    end loop;
    return c;
  end function slv_popcount;

  function bin2gray(bin : credit_cnt_t) return credit_cnt_t is
    variable g : credit_cnt_t;
  begin
    g(g'high) := bin(bin'high);
    for i in g'high-1 downto g'low loop
      g(i) := bin(i+1) xor bin(i);
    end loop;
    return g;
  end function bin2gray;

  function gray2bin(gray : credit_cnt_t) return credit_cnt_t is
    variable b : credit_cnt_t;
  begin
    b(b'high) := gray(gray'high);
    for i in b'high-1 downto b'low loop
      b(i) := b(i+1) xor gray(i);
    end loop;
    return b;
  end function gray2bin;

  procedure drain_credit_evt(
    signal evt_bin_seen : inout credit_cnt_t;
    signal pending      : inout credit_pend_t;
    signal pulse        : out std_logic;
    constant evt_bin_sync : in credit_cnt_t
  ) is
    variable evt_delta : credit_pend_t;
  begin
    evt_delta := '0' & (evt_bin_sync - evt_bin_seen);
    evt_bin_seen <= evt_bin_sync;

    if (pending /= 0) or (evt_delta /= 0) then
      pulse <= '1';
      pending <= pending + evt_delta - 1;
    else
      pulse <= '0';
      pending <= (others => '0');
    end if;
  end procedure drain_credit_evt;

begin

  -- Capture each cable bit into an IOB-local register first, then hand a
  -- vectorized second stage to the core-facing D2D logic.
  c0_rx_iob_regs : for i in 0 to 67 generate
  begin
    c0_rx_iob_reg : process (cable_clk_rcv_global_0)
    begin
      if rising_edge(cable_clk_rcv_global_0) then
        if d2d_rstn = '0' or d2d_rx_mmcm_locked0 = '0' then
          c0_d2d_data_rx_iob(i) <= '0';
        else
          c0_d2d_data_rx_iob(i) <= c0_d2d_data_rx_io(i);
        end if;
      end if;
    end process c0_rx_iob_reg;
  end generate c0_rx_iob_regs;

  c0_credit_evt_src : process (cable_clk_rcv_global_0)
  begin
    if rising_edge(cable_clk_rcv_global_0) then
      if d2d_rstn = '0' or d2d_rx_mmcm_locked0 = '0' then
        c0_credit_in_evt_bin_src <= (others => '0');
      elsif c0_d2d_data_rx_iob(66) = '1' then
        c0_credit_in_evt_bin_src <= c0_credit_in_evt_bin_src + 1;
      end if;
    end if;
  end process c0_credit_evt_src;

  -- Previous wide queued RX LED debug kept for reference.
  -- rx_led_debug : process (cable_clk_rcv_global_0)
  --   variable next_red_pending : unsigned(led_red_pending'range);
  -- begin
  --   if rising_edge(cable_clk_rcv_global_0) then
  --     if d2d_rstn = '0' or d2d_rx_mmcm_locked0 = '0' then
  --       led_yellow_count    <= (others => '0');
  --       led_red_pending     <= (others => '0');
  --       led_red_phase_prev  <= '0';
  --     else
  --       led_yellow_count <= led_yellow_count + 1;
  --
  --       next_red_pending := led_red_pending;
  --       if c0_d2d_data_rx_iob(65) = '1' then
  --         next_red_pending := next_red_pending + 1;
  --       end if;
  --
  --       if led_red_phase_prev = '1' and led_yellow_count(26) = '0' and next_red_pending /= 0 then
  --         next_red_pending := next_red_pending - 1;
  --       end if;
  --
  --       led_red_pending    <= next_red_pending;
  --       led_red_phase_prev <= led_yellow_count(26);
  --     end if;
  --   end if;
  -- end process rx_led_debug;

  -- Front-panel RX activity indicators in the recovered cable clock domain.
  rx_led_debug_phase : process (cable_clk_rcv_global_0)
  begin
    if rising_edge(cable_clk_rcv_global_0) then
      if d2d_rstn = '0' or d2d_rx_mmcm_locked0 = '0' then
        led_yellow_count   <= (others => '0');
        led_red_phase_prev <= '0';
      else
        led_red_phase_prev <= led_yellow_count(26);
        led_yellow_count   <= led_yellow_count + 1;
      end if;
    end if;
  end process rx_led_debug_phase;

  rx_led_debug_pending : process (cable_clk_rcv_global_0)
    variable next_red_pending : unsigned(led_red_pending'range);
  begin
    if rising_edge(cable_clk_rcv_global_0) then
      if d2d_rstn = '0' or d2d_rx_mmcm_locked0 = '0' then
        led_red_pending <= (others => '0');
      else
        next_red_pending := led_red_pending;
        if c0_d2d_data_rx_iob(65) = '1' and next_red_pending /= led_pending_max then
          next_red_pending := next_red_pending + 1;
        end if;

        if led_red_phase_prev = '1' and led_yellow_count(26) = '0' and next_red_pending /= 0 then
          next_red_pending := next_red_pending - 1;
        end if;

        led_red_pending <= next_red_pending;
      end if;
    end if;
  end process rx_led_debug_pending;

  led_yellow_dbg <= led_yellow_count(26);
  led_red_dbg <= led_yellow_count(26) when led_red_pending /= 0 else '0';

  -- Lossless credit CDC across asynchronous domains.
  c0_credit_in_evt_gray_src <= bin2gray(c0_credit_in_evt_bin_src);
  chiplet_credit_out_n_evt_gray_src <= bin2gray(chiplet_credit_out_n_evt_bin_src);
  chiplet_credit_out_s_evt_gray_src <= bin2gray(chiplet_credit_out_s_evt_bin_src);
  chiplet_credit_out_w_evt_gray_src <= bin2gray(chiplet_credit_out_w_evt_bin_src);
  chiplet_credit_out_e_evt_gray_src <= bin2gray(chiplet_credit_out_e_evt_bin_src);

  chiplet_credit_out_n_inc <= slv_popcount(chiplet_credit_out_n);
  chiplet_credit_out_s_inc <= slv_popcount(chiplet_credit_out_s);
  chiplet_credit_out_w_inc <= slv_popcount(chiplet_credit_out_w);
  chiplet_credit_out_e_inc <= slv_popcount(chiplet_credit_out_e);

  c0_credit_in_evt_bin_sync <= gray2bin(c0_credit_in_evt_gray_ff2);
  chiplet_credit_out_n_evt_bin_sync <= gray2bin(chiplet_credit_out_n_evt_gray_ff2);
  chiplet_credit_out_s_evt_bin_sync <= gray2bin(chiplet_credit_out_s_evt_gray_ff2);
  chiplet_credit_out_w_evt_bin_sync <= gray2bin(chiplet_credit_out_w_evt_gray_ff2);
  chiplet_credit_out_e_evt_bin_sync <= gray2bin(chiplet_credit_out_e_evt_gray_ff2);

  chiplet_credit_evt_src : process (clkm)
  begin
    if rising_edge(clkm) then
      if d2d_rstn = '0' then
        chiplet_credit_out_n_evt_bin_src <= (others => '0');
        chiplet_credit_out_s_evt_bin_src <= (others => '0');
        chiplet_credit_out_w_evt_bin_src <= (others => '0');
        chiplet_credit_out_e_evt_bin_src <= (others => '0');
      else
        chiplet_credit_out_n_evt_bin_src <= chiplet_credit_out_n_evt_bin_src + chiplet_credit_out_n_inc;
        chiplet_credit_out_s_evt_bin_src <= chiplet_credit_out_s_evt_bin_src + chiplet_credit_out_s_inc;
        chiplet_credit_out_w_evt_bin_src <= chiplet_credit_out_w_evt_bin_src + chiplet_credit_out_w_inc;
        chiplet_credit_out_e_evt_bin_src <= chiplet_credit_out_e_evt_bin_src + chiplet_credit_out_e_inc;
      end if;
    end if;
  end process chiplet_credit_evt_src;

  d2d_credit_evt_sync_and_drain : process (d2d_clk_int)
  begin
    if rising_edge(d2d_clk_int) then
      if d2d_rstn = '0' then
        c0_credit_in_evt_gray_ff1 <= (others => '0');
        c0_credit_in_evt_gray_ff2 <= (others => '0');
        chiplet_credit_out_n_evt_gray_ff1 <= (others => '0');
        chiplet_credit_out_n_evt_gray_ff2 <= (others => '0');
        chiplet_credit_out_s_evt_gray_ff1 <= (others => '0');
        chiplet_credit_out_s_evt_gray_ff2 <= (others => '0');
        chiplet_credit_out_w_evt_gray_ff1 <= (others => '0');
        chiplet_credit_out_w_evt_gray_ff2 <= (others => '0');
        chiplet_credit_out_e_evt_gray_ff1 <= (others => '0');
        chiplet_credit_out_e_evt_gray_ff2 <= (others => '0');

        c0_credit_in_evt_bin_seen <= (others => '0');
        chiplet_credit_out_n_evt_bin_seen <= (others => '0');
        chiplet_credit_out_s_evt_bin_seen <= (others => '0');
        chiplet_credit_out_w_evt_bin_seen <= (others => '0');
        chiplet_credit_out_e_evt_bin_seen <= (others => '0');

        c0_credit_in_pending <= (others => '0');
        chiplet_credit_out_n_pending <= (others => '0');
        chiplet_credit_out_s_pending <= (others => '0');
        chiplet_credit_out_w_pending <= (others => '0');
        chiplet_credit_out_e_pending <= (others => '0');

        c0_credit_in_sync_pulse <= '0';
        chiplet_credit_out_n_pulse_scalar <= '0';
        chiplet_credit_out_s_pulse_scalar <= '0';
        chiplet_credit_out_w_pulse_scalar <= '0';
        chiplet_credit_out_e_pulse_scalar <= '0';
      else
        c0_credit_in_evt_gray_ff1 <= c0_credit_in_evt_gray_src;
        c0_credit_in_evt_gray_ff2 <= c0_credit_in_evt_gray_ff1;
        chiplet_credit_out_n_evt_gray_ff1 <= chiplet_credit_out_n_evt_gray_src;
        chiplet_credit_out_n_evt_gray_ff2 <= chiplet_credit_out_n_evt_gray_ff1;
        chiplet_credit_out_s_evt_gray_ff1 <= chiplet_credit_out_s_evt_gray_src;
        chiplet_credit_out_s_evt_gray_ff2 <= chiplet_credit_out_s_evt_gray_ff1;
        chiplet_credit_out_w_evt_gray_ff1 <= chiplet_credit_out_w_evt_gray_src;
        chiplet_credit_out_w_evt_gray_ff2 <= chiplet_credit_out_w_evt_gray_ff1;
        chiplet_credit_out_e_evt_gray_ff1 <= chiplet_credit_out_e_evt_gray_src;
        chiplet_credit_out_e_evt_gray_ff2 <= chiplet_credit_out_e_evt_gray_ff1;

        drain_credit_evt(
          c0_credit_in_evt_bin_seen,
          c0_credit_in_pending,
          c0_credit_in_sync_pulse,
          c0_credit_in_evt_bin_sync
        );
        drain_credit_evt(
          chiplet_credit_out_n_evt_bin_seen,
          chiplet_credit_out_n_pending,
          chiplet_credit_out_n_pulse_scalar,
          chiplet_credit_out_n_evt_bin_sync
        );
        drain_credit_evt(
          chiplet_credit_out_s_evt_bin_seen,
          chiplet_credit_out_s_pending,
          chiplet_credit_out_s_pulse_scalar,
          chiplet_credit_out_s_evt_bin_sync
        );
        drain_credit_evt(
          chiplet_credit_out_w_evt_bin_seen,
          chiplet_credit_out_w_pending,
          chiplet_credit_out_w_pulse_scalar,
          chiplet_credit_out_w_evt_bin_sync
        );
        drain_credit_evt(
          chiplet_credit_out_e_evt_bin_seen,
          chiplet_credit_out_e_pending,
          chiplet_credit_out_e_pulse_scalar,
          chiplet_credit_out_e_evt_bin_sync
        );
      end if;
    end if;
  end process d2d_credit_evt_sync_and_drain;

  gen_credit_cdc_board0 : if BOARD_NUM = 0 generate
  begin
    chiplet_credit_out_s_sync_pulse <= (others => chiplet_credit_out_s_pulse_scalar);
    chiplet_credit_out_e_sync_pulse <= (others => chiplet_credit_out_e_pulse_scalar);
    chiplet_credit_out_n_sync_pulse <= (others => '0');
    chiplet_credit_out_w_sync_pulse <= (others => '0');
  end generate gen_credit_cdc_board0;

  gen_credit_cdc_board1 : if BOARD_NUM = 1 generate
  begin
    chiplet_credit_out_s_sync_pulse <= (others => chiplet_credit_out_s_pulse_scalar);
    chiplet_credit_out_w_sync_pulse <= (others => chiplet_credit_out_w_pulse_scalar);
    chiplet_credit_out_n_sync_pulse <= (others => '0');
    chiplet_credit_out_e_sync_pulse <= (others => '0');
  end generate gen_credit_cdc_board1;

  gen_credit_cdc_board2 : if BOARD_NUM = 2 generate
  begin
    chiplet_credit_out_n_sync_pulse <= (others => chiplet_credit_out_n_pulse_scalar);
    chiplet_credit_out_e_sync_pulse <= (others => chiplet_credit_out_e_pulse_scalar);
    chiplet_credit_out_s_sync_pulse <= (others => '0');
    chiplet_credit_out_w_sync_pulse <= (others => '0');
  end generate gen_credit_cdc_board2;

  gen_credit_cdc_board3 : if BOARD_NUM = 3 generate
  begin
    chiplet_credit_out_n_sync_pulse <= (others => chiplet_credit_out_n_pulse_scalar);
    chiplet_credit_out_w_sync_pulse <= (others => chiplet_credit_out_w_pulse_scalar);
    chiplet_credit_out_s_sync_pulse <= (others => '0');
    chiplet_credit_out_e_sync_pulse <= (others => '0');
  end generate gen_credit_cdc_board3;

  gen_board_io_cable_0 : if BOARD_NUM = 0 or BOARD_NUM = 2 generate
    gen_bufs : for i in 0 to 67 generate
      tx_iobuf_0 : IOBUF
        port map (
          O   => open,
          IO  => c0_cable_io_data(i + 68),
          I   => c0_d2d_data_tx_io(i),
          T   => '0'
        );
      rx_iobuf_0 : IOBUF
        port map (
          O   => c0_d2d_data_rx_io(i),
          IO  => c0_cable_io_data(i),
          I   => '0',
          T   => '1'
        );
    end generate gen_bufs;
  end generate gen_board_io_cable_0;

  gen_board_io_cable_2 : if BOARD_NUM = 1 or BOARD_NUM = 3 generate
    gen_bufs : for i in 0 to 67 generate
      tx_iobuf_0 : IOBUF
        port map (
          O   => open,
          IO  => c0_cable_io_data(i),
          I   => c0_d2d_data_tx_io(i),
          T   => '0'
        );
      rx_iobuf_0 : IOBUF
        port map (
          O   => c0_d2d_data_rx_io(i),
          IO  => c0_cable_io_data(i + 68),
          I   => '0',
          T   => '1'
        );
    end generate gen_bufs;
  end generate gen_board_io_cable_2;

  d2d_clk_ibufgds  : ibufgds
    generic map (
      IBUF_LOW_PWR => FALSE
    )
    port map (
      I   => d2d_clk_p,
      IB  => d2d_clk_n,
      O   => d2d_clk_int
    );

  -- Previous ODDRE1-based clock forwarding kept for reference.
  --
  -- inst_oddr_clk_fwd0 : ODDRE1
  -- generic map (
  --   IS_C_INVERTED   => '0',
  --   IS_D1_INVERTED  => '0',
  --   IS_D2_INVERTED  => '0',
  --   SIM_DEVICE      => "ULTRASCALE_PLUS",
  --   SRVAL           => '0'
  -- )
  -- port map (
  --   Q   =>  cable_clk_fwd_int_0,
  --   C   =>  d2d_clk_int,
  --   D1  =>  '1',
  --   D2  =>  '0',
  --   SR  =>  '0'
  -- );
  --
  -- inst_oddr_clk_fwd1 : ODDRE1
  -- generic map (
  --   IS_C_INVERTED   => '0',
  --   IS_D1_INVERTED  => '0',
  --   IS_D2_INVERTED  => '0',
  --   SIM_DEVICE      => "ULTRASCALE_PLUS",
  --   SRVAL           => '0'
  -- )
  -- port map (
  --   Q   =>  cable_clk_fwd_int_1,
  --   C   =>  d2d_clk_int,
  --   D1  =>  '1',
  --   D2  =>  '0',
  --   SR  =>  '0'
  -- );

  cable_clk_fwd_int_0 <= d2d_clk_int;
  -- Previous ODDRE1-based SDR launch path kept for reference.
  --
  -- gen_tx_oddr : for i in 0 to 67 generate
  --   inst_oddre1_data_c0 : ODDRE1
  --   generic map (
  --     IS_C_INVERTED  => '0',
  --     IS_D1_INVERTED => '0',
  --     IS_D2_INVERTED => '0',
  --     SIM_DEVICE     => "ULTRASCALE_PLUS",
  --     SRVAL          => '0'
  --   )
  --   port map (
  --     Q  => c0_d2d_data_tx_io(i),
  --     C  => d2d_clk_int,
  --     D1 => c0_d2d_data_tx(i),
  --     D2 => c0_d2d_data_tx(i),
  --     SR => '0'
  --   );
  --
  --   inst_oddre1_data_c1 : ODDRE1
  --   generic map (
  --     IS_C_INVERTED  => '0',
  --     IS_D1_INVERTED => '0',
  --     IS_D2_INVERTED => '0',
  --     SIM_DEVICE     => "ULTRASCALE_PLUS",
  --     SRVAL          => '0'
  --   )
  --   port map (
  --     Q  => c1_d2d_data_tx_io(i),
  --     C  => d2d_clk_int,
  --     D1 => c1_d2d_data_tx(i),
  --     D2 => c1_d2d_data_tx(i),
  --     SR => '0'
  --   );
  -- end generate gen_tx_oddr;

  -- SDR launch is a plain rising-edge register stage into the IOBUF inputs.
  d2d_tx_sdr_regs : process (d2d_clk_int)
  begin
    if rising_edge(d2d_clk_int) then
      c0_d2d_data_tx_io <= c0_d2d_data_tx;
    end if;
  end process d2d_tx_sdr_regs;

  -- Previous wide queued TX LED debug kept for reference.
  -- tx_credit_led_debug : process (d2d_clk_int)
  --   variable next_green_pending : unsigned(led_green_pending'range);
  -- begin
  --   if rising_edge(d2d_clk_int) then
  --     if d2d_rstn = '0' then
  --       led_green_count      <= (others => '0');
  --       led_green_pending    <= (others => '0');
  --       led_green_phase_prev <= '0';
  --     else
  --       led_green_count <= led_green_count + 1;
  --
  --       next_green_pending := led_green_pending;
  --       if c0_d2d_data_tx_io(66) = '1' then
  --         next_green_pending := next_green_pending + 1;
  --       end if;
  --
  --       if led_green_phase_prev = '1' and led_green_count(26) = '0' and next_green_pending /= 0 then
  --         next_green_pending := next_green_pending - 1;
  --       end if;
  --
  --       led_green_pending    <= next_green_pending;
  --       led_green_phase_prev <= led_green_count(26);
  --     end if;
  --   end if;
  -- end process tx_credit_led_debug;

  tx_credit_led_phase : process (d2d_clk_int)
  begin
    if rising_edge(d2d_clk_int) then
      if d2d_rstn = '0' then
        led_green_count      <= (others => '0');
        led_green_phase_prev <= '0';
      else
        led_green_phase_prev <= led_green_count(26);
        led_green_count      <= led_green_count + 1;
      end if;
    end if;
  end process tx_credit_led_phase;

  tx_credit_led_pending : process (d2d_clk_int)
    variable next_green_pending : unsigned(led_green_pending'range);
  begin
    if rising_edge(d2d_clk_int) then
      if d2d_rstn = '0' then
        led_green_pending <= (others => '0');
      else
        next_green_pending := led_green_pending;
        if c0_d2d_data_tx_io(66) = '1' and next_green_pending /= led_pending_max then
          next_green_pending := next_green_pending + 1;
        end if;

        if led_green_phase_prev = '1' and led_green_count(26) = '0' and next_green_pending /= 0 then
          next_green_pending := next_green_pending - 1;
        end if;

        led_green_pending <= next_green_pending;
      end if;
    end if;
  end process tx_credit_led_pending;

  -- Queue one visible half-period blink per sampled TX credit pulse.
  led_green_dbg <= led_green_count(26) when led_green_pending /= 0 else '0';

  inst_obufds_clk_0 : OBUFDS
    generic map (
      IOSTANDARD  => "LVDS"
    )
    port map (
      I   => cable_clk_fwd_int_0,
      O   => c0_cable_clk_p,
      OB  => c0_cable_clk_n
    );

  inst_ibufds_rcv_0 : IBUFDS
    generic map (
      DIFF_TERM     => TRUE,
      IBUF_LOW_PWR  => FALSE,
      IOSTANDARD    => "LVDS"
    )
    port map (
      I   => c0_cable_clk_p_rcv,
      IB  => c0_cable_clk_n_rcv,
      O   => cable_clk_rcv_raw_0
    );

  -- inst_mmcm_rcv_0 : MMCME4_ADV
  inst_mmcm_rcv_0 : MMCME3_ADV
    generic map (
      BANDWIDTH            => "OPTIMIZED",
      COMPENSATION         => "ZHOLD",
      DIVCLK_DIVIDE        => 1,
      CLKFBOUT_MULT_F      => 10.000,
      CLKOUT0_DIVIDE_F     => 10.000,
      CLKOUT0_PHASE        => D2D_RX_MMCM_PHASE_DEG_C0,
      CLKIN1_PERIOD        => D2D_RX_MMCM_CLKIN_PERIOD_NS
    )
    port map (
      CLKIN1   => cable_clk_rcv_raw_0,
      CLKIN2   => '0',
      CLKINSEL => '1',
      RST      => rst,
      PWRDWN   => '0',
      CLKFBOUT => d2d_rx_mmcm_clkfb_out0,
      CLKFBIN  => d2d_rx_mmcm_clkfb_in0,
      CLKOUT0  => d2d_rx_mmcm_clk_out0,
      LOCKED   => d2d_rx_mmcm_locked0,
      DADDR => (others => '0'), DCLK => '0', DEN => '0', DI => (others => '0'),
      DWE => '0', PSCLK => '0', PSEN => '0', PSINCDEC => '0', CDDCREQ => '0'
    );

  inst_bufg_fb_0 : BUFG
    port map ( I => d2d_rx_mmcm_clkfb_out0, O => d2d_rx_mmcm_clkfb_in0 );

  inst_bufg_out_0 : BUFG
    port map ( I => d2d_rx_mmcm_clk_out0, O => cable_clk_rcv_global_0 );

  -- gen_main_board : if BOARD_NUM = 0 generate
    c0_diagnostic : process (cable_clk_rcv_global_0, clkm_sync_rst)
    begin  -- process c0_diagnostic
      if clkm_sync_rst = '1' then           -- asynchronous reset (active high)
        c0_diagnostic_count <= (others => '0');
      elsif cable_clk_rcv_global_0'event and cable_clk_rcv_global_0 = '1' then  -- rising clock edge
        c0_diagnostic_count <= c0_diagnostic_count + 1;
      end if;
    end process c0_diagnostic;
    c0_diagnostic_toggle <= c0_diagnostic_count(26);
    c0_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c0_diagnostic_led, c0_diagnostic_toggle);
  
    -- c1_diagnostic : process (clkm_1, clkm_sync_rst_1)
    -- begin  -- process c1_diagnostic
    --   if clkm_sync_rst_1 = '1' then           -- asynchronous reset (active high)
    --     c1_diagnostic_count <= (others => '0');
    --   elsif clkm_1'event and clkm_1 = '1' then  -- rising clock edge
    --     c1_diagnostic_count <= c1_diagnostic_count + 1;
    --   end if;
    -- end process c1_diagnostic;
    -- c1_diagnostic_toggle <= c1_diagnostic_count(26);
    -- c1_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c1_diagnostic_led, c1_diagnostic_toggle);
  
    -- c2_diagnostic : process (clkm_2, clkm_sync_rst_2)
    -- begin  -- process c2_diagnostic
    --   if clkm_sync_rst_2 = '1' then           -- asynchronous reset (active high)
    --     c2_diagnostic_count <= (others => '0');
    --   elsif clkm_2'event and clkm_2 = '1' then  -- rising clock edge
    --     c2_diagnostic_count <= c2_diagnostic_count + 1;
    --   end if;
    -- end process c2_diagnostic;
    -- c2_diagnostic_toggle <= c2_diagnostic_count(26);
    -- c2_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c2_diagnostic_led, c2_diagnostic_toggle);
  
    -- c3_diagnostic : process (clkm_3, clkm_sync_rst_3)
    -- begin  -- process c3_diagnostic
    --   if clkm_sync_rst_3 = '1' then           -- asynchronous reset (active high)
    --     c3_diagnostic_count <= (others => '0');
    --   elsif clkm_3'event and clkm_3 = '1' then  -- rising clock edge
    --     c3_diagnostic_count <= c3_diagnostic_count + 1;
    --   end if;
    -- end process c3_diagnostic;
    -- c3_diagnostic_toggle <= c3_diagnostic_count(26);
    -- c3_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c3_diagnostic_led, c3_diagnostic_toggle);
  
    -- c4_diagnostic : process (clkm_4, clkm_sync_rst_4)
    -- begin  -- process c4_diagnostic
    --   if clkm_sync_rst_4 = '1' then           -- asynchronous reset (active high)
    --     c4_diagnostic_count <= (others => '0');
    --   elsif clkm_4'event and clkm_4 = '1' then  -- rising clock edge
    --     c4_diagnostic_count <= c4_diagnostic_count + 1;
    --   end if;
    -- end process c4_diagnostic;
    -- c4_diagnostic_toggle <= c4_diagnostic_count(26);
    -- c4_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c4_diagnostic_led, c4_diagnostic_toggle);
  
    -- c5_diagnostic : process (clkm_5, clkm_sync_rst_5)
    -- begin  -- process c5_diagnostic
    --   if clkm_sync_rst_5 = '1' then           -- asynchronous reset (active high)
    --     c5_diagnostic_count <= (others => '0');
    --   elsif clkm_5'event and clkm_5 = '1' then  -- rising clock edge
    --     c5_diagnostic_count <= c5_diagnostic_count + 1;
    --   end if;
    -- end process c5_diagnostic;
    -- c5_diagnostic_toggle <= c5_diagnostic_count(26);
    -- c5_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c5_diagnostic_led, c5_diagnostic_toggle);
  
    -- c6_diagnostic : process (clkm_6, clkm_sync_rst_6)
    -- begin  -- process c6_diagnostic
    --   if clkm_sync_rst_6 = '1' then           -- asynchronous reset (active high)
    --     c6_diagnostic_count <= (others => '0');
    --   elsif clkm_6'event and clkm_6 = '1' then  -- rising clock edge
    --     c6_diagnostic_count <= c6_diagnostic_count + 1;
    --   end if;
    -- end process c6_diagnostic;
    -- c6_diagnostic_toggle <= c6_diagnostic_count(26);
    -- c6_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c6_diagnostic_led, c6_diagnostic_toggle);
  
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
-- end generate gen_main_board;

-------------------------------------------------------------------------------
-- Leds -----------------------------------------------------------------------
-------------------------------------------------------------------------------


  -- From TX credit pulse counter
  tx_credit_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v) port map (LED_GREEN, led_green_dbg);

  -- From RX cable debug logic
  cpuerr_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v) port map (LED_RED, led_red_dbg);
  --pragma translate_off
  process(clkm, rstn)
  begin  -- process
    if rstn = '1' then
      assert cpuerr = '0' report "Program Completed!" severity failure;
    end if;
  end process;
  --pragma translate_on

  -- gen_main_board_1 : if BOARD_NUM = 0 generate
    -- From DDR controller (on FPGA)
    calib0_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c0_calib_complete, c0_calib_done);
    -- calib1_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c1_calib_complete, c1_calib_done);
    -- calib2_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c2_calib_complete, c2_calib_done);
    -- calib3_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c3_calib_complete, c3_calib_done);
    -- calib4_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c4_calib_complete, c4_calib_done);
    -- calib5_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c5_calib_complete, c5_calib_done);
    -- calib6_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c6_calib_complete, c6_calib_done);
    --calib7_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c7_calib_complete, c7_calib_done);
  -- end generate gen_main_board_1;

  led3_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v) port map (LED_BLUE, d2d_ready);

  led4_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v) port map (LED_YELLOW, led_yellow_dbg);

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
-------------------------------------------------------------------------------
-- Buttons --------------------------------------------------------------------
-------------------------------------------------------------------------------

  --pio_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --  port map (button(i-4), gpioi.din(i));

----------------------------------------------------------------------
--- FPGA Reset and Clock generation  ---------------------------------
----------------------------------------------------------------------

  cgi.pllctrl <= "00";

  -- gen_main_board_pll_reset : if BOARD_NUM = 0 generate
    cgi.pllrst <= rstraw;
  -- end generate gen_main_board_pll_reset;

  -- gen_satellite_board_pll_reset : if BOARD_NUM /= 0 generate
  --   -- Satellite boards do not have a documented external reset source in the
  --   -- generated proFPGA project. Keep their PLL out of reset unconditionally.
  --   cgi.pllrst <= '1';
  -- end generate gen_satellite_board_pll_reset;

  -- gen_sate_board_lock : if BOARD_NUM /= 0 generate
  --   lock <= cgo.clklock;
  -- end generate gen_sate_board_lock;
  -- gen_main_board_lock : if BOARD_NUM = 0 generate
    lock <= c0_calib_done and cgo.clklock;
    --  and c1_calib_done and c2_calib_done and c3_calib_done
            -- and c4_calib_done and c5_calib_done and c6_calib_done and cgo.clklock;
  -- end generate gen_main_board_lock;

  reset_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (reset, rst);

  -- gen_main_board_reset : if BOARD_NUM = 0 generate
  --   rst <= rst_pad;
  -- end generate gen_main_board_reset;

  -- gen_satellite_board_reset : if BOARD_NUM /= 0 generate
  --   -- Preserve the shared top-level port for the board wrapper, but do not
  --   -- let an unconnected satellite reset pad control system startup. Generate
  --   -- a local power-on reset so raw-reset consumers still see an asserted
  --   -- reset phase after the board PLL locks.
  --   keep_reset_port : unread port map (d_i => rst_pad);

  --   satellite_reset_gen : process (esp_clk)
  --   begin
  --     -- if cgo.clklock = '0' then
  --       if rising_edge(esp_clk) then
  --         if satellite_rst_count = x"FF" then
  --           satellite_rst <= '0';
  --         else
  --           satellite_rst <= '1';
  --           satellite_rst_count <= satellite_rst_count + 1;
  --         end if;
  --     end if;
  --   end process satellite_reset_gen;

  --   rst <= satellite_rst;
  -- end generate gen_satellite_board_reset;

  rst0      : rstgen                    -- D2D reset generator
    generic map (acthigh => 1, syncin => 0)
    port map (rst, clkm, lock, d2d_rstn, open);

  d2d_rst <= not d2d_rstn;
  c0_d2d_link_ready <= (d2d_tx_link_ready_w and d2d_rx_link_ready_w) when C0_IS_WEST else
                       (d2d_tx_link_ready_e and d2d_rx_link_ready_e);

  d2d_ready <= '1' when ISOLATE_BOARD0_D2D else
               d2d_rx_mmcm_locked0 and
               c0_d2d_link_ready;

  -- Release the rest of the system only after the D2D clocks are up under
  -- the original reset timing.
  d2d_startup_sync : process (clkm, d2d_rstn)
  begin
    if d2d_rstn = '0' then
      d2d_ready_sync_1 <= '0';
      d2d_ready_sync   <= '0';
      d2d_startup_done <= '0';
    elsif rising_edge(clkm) then
      d2d_ready_sync_1 <= d2d_ready;
      d2d_ready_sync   <= d2d_ready_sync_1;
      if d2d_ready_sync = '1' then
        d2d_startup_done <= '1';
      end if;
    end if;
  end process d2d_startup_sync;

  delayed_rst0 : rstgen
    generic map (acthigh => 1, syncin => 0)
    port map (d2d_rst, clkm, d2d_startup_done, rstn, open);

--  gen_main_board_mig_rstgen : if BOARD_NUM = 0 generate
    mig_rst0 : rstgen                         -- reset generator
      generic map (acthigh => 1)
      port map (rst, clkm, lock, migrstn, rstraw);
    -- mig_rst1 : rstgen                         -- reset generator
    --   generic map (acthigh => 1)
    --   port map (rst, clkm_1, lock, migrstn_1, rstraw_1);
    -- mig_rst2 : rstgen                         -- reset generator
    --   generic map (acthigh => 1)
    --   port map (rst, clkm_2, lock, migrstn_2, rstraw_2);
    -- mig_rst3 : rstgen                         -- reset generator
    --   generic map (acthigh => 1)
    --   port map (rst, clkm_3, lock, migrstn_3, rstraw_3);
    -- mig_rst4 : rstgen                         -- reset generator
    --   generic map (acthigh => 1)
    --   port map (rst, clkm_4, lock, migrstn_4, rstraw_4);
    -- mig_rst5 : rstgen                         -- reset generator
    --   generic map (acthigh => 1)
    --   port map (rst, clkm_5, lock, migrstn_5, rstraw_5);
    -- mig_rst6 : rstgen                         -- reset generator
    --   generic map (acthigh => 1)
    --   port map (rst, clkm_6, lock, migrstn_6, rstraw_6);
  --  mig_rst7 : rstgen                         -- reset generator
  --    generic map (acthigh => 1)
  --    port map (rst, clkm_7, lock, migrstn_7, rstraw_7);
--  end generate gen_main_board_mig_rstgen;

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

-----------------------------------------------------------------------------
-- UART pads
-----------------------------------------------------------------------------
  -- gen_main_board_uart : if BOARD_NUM = 0 generate
  --   uart_rxd_pad   : inpad  generic map (level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_rxd, uart_rxd_int);
  --   uart_txd_pad   : outpad generic map (level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_txd, uart_txd_int);
  --   uart_ctsn_pad : inpad  generic map (level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_ctsn, uart_ctsn_int);
  --   uart_rtsn_pad : outpad generic map (level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_rtsn, uart_rtsn_int);
  -- end generate gen_main_board_uart;

  -- gen_satellite_board_uart : if BOARD_NUM /= 0 generate
    -- No UART card on satellite boards: keep UART RX/CTS inactive.
    uart_rxd_int  <= '1';
    uart_ctsn_int <= '1';
    UART_TXD      <= '1';
    UART_RTS_B    <= '1';
    -- uart_txd_int      <= '1';
    -- uart_rtsn_int     <= '1';
  -- end generate gen_satellite_board_uart;
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

    -- ddrc1 : ahb2mig_ebddr4r5
    --   generic map (
    --     hindex => 0,
    --     haddr  => ddr_haddr(this_ddr_index(1)),
    --     hmask  => ddr_hmask(this_ddr_index(1)))
    --   port map (
    --     c0_sys_clk_p     => c1_sys_clk_p,
    --     c0_sys_clk_n     => c1_sys_clk_n,
    --     c0_ddr4_act_n    => c1_ddr4_act_n,
    --     c0_ddr4_adr      => c1_ddr4_adr,
    --     c0_ddr4_ba       => c1_ddr4_ba,
    --     c0_ddr4_bg       => c1_ddr4_bg,
    --     c0_ddr4_cke      => c1_ddr4_cke,
    --     c0_ddr4_odt      => c1_ddr4_odt,
    --     c0_ddr4_cs_n     => c1_ddr4_cs_n,
    --     c0_ddr4_ck_t     => c1_ddr4_ck_t,
    --     c0_ddr4_ck_c     => c1_ddr4_ck_c,
    --     c0_ddr4_reset_n  => c1_ddr4_reset_n,
    --     c0_ddr4_dm_dbi_n => c1_ddr4_dm_dbi_n,
    --     c0_ddr4_dq       => c1_ddr4_dq,
    --     c0_ddr4_dqs_c    => c1_ddr4_dqs_c,
    --     c0_ddr4_dqs_t    => c1_ddr4_dqs_t,
    --     ahbso            => ddr_ahbso(1),
    --     ahbsi            => ddr_ahbsi(1),
    --     calib_done       => c1_calib_done,
    --     rst_n_syn        => migrstn_1,
    --     rst_n_async      => rstraw_1,
    --     clk_amba         => clkm_1,
    --     ui_clk           => clkm_1,
    --     ui_clk_sync_rst  => clkm_sync_rst_1
    --     );

    -- ddrc2 : ahb2mig_ebddr4r5
    --   generic map (
    --     hindex => 0,
    --     haddr  => ddr_haddr(this_ddr_index(2)),
    --     hmask  => ddr_hmask(this_ddr_index(2)))
    --   port map (
    --     c0_sys_clk_p     => c2_sys_clk_p,
    --     c0_sys_clk_n     => c2_sys_clk_n,
    --     c0_ddr4_act_n    => c2_ddr4_act_n,
    --     c0_ddr4_adr      => c2_ddr4_adr,
    --     c0_ddr4_ba       => c2_ddr4_ba,
    --     c0_ddr4_bg       => c2_ddr4_bg,
    --     c0_ddr4_cke      => c2_ddr4_cke,
    --     c0_ddr4_odt      => c2_ddr4_odt,
    --     c0_ddr4_cs_n     => c2_ddr4_cs_n,
    --     c0_ddr4_ck_t     => c2_ddr4_ck_t,
    --     c0_ddr4_ck_c     => c2_ddr4_ck_c,
    --     c0_ddr4_reset_n  => c2_ddr4_reset_n,
    --     c0_ddr4_dm_dbi_n => c2_ddr4_dm_dbi_n,
    --     c0_ddr4_dq       => c2_ddr4_dq,
    --     c0_ddr4_dqs_c    => c2_ddr4_dqs_c,
    --     c0_ddr4_dqs_t    => c2_ddr4_dqs_t,
    --     ahbso            => ddr_ahbso(2),
    --     ahbsi            => ddr_ahbsi(2),
    --     calib_done       => c2_calib_done,
    --     rst_n_syn        => migrstn_2,
    --     rst_n_async      => rstraw_2,
    --     clk_amba         => clkm_2,
    --     ui_clk           => clkm_2,
    --     ui_clk_sync_rst  => clkm_sync_rst_2
    --     );

    -- ddrc3 : ahb2mig_ebddr4r5
    --   generic map (
    --     hindex => 0,
    --     haddr  => ddr_haddr(this_ddr_index(3)),
    --     hmask  => ddr_hmask(this_ddr_index(3)))
    --   port map (
    --     c0_sys_clk_p     => c3_sys_clk_p,
    --     c0_sys_clk_n     => c3_sys_clk_n,
    --     c0_ddr4_act_n    => c3_ddr4_act_n,
    --     c0_ddr4_adr      => c3_ddr4_adr,
    --     c0_ddr4_ba       => c3_ddr4_ba,
    --     c0_ddr4_bg       => c3_ddr4_bg,
    --     c0_ddr4_cke      => c3_ddr4_cke,
    --     c0_ddr4_odt      => c3_ddr4_odt,
    --     c0_ddr4_cs_n     => c3_ddr4_cs_n,
    --     c0_ddr4_ck_t     => c3_ddr4_ck_t,
    --     c0_ddr4_ck_c     => c3_ddr4_ck_c,
    --     c0_ddr4_reset_n  => c3_ddr4_reset_n,
    --     c0_ddr4_dm_dbi_n => c3_ddr4_dm_dbi_n,
    --     c0_ddr4_dq       => c3_ddr4_dq,
    --     c0_ddr4_dqs_c    => c3_ddr4_dqs_c,
    --     c0_ddr4_dqs_t    => c3_ddr4_dqs_t,
    --     ahbso            => ddr_ahbso(3),
    --     ahbsi            => ddr_ahbsi(3),
    --     calib_done       => c3_calib_done,
    --     rst_n_syn        => migrstn_3,
    --     rst_n_async      => rstraw_3,
    --     clk_amba         => clkm_3,
    --     ui_clk           => clkm_3,
    --     ui_clk_sync_rst  => clkm_sync_rst_3
    --     );

    -- ddrc4 : ahb2mig_ebddr4r5
    --   generic map (
    --     hindex => 0,
    --     haddr  => ddr_haddr(this_ddr_index(4)),
    --     hmask  => ddr_hmask(this_ddr_index(4)))
    --   port map (
    --     c0_sys_clk_p     => c4_sys_clk_p,
    --     c0_sys_clk_n     => c4_sys_clk_n,
    --     c0_ddr4_act_n    => c4_ddr4_act_n,
    --     c0_ddr4_adr      => c4_ddr4_adr,
    --     c0_ddr4_ba       => c4_ddr4_ba,
    --     c0_ddr4_bg       => c4_ddr4_bg,
    --     c0_ddr4_cke      => c4_ddr4_cke,
    --     c0_ddr4_odt      => c4_ddr4_odt,
    --     c0_ddr4_cs_n     => c4_ddr4_cs_n,
    --     c0_ddr4_ck_t     => c4_ddr4_ck_t,
    --     c0_ddr4_ck_c     => c4_ddr4_ck_c,
    --     c0_ddr4_reset_n  => c4_ddr4_reset_n,
    --     c0_ddr4_dm_dbi_n => c4_ddr4_dm_dbi_n,
    --     c0_ddr4_dq       => c4_ddr4_dq,
    --     c0_ddr4_dqs_c    => c4_ddr4_dqs_c,
    --     c0_ddr4_dqs_t    => c4_ddr4_dqs_t,
    --     ahbso            => ddr_ahbso(4),
    --     ahbsi            => ddr_ahbsi(4),
    --     calib_done       => c4_calib_done,
    --     rst_n_syn        => migrstn_4,
    --     rst_n_async      => rstraw_4,
    --     clk_amba         => clkm_4,
    --     ui_clk           => clkm_4,
    --     ui_clk_sync_rst  => clkm_sync_rst_4
    --     );

    -- ddrc5 : ahb2mig_ebddr4r5
    --   generic map (
    --     hindex => 0,
    --     haddr  => ddr_haddr(this_ddr_index(5)),
    --     hmask  => ddr_hmask(this_ddr_index(5)))
    --   port map (
    --     c0_sys_clk_p     => c5_sys_clk_p,
    --     c0_sys_clk_n     => c5_sys_clk_n,
    --     c0_ddr4_act_n    => c5_ddr4_act_n,
    --     c0_ddr4_adr      => c5_ddr4_adr,
    --     c0_ddr4_ba       => c5_ddr4_ba,
    --     c0_ddr4_bg       => c5_ddr4_bg,
    --     c0_ddr4_cke      => c5_ddr4_cke,
    --     c0_ddr4_odt      => c5_ddr4_odt,
    --     c0_ddr4_cs_n     => c5_ddr4_cs_n,
    --     c0_ddr4_ck_t     => c5_ddr4_ck_t,
    --     c0_ddr4_ck_c     => c5_ddr4_ck_c,
    --     c0_ddr4_reset_n  => c5_ddr4_reset_n,
    --     c0_ddr4_dm_dbi_n => c5_ddr4_dm_dbi_n,
    --     c0_ddr4_dq       => c5_ddr4_dq,
    --     c0_ddr4_dqs_c    => c5_ddr4_dqs_c,
    --     c0_ddr4_dqs_t    => c5_ddr4_dqs_t,
    --     ahbso            => ddr_ahbso(5),
    --     ahbsi            => ddr_ahbsi(5),
    --     calib_done       => c5_calib_done,
    --     rst_n_syn        => migrstn_5,
    --     rst_n_async      => rstraw_5,
    --     clk_amba         => clkm_5,
    --     ui_clk           => clkm_5,
    --     ui_clk_sync_rst  => clkm_sync_rst_5
    --     );

    -- ddrc6 : ahb2mig_ebddr4r5
    --   generic map (
    --     hindex => 0,
    --     haddr  => ddr_haddr(this_ddr_index(6)),
    --     hmask  => ddr_hmask(this_ddr_index(6)))
    --   port map (
    --     c0_sys_clk_p     => c6_sys_clk_p,
    --     c0_sys_clk_n     => c6_sys_clk_n,
    --     c0_ddr4_act_n    => c6_ddr4_act_n,
    --     c0_ddr4_adr      => c6_ddr4_adr,
    --     c0_ddr4_ba       => c6_ddr4_ba,
    --     c0_ddr4_bg       => c6_ddr4_bg,
    --     c0_ddr4_cke      => c6_ddr4_cke,
    --     c0_ddr4_odt      => c6_ddr4_odt,
    --     c0_ddr4_cs_n     => c6_ddr4_cs_n,
    --     c0_ddr4_ck_t     => c6_ddr4_ck_t,
    --     c0_ddr4_ck_c     => c6_ddr4_ck_c,
    --     c0_ddr4_reset_n  => c6_ddr4_reset_n,
    --     c0_ddr4_dm_dbi_n => c6_ddr4_dm_dbi_n,
    --     c0_ddr4_dq       => c6_ddr4_dq,
    --     c0_ddr4_dqs_c    => c6_ddr4_dqs_c,
    --     c0_ddr4_dqs_t    => c6_ddr4_dqs_t,
    --     ahbso            => ddr_ahbso(6),
    --     ahbsi            => ddr_ahbsi(6),
    --     calib_done       => c6_calib_done,
    --     rst_n_syn        => migrstn_6,
    --     rst_n_async      => rstraw_6,
    --     clk_amba         => clkm_6,
    --     ui_clk           => clkm_6,
    --     ui_clk_sync_rst  => clkm_sync_rst_6
    --     );

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
  -- gen_mig_satellite : if BOARD_NUM /= 0 generate
    -- c0_ddr4_act_n    <= '1';
    -- c0_ddr4_adr      <= (others => '0');
    -- c0_ddr4_ba       <= (others => '0');
    -- c0_ddr4_bg       <= (others => '0');
    -- c0_ddr4_cke      <= (others => '0');
    -- c0_ddr4_odt      <= (others => '0');
    -- c0_ddr4_cs_n     <= (others => '0');
    -- c0_ddr4_ck_t     <= (others => '0');
    -- c0_ddr4_ck_c     <= (others => '0');
    -- c0_ddr4_reset_n  <= '1';
    -- c0_ddr4_dm_dbi_n <= (others => 'Z');
    -- c0_ddr4_dq       <= (others => 'Z');
    -- c0_ddr4_dqs_c    <= (others => 'Z');
    -- c0_ddr4_dqs_t    <= (others => 'Z');
    -- c0_calib_done    <= '1';

    -- c1_ddr4_act_n    <= '1';
    -- c1_ddr4_adr      <= (others => '0');
    -- c1_ddr4_ba       <= (others => '0');
    -- c1_ddr4_bg       <= (others => '0');
    -- c1_ddr4_cke      <= (others => '0');
    -- c1_ddr4_odt      <= (others => '0');
    -- c1_ddr4_cs_n     <= (others => '0');
    -- c1_ddr4_ck_t     <= (others => '0');
    -- c1_ddr4_ck_c     <= (others => '0');
    -- c1_ddr4_reset_n  <= '1';
    -- c1_ddr4_dm_dbi_n <= (others => 'Z');
    -- c1_ddr4_dq       <= (others => 'Z');
    -- c1_ddr4_dqs_c    <= (others => 'Z');
    -- c1_ddr4_dqs_t    <= (others => 'Z');
    -- c1_calib_done    <= '1';

    -- c2_ddr4_act_n    <= '1';
    -- c2_ddr4_adr      <= (others => '0');
    -- c2_ddr4_ba       <= (others => '0');
    -- c2_ddr4_bg       <= (others => '0');
    -- c2_ddr4_cke      <= (others => '0');
    -- c2_ddr4_odt      <= (others => '0');
    -- c2_ddr4_cs_n     <= (others => '0');
    -- c2_ddr4_ck_t     <= (others => '0');
    -- c2_ddr4_ck_c     <= (others => '0');
    -- c2_ddr4_reset_n  <= '1';
    -- c2_ddr4_dm_dbi_n <= (others => 'Z');
    -- c2_ddr4_dq       <= (others => 'Z');
    -- c2_ddr4_dqs_c    <= (others => 'Z');
    -- c2_ddr4_dqs_t    <= (others => 'Z');
    -- c2_calib_done    <= '1';

    -- c3_ddr4_act_n    <= '1';
    -- c3_ddr4_adr      <= (others => '0');
    -- c3_ddr4_ba       <= (others => '0');
    -- c3_ddr4_bg       <= (others => '0');
    -- c3_ddr4_cke      <= (others => '0');
    -- c3_ddr4_odt      <= (others => '0');
    -- c3_ddr4_cs_n     <= (others => '0');
    -- c3_ddr4_ck_t     <= (others => '0');
    -- c3_ddr4_ck_c     <= (others => '0');
    -- c3_ddr4_reset_n  <= '1';
    -- c3_ddr4_dm_dbi_n <= (others => 'Z');
    -- c3_ddr4_dq       <= (others => 'Z');
    -- c3_ddr4_dqs_c    <= (others => 'Z');
    -- c3_ddr4_dqs_t    <= (others => 'Z');
    -- c3_calib_done    <= '1';

    -- c4_ddr4_act_n    <= '1';
    -- c4_ddr4_adr      <= (others => '0');
    -- c4_ddr4_ba       <= (others => '0');
    -- c4_ddr4_bg       <= (others => '0');
    -- c4_ddr4_cke      <= (others => '0');
    -- c4_ddr4_odt      <= (others => '0');
    -- c4_ddr4_cs_n     <= (others => '0');
    -- c4_ddr4_ck_t     <= (others => '0');
    -- c4_ddr4_ck_c     <= (others => '0');
    -- c4_ddr4_reset_n  <= '1';
    -- c4_ddr4_dm_dbi_n <= (others => 'Z');
    -- c4_ddr4_dq       <= (others => 'Z');
    -- c4_ddr4_dqs_c    <= (others => 'Z');
    -- c4_ddr4_dqs_t    <= (others => 'Z');
    -- c4_calib_done    <= '1';

    -- c5_ddr4_act_n    <= '1';
    -- c5_ddr4_adr      <= (others => '0');
    -- c5_ddr4_ba       <= (others => '0');
    -- c5_ddr4_bg       <= (others => '0');
    -- c5_ddr4_cke      <= (others => '0');
    -- c5_ddr4_odt      <= (others => '0');
    -- c5_ddr4_cs_n     <= (others => '0');
    -- c5_ddr4_ck_t     <= (others => '0');
    -- c5_ddr4_ck_c     <= (others => '0');
    -- c5_ddr4_reset_n  <= '1';
    -- c5_ddr4_dm_dbi_n <= (others => 'Z');
    -- c5_ddr4_dq       <= (others => 'Z');
    -- c5_ddr4_dqs_c    <= (others => 'Z');
    -- c5_ddr4_dqs_t    <= (others => 'Z');
    -- c5_calib_done    <= '1';

    -- c6_ddr4_act_n    <= '1';
    -- c6_ddr4_adr      <= (others => '0');
    -- c6_ddr4_ba       <= (others => '0');
    -- c6_ddr4_bg       <= (others => '0');
    -- c6_ddr4_cke      <= (others => '0');
    -- c6_ddr4_odt      <= (others => '0');
    -- c6_ddr4_cs_n     <= (others => '0');
    -- c6_ddr4_ck_t     <= (others => '0');
    -- c6_ddr4_ck_c     <= (others => '0');
    -- c6_ddr4_reset_n  <= '1';
    -- c6_ddr4_dm_dbi_n <= (others => 'Z');
    -- c6_ddr4_dq       <= (others => 'Z');
    -- c6_ddr4_dqs_c    <= (others => 'Z');
    -- c6_ddr4_dqs_t    <= (others => 'Z');
    -- c6_calib_done    <= '1';

    -- rstraw_1         <= not rst;
    -- rstraw_2         <= not rst;
    -- rstraw_3         <= not rst;
    -- rstraw_4         <= not rst;
    -- rstraw_5         <= not rst;
    -- rstraw_6         <= not rst;

    -- c1_diagnostic_led <= '0'; c1_calib_complete <= '1';
    -- c2_diagnostic_led <= '0'; c2_calib_complete <= '1';
    -- c3_diagnostic_led <= '0'; c3_calib_complete <= '1';
    -- c4_diagnostic_led <= '0'; c4_calib_complete <= '1';
    -- c5_diagnostic_led <= '0'; c5_calib_complete <= '1';
    -- c6_diagnostic_led <= '0'; c6_calib_complete <= '1';

    -- Keep UART CTS asserted in simulation so bootrom TX wait loops can drain.
    -- uart_rxd_int     <= '0';
    -- uart_ctsn_int    <= '0';
    -- emdio            <= 'Z';

    -- gen_sim_clocks : if SIMULATION generate
    --     clkm   <= not clkm   after 3.2 ns;
    --     clkm_1 <= not clkm_1 after 3.2 ns;
    --     clkm_2 <= not clkm_2 after 3.2 ns;
    --     clkm_3 <= not clkm_3 after 3.2 ns;
    --     clkm_4 <= not clkm_4 after 3.2 ns;
    --     clkm_5 <= not clkm_5 after 3.2 ns;
    --     clkm_6 <= not clkm_6 after 3.2 ns;
    -- end generate gen_sim_clocks;

    -- gen_syn_clocks : if not SIMULATION generate
    --     clkm   <= chip_refclk;
    --     clkm_1 <= chip_refclk;
    --     clkm_2 <= chip_refclk;
    --     clkm_3 <= chip_refclk;
    --     clkm_4 <= chip_refclk;
    --     clkm_5 <= chip_refclk;
    --     clkm_6 <= chip_refclk;
    -- end generate gen_syn_clocks;

    ahb_termination : for i in 1 to MAX_NMEM_TILES-1 generate
      ddr_ahbso(i) <= ahbs_none; 
    end generate ahb_termination;
  -- end generate gen_mig_satellite;
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

    -- mig_ahbram1 : ahbram_sim
    --   generic map (
    --     hindex => 0,
    --     tech   => 0,
    --     kbytes => 100,
    --     pipe   => 0,
    --     maccsz => AHBDW,
    --     fname  => "ram.srec"
    --     )
    --   port map(
    --     rst   => rstn,
    --     clk   => clkm,
    --     haddr => ddr_haddr(this_ddr_index(1)),
    --     hmask => ddr_hmask(this_ddr_index(1)),
    --     ahbsi => ddr_ahbsi(1),
    --     ahbso => ddr_ahbso(1)
    --     );

    -- mig_ahbram2 : ahbram_sim
    --   generic map (
    --     hindex => 0,
    --     tech   => 0,
    --     kbytes => 100,
    --     pipe   => 0,
    --     maccsz => AHBDW,
    --     fname  => "ram.srec"
    --     )
    --   port map(
    --     rst   => rstn,
    --     clk   => clkm,
    --     haddr => ddr_haddr(this_ddr_index(2)),
    --     hmask => ddr_hmask(this_ddr_index(2)),
    --     ahbsi => ddr_ahbsi(2),
    --     ahbso => ddr_ahbso(2)
    --     );

    -- mig_ahbram3 : ahbram_sim
    --   generic map (
    --     hindex => 0,
    --     tech   => 0,
    --     kbytes => 100,
    --     pipe   => 0,
    --     maccsz => AHBDW,
    --     fname  => "ram.srec"
    --     )
    --   port map(
    --     rst   => rstn,
    --     clk   => clkm,
    --     haddr => ddr_haddr(this_ddr_index(3)),
    --     hmask => ddr_hmask(this_ddr_index(3)),
    --     ahbsi => ddr_ahbsi(3),
    --     ahbso => ddr_ahbso(3)
    --     );

    -- mig_ahbram4 : ahbram_sim
    --   generic map (
    --     hindex => 0,
    --     tech   => 0,
    --     kbytes => 100,
    --     pipe   => 0,
    --     maccsz => AHBDW,
    --     fname  => "ram.srec"
    --     )
    --   port map(
    --     rst   => rstn,
    --     clk   => clkm,
    --     haddr => ddr_haddr(this_ddr_index(4)),
    --     hmask => ddr_hmask(this_ddr_index(4)),
    --     ahbsi => ddr_ahbsi(4),
    --     ahbso => ddr_ahbso(4)
    --     );

    -- mig_ahbram5 : ahbram_sim
    --   generic map (
    --     hindex => 0,
    --     tech   => 0,
    --     kbytes => 100,
    --     pipe   => 0,
    --     maccsz => AHBDW,
    --     fname  => "ram.srec"
    --     )
    --   port map(
    --     rst   => rstn,
    --     clk   => clkm,
    --     haddr => ddr_haddr(this_ddr_index(5)),
    --     hmask => ddr_hmask(this_ddr_index(5)),
    --     ahbsi => ddr_ahbsi(5),
    --     ahbso => ddr_ahbso(5)
    --     );

    -- mig_ahbram6 : ahbram_sim
    --   generic map (
    --     hindex => 0,
    --     tech   => 0,
    --     kbytes => 100,
    --     pipe   => 0,
    --     maccsz => AHBDW,
    --     fname  => "ram.srec"
    --     )
    --   port map(
    --     rst   => rstn,
    --     clk   => clkm,
    --     haddr => ddr_haddr(this_ddr_index(6)),
    --     hmask => ddr_hmask(this_ddr_index(6)),
    --     ahbsi => ddr_ahbsi(6),
    --     ahbso => ddr_ahbso(6)
    --     );

    -- mig_ahbram7 : ahbram_sim
    --   generic map (
    --     hindex => 0,
    --     tech   => 0,
    --     kbytes => 100,
    --     pipe   => 0,
    --     maccsz => AHBDW,
    --     fname  => "ram.srec"
    --     )
    --   port map(
    --     rst   => rstn,
    --     clk   => clkm,
    --     haddr => ddr_haddr(this_ddr_index(7)),
    --     hmask => ddr_hmask(this_ddr_index(7)),
    --     ahbsi => ddr_ahbsi(7),
    --     ahbso => ddr_ahbso(7)
    --     );

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

    -- c1_ddr4_act_n    <= '1';
    -- c1_ddr4_adr      <= (others => '0');
    -- c1_ddr4_ba       <= (others => '0');
    -- c1_ddr4_bg       <= (others => '0');
    -- c1_ddr4_cke      <= (others => '0');
    -- c1_ddr4_odt      <= (others => '0');
    -- c1_ddr4_cs_n     <= (others => '0');
    -- c1_ddr4_ck_t     <= (others => '0');
    -- c1_ddr4_ck_c     <= (others => '0');
    -- c1_ddr4_reset_n  <= '1';
    -- c1_ddr4_dm_dbi_n <= (others => 'Z');
    -- c1_ddr4_dq       <= (others => 'Z');
    -- c1_ddr4_dqs_c    <= (others => 'Z');
    -- c1_ddr4_dqs_t    <= (others => 'Z');
    -- c1_calib_done <= '1';
    -- clkm_1          <= not clkm_1        after 3.2 ns;

    -- c2_ddr4_act_n    <= '1';
    -- c2_ddr4_adr      <= (others => '0');
    -- c2_ddr4_ba       <= (others => '0');
    -- c2_ddr4_bg       <= (others => '0');
    -- c2_ddr4_cke      <= (others => '0');
    -- c2_ddr4_odt      <= (others => '0');
    -- c2_ddr4_cs_n     <= (others => '0');
    -- c2_ddr4_ck_t     <= (others => '0');
    -- c2_ddr4_ck_c     <= (others => '0');
    -- c2_ddr4_reset_n  <= '1';
    -- c2_ddr4_dm_dbi_n <= (others => 'Z');
    -- c2_ddr4_dq       <= (others => 'Z');
    -- c2_ddr4_dqs_c    <= (others => 'Z');
    -- c2_ddr4_dqs_t    <= (others => 'Z');
    -- c2_calib_done <= '1';
    -- clkm_2          <= not clkm_2        after 3.2 ns;

    -- c3_ddr4_act_n    <= '1';
    -- c3_ddr4_adr      <= (others => '0');
    -- c3_ddr4_ba       <= (others => '0');
    -- c3_ddr4_bg       <= (others => '0');
    -- c3_ddr4_cke      <= (others => '0');
    -- c3_ddr4_odt      <= (others => '0');
    -- c3_ddr4_cs_n     <= (others => '0');
    -- c3_ddr4_ck_t     <= (others => '0');
    -- c3_ddr4_ck_c     <= (others => '0');
    -- c3_ddr4_reset_n  <= '1';
    -- c3_ddr4_dm_dbi_n <= (others => 'Z');
    -- c3_ddr4_dq       <= (others => 'Z');
    -- c3_ddr4_dqs_c    <= (others => 'Z');
    -- c3_ddr4_dqs_t    <= (others => 'Z');
    -- c3_calib_done <= '1';
    -- clkm_3          <= not clkm_3        after 3.2 ns;

    -- c4_ddr4_act_n    <= '1';
    -- c4_ddr4_adr      <= (others => '0');
    -- c4_ddr4_ba       <= (others => '0');
    -- c4_ddr4_bg       <= (others => '0');
    -- c4_ddr4_cke      <= (others => '0');
    -- c4_ddr4_odt      <= (others => '0');
    -- c4_ddr4_cs_n     <= (others => '0');
    -- c4_ddr4_ck_t     <= (others => '0');
    -- c4_ddr4_ck_c     <= (others => '0');
    -- c4_ddr4_reset_n  <= '1';
    -- c4_ddr4_dm_dbi_n <= (others => 'Z');
    -- c4_ddr4_dq       <= (others => 'Z');
    -- c4_ddr4_dqs_c    <= (others => 'Z');
    -- c4_ddr4_dqs_t    <= (others => 'Z');
    -- c4_calib_done <= '1';
    -- clkm_4          <= not clkm_4        after 3.2 ns;

    -- c5_ddr4_act_n    <= '1';
    -- c5_ddr4_adr      <= (others => '0');
    -- c5_ddr4_ba       <= (others => '0');
    -- c5_ddr4_bg       <= (others => '0');
    -- c5_ddr4_cke      <= (others => '0');
    -- c5_ddr4_odt      <= (others => '0');
    -- c5_ddr4_cs_n     <= (others => '0');
    -- c5_ddr4_ck_t     <= (others => '0');
    -- c5_ddr4_ck_c     <= (others => '0');
    -- c5_ddr4_reset_n  <= '1';
    -- c5_ddr4_dm_dbi_n <= (others => 'Z');
    -- c5_ddr4_dq       <= (others => 'Z');
    -- c5_ddr4_dqs_c    <= (others => 'Z');
    -- c5_ddr4_dqs_t    <= (others => 'Z');
    -- c5_calib_done <= '1';
    -- clkm_5          <= not clkm_5        after 3.2 ns;

    -- c6_ddr4_act_n    <= '1';
    -- c6_ddr4_adr      <= (others => '0');
    -- c6_ddr4_ba       <= (others => '0');
    -- c6_ddr4_bg       <= (others => '0');
    -- c6_ddr4_cke      <= (others => '0');
    -- c6_ddr4_odt      <= (others => '0');
    -- c6_ddr4_cs_n     <= (others => '0');
    -- c6_ddr4_ck_t     <= (others => '0');
    -- c6_ddr4_ck_c     <= (others => '0');
    -- c6_ddr4_reset_n  <= '1';
    -- c6_ddr4_dm_dbi_n <= (others => 'Z');
    -- c6_ddr4_dq       <= (others => 'Z');
    -- c6_ddr4_dqs_c    <= (others => 'Z');
    -- c6_ddr4_dqs_t    <= (others => 'Z');
    -- c6_calib_done <= '1';
    -- clkm_6          <= not clkm_6        after 3.2 ns;

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

  -- reset_o2 <= rstn;
  -- eth0 : if SIMULATION = false and CFG_GRETH = 1 and BOARD_NUM = 0 generate  -- Gaisler ethernet MAC
  --   e1 : grethm
  --     generic map(
  --       hindex      => CFG_AHB_JTAG,
  --       ehindex     => CFG_AHB_JTAG + 1,
  --       pindex      => 6,
  --       paddr       => 16#800#,
  --       pmask       => 16#f00#,
  --       pirq        => 12,
  --       little_end  => GLOB_CPU_RISCV * CFG_L2_DISABLE,
  --       memtech     => CFG_FABTECH,
  --       enable_mdio => 1,
  --       fifosize    => CFG_ETH_FIFO,
  --       nsync       => 1, -- KL changed from 1 to 2 for stability
  --       edcl        => CFG_DSU_ETH,
  --       edclbufsz   => CFG_ETH_BUF,
  --       macaddrh    => CFG_ETH_ENM,
  --       macaddrl    => CFG_ETH_ENL,
  --       phyrstadr   => 1, -- KL changed from 1 to 0
  --       ipaddrh     => CFG_ETH_IPM,
  --       ipaddrl     => CFG_ETH_IPL,
  --       giga        => CFG_GRETH1G,
  --       edclsepahbg => 1)
  --     port map(
  --       rst    => rstn,
  --       clk    => chip_refclk,
  --       mdcscaler => CPU_FREQ/1000,
  --       ahbmi  => eth0_ahbmi,
  --       ahbmo  => eth0_ahbmo,
  --       eahbmo => edcl_ahbmo,
  --       apbi   => eth0_apbi,
  --       apbo   => eth0_apbo,
  --       ethi   => ethi,
  --       etho   => etho);
  -- end generate;

  ethi.edclsepahb <= '1';

  -- eth pads
  -- eth0_inpads : if (CFG_GRETH = 1 and BOARD_NUM = 0) generate
  --   etxc_pad : clkpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v, arch => 2)
  --     port map (etx_clk, ethi.tx_clk);
  --   erxc_pad : clkpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v, arch => 2)
  --     port map (erx_clk, ethi.rx_clk);
  --   erxd_pad : inpadv generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v, width => 4)
  --     port map (erxd, ethi.rxd(3 downto 0));
  --   erxdv_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --     port map (erx_dv, ethi.rx_dv);
  --   erxer_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --     port map (erx_er, ethi.rx_er);
  --   erxco_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --     port map (erx_col, ethi.rx_col);
  --   erxcr_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --     port map (erx_crs, ethi.rx_crs);
  -- end generate eth0_inpads;

  -- gen_pads : if BOARD_NUM = 0 generate
  --   emdio_pad : iopad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --     port map (emdio, etho.mdio_o, etho.mdio_oe, ethi.mdio_i);
  --   etxd_pad : outpadv generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v, width => 4)
  --     port map (etxd, etho.txd(3 downto 0));
  --   etxen_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --     port map (etx_en, etho.tx_en);
  --   etxer_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --     port map (etx_er, etho.tx_er);
  --   emdc_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --     port map (emdc, etho.mdc);
  -- end generate gen_pads;

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
  chip_rst       <= rstn;
  chip_rst_inv   <= not rstn;
  sys_clk(0)     <= clkm;
  -- sys_clk(1)     <= clkm_1;
  -- sys_clk(2)     <= clkm_2;
  -- sys_clk(3)     <= clkm_3;
  -- sys_clk(4)     <= clkm_4;
  -- sys_clk(5)     <= clkm_5;
  -- sys_clk(6)     <= clkm_6;
--  sys_clk(7)     <= clkm_7;

  -- Leave DDR slot 0 connected to the single satellite DDR controller/model.
  -- Tie off only upper unused slots.
  set_upper_sat_ahbsi : for i in MEM_ID_RANGE_MSB + 1 to MAX_NMEM_TILES-1 generate
      ddr_ahbsi(i) <= ahbs_in_none;
  end generate set_upper_sat_ahbsi;

  -- D2D cable mapping:
  -- c1 cable maps to N on boards 2/3 and S on boards 0/1.
  -- c0 cable maps to W on boards 1/3 and E on boards 0/2.
  gen_d2d_isolated : if (BOARD_NUM = 0) and ISOLATE_BOARD0_D2D generate
    zero_loop : for i in 0 to WIRES_PER_CONNECTION-1 generate
      chiplet_data_n_in(i)    <= (others => '0');
      chiplet_credit_in_n(i)  <= '0';
      chiplet_valid_in_n(i)   <= '0';
      chiplet_data_s_in(i)    <= (others => '0');
      chiplet_credit_in_s(i)  <= '0';
      chiplet_valid_in_s(i)   <= '0';
      chiplet_data_e_in(i)    <= (others => '0');
      chiplet_credit_in_e(i)  <= '0';
      chiplet_valid_in_e(i)   <= '0';
      chiplet_data_w_in(i)    <= (others => '0');
      chiplet_credit_in_w(i)  <= '0';
      chiplet_valid_in_w(i)   <= '0';
    end generate zero_loop;

    c0_d2d_data_tx       <= (others => '0');
    d2d_clk_n_in_int     <= '0';
    d2d_clk_s_in_int     <= '0';
    d2d_clk_w_in_int     <= '0';
    d2d_clk_e_in_int     <= '0';
  end generate gen_d2d_isolated;

  gen_d2d_connected : if not ((BOARD_NUM = 0) and ISOLATE_BOARD0_D2D) generate
    zero_loop : for i in 0 to WIRES_PER_CONNECTION-1 generate
      chiplet_data_n_in(i) <= (others => '0');
      chiplet_credit_in_n(i) <= '0';
      chiplet_valid_in_n(i) <= '0';

      chiplet_data_s_in(i) <= (others => '0');
      chiplet_credit_in_s(i) <= '0';
      chiplet_valid_in_s(i) <= '0';

      chiplet_data_w_in(i) <= c0_d2d_data_rx_iob(65 downto 0) when C0_IS_WEST else (others => '0');
      chiplet_credit_in_w(i) <= c0_credit_in_sync_pulse when C0_IS_WEST else '0';
      chiplet_valid_in_w(i) <= c0_d2d_data_rx_iob(67) when C0_IS_WEST else '0';

      chiplet_data_e_in(i) <= c0_d2d_data_rx_iob(65 downto 0) when not C0_IS_WEST else (others => '0');
      chiplet_credit_in_e(i) <= c0_credit_in_sync_pulse when not C0_IS_WEST else '0';
      chiplet_valid_in_e(i) <= c0_d2d_data_rx_iob(67) when not C0_IS_WEST else '0';

      c0_d2d_data_tx(65 downto 0) <= chiplet_data_w_out(i) when C0_IS_WEST else chiplet_data_e_out(i);
      c0_d2d_data_tx(66) <= chiplet_credit_out_w_sync_pulse(i) when C0_IS_WEST else chiplet_credit_out_e_sync_pulse(i);
      c0_d2d_data_tx(67) <= chiplet_valid_out_w(i) when C0_IS_WEST else chiplet_valid_out_e(i);
    end generate zero_loop;

    d2d_clk_n_in_int <= '0';
    d2d_clk_s_in_int <= '0';
    d2d_clk_w_in_int <= cable_clk_rcv_global_0 when C0_IS_WEST else '0';
    d2d_clk_e_in_int <= cable_clk_rcv_global_0 when not C0_IS_WEST else '0';
  end generate gen_d2d_connected;

  d2dgen_n  : if D2D_CHANNELS_N > 0 generate
    d2d_tx_n  : d2d_tx_top
      generic map (
        TXCHANNELS                  => D2D_CHANNELS_N,
        TILES                       => CFG_XLEN(BOARD_NUM),
        flow_control                => 0,
        chwidth                     => COH_NOC_FLIT_SIZE,
        cohwidth                    => COH_NOC_FLIT_SIZE,
        miscwidth                   => MISC_NOC_FLIT_SIZE,
        dmawidth                    => DMA_NOC_FLIT_SIZE
      )
      port map (
        clk                         => sys_clk(0),
        rst                         => d2d_rst,
        d2d_clk_in                  => d2d_clk_int,
        d2d_snd_data_out            => chiplet_data_n_out,
        d2d_valid_out               => chiplet_valid_out_n,
        d2d_link_ready              => d2d_tx_link_ready_n,
        d2d_credit_in               => chiplet_credit_in_n,
        noc1_data_in                => d2d_noc1_data_in_n,
        noc2_data_in                => d2d_noc2_data_in_n,
        noc3_data_in                => d2d_noc3_data_in_n,
        noc4_data_in                => d2d_noc4_data_in_n,
        noc5_data_in                => d2d_noc5_data_in_n,
        noc6_data_in                => d2d_noc6_data_in_n,
        bypass_data_in              => bypass_data_out(0),
        noc1_data_void_in           => d2d_noc1_data_void_in_n,
        noc2_data_void_in           => d2d_noc2_data_void_in_n,
        noc3_data_void_in           => d2d_noc3_data_void_in_n,
        noc4_data_void_in           => d2d_noc4_data_void_in_n,
        noc5_data_void_in           => d2d_noc5_data_void_in_n,
        noc6_data_void_in           => d2d_noc6_data_void_in_n,
        bypass_data_void_in         => bypass_data_void_out(0),
        noc1_stop_out               => d2d_noc1_stop_out_n,
        noc2_stop_out               => d2d_noc2_stop_out_n,
        noc3_stop_out               => d2d_noc3_stop_out_n,
        noc4_stop_out               => d2d_noc4_stop_out_n,
        noc5_stop_out               => d2d_noc5_stop_out_n,
        noc6_stop_out               => d2d_noc6_stop_out_n,
        bypass_stop_out             => bypass_stop_in(0)
      );

    d2d_rx_n  : d2d_rx_top
      generic map (
        d2d_position                => "00",
        local_chip_y                => chip_yx'(std_logic_vector(to_unsigned(ROW, CHIP_YX_WIDTH))),
        local_chip_x                => chip_yx'(std_logic_vector(to_unsigned(COL, CHIP_YX_WIDTH))),
        max_dim                     => std_logic_vector(to_unsigned(CFG_YLEN(BOARD_NUM), YX_WIDTH)),
        RXCHANNELS                  => D2D_CHANNELS_N,
        TILES                       => CFG_XLEN(BOARD_NUM),
        flow_control                => 0,
        chwidth                     => COH_NOC_FLIT_SIZE,
        cohwidth                    => COH_NOC_FLIT_SIZE,
        miscwidth                   => MISC_NOC_FLIT_SIZE,
        dmawidth                    => DMA_NOC_FLIT_SIZE
      )
      port map (
        clk                         => sys_clk(0),
        rst                         => d2d_rst,
        d2d_clk_in                  => d2d_clk_n_in_int,
        d2d_rcv_data_in             => chiplet_data_n_in,
        d2d_valid_in                => chiplet_valid_in_n,
        d2d_link_ready              => d2d_rx_link_ready_n,
        d2d_credit_out              => chiplet_credit_out_n,
        noc1_data_out               => d2d_noc1_data_out_n,
        noc2_data_out               => d2d_noc2_data_out_n,
        noc3_data_out               => d2d_noc3_data_out_n,
        noc4_data_out               => d2d_noc4_data_out_n,
        noc5_data_out               => d2d_noc5_data_out_n,
        noc6_data_out               => d2d_noc6_data_out_n,
        bypass_data_out             => bypass_data_in(0),
        noc1_data_void_out          => d2d_noc1_data_void_out_n,
        noc2_data_void_out          => d2d_noc2_data_void_out_n,
        noc3_data_void_out          => d2d_noc3_data_void_out_n,
        noc4_data_void_out          => d2d_noc4_data_void_out_n,
        noc5_data_void_out          => d2d_noc5_data_void_out_n,
        noc6_data_void_out          => d2d_noc6_data_void_out_n,
        bypass_data_void_out        => bypass_data_void_in(0),
        noc1_stop_in                => d2d_noc1_stop_in_n,
        noc2_stop_in                => d2d_noc2_stop_in_n,
        noc3_stop_in                => d2d_noc3_stop_in_n,
        noc4_stop_in                => d2d_noc4_stop_in_n,
        noc5_stop_in                => d2d_noc5_stop_in_n,
        noc6_stop_in                => d2d_noc6_stop_in_n,
        bypass_stop_in              => bypass_stop_out(0)
      );
  end generate d2dgen_n;

  no_d2dgen_n : if D2D_CHANNELS_N = 0 generate
  begin
    chiplet_data_n_out <= (others => (others => '0'));
    chiplet_valid_out_n <= (others => '0');
    chiplet_credit_out_n <= (others => '0');
    bypass_data_in(0) <= (others => '0');
    bypass_data_void_in(0) <= '1';
    bypass_stop_in(0) <= '1';
    d2d_tx_link_ready_n <= '1';
    d2d_rx_link_ready_n <= '1';
  end generate no_d2dgen_n;

  d2dgen_s  : if D2D_CHANNELS_S > 0 generate
    d2d_tx_s  : d2d_tx_top
      generic map (
        TXCHANNELS                  => D2D_CHANNELS_S,
        TILES                       => CFG_XLEN(BOARD_NUM),
        flow_control                => 0,
        chwidth                     => COH_NOC_FLIT_SIZE,
        cohwidth                    => COH_NOC_FLIT_SIZE,
        miscwidth                   => MISC_NOC_FLIT_SIZE,
        dmawidth                    => DMA_NOC_FLIT_SIZE
      )
      port map (
        clk                         => sys_clk(0),
        rst                         => d2d_rst,
        d2d_clk_in                  => d2d_clk_int,
        d2d_snd_data_out            => chiplet_data_s_out,
        d2d_valid_out               => chiplet_valid_out_s,
        d2d_link_ready              => d2d_tx_link_ready_s,
        d2d_credit_in               => chiplet_credit_in_s,
        noc1_data_in                => d2d_noc1_data_in_s,
        noc2_data_in                => d2d_noc2_data_in_s,
        noc3_data_in                => d2d_noc3_data_in_s,
        noc4_data_in                => d2d_noc4_data_in_s,
        noc5_data_in                => d2d_noc5_data_in_s,
        noc6_data_in                => d2d_noc6_data_in_s,
        bypass_data_in              => bypass_data_out(1),
        noc1_data_void_in           => d2d_noc1_data_void_in_s,
        noc2_data_void_in           => d2d_noc2_data_void_in_s,
        noc3_data_void_in           => d2d_noc3_data_void_in_s,
        noc4_data_void_in           => d2d_noc4_data_void_in_s,
        noc5_data_void_in           => d2d_noc5_data_void_in_s,
        noc6_data_void_in           => d2d_noc6_data_void_in_s,
        bypass_data_void_in         => bypass_data_void_out(1),
        noc1_stop_out               => d2d_noc1_stop_out_s,
        noc2_stop_out               => d2d_noc2_stop_out_s,
        noc3_stop_out               => d2d_noc3_stop_out_s,
        noc4_stop_out               => d2d_noc4_stop_out_s,
        noc5_stop_out               => d2d_noc5_stop_out_s,
        noc6_stop_out               => d2d_noc6_stop_out_s,
        bypass_stop_out             => bypass_stop_in(1)
      );

    d2d_rx_s  : d2d_rx_top
      generic map (
        d2d_position                => "01",
        local_chip_y                => chip_yx'(std_logic_vector(to_unsigned(ROW, CHIP_YX_WIDTH))),
        local_chip_x                => chip_yx'(std_logic_vector(to_unsigned(COL, CHIP_YX_WIDTH))),
        max_dim                     => std_logic_vector(to_unsigned(CFG_YLEN(BOARD_NUM), YX_WIDTH)),
        RXCHANNELS                  => D2D_CHANNELS_S,
        TILES                       => CFG_XLEN(BOARD_NUM),
        flow_control                => 0,
        chwidth                     => COH_NOC_FLIT_SIZE,
        cohwidth                    => COH_NOC_FLIT_SIZE,
        miscwidth                   => MISC_NOC_FLIT_SIZE,
        dmawidth                    => DMA_NOC_FLIT_SIZE
      )
      port map (
        clk                         => sys_clk(0),
        rst                         => d2d_rst,
        d2d_clk_in                  => d2d_clk_s_in_int,
        d2d_rcv_data_in             => chiplet_data_s_in,
        d2d_valid_in                => chiplet_valid_in_s,
        d2d_link_ready              => d2d_rx_link_ready_s,
        d2d_credit_out              => chiplet_credit_out_s,
        noc1_data_out               => d2d_noc1_data_out_s,
        noc2_data_out               => d2d_noc2_data_out_s,
        noc3_data_out               => d2d_noc3_data_out_s,
        noc4_data_out               => d2d_noc4_data_out_s,
        noc5_data_out               => d2d_noc5_data_out_s,
        noc6_data_out               => d2d_noc6_data_out_s,
        bypass_data_out             => bypass_data_in(1),
        noc1_data_void_out          => d2d_noc1_data_void_out_s,
        noc2_data_void_out          => d2d_noc2_data_void_out_s,
        noc3_data_void_out          => d2d_noc3_data_void_out_s,
        noc4_data_void_out          => d2d_noc4_data_void_out_s,
        noc5_data_void_out          => d2d_noc5_data_void_out_s,
        noc6_data_void_out          => d2d_noc6_data_void_out_s,
        bypass_data_void_out        => bypass_data_void_in(1),
        noc1_stop_in                => d2d_noc1_stop_in_s,
        noc2_stop_in                => d2d_noc2_stop_in_s,
        noc3_stop_in                => d2d_noc3_stop_in_s,
        noc4_stop_in                => d2d_noc4_stop_in_s,
        noc5_stop_in                => d2d_noc5_stop_in_s,
        noc6_stop_in                => d2d_noc6_stop_in_s,
        bypass_stop_in              => bypass_stop_out(1)
      );
  end generate d2dgen_s;

  no_d2dgen_s : if D2D_CHANNELS_S = 0 generate
  begin
    chiplet_data_s_out <= (others => (others => '0'));
    chiplet_valid_out_s <= (others => '0');
    chiplet_credit_out_s <= (others => '0');
    bypass_data_in(1) <= (others => '0');
    bypass_data_void_in(1) <= '1';
    bypass_stop_in(1) <= '1';
    d2d_tx_link_ready_s <= '1';
    d2d_rx_link_ready_s <= '1';
  end generate no_d2dgen_s;

  d2dgen_e  : if D2D_CHANNELS_E > 0 generate
    d2d_tx_e  : d2d_tx_top
      generic map (
        TXCHANNELS                  => D2D_CHANNELS_E,
        TILES                       => CFG_YLEN(BOARD_NUM),
        flow_control                => 0,
        chwidth                     => COH_NOC_FLIT_SIZE,
        cohwidth                    => COH_NOC_FLIT_SIZE,
        miscwidth                   => MISC_NOC_FLIT_SIZE,
        dmawidth                    => DMA_NOC_FLIT_SIZE
      )
      port map (
        clk                         => sys_clk(0),
        rst                         => d2d_rst,
        d2d_clk_in                  => d2d_clk_int,
        d2d_snd_data_out            => chiplet_data_e_out,
        d2d_valid_out               => chiplet_valid_out_e,
        d2d_link_ready              => d2d_tx_link_ready_e,
        d2d_credit_in               => chiplet_credit_in_e,
        noc1_data_in                => d2d_noc1_data_in_e,
        noc2_data_in                => d2d_noc2_data_in_e,
        noc3_data_in                => d2d_noc3_data_in_e,
        noc4_data_in                => d2d_noc4_data_in_e,
        noc5_data_in                => d2d_noc5_data_in_e,
        noc6_data_in                => d2d_noc6_data_in_e,
        bypass_data_in              => bypass_data_out(3),
        noc1_data_void_in           => d2d_noc1_data_void_in_e,
        noc2_data_void_in           => d2d_noc2_data_void_in_e,
        noc3_data_void_in           => d2d_noc3_data_void_in_e,
        noc4_data_void_in           => d2d_noc4_data_void_in_e,
        noc5_data_void_in           => d2d_noc5_data_void_in_e,
        noc6_data_void_in           => d2d_noc6_data_void_in_e,
        bypass_data_void_in         => bypass_data_void_out(3),
        noc1_stop_out               => d2d_noc1_stop_out_e,
        noc2_stop_out               => d2d_noc2_stop_out_e,
        noc3_stop_out               => d2d_noc3_stop_out_e,
        noc4_stop_out               => d2d_noc4_stop_out_e,
        noc5_stop_out               => d2d_noc5_stop_out_e,
        noc6_stop_out               => d2d_noc6_stop_out_e,
        bypass_stop_out             => bypass_stop_in(3)
      );

    d2d_rx_e  : d2d_rx_top
      generic map (
        d2d_position                => "11",
        local_chip_y                => chip_yx'(std_logic_vector(to_unsigned(ROW, CHIP_YX_WIDTH))),
        local_chip_x                => chip_yx'(std_logic_vector(to_unsigned(COL, CHIP_YX_WIDTH))),
        max_dim                     => std_logic_vector(to_unsigned(CFG_XLEN(BOARD_NUM), YX_WIDTH)),
        RXCHANNELS                  => D2D_CHANNELS_E,
        TILES                       => CFG_YLEN(BOARD_NUM),
        flow_control                => 0,
        chwidth                     => COH_NOC_FLIT_SIZE,
        cohwidth                    => COH_NOC_FLIT_SIZE,
        miscwidth                   => MISC_NOC_FLIT_SIZE,
        dmawidth                    => DMA_NOC_FLIT_SIZE
      )
      port map (
        clk                         => sys_clk(0),
        rst                         => d2d_rst,
        d2d_clk_in                  => d2d_clk_e_in_int,
        d2d_rcv_data_in             => chiplet_data_e_in,
        d2d_valid_in                => chiplet_valid_in_e,
        d2d_link_ready              => d2d_rx_link_ready_e,
        d2d_credit_out              => chiplet_credit_out_e,
        noc1_data_out               => d2d_noc1_data_out_e,
        noc2_data_out               => d2d_noc2_data_out_e,
        noc3_data_out               => d2d_noc3_data_out_e,
        noc4_data_out               => d2d_noc4_data_out_e,
        noc5_data_out               => d2d_noc5_data_out_e,
        noc6_data_out               => d2d_noc6_data_out_e,
        bypass_data_out             => bypass_data_in(3),
        noc1_data_void_out          => d2d_noc1_data_void_out_e,
        noc2_data_void_out          => d2d_noc2_data_void_out_e,
        noc3_data_void_out          => d2d_noc3_data_void_out_e,
        noc4_data_void_out          => d2d_noc4_data_void_out_e,
        noc5_data_void_out          => d2d_noc5_data_void_out_e,
        noc6_data_void_out          => d2d_noc6_data_void_out_e,
        bypass_data_void_out        => bypass_data_void_in(3),
        noc1_stop_in                => d2d_noc1_stop_in_e,
        noc2_stop_in                => d2d_noc2_stop_in_e,
        noc3_stop_in                => d2d_noc3_stop_in_e,
        noc4_stop_in                => d2d_noc4_stop_in_e,
        noc5_stop_in                => d2d_noc5_stop_in_e,
        noc6_stop_in                => d2d_noc6_stop_in_e,
        bypass_stop_in              => bypass_stop_out(3)
      );
  end generate d2dgen_e;

  no_d2dgen_e : if D2D_CHANNELS_E = 0 generate
  begin
    chiplet_data_e_out <= (others => (others => '0'));
    chiplet_valid_out_e <= (others => '0');
    chiplet_credit_out_e <= (others => '0');
    bypass_data_in(3) <= (others => '0');
    bypass_data_void_in(3) <= '1';
    bypass_stop_in(3) <= '1';
    d2d_tx_link_ready_e <= '1';
    d2d_rx_link_ready_e <= '1';
  end generate no_d2dgen_e;

  d2dgen_w  : if D2D_CHANNELS_W > 0 generate
    d2d_tx_w  : d2d_tx_top
      generic map (
        TXCHANNELS                  => D2D_CHANNELS_W,
        TILES                       => CFG_YLEN(BOARD_NUM),
        flow_control                => 0,
        chwidth                     => COH_NOC_FLIT_SIZE,
        cohwidth                    => COH_NOC_FLIT_SIZE,
        miscwidth                   => MISC_NOC_FLIT_SIZE,
        dmawidth                    => DMA_NOC_FLIT_SIZE
      )
      port map (
        clk                         => sys_clk(0),
        rst                         => d2d_rst,
        d2d_clk_in                  => d2d_clk_int,
        d2d_snd_data_out            => chiplet_data_w_out,
        d2d_valid_out               => chiplet_valid_out_w,
        d2d_link_ready              => d2d_tx_link_ready_w,
        d2d_credit_in               => chiplet_credit_in_w,
        noc1_data_in                => d2d_noc1_data_in_w,
        noc2_data_in                => d2d_noc2_data_in_w,
        noc3_data_in                => d2d_noc3_data_in_w,
        noc4_data_in                => d2d_noc4_data_in_w,
        noc5_data_in                => d2d_noc5_data_in_w,
        noc6_data_in                => d2d_noc6_data_in_w,
        bypass_data_in              => bypass_data_out(2),
        noc1_data_void_in           => d2d_noc1_data_void_in_w,
        noc2_data_void_in           => d2d_noc2_data_void_in_w,
        noc3_data_void_in           => d2d_noc3_data_void_in_w,
        noc4_data_void_in           => d2d_noc4_data_void_in_w,
        noc5_data_void_in           => d2d_noc5_data_void_in_w,
        noc6_data_void_in           => d2d_noc6_data_void_in_w,
        bypass_data_void_in         => bypass_data_void_out(2),
        noc1_stop_out               => d2d_noc1_stop_out_w,
        noc2_stop_out               => d2d_noc2_stop_out_w,
        noc3_stop_out               => d2d_noc3_stop_out_w,
        noc4_stop_out               => d2d_noc4_stop_out_w,
        noc5_stop_out               => d2d_noc5_stop_out_w,
        noc6_stop_out               => d2d_noc6_stop_out_w,
        bypass_stop_out             => bypass_stop_in(2)
      );

    d2d_rx_w  : d2d_rx_top
      generic map (
        d2d_position                => "10",
        local_chip_y                => chip_yx'(std_logic_vector(to_unsigned(ROW, CHIP_YX_WIDTH))),
        local_chip_x                => chip_yx'(std_logic_vector(to_unsigned(COL, CHIP_YX_WIDTH))),
        max_dim                     => std_logic_vector(to_unsigned(CFG_XLEN(BOARD_NUM), YX_WIDTH)),
        RXCHANNELS                  => D2D_CHANNELS_W,
        TILES                       => CFG_YLEN(BOARD_NUM),
        flow_control                => 0,
        chwidth                     => COH_NOC_FLIT_SIZE,
        cohwidth                    => COH_NOC_FLIT_SIZE,
        miscwidth                   => MISC_NOC_FLIT_SIZE,
        dmawidth                    => DMA_NOC_FLIT_SIZE
      )
      port map (
        clk                         => sys_clk(0),
        rst                         => d2d_rst,
        d2d_clk_in                  => d2d_clk_w_in_int,
        d2d_rcv_data_in             => chiplet_data_w_in,
        d2d_valid_in                => chiplet_valid_in_w,
        d2d_link_ready              => d2d_rx_link_ready_w,
        d2d_credit_out              => chiplet_credit_out_w,
        noc1_data_out               => d2d_noc1_data_out_w,
        noc2_data_out               => d2d_noc2_data_out_w,
        noc3_data_out               => d2d_noc3_data_out_w,
        noc4_data_out               => d2d_noc4_data_out_w,
        noc5_data_out               => d2d_noc5_data_out_w,
        noc6_data_out               => d2d_noc6_data_out_w,
        bypass_data_out             => bypass_data_in(2),
        noc1_data_void_out          => d2d_noc1_data_void_out_w,
        noc2_data_void_out          => d2d_noc2_data_void_out_w,
        noc3_data_void_out          => d2d_noc3_data_void_out_w,
        noc4_data_void_out          => d2d_noc4_data_void_out_w,
        noc5_data_void_out          => d2d_noc5_data_void_out_w,
        noc6_data_void_out          => d2d_noc6_data_void_out_w,
        bypass_data_void_out        => bypass_data_void_in(2),
        noc1_stop_in                => d2d_noc1_stop_in_w,
        noc2_stop_in                => d2d_noc2_stop_in_w,
        noc3_stop_in                => d2d_noc3_stop_in_w,
        noc4_stop_in                => d2d_noc4_stop_in_w,
        noc5_stop_in                => d2d_noc5_stop_in_w,
        noc6_stop_in                => d2d_noc6_stop_in_w,
        bypass_stop_in              => bypass_stop_out(2)
      );
  end generate d2dgen_w;

  no_d2dgen_w : if D2D_CHANNELS_W = 0 generate
  begin
    chiplet_data_w_out <= (others => (others => '0'));
    chiplet_valid_out_w <= (others => '0');
    chiplet_credit_out_w <= (others => '0');
    bypass_data_in(2) <= (others => '0');
    bypass_data_void_in(2) <= '1';
    bypass_stop_in(2) <= '1';
    d2d_tx_link_ready_w <= '1';
    d2d_rx_link_ready_w <= '1';
  end generate no_d2dgen_w;

  bypass_router_i : bypass_router
    generic map (
      flow_control                => 0,
      width                       => COH_NOC_FLIT_SIZE,
      depth                       => 4,
      ports                       => bypass_ports,
      DEST_SIZE                   => 1)
    port map (
      clk                         => sys_clk(0),
      rst                         => chip_rst_inv,
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
      rst         => chip_rst,
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
