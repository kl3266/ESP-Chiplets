-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.monitor_pkg.all;
use work.esp_csr_pkg.all;
use work.nocpackage.all;
use work.cachepackage.all;
use work.socmap.all;

package tiles_pkg is

  component esp is
    generic (
      SIMULATION : boolean := false);
    port (
      rst                : in  std_logic;
      sys_clk            : in    std_logic_vector(0 to MEM_ID_RANGE_MSB);
      refclk             : in  std_logic;
      uart_rxd           : in  std_logic;
      uart_txd           : out std_logic;
      uart_ctsn          : in  std_logic;
      uart_rtsn          : out std_logic;
      cpuerr             : out   std_logic;
      ddr_ahbsi          : out ahb_slv_in_vector_type(0 to MEM_ID_RANGE_MSB);
      ddr_ahbso          : in  ahb_slv_out_vector_type(0 to MEM_ID_RANGE_MSB);
      eth0_apbi          : out apb_slv_in_type;
      eth0_apbo          : in  apb_slv_out_type;
      sgmii0_apbi        : out apb_slv_in_type;
      sgmii0_apbo        : in  apb_slv_out_type;
      eth0_ahbmi         : out ahb_mst_in_type;
      eth0_ahbmo         : in  ahb_mst_out_type;
      edcl_ahbmo         : in  ahb_mst_out_type;
      dvi_apbi           : out apb_slv_in_type;
      dvi_apbo           : in  apb_slv_out_type;
      dvi_ahbmi          : out ahb_mst_in_type;
      dvi_ahbmo          : in  ahb_mst_out_type;
      mon_noc            : out monitor_noc_matrix(1 to 6, 0 to CFG_TILES_NUM-1);
      mon_acc            : out monitor_acc_vector(0 to relu(accelerators_num-1));
      mon_mem            : out monitor_mem_vector(0 to CFG_NMEM_TILE + CFG_NSLM_TILE + CFG_NSLMDDR_TILE - 1);
      mon_l2             : out monitor_cache_vector(0 to relu(CFG_NL2 - 1));
      mon_llc            : out monitor_cache_vector(0 to relu(CFG_NLLC - 1));
      mon_dvfs           : out monitor_dvfs_vector(0 to CFG_TILES_NUM-1));
  end component esp;
--  component esp_chiplet is
--    generic (
--      SIMULATION : boolean := false;
--      D2D_CHANNELS_N  : integer := 0;
--      D2D_CHANNELS_S  : integer := 0;
--      D2D_CHANNELS_W  : integer := 0;
--      D2D_CHANNELS_E  : integer := 0;
--      BOARD_NUM       : integer := 0
--  );
--    port (
--      rst                : in  std_logic;
--      d2d_rst            : in  std_logic;
--      sys_clk            : in  std_logic_vector(0 to MEM_ID_RANGE_MSB);
--      refclk             : in  std_logic;
--      uart_rxd           : in  std_logic;
--      uart_txd           : out std_logic;
--      uart_ctsn          : in  std_logic;
--      uart_rtsn          : out std_logic;
--      cpuerr             : out   std_logic;
--      ddr_ahbsi          : out ahb_slv_in_vector_type(0 to MEM_ID_RANGE_MSB);
--      ddr_ahbso          : in  ahb_slv_out_vector_type(0 to MEM_ID_RANGE_MSB);
--      eth0_apbi          : out apb_slv_in_type;
--      eth0_apbo          : in  apb_slv_out_type;
--      sgmii0_apbi        : out apb_slv_in_type;
--      sgmii0_apbo        : in  apb_slv_out_type;
--      eth0_ahbmi         : out ahb_mst_in_type;
--      eth0_ahbmo         : in  ahb_mst_out_type;
--      edcl_ahbmo         : in  ahb_mst_out_type;
--      dvi_apbi           : out apb_slv_in_type;
--      dvi_apbo           : in  apb_slv_out_type;
--      dvi_ahbmi          : out ahb_mst_in_type;
--      dvi_ahbmo          : in  ahb_mst_out_type;
--      mon_noc            : out monitor_noc_matrix(1 to 6, 0 to CFG_CHIPLET_TILES(BOARD_NUM)-1);
--      mon_acc            : out monitor_acc_vector(0 to relu(CFG_NACC_TILE_CHIPLET(BOARD_NUM)-1));
--      mon_mem            : out monitor_mem_vector(0 to CFG_NMEM_TILE_CHIPLET(BOARD_NUM) + CFG_NSLM_TILE_CHIPLET(BOARD_NUM) + CFG_NSLMDDR_TILE_CHIPLET(BOARD_NUM) - 1);
--      mon_l2             : out monitor_cache_vector(0 to relu(CFG_NL2_CHIPLET(BOARD_NUM) - 1));
--      mon_llc            : out monitor_cache_vector(0 to relu(CFG_NLLC_CHIPLET(BOARD_NUM) - 1));
--      mon_dvfs           : out monitor_dvfs_vector(0 to CFG_CHIPLET_TILES(BOARD_NUM)-1);
--      d2d_clk            : in  std_ulogic;
--      d2d_clk_n_in       : in  std_ulogic;
--      d2d_clk_s_in       : in  std_ulogic;
--      d2d_clk_w_in       : in  std_ulogic;
--      d2d_clk_e_in       : in  std_ulogic;
--      chiplet_data_n_in     : in  coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_data_s_in     : in  coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_data_w_in     : in  coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_data_e_in     : in  coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_data_n_out    : out coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_data_s_out    : out coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_data_w_out    : out coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_data_e_out    : out coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_credit_in_n   : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_credit_in_s   : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_credit_in_w   : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_credit_in_e   : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_credit_out_n  : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_credit_out_s  : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_credit_out_w  : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_credit_out_e  : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_valid_in_n    : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_valid_in_s    : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_valid_in_w    : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_valid_in_e    : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_valid_out_n   : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_valid_out_s   : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_valid_out_w   : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
--      chiplet_valid_out_e   : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
--      d2d_link_ready_n      : out std_logic;
--      d2d_link_ready_s      : out std_logic;
--      d2d_link_ready_w      : out std_logic;
--      d2d_link_ready_e      : out std_logic;
--      dbg_apb_req_seen      : out std_logic;
--      dbg_apb_rsp_sent      : out std_logic
--    );
--  end component esp_chiplet;
  component esp_chiplet is
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
  end component esp_chiplet;

  component tile_cpu is
    generic (
      SIMULATION         : boolean              := false;
      this_has_dco       : integer range 0 to 1 := 0;
      chiplet_index      : integer := 0);
    port (
      raw_rstn           : in  std_ulogic;
      tile_rst           : in  std_ulogic;
      ext_clk            : in  std_ulogic;
      clk_div            : out std_ulogic;
      tile_clk_out       : out std_ulogic;
      tile_rstn_out          : out std_ulogic;
      -- DCO config
      dco_freq_sel       : in std_logic_vector(1 downto 0);
      dco_div_sel        : in std_logic_vector(2 downto 0);
      dco_fc_sel         : in std_logic_vector(5 downto 0);
      dco_cc_sel         : in std_logic_vector(5 downto 0);
      dco_clk_sel        : in std_ulogic;
      dco_en             : in std_ulogic;  
      cpuerr             : out std_ulogic;
      -- NOC
      test1_output_port   : in coh_noc_flit_type;
      test1_data_void_out : in std_ulogic;
      test1_stop_in       : in std_ulogic;
      test2_output_port   : in coh_noc_flit_type;
      test2_data_void_out : in std_ulogic;
      test2_stop_in       : in std_ulogic;
      test3_output_port   : in coh_noc_flit_type;
      test3_data_void_out : in std_ulogic;
      test3_stop_in       : in std_ulogic;
      test4_output_port   : in dma_noc_flit_type;
      test4_data_void_out : in std_ulogic;
      test4_stop_in       : in std_ulogic;
      test5_output_port   : in misc_noc_flit_type;
      test5_data_void_out : in std_ulogic;
      test5_stop_in       : in std_ulogic;
      test6_output_port   : in dma_noc_flit_type;
      test6_data_void_out : in std_ulogic;
      test6_stop_in       : in std_ulogic;
      test1_input_port    : out coh_noc_flit_type;
      test1_data_void_in  : out std_ulogic;
      test1_stop_out      : out std_ulogic;
      test2_input_port    : out coh_noc_flit_type;
      test2_data_void_in  : out std_ulogic;
      test2_stop_out      : out std_ulogic;
      test3_input_port    : out coh_noc_flit_type;
      test3_data_void_in  : out std_ulogic;
      test3_stop_out      : out std_ulogic;
      test4_input_port    : out dma_noc_flit_type;
      test4_data_void_in  : out std_ulogic;
      test4_stop_out      : out std_ulogic;
      test5_input_port    : out misc_noc_flit_type;
      test5_data_void_in  : out std_ulogic;
      test5_stop_out      : out std_ulogic;
      test6_input_port    : out dma_noc_flit_type;
      test6_data_void_in  : out std_ulogic;
      test6_stop_out      : out std_ulogic;
      mon_noc             : in  monitor_noc_vector(1 to 6);
      mon_cache           : out monitor_cache_type;
      mon_dvfs            : out monitor_dvfs_type);
  end component tile_cpu;

  component tile_acc is
    generic (
      this_hls_conf      : hlscfg_t             := 0;
      this_device        : devid_t              := 0;
      this_irq_type      : integer              := 0;
      this_has_l2        : integer range 0 to 1 := 0;
      this_has_dco       : integer range 0 to 1 := 0;
      chiplet_index      : integer := 0);
    port (
      raw_rstn           : in  std_ulogic;
      tile_rst           : in  std_ulogic;
      ext_clk            : in  std_ulogic;
      clk_div            : out std_ulogic;
      tile_clk_out       : out std_ulogic;
      tile_rstn_out          : out std_ulogic;
      -- DCO config
      dco_freq_sel       : in std_logic_vector(1 downto 0);
      dco_div_sel        : in std_logic_vector(2 downto 0);
      dco_fc_sel         : in std_logic_vector(5 downto 0);
      dco_cc_sel         : in std_logic_vector(5 downto 0);
      dco_clk_sel        : in std_ulogic;
      dco_en             : in std_ulogic;  
      -- NOC
      test1_output_port   : in coh_noc_flit_type;
      test1_data_void_out : in std_ulogic;
      test1_stop_in       : in std_ulogic;
      test2_output_port   : in coh_noc_flit_type;
      test2_data_void_out : in std_ulogic;
      test2_stop_in       : in std_ulogic;
      test3_output_port   : in coh_noc_flit_type;
      test3_data_void_out : in std_ulogic;
      test3_stop_in       : in std_ulogic;
      test4_output_port   : in dma_noc_flit_type;
      test4_data_void_out : in std_ulogic;
      test4_stop_in       : in std_ulogic;
      test5_output_port   : in misc_noc_flit_type;
      test5_data_void_out : in std_ulogic;
      test5_stop_in       : in std_ulogic;
      test6_output_port   : in dma_noc_flit_type;
      test6_data_void_out : in std_ulogic;
      test6_stop_in       : in std_ulogic;
      test1_input_port    : out coh_noc_flit_type;
      test1_data_void_in  : out std_ulogic;
      test1_stop_out      : out std_ulogic;
      test2_input_port    : out coh_noc_flit_type;
      test2_data_void_in  : out std_ulogic;
      test2_stop_out      : out std_ulogic;
      test3_input_port    : out coh_noc_flit_type;
      test3_data_void_in  : out std_ulogic;
      test3_stop_out      : out std_ulogic;
      test4_input_port    : out dma_noc_flit_type;
      test4_data_void_in  : out std_ulogic;
      test4_stop_out      : out std_ulogic;
      test5_input_port    : out misc_noc_flit_type;
      test5_data_void_in  : out std_ulogic;
      test5_stop_out      : out std_ulogic;
      test6_input_port    : out dma_noc_flit_type;
      test6_data_void_in  : out std_ulogic;
      test6_stop_out      : out std_ulogic;
      --Monitor signals
      mon_noc             : in  monitor_noc_vector(1 to 6);
      mon_acc             : out monitor_acc_type;
      mon_cache           : out monitor_cache_type;
      mon_dvfs            : out monitor_dvfs_type;
	  acc_activity	      : out std_ulogic
      );
  end component tile_acc;

  component tile_io is
    generic (
      SIMULATION   : boolean              := false;
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
      tile_rstn_out          : out std_ulogic;
      noc_clk_out        : out std_ulogic;
      noc_clk_lock       : out std_ulogic;
      -- DCO config
      dco_freq_sel       : in std_logic_vector(1 downto 0);
      dco_div_sel        : in std_logic_vector(2 downto 0);
      dco_fc_sel         : in std_logic_vector(5 downto 0);
      dco_cc_sel         : in std_logic_vector(5 downto 0);
      dco_clk_sel        : in std_ulogic;
      dco_en             : in std_ulogic;  
      -- I/O bus interfaces
      eth0_apbi          : out apb_slv_in_type;
      eth0_apbo          : in  apb_slv_out_type;
      sgmii0_apbi        : out apb_slv_in_type;
      sgmii0_apbo        : in  apb_slv_out_type;
      eth0_ahbmi         : out ahb_mst_in_type;
      eth0_ahbmo         : in  ahb_mst_out_type;
      edcl_ahbmo         : in  ahb_mst_out_type;
      dvi_apbi           : out apb_slv_in_type;
      dvi_apbo           : in  apb_slv_out_type;
      dvi_ahbmi          : out ahb_mst_in_type;
      dvi_ahbmo          : in  ahb_mst_out_type;
      uart_rxd           : in  std_ulogic;
      uart_txd           : out std_ulogic;
      uart_ctsn          : in  std_ulogic;
      uart_rtsn          : out std_ulogic;
      mdcscaler          : out std_logic_vector(ESP_CSR_MDC_SCALER_CFG_MSB - ESP_CSR_MDC_SCALER_CFG_LSB downto 0);
      -- I/O link
      iolink_data_oen   : out std_logic;
      iolink_data_in    : in  std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
      iolink_data_out   : out std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
      iolink_valid_in   : in  std_ulogic;
      iolink_valid_out  : out std_ulogic;
      iolink_clk_in     : in  std_ulogic;
      iolink_clk_out    : out std_ulogic;
      iolink_credit_in  : in  std_ulogic;
      iolink_credit_out : out std_ulogic;
      -- NOC
      test1_output_port   : in coh_noc_flit_type;
      test1_data_void_out : in std_ulogic;
      test1_stop_in       : in std_ulogic;
      test2_output_port   : in coh_noc_flit_type;
      test2_data_void_out : in std_ulogic;
      test2_stop_in       : in std_ulogic;
      test3_output_port   : in coh_noc_flit_type;
      test3_data_void_out : in std_ulogic;
      test3_stop_in       : in std_ulogic;
      test4_output_port   : in dma_noc_flit_type;
      test4_data_void_out : in std_ulogic;
      test4_stop_in       : in std_ulogic;
      test5_output_port   : in misc_noc_flit_type;
      test5_data_void_out : in std_ulogic;
      test5_stop_in       : in std_ulogic;
      test6_output_port   : in dma_noc_flit_type;
      test6_data_void_out : in std_ulogic;
      test6_stop_in       : in std_ulogic;
      test1_input_port    : out coh_noc_flit_type;
      test1_data_void_in  : out std_ulogic;
      test1_stop_out      : out std_ulogic;
      test2_input_port    : out coh_noc_flit_type;
      test2_data_void_in  : out std_ulogic;
      test2_stop_out      : out std_ulogic;
      test3_input_port    : out coh_noc_flit_type;
      test3_data_void_in  : out std_ulogic;
      test3_stop_out      : out std_ulogic;
      test4_input_port    : out dma_noc_flit_type;
      test4_data_void_in  : out std_ulogic;
      test4_stop_out      : out std_ulogic;
      test5_input_port    : out misc_noc_flit_type;
      test5_data_void_in  : out std_ulogic;
      test5_stop_out      : out std_ulogic;
      test6_input_port    : out dma_noc_flit_type;
      test6_data_void_in  : out std_ulogic;
      test6_stop_out      : out std_ulogic;
      mon_noc             : in  monitor_noc_vector(1 to 6);
      mon_dvfs            : out monitor_dvfs_type);
  end component tile_io;

  component tile_mem is
    generic (
      SIMULATION   : boolean := false;
      this_has_dco : integer range 0 to 1 := 0;
      this_has_ddr : integer range 0 to 1 := 1;
      chiplet_index : integer := 0);
    port (
      raw_rstn           : in  std_ulogic;
      tile_rst           : in  std_ulogic;
      ext_clk            : in  std_ulogic;
      clk_div            : out std_ulogic;
      tile_clk_out       : out std_ulogic;
      tile_rstn_out      : out std_ulogic;
      -- DCO config
      dco_freq_sel       : in std_logic_vector(1 downto 0);
      dco_div_sel        : in std_logic_vector(2 downto 0);
      dco_fc_sel         : in std_logic_vector(5 downto 0);
      dco_cc_sel         : in std_logic_vector(5 downto 0);
      dco_clk_sel        : in std_ulogic;
      dco_en             : in std_ulogic;  
      dco_clk_delay_sel  : in std_logic_vector(11 downto 0);
      -- DDR controller ports (this_has_ddr -> 1)
      dco_clk_div2       : out std_ulogic;
      dco_clk_div2_90    : out std_ulogic;
      phy_rstn           : out std_ulogic;
      ddr_ahbsi          : out ahb_slv_in_type;
      ddr_ahbso          : in  ahb_slv_out_type;
      -- FPGA proxy memory link (this_has_ddr -> 0)
      fpga_data_in       : in  std_logic_vector(CFG_MEM_LINK_BITS - 1 downto 0);
      fpga_data_out      : out std_logic_vector(CFG_MEM_LINK_BITS - 1 downto 0);
      fpga_oen           : out std_ulogic;
      fpga_valid_in      : in  std_ulogic;
      fpga_valid_out     : out std_ulogic;
      fpga_clk_in        : in  std_ulogic;
      fpga_clk_out       : out std_ulogic;
      fpga_credit_in     : in  std_ulogic;
      fpga_credit_out    : out std_ulogic;
      -- NOC
      test1_output_port   : in coh_noc_flit_type;
      test1_data_void_out : in std_ulogic;
      test1_stop_in       : in std_ulogic;
      test2_output_port   : in coh_noc_flit_type;
      test2_data_void_out : in std_ulogic;
      test2_stop_in       : in std_ulogic;
      test3_output_port   : in coh_noc_flit_type;
      test3_data_void_out : in std_ulogic;
      test3_stop_in       : in std_ulogic;
      test4_output_port   : in dma_noc_flit_type;
      test4_data_void_out : in std_ulogic;
      test4_stop_in       : in std_ulogic;
      test5_output_port   : in misc_noc_flit_type;
      test5_data_void_out : in std_ulogic;
      test5_stop_in       : in std_ulogic;
      test6_output_port   : in dma_noc_flit_type;
      test6_data_void_out : in std_ulogic;
      test6_stop_in       : in std_ulogic;
      test1_input_port    : out coh_noc_flit_type;
      test1_data_void_in  : out std_ulogic;
      test1_stop_out      : out std_ulogic;
      test2_input_port    : out coh_noc_flit_type;
      test2_data_void_in  : out std_ulogic;
      test2_stop_out      : out std_ulogic;
      test3_input_port    : out coh_noc_flit_type;
      test3_data_void_in  : out std_ulogic;
      test3_stop_out      : out std_ulogic;
      test4_input_port    : out dma_noc_flit_type;
      test4_data_void_in  : out std_ulogic;
      test4_stop_out      : out std_ulogic;
      test5_input_port    : out misc_noc_flit_type;
      test5_data_void_in  : out std_ulogic;
      test5_stop_out      : out std_ulogic;
      test6_input_port    : out dma_noc_flit_type;
      test6_data_void_in  : out std_ulogic;
      test6_stop_out      : out std_ulogic;
      mon_noc             : in  monitor_noc_vector(1 to 6);
      mon_mem             : out monitor_mem_type;
      mon_cache           : out monitor_cache_type;
      mon_dvfs            : out monitor_dvfs_type);
  end component tile_mem;

  component tile_empty is
    generic (
      SIMULATION   : boolean              := false;
      this_has_dco : integer range 0 to 1 := 0;
      chiplet_index : integer := 0);
    port (
      raw_rstn           : in  std_ulogic;
      tile_rst           : in  std_logic;
      ext_clk            : in  std_ulogic;
      clk_div            : out std_ulogic;
      tile_clk_out       : out std_ulogic;
      tile_rstn_out          : out std_ulogic;
      -- DCO config
      dco_freq_sel       : in std_logic_vector(1 downto 0);
      dco_div_sel        : in std_logic_vector(2 downto 0);
      dco_fc_sel         : in std_logic_vector(5 downto 0);
      dco_cc_sel         : in std_logic_vector(5 downto 0);
      dco_clk_sel        : in std_ulogic;
      dco_en             : in std_ulogic;  
      -- NoC
      test1_output_port   : in coh_noc_flit_type;
      test1_data_void_out : in std_ulogic;
      test1_stop_in       : in std_ulogic;
      test2_output_port   : in coh_noc_flit_type;
      test2_data_void_out : in std_ulogic;
      test2_stop_in       : in std_ulogic;
      test3_output_port   : in coh_noc_flit_type;
      test3_data_void_out : in std_ulogic;
      test3_stop_in       : in std_ulogic;
      test4_output_port   : in dma_noc_flit_type;
      test4_data_void_out : in std_ulogic;
      test4_stop_in       : in std_ulogic;
      test5_output_port   : in misc_noc_flit_type;
      test5_data_void_out : in std_ulogic;
      test5_stop_in       : in std_ulogic;
      test6_output_port   : in dma_noc_flit_type;
      test6_data_void_out : in std_ulogic;
      test6_stop_in       : in std_ulogic;
      test1_input_port    : out coh_noc_flit_type;
      test1_data_void_in  : out std_ulogic;
      test1_stop_out      : out std_ulogic;
      test2_input_port    : out coh_noc_flit_type;
      test2_data_void_in  : out std_ulogic;
      test2_stop_out      : out std_ulogic;
      test3_input_port    : out coh_noc_flit_type;
      test3_data_void_in  : out std_ulogic;
      test3_stop_out      : out std_ulogic;
      test4_input_port    : out dma_noc_flit_type;
      test4_data_void_in  : out std_ulogic;
      test4_stop_out      : out std_ulogic;
      test5_input_port    : out misc_noc_flit_type;
      test5_data_void_in  : out std_ulogic;
      test5_stop_out      : out std_ulogic;
      test6_input_port    : out dma_noc_flit_type;
      test6_data_void_in  : out std_ulogic;
      test6_stop_out      : out std_ulogic;
      mon_noc             : in  monitor_noc_vector(1 to 6);
      mon_dvfs_out        : out monitor_dvfs_type);
  end component tile_empty;

  component tile_slm is
    generic (
      SIMULATION   : boolean := false;
      this_has_dco : integer range 0 to 1 := 0;
      this_has_ddr : integer range 0 to 1 := 0;
      chiplet_index : integer := 0);
    port (
      raw_rstn           : in  std_ulogic;
      tile_rst           : in  std_ulogic;
      ext_clk            : in  std_ulogic;
      clk_div            : out std_ulogic;
      tile_clk_out       : out std_ulogic;
      tile_rstn_out      : out std_ulogic;
      tile_id_out        : out std_logic_vector(ESP_CSR_TILE_ID_MSB - ESP_CSR_TILE_ID_LSB downto 0);
      -- DCO config
      dco_freq_sel       : in std_logic_vector(1 downto 0);
      dco_div_sel        : in std_logic_vector(2 downto 0);
      dco_fc_sel         : in std_logic_vector(5 downto 0);
      dco_cc_sel         : in std_logic_vector(5 downto 0);
      dco_clk_sel        : in std_ulogic;
      dco_en             : in std_ulogic;  
      dco_clk_delay_sel  : in std_logic_vector(11 downto 0);
      -- DDR controller ports (this_has_ddr -> 1)
      dco_clk_div2       : out std_ulogic;
      dco_clk_div2_90    : out std_ulogic;
      phy_rstn           : out std_ulogic;
      ddr_ahbsi          : out ahb_slv_in_type;
      ddr_ahbso          : in  ahb_slv_out_type;
      ddr_cfg0           : out std_logic_vector(31 downto 0);
      ddr_cfg1           : out std_logic_vector(31 downto 0);
      ddr_cfg2           : out std_logic_vector(31 downto 0);
      -- NoC
      test1_output_port   : in coh_noc_flit_type;
      test1_data_void_out : in std_ulogic;
      test1_stop_in       : in std_ulogic;
      test2_output_port   : in coh_noc_flit_type;
      test2_data_void_out : in std_ulogic;
      test2_stop_in       : in std_ulogic;
      test3_output_port   : in coh_noc_flit_type;
      test3_data_void_out : in std_ulogic;
      test3_stop_in       : in std_ulogic;
      test4_output_port   : in dma_noc_flit_type;
      test4_data_void_out : in std_ulogic;
      test4_stop_in       : in std_ulogic;
      test5_output_port   : in misc_noc_flit_type;
      test5_data_void_out : in std_ulogic;
      test5_stop_in       : in std_ulogic;
      test6_output_port   : in dma_noc_flit_type;
      test6_data_void_out : in std_ulogic;
      test6_stop_in       : in std_ulogic;
      test1_input_port    : out coh_noc_flit_type;
      test1_data_void_in  : out std_ulogic;
      test1_stop_out      : out std_ulogic;
      test2_input_port    : out coh_noc_flit_type;
      test2_data_void_in  : out std_ulogic;
      test2_stop_out      : out std_ulogic;
      test3_input_port    : out coh_noc_flit_type;
      test3_data_void_in  : out std_ulogic;
      test3_stop_out      : out std_ulogic;
      test4_input_port    : out dma_noc_flit_type;
      test4_data_void_in  : out std_ulogic;
      test4_stop_out      : out std_ulogic;
      test5_input_port    : out misc_noc_flit_type;
      test5_data_void_in  : out std_ulogic;
      test5_stop_out      : out std_ulogic;
      test6_input_port    : out dma_noc_flit_type;
      test6_data_void_in  : out std_ulogic;
      test6_stop_out      : out std_ulogic;
      mon_noc             : in  monitor_noc_vector(1 to 6);
      mon_mem             : out monitor_mem_type;
      mon_dvfs            : out monitor_dvfs_type);
  end component tile_slm;

end tiles_pkg;
