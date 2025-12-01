-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
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
use work.esp_noc_csr_pkg.all;
use work.sldacc.all;
use work.tile.all;
use work.nocpackage.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;
use work.tiles_asic_pkg.all;
use work.pads_loc.all;

entity ESP_ASIC_TOP is
  generic (
    SIMULATION : boolean := false;
    D2D_CHANNELS_N  : integer := 0;
    D2D_CHANNELS_S  : integer := 0;
    D2D_CHANNELS_W  : integer := 0;
    D2D_CHANNELS_E  : integer := 0;
    chiplet_index   : integer := 0
  );
  port (
    reset           : in    std_logic;
    d2d_clk         : in    std_logic;
    -- Backup external clocks for selected tiles and NoC
    ext_clk         : in    std_logic;
    clk_div         : out   std_logic;
    -- FPGA proxy memory link
    fpga_data       : inout std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index) * CFG_MEM_LINK_BITS - 1 downto 0);
    fpga_valid_in   : in    std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index)-1 downto 0);
    fpga_valid_out  : out   std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index)-1 downto 0);
    fpga_clk_in     : in    std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index)-1 downto 0);
    fpga_clk_out    : out   std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index)-1 downto 0);
    fpga_credit_in  : in    std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index)-1 downto 0);
    fpga_credit_out : out   std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index)-1 downto 0);
    -- I/O link
    iolink_data       : inout std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
    iolink_valid_in   : in    std_ulogic;
    iolink_valid_out  : out   std_ulogic;
    iolink_clk_in     : in    std_ulogic;
    iolink_clk_out    : out   std_ulogic;
    iolink_credit_in  : in    std_ulogic;
    iolink_credit_out : out   std_ulogic;
    -- Ethernet signals
    reset_o2        : out   std_ulogic;
    etx_clk         : in    std_ulogic;
    erx_clk         : in    std_ulogic;
    erxd            : in    std_logic_vector(3 downto 0);
    erx_dv          : in    std_ulogic;
    erx_er          : in    std_ulogic;
    erx_col         : in    std_ulogic;
    erx_crs         : in    std_ulogic;
    etxd            : out   std_logic_vector(3 downto 0);
    etx_en          : out   std_ulogic;
    etx_er          : out   std_ulogic;
    emdc            : out   std_ulogic;
    emdio           : inout std_logic;
    -- UART
    uart_rxd        : in    std_logic;  -- UART1_RX (u1i.rxd)
    uart_txd        : out   std_logic;  -- UART1_TX (u1o.txd)
    uart_ctsn       : in    std_logic;  -- UART1_RTSN (u1i.ctsn)
    uart_rtsn       : out   std_logic;  -- UART1_RTSN (u1o.rtsn)
    --JTAG
    tclk            : in    std_logic;
    tms             : in    std_logic;
    tdi_io          : in    std_logic;
    tdi_cpu         : in    std_logic;
    tdi_mem         : in    std_logic;
    tdi_acc         : in    std_logic;
    tdo_io          : out   std_logic;
    tdo_cpu         : out   std_logic;
    tdo_mem         : out   std_logic;
    tdo_acc         : out   std_logic;
    chiplet_data_n_in     : in  coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_s_in     : in  coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_w_in     : in  coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_e_in     : in  coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_n_out    : out coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_s_out    : out coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_w_out    : out coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_e_out    : out coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_in_n   : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_in_s   : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_in_w   : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_in_e   : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_out_n  : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_out_s  : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_out_w  : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_out_e  : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);     
    chiplet_valid_in_n    : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_in_s    : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_in_w    : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_in_e    : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_out_n   : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_out_s   : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_out_w   : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_out_e   : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0)
  );
end;



architecture rtl of ESP_ASIC_TOP is

  component d2d_tx_top is
    generic (
      TXCHANNELS    : integer;
      TILES         : integer;
      flow_control  : integer;  --0 = AN; 1 = CB
      chwidth       : integer;
      cohwidth  : integer;
      miscwidth : integer;
      dmawidth  : integer
    );
    port (
      clk                 : in  std_ulogic;
      rst                 : in  std_ulogic;
      d2d_clk_in          : in  std_ulogic;
  
      -- D2D Tx --> D2D Rx
      d2d_snd_data_out    : out coh_noc_flit_vector(TXCHANNELS-1 downto 0);
      d2d_valid_out       : out std_logic_vector(TXCHANNELS-1 downto 0);
  
      -- D2D Rx --> D2D Tx
      d2d_credit_in       : in  std_logic_vector(TXCHANNELS-1 downto 0);
      
      -- NoC --> D2D
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
  
      -- D2D --> NoC
      noc1_stop_out       : out std_logic_vector(TILES-1 downto 0);
      noc2_stop_out       : out std_logic_vector(TILES-1 downto 0);
      noc3_stop_out       : out std_logic_vector(TILES-1 downto 0);
      noc4_stop_out       : out std_logic_vector(TILES-1 downto 0);
      noc5_stop_out       : out std_logic_vector(TILES-1 downto 0);
      noc6_stop_out       : out std_logic_vector(TILES-1 downto 0)
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
  
      -- D2D Rx --> D2D Tx
      d2d_credit_out    : out std_logic_vector(RXCHANNELS-1 downto 0);
      
      -- D2D --> NoC
      noc1_data_out      : out coh_noc_flit_vector(TILES-1 downto 0);
      noc2_data_out      : out coh_noc_flit_vector(TILES-1 downto 0);
      noc3_data_out      : out coh_noc_flit_vector(TILES-1 downto 0);
      noc4_data_out      : out dma_noc_flit_vector(TILES-1 downto 0);
      noc5_data_out      : out misc_noc_flit_vector(TILES-1 downto 0);
      noc6_data_out      : out dma_noc_flit_vector(TILES-1 downto 0);
      
      noc1_data_void_out : out std_logic_vector(TILES-1 downto 0);
      noc2_data_void_out : out std_logic_vector(TILES-1 downto 0);
      noc3_data_void_out : out std_logic_vector(TILES-1 downto 0);
      noc4_data_void_out : out std_logic_vector(TILES-1 downto 0);
      noc5_data_void_out : out std_logic_vector(TILES-1 downto 0);
      noc6_data_void_out : out std_logic_vector(TILES-1 downto 0);
      
      -- NoC --> D2D
      noc1_stop_in       : in  std_logic_vector(TILES-1 downto 0);
      noc2_stop_in       : in  std_logic_vector(TILES-1 downto 0);
      noc3_stop_in       : in  std_logic_vector(TILES-1 downto 0);
      noc4_stop_in       : in  std_logic_vector(TILES-1 downto 0);
      noc5_stop_in       : in  std_logic_vector(TILES-1 downto 0);
      noc6_stop_in       : in  std_logic_vector(TILES-1 downto 0)
    );
  end component d2d_rx_top;

  constant CHIPLET_NUM_TILES : integer := CFG_CHIPLET_TILES(chiplet_index);
  constant XLEN : integer := CFG_XLEN(chiplet_index);
  constant YLEN : integer := CFG_YLEN(chiplet_index);
  constant CHIPLET_IDX_BASE : integer := CFG_CHIPLET_TILE_BASE(chiplet_index);
  
  constant NCPU_THIS      : integer := CFG_NCPU_TILE_CHIPLET(chiplet_index);
  constant NMEM_THIS      : integer := CFG_NMEM_TILE_CHIPLET(chiplet_index);
  constant NSLM_THIS      : integer := CFG_NSLM_TILE_CHIPLET(chiplet_index);
  constant NSLMDDR_THIS   : integer := CFG_NSLMDDR_TILE_CHIPLET(chiplet_index);
  constant NL2_THIS       : integer := CFG_NL2_CHIPLET(chiplet_index);
  constant NLLC_THIS      : integer := CFG_NLLC_CHIPLET(chiplet_index);
  constant NLLC_COH_THIS  : integer := CFG_NLLC_COHERENT_CHIPLET(chiplet_index);

  -- Global ID to local ID conversion
--  constant io_idx : integer := io_tile_id(chiplet_index) - CHIPLET_IDX_BASE;
--  constant mem_idx : integer := mem_tile_id(CFG_NMEM_TILE_BASE(chiplet_index)) - CHIPLET_IDX_BASE;
  constant acc_idx : integer := acc_tile_id(CFG_NACC_TILE_BASE(chiplet_index)) - CHIPLET_IDX_BASE;

  type handshake_vec is array (natural range <>) of std_logic_vector(3 downto 0);
  type boolean_vec is array (natural range <>) of boolean;

--  constant is_io_tile : boolean_vec(0 to CHIPLET_NUM_TILES-1) := (io_idx => true, others => false);

  -- NOC Signals
  signal noc1_data_n_in     : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc1_data_s_in     : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc1_data_w_in     : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc1_data_e_in     : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc1_data_void_in  : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc1_stop_in       : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc1_data_n_out    : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc1_data_s_out    : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc1_data_w_out    : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc1_data_e_out    : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc1_data_void_out : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc1_stop_out      : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc2_data_n_in     : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc2_data_s_in     : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc2_data_w_in     : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc2_data_e_in     : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc2_data_void_in  : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc2_stop_in       : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc2_data_n_out    : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc2_data_s_out    : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc2_data_w_out    : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc2_data_e_out    : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc2_data_void_out : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc2_stop_out      : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc3_data_n_in     : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc3_data_s_in     : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc3_data_w_in     : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc3_data_e_in     : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc3_data_void_in  : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc3_stop_in       : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc3_data_n_out    : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc3_data_s_out    : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc3_data_w_out    : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc3_data_e_out    : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc3_data_void_out : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc3_stop_out      : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc4_data_n_in     : dma_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc4_data_s_in     : dma_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc4_data_w_in     : dma_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc4_data_e_in     : dma_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc4_data_void_in  : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc4_stop_in       : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc4_data_n_out    : dma_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc4_data_s_out    : dma_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc4_data_w_out    : dma_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc4_data_e_out    : dma_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc4_data_void_out : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc4_stop_out      : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc5_data_n_in     : misc_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc5_data_s_in     : misc_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc5_data_w_in     : misc_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc5_data_e_in     : misc_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc5_data_void_in  : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc5_stop_in       : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc5_data_n_out    : misc_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc5_data_s_out    : misc_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc5_data_w_out    : misc_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc5_data_e_out    : misc_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc5_data_void_out : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc5_stop_out      : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc6_data_n_in     : dma_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc6_data_s_in     : dma_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc6_data_w_in     : dma_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc6_data_e_in     : dma_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc6_data_void_in  : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc6_stop_in       : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc6_data_n_out    : dma_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc6_data_s_out    : dma_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc6_data_w_out    : dma_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc6_data_e_out    : dma_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc6_data_void_out : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);
  signal noc6_stop_out      : handshake_vec(CHIPLET_NUM_TILES-1 downto 0);

  signal noc1_data_l_in          : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc1_data_l_out         : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc1_data_void_in_tile  : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc1_data_void_out_tile : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc1_stop_in_tile       : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc1_stop_out_tile      : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc2_data_l_in          : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc2_data_l_out         : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc2_data_void_in_tile  : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc2_data_void_out_tile : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc2_stop_in_tile       : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc2_stop_out_tile      : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc3_data_l_in          : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc3_data_l_out         : coh_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc3_data_void_in_tile  : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc3_data_void_out_tile : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc3_stop_in_tile       : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc3_stop_out_tile      : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc4_data_l_in          : dma_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc4_data_l_out         : dma_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc4_data_void_in_tile  : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc4_data_void_out_tile : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc4_stop_in_tile       : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc4_stop_out_tile      : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc5_data_l_in          : misc_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc5_data_l_out         : misc_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc5_data_void_in_tile  : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc5_data_void_out_tile : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc5_stop_in_tile       : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc5_stop_out_tile      : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc6_data_l_in          : dma_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc6_data_l_out         : dma_noc_flit_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc6_data_void_in_tile  : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc6_data_void_out_tile : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc6_stop_in_tile       : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc6_stop_out_tile      : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);

  -- signal mapping
  signal noc1_data_void_in_mapped_n  : std_logic_vector(XLEN-1 downto 0);
  signal noc1_stop_out_mapped_n      : std_logic_vector(XLEN-1 downto 0);
  signal noc1_data_void_out_mapped_n : std_logic_vector(XLEN-1 downto 0);
  signal noc1_stop_in_mapped_n       : std_logic_vector(XLEN-1 downto 0);
  signal noc2_data_void_in_mapped_n  : std_logic_vector(XLEN-1 downto 0);
  signal noc2_stop_out_mapped_n      : std_logic_vector(XLEN-1 downto 0);
  signal noc2_data_void_out_mapped_n : std_logic_vector(XLEN-1 downto 0);
  signal noc2_stop_in_mapped_n       : std_logic_vector(XLEN-1 downto 0);
  signal noc3_data_void_in_mapped_n  : std_logic_vector(XLEN-1 downto 0);
  signal noc3_stop_out_mapped_n      : std_logic_vector(XLEN-1 downto 0);
  signal noc3_data_void_out_mapped_n : std_logic_vector(XLEN-1 downto 0);
  signal noc3_stop_in_mapped_n       : std_logic_vector(XLEN-1 downto 0);
  signal noc4_data_void_in_mapped_n  : std_logic_vector(XLEN-1 downto 0);
  signal noc4_stop_out_mapped_n      : std_logic_vector(XLEN-1 downto 0);
  signal noc4_data_void_out_mapped_n : std_logic_vector(XLEN-1 downto 0);
  signal noc4_stop_in_mapped_n       : std_logic_vector(XLEN-1 downto 0);
  signal noc5_data_void_in_mapped_n  : std_logic_vector(XLEN-1 downto 0);
  signal noc5_stop_out_mapped_n      : std_logic_vector(XLEN-1 downto 0);
  signal noc5_data_void_out_mapped_n : std_logic_vector(XLEN-1 downto 0);
  signal noc5_stop_in_mapped_n       : std_logic_vector(XLEN-1 downto 0);
  signal noc6_data_void_in_mapped_n  : std_logic_vector(XLEN-1 downto 0);
  signal noc6_stop_out_mapped_n      : std_logic_vector(XLEN-1 downto 0);
  signal noc6_data_void_out_mapped_n : std_logic_vector(XLEN-1 downto 0);
  signal noc6_stop_in_mapped_n       : std_logic_vector(XLEN-1 downto 0);

  signal noc1_data_void_in_mapped_s  : std_logic_vector(XLEN-1 downto 0);
  signal noc1_stop_out_mapped_s      : std_logic_vector(XLEN-1 downto 0);
  signal noc1_data_void_out_mapped_s : std_logic_vector(XLEN-1 downto 0);
  signal noc1_stop_in_mapped_s       : std_logic_vector(XLEN-1 downto 0);
  signal noc2_data_void_in_mapped_s  : std_logic_vector(XLEN-1 downto 0);
  signal noc2_stop_out_mapped_s      : std_logic_vector(XLEN-1 downto 0);
  signal noc2_data_void_out_mapped_s : std_logic_vector(XLEN-1 downto 0);
  signal noc2_stop_in_mapped_s       : std_logic_vector(XLEN-1 downto 0);
  signal noc3_data_void_in_mapped_s  : std_logic_vector(XLEN-1 downto 0);
  signal noc3_stop_out_mapped_s      : std_logic_vector(XLEN-1 downto 0);
  signal noc3_data_void_out_mapped_s : std_logic_vector(XLEN-1 downto 0);
  signal noc3_stop_in_mapped_s       : std_logic_vector(XLEN-1 downto 0);
  signal noc4_data_void_in_mapped_s  : std_logic_vector(XLEN-1 downto 0);
  signal noc4_stop_out_mapped_s      : std_logic_vector(XLEN-1 downto 0);
  signal noc4_data_void_out_mapped_s : std_logic_vector(XLEN-1 downto 0);
  signal noc4_stop_in_mapped_s       : std_logic_vector(XLEN-1 downto 0);
  signal noc5_data_void_in_mapped_s  : std_logic_vector(XLEN-1 downto 0);
  signal noc5_stop_out_mapped_s      : std_logic_vector(XLEN-1 downto 0);
  signal noc5_data_void_out_mapped_s : std_logic_vector(XLEN-1 downto 0);
  signal noc5_stop_in_mapped_s       : std_logic_vector(XLEN-1 downto 0);
  signal noc6_data_void_in_mapped_s  : std_logic_vector(XLEN-1 downto 0);
  signal noc6_stop_out_mapped_s      : std_logic_vector(XLEN-1 downto 0);
  signal noc6_data_void_out_mapped_s : std_logic_vector(XLEN-1 downto 0);
  signal noc6_stop_in_mapped_s       : std_logic_vector(XLEN-1 downto 0);

  signal noc1_data_void_in_mapped_e  : std_logic_vector(YLEN-1 downto 0);
  signal noc1_stop_out_mapped_e      : std_logic_vector(YLEN-1 downto 0);
  signal noc1_data_void_out_mapped_e : std_logic_vector(YLEN-1 downto 0);
  signal noc1_stop_in_mapped_e       : std_logic_vector(YLEN-1 downto 0);
  signal noc2_data_void_in_mapped_e  : std_logic_vector(YLEN-1 downto 0);
  signal noc2_stop_out_mapped_e      : std_logic_vector(YLEN-1 downto 0);
  signal noc2_data_void_out_mapped_e : std_logic_vector(YLEN-1 downto 0);
  signal noc2_stop_in_mapped_e       : std_logic_vector(YLEN-1 downto 0);
  signal noc3_data_void_in_mapped_e  : std_logic_vector(YLEN-1 downto 0);
  signal noc3_stop_out_mapped_e      : std_logic_vector(YLEN-1 downto 0);
  signal noc3_data_void_out_mapped_e : std_logic_vector(YLEN-1 downto 0);
  signal noc3_stop_in_mapped_e       : std_logic_vector(YLEN-1 downto 0);
  signal noc4_data_void_in_mapped_e  : std_logic_vector(YLEN-1 downto 0);
  signal noc4_stop_out_mapped_e      : std_logic_vector(YLEN-1 downto 0);
  signal noc4_data_void_out_mapped_e : std_logic_vector(YLEN-1 downto 0);
  signal noc4_stop_in_mapped_e       : std_logic_vector(YLEN-1 downto 0);
  signal noc5_data_void_in_mapped_e  : std_logic_vector(YLEN-1 downto 0);
  signal noc5_stop_out_mapped_e      : std_logic_vector(YLEN-1 downto 0);
  signal noc5_data_void_out_mapped_e : std_logic_vector(YLEN-1 downto 0);
  signal noc5_stop_in_mapped_e       : std_logic_vector(YLEN-1 downto 0);
  signal noc6_data_void_in_mapped_e  : std_logic_vector(YLEN-1 downto 0);
  signal noc6_stop_out_mapped_e      : std_logic_vector(YLEN-1 downto 0);
  signal noc6_data_void_out_mapped_e : std_logic_vector(YLEN-1 downto 0);
  signal noc6_stop_in_mapped_e       : std_logic_vector(YLEN-1 downto 0);

  signal noc1_data_void_in_mapped_w  : std_logic_vector(YLEN-1 downto 0);
  signal noc1_stop_out_mapped_w      : std_logic_vector(YLEN-1 downto 0);
  signal noc1_data_void_out_mapped_w : std_logic_vector(YLEN-1 downto 0);
  signal noc1_stop_in_mapped_w       : std_logic_vector(YLEN-1 downto 0);
  signal noc2_data_void_in_mapped_w  : std_logic_vector(YLEN-1 downto 0);
  signal noc2_stop_out_mapped_w      : std_logic_vector(YLEN-1 downto 0);
  signal noc2_data_void_out_mapped_w : std_logic_vector(YLEN-1 downto 0);
  signal noc2_stop_in_mapped_w       : std_logic_vector(YLEN-1 downto 0);
  signal noc3_data_void_in_mapped_w  : std_logic_vector(YLEN-1 downto 0);
  signal noc3_stop_out_mapped_w      : std_logic_vector(YLEN-1 downto 0);
  signal noc3_data_void_out_mapped_w : std_logic_vector(YLEN-1 downto 0);
  signal noc3_stop_in_mapped_w       : std_logic_vector(YLEN-1 downto 0);
  signal noc4_data_void_in_mapped_w  : std_logic_vector(YLEN-1 downto 0);
  signal noc4_stop_out_mapped_w      : std_logic_vector(YLEN-1 downto 0);
  signal noc4_data_void_out_mapped_w : std_logic_vector(YLEN-1 downto 0);
  signal noc4_stop_in_mapped_w       : std_logic_vector(YLEN-1 downto 0);
  signal noc5_data_void_in_mapped_w  : std_logic_vector(YLEN-1 downto 0);
  signal noc5_stop_out_mapped_w      : std_logic_vector(YLEN-1 downto 0);
  signal noc5_data_void_out_mapped_w : std_logic_vector(YLEN-1 downto 0);
  signal noc5_stop_in_mapped_w       : std_logic_vector(YLEN-1 downto 0);
  signal noc6_data_void_in_mapped_w  : std_logic_vector(YLEN-1 downto 0);
  signal noc6_stop_out_mapped_w      : std_logic_vector(YLEN-1 downto 0);
  signal noc6_data_void_out_mapped_w : std_logic_vector(YLEN-1 downto 0);
  signal noc6_stop_in_mapped_w       : std_logic_vector(YLEN-1 downto 0);

  signal noc1_data_in_mapped_w       : coh_noc_flit_vector(YLEN-1 downto 0);
  signal noc2_data_in_mapped_w       : coh_noc_flit_vector(YLEN-1 downto 0);
  signal noc3_data_in_mapped_w       : coh_noc_flit_vector(YLEN-1 downto 0);
  signal noc4_data_in_mapped_w       : dma_noc_flit_vector(YLEN-1 downto 0);
  signal noc5_data_in_mapped_w       : misc_noc_flit_vector(YLEN-1 downto 0);
  signal noc6_data_in_mapped_w       : dma_noc_flit_vector(YLEN-1 downto 0);

  signal noc1_data_out_mapped_w      : coh_noc_flit_vector(YLEN-1 downto 0);
  signal noc2_data_out_mapped_w      : coh_noc_flit_vector(YLEN-1 downto 0);
  signal noc3_data_out_mapped_w      : coh_noc_flit_vector(YLEN-1 downto 0);
  signal noc4_data_out_mapped_w      : dma_noc_flit_vector(YLEN-1 downto 0);
  signal noc5_data_out_mapped_w      : misc_noc_flit_vector(YLEN-1 downto 0);
  signal noc6_data_out_mapped_w      : dma_noc_flit_vector(YLEN-1 downto 0);

  signal noc1_data_in_mapped_e       : coh_noc_flit_vector(YLEN-1 downto 0);
  signal noc2_data_in_mapped_e       : coh_noc_flit_vector(YLEN-1 downto 0);
  signal noc3_data_in_mapped_e       : coh_noc_flit_vector(YLEN-1 downto 0);
  signal noc4_data_in_mapped_e       : dma_noc_flit_vector(YLEN-1 downto 0);
  signal noc5_data_in_mapped_e       : misc_noc_flit_vector(YLEN-1 downto 0);
  signal noc6_data_in_mapped_e       : dma_noc_flit_vector(YLEN-1 downto 0);

  signal noc1_data_out_mapped_e      : coh_noc_flit_vector(YLEN-1 downto 0);
  signal noc2_data_out_mapped_e      : coh_noc_flit_vector(YLEN-1 downto 0);
  signal noc3_data_out_mapped_e      : coh_noc_flit_vector(YLEN-1 downto 0);
  signal noc4_data_out_mapped_e      : dma_noc_flit_vector(YLEN-1 downto 0);
  signal noc5_data_out_mapped_e      : misc_noc_flit_vector(YLEN-1 downto 0);
  signal noc6_data_out_mapped_e      : dma_noc_flit_vector(YLEN-1 downto 0);

  type mon_noc_vector is array (CHIPLET_NUM_TILES-1 downto 0) of monitor_noc_vector(1 to 6);
  signal mon_noc                 : mon_noc_vector;

  -- DCO config
  type dco_clk_delay_sel_vector is array (CHIPLET_NUM_TILES-1 downto 0) of std_logic_vector(11 downto 0);
  type dco_freq_sel_vector      is array (CHIPLET_NUM_TILES-1 downto 0) of std_logic_vector(1 downto 0);
  type dco_cc_sel_vector        is array (CHIPLET_NUM_TILES-1 downto 0) of std_logic_vector(5 downto 0);
  type dco_fc_sel_vector        is array (CHIPLET_NUM_TILES-1 downto 0) of std_logic_vector(5 downto 0);
  type dco_div_sel_vector       is array (CHIPLET_NUM_TILES-1 downto 0) of std_logic_vector(2 downto 0);

  signal dco_en            : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal dco_clk_sel       : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal dco_cc_sel        : dco_cc_sel_vector; 
  signal dco_fc_sel        : dco_fc_sel_vector; 
  signal dco_div_sel       : dco_div_sel_vector;
  signal dco_freq_sel      : dco_freq_sel_vector; 
  signal dco_clk_delay_sel : dco_clk_delay_sel_vector;


  -- Global NoC reset and clock
  signal noc_clk       : std_ulogic;
  signal noc_rstn      : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal raw_rstn      : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0);
  signal noc_clk_lock  : std_ulogic;
  signal tile_clk      : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0); 
  signal tile_rstn     : std_logic_vector(CHIPLET_NUM_TILES-1 downto 0); 
 
  -- I/O for PADS
  constant pad_fixed_cfg : std_logic_vector(19 - (ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB + 1) downto 0) := (others => '0');
  type pad_cfg_full_array is array (0 to CHIPLET_NUM_TILES - 1) of std_logic_vector(19 downto 0);
  type pad_cfg_array is array (0 to CHIPLET_NUM_TILES - 1) of std_logic_vector(ESP_CSR_PAD_CFG_MSB - ESP_CSR_PAD_CFG_LSB downto 0);
  -- Current default configuration is SR=0, DS1=1, DS0=1
  signal pad_cfg : pad_cfg_array;
  signal full_pad_cfg : pad_cfg_full_array;
  signal fpga_data_pad_cfg : std_logic_vector(20 * CFG_NMEM_TILE_CHIPLET(chiplet_index) * CFG_MEM_LINK_BITS - 1 downto 0);

  -- External clocks and reset
  signal reset_int   : std_logic;
  signal ext_clk_int : std_logic;  -- backup tile clock
  signal clk_div_int : std_logic_vector(0 to CHIPLET_NUM_TILES - 1);  -- tile clock monitor for testing purposes
  signal ext_clk_noc_int : std_logic;
  signal clk_div_noc_int : std_logic;

  -- Test interface
  signal tdi_int  : std_logic_vector(0 to CHIPLET_NUM_TILES - 1);
  signal tdo_int  : std_logic_vector(0 to CHIPLET_NUM_TILES - 1);
  signal tms_int  : std_logic;
  signal tclk_int : std_logic;

  -- FPGA proxy
  signal fpga_oen            : std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index) - 1 downto 0);
  signal fpga_oen_ext        : std_logic_vector(CFG_MEM_LINK_BITS * CFG_NMEM_TILE_CHIPLET(chiplet_index) - 1 downto 0);
  signal fpga_data_in        : std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index) * (CFG_MEM_LINK_BITS) - 1 downto 0);
  signal fpga_data_out       : std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index) * (CFG_MEM_LINK_BITS) - 1 downto 0);
  signal fpga_valid_in_int   : std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index) - 1 downto 0);
  signal fpga_valid_out_int  : std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index) - 1 downto 0);
  signal fpga_clk_in_int     : std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index) - 1 downto 0);
  signal fpga_clk_out_int    : std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index) - 1 downto 0);
  signal fpga_credit_in_int  : std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index) - 1 downto 0);
  signal fpga_credit_out_int : std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index) - 1 downto 0);

  -- I/O Link
  signal iolink_data_ien                             : std_ulogic;
  signal iolink_data_oen                             : std_ulogic;
  signal iolink_data_in_int                          : std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
  signal iolink_data_out_int                         : std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
  signal iolink_valid_in_int                         : std_ulogic;
  signal iolink_valid_out_int, iolink_valid_out_io   : std_ulogic;
  signal iolink_clk_in_int                           : std_ulogic;
  signal iolink_clk_out_int, iolink_clk_out_io       : std_ulogic;
  signal iolink_credit_in_int                        : std_ulogic;
  signal iolink_credit_out_int, iolink_credit_out_io : std_ulogic;

  -- Ethernet signals
  signal reset_o2_int    : std_ulogic;
  signal etx_clk_int     : std_ulogic;
  signal erx_clk_int     : std_ulogic;
  signal erxd_int        : std_logic_vector(3 downto 0);
  signal erx_dv_int      : std_ulogic;
  signal erx_er_int      : std_ulogic;
  signal erx_col_int     : std_ulogic;
  signal erx_crs_int     : std_ulogic;
  signal etxd_int        : std_logic_vector(3 downto 0);
  signal etx_en_int      : std_ulogic;
  signal etx_er_int      : std_ulogic;
  signal emdc_int        : std_ulogic;
  signal emdio_i         : std_logic;
  signal emdio_o         : std_logic;
  signal emdio_oe        : std_logic;

  -- UART
  signal uart_rxd_int    : std_logic;   -- UART1_RX (u1i.rxd)
  signal uart_txd_int    : std_logic;   -- UART1_TX (u1o.txd)
  signal uart_ctsn_int   : std_logic;   -- UART1_RTSN (u1i.ctsn)
  signal uart_rtsn_int   : std_logic;   -- UART1_RTSN (u1o.rtsn)

  signal cpuerr_vec      : std_ulogic_vector(0 to NCPU_THIS-1);

  constant ROW : integer := chiplet_index / CFG_CHIPLET_COLS;
  constant COL : integer := chiplet_index mod CFG_CHIPLET_COLS;

begin

--  --pragma translate_off
--  assert (io_idx >= 0) and (io_idx < CHIPLET_NUM_TILES)
--    report "io_idx for chiplet (" & integer'image(chiplet_index) & ") out of range for this chiplet"
--    severity failure;
  
  -----------------------------------------------------------------------------
  -- PADS
  -----------------------------------------------------------------------------

  pad_cfg_gen : for i in 0 to CHIPLET_NUM_TILES - 1 generate
    full_pad_cfg(i) <= pad_fixed_cfg & pad_cfg(i);
  end generate pad_cfg_gen;

  reset_pad : inpad generic map (loc => reset_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (reset, reset_int);
  -- ext_clk and div_clk for NoC (DCO located in the I/O tile)
  ext_clk_pad : inpad generic map (loc => ext_clk_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (ext_clk, ext_clk_int);

  io_gen : if CFG_IO_TILE_CHIPLET(chiplet_index) = '1' generate
    constant io_idx : integer := io_tile_id(chiplet_index) - CHIPLET_IDX_BASE;
  begin
    clk_div_pad : outpad generic map (loc => clk_div_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (clk_div, clk_div_noc_int, full_pad_cfg(io_idx));
    -- tdi/o_io
    tdi_io_pad : inpad generic map (loc => tdi_io_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdi_io, tdi_int(io_idx));
    tdo_io_pad : outpad generic map (loc => tdo_io_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdo_io, tdo_int(io_idx), full_pad_cfg(io_idx));
    -- Ethernet
    reset_o2_pad : outpad generic map (tech => CFG_FABTECH, loc => reset_o2_pad_loc, level => cmos, voltage => x18v)
      port map (reset_o2, reset_o2_int, full_pad_cfg(io_idx));
  
    etx_clk_pad : inpad generic map (tech => CFG_FABTECH, loc => etx_clk_pad_loc, level => cmos, voltage => x18v)
      port map (etx_clk, etx_clk_int);
    erx_clk_pad : inpad generic map (tech => CFG_FABTECH, loc => erx_clk_pad_loc, level => cmos, voltage => x18v)
      port map (erx_clk, erx_clk_int);
    erxd_pad : inpadv generic map (tech => CFG_FABTECH, loc => erxd_pad_loc, level => cmos, voltage => x18v, width => 4)
      port map (erxd, erxd_int);
    erx_dv_pad : inpad generic map (tech => CFG_FABTECH, loc => erx_dv_pad_loc, level => cmos, voltage => x18v)
      port map (erx_dv, erx_dv_int);
    erx_er_pad : inpad generic map (tech => CFG_FABTECH, loc => erx_er_pad_loc, level => cmos, voltage => x18v)
      port map (erx_er, erx_er_int);
    erx_col_pad : inpad generic map (tech => CFG_FABTECH, loc => erx_col_pad_loc, level => cmos, voltage => x18v)
      port map (erx_col, erx_col_int);
    erx_crs_pad : inpad generic map (tech => CFG_FABTECH, loc => erx_crs_pad_loc, level => cmos, voltage => x18v)
      port map (erx_crs, erx_crs_int);
  
    emdio_pad : iopad generic map (tech => CFG_FABTECH, loc => emdio_pad_loc, level => cmos, voltage => x18v, oepol => 1)
      port map (emdio, emdio_o, emdio_oe, emdio_i, full_pad_cfg(io_idx));
  
    etxd_pad : outpadv generic map (tech => CFG_FABTECH, loc => etxd_pad_loc, level => cmos, voltage => x18v, width => 4)
      port map (etxd, etxd_int, full_pad_cfg(io_idx));
    etx_en_pad : outpad generic map (tech => CFG_FABTECH, loc => etx_en_pad_loc, level => cmos, voltage => x18v)
      port map (etx_en, etx_en_int, full_pad_cfg(io_idx));
    etx_er_pad : outpad generic map (tech => CFG_FABTECH, loc => etx_er_pad_loc, level => cmos, voltage => x18v)
      port map (etx_er, etx_er_int, full_pad_cfg(io_idx));
    emdc_pad : outpad generic map (tech => CFG_FABTECH, loc => emdc_pad_loc, level => cmos, voltage => x18v)
      port map (emdc, emdc_int, full_pad_cfg(io_idx));
  
    --IO Link
    iolink_data_pad : iopadv generic map (tech => CFG_FABTECH, loc => iolink_data_pad_loc, level => cmos, voltage => x18v, width => CFG_IOLINK_BITS, oepol => 1)
      port map (iolink_data, iolink_data_out_int, iolink_data_oen, iolink_data_in_int, full_pad_cfg(io_idx));
    iolink_valid_in_pad : inpad generic map (loc => iolink_valid_in_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH)
      port map (iolink_valid_in, iolink_valid_in_int);
    iolink_valid_out_pad : outpad generic map (loc => iolink_valid_out_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH)
      port map (iolink_valid_out, iolink_valid_out_int, full_pad_cfg(io_idx));
    iolink_clk_in_pad : inpad generic map (loc => iolink_clk_in_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH)
      port map (iolink_clk_in, iolink_clk_in_int);
    iolink_clk_out_pad : outpad generic map (loc => iolink_clk_out_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH)
      port map (iolink_clk_out, iolink_clk_out_int, full_pad_cfg(io_idx));
    iolink_credit_in_pad : inpad generic map (loc => iolink_credit_in_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH)
      port map (iolink_credit_in, iolink_credit_in_int);
    iolink_credit_out_pad : outpad generic map (loc => iolink_credit_out_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH)
      port map (iolink_credit_out, iolink_credit_out_int, full_pad_cfg(io_idx));
  
    -- UART
    uart_rxd_pad  : inpad generic map (loc => uart_rxd_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_rxd, uart_rxd_int);
    uart_txd_pad  : outpad generic map (loc => uart_txd_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_txd, uart_txd_int, full_pad_cfg(io_idx));
    uart_ctsn_pad : inpad generic map (loc => uart_ctsn_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_ctsn, uart_ctsn_int);
    uart_rtsn_pad : outpad generic map (loc => uart_rtsn_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (uart_rtsn, uart_rtsn_int, full_pad_cfg(io_idx));

  end generate io_gen;
  -- tdi/o_cpu
  ncpu_nonzero_gen : if CFG_NCPU_TILE_CHIPLET(chiplet_index) /= 0 generate
    constant cpu_idx : integer := cpu_tile_id(CFG_NCPU_TILE_BASE(chiplet_index)) - CHIPLET_IDX_BASE;
  begin
    process(noc_clk, noc_rstn(0))
    begin  -- process
      if noc_rstn(0) = '1' then
        assert cpuerr_vec(0) = '0' report "Program Completed!" severity failure; --failure -> note
      end if;
    end process;
    --pragma translate_on
    tdi_cpu_pad : inpad generic map (loc => tdi_cpu_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdi_cpu, tdi_int(cpu_idx));
    tdo_cpu_pad : outpad generic map (loc => tdo_cpu_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdo_cpu, tdo_int(cpu_idx), full_pad_cfg(cpu_idx));
  end generate ncpu_nonzero_gen;
  ncpu_zero_gen : if CFG_NCPU_TILE_CHIPLET(chiplet_index) = 0 generate
--    constant cpu_idx : integer := cpu_tile_id(CFG_NCPU_TILE_BASE(chiplet_index)) - CHIPLET_IDX_BASE;
  begin
--    tdi_int(cpu_idx) <= '0';
    tdo_cpu <= '0';
  end generate ncpu_zero_gen;
  nmem_nonzero_gen : if CFG_NMEM_TILE_CHIPLET(chiplet_index) /= 0 generate
    constant mem_idx : integer := mem_tile_id(CFG_NMEM_TILE_BASE(chiplet_index)) - CHIPLET_IDX_BASE;
  begin
    -- tdi/o_mem pad is close to memory tile 0
    tdi_mem_pad : inpad generic map (loc => tdi_mem_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdi_mem, tdi_int(mem_idx));
    tdo_mem_pad : outpad generic map (loc => tdo_mem_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdo_mem, tdo_int(mem_idx), full_pad_cfg(mem_idx));
    fpga_data_pad : iopadvvv generic map (tech => CFG_FABTECH, loc => fpga_data_pad_loc, level => cmos, voltage => x18v, width => CFG_NMEM_TILE_CHIPLET(chiplet_index)*CFG_MEM_LINK_BITS, oepol => 1)
      port map (fpga_data, fpga_data_out, fpga_oen_ext, fpga_data_in, fpga_data_pad_cfg);
    fpga_valid_in_pad : inpadv generic map (loc => fpga_valid_in_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => CFG_NMEM_TILE_CHIPLET(chiplet_index))
      port map (fpga_valid_in, fpga_valid_in_int);
    fpga_valid_out_pad : outpadv generic map (loc => fpga_valid_out_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => CFG_NMEM_TILE_CHIPLET(chiplet_index))
      port map (fpga_valid_out, fpga_valid_out_int, full_pad_cfg(mem_idx));
    fpga_clk_in_pad : inpadv generic map (loc => fpga_clk_in_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => CFG_NMEM_TILE_CHIPLET(chiplet_index))
      port map (fpga_clk_in, fpga_clk_in_int);
    fpga_clk_out_pad : outpadv generic map (loc => fpga_clk_out_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => CFG_NMEM_TILE_CHIPLET(chiplet_index))
      port map (fpga_clk_out, fpga_clk_out_int, full_pad_cfg(mem_idx));
    fpga_credit_in_pad : inpadv generic map (loc => fpga_credit_in_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => CFG_NMEM_TILE_CHIPLET(chiplet_index))
      port map (fpga_credit_in, fpga_credit_in_int);
    fpga_credit_out_pad : outpadv generic map (loc => fpga_credit_out_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH, width => CFG_NMEM_TILE_CHIPLET(chiplet_index))
      port map (fpga_credit_out, fpga_credit_out_int, full_pad_cfg(mem_idx));
      fpga_pad_tiles_gen : for i in 0 to CFG_NMEM_TILE_CHIPLET(chiplet_index) - 1 generate
        constant MEM_BASE_G : integer := CFG_NMEM_TILE_BASE(chiplet_index);
        constant mem_gid : integer := mem_tile_id(MEM_BASE_G + i);
        constant mem_lid : integer := mem_gid - CHIPLET_IDX_BASE;
      begin
        fpga_pad_wires_gen : for j in 0 to CFG_MEM_LINK_BITS - 1 generate
          fpga_oen_ext(i * CFG_MEM_LINK_BITS + j) <= fpga_oen(i);
          fpga_data_pad_cfg((i * CFG_MEM_LINK_BITS + j + 1) * 20 - 1 downto (i * CFG_MEM_LINK_BITS + j) * 20) <= full_pad_cfg(mem_lid);
        end generate fpga_pad_wires_gen;
      end generate fpga_pad_tiles_gen;
  end generate nmem_nonzero_gen;
  nmem_zero_gen : if CFG_NMEM_TILE_CHIPLET(chiplet_index) = 0 generate
--    constant mem_idx : integer := mem_tile_id(CFG_NMEM_TILE_BASE(chiplet_index)) - CHIPLET_IDX_BASE;
  begin
--    tdi_int(mem_idx) <= '0';
    tdo_mem <= '0';
  end generate nmem_zero_gen;
  
  -- tdi/o_acc
  tdi_acc_pad : inpad generic map (loc => tdi_acc_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdi_acc, tdi_int(acc_idx));
  tdo_acc_pad : outpad generic map (loc => tdo_acc_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tdo_acc, tdo_int(acc_idx), full_pad_cfg(acc_idx));

  tms_pad  : inpad generic map (loc => tms_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tms, tms_int);
  tclk_pad : inpad generic map (loc => tclk_pad_loc, level => cmos, voltage => x18v, tech => CFG_FABTECH) port map (tclk, tclk_int);

--  end generate pads_gen;

  -- D2D
  d2dgen_n : if D2D_CHANNELS_N /= 0 generate
  begin
    noc_connections_gen_n : for tile_idx in 0 to XLEN - 1 generate
--      noc1_data_in_mapped_n(tile_idx) <= noc1_data_n_out(tile_idx);
--      noc2_data_in_mapped_n(tile_idx) <= noc2_data_n_out(tile_idx);
--      noc3_data_in_mapped_n(tile_idx) <= noc3_data_n_out(tile_idx);
--      noc5_data_in_mapped_n(tile_idx) <= noc5_data_n_out(tile_idx);
--      noc4_data_in_mapped_n(tile_idx) <= noc4_data_n_out(tile_idx);
--      noc6_data_in_mapped_n(tile_idx) <= noc6_data_n_out(tile_idx);
--      noc1_data_n_in(tile_idx) <= noc1_data_out_mapped_n(tile_idx);
--      noc2_data_n_in(tile_idx) <= noc2_data_out_mapped_n(tile_idx);
--      noc3_data_n_in(tile_idx) <= noc3_data_out_mapped_n(tile_idx);
--      noc5_data_n_in(tile_idx) <= noc5_data_out_mapped_n(tile_idx); 
--      noc4_data_n_in(tile_idx) <= noc4_data_out_mapped_n(tile_idx);
--      noc6_data_n_in(tile_idx) <= noc6_data_out_mapped_n(tile_idx);
      noc1_data_void_out_mapped_n(tile_idx) <= noc1_data_void_out(tile_idx)(0);
      noc2_data_void_out_mapped_n(tile_idx) <= noc2_data_void_out(tile_idx)(0);
      noc3_data_void_out_mapped_n(tile_idx) <= noc3_data_void_out(tile_idx)(0);
      noc4_data_void_out_mapped_n(tile_idx) <= noc4_data_void_out(tile_idx)(0);
      noc5_data_void_out_mapped_n(tile_idx) <= noc5_data_void_out(tile_idx)(0);
      noc6_data_void_out_mapped_n(tile_idx) <= noc6_data_void_out(tile_idx)(0);
      noc1_data_void_in(tile_idx)(0) <= noc1_data_void_in_mapped_n(tile_idx);
      noc2_data_void_in(tile_idx)(0) <= noc2_data_void_in_mapped_n(tile_idx);
      noc3_data_void_in(tile_idx)(0) <= noc3_data_void_in_mapped_n(tile_idx);
      noc4_data_void_in(tile_idx)(0) <= noc4_data_void_in_mapped_n(tile_idx);
      noc5_data_void_in(tile_idx)(0) <= noc5_data_void_in_mapped_n(tile_idx);
      noc6_data_void_in(tile_idx)(0) <= noc6_data_void_in_mapped_n(tile_idx);
      noc1_stop_out_mapped_n(tile_idx) <= noc1_stop_out(tile_idx)(0);
      noc2_stop_out_mapped_n(tile_idx) <= noc2_stop_out(tile_idx)(0);
      noc3_stop_out_mapped_n(tile_idx) <= noc3_stop_out(tile_idx)(0);
      noc4_stop_out_mapped_n(tile_idx) <= noc4_stop_out(tile_idx)(0);
      noc5_stop_out_mapped_n(tile_idx) <= noc5_stop_out(tile_idx)(0);
      noc6_stop_out_mapped_n(tile_idx) <= noc6_stop_out(tile_idx)(0);
      noc1_stop_in(tile_idx)(0) <= noc1_stop_in_mapped_n(tile_idx);
      noc2_stop_in(tile_idx)(0) <= noc2_stop_in_mapped_n(tile_idx);
      noc3_stop_in(tile_idx)(0) <= noc3_stop_in_mapped_n(tile_idx);
      noc4_stop_in(tile_idx)(0) <= noc4_stop_in_mapped_n(tile_idx);
      noc5_stop_in(tile_idx)(0) <= noc5_stop_in_mapped_n(tile_idx);
      noc6_stop_in(tile_idx)(0) <= noc6_stop_in_mapped_n(tile_idx);
    end generate noc_connections_gen_n;
    -- Instantiate D2D N Module here
    d2d_tx_n  : d2d_tx_top
      generic map (
        TXCHANNELS                  => D2D_CHANNELS_N,
        TILES                       => XLEN,
        flow_control                => 0, --0 = AN; 1 = CB
        chwidth                     => COH_NOC_FLIT_SIZE,
        cohwidth                    => COH_NOC_FLIT_SIZE,
        miscwidth                   => MISC_NOC_FLIT_SIZE,
        dmawidth                    => DMA_NOC_FLIT_SIZE
      )
      port map (
        clk                         => noc_clk,
        rst                         => reset_int,
        d2d_clk_in                  => d2d_clk,
        d2d_snd_data_out            => chiplet_data_n_out,
        d2d_valid_out               => chiplet_valid_out_n,
        d2d_credit_in               => chiplet_credit_in_n,
        noc1_data_in                => noc1_data_n_out(XLEN-1 downto 0),
        noc2_data_in                => noc2_data_n_out(XLEN-1 downto 0),
        noc3_data_in                => noc3_data_n_out(XLEN-1 downto 0),
        noc4_data_in                => noc4_data_n_out(XLEN-1 downto 0),
        noc5_data_in                => noc5_data_n_out(XLEN-1 downto 0),
        noc6_data_in                => noc6_data_n_out(XLEN-1 downto 0),
        noc1_data_void_in           => noc1_data_void_out_mapped_n,
        noc2_data_void_in           => noc2_data_void_out_mapped_n,
        noc3_data_void_in           => noc3_data_void_out_mapped_n,
        noc4_data_void_in           => noc4_data_void_out_mapped_n,
        noc5_data_void_in           => noc5_data_void_out_mapped_n,
        noc6_data_void_in           => noc6_data_void_out_mapped_n,
        noc1_stop_out               => noc1_stop_in_mapped_n,
        noc2_stop_out               => noc2_stop_in_mapped_n,
        noc3_stop_out               => noc3_stop_in_mapped_n,
        noc4_stop_out               => noc4_stop_in_mapped_n,
        noc5_stop_out               => noc5_stop_in_mapped_n,
        noc6_stop_out               => noc6_stop_in_mapped_n
      );
      d2d_rx_n  : d2d_rx_top
      generic map (
        d2d_position                => "00",
        local_chip_y                => chip_yx'(std_logic_vector(to_unsigned(ROW, CHIP_YX_WIDTH))),
        local_chip_x                => chip_yx'(std_logic_vector(to_unsigned(COL, CHIP_YX_WIDTH))),
        max_dim                     => std_logic_vector(to_unsigned(YLEN, YX_WIDTH)),
        RXCHANNELS                  => D2D_CHANNELS_N,
        TILES                       => XLEN,
        flow_control                => 0,
        chwidth                     => COH_NOC_FLIT_SIZE,
        cohwidth                    => COH_NOC_FLIT_SIZE,
        miscwidth                   => MISC_NOC_FLIT_SIZE,
        dmawidth                    => DMA_NOC_FLIT_SIZE
      )
      port map (
        clk                         => noc_clk,
        rst                         => reset_int,
        d2d_clk_in                  => d2d_clk,
        d2d_rcv_data_in             => chiplet_data_n_in,
        d2d_valid_in                => chiplet_valid_in_n,
        d2d_credit_out              => chiplet_credit_out_n,
        noc1_data_out               => noc1_data_n_in(XLEN-1 downto 0),
        noc2_data_out               => noc2_data_n_in(XLEN-1 downto 0),
        noc3_data_out               => noc3_data_n_in(XLEN-1 downto 0),
        noc4_data_out               => noc4_data_n_in(XLEN-1 downto 0),
        noc5_data_out               => noc5_data_n_in(XLEN-1 downto 0),
        noc6_data_out               => noc6_data_n_in(XLEN-1 downto 0),
        noc1_data_void_out          => noc1_data_void_in_mapped_n,
        noc2_data_void_out          => noc2_data_void_in_mapped_n,
        noc3_data_void_out          => noc3_data_void_in_mapped_n,
        noc4_data_void_out          => noc4_data_void_in_mapped_n,
        noc5_data_void_out          => noc5_data_void_in_mapped_n,
        noc6_data_void_out          => noc6_data_void_in_mapped_n,
        noc1_stop_in                => noc1_stop_out_mapped_n,
        noc2_stop_in                => noc2_stop_out_mapped_n,
        noc3_stop_in                => noc3_stop_out_mapped_n,
        noc4_stop_in                => noc4_stop_out_mapped_n,
        noc5_stop_in                => noc5_stop_out_mapped_n,
        noc6_stop_in                => noc6_stop_out_mapped_n
      );
  end generate d2dgen_n;
  no_d2dgen_n : if D2D_CHANNELS_N = 0 generate
  begin
    chiplet_data_n_out <= (others => (others => '0'));
    chiplet_valid_out_n <= (others => '0');
    chiplet_credit_out_n <= (others => '0');
  end generate no_d2dgen_n;


  d2dgen_s : if D2D_CHANNELS_S /= 0 generate
  begin
    noc_connections_gen_s : for tile_idx in 0 to XLEN - 1 generate
      constant internal_tile_idx : natural := (YLEN-1)*XLEN + tile_idx;
    begin
--      noc1_data_in_mapped_s(tile_idx) <= noc1_data_s_out(internal_tile_idx);
--      noc2_data_in_mapped_s(tile_idx) <= noc2_data_s_out(internal_tile_idx);
--      noc3_data_in_mapped_s(tile_idx) <= noc3_data_s_out(internal_tile_idx);
--      noc5_data_in_mapped_s(tile_idx) <= noc5_data_s_out(internal_tile_idx);
--      noc4_data_in_mapped_s(tile_idx) <= noc4_data_s_out(internal_tile_idx);
--      noc6_data_in_mapped_s(tile_idx) <= noc6_data_s_out(internal_tile_idx);
--      noc1_data_s_in(internal_tile_idx) <= noc1_data_out_mapped_s(tile_idx);
--      noc2_data_s_in(internal_tile_idx) <= noc2_data_out_mapped_s(tile_idx);
--      noc3_data_s_in(internal_tile_idx) <= noc3_data_out_mapped_s(tile_idx);       
--      noc5_data_s_in(internal_tile_idx) <= noc5_data_out_mapped_s(tile_idx);
--      noc4_data_s_in(internal_tile_idx) <= noc4_data_out_mapped_s(tile_idx);
--      noc6_data_s_in(internal_tile_idx) <= noc6_data_out_mapped_s(tile_idx);
      noc1_data_void_out_mapped_s(tile_idx) <= noc1_data_void_out(internal_tile_idx)(1);
      noc2_data_void_out_mapped_s(tile_idx) <= noc2_data_void_out(internal_tile_idx)(1);
      noc3_data_void_out_mapped_s(tile_idx) <= noc3_data_void_out(internal_tile_idx)(1);
      noc4_data_void_out_mapped_s(tile_idx) <= noc4_data_void_out(internal_tile_idx)(1);
      noc5_data_void_out_mapped_s(tile_idx) <= noc5_data_void_out(internal_tile_idx)(1);
      noc6_data_void_out_mapped_s(tile_idx) <= noc6_data_void_out(internal_tile_idx)(1);
      noc1_data_void_in(internal_tile_idx)(1) <= noc1_data_void_in_mapped_s(tile_idx);
      noc2_data_void_in(internal_tile_idx)(1) <= noc2_data_void_in_mapped_s(tile_idx);
      noc3_data_void_in(internal_tile_idx)(1) <= noc3_data_void_in_mapped_s(tile_idx);
      noc4_data_void_in(internal_tile_idx)(1) <= noc4_data_void_in_mapped_s(tile_idx);
      noc5_data_void_in(internal_tile_idx)(1) <= noc5_data_void_in_mapped_s(tile_idx);
      noc6_data_void_in(internal_tile_idx)(1) <= noc6_data_void_in_mapped_s(tile_idx);
      noc1_stop_out_mapped_s(tile_idx) <= noc1_stop_out(internal_tile_idx)(1);
      noc2_stop_out_mapped_s(tile_idx) <= noc2_stop_out(internal_tile_idx)(1);
      noc3_stop_out_mapped_s(tile_idx) <= noc3_stop_out(internal_tile_idx)(1);
      noc4_stop_out_mapped_s(tile_idx) <= noc4_stop_out(internal_tile_idx)(1);
      noc5_stop_out_mapped_s(tile_idx) <= noc5_stop_out(internal_tile_idx)(1);
      noc6_stop_out_mapped_s(tile_idx) <= noc6_stop_out(internal_tile_idx)(1);
      noc1_stop_in(internal_tile_idx)(1) <= noc1_stop_in_mapped_s(tile_idx);
      noc2_stop_in(internal_tile_idx)(1) <= noc2_stop_in_mapped_s(tile_idx);
      noc3_stop_in(internal_tile_idx)(1) <= noc3_stop_in_mapped_s(tile_idx);
      noc4_stop_in(internal_tile_idx)(1) <= noc4_stop_in_mapped_s(tile_idx);
      noc5_stop_in(internal_tile_idx)(1) <= noc5_stop_in_mapped_s(tile_idx);
      noc6_stop_in(internal_tile_idx)(1) <= noc6_stop_in_mapped_s(tile_idx);
    end generate noc_connections_gen_s;
    -- instantiate D2D S module here
    d2d_tx_s  : d2d_tx_top
      generic map (
        TXCHANNELS                  => D2D_CHANNELS_S,
        TILES                       => XLEN,
        flow_control                => 0, --0 = AN; 1 = CB
        chwidth                     => COH_NOC_FLIT_SIZE,
        cohwidth                    => COH_NOC_FLIT_SIZE,
        miscwidth                   => MISC_NOC_FLIT_SIZE,
        dmawidth                    => DMA_NOC_FLIT_SIZE
      )
      port map (
        clk                         => noc_clk,
        rst                         => reset_int,
        d2d_clk_in                  => d2d_clk,
        d2d_snd_data_out            => chiplet_data_s_out,
        d2d_valid_out               => chiplet_valid_out_s,
        d2d_credit_in               => chiplet_credit_in_s,
        noc1_data_in                => noc1_data_s_out(YLEN*XLEN-1 downto (YLEN-1)*XLEN),
        noc2_data_in                => noc2_data_s_out(YLEN*XLEN-1 downto (YLEN-1)*XLEN),
        noc3_data_in                => noc3_data_s_out(YLEN*XLEN-1 downto (YLEN-1)*XLEN),
        noc4_data_in                => noc4_data_s_out(YLEN*XLEN-1 downto (YLEN-1)*XLEN),
        noc5_data_in                => noc5_data_s_out(YLEN*XLEN-1 downto (YLEN-1)*XLEN),
        noc6_data_in                => noc6_data_s_out(YLEN*XLEN-1 downto (YLEN-1)*XLEN),
        noc1_data_void_in           => noc1_data_void_out_mapped_s,
        noc2_data_void_in           => noc2_data_void_out_mapped_s,
        noc3_data_void_in           => noc3_data_void_out_mapped_s,
        noc4_data_void_in           => noc4_data_void_out_mapped_s,
        noc5_data_void_in           => noc5_data_void_out_mapped_s,
        noc6_data_void_in           => noc6_data_void_out_mapped_s,
        noc1_stop_out               => noc1_stop_in_mapped_s,
        noc2_stop_out               => noc2_stop_in_mapped_s,
        noc3_stop_out               => noc3_stop_in_mapped_s,
        noc4_stop_out               => noc4_stop_in_mapped_s,
        noc5_stop_out               => noc5_stop_in_mapped_s,
        noc6_stop_out               => noc6_stop_in_mapped_s
      );
      d2d_rx_s  : d2d_rx_top
      generic map (
        d2d_position                => "01",
        local_chip_y                => chip_yx'(std_logic_vector(to_unsigned(ROW, CHIP_YX_WIDTH))),
        local_chip_x                => chip_yx'(std_logic_vector(to_unsigned(COL, CHIP_YX_WIDTH))),
        max_dim                     => std_logic_vector(to_unsigned(YLEN, YX_WIDTH)),
        RXCHANNELS                  => D2D_CHANNELS_S,
        TILES                       => XLEN,
        flow_control                => 0,
        chwidth                     => COH_NOC_FLIT_SIZE,
        cohwidth                    => COH_NOC_FLIT_SIZE,
        miscwidth                   => MISC_NOC_FLIT_SIZE,
        dmawidth                    => DMA_NOC_FLIT_SIZE
      )
      port map (
        clk                         => noc_clk,
        rst                         => reset_int,
        d2d_clk_in                  => d2d_clk,
        d2d_rcv_data_in             => chiplet_data_s_in,
        d2d_valid_in                => chiplet_valid_in_s,
        d2d_credit_out              => chiplet_credit_out_s,
        noc1_data_out               => noc1_data_s_in(YLEN*XLEN-1 downto (YLEN-1)*XLEN),
        noc2_data_out               => noc2_data_s_in(YLEN*XLEN-1 downto (YLEN-1)*XLEN),
        noc3_data_out               => noc3_data_s_in(YLEN*XLEN-1 downto (YLEN-1)*XLEN),
        noc4_data_out               => noc4_data_s_in(YLEN*XLEN-1 downto (YLEN-1)*XLEN),
        noc5_data_out               => noc5_data_s_in(YLEN*XLEN-1 downto (YLEN-1)*XLEN),
        noc6_data_out               => noc6_data_s_in(YLEN*XLEN-1 downto (YLEN-1)*XLEN),
        noc1_data_void_out          => noc1_data_void_in_mapped_s,
        noc2_data_void_out          => noc2_data_void_in_mapped_s,
        noc3_data_void_out          => noc3_data_void_in_mapped_s,
        noc4_data_void_out          => noc4_data_void_in_mapped_s,
        noc5_data_void_out          => noc5_data_void_in_mapped_s,
        noc6_data_void_out          => noc6_data_void_in_mapped_s,
        noc1_stop_in                => noc1_stop_out_mapped_s,
        noc2_stop_in                => noc2_stop_out_mapped_s,
        noc3_stop_in                => noc3_stop_out_mapped_s,
        noc4_stop_in                => noc4_stop_out_mapped_s,
        noc5_stop_in                => noc5_stop_out_mapped_s,
        noc6_stop_in                => noc6_stop_out_mapped_s
      );
  end generate d2dgen_s;
  no_d2dgen_s : if D2D_CHANNELS_S = 0 generate
  begin
    chiplet_data_s_out <= (others => (others => '0'));
    chiplet_valid_out_s <= (others => '0');
    chiplet_credit_out_s <= (others => '0');
  end generate no_d2dgen_s;

  -- E and W modules.
  d2dgen_w : if D2D_CHANNELS_W /= 0 generate
  begin
    noc_connections_gen_w : for tile_idx in 0 to YLEN - 1 generate
      constant internal_tile_idx : natural := XLEN*tile_idx;
    begin
      noc1_data_w_in(internal_tile_idx) <= noc1_data_in_mapped_w(tile_idx);
      noc2_data_w_in(internal_tile_idx) <= noc2_data_in_mapped_w(tile_idx);
      noc3_data_w_in(internal_tile_idx) <= noc3_data_in_mapped_w(tile_idx);
      noc4_data_w_in(internal_tile_idx) <= noc4_data_in_mapped_w(tile_idx);
      noc5_data_w_in(internal_tile_idx) <= noc5_data_in_mapped_w(tile_idx);
      noc6_data_w_in(internal_tile_idx) <= noc6_data_in_mapped_w(tile_idx);
      noc1_data_out_mapped_w(tile_idx) <= noc1_data_w_out(internal_tile_idx);
      noc2_data_out_mapped_w(tile_idx) <= noc2_data_w_out(internal_tile_idx);
      noc3_data_out_mapped_w(tile_idx) <= noc3_data_w_out(internal_tile_idx);
      noc4_data_out_mapped_w(tile_idx) <= noc4_data_w_out(internal_tile_idx);
      noc5_data_out_mapped_w(tile_idx) <= noc5_data_w_out(internal_tile_idx);
      noc6_data_out_mapped_w(tile_idx) <= noc6_data_w_out(internal_tile_idx);
      noc1_data_void_out_mapped_w(tile_idx) <= noc1_data_void_out(internal_tile_idx)(2);
      noc2_data_void_out_mapped_w(tile_idx) <= noc2_data_void_out(internal_tile_idx)(2);
      noc3_data_void_out_mapped_w(tile_idx) <= noc3_data_void_out(internal_tile_idx)(2);
      noc4_data_void_out_mapped_w(tile_idx) <= noc4_data_void_out(internal_tile_idx)(2);
      noc5_data_void_out_mapped_w(tile_idx) <= noc5_data_void_out(internal_tile_idx)(2);
      noc6_data_void_out_mapped_w(tile_idx) <= noc6_data_void_out(internal_tile_idx)(2);
      noc1_data_void_in(internal_tile_idx)(2) <= noc1_data_void_in_mapped_w(tile_idx);
      noc2_data_void_in(internal_tile_idx)(2) <= noc2_data_void_in_mapped_w(tile_idx);
      noc3_data_void_in(internal_tile_idx)(2) <= noc3_data_void_in_mapped_w(tile_idx);
      noc4_data_void_in(internal_tile_idx)(2) <= noc4_data_void_in_mapped_w(tile_idx);
      noc5_data_void_in(internal_tile_idx)(2) <= noc5_data_void_in_mapped_w(tile_idx);
      noc6_data_void_in(internal_tile_idx)(2) <= noc6_data_void_in_mapped_w(tile_idx);
      noc1_stop_out_mapped_w(tile_idx) <= noc1_stop_out(internal_tile_idx)(2);
      noc2_stop_out_mapped_w(tile_idx) <= noc2_stop_out(internal_tile_idx)(2);
      noc3_stop_out_mapped_w(tile_idx) <= noc3_stop_out(internal_tile_idx)(2);
      noc4_stop_out_mapped_w(tile_idx) <= noc4_stop_out(internal_tile_idx)(2);
      noc5_stop_out_mapped_w(tile_idx) <= noc5_stop_out(internal_tile_idx)(2);
      noc6_stop_out_mapped_w(tile_idx) <= noc6_stop_out(internal_tile_idx)(2);
      noc1_stop_in(internal_tile_idx)(2) <= noc1_stop_in_mapped_w(tile_idx);
      noc2_stop_in(internal_tile_idx)(2) <= noc2_stop_in_mapped_w(tile_idx);
      noc3_stop_in(internal_tile_idx)(2) <= noc3_stop_in_mapped_w(tile_idx);
      noc4_stop_in(internal_tile_idx)(2) <= noc4_stop_in_mapped_w(tile_idx);
      noc5_stop_in(internal_tile_idx)(2) <= noc5_stop_in_mapped_w(tile_idx);
      noc6_stop_in(internal_tile_idx)(2) <= noc6_stop_in_mapped_w(tile_idx);
    end generate noc_connections_gen_w;
    -- instantiate D2D W module here
    d2d_tx_w  : d2d_tx_top
      generic map (
        TXCHANNELS                  => D2D_CHANNELS_W,
        TILES                       => YLEN,
        flow_control                => 0, --0 = AN; 1 = CB
        chwidth                     => COH_NOC_FLIT_SIZE,
        cohwidth                    => COH_NOC_FLIT_SIZE,
        miscwidth                   => MISC_NOC_FLIT_SIZE,
        dmawidth                    => DMA_NOC_FLIT_SIZE
      )
      port map (
        clk                         => noc_clk,
        rst                         => reset_int,
        d2d_clk_in                  => d2d_clk,
        d2d_snd_data_out            => chiplet_data_w_out,
        d2d_valid_out               => chiplet_valid_out_w,
        d2d_credit_in               => chiplet_credit_in_w,
        noc1_data_in                => noc1_data_out_mapped_w,
        noc2_data_in                => noc2_data_out_mapped_w,
        noc3_data_in                => noc3_data_out_mapped_w,
        noc4_data_in                => noc4_data_out_mapped_w,
        noc5_data_in                => noc5_data_out_mapped_w,
        noc6_data_in                => noc6_data_out_mapped_w,
        noc1_data_void_in           => noc1_data_void_out_mapped_w,
        noc2_data_void_in           => noc2_data_void_out_mapped_w,
        noc3_data_void_in           => noc3_data_void_out_mapped_w,
        noc4_data_void_in           => noc4_data_void_out_mapped_w,
        noc5_data_void_in           => noc5_data_void_out_mapped_w,
        noc6_data_void_in           => noc6_data_void_out_mapped_w,
        noc1_stop_out               => noc1_stop_in_mapped_w,
        noc2_stop_out               => noc2_stop_in_mapped_w,
        noc3_stop_out               => noc3_stop_in_mapped_w,
        noc4_stop_out               => noc4_stop_in_mapped_w,
        noc5_stop_out               => noc5_stop_in_mapped_w,
        noc6_stop_out               => noc6_stop_in_mapped_w
      );
      d2d_rx_w  : d2d_rx_top
      generic map (
        d2d_position                => "10",
        local_chip_y                => chip_yx'(std_logic_vector(to_unsigned(ROW, CHIP_YX_WIDTH))),
        local_chip_x                => chip_yx'(std_logic_vector(to_unsigned(COL, CHIP_YX_WIDTH))),
        max_dim                     => std_logic_vector(to_unsigned(XLEN, YX_WIDTH)),
        RXCHANNELS                  => D2D_CHANNELS_W,
        TILES                       => YLEN,
        flow_control                => 0,
        chwidth                     => COH_NOC_FLIT_SIZE,
        cohwidth                    => COH_NOC_FLIT_SIZE,
        miscwidth                   => MISC_NOC_FLIT_SIZE,
        dmawidth                    => DMA_NOC_FLIT_SIZE
      )
      port map (
        clk                         => noc_clk,
        rst                         => reset_int,
        d2d_clk_in                  => d2d_clk,
        d2d_rcv_data_in             => chiplet_data_w_in,
        d2d_valid_in                => chiplet_valid_in_w,
        d2d_credit_out              => chiplet_credit_out_w,
        noc1_data_out               => noc1_data_in_mapped_w,
        noc2_data_out               => noc2_data_in_mapped_w,
        noc3_data_out               => noc3_data_in_mapped_w,
        noc4_data_out               => noc4_data_in_mapped_w,
        noc5_data_out               => noc5_data_in_mapped_w,
        noc6_data_out               => noc6_data_in_mapped_w,
        noc1_data_void_out          => noc1_data_void_in_mapped_w,
        noc2_data_void_out          => noc2_data_void_in_mapped_w,
        noc3_data_void_out          => noc3_data_void_in_mapped_w,
        noc4_data_void_out          => noc4_data_void_in_mapped_w,
        noc5_data_void_out          => noc5_data_void_in_mapped_w,
        noc6_data_void_out          => noc6_data_void_in_mapped_w,
        noc1_stop_in                => noc1_stop_out_mapped_w,
        noc2_stop_in                => noc2_stop_out_mapped_w,
        noc3_stop_in                => noc3_stop_out_mapped_w,
        noc4_stop_in                => noc4_stop_out_mapped_w,
        noc5_stop_in                => noc5_stop_out_mapped_w,
        noc6_stop_in                => noc6_stop_out_mapped_w
      );
  end generate d2dgen_w;
  no_d2dgen_w : if D2D_CHANNELS_W = 0 generate
  begin
    chiplet_data_w_out <= (others => (others => '0'));
    chiplet_valid_out_w <= (others => '0');
    chiplet_credit_out_w <= (others => '0');
  end generate no_d2dgen_w;


  d2dgen_e : if D2D_CHANNELS_E /= 0 generate
  begin
    noc_connections_gen_e : for tile_idx in 0 to YLEN - 1 generate
      constant internal_tile_idx : natural := XLEN*tile_idx + XLEN - 1;
    begin
      noc1_data_e_in(internal_tile_idx) <= noc1_data_in_mapped_e(tile_idx);
      noc2_data_e_in(internal_tile_idx) <= noc2_data_in_mapped_e(tile_idx);
      noc3_data_e_in(internal_tile_idx) <= noc3_data_in_mapped_e(tile_idx);
      noc4_data_e_in(internal_tile_idx) <= noc4_data_in_mapped_e(tile_idx);
      noc5_data_e_in(internal_tile_idx) <= noc5_data_in_mapped_e(tile_idx);
      noc6_data_e_in(internal_tile_idx) <= noc6_data_in_mapped_e(tile_idx);
      noc1_data_out_mapped_e(tile_idx) <= noc1_data_e_out(internal_tile_idx);
      noc2_data_out_mapped_e(tile_idx) <= noc2_data_e_out(internal_tile_idx);
      noc3_data_out_mapped_e(tile_idx) <= noc3_data_e_out(internal_tile_idx);
      noc4_data_out_mapped_e(tile_idx) <= noc4_data_e_out(internal_tile_idx);
      noc5_data_out_mapped_e(tile_idx) <= noc5_data_e_out(internal_tile_idx);
      noc6_data_out_mapped_e(tile_idx) <= noc6_data_e_out(internal_tile_idx);
      noc1_data_void_out_mapped_e(tile_idx) <= noc1_data_void_out(internal_tile_idx)(3);
      noc2_data_void_out_mapped_e(tile_idx) <= noc2_data_void_out(internal_tile_idx)(3);
      noc3_data_void_out_mapped_e(tile_idx) <= noc3_data_void_out(internal_tile_idx)(3);
      noc4_data_void_out_mapped_e(tile_idx) <= noc4_data_void_out(internal_tile_idx)(3);
      noc5_data_void_out_mapped_e(tile_idx) <= noc5_data_void_out(internal_tile_idx)(3);
      noc6_data_void_out_mapped_e(tile_idx) <= noc6_data_void_out(internal_tile_idx)(3);
      noc1_data_void_in(internal_tile_idx)(3) <= noc1_data_void_in_mapped_e(tile_idx);
      noc2_data_void_in(internal_tile_idx)(3) <= noc2_data_void_in_mapped_e(tile_idx);
      noc3_data_void_in(internal_tile_idx)(3) <= noc3_data_void_in_mapped_e(tile_idx);
      noc4_data_void_in(internal_tile_idx)(3) <= noc4_data_void_in_mapped_e(tile_idx);
      noc5_data_void_in(internal_tile_idx)(3) <= noc5_data_void_in_mapped_e(tile_idx);
      noc6_data_void_in(internal_tile_idx)(3) <= noc6_data_void_in_mapped_e(tile_idx);
      noc1_stop_out_mapped_e(tile_idx) <= noc1_stop_out(internal_tile_idx)(3);
      noc2_stop_out_mapped_e(tile_idx) <= noc2_stop_out(internal_tile_idx)(3);
      noc3_stop_out_mapped_e(tile_idx) <= noc3_stop_out(internal_tile_idx)(3);
      noc4_stop_out_mapped_e(tile_idx) <= noc4_stop_out(internal_tile_idx)(3);
      noc5_stop_out_mapped_e(tile_idx) <= noc5_stop_out(internal_tile_idx)(3);
      noc6_stop_out_mapped_e(tile_idx) <= noc6_stop_out(internal_tile_idx)(3);
      noc1_stop_in(internal_tile_idx)(3) <= noc1_stop_in_mapped_e(tile_idx);
      noc2_stop_in(internal_tile_idx)(3) <= noc2_stop_in_mapped_e(tile_idx);
      noc3_stop_in(internal_tile_idx)(3) <= noc3_stop_in_mapped_e(tile_idx);
      noc4_stop_in(internal_tile_idx)(3) <= noc4_stop_in_mapped_e(tile_idx);
      noc5_stop_in(internal_tile_idx)(3) <= noc5_stop_in_mapped_e(tile_idx);
      noc6_stop_in(internal_tile_idx)(3) <= noc6_stop_in_mapped_e(tile_idx);
    end generate noc_connections_gen_e;
    -- instantiate D2D S module here
    d2d_tx_e  : d2d_tx_top
      generic map (
        TXCHANNELS                  => D2D_CHANNELS_E,
        TILES                       => YLEN,
        flow_control                => 0, --0 = AN; 1 = CB
        chwidth                     => COH_NOC_FLIT_SIZE,
        cohwidth                    => COH_NOC_FLIT_SIZE,
        miscwidth                   => MISC_NOC_FLIT_SIZE,
        dmawidth                    => DMA_NOC_FLIT_SIZE
      )
      port map (
        clk                         => noc_clk,
        rst                         => reset_int,
        d2d_clk_in                  => d2d_clk,
        d2d_snd_data_out            => chiplet_data_e_out,
        d2d_valid_out               => chiplet_valid_out_e,
        d2d_credit_in               => chiplet_credit_in_e,
        noc1_data_in                => noc1_data_out_mapped_e,
        noc2_data_in                => noc2_data_out_mapped_e,
        noc3_data_in                => noc3_data_out_mapped_e,
        noc4_data_in                => noc4_data_out_mapped_e,
        noc5_data_in                => noc5_data_out_mapped_e,
        noc6_data_in                => noc6_data_out_mapped_e,
        noc1_data_void_in           => noc1_data_void_out_mapped_e,
        noc2_data_void_in           => noc2_data_void_out_mapped_e,
        noc3_data_void_in           => noc3_data_void_out_mapped_e,
        noc4_data_void_in           => noc4_data_void_out_mapped_e,
        noc5_data_void_in           => noc5_data_void_out_mapped_e,
        noc6_data_void_in           => noc6_data_void_out_mapped_e,
        noc1_stop_out               => noc1_stop_in_mapped_e,
        noc2_stop_out               => noc2_stop_in_mapped_e,
        noc3_stop_out               => noc3_stop_in_mapped_e,
        noc4_stop_out               => noc4_stop_in_mapped_e,
        noc5_stop_out               => noc5_stop_in_mapped_e,
        noc6_stop_out               => noc6_stop_in_mapped_e
      );
      d2d_rx_e  : d2d_rx_top
      generic map (
        d2d_position                => "11",
        local_chip_y                => chip_yx'(std_logic_vector(to_unsigned(ROW, CHIP_YX_WIDTH))),
        local_chip_x                => chip_yx'(std_logic_vector(to_unsigned(COL, CHIP_YX_WIDTH))),
        max_dim                     => std_logic_vector(to_unsigned(XLEN, YX_WIDTH)),
        RXCHANNELS                  => D2D_CHANNELS_E,
        TILES                       => YLEN,
        flow_control                => 0,
        chwidth                     => COH_NOC_FLIT_SIZE,
        cohwidth                    => COH_NOC_FLIT_SIZE,
        miscwidth                   => MISC_NOC_FLIT_SIZE,
        dmawidth                    => DMA_NOC_FLIT_SIZE
      )
      port map (
        clk                         => noc_clk,
        rst                         => reset_int,
        d2d_clk_in                  => d2d_clk,
        d2d_rcv_data_in             => chiplet_data_e_in,
        d2d_valid_in                => chiplet_valid_in_e,
        d2d_credit_out              => chiplet_credit_out_e,
        noc1_data_out               => noc1_data_in_mapped_e,
        noc2_data_out               => noc2_data_in_mapped_e,
        noc3_data_out               => noc3_data_in_mapped_e,
        noc4_data_out               => noc4_data_in_mapped_e,
        noc5_data_out               => noc5_data_in_mapped_e,
        noc6_data_out               => noc6_data_in_mapped_e,
        noc1_data_void_out          => noc1_data_void_in_mapped_e,
        noc2_data_void_out          => noc2_data_void_in_mapped_e,
        noc3_data_void_out          => noc3_data_void_in_mapped_e,
        noc4_data_void_out          => noc4_data_void_in_mapped_e,
        noc5_data_void_out          => noc5_data_void_in_mapped_e,
        noc6_data_void_out          => noc6_data_void_in_mapped_e,
        noc1_stop_in                => noc1_stop_out_mapped_e,
        noc2_stop_in                => noc2_stop_out_mapped_e,
        noc3_stop_in                => noc3_stop_out_mapped_e,
        noc4_stop_in                => noc4_stop_out_mapped_e,
        noc5_stop_in                => noc5_stop_out_mapped_e,
        noc6_stop_in                => noc6_stop_out_mapped_e
      );
  end generate d2dgen_e;
  no_d2dgen_e : if D2D_CHANNELS_E = 0 generate
  begin
    chiplet_data_e_out <= (others => (others => '0'));
    chiplet_valid_out_e <= (others => '0');
    chiplet_credit_out_e <= (others => '0');
  end generate no_d2dgen_e;

  -----------------------------------------------------------------------------
  -- NOC CONNECTIONS
  -----------------------------------------------------------------------------
  meshgen_y : for i in 0 to YLEN-1 generate
    meshgen_x : for j in 0 to XLEN-1 generate

      y_0 : if (i = 0) generate
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
        noc1_data_n_in(i*XLEN + j)       <= noc1_data_s_out((i-1)*XLEN + j);
        noc1_data_void_in(i*XLEN + j)(0) <= noc1_data_void_out((i-1)*XLEN + j)(1);
        noc1_stop_in(i*XLEN + j)(0)      <= noc1_stop_out((i-1)*XLEN + j)(1);
        noc2_data_n_in(i*XLEN + j)       <= noc2_data_s_out((i-1)*XLEN + j);
        noc2_data_void_in(i*XLEN + j)(0) <= noc2_data_void_out((i-1)*XLEN + j)(1);
        noc2_stop_in(i*XLEN + j)(0)      <= noc2_stop_out((i-1)*XLEN + j)(1);
        noc3_data_n_in(i*XLEN + j)       <= noc3_data_s_out((i-1)*XLEN + j);
        noc3_data_void_in(i*XLEN + j)(0) <= noc3_data_void_out((i-1)*XLEN + j)(1);
        noc3_stop_in(i*XLEN + j)(0)      <= noc3_stop_out((i-1)*XLEN + j)(1);
        noc4_data_n_in(i*XLEN + j)       <= noc4_data_s_out((i-1)*XLEN + j);
        noc4_data_void_in(i*XLEN + j)(0) <= noc4_data_void_out((i-1)*XLEN + j)(1);
        noc4_stop_in(i*XLEN + j)(0)      <= noc4_stop_out((i-1)*XLEN + j)(1);
        noc5_data_n_in(i*XLEN + j)       <= noc5_data_s_out((i-1)*XLEN + j);
        noc5_data_void_in(i*XLEN + j)(0) <= noc5_data_void_out((i-1)*XLEN + j)(1);
        noc5_stop_in(i*XLEN + j)(0)      <= noc5_stop_out((i-1)*XLEN + j)(1);
        noc6_data_n_in(i*XLEN + j)       <= noc6_data_s_out((i-1)*XLEN + j);
        noc6_data_void_in(i*XLEN + j)(0) <= noc6_data_void_out((i-1)*XLEN + j)(1);
        noc6_stop_in(i*XLEN + j)(0)      <= noc6_stop_out((i-1)*XLEN + j)(1);
      end generate y_non_0;

      y_YLEN : if (i = YLEN-1) generate
        d2d_s: if D2D_CHANNELS_S = 0 generate
        -- South port is unconnected
          noc1_data_s_in(i*XLEN + j) <= (others => '0');
          noc1_data_void_in(i*XLEN + j)(1) <= '1';
          noc1_stop_in(i*XLEN + j)(1) <= '0';
          noc2_data_s_in(i*XLEN + j) <= (others => '0');
          noc2_data_void_in(i*XLEN + j)(1) <= '1';
          noc2_stop_in(i*XLEN + j)(1) <= '0';
          noc3_data_s_in(i*XLEN + j) <= (others => '0');
          noc3_data_void_in(i*XLEN + j)(1) <= '1';
          noc3_stop_in(i*XLEN + j)(1) <= '0';
          noc4_data_s_in(i*XLEN + j) <= (others => '0');
          noc4_data_void_in(i*XLEN + j)(1) <= '1';
          noc4_stop_in(i*XLEN + j)(1) <= '0';
          noc5_data_s_in(i*XLEN + j) <= (others => '0');
          noc5_data_void_in(i*XLEN + j)(1) <= '1';
          noc5_stop_in(i*XLEN + j)(1) <= '0';
          noc6_data_s_in(i*XLEN + j) <= (others => '0');
          noc6_data_void_in(i*XLEN + j)(1) <= '1';
          noc6_stop_in(i*XLEN + j)(1) <= '0';
        end generate d2d_s;
      end generate y_YLEN;

      y_non_YLEN : if (i /= YLEN-1) generate
        -- south port is connected
        noc1_data_s_in(i*XLEN + j)       <= noc1_data_n_out((i+1)*XLEN + j);
        noc1_data_void_in(i*XLEN + j)(1) <= noc1_data_void_out((i+1)*XLEN + j)(0);
        noc1_stop_in(i*XLEN + j)(1)      <= noc1_stop_out((i+1)*XLEN + j)(0);
        noc2_data_s_in(i*XLEN + j)       <= noc2_data_n_out((i+1)*XLEN + j);
        noc2_data_void_in(i*XLEN + j)(1) <= noc2_data_void_out((i+1)*XLEN + j)(0);
        noc2_stop_in(i*XLEN + j)(1)      <= noc2_stop_out((i+1)*XLEN + j)(0);
        noc3_data_s_in(i*XLEN + j)       <= noc3_data_n_out((i+1)*XLEN + j);
        noc3_data_void_in(i*XLEN + j)(1) <= noc3_data_void_out((i+1)*XLEN + j)(0);
        noc3_stop_in(i*XLEN + j)(1)      <= noc3_stop_out((i+1)*XLEN + j)(0);
        noc4_data_s_in(i*XLEN + j)       <= noc4_data_n_out((i+1)*XLEN + j);
        noc4_data_void_in(i*XLEN + j)(1) <= noc4_data_void_out((i+1)*XLEN + j)(0);
        noc4_stop_in(i*XLEN + j)(1)      <= noc4_stop_out((i+1)*XLEN + j)(0);
        noc5_data_s_in(i*XLEN + j)       <= noc5_data_n_out((i+1)*XLEN + j);
        noc5_data_void_in(i*XLEN + j)(1) <= noc5_data_void_out((i+1)*XLEN + j)(0);
        noc5_stop_in(i*XLEN + j)(1)      <= noc5_stop_out((i+1)*XLEN + j)(0);
        noc6_data_s_in(i*XLEN + j)       <= noc6_data_n_out((i+1)*XLEN + j);
        noc6_data_void_in(i*XLEN + j)(1) <= noc6_data_void_out((i+1)*XLEN + j)(0);
        noc6_stop_in(i*XLEN + j)(1)      <= noc6_stop_out((i+1)*XLEN + j)(0);
      end generate y_non_YLEN;

      x_0 : if (j = 0) generate
        -- West port is unconnected
        d2d_w: if D2D_CHANNELS_W = 0 generate
          noc1_data_w_in(i*XLEN + j) <= (others => '0');
          noc1_data_void_in(i*XLEN + j)(2) <= '1';
          noc1_stop_in(i*XLEN + j)(2) <= '0';
          noc2_data_w_in(i*XLEN + j) <= (others => '0');
          noc2_data_void_in(i*XLEN + j)(2) <= '1';
          noc2_stop_in(i*XLEN + j)(2) <= '0';
          noc3_data_w_in(i*XLEN + j) <= (others => '0');
          noc3_data_void_in(i*XLEN + j)(2) <= '1';
          noc3_stop_in(i*XLEN + j)(2) <= '0';
          noc4_data_w_in(i*XLEN + j) <= (others => '0');
          noc4_data_void_in(i*XLEN + j)(2) <= '1';
          noc4_stop_in(i*XLEN + j)(2) <= '0';
          noc5_data_w_in(i*XLEN + j) <= (others => '0');
          noc5_data_void_in(i*XLEN + j)(2) <= '1';
          noc5_stop_in(i*XLEN + j)(2) <= '0';
          noc6_data_w_in(i*XLEN + j) <= (others => '0');
          noc6_data_void_in(i*XLEN + j)(2) <= '1';
          noc6_stop_in(i*XLEN + j)(2) <= '0';
        end generate d2d_w;
      end generate x_0;

      x_non_0 : if (j /= 0) generate
        -- West port is connected
        noc1_data_w_in(i*XLEN + j)       <= noc1_data_e_out(i*XLEN + j - 1);
        noc1_data_void_in(i*XLEN + j)(2) <= noc1_data_void_out(i*XLEN + j - 1)(3);
        noc1_stop_in(i*XLEN + j)(2)      <= noc1_stop_out(i*XLEN + j - 1)(3);
        noc2_data_w_in(i*XLEN + j)       <= noc2_data_e_out(i*XLEN + j - 1);
        noc2_data_void_in(i*XLEN + j)(2) <= noc2_data_void_out(i*XLEN + j - 1)(3);
        noc2_stop_in(i*XLEN + j)(2)      <= noc2_stop_out(i*XLEN + j - 1)(3);
        noc3_data_w_in(i*XLEN + j)       <= noc3_data_e_out(i*XLEN + j - 1);
        noc3_data_void_in(i*XLEN + j)(2) <= noc3_data_void_out(i*XLEN + j - 1)(3);
        noc3_stop_in(i*XLEN + j)(2)      <= noc3_stop_out(i*XLEN + j - 1)(3);
        noc4_data_w_in(i*XLEN + j)       <= noc4_data_e_out(i*XLEN + j - 1);
        noc4_data_void_in(i*XLEN + j)(2) <= noc4_data_void_out(i*XLEN + j - 1)(3);
        noc4_stop_in(i*XLEN + j)(2)      <= noc4_stop_out(i*XLEN + j - 1)(3);
        noc5_data_w_in(i*XLEN + j)       <= noc5_data_e_out(i*XLEN + j - 1);
        noc5_data_void_in(i*XLEN + j)(2) <= noc5_data_void_out(i*XLEN + j - 1)(3);
        noc5_stop_in(i*XLEN + j)(2)      <= noc5_stop_out(i*XLEN + j - 1)(3);
        noc6_data_w_in(i*XLEN + j)       <= noc6_data_e_out(i*XLEN + j - 1);
        noc6_data_void_in(i*XLEN + j)(2) <= noc6_data_void_out(i*XLEN + j - 1)(3);
        noc6_stop_in(i*XLEN + j)(2)      <= noc6_stop_out(i*XLEN + j - 1)(3);
      end generate x_non_0;

      x_XLEN : if (j = XLEN-1) generate
        -- East port is unconnected
        d2d_e: if D2D_CHANNELS_E = 0 generate
          noc1_data_e_in(i*XLEN + j) <= (others => '0');
          noc1_data_void_in(i*XLEN + j)(3) <= '1';
          noc1_stop_in(i*XLEN + j)(3) <= '0';
          noc2_data_e_in(i*XLEN + j) <= (others => '0');
          noc2_data_void_in(i*XLEN + j)(3) <= '1';
          noc2_stop_in(i*XLEN + j)(3) <= '0';
          noc3_data_e_in(i*XLEN + j) <= (others => '0');
          noc3_data_void_in(i*XLEN + j)(3) <= '1';
          noc3_stop_in(i*XLEN + j)(3) <= '0';
          noc4_data_e_in(i*XLEN + j) <= (others => '0');
          noc4_data_void_in(i*XLEN + j)(3) <= '1';
          noc4_stop_in(i*XLEN + j)(3) <= '0';
          noc5_data_e_in(i*XLEN + j) <= (others => '0');
          noc5_data_void_in(i*XLEN + j)(3) <= '1';
          noc5_stop_in(i*XLEN + j)(3) <= '0';
          noc6_data_e_in(i*XLEN + j) <= (others => '0');
          noc6_data_void_in(i*XLEN + j)(3) <= '1';
          noc6_stop_in(i*XLEN + j)(3) <= '0';
        end generate d2d_e;
      end generate x_XLEN;

      x_non_XLEN : if (j /= XLEN-1) generate
        -- East port is connected
        noc1_data_e_in(i*XLEN + j)       <= noc1_data_w_out(i*XLEN + j + 1);
        noc1_data_void_in(i*XLEN + j)(3) <= noc1_data_void_out(i*XLEN + j + 1)(2);
        noc1_stop_in(i*XLEN + j)(3)      <= noc1_stop_out(i*XLEN + j + 1)(2);
        noc2_data_e_in(i*XLEN + j)       <= noc2_data_w_out(i*XLEN + j + 1);
        noc2_data_void_in(i*XLEN + j)(3) <= noc2_data_void_out(i*XLEN + j + 1)(2);
        noc2_stop_in(i*XLEN + j)(3)      <= noc2_stop_out(i*XLEN + j + 1)(2);
        noc3_data_e_in(i*XLEN + j)       <= noc3_data_w_out(i*XLEN + j + 1);
        noc3_data_void_in(i*XLEN + j)(3) <= noc3_data_void_out(i*XLEN + j + 1)(2);
        noc3_stop_in(i*XLEN + j)(3)      <= noc3_stop_out(i*XLEN + j + 1)(2);
        noc4_data_e_in(i*XLEN + j)       <= noc4_data_w_out(i*XLEN + j + 1);
        noc4_data_void_in(i*XLEN + j)(3) <= noc4_data_void_out(i*XLEN + j + 1)(2);
        noc4_stop_in(i*XLEN + j)(3)      <= noc4_stop_out(i*XLEN + j + 1)(2);
        noc5_data_e_in(i*XLEN + j)       <= noc5_data_w_out(i*XLEN + j + 1);
        noc5_data_void_in(i*XLEN + j)(3) <= noc5_data_void_out(i*XLEN + j + 1)(2);
        noc5_stop_in(i*XLEN + j)(3)      <= noc5_stop_out(i*XLEN + j + 1)(2);
        noc6_data_e_in(i*XLEN + j)       <= noc6_data_w_out(i*XLEN + j + 1);
        noc6_data_void_in(i*XLEN + j)(3) <= noc6_data_void_out(i*XLEN + j + 1)(2);
        noc6_stop_in(i*XLEN + j)(3)      <= noc6_stop_out(i*XLEN + j + 1)(2);
      end generate x_non_XLEN;

    end generate meshgen_x;
  end generate meshgen_y;

  router_gen : for i in 0 to CHIPLET_NUM_TILES - 1 generate
    constant GI : integer := CHIPLET_IDX_BASE + i;
  begin
    gen_io : if CFG_IO_TILE_CHIPLET(chiplet_index) = '1' generate
      constant io_idx : integer := io_tile_id(chiplet_index) - CHIPLET_IDX_BASE;
    begin
      io_router : if i = io_idx generate
        noc_domain_socket_i : noc_domain_socket
          generic map (
            this_has_token_pm => 0,
            is_tile_io        => true, --is_io_tile(i),
            SIMULATION        => SIMULATION,
            ROUTER_PORTS      => set_router_ports(CFG_FABTECH, CFG_CHIPLET_COLS, CFG_CHIPLET_ROWS, XLEN, YLEN, tile_x(GI), tile_y(GI), chip_x(GI), chip_y(GI)),
            HAS_SYNC          => 1)
          port map (
            rst                     => reset_int,
            noc_clk_lock            => noc_clk_lock,
            tile_rstn               => tile_rstn(i),
            noc_clk                 => noc_clk,
            tile_clk                => tile_clk(i),
            noc_rstn                => noc_rstn(i),
            raw_rstn                => raw_rstn(i),
            acc_clk                 => open,
            -- DCO config
            dco_freq_sel            => dco_freq_sel(i),
            dco_div_sel             => dco_div_sel(i),
            dco_fc_sel              => dco_fc_sel(i),
            dco_cc_sel              => dco_cc_sel(i),
            dco_clk_sel             => dco_clk_sel(i),
            dco_en                  => dco_en(i),
            dco_clk_delay_sel       => dco_clk_delay_sel(i),
            -- pad config
            pad_cfg                 => pad_cfg(i),
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
            mon_noc                 => mon_noc(i),
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
            noc6_stop_out_tile      => noc6_stop_out_tile(i)
          );
        end generate io_router;
        not_io_router : if i /= io_idx generate
        noc_domain_socket_i : noc_domain_socket
          generic map (
            this_has_token_pm => 0,
            is_tile_io        => false, --is_io_tile(i),
            SIMULATION        => SIMULATION,
            ROUTER_PORTS      => set_router_ports(CFG_FABTECH, CFG_CHIPLET_COLS, CFG_CHIPLET_ROWS, XLEN, YLEN, tile_x(GI), tile_y(GI), chip_x(GI), chip_y(GI)),
            HAS_SYNC          => 1)
          port map (
            rst                     => reset_int,
            noc_clk_lock            => noc_clk_lock,
            tile_rstn               => tile_rstn(i),
            noc_clk                 => noc_clk,
            tile_clk                => tile_clk(i),
            noc_rstn                => noc_rstn(i),
            raw_rstn                => raw_rstn(i),
            acc_clk                 => open,
            -- DCO config
            dco_freq_sel            => dco_freq_sel(i),
            dco_div_sel             => dco_div_sel(i),
            dco_fc_sel              => dco_fc_sel(i),
            dco_cc_sel              => dco_cc_sel(i),
            dco_clk_sel             => dco_clk_sel(i),
            dco_en                  => dco_en(i),
            dco_clk_delay_sel       => dco_clk_delay_sel(i),
            -- pad config
            pad_cfg                 => pad_cfg(i),
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
            mon_noc                 => mon_noc(i),
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
    gen_not_io : if CFG_IO_TILE_CHIPLET(chiplet_index) = '0' generate
      noc_domain_socket_i : noc_domain_socket
        generic map (
          this_has_token_pm => 0,
          is_tile_io        => false, --is_io_tile(i),
          SIMULATION        => SIMULATION,
          ROUTER_PORTS      => set_router_ports(CFG_FABTECH, CFG_CHIPLET_COLS, CFG_CHIPLET_ROWS, XLEN, YLEN, tile_x(GI), tile_y(GI), chip_x(GI), chip_y(GI)),
          HAS_SYNC          => 1)
        port map (
          rst                     => reset_int,
          noc_clk_lock            => noc_clk_lock,
          tile_rstn               => tile_rstn(i),
          noc_clk                 => noc_clk,
          tile_clk                => tile_clk(i),
          noc_rstn                => noc_rstn(i),
          raw_rstn                => raw_rstn(i),
          acc_clk                 => open,
          -- DCO config
          dco_freq_sel            => dco_freq_sel(i),
          dco_div_sel             => dco_div_sel(i),
          dco_fc_sel              => dco_fc_sel(i),
          dco_cc_sel              => dco_cc_sel(i),
          dco_clk_sel             => dco_clk_sel(i),
          dco_en                  => dco_en(i),
          dco_clk_delay_sel       => dco_clk_delay_sel(i),
          -- pad config
          pad_cfg                 => pad_cfg(i),
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
          mon_noc                 => mon_noc(i),
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
  tiles_gen : for i in 0 to CHIPLET_NUM_TILES - 1 generate
    constant GI : integer := CHIPLET_IDX_BASE + i;
  begin
    empty_tile : if tile_type(GI) = 0 generate
      tile_empty_i : asic_tile_empty
        generic map (
          SIMULATION   => SIMULATION,
          this_has_dco => 0,
          HAS_SYNC     => 0,
          chiplet_index => chiplet_index)
        port map (
          rst                     => reset_int,
          raw_rstn                => raw_rstn(i),
          noc_rstn                => noc_rstn(i),
          tile_rstn               => tile_rstn(i),  
          tile_clk                => tile_clk(i),
          ext_clk                 => noc_clk,
          clk_div                 => clk_div_int(i),
          tdi                     => tdi_int(i),
          tdo                     => tdo_int(i),
          tms                     => tms_int,
          tclk                    => tclk_int,
          -- DCO config
          dco_freq_sel            => dco_freq_sel(i),
          dco_div_sel             => dco_div_sel(i),
          dco_fc_sel              => dco_fc_sel(i),
          dco_cc_sel              => dco_cc_sel(i),
          dco_clk_sel             => dco_clk_sel(i),
          dco_en                  => dco_en(i),
          -- Noc interface
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
          mon_noc                 => mon_noc(i));
    end generate empty_tile;


    cpu_tile : if tile_type(GI) = 1 generate
      constant CPU_ORD_BASE : integer := CFG_NCPU_TILE_BASE(chiplet_index);
      constant cpu_li       : integer := tile_cpu_id(GI) - CPU_ORD_BASE;
    begin
-- pragma translate_off
      assert tile_cpu_id(GI) /= -1 report "Undefined CPU ID for CPU tile" severity error;
-- pragma translate_on
      tile_cpu_i : asic_tile_cpu
        generic map (
          SIMULATION   => SIMULATION,
          this_has_dco => 0,
          HAS_SYNC     => 0,
          chiplet_index => chiplet_index)
        port map (
          rst                     => reset_int,
          raw_rstn                => raw_rstn(i),
          noc_rstn                => noc_rstn(i),
          tile_rstn               => tile_rstn(i),  
          tile_clk                => tile_clk(i),
          ext_clk                 => noc_clk,
          clk_div                 => clk_div_int(i),
          --cpuerr                  => cpuerr_vec((tile_cpu_id(GI) - CHIPLET_IDX_BASE)),
          cpuerr                  => cpuerr_vec(cpu_li),
          tdi                     => tdi_int(i),
          tdo                     => tdo_int(i),
          tms                     => tms_int,
          tclk                    => tclk_int,
          -- DCO config
          dco_freq_sel            => dco_freq_sel(i),
          dco_div_sel             => dco_div_sel(i),
          dco_fc_sel              => dco_fc_sel(i),
          dco_cc_sel              => dco_cc_sel(i),
          dco_clk_sel             => dco_clk_sel(i),
          dco_en                  => dco_en(i),
          -- Noc interface
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
          mon_noc                 => mon_noc(i));
    end generate cpu_tile;


    accelerator_tile : if tile_type(GI) = 2 generate
-- pragma translate_off
      assert tile_device(GI) /= 0 report "Undefined device ID for accelerator tile" severity error;
-- pragma translate_on
      tile_acc_i : asic_tile_acc
        generic map (
          SIMULATION        => SIMULATION,
          this_hls_conf     => tile_design_point(GI),
          this_device       => tile_device(GI),
          this_irq_type     => tile_irq_type(GI),
          this_has_l2       => tile_has_l2(GI),
          this_has_token_pm => tile_has_tdvfs(GI),
          this_has_dco      => 0,
          HAS_SYNC          => 0,
          chiplet_index     => chiplet_index)
        port map (
          rst                     => reset_int,
          raw_rstn                => raw_rstn(i),
          noc_rstn                => noc_rstn(i),
          tile_rstn               => tile_rstn(i),  
          tile_clk                => tile_clk(i),
          ext_clk                 => noc_clk,
          clk_div                 => clk_div_int(i),
          tdi                     => tdi_int(i),
          tdo                     => tdo_int(i),
          tms                     => tms_int,
          tclk                    => tclk_int,
          -- DCO config
          dco_freq_sel            => dco_freq_sel(i),
          dco_div_sel             => dco_div_sel(i),
          dco_fc_sel              => dco_fc_sel(i),
          dco_cc_sel              => dco_cc_sel(i),
          dco_clk_sel             => dco_clk_sel(i),
          dco_en                  => dco_en(i),
          -- Noc interface
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
          mon_noc                 => mon_noc(i));
    end generate accelerator_tile;


    io_tile : if tile_type(GI) = 3 generate
      tile_io_i : asic_tile_io
        generic map (
          SIMULATION   => SIMULATION,
          this_has_dco => 0,
          HAS_SYNC     => 0,
          chiplet_index => chiplet_index)
        port map (
          rst                     => reset_int,       -- from I/O PAD reset
          raw_rstn                => raw_rstn(i),
          noc_rstn                => noc_rstn(i),
          tile_rstn               => tile_rstn(i),  
          tile_clk                => tile_clk(i),
          noc_clk_out             => noc_clk,         -- NoC clock out
          noc_clk_lock_out        => noc_clk_lock,
          ext_clk_noc             => ext_clk_int,     -- backup NoC clock
          clk_div_noc             => clk_div_noc_int,
          ext_clk                 => noc_clk,  -- backup clock (fixed)
          clk_div                 => clk_div_int(i),
          reset_o2                => reset_o2_int,
          etx_clk                 => etx_clk_int,
          erx_clk                 => erx_clk_int,
          erxd                    => erxd_int,
          erx_dv                  => erx_dv_int,
          erx_er                  => erx_er_int,
          erx_col                 => erx_col_int,
          erx_crs                 => erx_crs_int,
          etxd                    => etxd_int,
          etx_en                  => etx_en_int,
          etx_er                  => etx_er_int,
          emdc                    => emdc_int,
          emdio_i                 => emdio_i,
          emdio_o                 => emdio_o,
          emdio_oe                => emdio_oe,
          iolink_data_oen         => iolink_data_oen,
          iolink_data_in          => iolink_data_in_int,
          iolink_data_out         => iolink_data_out_int,
          iolink_valid_in         => iolink_valid_in_int,
          iolink_valid_out        => iolink_valid_out_int,
          iolink_clk_in           => iolink_clk_in_int,
          iolink_clk_out          => iolink_clk_out_int,
          iolink_credit_in        => iolink_credit_in_int,
          iolink_credit_out       => iolink_credit_out_int,
          uart_rxd                => uart_rxd_int,
          uart_txd                => uart_txd_int,
          uart_ctsn               => uart_ctsn_int,
          uart_rtsn               => uart_rtsn_int,
          tdi                     => tdi_int(i),
          tdo                     => tdo_int(i),
          tms                     => tms_int,
          tclk                    => tclk_int,
          -- DCO config
          dco_freq_sel            => dco_freq_sel(i),
          dco_div_sel             => dco_div_sel(i),
          dco_fc_sel              => dco_fc_sel(i),
          dco_cc_sel              => dco_cc_sel(i),
          dco_clk_sel             => dco_clk_sel(i),
          dco_en                  => dco_en(i),
          -- Noc interface
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
          mon_noc                 => mon_noc(i));
    end generate io_tile;


    mem_tile : if tile_type(GI) = 4 generate
      constant MEM_ORD_BASE : integer := CFG_NMEM_TILE_BASE(chiplet_index);  -- global ordinal of this chiplet's first MEM
      constant mem_li       : integer := tile_mem_id(GI) - MEM_ORD_BASE;     -- 0 .. NMEM_THIS-1
    begin
      tile_mem_i : asic_tile_mem
        generic map (
          this_has_dco => 0,
          HAS_SYNC     => 0,
          chiplet_index => chiplet_index)
        port map (
          rst                => reset_int,
          raw_rstn           => raw_rstn(i),
          noc_rstn           => noc_rstn(i),
          tile_rstn          => tile_rstn(i),  
          tile_clk           => tile_clk(i),
          ext_clk            => noc_clk,
          clk_div            => clk_div_int(i),
          fpga_data_in       => fpga_data_in((mem_li + 1) * (CFG_MEM_LINK_BITS) - 1 downto mem_li * (CFG_MEM_LINK_BITS)),
          fpga_data_out      => fpga_data_out((mem_li + 1) * (CFG_MEM_LINK_BITS) - 1 downto mem_li * (CFG_MEM_LINK_BITS)),
          fpga_oen           => fpga_oen(mem_li),
          fpga_valid_in      => fpga_valid_in_int(mem_li),
          fpga_valid_out     => fpga_valid_out_int(mem_li),
          fpga_clk_in        => fpga_clk_in_int(mem_li),
          fpga_clk_out       => fpga_clk_out_int(mem_li),
          fpga_credit_in     => fpga_credit_in_int(mem_li),
          fpga_credit_out    => fpga_credit_out_int(mem_li),
          tdi                => tdi_int(i),
          tdo                => tdo_int(i),
          tms                => tms_int,
          tclk               => tclk_int,
          -- DCO config
          dco_freq_sel            => dco_freq_sel(i),
          dco_div_sel             => dco_div_sel(i),
          dco_fc_sel              => dco_fc_sel(i),
          dco_cc_sel              => dco_cc_sel(i),
          dco_clk_sel             => dco_clk_sel(i),
          dco_en                  => dco_en(i),
          dco_clk_delay_sel       => dco_clk_delay_sel(i),
          -- Noc interface
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
          mon_noc                 => mon_noc(i));
    end generate mem_tile;

    slm_tile : if tile_type(GI) = 5 generate
      tile_slm_i : asic_tile_slm
        generic map (
          this_has_dco => 0,
          HAS_SYNC     => 0,
          chiplet_index => chiplet_index)
        port map (
          rst                     => reset_int,
          raw_rstn                => raw_rstn(i),
          noc_rstn                => noc_rstn(i),
          tile_rstn               => tile_rstn(i),  
          tile_clk                => tile_clk(i),
          ext_clk                 => noc_clk,
          clk_div                 => clk_div_int(i),
          tdi                     => tdi_int(i),
          tdo                     => tdo_int(i),
          tms                     => tms_int,
          tclk                    => tclk_int,
          -- DCO config
          dco_freq_sel            => dco_freq_sel(i),
          dco_div_sel             => dco_div_sel(i),
          dco_fc_sel              => dco_fc_sel(i),
          dco_cc_sel              => dco_cc_sel(i),
          dco_clk_sel             => dco_clk_sel(i),
          dco_en                  => dco_en(i),
          dco_clk_delay_sel       => dco_clk_delay_sel(i),
          -- Noc interface
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
          mon_noc                 => mon_noc(i));
    end generate slm_tile;

  end generate tiles_gen;

end;
