-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

------------------------------------------------------------------------------
--  ESP - profpga - TA1 - xcvu440
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
    esp_clk_p         : in    std_ulogic;  -- 78.25 MHz clock
    esp_clk_n         : in    std_ulogic;  -- 78.25 MHz clock

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
    tft_nhpd          : in    std_ulogic;  -- Hot plug
    tft_clk_p         : out   std_ulogic;
    tft_clk_n         : out   std_ulogic;
    tft_data          : out   std_logic_vector(23 downto 0);
    tft_hsync         : out   std_ulogic;
    tft_vsync         : out   std_ulogic;
    tft_de            : out   std_ulogic;
    tft_dken          : out   std_ulogic;
    tft_ctl1_a1_dk1   : out   std_ulogic;
    tft_ctl2_a2_dk2   : out   std_ulogic;
    tft_a3_dk3        : out   std_ulogic;
    tft_isel          : out   std_ulogic;
    tft_bsel          : out   std_logic;
    tft_dsel          : out   std_logic;
    tft_edge          : out   std_ulogic;
    tft_npd           : out   std_ulogic;

    LED_RED    : out std_ulogic;
    LED_GREEN  : out std_ulogic;
    LED_BLUE   : out std_ulogic;
    LED_YELLOW : out std_ulogic
    );
end;


architecture rtl of top is
  -- multiple of [45 / CLKOUT0_DIVIDE_F] = [45 / 10.000] = 4.500
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
      noc1_data_out      : out coh_noc_flit_vector(TILES-1 downto 0);
      noc2_data_out      : out coh_noc_flit_vector(TILES-1 downto 0);
      noc3_data_out      : out coh_noc_flit_vector(TILES-1 downto 0);
      noc4_data_out      : out dma_noc_flit_vector(TILES-1 downto 0);
      noc5_data_out      : out misc_noc_flit_vector(TILES-1 downto 0);
      noc6_data_out      : out dma_noc_flit_vector(TILES-1 downto 0);
      bypass_data_out    : out coh_noc_flit_type;
      
      noc1_data_void_out : out std_logic_vector(TILES-1 downto 0);
      noc2_data_void_out : out std_logic_vector(TILES-1 downto 0);
      noc3_data_void_out : out std_logic_vector(TILES-1 downto 0);
      noc4_data_void_out : out std_logic_vector(TILES-1 downto 0);
      noc5_data_void_out : out std_logic_vector(TILES-1 downto 0);
      noc6_data_void_out : out std_logic_vector(TILES-1 downto 0);
      bypass_data_void_out  : out std_logic;
      
      -- NoC --> D2D
      noc1_stop_in       : in  std_logic_vector(TILES-1 downto 0);
      noc2_stop_in       : in  std_logic_vector(TILES-1 downto 0);
      noc3_stop_in       : in  std_logic_vector(TILES-1 downto 0);
      noc4_stop_in       : in  std_logic_vector(TILES-1 downto 0);
      noc5_stop_in       : in  std_logic_vector(TILES-1 downto 0);
      noc6_stop_in       : in  std_logic_vector(TILES-1 downto 0);
      bypass_stop_in     : in  std_logic
    );
  end component d2d_rx_top;
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

  function set_ddr_index (
    constant n : integer range 0 to 3)
    return integer is
  begin
    if n > (MEM_ID_RANGE_MSB) then
      return MEM_ID_RANGE_MSB;
    else
      return n;
    end if;
  end set_ddr_index;

  constant this_ddr_index : attribute_vector(0 to 3) := (
    0 => set_ddr_index(0),
    1 => set_ddr_index(1),
    2 => set_ddr_index(2),
    3 => set_ddr_index(3)
    );
  constant diagnostic_pending_max : unsigned(11 downto 0) := (others => '1');

-- clock and reset
  signal clkm, clkm_1, clkm_2, clkm_3                   : std_ulogic := '0';
  signal clkm_sync_rst, clkm_sync_rst_1, clkm_sync_rst_2, clkm_sync_rst_3                 : std_ulogic;
  signal d2d_rstn, d2d_rst, rstn, rstraw, rstraw_1, rstraw_2, rstraw_3     : std_ulogic;
  signal lock, rst                                      : std_ulogic;
  signal migrstn, migrstn_1, migrstn_2, migrstn_3       : std_logic;
  signal cgi                                            : clkgen_in_type;
  signal cgo                                            : clkgen_out_type;

---mig signals
  signal c0_calib_done        : std_ulogic;
  signal c0_diagnostic_count  : std_logic_vector(26 downto 0);
  signal c0_diagnostic_toggle : std_ulogic;
  signal c1_calib_done        : std_ulogic;
  signal c1_diagnostic_count  : std_logic_vector(26 downto 0);
  signal c1_diagnostic_toggle : std_ulogic;
  signal c2_calib_done        : std_ulogic;
  signal c2_diagnostic_count  : unsigned(26 downto 0) := (others => '0');
  signal c2_diagnostic_pending : unsigned(11 downto 0) := (others => '0');
  signal c2_diagnostic_phase_prev : std_ulogic := '0';
  signal c2_diagnostic_toggle : std_ulogic;
  signal c3_calib_done        : std_ulogic;
  signal c3_diagnostic_count  : unsigned(26 downto 0) := (others => '0');
  signal c3_diagnostic_pending : unsigned(11 downto 0) := (others => '0');
  signal c3_diagnostic_phase_prev : std_ulogic := '0';
  signal c3_diagnostic_toggle : std_ulogic;
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

constant MAX_NMEM_TILES : integer := 4;
-- Memory controller DDR4
  signal ddr_ahbsi : ahb_slv_in_vector_type(0 to MAX_NMEM_TILES - 1);
  signal ddr_ahbso : ahb_slv_out_vector_type(0 to MAX_NMEM_TILES - 1);

-- Ethernet
constant CPU_FREQ : integer := 78125;  -- cpu frequency in KHz

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
  signal chip_rst       : std_ulogic;
  signal chip_rst_inv   : std_ulogic;
  signal d2d_rx_clocks_locked : std_ulogic;
  signal d2d_ready      : std_ulogic;
  signal d2d_ready_sync : std_ulogic := '0';
  signal d2d_ready_sync_1 : std_ulogic := '0';
  signal d2d_startup_done : std_ulogic := '0';
  signal sys_clk        : std_logic_vector(0 to MAX_NMEM_TILES - 1);
  signal esp_clk        : std_ulogic;
  signal chip_refclk    : std_ulogic;

  attribute keep of clkm        : signal is true;
  attribute keep of clkm_1      : signal is true;
  attribute keep of clkm_2      : signal is true;
  attribute keep of clkm_3      : signal is true;
  attribute keep of chip_refclk : signal is true;

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

-- MMI64
  signal user_rstn      : std_ulogic;
  signal mon_ddr        : monitor_ddr_vector(0 to MEM_ID_RANGE_MSB);
  signal mon_ddr_reg    : monitor_ddr_vector(0 to MEM_ID_RANGE_MSB);
  signal mon_noc        : monitor_noc_matrix(1 to 6, 0 to CFG_CHIPLET_TILES(BOARD_NUM)-1);
  signal mon_noc_actual : monitor_noc_matrix(0 to 1, 0 to CFG_CHIPLET_TILES(BOARD_NUM)-1);
  signal mon_mem        : monitor_mem_vector(0 to CFG_NMEM_TILE_CHIPLET(BOARD_NUM) + CFG_NSLM_TILE_CHIPLET(BOARD_NUM) + CFG_NSLMDDR_TILE_CHIPLET(BOARD_NUM) - 1);
  signal mon_mem_reg    : monitor_mem_vector(0 to CFG_NMEM_TILE_CHIPLET(BOARD_NUM) + CFG_NSLM_TILE_CHIPLET(BOARD_NUM) + CFG_NSLMDDR_TILE_CHIPLET(BOARD_NUM) - 1);
  signal mon_l2         : monitor_cache_vector(0 to relu(CFG_NL2_CHIPLET(BOARD_NUM) - 1));
  signal mon_llc        : monitor_cache_vector(0 to relu(CFG_NLLC_CHIPLET(BOARD_NUM) - 1));
  signal mon_acc        : monitor_acc_vector(0 to relu(CFG_NACC_TILE_CHIPLET(BOARD_NUM)-1));
  signal mon_dvfs       : monitor_dvfs_vector(0 to CFG_CHIPLET_TILES(BOARD_NUM)-1);

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

  -- c1_credit_evt_src : process (cable_clk_rcv_global_1)
  -- begin
  --   if rising_edge(cable_clk_rcv_global_1) then
  --     if d2d_rstn = '0' or d2d_rx_mmcm_locked1 = '0' then
  --       c1_credit_in_evt_bin_src <= (others => '0');
  --     elsif c1_d2d_data_rx_iob(66) = '1' then
  --       c1_credit_in_evt_bin_src <= c1_credit_in_evt_bin_src + 1;
  --     end if;
  --   end if;
  -- end process c1_credit_evt_src;

  -- Lossless credit CDC across asynchronous domains.
  c0_credit_in_evt_gray_src <= bin2gray(c0_credit_in_evt_bin_src);
  -- c1_credit_in_evt_gray_src <= bin2gray(c1_credit_in_evt_bin_src);
  chiplet_credit_out_n_evt_gray_src <= bin2gray(chiplet_credit_out_n_evt_bin_src);
  chiplet_credit_out_s_evt_gray_src <= bin2gray(chiplet_credit_out_s_evt_bin_src);
  chiplet_credit_out_w_evt_gray_src <= bin2gray(chiplet_credit_out_w_evt_bin_src);
  chiplet_credit_out_e_evt_gray_src <= bin2gray(chiplet_credit_out_e_evt_bin_src);

  chiplet_credit_out_n_inc <= slv_popcount(chiplet_credit_out_n);
  chiplet_credit_out_s_inc <= slv_popcount(chiplet_credit_out_s);
  chiplet_credit_out_w_inc <= slv_popcount(chiplet_credit_out_w);
  chiplet_credit_out_e_inc <= slv_popcount(chiplet_credit_out_e);

  c0_credit_in_evt_bin_sync <= gray2bin(c0_credit_in_evt_gray_ff2);
  -- c1_credit_in_evt_bin_sync <= gray2bin(c1_credit_in_evt_gray_ff2);
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
        -- c1_credit_in_evt_gray_ff1 <= (others => '0');
        -- c1_credit_in_evt_gray_ff2 <= (others => '0');
        chiplet_credit_out_n_evt_gray_ff1 <= (others => '0');
        chiplet_credit_out_n_evt_gray_ff2 <= (others => '0');
        chiplet_credit_out_s_evt_gray_ff1 <= (others => '0');
        chiplet_credit_out_s_evt_gray_ff2 <= (others => '0');
        chiplet_credit_out_w_evt_gray_ff1 <= (others => '0');
        chiplet_credit_out_w_evt_gray_ff2 <= (others => '0');
        chiplet_credit_out_e_evt_gray_ff1 <= (others => '0');
        chiplet_credit_out_e_evt_gray_ff2 <= (others => '0');

        c0_credit_in_evt_bin_seen <= (others => '0');
        -- c1_credit_in_evt_bin_seen <= (others => '0');
        chiplet_credit_out_n_evt_bin_seen <= (others => '0');
        chiplet_credit_out_s_evt_bin_seen <= (others => '0');
        chiplet_credit_out_w_evt_bin_seen <= (others => '0');
        chiplet_credit_out_e_evt_bin_seen <= (others => '0');

        c0_credit_in_pending <= (others => '0');
        -- c1_credit_in_pending <= (others => '0');
        chiplet_credit_out_n_pending <= (others => '0');
        chiplet_credit_out_s_pending <= (others => '0');
        chiplet_credit_out_w_pending <= (others => '0');
        chiplet_credit_out_e_pending <= (others => '0');

        c0_credit_in_sync_pulse <= '0';
        -- c1_credit_in_sync_pulse <= '0';
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
        -- drain_credit_evt(
        --   c1_credit_in_evt_bin_seen,
        --   c1_credit_in_pending,
        --   c1_credit_in_sync_pulse,
        --   c1_credit_in_evt_bin_sync
        -- );
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
          O   => open,                         -- TX path does not need readback
          IO  => c0_cable_io_data(i + 68),     -- Map to upper half (68..135)
          I   => c0_d2d_data_tx_io(i),
          T   => '0'                           -- Drive output
        );
      rx_iobuf_0 : IOBUF
        port map (
          O   => c0_d2d_data_rx_io(i),
          IO  => c0_cable_io_data(i),
          I   => '0',
          T   => '1'                           -- High-Z on RX direction
        );
    end generate gen_bufs;
  end generate gen_board_io_cable_0;

  -- gen_board_io_cable_1 : if BOARD_NUM = 0 or BOARD_NUM = 1 generate
  --   gen_bufs_1 : for i in 0 to 67 generate
  --     tx_iobuf_1 : IOBUF
  --       port map (
  --         O   => open,                         -- TX path does not need readback
  --         IO  => c1_cable_io_data(i + 68),     -- Map to upper half (68..135)
  --         I   => c1_d2d_data_tx_io(i),
  --         T   => '0'                           -- Drive output
  --       );
  --     rx_iobuf_1 : IOBUF
  --       port map (
  --         O   => c1_d2d_data_rx_io(i),
  --         IO  => c1_cable_io_data(i),
  --         I   => '0',
  --         T   => '1'                           -- High-Z on RX direction
  --       );
  --   end generate gen_bufs_1;
  -- end generate gen_board_io_cable_1;

  gen_board_io_cable_2 : if BOARD_NUM = 1 or BOARD_NUM = 3 generate
    gen_bufs : for i in 0 to 67 generate
      tx_iobuf_0 : IOBUF
        port map (
          O   => open,                         -- TX path does not need readback
          IO  => c0_cable_io_data(i),          -- Map to lower half (0..67)
          I   => c0_d2d_data_tx_io(i),
          T   => '0'                           -- Drive output
        );
      rx_iobuf_0 : IOBUF
        port map (
          O   => c0_d2d_data_rx_io(i),
          IO  => c0_cable_io_data(i + 68),
          I   => '0',
          T   => '1'                           -- High-Z on RX direction
        );
    end generate gen_bufs;
  end generate gen_board_io_cable_2;

  -- gen_board_io_cable_3 : if BOARD_NUM = 2 or BOARD_NUM = 3 generate
  --   gen_bufs_1 : for i in 0 to 67 generate
  --     tx_iobuf_1 : IOBUF
  --       port map (
  --         O   => open,                         -- TX path does not need readback
  --         IO  => c1_cable_io_data(i),          -- Map to lower half (0..67)
  --         I   => c1_d2d_data_tx_io(i),
  --         T   => '0'                           -- Drive output
  --       );
  --     rx_iobuf_1 : IOBUF
  --       port map (
  --         O   => c1_d2d_data_rx_io(i),
  --         IO  => c1_cable_io_data(i + 68),
  --         I   => '0',
  --         T   => '1'                           -- High-Z on RX direction
  --       );
  --   end generate gen_bufs_1;
  -- end generate gen_board_io_cable_3;

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
  -- cable_clk_fwd_int_1 <= d2d_clk_int;

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
      -- c1_d2d_data_tx_io <= c1_d2d_data_tx;
    end if;
  end process d2d_tx_sdr_regs;

  inst_obufds_clk_0 : OBUFDS
    generic map (
      IOSTANDARD  => "LVDS"
    )
    port map (
      I   => cable_clk_fwd_int_0,  -- Forwarded clock from the D2D clock domain (d2d_clk_int)
      O   => c0_cable_clk_p,
      OB  => c0_cable_clk_n
    );

  -- inst_obufds_clk_1 : OBUFDS
  --   generic map (
  --     IOSTANDARD  => "LVDS"
  --   )
  --   port map (
  --     I   => cable_clk_fwd_int_1,  -- Forwarded clock from the D2D clock domain (d2d_clk_int)
  --     O   => c1_cable_clk_p,
  --     OB  => c1_cable_clk_n
  --   );

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
      -- Tune this phase as the RX capture alignment knob for cable 0.
      CLKOUT0_PHASE        => D2D_RX_MMCM_PHASE_DEG_C0,
      CLKIN1_PERIOD        => D2D_RX_MMCM_CLKIN_PERIOD_NS
      )
    port map (
      CLKIN1   => cable_clk_rcv_raw_0,
      CLKIN2   => '0',
      CLKINSEL => '1',
      RST      => rst,         -- RX capture clock must come up before D2D-ready can assert
      PWRDWN   => '0',
      
      -- Zero-Delay Feedback Loop
      CLKFBOUT => d2d_rx_mmcm_clkfb_out0,
      CLKFBIN  => d2d_rx_mmcm_clkfb_in0,
      
      -- Output and Lock Status
      CLKOUT0  => d2d_rx_mmcm_clk_out0,
      LOCKED   => d2d_rx_mmcm_locked0,

      -- Tie off unused pins
      DADDR => (others => '0'), DCLK => '0', DEN => '0', DI => (others => '0'),
      DWE => '0', PSCLK => '0', PSEN => '0', PSINCDEC => '0', CDDCREQ => '0'
    );

  -- Feedback Global Clock Buffer
  inst_bufg_fb_0 : BUFG
    port map ( I => d2d_rx_mmcm_clkfb_out0, O => d2d_rx_mmcm_clkfb_in0 );

  -- Output Global Clock Buffer (This is your deskewed RX clock)
  inst_bufg_out_0 : BUFG
    port map ( I => d2d_rx_mmcm_clk_out0, O => cable_clk_rcv_global_0 );

  -- inst_ibufds_rcv_1 : IBUFDS
  --   generic map (
  --     DIFF_TERM     => TRUE,
  --     IBUF_LOW_PWR  => FALSE,
  --     IOSTANDARD    => "LVDS"
  --   )
  --   port map (
  --     I   => c1_cable_clk_p_rcv,
  --     IB  => c1_cable_clk_n_rcv,
  --     O   => cable_clk_rcv_raw_1
  --   );

  -- inst_mmcm_rcv_1 : MMCME4_ADV
  --   generic map (
  --     BANDWIDTH            => "OPTIMIZED",
  --     COMPENSATION         => "ZHOLD", 
  --     DIVCLK_DIVIDE        => 1,
  --     CLKFBOUT_MULT_F      => 10.000,
  --     CLKOUT0_DIVIDE_F     => 10.000,
  --     -- Tune this phase as the RX capture alignment knob for cable 1.
  --     CLKOUT0_PHASE        => D2D_RX_MMCM_PHASE_DEG_C1,
  --     CLKIN1_PERIOD        => D2D_RX_MMCM_CLKIN_PERIOD_NS
  --   )
  --   port map (
  --     CLKIN1   => cable_clk_rcv_raw_1,
  --     CLKIN2   => '0',
  --     CLKINSEL => '1',
  --     RST      => rst,         -- RX capture clock must come up before D2D-ready can assert
  --     PWRDWN   => '0',
      
  --     -- Zero-Delay Feedback Loop
  --     CLKFBOUT => d2d_rx_mmcm_clkfb_out1,
  --     CLKFBIN  => d2d_rx_mmcm_clkfb_in1,
      
  --     -- Output and Lock Status
  --     CLKOUT0  => d2d_rx_mmcm_clk_out1,
  --     LOCKED   => d2d_rx_mmcm_locked1,

  --     -- Tie off unused pins
  --     DADDR => (others => '0'), DCLK => '0', DEN => '0', DI => (others => '0'),
  --     DWE => '0', PSCLK => '0', PSEN => '0', PSINCDEC => '0', CDDCREQ => '0'
  --   );

  -- -- Feedback Global Clock Buffer
  -- inst_bufg_fb_1 : BUFG
  --   port map ( I => d2d_rx_mmcm_clkfb_out1, O => d2d_rx_mmcm_clkfb_in1 );

  -- -- Output Global Clock Buffer (This is your deskewed RX clock)
  -- inst_bufg_out_1 : BUFG
  --   port map ( I => d2d_rx_mmcm_clk_out1, O => cable_clk_rcv_global_1 );

  c0_diagnostic : process (d2d_clk_int, rst)
  begin  -- D2D TX source clock activity
    if rst = '1' then
      c0_diagnostic_count <= (others => '0');
    elsif d2d_clk_int'event and d2d_clk_int = '1' then
      c0_diagnostic_count <= c0_diagnostic_count + 1;
    end if;
  end process c0_diagnostic;
  c0_diagnostic_toggle <= c0_diagnostic_count(26);
  c0_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c0_diagnostic_led, c0_diagnostic_toggle);

  c1_diagnostic : process (cable_clk_rcv_global_0, rst)
  begin  -- Recovered RX clock activity on D2D cable 0
    if rst = '1' then
      c1_diagnostic_count <= (others => '0');
    elsif cable_clk_rcv_global_0'event and cable_clk_rcv_global_0 = '1' then
      c1_diagnostic_count <= c1_diagnostic_count + 1;
    end if;
  end process c1_diagnostic;
  c1_diagnostic_toggle <= c1_diagnostic_count(26);
  c1_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c1_diagnostic_led, c1_diagnostic_toggle);

  -- Previous fixed-rate c2 diagnostic kept for reference.
  -- c2_diagnostic : process (clkm_2, clkm_sync_rst_2)
  -- begin  -- Recovered RX clock activity on D2D cable 0
  --   if rst = '1' then
  --     c2_diagnostic_count <= (others => '0');
  --   elsif clkm_2'event and clkm_2 = '1' then
  --     c2_diagnostic_count <= c2_diagnostic_count + 1;
  --   end if;
  -- end process c2_diagnostic;
  -- c2_diagnostic_toggle <= c2_diagnostic_count(26);

  -- Previous wide queued c2 diagnostic kept for reference.
  -- c2_diagnostic : process (cable_clk_rcv_global_0)
  --   variable next_c2_pending : unsigned(c2_diagnostic_pending'range);
  -- begin
  --   if rising_edge(cable_clk_rcv_global_0) then
  --     if d2d_rstn = '0' or d2d_rx_mmcm_locked0 = '0' then
  --       c2_diagnostic_count <= (others => '0');
  --       c2_diagnostic_pending <= (others => '0');
  --       c2_diagnostic_phase_prev <= '0';
  --     else
  --       c2_diagnostic_count <= c2_diagnostic_count + 1;
  --
  --       next_c2_pending := c2_diagnostic_pending;
  --       if c0_d2d_data_rx_iob(66) = '1' then
  --         next_c2_pending := next_c2_pending + 1;
  --       end if;
  --
  --       if c2_diagnostic_phase_prev = '1' and c2_diagnostic_count(26) = '0' and next_c2_pending /= 0 then
  --         next_c2_pending := next_c2_pending - 1;
  --       end if;
  --
  --       c2_diagnostic_pending <= next_c2_pending;
  --       c2_diagnostic_phase_prev <= c2_diagnostic_count(26);
  --     end if;
  --   end if;
  -- end process c2_diagnostic;

  c2_diagnostic_phase : process (cable_clk_rcv_global_0)
  begin
    if rising_edge(cable_clk_rcv_global_0) then
      if d2d_rstn = '0' or d2d_rx_mmcm_locked0 = '0' then
        c2_diagnostic_count <= (others => '0');
        c2_diagnostic_phase_prev <= '0';
      else
        c2_diagnostic_phase_prev <= c2_diagnostic_count(26);
        c2_diagnostic_count <= c2_diagnostic_count + 1;
      end if;
    end if;
  end process c2_diagnostic_phase;

  c2_diagnostic_pending_q : process (cable_clk_rcv_global_0)
    variable next_c2_pending : unsigned(c2_diagnostic_pending'range);
  begin
    if rising_edge(cable_clk_rcv_global_0) then
      if d2d_rstn = '0' or d2d_rx_mmcm_locked0 = '0' then
        c2_diagnostic_pending <= (others => '0');
      else
        next_c2_pending := c2_diagnostic_pending;
        if c0_d2d_data_rx_iob(66) = '1' and next_c2_pending /= diagnostic_pending_max then
          next_c2_pending := next_c2_pending + 1;
        end if;

        if c2_diagnostic_phase_prev = '1' and c2_diagnostic_count(26) = '0' and next_c2_pending /= 0 then
          next_c2_pending := next_c2_pending - 1;
        end if;

        c2_diagnostic_pending <= next_c2_pending;
      end if;
    end if;
  end process c2_diagnostic_pending_q;
  c2_diagnostic_toggle <= c2_diagnostic_count(26) when c2_diagnostic_pending /= 0 else '0';
  c2_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c2_diagnostic_led, c2_diagnostic_toggle);
  
  -- Previous fixed-rate c3 diagnostic kept for reference.
  -- c3_diagnostic : process (clkm_3, clkm_sync_rst_3)
  -- begin  -- process c3_diagnostic
  --   if clkm_sync_rst_3 = '1' then           -- asynchronous reset (active high)
  --     c3_diagnostic_count <= (others => '0');
  --   elsif clkm_3'event and clkm_3 = '1' then  -- rising clock edge
  --     c3_diagnostic_count <= c3_diagnostic_count + 1;
  --   end if;
  -- end process c3_diagnostic;
  -- c3_diagnostic_toggle <= c3_diagnostic_count(26);

  -- Previous wide queued c3 diagnostic kept for reference.
  -- c3_diagnostic : process (d2d_clk_int)
  --   variable next_c3_pending : unsigned(c3_diagnostic_pending'range);
  -- begin
  --   if rising_edge(d2d_clk_int) then
  --     if d2d_rstn = '0' then
  --       c3_diagnostic_count <= (others => '0');
  --       c3_diagnostic_pending <= (others => '0');
  --       c3_diagnostic_phase_prev <= '0';
  --     else
  --       c3_diagnostic_count <= c3_diagnostic_count + 1;
  --
  --       next_c3_pending := c3_diagnostic_pending;
  --       if c0_d2d_data_tx_io(65) = '1' then
  --         next_c3_pending := next_c3_pending + 1;
  --       end if;
  --
  --       if c3_diagnostic_phase_prev = '1' and c3_diagnostic_count(26) = '0' and next_c3_pending /= 0 then
  --         next_c3_pending := next_c3_pending - 1;
  --       end if;
  --
  --       c3_diagnostic_pending <= next_c3_pending;
  --       c3_diagnostic_phase_prev <= c3_diagnostic_count(26);
  --     end if;
  --   end if;
  -- end process c3_diagnostic;

  c3_diagnostic_phase : process (d2d_clk_int)
  begin
    if rising_edge(d2d_clk_int) then
      if d2d_rstn = '0' then
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
  begin
    if rising_edge(d2d_clk_int) then
      if d2d_rstn = '0' then
        c3_diagnostic_pending <= (others => '0');
      else
        next_c3_pending := c3_diagnostic_pending;
        if c0_d2d_data_tx_io(65) = '1' and next_c3_pending /= diagnostic_pending_max then
          next_c3_pending := next_c3_pending + 1;
        end if;

        if c3_diagnostic_phase_prev = '1' and c3_diagnostic_count(26) = '0' and next_c3_pending /= 0 then
          next_c3_pending := next_c3_pending - 1;
        end if;

        c3_diagnostic_pending <= next_c3_pending;
      end if;
    end if;
  end process c3_diagnostic_pending_q;
  c3_diagnostic_toggle <= c3_diagnostic_count(26) when c3_diagnostic_pending /= 0 else '0';
  c3_led_diag_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c3_diagnostic_led, c3_diagnostic_toggle);


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

  -- From DDR controller (on FPGA)
  calib0_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c0_calib_complete, c0_calib_done);
  calib1_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c1_calib_complete, c1_calib_done);
  calib2_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c2_calib_complete, c2_calib_done);
  calib3_complete_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (c3_calib_complete, c3_calib_done);


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
-------------------------------------------------------------------------------
-- Buttons --------------------------------------------------------------------
-------------------------------------------------------------------------------

  --pio_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
  --  port map (button(i-4), gpioi.din(i));

----------------------------------------------------------------------
--- FPGA Reset and Clock generation  ---------------------------------
----------------------------------------------------------------------

  cgi.pllctrl <= "00";
  cgi.pllrst  <= rstraw;

  lock <= c0_calib_done and c1_calib_done and c2_calib_done and c3_calib_done and cgo.clklock;

  reset_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x12v) port map (reset, rst);
  rst0      : rstgen                    -- reset generator
    generic map (acthigh => 1, syncin => 0)
    port map (rst, clkm, lock, d2d_rstn, open);

  d2d_rst <= not d2d_rstn;
  d2d_rx_clocks_locked <= d2d_rx_mmcm_locked0;
  -- c1_d2d_link_ready <= (d2d_tx_link_ready_n and d2d_rx_link_ready_n) when C1_IS_NORTH else
  --                      (d2d_tx_link_ready_s and d2d_rx_link_ready_s);
  c0_d2d_link_ready <= (d2d_tx_link_ready_w and d2d_rx_link_ready_w) when C0_IS_WEST else
                       (d2d_tx_link_ready_e and d2d_rx_link_ready_e);
  front_led_blue_dbg <= not (d2d_rx_clocks_locked and front_panel_blink);
  front_led_yellow_dbg <= not (d2d_startup_done and front_panel_blink);

  d2d_ready <= '1' when (BOARD_NUM = 0 and ISOLATE_BOARD0_D2D) else
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

  uart_rxd_pad   : inpad  generic map (level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_rxd, uart_rxd_int);
  uart_txd_pad   : outpad generic map (level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_txd, uart_txd_int);
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
  
     end generate gen_mig;

  gen_mig_model : if (SIMULATION = true) generate
    -- pragma translate_off

    mig_ahbram : ahbram_sim
      generic map (
        hindex => 0,
        tech   => 0,
        kbytes => 1000,
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
        kbytes => 1000,
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
        kbytes => 1000,
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
        kbytes => 1000,
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

  -- pragma translate_on
  end generate gen_mig_model;

-----------------------------------------------------------------------
---  ETHERNET ---------------------------------------------------------
-----------------------------------------------------------------------

  reset_o2 <= rstn;
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
        nsync       => 1,
        edcl        => CFG_DSU_ETH,
        edclbufsz   => CFG_ETH_BUF,
        macaddrh    => CFG_ETH_ENM,
        macaddrl    => CFG_ETH_ENL,
        phyrstadr   => 1,
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
  eth0_inpads : if (CFG_GRETH = 1) generate
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

  no_eth0 : if SIMULATION = true or CFG_GRETH = 0 generate
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
        rstn        => rstraw,
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

  novga : if CFG_SVGA_ENABLE = 0 generate
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

  tft_nhpd_pad : inpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_nhpd, dvi_nhpd);

  tft_clkp_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_clk_p, clkvga_p);
  tft_clkn_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_clk_n, clkvga_n);

  tft_data_pad : outpadv generic map (width => 24, tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_data, dvi_data);
  tft_hsync_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_hsync, dvi_hsync);
  tft_vsync_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_vsync, dvi_vsync);
  tft_de_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_de, dvi_de);

  tft_dken_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_dken, dvi_dken);
  tft_ctl1_a1_dk1_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_ctl1_a1_dk1, dvi_ctl1_a1_dk1);
  tft_ctl2_a2_dk2_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_ctl2_a2_dk2, dvi_ctl2_a2_dk2);
  tft_a3_dk3_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_a3_dk3, dvi_a3_dk3);

  tft_isel_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_isel, dvi_isel);
  tft_bsel_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_bsel, dvi_bsel);
  tft_dsel_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_dsel, dvi_dsel);
  tft_edge_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_edge, dvi_edge);
  tft_npd_pad : outpad generic map (tech => CFG_FABTECH, level => cmos, voltage => x18v)
    port map (tft_npd, dvi_npd);

  -----------------------------------------------------------------------------
  -- CHIP
  -----------------------------------------------------------------------------
  chip_rst       <= rstn;
  chip_rst_inv   <= not rstn;
  sys_clk(0)     <= clkm;
  sys_clk(1)     <= clkm_1;
  sys_clk(2)     <= clkm_2;
  sys_clk(3)     <= clkm_3; 

  set_upper_ahbsi : for i in CFG_NMEM_TILE_CHIPLET(BOARD_NUM) to MAX_NMEM_TILES-1 generate
        ddr_ahbsi(i) <= ahbs_in_none; 
  end generate set_upper_ahbsi; 

  gen_d2d_connected : if not ((BOARD_NUM = 0) and ISOLATE_BOARD0_D2D) generate
    zero_loop : for i in 0 to WIRES_PER_CONNECTION-1 generate
      -- chiplet_data_n_in(i) <= c1_d2d_data_rx_iob(65 downto 0) when C1_IS_NORTH else (others => '0');
      -- chiplet_credit_in_n(i) <= c1_credit_in_sync_pulse when C1_IS_NORTH else '0';
      -- chiplet_valid_in_n(i) <= c1_d2d_data_rx_iob(67) when C1_IS_NORTH else '0';

      -- chiplet_data_s_in(i) <= c1_d2d_data_rx_iob(65 downto 0) when not C1_IS_NORTH else (others => '0');
      -- chiplet_credit_in_s(i) <= c1_credit_in_sync_pulse when not C1_IS_NORTH else '0';
      -- chiplet_valid_in_s(i) <= c1_d2d_data_rx_iob(67) when not C1_IS_NORTH else '0';

      chiplet_data_w_in(i) <= c0_d2d_data_rx_iob(65 downto 0) when C0_IS_WEST else (others => '0');
      chiplet_credit_in_w(i) <= c0_credit_in_sync_pulse when C0_IS_WEST else '0';
      chiplet_valid_in_w(i) <= c0_d2d_data_rx_iob(67) when C0_IS_WEST else '0';

      chiplet_data_e_in(i) <= c0_d2d_data_rx_iob(65 downto 0) when not C0_IS_WEST else (others => '0');
      chiplet_credit_in_e(i) <= c0_credit_in_sync_pulse when not C0_IS_WEST else '0';
      chiplet_valid_in_e(i) <= c0_d2d_data_rx_iob(67) when not C0_IS_WEST else '0';

      -- c1_d2d_data_tx(65 downto 0) <= chiplet_data_n_out(i) when C1_IS_NORTH else chiplet_data_s_out(i);
      -- c1_d2d_data_tx(66) <= chiplet_credit_out_n_sync_pulse(i) when C1_IS_NORTH else chiplet_credit_out_s_sync_pulse(i);
      -- c1_d2d_data_tx(67) <= chiplet_valid_out_n(i) when C1_IS_NORTH else chiplet_valid_out_s(i);

      c0_d2d_data_tx(65 downto 0) <= chiplet_data_w_out(i) when C0_IS_WEST else chiplet_data_e_out(i);
      c0_d2d_data_tx(66) <= chiplet_credit_out_w_sync_pulse(i) when C0_IS_WEST else chiplet_credit_out_e_sync_pulse(i);
      c0_d2d_data_tx(67) <= chiplet_valid_out_w(i) when C0_IS_WEST else chiplet_valid_out_e(i);
    end generate zero_loop;

    -- d2d_clk_n_in_int <= cable_clk_rcv_global_1 when C1_IS_NORTH else '0';
    -- d2d_clk_s_in_int <= cable_clk_rcv_global_1 when not C1_IS_NORTH else '0';
    d2d_clk_w_in_int <= cable_clk_rcv_global_0 when C0_IS_WEST else '0';
    d2d_clk_e_in_int <= cable_clk_rcv_global_0 when not C0_IS_WEST else '0';
  end generate gen_d2d_connected;

  d2dgen_n  : if D2D_CHANNELS_N > 0 generate
    -- Instantiate D2D N Module here
    d2d_tx_n  : d2d_tx_top
      generic map (
        TXCHANNELS                  => D2D_CHANNELS_N,
        TILES                       => CFG_XLEN(BOARD_NUM),
        flow_control                => 0, --0 = AN; 1 = CB
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
        bypass_data_in              => bypass_data_out(0),  -- from the bypass router's perspective, it is out
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
    -- Instantiate D2D S Module here
    d2d_tx_s  : d2d_tx_top
      generic map (
        TXCHANNELS                  => D2D_CHANNELS_S,
        TILES                       => CFG_XLEN(BOARD_NUM),
        flow_control                => 0, --0 = AN; 1 = CB
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
        bypass_data_in              => bypass_data_out(1),  -- from the bypass router's perspective, it is out
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
    -- Instantiate D2D E Module here
    d2d_tx_e  : d2d_tx_top
      generic map (
        TXCHANNELS                  => D2D_CHANNELS_E,
        TILES                       => CFG_YLEN(BOARD_NUM),
        flow_control                => 0, --0 = AN; 1 = CB
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
        bypass_data_in              => bypass_data_out(3),  -- from the bypass router's perspective, it is out
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
    -- Instantiate D2D W Module here
    d2d_tx_w  : d2d_tx_top
      generic map (
        TXCHANNELS                  => D2D_CHANNELS_W,
        TILES                       => CFG_YLEN(BOARD_NUM),
        flow_control                => 0, --0 = AN; 1 = CB
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
        bypass_data_in              => bypass_data_out(2),  -- from the bypass router's perspective, it is out
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
