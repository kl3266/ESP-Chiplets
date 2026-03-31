-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.net.all;
-- pragma translate_off
use work.sim.all;
library unisim;
use unisim.all;
-- pragma translate_on
use work.monitor_pkg.all;
use work.sldacc.all;
use work.tile.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;
use work.tiles_pkg.all;
use work.tiles_fpga_pkg.all;

entity esp_chiplet is
  generic (
    SIMULATION : boolean := false;
    D2D_CHANNELS_N  : integer := 0;
    D2D_CHANNELS_S  : integer := 0;
    D2D_CHANNELS_W  : integer := 0;
    D2D_CHANNELS_E  : integer := 0;
    X_TILES         : integer := 2;
    Y_TILES         : integer := 2;
    BOARD_NUM       : integer := 0  -- KL ASSUMING 1 Chiplet per board
);
  port (
    rst               : in    std_logic;
    sys_clk           : in    std_logic_vector(0 to MEM_ID_RANGE_MSB);
    refclk            : in    std_logic;
    uart_rxd          : in    std_logic;  -- UART1_RX (u1i.rxd)
    uart_txd          : out   std_logic;  -- UART1_TX (u1o.txd)
    uart_ctsn         : in    std_logic;  -- UART1_RTSN (u1i.ctsn)
    uart_rtsn         : out   std_logic;  -- UART1_RTSN (u1o.rtsn)
    cpuerr            : out   std_logic;
    ddr_ahbsi         : out ahb_slv_in_vector_type(0 to MEM_ID_RANGE_MSB);
    ddr_ahbso         : in  ahb_slv_out_vector_type(0 to MEM_ID_RANGE_MSB);
    eth0_apbi         : out apb_slv_in_type;
    eth0_apbo         : in  apb_slv_out_type;
    sgmii0_apbi       : out apb_slv_in_type;
    sgmii0_apbo       : in  apb_slv_out_type;
    eth0_ahbmi        : out ahb_mst_in_type;
    eth0_ahbmo        : in  ahb_mst_out_type;
    edcl_ahbmo        : in  ahb_mst_out_type;
    dvi_apbi          : out apb_slv_in_type;
    dvi_apbo          : in  apb_slv_out_type;
    dvi_ahbmi         : out ahb_mst_in_type;
    dvi_ahbmo         : in  ahb_mst_out_type;
    mon_noc           : out monitor_noc_matrix(1 to 6, 0 to CFG_CHIPLET_TILES(BOARD_NUM)-1);
    mon_acc           : out monitor_acc_vector(0 to relu(CFG_NACC_TILE_CHIPLET(BOARD_NUM)-1));
    mon_mem           : out monitor_mem_vector(0 to CFG_NMEM_TILE_CHIPLET(BOARD_NUM) + CFG_NSLM_TILE_CHIPLET(BOARD_NUM) + CFG_NSLMDDR_TILE_CHIPLET(BOARD_NUM) - 1);
    mon_l2            : out monitor_cache_vector(0 to relu(CFG_NL2_CHIPLET(BOARD_NUM) - 1));
    mon_llc           : out monitor_cache_vector(0 to relu(CFG_NLLC_CHIPLET(BOARD_NUM) - 1));
    mon_dvfs          : out monitor_dvfs_vector(0 to CFG_CHIPLET_TILES(BOARD_NUM)-1);

    -- D2D --> NoC RX N
    d2d_noc1_data_in_n        : in  coh_noc_flit_vector(X_TILES-1 downto 0);
    d2d_noc2_data_in_n        : in  coh_noc_flit_vector(X_TILES-1 downto 0);
    d2d_noc3_data_in_n        : in  coh_noc_flit_vector(X_TILES-1 downto 0);
    d2d_noc4_data_in_n        : in  dma_noc_flit_vector(X_TILES-1 downto 0);
    d2d_noc5_data_in_n        : in  misc_noc_flit_vector(X_TILES-1 downto 0);
    d2d_noc6_data_in_n        : in  dma_noc_flit_vector(X_TILES-1 downto 0);
  
    d2d_noc1_data_void_in_n   : in  std_logic_vector(X_TILES-1 downto 0);
    d2d_noc2_data_void_in_n   : in  std_logic_vector(X_TILES-1 downto 0);
    d2d_noc3_data_void_in_n   : in  std_logic_vector(X_TILES-1 downto 0);
    d2d_noc4_data_void_in_n   : in  std_logic_vector(X_TILES-1 downto 0);
    d2d_noc5_data_void_in_n   : in  std_logic_vector(X_TILES-1 downto 0);
    d2d_noc6_data_void_in_n   : in  std_logic_vector(X_TILES-1 downto 0);
  
    -- NoC --> D2D RX N
    d2d_noc1_stop_out_n       : out std_logic_vector(X_TILES-1 downto 0);
    d2d_noc2_stop_out_n       : out std_logic_vector(X_TILES-1 downto 0);
    d2d_noc3_stop_out_n       : out std_logic_vector(X_TILES-1 downto 0);
    d2d_noc4_stop_out_n       : out std_logic_vector(X_TILES-1 downto 0);
    d2d_noc5_stop_out_n       : out std_logic_vector(X_TILES-1 downto 0);
    d2d_noc6_stop_out_n       : out std_logic_vector(X_TILES-1 downto 0);

    -- D2D --> NoC RX S
    d2d_noc1_data_in_s        : in  coh_noc_flit_vector(X_TILES-1 downto 0);
    d2d_noc2_data_in_s        : in  coh_noc_flit_vector(X_TILES-1 downto 0);
    d2d_noc3_data_in_s        : in  coh_noc_flit_vector(X_TILES-1 downto 0);
    d2d_noc4_data_in_s        : in  dma_noc_flit_vector(X_TILES-1 downto 0);
    d2d_noc5_data_in_s        : in  misc_noc_flit_vector(X_TILES-1 downto 0);
    d2d_noc6_data_in_s        : in  dma_noc_flit_vector(X_TILES-1 downto 0);
  
    d2d_noc1_data_void_in_s   : in  std_logic_vector(X_TILES-1 downto 0);
    d2d_noc2_data_void_in_s   : in  std_logic_vector(X_TILES-1 downto 0);
    d2d_noc3_data_void_in_s   : in  std_logic_vector(X_TILES-1 downto 0);
    d2d_noc4_data_void_in_s   : in  std_logic_vector(X_TILES-1 downto 0);
    d2d_noc5_data_void_in_s   : in  std_logic_vector(X_TILES-1 downto 0);
    d2d_noc6_data_void_in_s   : in  std_logic_vector(X_TILES-1 downto 0);
  
    -- NoC --> D2D RX S
    d2d_noc1_stop_out_s       : out std_logic_vector(X_TILES-1 downto 0);
    d2d_noc2_stop_out_s       : out std_logic_vector(X_TILES-1 downto 0);
    d2d_noc3_stop_out_s       : out std_logic_vector(X_TILES-1 downto 0);
    d2d_noc4_stop_out_s       : out std_logic_vector(X_TILES-1 downto 0);
    d2d_noc5_stop_out_s       : out std_logic_vector(X_TILES-1 downto 0);
    d2d_noc6_stop_out_s       : out std_logic_vector(X_TILES-1 downto 0);

    -- D2D --> NoC RX E
    d2d_noc1_data_in_e        : in  coh_noc_flit_vector(Y_TILES-1 downto 0);
    d2d_noc2_data_in_e        : in  coh_noc_flit_vector(Y_TILES-1 downto 0);
    d2d_noc3_data_in_e        : in  coh_noc_flit_vector(Y_TILES-1 downto 0);
    d2d_noc4_data_in_e        : in  dma_noc_flit_vector(Y_TILES-1 downto 0);
    d2d_noc5_data_in_e        : in  misc_noc_flit_vector(Y_TILES-1 downto 0);
    d2d_noc6_data_in_e        : in  dma_noc_flit_vector(Y_TILES-1 downto 0);
  
    d2d_noc1_data_void_in_e   : in  std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc2_data_void_in_e   : in  std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc3_data_void_in_e   : in  std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc4_data_void_in_e   : in  std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc5_data_void_in_e   : in  std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc6_data_void_in_e   : in  std_logic_vector(Y_TILES-1 downto 0);
  
    -- NoC --> D2D RX E
    d2d_noc1_stop_out_e       : out std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc2_stop_out_e       : out std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc3_stop_out_e       : out std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc4_stop_out_e       : out std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc5_stop_out_e       : out std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc6_stop_out_e       : out std_logic_vector(Y_TILES-1 downto 0);

    -- D2D --> NoC RX W
    d2d_noc1_data_in_w        : in  coh_noc_flit_vector(Y_TILES-1 downto 0);
    d2d_noc2_data_in_w        : in  coh_noc_flit_vector(Y_TILES-1 downto 0);
    d2d_noc3_data_in_w        : in  coh_noc_flit_vector(Y_TILES-1 downto 0);
    d2d_noc4_data_in_w        : in  dma_noc_flit_vector(Y_TILES-1 downto 0);
    d2d_noc5_data_in_w        : in  misc_noc_flit_vector(Y_TILES-1 downto 0);
    d2d_noc6_data_in_w        : in  dma_noc_flit_vector(Y_TILES-1 downto 0);
  
    d2d_noc1_data_void_in_w   : in  std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc2_data_void_in_w   : in  std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc3_data_void_in_w   : in  std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc4_data_void_in_w   : in  std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc5_data_void_in_w   : in  std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc6_data_void_in_w   : in  std_logic_vector(Y_TILES-1 downto 0);
  
    -- NoC --> D2D RX W
    d2d_noc1_stop_out_w       : out std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc2_stop_out_w       : out std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc3_stop_out_w       : out std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc4_stop_out_w       : out std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc5_stop_out_w       : out std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc6_stop_out_w       : out std_logic_vector(Y_TILES-1 downto 0);

    -- NoC --> D2D RX N
    d2d_noc1_data_out_n        : out  coh_noc_flit_vector(X_TILES-1 downto 0);
    d2d_noc2_data_out_n        : out  coh_noc_flit_vector(X_TILES-1 downto 0);
    d2d_noc3_data_out_n        : out  coh_noc_flit_vector(X_TILES-1 downto 0);
    d2d_noc4_data_out_n        : out  dma_noc_flit_vector(X_TILES-1 downto 0);
    d2d_noc5_data_out_n        : out  misc_noc_flit_vector(X_TILES-1 downto 0);
    d2d_noc6_data_out_n        : out  dma_noc_flit_vector(X_TILES-1 downto 0);
  
    d2d_noc1_data_void_out_n   : out  std_logic_vector(X_TILES-1 downto 0);
    d2d_noc2_data_void_out_n   : out  std_logic_vector(X_TILES-1 downto 0);
    d2d_noc3_data_void_out_n   : out  std_logic_vector(X_TILES-1 downto 0);
    d2d_noc4_data_void_out_n   : out  std_logic_vector(X_TILES-1 downto 0);
    d2d_noc5_data_void_out_n   : out  std_logic_vector(X_TILES-1 downto 0);
    d2d_noc6_data_void_out_n   : out  std_logic_vector(X_TILES-1 downto 0);
  
    -- D2D --> NoC RX N
    d2d_noc1_stop_in_n       : in std_logic_vector(X_TILES-1 downto 0);
    d2d_noc2_stop_in_n       : in std_logic_vector(X_TILES-1 downto 0);
    d2d_noc3_stop_in_n       : in std_logic_vector(X_TILES-1 downto 0);
    d2d_noc4_stop_in_n       : in std_logic_vector(X_TILES-1 downto 0);
    d2d_noc5_stop_in_n       : in std_logic_vector(X_TILES-1 downto 0);
    d2d_noc6_stop_in_n       : in std_logic_vector(X_TILES-1 downto 0);

    -- NoC --> D2D RX S
    d2d_noc1_data_out_s        : out  coh_noc_flit_vector(X_TILES-1 downto 0);
    d2d_noc2_data_out_s        : out  coh_noc_flit_vector(X_TILES-1 downto 0);
    d2d_noc3_data_out_s        : out  coh_noc_flit_vector(X_TILES-1 downto 0);
    d2d_noc4_data_out_s        : out  dma_noc_flit_vector(X_TILES-1 downto 0);
    d2d_noc5_data_out_s        : out  misc_noc_flit_vector(X_TILES-1 downto 0);
    d2d_noc6_data_out_s        : out  dma_noc_flit_vector(X_TILES-1 downto 0);
  
    d2d_noc1_data_void_out_s   : out  std_logic_vector(X_TILES-1 downto 0);
    d2d_noc2_data_void_out_s   : out  std_logic_vector(X_TILES-1 downto 0);
    d2d_noc3_data_void_out_s   : out  std_logic_vector(X_TILES-1 downto 0);
    d2d_noc4_data_void_out_s   : out  std_logic_vector(X_TILES-1 downto 0);
    d2d_noc5_data_void_out_s   : out  std_logic_vector(X_TILES-1 downto 0);
    d2d_noc6_data_void_out_s   : out  std_logic_vector(X_TILES-1 downto 0);
  
    -- D2D --> NoC RX S
    d2d_noc1_stop_in_s       : in std_logic_vector(X_TILES-1 downto 0);
    d2d_noc2_stop_in_s       : in std_logic_vector(X_TILES-1 downto 0);
    d2d_noc3_stop_in_s       : in std_logic_vector(X_TILES-1 downto 0);
    d2d_noc4_stop_in_s       : in std_logic_vector(X_TILES-1 downto 0);
    d2d_noc5_stop_in_s       : in std_logic_vector(X_TILES-1 downto 0);
    d2d_noc6_stop_in_s       : in std_logic_vector(X_TILES-1 downto 0);

    -- NoC --> D2D RX E
    d2d_noc1_data_out_e        : out  coh_noc_flit_vector(Y_TILES-1 downto 0);
    d2d_noc2_data_out_e        : out  coh_noc_flit_vector(Y_TILES-1 downto 0);
    d2d_noc3_data_out_e        : out  coh_noc_flit_vector(Y_TILES-1 downto 0);
    d2d_noc4_data_out_e        : out  dma_noc_flit_vector(Y_TILES-1 downto 0);
    d2d_noc5_data_out_e        : out  misc_noc_flit_vector(Y_TILES-1 downto 0);
    d2d_noc6_data_out_e        : out  dma_noc_flit_vector(Y_TILES-1 downto 0);
  
    d2d_noc1_data_void_out_e   : out  std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc2_data_void_out_e   : out  std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc3_data_void_out_e   : out  std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc4_data_void_out_e   : out  std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc5_data_void_out_e   : out  std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc6_data_void_out_e   : out  std_logic_vector(Y_TILES-1 downto 0);
  
    -- D2D --> NoC RX E
    d2d_noc1_stop_in_e       : in std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc2_stop_in_e       : in std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc3_stop_in_e       : in std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc4_stop_in_e       : in std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc5_stop_in_e       : in std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc6_stop_in_e       : in std_logic_vector(Y_TILES-1 downto 0);

    -- NoC --> D2D RX W
    d2d_noc1_data_out_w        : out  coh_noc_flit_vector(Y_TILES-1 downto 0);
    d2d_noc2_data_out_w        : out  coh_noc_flit_vector(Y_TILES-1 downto 0);
    d2d_noc3_data_out_w        : out  coh_noc_flit_vector(Y_TILES-1 downto 0);
    d2d_noc4_data_out_w        : out  dma_noc_flit_vector(Y_TILES-1 downto 0);
    d2d_noc5_data_out_w        : out  misc_noc_flit_vector(Y_TILES-1 downto 0);
    d2d_noc6_data_out_w        : out  dma_noc_flit_vector(Y_TILES-1 downto 0);
  
    d2d_noc1_data_void_out_w   : out  std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc2_data_void_out_w   : out  std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc3_data_void_out_w   : out  std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc4_data_void_out_w   : out  std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc5_data_void_out_w   : out  std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc6_data_void_out_w   : out  std_logic_vector(Y_TILES-1 downto 0);
  
    -- D2D --> NoC RX W
    d2d_noc1_stop_in_w       : in std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc2_stop_in_w       : in std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc3_stop_in_w       : in std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc4_stop_in_w       : in std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc5_stop_in_w       : in std_logic_vector(Y_TILES-1 downto 0);
    d2d_noc6_stop_in_w       : in std_logic_vector(Y_TILES-1 downto 0)
);
end;


architecture rtl of esp_chiplet is

  component tile_io_abbrev is
    generic (
      SIMULATION : boolean := false;
      this_has_dco : integer range 0 to 2 := 0;
      chiplet_index : integer := 0); 
    port (
      raw_rstn           : in  std_ulogic;
      tile_rst           : in  std_ulogic;
      ext_clk_noc        : in  std_ulogic;
      clk_div_noc        : out std_ulogic;
      ext_clk            : in  std_ulogic;
      clk_div            : out std_ulogic;
      tile_clk_out       : out std_ulogic;
      tile_rstn_out      : out std_ulogic;
      noc_clk_out        : out std_ulogic;
      noc_clk_lock       : out std_ulogic;
      dco_freq_sel       : in std_logic_vector(1 downto 0);
      dco_div_sel        : in std_logic_vector(2 downto 0);
      dco_fc_sel         : in std_logic_vector(5 downto 0);
      dco_cc_sel         : in std_logic_vector(5 downto 0);
      dco_clk_sel        : in std_ulogic;
      dco_en             : in std_ulogic;  
      -- NOC Ports
      test1_output_port    : in coh_noc_flit_type;
      test1_data_void_out : in std_ulogic;
      test1_stop_in        : in std_ulogic;
      test2_output_port    : in coh_noc_flit_type;
      test2_data_void_out : in std_ulogic;
      test2_stop_in        : in std_ulogic;
      test3_output_port    : in coh_noc_flit_type;
      test3_data_void_out : in std_ulogic;
      test3_stop_in        : in std_ulogic;
      test4_output_port    : in dma_noc_flit_type;
      test4_data_void_out : in std_ulogic;
      test4_stop_in        : in std_ulogic;
      test5_output_port    : in misc_noc_flit_type;
      test5_data_void_out : in std_ulogic;
      test5_stop_in        : in std_ulogic;
      test6_output_port    : in dma_noc_flit_type;
      test6_data_void_out : in std_ulogic;
      test6_stop_in        : in std_ulogic;
      test1_input_port     : out coh_noc_flit_type;
      test1_data_void_in  : out std_ulogic;
      test1_stop_out       : out std_ulogic;
      test2_input_port     : out coh_noc_flit_type;
      test2_data_void_in  : out std_ulogic;
      test2_stop_out       : out std_ulogic;
      test3_input_port     : out coh_noc_flit_type;
      test3_data_void_in  : out std_ulogic;
      test3_stop_out       : out std_ulogic;
      test4_input_port     : out dma_noc_flit_type;
      test4_data_void_in  : out std_ulogic;
      test4_stop_out       : out std_ulogic;
      test5_input_port     : out misc_noc_flit_type;
      test5_data_void_in  : out std_ulogic;
      test5_stop_out       : out std_ulogic;
      test6_input_port     : out dma_noc_flit_type;
      test6_data_void_in  : out std_ulogic;
      test6_stop_out       : out std_ulogic;
      mon_noc             : in  monitor_noc_vector(1 to 6);
      mon_dvfs            : out monitor_dvfs_type
    );
  end component;

  component relay_station_tile is
      port (
          clk                 :   in  std_ulogic;
          rst                 :   in  std_ulogic;
          noc1_data_in        :   in  coh_noc_flit_type;
          noc1_data_void_in   :   in  std_logic;
          noc1_stop_in        :   in  std_logic;
          noc1_data_out       :   out coh_noc_flit_type;
          noc1_data_void_out  :   out std_logic;
          noc1_stop_out       :   out std_logic;
          noc2_data_in        :   in  coh_noc_flit_type;
          noc2_data_void_in   :   in  std_logic;
          noc2_stop_in        :   in  std_logic;
          noc2_data_out       :   out coh_noc_flit_type;
          noc2_data_void_out  :   out std_logic;
          noc2_stop_out       :   out std_logic;
          noc3_data_in        :   in  coh_noc_flit_type;
          noc3_data_void_in   :   in  std_logic;
          noc3_stop_in        :   in  std_logic;
          noc3_data_out       :   out coh_noc_flit_type;
          noc3_data_void_out  :   out std_logic;
          noc3_stop_out       :   out std_logic;
          noc4_data_in        :   in  dma_noc_flit_type;
          noc4_data_void_in   :   in  std_logic;
          noc4_stop_in        :   in  std_logic;
          noc4_data_out       :   out dma_noc_flit_type;
          noc4_data_void_out  :   out std_logic;
          noc4_stop_out       :   out std_logic;
          noc5_data_in        :   in  misc_noc_flit_type;
          noc5_data_void_in   :   in  std_logic;
          noc5_stop_in        :   in  std_logic;
          noc5_data_out       :   out misc_noc_flit_type;
          noc5_data_void_out  :   out std_logic;
          noc5_stop_out       :   out std_logic;
          noc6_data_in        :   in  dma_noc_flit_type;
          noc6_data_void_in   :   in  std_logic;
          noc6_stop_in        :   in  std_logic;
          noc6_data_out       :   out dma_noc_flit_type;
          noc6_data_void_out  :   out std_logic;
          noc6_stop_out       :   out std_logic
      );
    end component relay_station_tile;

constant nocs_num : integer := 6;

type noc_ctrl_matrix is array (1 to nocs_num) of std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
type handshake_vec is array (CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0) of std_logic_vector(3 downto 0);
type boolean_vec is array (natural range <>) of boolean;

-- constant is_io_tile : boolean_vec(0 to CFG_CHIPLET_TILES(BOARD_NUM)-1) := (io_tile_id => true, others => false);

signal rst_int       : std_logic;
signal rst_inv       : std_logic;
signal sys_clk_int   : std_logic_vector(0 to MEM_ID_RANGE_MSB);
signal cpuerr_vec    : std_logic_vector(0 to CFG_NCPU_TILE_CHIPLET(BOARD_NUM)-1);

signal mon_dvfs_out : monitor_dvfs_vector(0 to CFG_CHIPLET_TILES(BOARD_NUM)-1);

type mon_noc_vector is array (CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0) of monitor_noc_vector(1 to nocs_num);
signal mon_noc_s    : mon_noc_vector;

signal mon_l2_int : monitor_cache_vector(0 to CFG_CHIPLET_TILES(BOARD_NUM)-1);
signal mon_llc_int : monitor_cache_vector(0 to CFG_CHIPLET_TILES(BOARD_NUM)-1);

-- DCO config
type dco_clk_delay_sel_vector is array (CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0) of std_logic_vector(11 downto 0);
type dco_freq_sel_vector      is array (CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0) of std_logic_vector(1 downto 0);
type dco_cc_sel_vector        is array (CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0) of std_logic_vector(5 downto 0);
type dco_fc_sel_vector        is array (CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0) of std_logic_vector(5 downto 0);
type dco_div_sel_vector       is array (CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0) of std_logic_vector(2 downto 0);

signal dco_en            : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal dco_clk_sel       : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal dco_cc_sel        : dco_cc_sel_vector;
signal dco_fc_sel        : dco_fc_sel_vector;
signal dco_div_sel       : dco_div_sel_vector;
signal dco_freq_sel      : dco_freq_sel_vector;

-- Global NoC reset and clock
signal tile_clk      : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);

-- NOC Signals
signal noc1_data_n_in       : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc1_data_s_in       : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc1_data_w_in       : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc1_data_e_in       : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc1_data_void_in    : handshake_vec;
signal noc1_stop_in         : handshake_vec;
signal noc1_data_n_out      : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc1_data_s_out      : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc1_data_w_out      : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc1_data_e_out      : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc1_data_void_out   : handshake_vec;
signal noc1_stop_out        : handshake_vec;
signal noc2_data_n_in       : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc2_data_s_in       : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc2_data_w_in       : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc2_data_e_in       : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc2_data_void_in    : handshake_vec;
signal noc2_stop_in         : handshake_vec;
signal noc2_data_n_out      : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc2_data_s_out      : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc2_data_w_out      : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc2_data_e_out      : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc2_data_void_out   : handshake_vec;
signal noc2_stop_out        : handshake_vec;
signal noc3_data_n_in       : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc3_data_s_in       : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc3_data_w_in       : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc3_data_e_in       : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc3_data_void_in    : handshake_vec;
signal noc3_stop_in         : handshake_vec;
signal noc3_data_n_out      : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc3_data_s_out      : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc3_data_w_out      : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc3_data_e_out      : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc3_data_void_out   : handshake_vec;
signal noc3_stop_out        : handshake_vec;
signal noc4_data_n_in       : dma_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc4_data_s_in       : dma_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc4_data_w_in       : dma_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc4_data_e_in       : dma_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc4_data_void_in    : handshake_vec;
signal noc4_stop_in         : handshake_vec;
signal noc4_data_n_out      : dma_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc4_data_s_out      : dma_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc4_data_w_out      : dma_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc4_data_e_out      : dma_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc4_data_void_out   : handshake_vec;
signal noc4_stop_out        : handshake_vec;
signal noc5_data_n_in       : misc_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc5_data_s_in       : misc_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc5_data_w_in       : misc_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc5_data_e_in       : misc_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc5_data_void_in    : handshake_vec;
signal noc5_stop_in         : handshake_vec;
signal noc5_data_n_out      : misc_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc5_data_s_out      : misc_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc5_data_w_out      : misc_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc5_data_e_out      : misc_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc5_data_void_out   : handshake_vec;
signal noc5_stop_out        : handshake_vec;
signal noc6_data_n_in       : dma_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc6_data_s_in       : dma_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc6_data_w_in       : dma_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc6_data_e_in       : dma_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc6_data_void_in    : handshake_vec;
signal noc6_stop_in         : handshake_vec;
signal noc6_data_n_out      : dma_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc6_data_s_out      : dma_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc6_data_w_out      : dma_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc6_data_e_out      : dma_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc6_data_void_out   : handshake_vec;
signal noc6_stop_out        : handshake_vec;

signal noc1_data_l_in          : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc1_data_l_out         : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc1_data_void_in_tile  : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc1_data_void_out_tile : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc1_stop_in_tile       : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc1_stop_out_tile      : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc2_data_l_in          : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc2_data_l_out         : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc2_data_void_in_tile  : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc2_data_void_out_tile : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc2_stop_in_tile       : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc2_stop_out_tile      : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc3_data_l_in          : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc3_data_l_out         : coh_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc3_data_void_in_tile  : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc3_data_void_out_tile : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc3_stop_in_tile       : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc3_stop_out_tile      : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc4_data_l_in          : dma_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc4_data_l_out         : dma_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc4_data_void_in_tile  : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc4_data_void_out_tile : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc4_stop_in_tile       : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc4_stop_out_tile      : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc5_data_l_in          : misc_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc5_data_l_out         : misc_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc5_data_void_in_tile  : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc5_data_void_out_tile : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc5_stop_in_tile       : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc5_stop_out_tile      : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc6_data_l_in          : dma_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc6_data_l_out         : dma_noc_flit_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc6_data_void_in_tile  : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc6_data_void_out_tile : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc6_stop_in_tile       : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);
signal noc6_stop_out_tile      : std_logic_vector(CFG_CHIPLET_TILES(BOARD_NUM)-1 downto 0);

-- relay station
signal noc1_data_void_in_rs_tx_n  : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc1_stop_out_rs_tx_n      : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc2_data_void_in_rs_tx_n  : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc2_stop_out_rs_tx_n      : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc3_data_void_in_rs_tx_n  : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc3_stop_out_rs_tx_n      : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc4_data_void_in_rs_tx_n  : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc4_stop_out_rs_tx_n      : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc5_data_void_in_rs_tx_n  : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc5_stop_out_rs_tx_n      : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc6_data_void_in_rs_tx_n  : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc6_stop_out_rs_tx_n      : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);

signal noc1_data_void_in_rs_tx_s  : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc1_stop_out_rs_tx_s      : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc2_data_void_in_rs_tx_s  : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc2_stop_out_rs_tx_s      : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc3_data_void_in_rs_tx_s  : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc3_stop_out_rs_tx_s      : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc4_data_void_in_rs_tx_s  : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc4_stop_out_rs_tx_s      : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc5_data_void_in_rs_tx_s  : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc5_stop_out_rs_tx_s      : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc6_data_void_in_rs_tx_s  : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc6_stop_out_rs_tx_s      : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);

signal noc1_data_void_in_rs_tx_e  : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc1_stop_out_rs_tx_e      : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc2_data_void_in_rs_tx_e  : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc2_stop_out_rs_tx_e      : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc3_data_void_in_rs_tx_e  : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc3_stop_out_rs_tx_e      : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc4_data_void_in_rs_tx_e  : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc4_stop_out_rs_tx_e      : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc5_data_void_in_rs_tx_e  : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc5_stop_out_rs_tx_e      : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc6_data_void_in_rs_tx_e  : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc6_stop_out_rs_tx_e      : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);

signal noc1_data_void_in_rs_tx_w  : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc1_stop_out_rs_tx_w      : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc2_data_void_in_rs_tx_w  : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc2_stop_out_rs_tx_w      : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc3_data_void_in_rs_tx_w  : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc3_stop_out_rs_tx_w      : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc4_data_void_in_rs_tx_w  : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc4_stop_out_rs_tx_w      : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc5_data_void_in_rs_tx_w  : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc5_stop_out_rs_tx_w      : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc6_data_void_in_rs_tx_w  : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc6_stop_out_rs_tx_w      : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);

signal noc1_data_void_out_rs_rx_n : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc1_stop_in_rs_rx_n       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc2_data_void_out_rs_rx_n : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc2_stop_in_rs_rx_n       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc3_data_void_out_rs_rx_n : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc3_stop_in_rs_rx_n       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc4_data_void_out_rs_rx_n : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc4_stop_in_rs_rx_n       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc5_data_void_out_rs_rx_n : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc5_stop_in_rs_rx_n       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc6_data_void_out_rs_rx_n : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc6_stop_in_rs_rx_n       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);

signal noc1_data_void_out_rs_rx_s : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc1_stop_in_rs_rx_s       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc2_data_void_out_rs_rx_s : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc2_stop_in_rs_rx_s       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc3_data_void_out_rs_rx_s : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc3_stop_in_rs_rx_s       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc4_data_void_out_rs_rx_s : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc4_stop_in_rs_rx_s       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc5_data_void_out_rs_rx_s : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc5_stop_in_rs_rx_s       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc6_data_void_out_rs_rx_s : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);
signal noc6_stop_in_rs_rx_s       : std_logic_vector(CFG_XLEN(BOARD_NUM)-1 downto 0);

signal noc1_data_void_out_rs_rx_e : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc1_stop_in_rs_rx_e       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc2_data_void_out_rs_rx_e : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc2_stop_in_rs_rx_e       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc3_data_void_out_rs_rx_e : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc3_stop_in_rs_rx_e       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc4_data_void_out_rs_rx_e : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc4_stop_in_rs_rx_e       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc5_data_void_out_rs_rx_e : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc5_stop_in_rs_rx_e       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc6_data_void_out_rs_rx_e : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc6_stop_in_rs_rx_e       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);

signal noc1_data_void_out_rs_rx_w : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc1_stop_in_rs_rx_w       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc2_data_void_out_rs_rx_w : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc2_stop_in_rs_rx_w       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc3_data_void_out_rs_rx_w : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc3_stop_in_rs_rx_w       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc4_data_void_out_rs_rx_w : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc4_stop_in_rs_rx_w       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc5_data_void_out_rs_rx_w : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc5_stop_in_rs_rx_w       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc6_data_void_out_rs_rx_w : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc6_stop_in_rs_rx_w       : std_logic_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);

signal noc1_data_in_rs_tx_w       : coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc2_data_in_rs_tx_w       : coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc3_data_in_rs_tx_w       : coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc4_data_in_rs_tx_w       : dma_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc5_data_in_rs_tx_w       : misc_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc6_data_in_rs_tx_w       : dma_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);

signal noc1_data_in_rs_tx_e       : coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc2_data_in_rs_tx_e       : coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc3_data_in_rs_tx_e       : coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc4_data_in_rs_tx_e       : dma_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc5_data_in_rs_tx_e       : misc_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc6_data_in_rs_tx_e       : dma_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);

signal noc1_data_out_rs_rx_w      : coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc2_data_out_rs_rx_w      : coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc3_data_out_rs_rx_w      : coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc4_data_out_rs_rx_w      : dma_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc5_data_out_rs_rx_w      : misc_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc6_data_out_rs_rx_w      : dma_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);

signal noc1_data_out_rs_rx_e      : coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc2_data_out_rs_rx_e      : coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc3_data_out_rs_rx_e      : coh_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc4_data_out_rs_rx_e      : dma_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc5_data_out_rs_rx_e      : misc_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);
signal noc6_data_out_rs_rx_e      : dma_noc_flit_vector(CFG_YLEN(BOARD_NUM)-1 downto 0);

begin

  rst_int <= rst;
  rst_inv <= not rst;
  clk_int_gen: for i in 0 to MEM_ID_RANGE_MSB generate
    sys_clk_int(i) <= sys_clk(i);
  end generate clk_int_gen;

--  cpuerr <= cpuerr_vec(0);
  cpuerr_gen  : if CFG_NCPU_TILE_CHIPLET(BOARD_NUM) > 0 generate
    cpuerr <= cpuerr_vec(0);
  end generate cpuerr_gen;
  no_cpuerr_gen : if CFG_NCPU_TILE_CHIPLET(BOARD_NUM) = 0 generate
    cpuerr <= '0';
  end generate no_cpuerr_gen;

  -----------------------------------------------------------------------------
  -- NOC CONNECTIONS
  -----------------------------------------------------------------------------

  -- D2D
  d2dgen_n : if D2D_CHANNELS_N /= 0 generate
  begin
    rs_gen_n : for tile_idx in 0 to CFG_XLEN(BOARD_NUM) - 1 generate
      noc1_data_void_in_rs_tx_n(tile_idx) <= noc1_data_void_out(tile_idx)(0);
      noc2_data_void_in_rs_tx_n(tile_idx) <= noc2_data_void_out(tile_idx)(0);
      noc3_data_void_in_rs_tx_n(tile_idx) <= noc3_data_void_out(tile_idx)(0);
      noc4_data_void_in_rs_tx_n(tile_idx) <= noc4_data_void_out(tile_idx)(0);
      noc5_data_void_in_rs_tx_n(tile_idx) <= noc5_data_void_out(tile_idx)(0);
      noc6_data_void_in_rs_tx_n(tile_idx) <= noc6_data_void_out(tile_idx)(0);

      noc1_stop_in(tile_idx)(0) <= noc1_stop_out_rs_tx_n(tile_idx);
      noc2_stop_in(tile_idx)(0) <= noc2_stop_out_rs_tx_n(tile_idx);
      noc3_stop_in(tile_idx)(0) <= noc3_stop_out_rs_tx_n(tile_idx);
      noc4_stop_in(tile_idx)(0) <= noc4_stop_out_rs_tx_n(tile_idx);
      noc5_stop_in(tile_idx)(0) <= noc5_stop_out_rs_tx_n(tile_idx);
      noc6_stop_in(tile_idx)(0) <= noc6_stop_out_rs_tx_n(tile_idx);

      noc1_data_void_in(tile_idx)(0) <= noc1_data_void_out_rs_rx_n(tile_idx);
      noc2_data_void_in(tile_idx)(0) <= noc2_data_void_out_rs_rx_n(tile_idx);
      noc3_data_void_in(tile_idx)(0) <= noc3_data_void_out_rs_rx_n(tile_idx);
      noc4_data_void_in(tile_idx)(0) <= noc4_data_void_out_rs_rx_n(tile_idx);
      noc5_data_void_in(tile_idx)(0) <= noc5_data_void_out_rs_rx_n(tile_idx);
      noc6_data_void_in(tile_idx)(0) <= noc6_data_void_out_rs_rx_n(tile_idx);

      noc1_stop_in_rs_rx_n(tile_idx) <= noc1_stop_out(tile_idx)(0);
      noc2_stop_in_rs_rx_n(tile_idx) <= noc2_stop_out(tile_idx)(0);
      noc3_stop_in_rs_rx_n(tile_idx) <= noc3_stop_out(tile_idx)(0);
      noc4_stop_in_rs_rx_n(tile_idx) <= noc4_stop_out(tile_idx)(0);
      noc5_stop_in_rs_rx_n(tile_idx) <= noc5_stop_out(tile_idx)(0);
      noc6_stop_in_rs_rx_n(tile_idx) <= noc6_stop_out(tile_idx)(0);

      rs_tx_n_tile : relay_station_tile
        port map (
          clk => sys_clk_int(0),
          rst => rst_inv,
          -- Facing NoC
          noc1_data_in       => noc1_data_n_out(tile_idx),
          noc2_data_in       => noc2_data_n_out(tile_idx),
          noc3_data_in       => noc3_data_n_out(tile_idx),
          noc4_data_in       => noc4_data_n_out(tile_idx),
          noc5_data_in       => noc5_data_n_out(tile_idx),
          noc6_data_in       => noc6_data_n_out(tile_idx),
          noc1_data_void_in  => noc1_data_void_in_rs_tx_n(tile_idx),
          noc2_data_void_in  => noc2_data_void_in_rs_tx_n(tile_idx),
          noc3_data_void_in  => noc3_data_void_in_rs_tx_n(tile_idx),
          noc4_data_void_in  => noc4_data_void_in_rs_tx_n(tile_idx),
          noc5_data_void_in  => noc5_data_void_in_rs_tx_n(tile_idx),
          noc6_data_void_in  => noc6_data_void_in_rs_tx_n(tile_idx),
          noc1_stop_out      => noc1_stop_out_rs_tx_n(tile_idx),
          noc2_stop_out      => noc2_stop_out_rs_tx_n(tile_idx),
          noc3_stop_out      => noc3_stop_out_rs_tx_n(tile_idx),
          noc4_stop_out      => noc4_stop_out_rs_tx_n(tile_idx),
          noc5_stop_out      => noc5_stop_out_rs_tx_n(tile_idx),
          noc6_stop_out      => noc6_stop_out_rs_tx_n(tile_idx),
          -- Facing D2D
          noc1_data_out      => d2d_noc1_data_out_n(tile_idx),
          noc2_data_out      => d2d_noc2_data_out_n(tile_idx),
          noc3_data_out      => d2d_noc3_data_out_n(tile_idx),
          noc4_data_out      => d2d_noc4_data_out_n(tile_idx),
          noc5_data_out      => d2d_noc5_data_out_n(tile_idx),
          noc6_data_out      => d2d_noc6_data_out_n(tile_idx),
          noc1_data_void_out => d2d_noc1_data_void_out_n(tile_idx),
          noc2_data_void_out => d2d_noc2_data_void_out_n(tile_idx),
          noc3_data_void_out => d2d_noc3_data_void_out_n(tile_idx),
          noc4_data_void_out => d2d_noc4_data_void_out_n(tile_idx),
          noc5_data_void_out => d2d_noc5_data_void_out_n(tile_idx),
          noc6_data_void_out => d2d_noc6_data_void_out_n(tile_idx),
          noc1_stop_in       => d2d_noc1_stop_in_n(tile_idx),
          noc2_stop_in       => d2d_noc2_stop_in_n(tile_idx),
          noc3_stop_in       => d2d_noc3_stop_in_n(tile_idx),
          noc4_stop_in       => d2d_noc4_stop_in_n(tile_idx),
          noc5_stop_in       => d2d_noc5_stop_in_n(tile_idx),
          noc6_stop_in       => d2d_noc6_stop_in_n(tile_idx)
        );

      rs_rx_n_tile : relay_station_tile
        port map (
          clk => sys_clk_int(0),
          rst => rst_inv,
          -- Facing D2D
          noc1_data_in       => d2d_noc1_data_in_n(tile_idx),
          noc2_data_in       => d2d_noc2_data_in_n(tile_idx),
          noc3_data_in       => d2d_noc3_data_in_n(tile_idx),
          noc4_data_in       => d2d_noc4_data_in_n(tile_idx),
          noc5_data_in       => d2d_noc5_data_in_n(tile_idx),
          noc6_data_in       => d2d_noc6_data_in_n(tile_idx),
          noc1_data_void_in  => d2d_noc1_data_void_in_n(tile_idx),
          noc2_data_void_in  => d2d_noc2_data_void_in_n(tile_idx),
          noc3_data_void_in  => d2d_noc3_data_void_in_n(tile_idx),
          noc4_data_void_in  => d2d_noc4_data_void_in_n(tile_idx),
          noc5_data_void_in  => d2d_noc5_data_void_in_n(tile_idx),
          noc6_data_void_in  => d2d_noc6_data_void_in_n(tile_idx),
          noc1_stop_out      => d2d_noc1_stop_out_n(tile_idx),
          noc2_stop_out      => d2d_noc2_stop_out_n(tile_idx),
          noc3_stop_out      => d2d_noc3_stop_out_n(tile_idx),
          noc4_stop_out      => d2d_noc4_stop_out_n(tile_idx),
          noc5_stop_out      => d2d_noc5_stop_out_n(tile_idx),
          noc6_stop_out      => d2d_noc6_stop_out_n(tile_idx),
          -- Facing NoC
          noc1_data_out      => noc1_data_n_in(tile_idx),
          noc2_data_out      => noc2_data_n_in(tile_idx),
          noc3_data_out      => noc3_data_n_in(tile_idx),
          noc4_data_out      => noc4_data_n_in(tile_idx),
          noc5_data_out      => noc5_data_n_in(tile_idx),
          noc6_data_out      => noc6_data_n_in(tile_idx),
          noc1_data_void_out => noc1_data_void_out_rs_rx_n(tile_idx),
          noc2_data_void_out => noc2_data_void_out_rs_rx_n(tile_idx),
          noc3_data_void_out => noc3_data_void_out_rs_rx_n(tile_idx),
          noc4_data_void_out => noc4_data_void_out_rs_rx_n(tile_idx),
          noc5_data_void_out => noc5_data_void_out_rs_rx_n(tile_idx),
          noc6_data_void_out => noc6_data_void_out_rs_rx_n(tile_idx),
          noc1_stop_in       => noc1_stop_in_rs_rx_n(tile_idx),
          noc2_stop_in       => noc2_stop_in_rs_rx_n(tile_idx),
          noc3_stop_in       => noc3_stop_in_rs_rx_n(tile_idx),
          noc4_stop_in       => noc4_stop_in_rs_rx_n(tile_idx),
          noc5_stop_in       => noc5_stop_in_rs_rx_n(tile_idx),
          noc6_stop_in       => noc6_stop_in_rs_rx_n(tile_idx)
        );
    end generate rs_gen_n;   
  end generate d2dgen_n;
  no_d2dgen_n : if D2D_CHANNELS_N = 0 generate
  begin
    d2d_noc1_data_out_n <= (others => (others => '0'));
    d2d_noc2_data_out_n <= (others => (others => '0'));
    d2d_noc3_data_out_n <= (others => (others => '0'));
    d2d_noc4_data_out_n <= (others => (others => '0'));
    d2d_noc5_data_out_n <= (others => (others => '0'));
    d2d_noc6_data_out_n <= (others => (others => '0'));

    d2d_noc1_data_void_out_n <= (others => '1');
    d2d_noc2_data_void_out_n <= (others => '1');
    d2d_noc3_data_void_out_n <= (others => '1');
    d2d_noc4_data_void_out_n <= (others => '1');
    d2d_noc5_data_void_out_n <= (others => '1');
    d2d_noc6_data_void_out_n <= (others => '1');

    d2d_noc1_stop_out_n <= (others => '0');
    d2d_noc2_stop_out_n <= (others => '0');
    d2d_noc3_stop_out_n <= (others => '0');
    d2d_noc4_stop_out_n <= (others => '0');
    d2d_noc5_stop_out_n <= (others => '0');
    d2d_noc6_stop_out_n <= (others => '0');
  end generate no_d2dgen_n;

  d2dgen_s : if D2D_CHANNELS_S /= 0 generate
  begin
    rs_gen_s : for tile_idx in 0 to CFG_XLEN(BOARD_NUM) - 1 generate
      constant internal_tile_idx : natural := (CFG_YLEN(BOARD_NUM)-1)*CFG_XLEN(BOARD_NUM) + tile_idx;
    begin
      noc1_data_void_in_rs_tx_s(tile_idx) <= noc1_data_void_out(internal_tile_idx)(1);
      noc2_data_void_in_rs_tx_s(tile_idx) <= noc2_data_void_out(internal_tile_idx)(1);
      noc3_data_void_in_rs_tx_s(tile_idx) <= noc3_data_void_out(internal_tile_idx)(1);
      noc4_data_void_in_rs_tx_s(tile_idx) <= noc4_data_void_out(internal_tile_idx)(1);
      noc5_data_void_in_rs_tx_s(tile_idx) <= noc5_data_void_out(internal_tile_idx)(1);
      noc6_data_void_in_rs_tx_s(tile_idx) <= noc6_data_void_out(internal_tile_idx)(1);

      noc1_stop_in(internal_tile_idx)(1) <= noc1_stop_out_rs_tx_s(tile_idx);
      noc2_stop_in(internal_tile_idx)(1) <= noc2_stop_out_rs_tx_s(tile_idx);
      noc3_stop_in(internal_tile_idx)(1) <= noc3_stop_out_rs_tx_s(tile_idx);
      noc4_stop_in(internal_tile_idx)(1) <= noc4_stop_out_rs_tx_s(tile_idx);
      noc5_stop_in(internal_tile_idx)(1) <= noc5_stop_out_rs_tx_s(tile_idx);
      noc6_stop_in(internal_tile_idx)(1) <= noc6_stop_out_rs_tx_s(tile_idx);

      noc1_data_void_in(internal_tile_idx)(1) <= noc1_data_void_out_rs_rx_s(tile_idx);
      noc2_data_void_in(internal_tile_idx)(1) <= noc2_data_void_out_rs_rx_s(tile_idx);
      noc3_data_void_in(internal_tile_idx)(1) <= noc3_data_void_out_rs_rx_s(tile_idx);
      noc4_data_void_in(internal_tile_idx)(1) <= noc4_data_void_out_rs_rx_s(tile_idx);
      noc5_data_void_in(internal_tile_idx)(1) <= noc5_data_void_out_rs_rx_s(tile_idx);
      noc6_data_void_in(internal_tile_idx)(1) <= noc6_data_void_out_rs_rx_s(tile_idx);

      noc1_stop_in_rs_rx_s(tile_idx) <= noc1_stop_out(internal_tile_idx)(1);
      noc2_stop_in_rs_rx_s(tile_idx) <= noc2_stop_out(internal_tile_idx)(1);
      noc3_stop_in_rs_rx_s(tile_idx) <= noc3_stop_out(internal_tile_idx)(1);
      noc4_stop_in_rs_rx_s(tile_idx) <= noc4_stop_out(internal_tile_idx)(1);
      noc5_stop_in_rs_rx_s(tile_idx) <= noc5_stop_out(internal_tile_idx)(1);
      noc6_stop_in_rs_rx_s(tile_idx) <= noc6_stop_out(internal_tile_idx)(1);

      rs_tx_s_tile : relay_station_tile
        port map (
          clk => sys_clk_int(0),
          rst => rst_inv,
          -- Facing NoC
          noc1_data_in       => noc1_data_s_out(internal_tile_idx),
          noc2_data_in       => noc2_data_s_out(internal_tile_idx),
          noc3_data_in       => noc3_data_s_out(internal_tile_idx),
          noc4_data_in       => noc4_data_s_out(internal_tile_idx),
          noc5_data_in       => noc5_data_s_out(internal_tile_idx),
          noc6_data_in       => noc6_data_s_out(internal_tile_idx),
          noc1_data_void_in  => noc1_data_void_in_rs_tx_s(tile_idx),
          noc2_data_void_in  => noc2_data_void_in_rs_tx_s(tile_idx),
          noc3_data_void_in  => noc3_data_void_in_rs_tx_s(tile_idx),
          noc4_data_void_in  => noc4_data_void_in_rs_tx_s(tile_idx),
          noc5_data_void_in  => noc5_data_void_in_rs_tx_s(tile_idx),
          noc6_data_void_in  => noc6_data_void_in_rs_tx_s(tile_idx),
          noc1_stop_out      => noc1_stop_out_rs_tx_s(tile_idx),
          noc2_stop_out      => noc2_stop_out_rs_tx_s(tile_idx),
          noc3_stop_out      => noc3_stop_out_rs_tx_s(tile_idx),
          noc4_stop_out      => noc4_stop_out_rs_tx_s(tile_idx),
          noc5_stop_out      => noc5_stop_out_rs_tx_s(tile_idx),
          noc6_stop_out      => noc6_stop_out_rs_tx_s(tile_idx),
          -- Facing D2D
          noc1_data_out      => d2d_noc1_data_out_s(tile_idx),
          noc2_data_out      => d2d_noc2_data_out_s(tile_idx),
          noc3_data_out      => d2d_noc3_data_out_s(tile_idx),
          noc4_data_out      => d2d_noc4_data_out_s(tile_idx),
          noc5_data_out      => d2d_noc5_data_out_s(tile_idx),
          noc6_data_out      => d2d_noc6_data_out_s(tile_idx),
          noc1_data_void_out => d2d_noc1_data_void_out_s(tile_idx),
          noc2_data_void_out => d2d_noc2_data_void_out_s(tile_idx),
          noc3_data_void_out => d2d_noc3_data_void_out_s(tile_idx),
          noc4_data_void_out => d2d_noc4_data_void_out_s(tile_idx),
          noc5_data_void_out => d2d_noc5_data_void_out_s(tile_idx),
          noc6_data_void_out => d2d_noc6_data_void_out_s(tile_idx),
          noc1_stop_in       => d2d_noc1_stop_in_s(tile_idx),
          noc2_stop_in       => d2d_noc2_stop_in_s(tile_idx),
          noc3_stop_in       => d2d_noc3_stop_in_s(tile_idx),
          noc4_stop_in       => d2d_noc4_stop_in_s(tile_idx),
          noc5_stop_in       => d2d_noc5_stop_in_s(tile_idx),
          noc6_stop_in       => d2d_noc6_stop_in_s(tile_idx)
        );

      rs_rx_s_tile : relay_station_tile
        port map (
          clk => sys_clk_int(0),
          rst => rst_inv,
          -- Facing D2D
          noc1_data_in       => d2d_noc1_data_in_s(tile_idx),
          noc2_data_in       => d2d_noc2_data_in_s(tile_idx),
          noc3_data_in       => d2d_noc3_data_in_s(tile_idx),
          noc4_data_in       => d2d_noc4_data_in_s(tile_idx),
          noc5_data_in       => d2d_noc5_data_in_s(tile_idx),
          noc6_data_in       => d2d_noc6_data_in_s(tile_idx),
          noc1_data_void_in  => d2d_noc1_data_void_in_s(tile_idx),
          noc2_data_void_in  => d2d_noc2_data_void_in_s(tile_idx),
          noc3_data_void_in  => d2d_noc3_data_void_in_s(tile_idx),
          noc4_data_void_in  => d2d_noc4_data_void_in_s(tile_idx),
          noc5_data_void_in  => d2d_noc5_data_void_in_s(tile_idx),
          noc6_data_void_in  => d2d_noc6_data_void_in_s(tile_idx),
          noc1_stop_out      => d2d_noc1_stop_out_s(tile_idx),
          noc2_stop_out      => d2d_noc2_stop_out_s(tile_idx),
          noc3_stop_out      => d2d_noc3_stop_out_s(tile_idx),
          noc4_stop_out      => d2d_noc4_stop_out_s(tile_idx),
          noc5_stop_out      => d2d_noc5_stop_out_s(tile_idx),
          noc6_stop_out      => d2d_noc6_stop_out_s(tile_idx),
          -- Facing NoC
          noc1_data_out      => noc1_data_s_in(internal_tile_idx),
          noc2_data_out      => noc2_data_s_in(internal_tile_idx),
          noc3_data_out      => noc3_data_s_in(internal_tile_idx),
          noc4_data_out      => noc4_data_s_in(internal_tile_idx),
          noc5_data_out      => noc5_data_s_in(internal_tile_idx),
          noc6_data_out      => noc6_data_s_in(internal_tile_idx),
          noc1_data_void_out => noc1_data_void_out_rs_rx_s(tile_idx),
          noc2_data_void_out => noc2_data_void_out_rs_rx_s(tile_idx),
          noc3_data_void_out => noc3_data_void_out_rs_rx_s(tile_idx),
          noc4_data_void_out => noc4_data_void_out_rs_rx_s(tile_idx),
          noc5_data_void_out => noc5_data_void_out_rs_rx_s(tile_idx),
          noc6_data_void_out => noc6_data_void_out_rs_rx_s(tile_idx),
          noc1_stop_in       => noc1_stop_in_rs_rx_s(tile_idx),
          noc2_stop_in       => noc2_stop_in_rs_rx_s(tile_idx),
          noc3_stop_in       => noc3_stop_in_rs_rx_s(tile_idx),
          noc4_stop_in       => noc4_stop_in_rs_rx_s(tile_idx),
          noc5_stop_in       => noc5_stop_in_rs_rx_s(tile_idx),
          noc6_stop_in       => noc6_stop_in_rs_rx_s(tile_idx)
        );
    end generate rs_gen_s;
  end generate d2dgen_s;
  no_d2dgen_s : if D2D_CHANNELS_S = 0 generate
  begin
    d2d_noc1_data_out_s <= (others => (others => '0'));
    d2d_noc2_data_out_s <= (others => (others => '0'));
    d2d_noc3_data_out_s <= (others => (others => '0'));
    d2d_noc4_data_out_s <= (others => (others => '0'));
    d2d_noc5_data_out_s <= (others => (others => '0'));
    d2d_noc6_data_out_s <= (others => (others => '0'));

    d2d_noc1_data_void_out_s <= (others => '1');
    d2d_noc2_data_void_out_s <= (others => '1');
    d2d_noc3_data_void_out_s <= (others => '1');
    d2d_noc4_data_void_out_s <= (others => '1');
    d2d_noc5_data_void_out_s <= (others => '1');
    d2d_noc6_data_void_out_s <= (others => '1');

    d2d_noc1_stop_out_s <= (others => '0');
    d2d_noc2_stop_out_s <= (others => '0');
    d2d_noc3_stop_out_s <= (others => '0');
    d2d_noc4_stop_out_s <= (others => '0');
    d2d_noc5_stop_out_s <= (others => '0');
    d2d_noc6_stop_out_s <= (others => '0');
  end generate no_d2dgen_s;

  -- E and W modules.
  d2dgen_w : if D2D_CHANNELS_W /= 0 generate
  begin
    rs_gen_w : for tile_idx in 0 to CFG_YLEN(BOARD_NUM) - 1 generate
      constant internal_tile_idx : natural := CFG_XLEN(BOARD_NUM)*tile_idx;
    begin
      noc1_data_w_in(internal_tile_idx) <= noc1_data_out_rs_rx_w(tile_idx);
      noc2_data_w_in(internal_tile_idx) <= noc2_data_out_rs_rx_w(tile_idx);
      noc3_data_w_in(internal_tile_idx) <= noc3_data_out_rs_rx_w(tile_idx);
      noc4_data_w_in(internal_tile_idx) <= noc4_data_out_rs_rx_w(tile_idx);
      noc5_data_w_in(internal_tile_idx) <= noc5_data_out_rs_rx_w(tile_idx);
      noc6_data_w_in(internal_tile_idx) <= noc6_data_out_rs_rx_w(tile_idx);

      noc1_data_in_rs_tx_w(tile_idx) <= noc1_data_w_out(internal_tile_idx);
      noc2_data_in_rs_tx_w(tile_idx) <= noc2_data_w_out(internal_tile_idx);
      noc3_data_in_rs_tx_w(tile_idx) <= noc3_data_w_out(internal_tile_idx);
      noc4_data_in_rs_tx_w(tile_idx) <= noc4_data_w_out(internal_tile_idx);
      noc5_data_in_rs_tx_w(tile_idx) <= noc5_data_w_out(internal_tile_idx);
      noc6_data_in_rs_tx_w(tile_idx) <= noc6_data_w_out(internal_tile_idx);

      noc1_data_void_in_rs_tx_w(tile_idx) <= noc1_data_void_out(internal_tile_idx)(2);
      noc2_data_void_in_rs_tx_w(tile_idx) <= noc2_data_void_out(internal_tile_idx)(2);
      noc3_data_void_in_rs_tx_w(tile_idx) <= noc3_data_void_out(internal_tile_idx)(2);
      noc4_data_void_in_rs_tx_w(tile_idx) <= noc4_data_void_out(internal_tile_idx)(2);
      noc5_data_void_in_rs_tx_w(tile_idx) <= noc5_data_void_out(internal_tile_idx)(2);
      noc6_data_void_in_rs_tx_w(tile_idx) <= noc6_data_void_out(internal_tile_idx)(2);

      noc1_stop_in(internal_tile_idx)(2) <= noc1_stop_out_rs_tx_w(tile_idx);
      noc2_stop_in(internal_tile_idx)(2) <= noc2_stop_out_rs_tx_w(tile_idx);
      noc3_stop_in(internal_tile_idx)(2) <= noc3_stop_out_rs_tx_w(tile_idx);
      noc4_stop_in(internal_tile_idx)(2) <= noc4_stop_out_rs_tx_w(tile_idx);
      noc5_stop_in(internal_tile_idx)(2) <= noc5_stop_out_rs_tx_w(tile_idx);
      noc6_stop_in(internal_tile_idx)(2) <= noc6_stop_out_rs_tx_w(tile_idx);

      noc1_data_void_in(internal_tile_idx)(2) <= noc1_data_void_out_rs_rx_w(tile_idx);
      noc2_data_void_in(internal_tile_idx)(2) <= noc2_data_void_out_rs_rx_w(tile_idx);
      noc3_data_void_in(internal_tile_idx)(2) <= noc3_data_void_out_rs_rx_w(tile_idx);
      noc4_data_void_in(internal_tile_idx)(2) <= noc4_data_void_out_rs_rx_w(tile_idx);
      noc5_data_void_in(internal_tile_idx)(2) <= noc5_data_void_out_rs_rx_w(tile_idx);
      noc6_data_void_in(internal_tile_idx)(2) <= noc6_data_void_out_rs_rx_w(tile_idx);

      noc1_stop_in_rs_rx_w(tile_idx) <= noc1_stop_out(internal_tile_idx)(2);
      noc2_stop_in_rs_rx_w(tile_idx) <= noc2_stop_out(internal_tile_idx)(2);
      noc3_stop_in_rs_rx_w(tile_idx) <= noc3_stop_out(internal_tile_idx)(2);
      noc4_stop_in_rs_rx_w(tile_idx) <= noc4_stop_out(internal_tile_idx)(2);
      noc5_stop_in_rs_rx_w(tile_idx) <= noc5_stop_out(internal_tile_idx)(2);
      noc6_stop_in_rs_rx_w(tile_idx) <= noc6_stop_out(internal_tile_idx)(2);

      rs_tx_w_tile : relay_station_tile
        port map (
          clk => sys_clk_int(0),
          rst => rst_inv,
          -- Facing NoC
          noc1_data_in       => noc1_data_in_rs_tx_w(tile_idx),
          noc2_data_in       => noc2_data_in_rs_tx_w(tile_idx),
          noc3_data_in       => noc3_data_in_rs_tx_w(tile_idx),
          noc4_data_in       => noc4_data_in_rs_tx_w(tile_idx),
          noc5_data_in       => noc5_data_in_rs_tx_w(tile_idx),
          noc6_data_in       => noc6_data_in_rs_tx_w(tile_idx),
          noc1_data_void_in  => noc1_data_void_in_rs_tx_w(tile_idx),
          noc2_data_void_in  => noc2_data_void_in_rs_tx_w(tile_idx),
          noc3_data_void_in  => noc3_data_void_in_rs_tx_w(tile_idx),
          noc4_data_void_in  => noc4_data_void_in_rs_tx_w(tile_idx),
          noc5_data_void_in  => noc5_data_void_in_rs_tx_w(tile_idx),
          noc6_data_void_in  => noc6_data_void_in_rs_tx_w(tile_idx),
          noc1_stop_out      => noc1_stop_out_rs_tx_w(tile_idx),
          noc2_stop_out      => noc2_stop_out_rs_tx_w(tile_idx),
          noc3_stop_out      => noc3_stop_out_rs_tx_w(tile_idx),
          noc4_stop_out      => noc4_stop_out_rs_tx_w(tile_idx),
          noc5_stop_out      => noc5_stop_out_rs_tx_w(tile_idx),
          noc6_stop_out      => noc6_stop_out_rs_tx_w(tile_idx),
          -- Facing D2D
          noc1_data_out      => d2d_noc1_data_out_w(tile_idx),
          noc2_data_out      => d2d_noc2_data_out_w(tile_idx),
          noc3_data_out      => d2d_noc3_data_out_w(tile_idx),
          noc4_data_out      => d2d_noc4_data_out_w(tile_idx),
          noc5_data_out      => d2d_noc5_data_out_w(tile_idx),
          noc6_data_out      => d2d_noc6_data_out_w(tile_idx),
          noc1_data_void_out => d2d_noc1_data_void_out_w(tile_idx),
          noc2_data_void_out => d2d_noc2_data_void_out_w(tile_idx),
          noc3_data_void_out => d2d_noc3_data_void_out_w(tile_idx),
          noc4_data_void_out => d2d_noc4_data_void_out_w(tile_idx),
          noc5_data_void_out => d2d_noc5_data_void_out_w(tile_idx),
          noc6_data_void_out => d2d_noc6_data_void_out_w(tile_idx),
          noc1_stop_in       => d2d_noc1_stop_in_w(tile_idx),
          noc2_stop_in       => d2d_noc2_stop_in_w(tile_idx),
          noc3_stop_in       => d2d_noc3_stop_in_w(tile_idx),
          noc4_stop_in       => d2d_noc4_stop_in_w(tile_idx),
          noc5_stop_in       => d2d_noc5_stop_in_w(tile_idx),
          noc6_stop_in       => d2d_noc6_stop_in_w(tile_idx)
        );

      rs_rx_w_tile : relay_station_tile
        port map (
          clk => sys_clk_int(0),
          rst => rst_inv,
          -- Facing D2D
          noc1_data_in       => d2d_noc1_data_in_w(tile_idx),
          noc2_data_in       => d2d_noc2_data_in_w(tile_idx),
          noc3_data_in       => d2d_noc3_data_in_w(tile_idx),
          noc4_data_in       => d2d_noc4_data_in_w(tile_idx),
          noc5_data_in       => d2d_noc5_data_in_w(tile_idx),
          noc6_data_in       => d2d_noc6_data_in_w(tile_idx),
          noc1_data_void_in  => d2d_noc1_data_void_in_w(tile_idx),
          noc2_data_void_in  => d2d_noc2_data_void_in_w(tile_idx),
          noc3_data_void_in  => d2d_noc3_data_void_in_w(tile_idx),
          noc4_data_void_in  => d2d_noc4_data_void_in_w(tile_idx),
          noc5_data_void_in  => d2d_noc5_data_void_in_w(tile_idx),
          noc6_data_void_in  => d2d_noc6_data_void_in_w(tile_idx),
          noc1_stop_out      => d2d_noc1_stop_out_w(tile_idx),
          noc2_stop_out      => d2d_noc2_stop_out_w(tile_idx),
          noc3_stop_out      => d2d_noc3_stop_out_w(tile_idx),
          noc4_stop_out      => d2d_noc4_stop_out_w(tile_idx),
          noc5_stop_out      => d2d_noc5_stop_out_w(tile_idx),
          noc6_stop_out      => d2d_noc6_stop_out_w(tile_idx),
          -- Facing NoC
          noc1_data_out      => noc1_data_out_rs_rx_w(tile_idx),
          noc2_data_out      => noc2_data_out_rs_rx_w(tile_idx),
          noc3_data_out      => noc3_data_out_rs_rx_w(tile_idx),
          noc4_data_out      => noc4_data_out_rs_rx_w(tile_idx),
          noc5_data_out      => noc5_data_out_rs_rx_w(tile_idx),
          noc6_data_out      => noc6_data_out_rs_rx_w(tile_idx),
          noc1_data_void_out => noc1_data_void_out_rs_rx_w(tile_idx),
          noc2_data_void_out => noc2_data_void_out_rs_rx_w(tile_idx),
          noc3_data_void_out => noc3_data_void_out_rs_rx_w(tile_idx),
          noc4_data_void_out => noc4_data_void_out_rs_rx_w(tile_idx),
          noc5_data_void_out => noc5_data_void_out_rs_rx_w(tile_idx),
          noc6_data_void_out => noc6_data_void_out_rs_rx_w(tile_idx),
          noc1_stop_in       => noc1_stop_in_rs_rx_w(tile_idx),
          noc2_stop_in       => noc2_stop_in_rs_rx_w(tile_idx),
          noc3_stop_in       => noc3_stop_in_rs_rx_w(tile_idx),
          noc4_stop_in       => noc4_stop_in_rs_rx_w(tile_idx),
          noc5_stop_in       => noc5_stop_in_rs_rx_w(tile_idx),
          noc6_stop_in       => noc6_stop_in_rs_rx_w(tile_idx)
        );
    end generate rs_gen_w;
  end generate d2dgen_w;
  no_d2dgen_w : if D2D_CHANNELS_W = 0 generate
  begin
    d2d_noc1_data_out_w <= (others => (others => '0'));
    d2d_noc2_data_out_w <= (others => (others => '0'));
    d2d_noc3_data_out_w <= (others => (others => '0'));
    d2d_noc4_data_out_w <= (others => (others => '0'));
    d2d_noc5_data_out_w <= (others => (others => '0'));
    d2d_noc6_data_out_w <= (others => (others => '0'));

    d2d_noc1_data_void_out_w <= (others => '1');
    d2d_noc2_data_void_out_w <= (others => '1');
    d2d_noc3_data_void_out_w <= (others => '1');
    d2d_noc4_data_void_out_w <= (others => '1');
    d2d_noc5_data_void_out_w <= (others => '1');
    d2d_noc6_data_void_out_w <= (others => '1');

    d2d_noc1_stop_out_w <= (others => '0');
    d2d_noc2_stop_out_w <= (others => '0');
    d2d_noc3_stop_out_w <= (others => '0');
    d2d_noc4_stop_out_w <= (others => '0');
    d2d_noc5_stop_out_w <= (others => '0');
    d2d_noc6_stop_out_w <= (others => '0');
  end generate no_d2dgen_w;

  d2dgen_e : if D2D_CHANNELS_E /= 0 generate
  begin
    rs_gen_e : for tile_idx in 0 to CFG_YLEN(BOARD_NUM) - 1 generate
      constant internal_tile_idx : natural := CFG_XLEN(BOARD_NUM)*tile_idx + CFG_XLEN(BOARD_NUM) - 1;
    begin
      noc1_data_e_in(internal_tile_idx) <= noc1_data_out_rs_rx_e(tile_idx);
      noc2_data_e_in(internal_tile_idx) <= noc2_data_out_rs_rx_e(tile_idx);
      noc3_data_e_in(internal_tile_idx) <= noc3_data_out_rs_rx_e(tile_idx);
      noc4_data_e_in(internal_tile_idx) <= noc4_data_out_rs_rx_e(tile_idx);
      noc5_data_e_in(internal_tile_idx) <= noc5_data_out_rs_rx_e(tile_idx);
      noc6_data_e_in(internal_tile_idx) <= noc6_data_out_rs_rx_e(tile_idx);

      noc1_data_in_rs_tx_e(tile_idx) <= noc1_data_e_out(internal_tile_idx);
      noc2_data_in_rs_tx_e(tile_idx) <= noc2_data_e_out(internal_tile_idx);
      noc3_data_in_rs_tx_e(tile_idx) <= noc3_data_e_out(internal_tile_idx);
      noc4_data_in_rs_tx_e(tile_idx) <= noc4_data_e_out(internal_tile_idx);
      noc5_data_in_rs_tx_e(tile_idx) <= noc5_data_e_out(internal_tile_idx);
      noc6_data_in_rs_tx_e(tile_idx) <= noc6_data_e_out(internal_tile_idx);

      noc1_data_void_in_rs_tx_e(tile_idx) <= noc1_data_void_out(internal_tile_idx)(3);
      noc2_data_void_in_rs_tx_e(tile_idx) <= noc2_data_void_out(internal_tile_idx)(3);
      noc3_data_void_in_rs_tx_e(tile_idx) <= noc3_data_void_out(internal_tile_idx)(3);
      noc4_data_void_in_rs_tx_e(tile_idx) <= noc4_data_void_out(internal_tile_idx)(3);
      noc5_data_void_in_rs_tx_e(tile_idx) <= noc5_data_void_out(internal_tile_idx)(3);
      noc6_data_void_in_rs_tx_e(tile_idx) <= noc6_data_void_out(internal_tile_idx)(3);

      noc1_stop_in(internal_tile_idx)(3) <= noc1_stop_out_rs_tx_e(tile_idx);
      noc2_stop_in(internal_tile_idx)(3) <= noc2_stop_out_rs_tx_e(tile_idx);
      noc3_stop_in(internal_tile_idx)(3) <= noc3_stop_out_rs_tx_e(tile_idx);
      noc4_stop_in(internal_tile_idx)(3) <= noc4_stop_out_rs_tx_e(tile_idx);
      noc5_stop_in(internal_tile_idx)(3) <= noc5_stop_out_rs_tx_e(tile_idx);
      noc6_stop_in(internal_tile_idx)(3) <= noc6_stop_out_rs_tx_e(tile_idx);

      noc1_data_void_in(internal_tile_idx)(3) <= noc1_data_void_out_rs_rx_e(tile_idx);
      noc2_data_void_in(internal_tile_idx)(3) <= noc2_data_void_out_rs_rx_e(tile_idx);
      noc3_data_void_in(internal_tile_idx)(3) <= noc3_data_void_out_rs_rx_e(tile_idx);
      noc4_data_void_in(internal_tile_idx)(3) <= noc4_data_void_out_rs_rx_e(tile_idx);
      noc5_data_void_in(internal_tile_idx)(3) <= noc5_data_void_out_rs_rx_e(tile_idx);
      noc6_data_void_in(internal_tile_idx)(3) <= noc6_data_void_out_rs_rx_e(tile_idx);

      noc1_stop_in_rs_rx_e(tile_idx) <= noc1_stop_out(internal_tile_idx)(3);
      noc2_stop_in_rs_rx_e(tile_idx) <= noc2_stop_out(internal_tile_idx)(3);
      noc3_stop_in_rs_rx_e(tile_idx) <= noc3_stop_out(internal_tile_idx)(3);
      noc4_stop_in_rs_rx_e(tile_idx) <= noc4_stop_out(internal_tile_idx)(3);
      noc5_stop_in_rs_rx_e(tile_idx) <= noc5_stop_out(internal_tile_idx)(3);
      noc6_stop_in_rs_rx_e(tile_idx) <= noc6_stop_out(internal_tile_idx)(3);

      rs_tx_e_tile : relay_station_tile
        port map (
          clk => sys_clk_int(0),
          rst => rst_inv,
          -- Facing NoC
          noc1_data_in       => noc1_data_in_rs_tx_e(tile_idx),
          noc2_data_in       => noc2_data_in_rs_tx_e(tile_idx),
          noc3_data_in       => noc3_data_in_rs_tx_e(tile_idx),
          noc4_data_in       => noc4_data_in_rs_tx_e(tile_idx),
          noc5_data_in       => noc5_data_in_rs_tx_e(tile_idx),
          noc6_data_in       => noc6_data_in_rs_tx_e(tile_idx),
          noc1_data_void_in  => noc1_data_void_in_rs_tx_e(tile_idx),
          noc2_data_void_in  => noc2_data_void_in_rs_tx_e(tile_idx),
          noc3_data_void_in  => noc3_data_void_in_rs_tx_e(tile_idx),
          noc4_data_void_in  => noc4_data_void_in_rs_tx_e(tile_idx),
          noc5_data_void_in  => noc5_data_void_in_rs_tx_e(tile_idx),
          noc6_data_void_in  => noc6_data_void_in_rs_tx_e(tile_idx),
          noc1_stop_out      => noc1_stop_out_rs_tx_e(tile_idx),
          noc2_stop_out      => noc2_stop_out_rs_tx_e(tile_idx),
          noc3_stop_out      => noc3_stop_out_rs_tx_e(tile_idx),
          noc4_stop_out      => noc4_stop_out_rs_tx_e(tile_idx),
          noc5_stop_out      => noc5_stop_out_rs_tx_e(tile_idx),
          noc6_stop_out      => noc6_stop_out_rs_tx_e(tile_idx),
          -- Facing D2D
          noc1_data_out      => d2d_noc1_data_out_e(tile_idx),
          noc2_data_out      => d2d_noc2_data_out_e(tile_idx),
          noc3_data_out      => d2d_noc3_data_out_e(tile_idx),
          noc4_data_out      => d2d_noc4_data_out_e(tile_idx),
          noc5_data_out      => d2d_noc5_data_out_e(tile_idx),
          noc6_data_out      => d2d_noc6_data_out_e(tile_idx),
          noc1_data_void_out => d2d_noc1_data_void_out_e(tile_idx),
          noc2_data_void_out => d2d_noc2_data_void_out_e(tile_idx),
          noc3_data_void_out => d2d_noc3_data_void_out_e(tile_idx),
          noc4_data_void_out => d2d_noc4_data_void_out_e(tile_idx),
          noc5_data_void_out => d2d_noc5_data_void_out_e(tile_idx),
          noc6_data_void_out => d2d_noc6_data_void_out_e(tile_idx),
          noc1_stop_in       => d2d_noc1_stop_in_e(tile_idx),
          noc2_stop_in       => d2d_noc2_stop_in_e(tile_idx),
          noc3_stop_in       => d2d_noc3_stop_in_e(tile_idx),
          noc4_stop_in       => d2d_noc4_stop_in_e(tile_idx),
          noc5_stop_in       => d2d_noc5_stop_in_e(tile_idx),
          noc6_stop_in       => d2d_noc6_stop_in_e(tile_idx)
        );

      rs_rx_e_tile : relay_station_tile
        port map (
          clk => sys_clk_int(0),
          rst => rst_inv,
          -- Facing D2D
          noc1_data_in       => d2d_noc1_data_in_e(tile_idx),
          noc2_data_in       => d2d_noc2_data_in_e(tile_idx),
          noc3_data_in       => d2d_noc3_data_in_e(tile_idx),
          noc4_data_in       => d2d_noc4_data_in_e(tile_idx),
          noc5_data_in       => d2d_noc5_data_in_e(tile_idx),
          noc6_data_in       => d2d_noc6_data_in_e(tile_idx),
          noc1_data_void_in  => d2d_noc1_data_void_in_e(tile_idx),
          noc2_data_void_in  => d2d_noc2_data_void_in_e(tile_idx),
          noc3_data_void_in  => d2d_noc3_data_void_in_e(tile_idx),
          noc4_data_void_in  => d2d_noc4_data_void_in_e(tile_idx),
          noc5_data_void_in  => d2d_noc5_data_void_in_e(tile_idx),
          noc6_data_void_in  => d2d_noc6_data_void_in_e(tile_idx),
          noc1_stop_out      => d2d_noc1_stop_out_e(tile_idx),
          noc2_stop_out      => d2d_noc2_stop_out_e(tile_idx),
          noc3_stop_out      => d2d_noc3_stop_out_e(tile_idx),
          noc4_stop_out      => d2d_noc4_stop_out_e(tile_idx),
          noc5_stop_out      => d2d_noc5_stop_out_e(tile_idx),
          noc6_stop_out      => d2d_noc6_stop_out_e(tile_idx),
          -- Facing NoC
          noc1_data_out      => noc1_data_out_rs_rx_e(tile_idx),
          noc2_data_out      => noc2_data_out_rs_rx_e(tile_idx),
          noc3_data_out      => noc3_data_out_rs_rx_e(tile_idx),
          noc4_data_out      => noc4_data_out_rs_rx_e(tile_idx),
          noc5_data_out      => noc5_data_out_rs_rx_e(tile_idx),
          noc6_data_out      => noc6_data_out_rs_rx_e(tile_idx),
          noc1_data_void_out => noc1_data_void_out_rs_rx_e(tile_idx),
          noc2_data_void_out => noc2_data_void_out_rs_rx_e(tile_idx),
          noc3_data_void_out => noc3_data_void_out_rs_rx_e(tile_idx),
          noc4_data_void_out => noc4_data_void_out_rs_rx_e(tile_idx),
          noc5_data_void_out => noc5_data_void_out_rs_rx_e(tile_idx),
          noc6_data_void_out => noc6_data_void_out_rs_rx_e(tile_idx),
          noc1_stop_in       => noc1_stop_in_rs_rx_e(tile_idx),
          noc2_stop_in       => noc2_stop_in_rs_rx_e(tile_idx),
          noc3_stop_in       => noc3_stop_in_rs_rx_e(tile_idx),
          noc4_stop_in       => noc4_stop_in_rs_rx_e(tile_idx),
          noc5_stop_in       => noc5_stop_in_rs_rx_e(tile_idx),
          noc6_stop_in       => noc6_stop_in_rs_rx_e(tile_idx)
        );
    end generate rs_gen_e;
  end generate d2dgen_e;
  no_d2dgen_e : if D2D_CHANNELS_E = 0 generate
  begin
    d2d_noc1_data_out_e <= (others => (others => '0'));
    d2d_noc2_data_out_e <= (others => (others => '0'));
    d2d_noc3_data_out_e <= (others => (others => '0'));
    d2d_noc4_data_out_e <= (others => (others => '0'));
    d2d_noc5_data_out_e <= (others => (others => '0'));
    d2d_noc6_data_out_e <= (others => (others => '0'));

    d2d_noc1_data_void_out_e <= (others => '1');
    d2d_noc2_data_void_out_e <= (others => '1');
    d2d_noc3_data_void_out_e <= (others => '1');
    d2d_noc4_data_void_out_e <= (others => '1');
    d2d_noc5_data_void_out_e <= (others => '1');
    d2d_noc6_data_void_out_e <= (others => '1');

    d2d_noc1_stop_out_e <= (others => '0');
    d2d_noc2_stop_out_e <= (others => '0');
    d2d_noc3_stop_out_e <= (others => '0');
    d2d_noc4_stop_out_e <= (others => '0');
    d2d_noc5_stop_out_e <= (others => '0');
    d2d_noc6_stop_out_e <= (others => '0');
  end generate no_d2dgen_e;

  meshgen_y: for i in 0 to CFG_YLEN(BOARD_NUM)-1 generate
    meshgen_x: for j in 0 to CFG_XLEN(BOARD_NUM)-1 generate

      y_0: if (i=0) generate
        d2d_n: if D2D_CHANNELS_N = 0 generate
          -- D2D Rx --> NOC Down
          noc1_data_n_in(j) <= (others => '0');
          noc1_data_void_in(j)(0) <= '1';
          noc2_data_n_in(j) <= (others => '0');
          noc2_data_void_in(j)(0) <= '1';
          noc3_data_n_in(j) <= (others => '0');
          noc3_data_void_in(j)(0) <= '1';
          noc4_data_n_in(j) <= (others => '0');
          noc4_data_void_in(j)(0) <= '1';
          noc5_data_n_in(j) <= (others => '0');
          noc5_data_void_in(j)(0) <= '1';
          noc6_data_n_in(j) <= (others => '0'); 
          noc6_data_void_in(j)(0) <= '1';
          noc1_stop_in(j)(0) <= '0';
          noc2_stop_in(j)(0) <= '0';
          noc3_stop_in(j)(0) <= '0';
          noc4_stop_in(j)(0) <= '0';
          noc5_stop_in(j)(0) <= '0';
          noc6_stop_in(j)(0) <= '0';
        end generate d2d_n;
      end generate y_0;

      y_non_0 : if (i /= 0) generate
        -- North port is connected
        noc1_data_n_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc1_data_s_out((i-1)*CFG_XLEN(BOARD_NUM) + j);
        noc1_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(0) <= noc1_data_void_out((i-1)*CFG_XLEN(BOARD_NUM) + j)(1);
        noc1_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(0)      <= noc1_stop_out((i-1)*CFG_XLEN(BOARD_NUM) + j)(1);
        noc2_data_n_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc2_data_s_out((i-1)*CFG_XLEN(BOARD_NUM) + j);
        noc2_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(0) <= noc2_data_void_out((i-1)*CFG_XLEN(BOARD_NUM) + j)(1);
        noc2_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(0)      <= noc2_stop_out((i-1)*CFG_XLEN(BOARD_NUM) + j)(1);
        noc3_data_n_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc3_data_s_out((i-1)*CFG_XLEN(BOARD_NUM) + j);
        noc3_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(0) <= noc3_data_void_out((i-1)*CFG_XLEN(BOARD_NUM) + j)(1);
        noc3_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(0)      <= noc3_stop_out((i-1)*CFG_XLEN(BOARD_NUM) + j)(1);
        noc4_data_n_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc4_data_s_out((i-1)*CFG_XLEN(BOARD_NUM) + j);
        noc4_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(0) <= noc4_data_void_out((i-1)*CFG_XLEN(BOARD_NUM) + j)(1);
        noc4_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(0)      <= noc4_stop_out((i-1)*CFG_XLEN(BOARD_NUM) + j)(1);
        noc5_data_n_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc5_data_s_out((i-1)*CFG_XLEN(BOARD_NUM) + j);
        noc5_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(0) <= noc5_data_void_out((i-1)*CFG_XLEN(BOARD_NUM) + j)(1);
        noc5_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(0)      <= noc5_stop_out((i-1)*CFG_XLEN(BOARD_NUM) + j)(1);
        noc6_data_n_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc6_data_s_out((i-1)*CFG_XLEN(BOARD_NUM) + j);
        noc6_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(0) <= noc6_data_void_out((i-1)*CFG_XLEN(BOARD_NUM) + j)(1);
        noc6_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(0)      <= noc6_stop_out((i-1)*CFG_XLEN(BOARD_NUM) + j)(1);
      end generate y_non_0;

      y_YLEN : if (i = CFG_YLEN(BOARD_NUM)-1) generate
        d2d_s: if D2D_CHANNELS_S = 0 generate
        -- South port is unconnected
          noc1_data_s_in(i*CFG_XLEN(BOARD_NUM) + j) <= (others => '0');
          noc1_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(1) <= '1';
          noc1_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(1) <= '0';
          noc2_data_s_in(i*CFG_XLEN(BOARD_NUM) + j) <= (others => '0');
          noc2_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(1) <= '1';
          noc2_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(1) <= '0';
          noc3_data_s_in(i*CFG_XLEN(BOARD_NUM) + j) <= (others => '0');
          noc3_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(1) <= '1';
          noc3_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(1) <= '0';
          noc4_data_s_in(i*CFG_XLEN(BOARD_NUM) + j) <= (others => '0');
          noc4_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(1) <= '1';
          noc4_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(1) <= '0';
          noc5_data_s_in(i*CFG_XLEN(BOARD_NUM) + j) <= (others => '0');
          noc5_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(1) <= '1';
          noc5_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(1) <= '0';
          noc6_data_s_in(i*CFG_XLEN(BOARD_NUM) + j) <= (others => '0');
          noc6_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(1) <= '1';
          noc6_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(1) <= '0';
        end generate d2d_s;
      end generate y_YLEN;

      y_non_YLEN : if (i /= CFG_YLEN(BOARD_NUM)-1) generate
        -- south port is connected
        noc1_data_s_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc1_data_n_out((i+1)*CFG_XLEN(BOARD_NUM) + j);
        noc1_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(1) <= noc1_data_void_out((i+1)*CFG_XLEN(BOARD_NUM) + j)(0);
        noc1_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(1)      <= noc1_stop_out((i+1)*CFG_XLEN(BOARD_NUM) + j)(0);
        noc2_data_s_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc2_data_n_out((i+1)*CFG_XLEN(BOARD_NUM) + j);
        noc2_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(1) <= noc2_data_void_out((i+1)*CFG_XLEN(BOARD_NUM) + j)(0);
        noc2_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(1)      <= noc2_stop_out((i+1)*CFG_XLEN(BOARD_NUM) + j)(0);
        noc3_data_s_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc3_data_n_out((i+1)*CFG_XLEN(BOARD_NUM) + j);
        noc3_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(1) <= noc3_data_void_out((i+1)*CFG_XLEN(BOARD_NUM) + j)(0);
        noc3_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(1)      <= noc3_stop_out((i+1)*CFG_XLEN(BOARD_NUM) + j)(0);
        noc4_data_s_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc4_data_n_out((i+1)*CFG_XLEN(BOARD_NUM) + j);
        noc4_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(1) <= noc4_data_void_out((i+1)*CFG_XLEN(BOARD_NUM) + j)(0);
        noc4_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(1)      <= noc4_stop_out((i+1)*CFG_XLEN(BOARD_NUM) + j)(0);
        noc5_data_s_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc5_data_n_out((i+1)*CFG_XLEN(BOARD_NUM) + j);
        noc5_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(1) <= noc5_data_void_out((i+1)*CFG_XLEN(BOARD_NUM) + j)(0);
        noc5_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(1)      <= noc5_stop_out((i+1)*CFG_XLEN(BOARD_NUM) + j)(0);
        noc6_data_s_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc6_data_n_out((i+1)*CFG_XLEN(BOARD_NUM) + j);
        noc6_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(1) <= noc6_data_void_out((i+1)*CFG_XLEN(BOARD_NUM) + j)(0);
        noc6_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(1)      <= noc6_stop_out((i+1)*CFG_XLEN(BOARD_NUM) + j)(0);
      end generate y_non_YLEN;

      x_0 : if (j = 0) generate
        -- West port is unconnected
        d2d_w: if D2D_CHANNELS_W = 0 generate
          noc1_data_w_in(i*CFG_XLEN(BOARD_NUM) + j) <= (others => '0');
          noc1_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(2) <= '1';
          noc1_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(2) <= '0';
          noc2_data_w_in(i*CFG_XLEN(BOARD_NUM) + j) <= (others => '0');
          noc2_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(2) <= '1';
          noc2_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(2) <= '0';
          noc3_data_w_in(i*CFG_XLEN(BOARD_NUM) + j) <= (others => '0');
          noc3_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(2) <= '1';
          noc3_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(2) <= '0';
          noc4_data_w_in(i*CFG_XLEN(BOARD_NUM) + j) <= (others => '0');
          noc4_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(2) <= '1';
          noc4_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(2) <= '0';
          noc5_data_w_in(i*CFG_XLEN(BOARD_NUM) + j) <= (others => '0');
          noc5_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(2) <= '1';
          noc5_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(2) <= '0';
          noc6_data_w_in(i*CFG_XLEN(BOARD_NUM) + j) <= (others => '0');
          noc6_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(2) <= '1';
          noc6_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(2) <= '0';
        end generate d2d_w;
      end generate x_0;

      x_non_0 : if (j /= 0) generate
        -- West port is connected
        noc1_data_w_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc1_data_e_out(i*CFG_XLEN(BOARD_NUM) + j - 1);
        noc1_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(2) <= noc1_data_void_out(i*CFG_XLEN(BOARD_NUM) + j - 1)(3);
        noc1_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(2)      <= noc1_stop_out(i*CFG_XLEN(BOARD_NUM) + j - 1)(3);
        noc2_data_w_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc2_data_e_out(i*CFG_XLEN(BOARD_NUM) + j - 1);
        noc2_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(2) <= noc2_data_void_out(i*CFG_XLEN(BOARD_NUM) + j - 1)(3);
        noc2_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(2)      <= noc2_stop_out(i*CFG_XLEN(BOARD_NUM) + j - 1)(3);
        noc3_data_w_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc3_data_e_out(i*CFG_XLEN(BOARD_NUM) + j - 1);
        noc3_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(2) <= noc3_data_void_out(i*CFG_XLEN(BOARD_NUM) + j - 1)(3);
        noc3_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(2)      <= noc3_stop_out(i*CFG_XLEN(BOARD_NUM) + j - 1)(3);
        noc4_data_w_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc4_data_e_out(i*CFG_XLEN(BOARD_NUM) + j - 1);
        noc4_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(2) <= noc4_data_void_out(i*CFG_XLEN(BOARD_NUM) + j - 1)(3);
        noc4_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(2)      <= noc4_stop_out(i*CFG_XLEN(BOARD_NUM) + j - 1)(3);
        noc5_data_w_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc5_data_e_out(i*CFG_XLEN(BOARD_NUM) + j - 1);
        noc5_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(2) <= noc5_data_void_out(i*CFG_XLEN(BOARD_NUM) + j - 1)(3);
        noc5_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(2)      <= noc5_stop_out(i*CFG_XLEN(BOARD_NUM) + j - 1)(3);
        noc6_data_w_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc6_data_e_out(i*CFG_XLEN(BOARD_NUM) + j - 1);
        noc6_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(2) <= noc6_data_void_out(i*CFG_XLEN(BOARD_NUM) + j - 1)(3);
        noc6_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(2)      <= noc6_stop_out(i*CFG_XLEN(BOARD_NUM) + j - 1)(3);
      end generate x_non_0;

      x_XLEN : if (j = CFG_XLEN(BOARD_NUM)-1) generate
        -- East port is unconnected
        d2d_e: if D2D_CHANNELS_E = 0 generate
          noc1_data_e_in(i*CFG_XLEN(BOARD_NUM) + j) <= (others => '0');
          noc1_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(3) <= '1';
          noc1_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(3) <= '0';
          noc2_data_e_in(i*CFG_XLEN(BOARD_NUM) + j) <= (others => '0');
          noc2_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(3) <= '1';
          noc2_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(3) <= '0';
          noc3_data_e_in(i*CFG_XLEN(BOARD_NUM) + j) <= (others => '0');
          noc3_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(3) <= '1';
          noc3_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(3) <= '0';
          noc4_data_e_in(i*CFG_XLEN(BOARD_NUM) + j) <= (others => '0');
          noc4_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(3) <= '1';
          noc4_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(3) <= '0';
          noc5_data_e_in(i*CFG_XLEN(BOARD_NUM) + j) <= (others => '0');
          noc5_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(3) <= '1';
          noc5_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(3) <= '0';
          noc6_data_e_in(i*CFG_XLEN(BOARD_NUM) + j) <= (others => '0');
          noc6_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(3) <= '1';
          noc6_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(3) <= '0';
        end generate d2d_e;
      end generate x_XLEN;

      x_non_XLEN : if (j /= CFG_XLEN(BOARD_NUM)-1) generate
        -- East port is connected
        noc1_data_e_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc1_data_w_out(i*CFG_XLEN(BOARD_NUM) + j + 1);
        noc1_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(3) <= noc1_data_void_out(i*CFG_XLEN(BOARD_NUM) + j + 1)(2);
        noc1_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(3)      <= noc1_stop_out(i*CFG_XLEN(BOARD_NUM) + j + 1)(2);
        noc2_data_e_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc2_data_w_out(i*CFG_XLEN(BOARD_NUM) + j + 1);
        noc2_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(3) <= noc2_data_void_out(i*CFG_XLEN(BOARD_NUM) + j + 1)(2);
        noc2_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(3)      <= noc2_stop_out(i*CFG_XLEN(BOARD_NUM) + j + 1)(2);
        noc3_data_e_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc3_data_w_out(i*CFG_XLEN(BOARD_NUM) + j + 1);
        noc3_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(3) <= noc3_data_void_out(i*CFG_XLEN(BOARD_NUM) + j + 1)(2);
        noc3_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(3)      <= noc3_stop_out(i*CFG_XLEN(BOARD_NUM) + j + 1)(2);
        noc4_data_e_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc4_data_w_out(i*CFG_XLEN(BOARD_NUM) + j + 1);
        noc4_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(3) <= noc4_data_void_out(i*CFG_XLEN(BOARD_NUM) + j + 1)(2);
        noc4_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(3)      <= noc4_stop_out(i*CFG_XLEN(BOARD_NUM) + j + 1)(2);
        noc5_data_e_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc5_data_w_out(i*CFG_XLEN(BOARD_NUM) + j + 1);
        noc5_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(3) <= noc5_data_void_out(i*CFG_XLEN(BOARD_NUM) + j + 1)(2);
        noc5_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(3)      <= noc5_stop_out(i*CFG_XLEN(BOARD_NUM) + j + 1)(2);
        noc6_data_e_in(i*CFG_XLEN(BOARD_NUM) + j)       <= noc6_data_w_out(i*CFG_XLEN(BOARD_NUM) + j + 1);
        noc6_data_void_in(i*CFG_XLEN(BOARD_NUM) + j)(3) <= noc6_data_void_out(i*CFG_XLEN(BOARD_NUM) + j + 1)(2);
        noc6_stop_in(i*CFG_XLEN(BOARD_NUM) + j)(3)      <= noc6_stop_out(i*CFG_XLEN(BOARD_NUM) + j + 1)(2);
      end generate x_non_XLEN;

    end generate meshgen_x;
  end generate meshgen_y;


  router_gen : for i in 0 to CFG_CHIPLET_TILES(BOARD_NUM) - 1 generate
    constant GI : integer := CFG_CHIPLET_TILE_BASE(BOARD_NUM) + i;
  begin
    gen_io : if CFG_IO_TILE_CHIPLET(BOARD_NUM) = '1' generate
      constant io_idx : integer := io_tile_id(BOARD_NUM) - CFG_CHIPLET_TILE_BASE(BOARD_NUM);
    begin
      io_router : if i = io_idx generate
        noc_domain_socket_i : noc_domain_socket
          generic map (
            this_has_token_pm => 0,
            is_tile_io        => true,
            SIMULATION        => SIMULATION,
            ROUTER_PORTS      => set_router_ports(CFG_FABTECH, CFG_CHIPLET_COLS, CFG_CHIPLET_ROWS, CFG_XLEN(BOARD_NUM), CFG_YLEN(BOARD_NUM), tile_x(GI), tile_y(GI), chip_x(GI), chip_y(GI)),
            HAS_SYNC          => 1)
          port map (
            rst                     => rst_inv,
            noc_clk_lock            => '1',
            tile_rstn               => rst_int,
            noc_clk                 => sys_clk_int(0),
            tile_clk                => tile_clk(i),
            noc_rstn                => open,
            raw_rstn                => open,
            acc_clk                 => open,
            -- DCO config
            dco_freq_sel            => dco_freq_sel(i),
            dco_div_sel             => dco_div_sel(i),
            dco_fc_sel              => dco_fc_sel(i),
            dco_cc_sel              => dco_cc_sel(i),
            dco_clk_sel             => dco_clk_sel(i),
            dco_en                  => dco_en(i),
            dco_clk_delay_sel       => open,
            -- pad config
            pad_cfg                 => open,
            -- NoC
            noc1_data_n_in          => noc1_data_n_in(i),
            noc1_data_s_in          => noc1_data_s_in(i),
            noc1_data_w_in          => noc1_data_w_in(i),
            noc1_data_e_in          => noc1_data_e_in(i),
            noc1_data_void_in       => noc1_data_void_in(i),
            noc1_stop_in            => noc1_stop_in(i),
            noc1_data_n_out         => noc1_data_n_out(i),
            noc1_data_s_out         => noc1_data_s_out(i),
            noc1_data_w_out         => noc1_data_w_out(i),
            noc1_data_e_out         => noc1_data_e_out(i),
            noc1_data_void_out      => noc1_data_void_out(i),
            noc1_stop_out           => noc1_stop_out(i),
            noc2_data_n_in          => noc2_data_n_in(i),
            noc2_data_s_in          => noc2_data_s_in(i),
            noc2_data_w_in          => noc2_data_w_in(i),
            noc2_data_e_in          => noc2_data_e_in(i),
            noc2_data_void_in       => noc2_data_void_in(i),
            noc2_stop_in            => noc2_stop_in(i),
            noc2_data_n_out         => noc2_data_n_out(i),
            noc2_data_s_out         => noc2_data_s_out(i),
            noc2_data_w_out         => noc2_data_w_out(i),
            noc2_data_e_out         => noc2_data_e_out(i),
            noc2_data_void_out      => noc2_data_void_out(i),
            noc2_stop_out           => noc2_stop_out(i),
            noc3_data_n_in          => noc3_data_n_in(i),
            noc3_data_s_in          => noc3_data_s_in(i),
            noc3_data_w_in          => noc3_data_w_in(i),
            noc3_data_e_in          => noc3_data_e_in(i),
            noc3_data_void_in       => noc3_data_void_in(i),
            noc3_stop_in            => noc3_stop_in(i),
            noc3_data_n_out         => noc3_data_n_out(i),
            noc3_data_s_out         => noc3_data_s_out(i),
            noc3_data_w_out         => noc3_data_w_out(i),
            noc3_data_e_out         => noc3_data_e_out(i),
            noc3_data_void_out      => noc3_data_void_out(i),
            noc3_stop_out           => noc3_stop_out(i),
            noc4_data_n_in          => noc4_data_n_in(i),
            noc4_data_s_in          => noc4_data_s_in(i),
            noc4_data_w_in          => noc4_data_w_in(i),
            noc4_data_e_in          => noc4_data_e_in(i),
            noc4_data_void_in       => noc4_data_void_in(i),
            noc4_stop_in            => noc4_stop_in(i),
            noc4_data_n_out         => noc4_data_n_out(i),
            noc4_data_s_out         => noc4_data_s_out(i),
            noc4_data_w_out         => noc4_data_w_out(i),
            noc4_data_e_out         => noc4_data_e_out(i),
            noc4_data_void_out      => noc4_data_void_out(i),
            noc4_stop_out           => noc4_stop_out(i),
            noc5_data_n_in          => noc5_data_n_in(i),
            noc5_data_s_in          => noc5_data_s_in(i),
            noc5_data_w_in          => noc5_data_w_in(i),
            noc5_data_e_in          => noc5_data_e_in(i),
            noc5_data_void_in       => noc5_data_void_in(i),
            noc5_stop_in            => noc5_stop_in(i),
            noc5_data_n_out         => noc5_data_n_out(i),
            noc5_data_s_out         => noc5_data_s_out(i),
            noc5_data_w_out         => noc5_data_w_out(i),
            noc5_data_e_out         => noc5_data_e_out(i),
            noc5_data_void_out      => noc5_data_void_out(i),
            noc5_stop_out           => noc5_stop_out(i),
            noc6_data_n_in          => noc6_data_n_in(i),
            noc6_data_s_in          => noc6_data_s_in(i),
            noc6_data_w_in          => noc6_data_w_in(i),
            noc6_data_e_in          => noc6_data_e_in(i),
            noc6_data_void_in       => noc6_data_void_in(i),
            noc6_stop_in            => noc6_stop_in(i),
            noc6_data_n_out         => noc6_data_n_out(i),
            noc6_data_s_out         => noc6_data_s_out(i),
            noc6_data_w_out         => noc6_data_w_out(i),
            noc6_data_e_out         => noc6_data_e_out(i),
            noc6_data_void_out      => noc6_data_void_out(i),
            noc6_stop_out           => noc6_stop_out(i),
            -- monitors
            mon_noc                 => mon_noc_s(i),
            acc_activity            => '0',
            -- synchronizers out to tile
            noc1_output_port_tile   => noc1_data_l_out(i),
            noc1_data_void_out_tile => noc1_data_void_out_tile(i),
            noc1_stop_in_tile       => noc1_stop_in_tile(i),
            noc2_output_port_tile   => noc2_data_l_out(i),
            noc2_data_void_out_tile => noc2_data_void_out_tile(i),
            noc2_stop_in_tile       => noc2_stop_in_tile(i),
            noc3_output_port_tile   => noc3_data_l_out(i),
            noc3_data_void_out_tile => noc3_data_void_out_tile(i),
            noc3_stop_in_tile       => noc3_stop_in_tile(i),
            noc4_output_port_tile   => noc4_data_l_out(i),
            noc4_data_void_out_tile => noc4_data_void_out_tile(i),
            noc4_stop_in_tile       => noc4_stop_in_tile(i),
            noc5_output_port_tile   => noc5_data_l_out(i),
            noc5_data_void_out_tile => noc5_data_void_out_tile(i),
            noc5_stop_in_tile       => noc5_stop_in_tile(i),
            noc6_output_port_tile   => noc6_data_l_out(i),
            noc6_data_void_out_tile => noc6_data_void_out_tile(i),
            noc6_stop_in_tile       => noc6_stop_in_tile(i),
           -- tile to synchronizers in
            noc1_input_port_tile    => noc1_data_l_in(i),
            noc1_data_void_in_tile  => noc1_data_void_in_tile(i),
            noc1_stop_out_tile      => noc1_stop_out_tile(i),
            noc2_input_port_tile    => noc2_data_l_in(i),
            noc2_data_void_in_tile  => noc2_data_void_in_tile(i),
            noc2_stop_out_tile      => noc2_stop_out_tile(i),
            noc3_input_port_tile    => noc3_data_l_in(i),
            noc3_data_void_in_tile  => noc3_data_void_in_tile(i),
            noc3_stop_out_tile      => noc3_stop_out_tile(i),
            noc4_input_port_tile    => noc4_data_l_in(i),
            noc4_data_void_in_tile  => noc4_data_void_in_tile(i),
            noc4_stop_out_tile      => noc4_stop_out_tile(i),
            noc5_input_port_tile    => noc5_data_l_in(i),
            noc5_data_void_in_tile  => noc5_data_void_in_tile(i),
            noc5_stop_out_tile      => noc5_stop_out_tile(i),
            noc6_input_port_tile    => noc6_data_l_in(i),
            noc6_data_void_in_tile  => noc6_data_void_in_tile(i),
            noc6_stop_out_tile      => noc6_stop_out_tile(i));
        end generate io_router;
      not_io_router : if i /= io_idx generate
        noc_domain_socket_i : noc_domain_socket
          generic map (
            this_has_token_pm => 0,
            is_tile_io        => false,
            SIMULATION        => SIMULATION,
            ROUTER_PORTS      => set_router_ports(CFG_FABTECH, CFG_CHIPLET_COLS, CFG_CHIPLET_ROWS, CFG_XLEN(BOARD_NUM), CFG_YLEN(BOARD_NUM), tile_x(GI), tile_y(GI), chip_x(GI), chip_y(GI)),
            HAS_SYNC          => 1)
          port map (
            rst                     => rst_inv,
            noc_clk_lock            => '1',
            tile_rstn               => rst_int,
            noc_clk                 => sys_clk_int(0),
            tile_clk                => tile_clk(i),
            noc_rstn                => open,
            raw_rstn                => open,
            acc_clk                 => open,
            -- DCO config
            dco_freq_sel            => dco_freq_sel(i),
            dco_div_sel             => dco_div_sel(i),
            dco_fc_sel              => dco_fc_sel(i),
            dco_cc_sel              => dco_cc_sel(i),
            dco_clk_sel             => dco_clk_sel(i),
            dco_en                  => dco_en(i),
            dco_clk_delay_sel       => open,
            -- pad config
            pad_cfg                 => open,
            -- NoC
            noc1_data_n_in          => noc1_data_n_in(i),
            noc1_data_s_in          => noc1_data_s_in(i),
            noc1_data_w_in          => noc1_data_w_in(i),
            noc1_data_e_in          => noc1_data_e_in(i),
            noc1_data_void_in       => noc1_data_void_in(i),
            noc1_stop_in            => noc1_stop_in(i),
            noc1_data_n_out         => noc1_data_n_out(i),
            noc1_data_s_out         => noc1_data_s_out(i),
            noc1_data_w_out         => noc1_data_w_out(i),
            noc1_data_e_out         => noc1_data_e_out(i),
            noc1_data_void_out      => noc1_data_void_out(i),
            noc1_stop_out           => noc1_stop_out(i),
            noc2_data_n_in          => noc2_data_n_in(i),
            noc2_data_s_in          => noc2_data_s_in(i),
            noc2_data_w_in          => noc2_data_w_in(i),
            noc2_data_e_in          => noc2_data_e_in(i),
            noc2_data_void_in       => noc2_data_void_in(i),
            noc2_stop_in            => noc2_stop_in(i),
            noc2_data_n_out         => noc2_data_n_out(i),
            noc2_data_s_out         => noc2_data_s_out(i),
            noc2_data_w_out         => noc2_data_w_out(i),
            noc2_data_e_out         => noc2_data_e_out(i),
            noc2_data_void_out      => noc2_data_void_out(i),
            noc2_stop_out           => noc2_stop_out(i),
            noc3_data_n_in          => noc3_data_n_in(i),
            noc3_data_s_in          => noc3_data_s_in(i),
            noc3_data_w_in          => noc3_data_w_in(i),
            noc3_data_e_in          => noc3_data_e_in(i),
            noc3_data_void_in       => noc3_data_void_in(i),
            noc3_stop_in            => noc3_stop_in(i),
            noc3_data_n_out         => noc3_data_n_out(i),
            noc3_data_s_out         => noc3_data_s_out(i),
            noc3_data_w_out         => noc3_data_w_out(i),
            noc3_data_e_out         => noc3_data_e_out(i),
            noc3_data_void_out      => noc3_data_void_out(i),
            noc3_stop_out           => noc3_stop_out(i),
            noc4_data_n_in          => noc4_data_n_in(i),
            noc4_data_s_in          => noc4_data_s_in(i),
            noc4_data_w_in          => noc4_data_w_in(i),
            noc4_data_e_in          => noc4_data_e_in(i),
            noc4_data_void_in       => noc4_data_void_in(i),
            noc4_stop_in            => noc4_stop_in(i),
            noc4_data_n_out         => noc4_data_n_out(i),
            noc4_data_s_out         => noc4_data_s_out(i),
            noc4_data_w_out         => noc4_data_w_out(i),
            noc4_data_e_out         => noc4_data_e_out(i),
            noc4_data_void_out      => noc4_data_void_out(i),
            noc4_stop_out           => noc4_stop_out(i),
            noc5_data_n_in          => noc5_data_n_in(i),
            noc5_data_s_in          => noc5_data_s_in(i),
            noc5_data_w_in          => noc5_data_w_in(i),
            noc5_data_e_in          => noc5_data_e_in(i),
            noc5_data_void_in       => noc5_data_void_in(i),
            noc5_stop_in            => noc5_stop_in(i),
            noc5_data_n_out         => noc5_data_n_out(i),
            noc5_data_s_out         => noc5_data_s_out(i),
            noc5_data_w_out         => noc5_data_w_out(i),
            noc5_data_e_out         => noc5_data_e_out(i),
            noc5_data_void_out      => noc5_data_void_out(i),
            noc5_stop_out           => noc5_stop_out(i),
            noc6_data_n_in          => noc6_data_n_in(i),
            noc6_data_s_in          => noc6_data_s_in(i),
            noc6_data_w_in          => noc6_data_w_in(i),
            noc6_data_e_in          => noc6_data_e_in(i),
            noc6_data_void_in       => noc6_data_void_in(i),
            noc6_stop_in            => noc6_stop_in(i),
            noc6_data_n_out         => noc6_data_n_out(i),
            noc6_data_s_out         => noc6_data_s_out(i),
            noc6_data_w_out         => noc6_data_w_out(i),
            noc6_data_e_out         => noc6_data_e_out(i),
            noc6_data_void_out      => noc6_data_void_out(i),
            noc6_stop_out           => noc6_stop_out(i),
            -- monitors
            mon_noc                 => mon_noc_s(i),
            acc_activity            => '0',
            -- synchronizers out to tile
            noc1_output_port_tile   => noc1_data_l_out(i),
            noc1_data_void_out_tile => noc1_data_void_out_tile(i),
            noc1_stop_in_tile       => noc1_stop_in_tile(i),
            noc2_output_port_tile   => noc2_data_l_out(i),
            noc2_data_void_out_tile => noc2_data_void_out_tile(i),
            noc2_stop_in_tile       => noc2_stop_in_tile(i),
            noc3_output_port_tile   => noc3_data_l_out(i),
            noc3_data_void_out_tile => noc3_data_void_out_tile(i),
            noc3_stop_in_tile       => noc3_stop_in_tile(i),
            noc4_output_port_tile   => noc4_data_l_out(i),
            noc4_data_void_out_tile => noc4_data_void_out_tile(i),
            noc4_stop_in_tile       => noc4_stop_in_tile(i),
            noc5_output_port_tile   => noc5_data_l_out(i),
            noc5_data_void_out_tile => noc5_data_void_out_tile(i),
            noc5_stop_in_tile       => noc5_stop_in_tile(i),
            noc6_output_port_tile   => noc6_data_l_out(i),
            noc6_data_void_out_tile => noc6_data_void_out_tile(i),
            noc6_stop_in_tile       => noc6_stop_in_tile(i),
           -- tile to synchronizers in
            noc1_input_port_tile    => noc1_data_l_in(i),
            noc1_data_void_in_tile  => noc1_data_void_in_tile(i),
            noc1_stop_out_tile      => noc1_stop_out_tile(i),
            noc2_input_port_tile    => noc2_data_l_in(i),
            noc2_data_void_in_tile  => noc2_data_void_in_tile(i),
            noc2_stop_out_tile      => noc2_stop_out_tile(i),
            noc3_input_port_tile    => noc3_data_l_in(i),
            noc3_data_void_in_tile  => noc3_data_void_in_tile(i),
            noc3_stop_out_tile      => noc3_stop_out_tile(i),
            noc4_input_port_tile    => noc4_data_l_in(i),
            noc4_data_void_in_tile  => noc4_data_void_in_tile(i),
            noc4_stop_out_tile      => noc4_stop_out_tile(i),
            noc5_input_port_tile    => noc5_data_l_in(i),
            noc5_data_void_in_tile  => noc5_data_void_in_tile(i),
            noc5_stop_out_tile      => noc5_stop_out_tile(i),
            noc6_input_port_tile    => noc6_data_l_in(i),
            noc6_data_void_in_tile  => noc6_data_void_in_tile(i),
            noc6_stop_out_tile      => noc6_stop_out_tile(i));
        end generate not_io_router;
      end generate gen_io;
    gen_not_io : if CFG_IO_TILE_CHIPLET(BOARD_NUM) = '0' generate
      noc_domain_socket_i : noc_domain_socket
        generic map (
          this_has_token_pm => 0,
          is_tile_io        => false,
          SIMULATION        => SIMULATION,
          ROUTER_PORTS      => set_router_ports(CFG_FABTECH, CFG_CHIPLET_COLS, CFG_CHIPLET_ROWS, CFG_XLEN(BOARD_NUM), CFG_YLEN(BOARD_NUM), tile_x(GI), tile_y(GI), chip_x(GI), chip_y(GI)),
          HAS_SYNC          => 1)
        port map (
          rst                     => rst_inv,
          noc_clk_lock            => '1',
          tile_rstn               => rst_int,
          noc_clk                 => sys_clk_int(0),
          tile_clk                => tile_clk(i),
          noc_rstn                => open,
          raw_rstn                => open,
          acc_clk                 => open,
          -- DCO config
          dco_freq_sel            => dco_freq_sel(i),
          dco_div_sel             => dco_div_sel(i),
          dco_fc_sel              => dco_fc_sel(i),
          dco_cc_sel              => dco_cc_sel(i),
          dco_clk_sel             => dco_clk_sel(i),
          dco_en                  => dco_en(i),
          dco_clk_delay_sel       => open,
          -- pad config
          pad_cfg                 => open,
          -- NoC
          noc1_data_n_in          => noc1_data_n_in(i),
          noc1_data_s_in          => noc1_data_s_in(i),
          noc1_data_w_in          => noc1_data_w_in(i),
          noc1_data_e_in          => noc1_data_e_in(i),
          noc1_data_void_in       => noc1_data_void_in(i),
          noc1_stop_in            => noc1_stop_in(i),
          noc1_data_n_out         => noc1_data_n_out(i),
          noc1_data_s_out         => noc1_data_s_out(i),
          noc1_data_w_out         => noc1_data_w_out(i),
          noc1_data_e_out         => noc1_data_e_out(i),
          noc1_data_void_out      => noc1_data_void_out(i),
          noc1_stop_out           => noc1_stop_out(i),
          noc2_data_n_in          => noc2_data_n_in(i),
          noc2_data_s_in          => noc2_data_s_in(i),
          noc2_data_w_in          => noc2_data_w_in(i),
          noc2_data_e_in          => noc2_data_e_in(i),
          noc2_data_void_in       => noc2_data_void_in(i),
          noc2_stop_in            => noc2_stop_in(i),
          noc2_data_n_out         => noc2_data_n_out(i),
          noc2_data_s_out         => noc2_data_s_out(i),
          noc2_data_w_out         => noc2_data_w_out(i),
          noc2_data_e_out         => noc2_data_e_out(i),
          noc2_data_void_out      => noc2_data_void_out(i),
          noc2_stop_out           => noc2_stop_out(i),
          noc3_data_n_in          => noc3_data_n_in(i),
          noc3_data_s_in          => noc3_data_s_in(i),
          noc3_data_w_in          => noc3_data_w_in(i),
          noc3_data_e_in          => noc3_data_e_in(i),
          noc3_data_void_in       => noc3_data_void_in(i),
          noc3_stop_in            => noc3_stop_in(i),
          noc3_data_n_out         => noc3_data_n_out(i),
          noc3_data_s_out         => noc3_data_s_out(i),
          noc3_data_w_out         => noc3_data_w_out(i),
          noc3_data_e_out         => noc3_data_e_out(i),
          noc3_data_void_out      => noc3_data_void_out(i),
          noc3_stop_out           => noc3_stop_out(i),
          noc4_data_n_in          => noc4_data_n_in(i),
          noc4_data_s_in          => noc4_data_s_in(i),
          noc4_data_w_in          => noc4_data_w_in(i),
          noc4_data_e_in          => noc4_data_e_in(i),
          noc4_data_void_in       => noc4_data_void_in(i),
          noc4_stop_in            => noc4_stop_in(i),
          noc4_data_n_out         => noc4_data_n_out(i),
          noc4_data_s_out         => noc4_data_s_out(i),
          noc4_data_w_out         => noc4_data_w_out(i),
          noc4_data_e_out         => noc4_data_e_out(i),
          noc4_data_void_out      => noc4_data_void_out(i),
          noc4_stop_out           => noc4_stop_out(i),
          noc5_data_n_in          => noc5_data_n_in(i),
          noc5_data_s_in          => noc5_data_s_in(i),
          noc5_data_w_in          => noc5_data_w_in(i),
          noc5_data_e_in          => noc5_data_e_in(i),
          noc5_data_void_in       => noc5_data_void_in(i),
          noc5_stop_in            => noc5_stop_in(i),
          noc5_data_n_out         => noc5_data_n_out(i),
          noc5_data_s_out         => noc5_data_s_out(i),
          noc5_data_w_out         => noc5_data_w_out(i),
          noc5_data_e_out         => noc5_data_e_out(i),
          noc5_data_void_out      => noc5_data_void_out(i),
          noc5_stop_out           => noc5_stop_out(i),
          noc6_data_n_in          => noc6_data_n_in(i),
          noc6_data_s_in          => noc6_data_s_in(i),
          noc6_data_w_in          => noc6_data_w_in(i),
          noc6_data_e_in          => noc6_data_e_in(i),
          noc6_data_void_in       => noc6_data_void_in(i),
          noc6_stop_in            => noc6_stop_in(i),
          noc6_data_n_out         => noc6_data_n_out(i),
          noc6_data_s_out         => noc6_data_s_out(i),
          noc6_data_w_out         => noc6_data_w_out(i),
          noc6_data_e_out         => noc6_data_e_out(i),
          noc6_data_void_out      => noc6_data_void_out(i),
          noc6_stop_out           => noc6_stop_out(i),
          -- monitors
          mon_noc                 => mon_noc_s(i),
          acc_activity            => '0',
          -- synchronizers out to tile
          noc1_output_port_tile   => noc1_data_l_out(i),
          noc1_data_void_out_tile => noc1_data_void_out_tile(i),
          noc1_stop_in_tile       => noc1_stop_in_tile(i),
          noc2_output_port_tile   => noc2_data_l_out(i),
          noc2_data_void_out_tile => noc2_data_void_out_tile(i),
          noc2_stop_in_tile       => noc2_stop_in_tile(i),
          noc3_output_port_tile   => noc3_data_l_out(i),
          noc3_data_void_out_tile => noc3_data_void_out_tile(i),
          noc3_stop_in_tile       => noc3_stop_in_tile(i),
          noc4_output_port_tile   => noc4_data_l_out(i),
          noc4_data_void_out_tile => noc4_data_void_out_tile(i),
          noc4_stop_in_tile       => noc4_stop_in_tile(i),
          noc5_output_port_tile   => noc5_data_l_out(i),
          noc5_data_void_out_tile => noc5_data_void_out_tile(i),
          noc5_stop_in_tile       => noc5_stop_in_tile(i),
          noc6_output_port_tile   => noc6_data_l_out(i),
          noc6_data_void_out_tile => noc6_data_void_out_tile(i),
          noc6_stop_in_tile       => noc6_stop_in_tile(i),
         -- tile to synchronizers in
          noc1_input_port_tile    => noc1_data_l_in(i),
          noc1_data_void_in_tile  => noc1_data_void_in_tile(i),
          noc1_stop_out_tile      => noc1_stop_out_tile(i),
          noc2_input_port_tile    => noc2_data_l_in(i),
          noc2_data_void_in_tile  => noc2_data_void_in_tile(i),
          noc2_stop_out_tile      => noc2_stop_out_tile(i),
          noc3_input_port_tile    => noc3_data_l_in(i),
          noc3_data_void_in_tile  => noc3_data_void_in_tile(i),
          noc3_stop_out_tile      => noc3_stop_out_tile(i),
          noc4_input_port_tile    => noc4_data_l_in(i),
          noc4_data_void_in_tile  => noc4_data_void_in_tile(i),
          noc4_stop_out_tile      => noc4_stop_out_tile(i),
          noc5_input_port_tile    => noc5_data_l_in(i),
          noc5_data_void_in_tile  => noc5_data_void_in_tile(i),
          noc5_stop_out_tile      => noc5_stop_out_tile(i),
          noc6_input_port_tile    => noc6_data_l_in(i),
          noc6_data_void_in_tile  => noc6_data_void_in_tile(i),
          noc6_stop_out_tile      => noc6_stop_out_tile(i));
    end generate gen_not_io;
  end generate router_gen;


  -----------------------------------------------------------------------------
  -- TILES
  -----------------------------------------------------------------------------
  tiles_gen: for i in 0 to CFG_CHIPLET_TILES(BOARD_NUM) - 1  generate
    constant GI : integer := CFG_CHIPLET_TILE_BASE(BOARD_NUM) + i;
  begin
    empty_tile: if tile_type(GI) = 0 generate
    tile_empty_i: fpga_tile_empty
      generic map (
        SIMULATION   => SIMULATION,
        HAS_SYNC     => CFG_HAS_SYNC,
        BOARD_NUM    => BOARD_NUM
      )
      port map (
        rst                => rst_int,
        clk                => sys_clk_int(0),
	      noc_clk            => sys_clk_int(0),
        tile_clk           => tile_clk(i),
        tile_rstn          => open,
        -- Test interface
        tdi                => '0',
        tdo                => open,
        tms                => '0',
        tclk               => '0',
        -- DCO config
        dco_freq_sel            => dco_freq_sel(i),
        dco_div_sel             => dco_div_sel(i),
        dco_fc_sel              => dco_fc_sel(i),
        dco_cc_sel              => dco_cc_sel(i),
        dco_clk_sel             => dco_clk_sel(i),
        dco_en                  => dco_en(i),
        -- NOC
        noc1_stop_in_tile       => noc1_stop_in_tile(i),
        noc1_stop_out_tile      => noc1_stop_out_tile(i),
        noc1_data_void_in_tile  => noc1_data_void_in_tile(i),
        noc1_data_void_out_tile => noc1_data_void_out_tile(i),
        noc2_stop_in_tile       => noc2_stop_in_tile(i),
        noc2_stop_out_tile      => noc2_stop_out_tile(i),
        noc2_data_void_in_tile  => noc2_data_void_in_tile(i),
        noc2_data_void_out_tile => noc2_data_void_out_tile(i),
        noc3_stop_in_tile       => noc3_stop_in_tile(i),
        noc3_stop_out_tile      => noc3_stop_out_tile(i),
        noc3_data_void_in_tile  => noc3_data_void_in_tile(i),
        noc3_data_void_out_tile => noc3_data_void_out_tile(i),
        noc4_stop_in_tile       => noc4_stop_in_tile(i),
        noc4_stop_out_tile      => noc4_stop_out_tile(i),
        noc4_data_void_in_tile  => noc4_data_void_in_tile(i),
        noc4_data_void_out_tile => noc4_data_void_out_tile(i),
        noc5_stop_in_tile       => noc5_stop_in_tile(i),
        noc5_stop_out_tile      => noc5_stop_out_tile(i),
        noc5_data_void_in_tile  => noc5_data_void_in_tile(i),
        noc5_data_void_out_tile => noc5_data_void_out_tile(i),
        noc6_stop_in_tile       => noc6_stop_in_tile(i),
        noc6_stop_out_tile      => noc6_stop_out_tile(i),
        noc6_data_void_in_tile  => noc6_data_void_in_tile(i),
        noc6_data_void_out_tile => noc6_data_void_out_tile(i),
        noc1_input_port_tile    => noc1_data_l_in(i),
        noc2_input_port_tile    => noc2_data_l_in(i),
        noc3_input_port_tile    => noc3_data_l_in(i),
        noc4_input_port_tile    => noc4_data_l_in(i),
        noc5_input_port_tile    => noc5_data_l_in(i),
        noc6_input_port_tile    => noc6_data_l_in(i),
        noc1_output_port_tile   => noc1_data_l_out(i),
        noc2_output_port_tile   => noc2_data_l_out(i),
        noc3_output_port_tile   => noc3_data_l_out(i),
        noc4_output_port_tile   => noc4_data_l_out(i),
        noc5_output_port_tile   => noc5_data_l_out(i),
        noc6_output_port_tile   => noc6_data_l_out(i),
        mon_noc                 => mon_noc_s(i),
	      mon_dvfs_out            => mon_dvfs_out(i));
    end generate empty_tile;


    cpu_tile: if tile_type(GI) = 1 generate
      constant CPU_ORD_BASE : integer := CFG_NCPU_TILE_BASE(BOARD_NUM);
      constant cpu_li       : integer := tile_cpu_id(GI) - CPU_ORD_BASE;
    begin
-- pragma translate_off
      assert tile_cpu_id(GI) /= -1 report "Undefined CPU ID for CPU tile" severity error;
-- pragma translate_on
      tile_cpu_i: fpga_tile_cpu
      generic map (
        SIMULATION         => SIMULATION,
        HAS_SYNC           => CFG_HAS_SYNC,
        BOARD_NUM          => BOARD_NUM
      )
      port map (
        rst                => rst_int,
        clk                => refclk,
        noc_clk            => sys_clk_int(0),
        tile_clk           => tile_clk(i),
        tile_rstn          => open,
        cpuerr             => cpuerr_vec(cpu_li),
        -- Test interface
        tdi                => '0',
        tdo                => open,
        tms                => '0',
        tclk               => '0',
        -- DCO config
        dco_freq_sel            => dco_freq_sel(i),
        dco_div_sel             => dco_div_sel(i),
        dco_fc_sel              => dco_fc_sel(i),
        dco_cc_sel              => dco_cc_sel(i),
        dco_clk_sel             => dco_clk_sel(i),
        dco_en                  => dco_en(i),
        -- NOC
        noc1_stop_in_tile       => noc1_stop_in_tile(i),
        noc1_stop_out_tile      => noc1_stop_out_tile(i),
        noc1_data_void_in_tile  => noc1_data_void_in_tile(i),
        noc1_data_void_out_tile => noc1_data_void_out_tile(i),
        noc2_stop_in_tile       => noc2_stop_in_tile(i),
        noc2_stop_out_tile      => noc2_stop_out_tile(i),
        noc2_data_void_in_tile  => noc2_data_void_in_tile(i),
        noc2_data_void_out_tile => noc2_data_void_out_tile(i),
        noc3_stop_in_tile       => noc3_stop_in_tile(i),
        noc3_stop_out_tile      => noc3_stop_out_tile(i),
        noc3_data_void_in_tile  => noc3_data_void_in_tile(i),
        noc3_data_void_out_tile => noc3_data_void_out_tile(i),
        noc4_stop_in_tile       => noc4_stop_in_tile(i),
        noc4_stop_out_tile      => noc4_stop_out_tile(i),
        noc4_data_void_in_tile  => noc4_data_void_in_tile(i),
        noc4_data_void_out_tile => noc4_data_void_out_tile(i),
        noc5_stop_in_tile       => noc5_stop_in_tile(i),
        noc5_stop_out_tile      => noc5_stop_out_tile(i),
        noc5_data_void_in_tile  => noc5_data_void_in_tile(i),
        noc5_data_void_out_tile => noc5_data_void_out_tile(i),
        noc6_stop_in_tile       => noc6_stop_in_tile(i),
        noc6_stop_out_tile      => noc6_stop_out_tile(i),
        noc6_data_void_in_tile  => noc6_data_void_in_tile(i),
        noc6_data_void_out_tile => noc6_data_void_out_tile(i),
        noc1_input_port_tile    => noc1_data_l_in(i),
        noc2_input_port_tile    => noc2_data_l_in(i),
        noc3_input_port_tile    => noc3_data_l_in(i),
        noc4_input_port_tile    => noc4_data_l_in(i),
        noc5_input_port_tile    => noc5_data_l_in(i),
        noc6_input_port_tile    => noc6_data_l_in(i),
        noc1_output_port_tile   => noc1_data_l_out(i),
        noc2_output_port_tile   => noc2_data_l_out(i),
        noc3_output_port_tile   => noc3_data_l_out(i),
        noc4_output_port_tile   => noc4_data_l_out(i),
        noc5_output_port_tile   => noc5_data_l_out(i),
        noc6_output_port_tile   => noc6_data_l_out(i),
        mon_noc                 => mon_noc_s(i),
        mon_cache               => mon_l2_int(i),
        mon_dvfs                => mon_dvfs_out(i));
    end generate cpu_tile;


    accelerator_tile: if tile_type(GI) = 2 generate
-- pragma translate_off
      assert tile_device(GI) /= 0 report "Undefined device ID for accelerator tile" severity error;
-- pragma translate_on
      tile_acc_i: fpga_tile_acc
      generic map (
        SIMULATION         => SIMULATION,
        this_hls_conf      => tile_design_point(GI),
        this_device        => tile_device(GI),
        this_irq_type      => tile_irq_type(GI),
        this_has_l2        => tile_has_l2(GI),
        this_has_token_pm  => tile_has_tdvfs(GI),
        HAS_SYNC           => CFG_HAS_SYNC,
        BOARD_NUM          => BOARD_NUM
      )
      port map (
        rst                => rst_int,
        clk                => refclk,
        noc_clk            => sys_clk_int(0),
        tile_clk           => tile_clk(i),
        tile_rstn          => open,
        -- Test interface
        tdi                => '0',
        tdo                => open,
        tms                => '0',
        tclk               => '0',
        -- DCO config
        dco_freq_sel            => dco_freq_sel(i),
        dco_div_sel             => dco_div_sel(i),
        dco_fc_sel              => dco_fc_sel(i),
        dco_cc_sel              => dco_cc_sel(i),
        dco_clk_sel             => dco_clk_sel(i),
        dco_en                  => dco_en(i),
        -- NOC
        noc1_stop_in_tile       => noc1_stop_in_tile(i),
        noc1_stop_out_tile      => noc1_stop_out_tile(i),
        noc1_data_void_in_tile  => noc1_data_void_in_tile(i),
        noc1_data_void_out_tile => noc1_data_void_out_tile(i),
        noc2_stop_in_tile       => noc2_stop_in_tile(i),
        noc2_stop_out_tile      => noc2_stop_out_tile(i),
        noc2_data_void_in_tile  => noc2_data_void_in_tile(i),
        noc2_data_void_out_tile => noc2_data_void_out_tile(i),
        noc3_stop_in_tile       => noc3_stop_in_tile(i),
        noc3_stop_out_tile      => noc3_stop_out_tile(i),
        noc3_data_void_in_tile  => noc3_data_void_in_tile(i),
        noc3_data_void_out_tile => noc3_data_void_out_tile(i),
        noc4_stop_in_tile       => noc4_stop_in_tile(i),
        noc4_stop_out_tile      => noc4_stop_out_tile(i),
        noc4_data_void_in_tile  => noc4_data_void_in_tile(i),
        noc4_data_void_out_tile => noc4_data_void_out_tile(i),
        noc5_stop_in_tile       => noc5_stop_in_tile(i),
        noc5_stop_out_tile      => noc5_stop_out_tile(i),
        noc5_data_void_in_tile  => noc5_data_void_in_tile(i),
        noc5_data_void_out_tile => noc5_data_void_out_tile(i),
        noc6_stop_in_tile       => noc6_stop_in_tile(i),
        noc6_stop_out_tile      => noc6_stop_out_tile(i),
        noc6_data_void_in_tile  => noc6_data_void_in_tile(i),
        noc6_data_void_out_tile => noc6_data_void_out_tile(i),
        noc1_input_port_tile    => noc1_data_l_in(i),
        noc2_input_port_tile    => noc2_data_l_in(i),
        noc3_input_port_tile    => noc3_data_l_in(i),
        noc4_input_port_tile    => noc4_data_l_in(i),
        noc5_input_port_tile    => noc5_data_l_in(i),
        noc6_input_port_tile    => noc6_data_l_in(i),
        noc1_output_port_tile   => noc1_data_l_out(i),
        noc2_output_port_tile   => noc2_data_l_out(i),
        noc3_output_port_tile   => noc3_data_l_out(i),
        noc4_output_port_tile   => noc4_data_l_out(i),
        noc5_output_port_tile   => noc5_data_l_out(i),
        noc6_output_port_tile   => noc6_data_l_out(i),
        mon_noc                 => mon_noc_s(i),
        --Monitor signals
        mon_acc                 => mon_acc(tile_acc_id(GI) - CFG_NACC_TILE_BASE(BOARD_NUM)),
        mon_cache               => mon_l2_int(i),
        mon_dvfs                => mon_dvfs_out(i)
        );
    end generate accelerator_tile;


    io_tile: if tile_type(GI) = 3 generate
      main_io : if BOARD_NUM = 0 generate
--      main_io : if true generate
        tile_io_i : fpga_tile_io
        generic map (
          SIMULATION   => SIMULATION,
          HAS_SYNC     => CFG_HAS_SYNC,
          BOARD_NUM    => BOARD_NUM
        )
        port map (
  	      rst                => rst_int,
  	      clk                => refclk,
  	      noc_clk            => sys_clk_int(0),
          tile_clk           => tile_clk(i),
          tile_rstn          => open,
          -- Test interface
          tdi                => '0',
          tdo                => open,
          tms                => '0',
          tclk               => '0',
          -- I/O bus interfaces
  	      eth0_apbi          => eth0_apbi,
  	      eth0_apbo          => eth0_apbo,
  	      sgmii0_apbi        => sgmii0_apbi,
  	      sgmii0_apbo        => sgmii0_apbo,
  	      eth0_ahbmi         => eth0_ahbmi,
  	      eth0_ahbmo         => eth0_ahbmo,
  	      edcl_ahbmo         => edcl_ahbmo,
  	      dvi_apbi           => dvi_apbi,
  	      dvi_apbo           => dvi_apbo,
  	      dvi_ahbmi          => dvi_ahbmi,
  	      dvi_ahbmo          => dvi_ahbmo,
        	uart_rxd           => uart_rxd,
        	uart_txd           => uart_txd,
        	uart_ctsn          => uart_ctsn,
        	uart_rtsn          => uart_rtsn,
          -- DCO config
          dco_freq_sel            => dco_freq_sel(i),
          dco_div_sel             => dco_div_sel(i),
          dco_fc_sel              => dco_fc_sel(i),
          dco_cc_sel              => dco_cc_sel(i),
          dco_clk_sel             => dco_clk_sel(i),
          dco_en                  => dco_en(i),
  	      -- NOC
          noc1_stop_in_tile       => noc1_stop_in_tile(i),
          noc1_stop_out_tile      => noc1_stop_out_tile(i),
          noc1_data_void_in_tile  => noc1_data_void_in_tile(i),
          noc1_data_void_out_tile => noc1_data_void_out_tile(i),
          noc2_stop_in_tile       => noc2_stop_in_tile(i),
          noc2_stop_out_tile      => noc2_stop_out_tile(i),
          noc2_data_void_in_tile  => noc2_data_void_in_tile(i),
          noc2_data_void_out_tile => noc2_data_void_out_tile(i),
          noc3_stop_in_tile       => noc3_stop_in_tile(i),
          noc3_stop_out_tile      => noc3_stop_out_tile(i),
          noc3_data_void_in_tile  => noc3_data_void_in_tile(i),
          noc3_data_void_out_tile => noc3_data_void_out_tile(i),
          noc4_stop_in_tile       => noc4_stop_in_tile(i),
          noc4_stop_out_tile      => noc4_stop_out_tile(i),
          noc4_data_void_in_tile  => noc4_data_void_in_tile(i),
          noc4_data_void_out_tile => noc4_data_void_out_tile(i),
          noc5_stop_in_tile       => noc5_stop_in_tile(i),
          noc5_stop_out_tile      => noc5_stop_out_tile(i),
          noc5_data_void_in_tile  => noc5_data_void_in_tile(i),
          noc5_data_void_out_tile => noc5_data_void_out_tile(i),
          noc6_stop_in_tile       => noc6_stop_in_tile(i),
          noc6_stop_out_tile      => noc6_stop_out_tile(i),
          noc6_data_void_in_tile  => noc6_data_void_in_tile(i),
          noc6_data_void_out_tile => noc6_data_void_out_tile(i),
          noc1_input_port_tile    => noc1_data_l_in(i),
          noc2_input_port_tile    => noc2_data_l_in(i),
          noc3_input_port_tile    => noc3_data_l_in(i),
          noc4_input_port_tile    => noc4_data_l_in(i),
          noc5_input_port_tile    => noc5_data_l_in(i),
          noc6_input_port_tile    => noc6_data_l_in(i),
          noc1_output_port_tile   => noc1_data_l_out(i),
          noc2_output_port_tile   => noc2_data_l_out(i),
          noc3_output_port_tile   => noc3_data_l_out(i),
          noc4_output_port_tile   => noc4_data_l_out(i),
          noc5_output_port_tile   => noc5_data_l_out(i),
          noc6_output_port_tile   => noc6_data_l_out(i),
          mon_noc                 => mon_noc_s(i),
  	      mon_dvfs                => mon_dvfs_out(i));
      end generate main_io;
      aux_io  : if BOARD_NUM /= 0 generate
        eth0_apbi                 <= apb_slv_in_none;
        sgmii0_apbi               <= apb_slv_in_none;
        eth0_ahbmi                <= ahbm_in_none;
        dvi_apbi                  <= apb_slv_in_none;
        dvi_ahbmi                 <= ahbm_in_none;
        uart_txd                  <= '1';
        uart_rtsn                 <= '1';

        tile_io_abbrev_i  : tile_io_abbrev
          generic map (
            SIMULATION   => SIMULATION,
            this_has_dco => 0,
            chiplet_index => BOARD_NUM
          )
          port map (
            raw_rstn                => '0',
            tile_rst                => rst_int,
            ext_clk_noc             => sys_clk_int(0),
            clk_div_noc             => open,
            ext_clk                 => refclk,
            clk_div                 => open,
            tile_clk_out            => tile_clk(i),
            tile_rstn_out           => open,
            noc_clk_out             => open,
            noc_clk_lock            => open,
            -- DCO config
            dco_freq_sel            => dco_freq_sel(i),
            dco_div_sel             => dco_div_sel(i),
            dco_fc_sel              => dco_fc_sel(i),
            dco_cc_sel              => dco_cc_sel(i),
            dco_clk_sel             => dco_clk_sel(i),
            dco_en                  => dco_en(i),
    	      -- NOC
            test1_stop_in       => noc1_stop_in_tile(i),
            test1_stop_out      => noc1_stop_out_tile(i),
            test1_data_void_in  => noc1_data_void_in_tile(i),
            test1_data_void_out => noc1_data_void_out_tile(i),
            test2_stop_in       => noc2_stop_in_tile(i),
            test2_stop_out      => noc2_stop_out_tile(i),
            test2_data_void_in  => noc2_data_void_in_tile(i),
            test2_data_void_out => noc2_data_void_out_tile(i),
            test3_stop_in       => noc3_stop_in_tile(i),
            test3_stop_out      => noc3_stop_out_tile(i),
            test3_data_void_in  => noc3_data_void_in_tile(i),
            test3_data_void_out => noc3_data_void_out_tile(i),
            test4_stop_in       => noc4_stop_in_tile(i),
            test4_stop_out      => noc4_stop_out_tile(i),
            test4_data_void_in  => noc4_data_void_in_tile(i),
            test4_data_void_out => noc4_data_void_out_tile(i),
            test5_stop_in       => noc5_stop_in_tile(i),
            test5_stop_out      => noc5_stop_out_tile(i),
            test5_data_void_in  => noc5_data_void_in_tile(i),
            test5_data_void_out => noc5_data_void_out_tile(i),
            test6_stop_in       => noc6_stop_in_tile(i),
            test6_stop_out      => noc6_stop_out_tile(i),
            test6_data_void_in  => noc6_data_void_in_tile(i),
            test6_data_void_out => noc6_data_void_out_tile(i),
            test1_input_port    => noc1_data_l_in(i),
            test2_input_port    => noc2_data_l_in(i),
            test3_input_port    => noc3_data_l_in(i),
            test4_input_port    => noc4_data_l_in(i),
            test5_input_port    => noc5_data_l_in(i),
            test6_input_port    => noc6_data_l_in(i),
            test1_output_port   => noc1_data_l_out(i),
            test2_output_port   => noc2_data_l_out(i),
            test3_output_port   => noc3_data_l_out(i),
            test4_output_port   => noc4_data_l_out(i),
            test5_output_port   => noc5_data_l_out(i),
            test6_output_port   => noc6_data_l_out(i),
            mon_noc             => mon_noc_s(i),
    	      mon_dvfs            => mon_dvfs_out(i));
      end generate aux_io;
    end generate io_tile;

    mem_tile: if tile_type(GI) = 4 generate
      constant MEM_ORD_BASE : integer := CFG_NMEM_TILE_BASE(BOARD_NUM);
      constant mem_li       : integer := tile_mem_id(GI) - MEM_ORD_BASE;
    begin
      tile_mem_i: fpga_tile_mem
      generic map (
        HAS_SYNC     => CFG_HAS_SYNC,
        BOARD_NUM    => BOARD_NUM
      )
      port map (
	      rst                => rst_int,
	      clk                => sys_clk_int(mem_li),  -- KL ?????
	      noc_clk            => sys_clk_int(0),
        tile_clk           => tile_clk(i),
        tile_rstn          => open,
        -- DDR controller ports (this_has_ddr -> 1)
	      ddr_ahbsi          => ddr_ahbsi(mem_li),  -- KL ?????
	      ddr_ahbso          => ddr_ahbso(mem_li),  -- KL ?????
                -- Test interface
        tdi                => '0',
        tdo                => open,
        tms                => '0',
        tclk               => '0',
        -- DCO config
        dco_freq_sel            => dco_freq_sel(i),
        dco_div_sel             => dco_div_sel(i),
        dco_fc_sel              => dco_fc_sel(i),
        dco_cc_sel              => dco_cc_sel(i),
        dco_clk_sel             => dco_clk_sel(i),
        dco_en                  => dco_en(i),
	-- NOC
        noc1_stop_in_tile       => noc1_stop_in_tile(i),
        noc1_stop_out_tile      => noc1_stop_out_tile(i),
        noc1_data_void_in_tile  => noc1_data_void_in_tile(i),
        noc1_data_void_out_tile => noc1_data_void_out_tile(i),
        noc2_stop_in_tile       => noc2_stop_in_tile(i),
        noc2_stop_out_tile      => noc2_stop_out_tile(i),
        noc2_data_void_in_tile  => noc2_data_void_in_tile(i),
        noc2_data_void_out_tile => noc2_data_void_out_tile(i),
        noc3_stop_in_tile       => noc3_stop_in_tile(i),
        noc3_stop_out_tile      => noc3_stop_out_tile(i),
        noc3_data_void_in_tile  => noc3_data_void_in_tile(i),
        noc3_data_void_out_tile => noc3_data_void_out_tile(i),
        noc4_stop_in_tile       => noc4_stop_in_tile(i),
        noc4_stop_out_tile      => noc4_stop_out_tile(i),
        noc4_data_void_in_tile  => noc4_data_void_in_tile(i),
        noc4_data_void_out_tile => noc4_data_void_out_tile(i),
        noc5_stop_in_tile       => noc5_stop_in_tile(i),
        noc5_stop_out_tile      => noc5_stop_out_tile(i),
        noc5_data_void_in_tile  => noc5_data_void_in_tile(i),
        noc5_data_void_out_tile => noc5_data_void_out_tile(i),
        noc6_stop_in_tile       => noc6_stop_in_tile(i),
        noc6_stop_out_tile      => noc6_stop_out_tile(i),
        noc6_data_void_in_tile  => noc6_data_void_in_tile(i),
        noc6_data_void_out_tile => noc6_data_void_out_tile(i),
        noc1_input_port_tile    => noc1_data_l_in(i),
        noc2_input_port_tile    => noc2_data_l_in(i),
        noc3_input_port_tile    => noc3_data_l_in(i),
        noc4_input_port_tile    => noc4_data_l_in(i),
        noc5_input_port_tile    => noc5_data_l_in(i),
        noc6_input_port_tile    => noc6_data_l_in(i),
        noc1_output_port_tile   => noc1_data_l_out(i),
        noc2_output_port_tile   => noc2_data_l_out(i),
        noc3_output_port_tile   => noc3_data_l_out(i),
        noc4_output_port_tile   => noc4_data_l_out(i),
        noc5_output_port_tile   => noc5_data_l_out(i),
        noc6_output_port_tile   => noc6_data_l_out(i),
        mon_noc            => mon_noc_s(i),
	      mon_mem            => mon_mem(mem_li),  -- KL ?????
	      mon_cache          => mon_llc_int(i),
	      mon_dvfs           => mon_dvfs_out(i));
    end generate mem_tile;

    slm_tile: if tile_type(GI) = 5 generate
      tile_slm_i: fpga_tile_slm
        generic map (
          SIMULATION   => SIMULATION,
          HAS_SYNC     => CFG_HAS_SYNC,
          BOARD_NUM    => BOARD_NUM
        )
        port map (
          rst                => rst_int,
          clk                => refclk,
          noc_clk            => sys_clk_int(0),
          tile_clk           => tile_clk(i),
          tile_rstn          => open,
          -- DDR controller ports (disaled in generic ESP top)
          ddr_ahbsi          => open,
          ddr_ahbso          => ahbs_none,
                    -- Test interface
          tdi                => '0',
          tdo                => open,
          tms                => '0',
          tclk               => '0',
          -- DCO config
          dco_freq_sel            => dco_freq_sel(i),
          dco_div_sel             => dco_div_sel(i),
          dco_fc_sel              => dco_fc_sel(i),
          dco_cc_sel              => dco_cc_sel(i),
          dco_clk_sel             => dco_clk_sel(i),
          dco_en                  => dco_en(i),
          -- NOC
          noc1_stop_in_tile       => noc1_stop_in_tile(i),
          noc1_stop_out_tile      => noc1_stop_out_tile(i),
          noc1_data_void_in_tile  => noc1_data_void_in_tile(i),
          noc1_data_void_out_tile => noc1_data_void_out_tile(i),
          noc2_stop_in_tile       => noc2_stop_in_tile(i),
          noc2_stop_out_tile      => noc2_stop_out_tile(i),
          noc2_data_void_in_tile  => noc2_data_void_in_tile(i),
          noc2_data_void_out_tile => noc2_data_void_out_tile(i),
          noc3_stop_in_tile       => noc3_stop_in_tile(i),
          noc3_stop_out_tile      => noc3_stop_out_tile(i),
          noc3_data_void_in_tile  => noc3_data_void_in_tile(i),
          noc3_data_void_out_tile => noc3_data_void_out_tile(i),
          noc4_stop_in_tile       => noc4_stop_in_tile(i),
          noc4_stop_out_tile      => noc4_stop_out_tile(i),
          noc4_data_void_in_tile  => noc4_data_void_in_tile(i),
          noc4_data_void_out_tile => noc4_data_void_out_tile(i),
          noc5_stop_in_tile       => noc5_stop_in_tile(i),
          noc5_stop_out_tile      => noc5_stop_out_tile(i),
          noc5_data_void_in_tile  => noc5_data_void_in_tile(i),
          noc5_data_void_out_tile => noc5_data_void_out_tile(i),
          noc6_stop_in_tile       => noc6_stop_in_tile(i),
          noc6_stop_out_tile      => noc6_stop_out_tile(i),
          noc6_data_void_in_tile  => noc6_data_void_in_tile(i),
          noc6_data_void_out_tile => noc6_data_void_out_tile(i),
          noc1_input_port_tile    => noc1_data_l_in(i),
          noc2_input_port_tile    => noc2_data_l_in(i),
          noc3_input_port_tile    => noc3_data_l_in(i),
          noc4_input_port_tile    => noc4_data_l_in(i),
          noc5_input_port_tile    => noc5_data_l_in(i),
          noc6_input_port_tile    => noc6_data_l_in(i),
          noc1_output_port_tile   => noc1_data_l_out(i),
          noc2_output_port_tile   => noc2_data_l_out(i),
          noc3_output_port_tile   => noc3_data_l_out(i),
          noc4_output_port_tile   => noc4_data_l_out(i),
          noc5_output_port_tile   => noc5_data_l_out(i),
          noc6_output_port_tile   => noc6_data_l_out(i),
          mon_noc            => mon_noc_s(i),
          mon_mem            => mon_mem(CFG_NMEM_TILE_CHIPLET(BOARD_NUM) + (tile_slm_id(GI) - CFG_NSLM_TILE_BASE(BOARD_NUM))),  -- KL tile_slm_id...? slm_id is global.?????
          mon_dvfs           => mon_dvfs_out(i));
    end generate slm_tile;

  end generate tiles_gen;

  no_mem_tile_gen: if CFG_NMEM_TILE_CHIPLET(BOARD_NUM) = 0 generate
    no_mem_tieoff_gen : for i in 0 to MEM_ID_RANGE_MSB generate
      ddr_ahbsi(i) <= ahbs_in_none;
    end generate no_mem_tieoff_gen;
  end generate no_mem_tile_gen;

  monitor_noc_gen: for i in 1 to nocs_num generate
    monitor_noc_tiles_gen: for j in 0 to CFG_CHIPLET_TILES(BOARD_NUM)-1 generate
      mon_noc(i,j) <= mon_noc_s(j)(i);
    end generate monitor_noc_tiles_gen;
  end generate monitor_noc_gen;

  mon_l2_gen  : if CFG_NL2_CHIPLET(BOARD_NUM) /= 0 generate
    monitor_l2_gen: for i in 0 to CFG_NL2_CHIPLET(BOARD_NUM) - 1 generate
  --    mon_l2(i) <= mon_l2_int(cache_tile_id(i));  -- KL ?????
      mon_l2(i) <= mon_l2_int(cache_tile_id(CFG_NL2_BASE(BOARD_NUM) + i) - CFG_CHIPLET_TILE_BASE(BOARD_NUM)); -- KL Is this conversion correct?
    end generate monitor_l2_gen;
  end generate mon_l2_gen;

  mon_llc_gen : if CFG_NLLC_CHIPLET(BOARD_NUM) /= 0 generate
    monitor_llc_gen: for i in 0 to CFG_NLLC_CHIPLET(BOARD_NUM) - 1 generate
      mon_llc(i) <= mon_llc_int(llc_tile_id(CFG_NLLC_BASE(BOARD_NUM) + i) - CFG_CHIPLET_TILE_BASE(BOARD_NUM));  -- KL Is this conversion correct?
    end generate monitor_llc_gen;
  end generate mon_llc_gen;

  -- Handle cases with no accelerators, no l2, no llc
  mon_acc_noacc_gen: if CFG_NACC_TILE_CHIPLET(BOARD_NUM) = 0 generate
    mon_acc(0) <= monitor_acc_none;
  end generate mon_acc_noacc_gen;

  mon_l2_nol2_gen: if CFG_NL2_CHIPLET(BOARD_NUM) = 0 generate
    mon_l2(0) <= monitor_cache_none;
  end generate mon_l2_nol2_gen;

  mon_llc_nollc_gen: if CFG_NLLC_CHIPLET(BOARD_NUM) = 0 generate
    mon_llc(0) <= monitor_cache_none;
  end generate mon_llc_nollc_gen;

  mon_dvfs <= mon_dvfs_out;

end;
