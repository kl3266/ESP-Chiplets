-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.uart.all;
use work.misc.all;
use work.net.all;
library unisim;
use unisim.VCOMPONENTS.all;
-- pragma translate_off
use work.sim.all;
use std.textio.all;
use work.stdio.all;
-- pragma translate_on
use work.monitor_pkg.all;
use work.esp_csr_pkg.all;
use work.sldacc.all;
use work.nocpackage.all;
use work.tile.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;

entity chip_emu_top is
  generic (
    SIMULATION : boolean := false);
  port (
    reset           : in    std_logic;
    -- Chip clock used for emulation on FPGA only
    clk_emu_p       : in    std_logic;
    clk_emu_n       : in    std_logic;
    clk_d2d_p       : in    std_logic;
    clk_d2d_n       : in    std_logic;
    -- Backup external clocks for selected tiles and NoC (unused for emulation)
    ext_clk         : in    std_logic;
    -- FPGA proxy memory link
    fpga_data       : inout std_logic_vector(CFG_NMEM_TILE * CFG_MEM_LINK_BITS - 1 downto 0);
    fpga_valid_in   : in    std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
    fpga_valid_out  : out   std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
    fpga_clk_in     : in    std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
    fpga_clk_out    : out   std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
    fpga_credit_in  : in    std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
    fpga_credit_out : out   std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
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
    tdo_acc         : out   std_logic
);
end chip_emu_top;


architecture rtl of chip_emu_top is

  -----------------------------------------------------------------------------
  -- ESP chip specific instance
  -----------------------------------------------------------------------------
  component ESP_ASIC_TOP is
    generic (
      SIMULATION : boolean;
      D2D_CHANNELS_N  : integer;
      D2D_CHANNELS_S  : integer;
      D2D_CHANNELS_E  : integer;
      D2D_CHANNELS_W  : integer;
      chiplet_index   : integer
    );
    port (
      reset           : in    std_logic;
      d2d_clk         : in    std_logic;
      ext_clk         : in    std_logic;
      fpga_data       : inout std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index) * CFG_MEM_LINK_BITS - 1 downto 0);
      fpga_valid_in   : in    std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index) - 1 downto 0);
      fpga_valid_out  : out   std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index) - 1 downto 0);
      fpga_clk_in     : in    std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index) - 1 downto 0);
      fpga_clk_out    : out   std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index) - 1 downto 0);
      fpga_credit_in  : in    std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index) - 1 downto 0);
      fpga_credit_out : out   std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index) - 1 downto 0);
      reset_o2        : out   std_ulogic;
      -- I/O link
      iolink_data       : inout std_logic_vector(CFG_IOLINK_BITS - 1 downto 0);
      iolink_valid_in   : in    std_ulogic;
      iolink_valid_out  : out   std_ulogic;
      iolink_clk_in     : in    std_ulogic;
      iolink_clk_out    : out   std_ulogic;
      iolink_credit_in  : in    std_ulogic;
      iolink_credit_out : out   std_ulogic;
      --Ethernet signals
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
      uart_rxd        : in    std_logic;
      uart_txd        : out   std_logic;
      uart_ctsn       : in    std_logic;
      uart_rtsn       : out   std_logic;
      --JTAG
      tclk            : in    std_logic;
      tms             : in    std_logic;
      tdi_io          : in    std_logic;
      tdi_cpu         : in    std_logic;
      tdi_mem         : in    std_logic;
      tdi_acc         : in    std_logic;
      tdo_io          : out    std_logic;
      tdo_cpu         : out    std_logic;
      tdo_mem         : out    std_logic;
      tdo_acc         : out    std_logic;
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
  end component ESP_ASIC_TOP;

--  constant NMEM_0 : integer := CFG_NMEM_TILE_CHIPLET(0);
--  constant NMEM_1 : integer := CFG_NMEM_TILE_CHIPLET(1);
--
--  constant MEM_0_LO : integer := 0;                               -- CFG_NMEM_TILE_INDEX(i) * CFG_MEM_LINK_BITS - 1
--  constant MEM_0_HI : integer := NMEM_0 * CFG_MEM_LINK_BITS - 1;  -- CFG_NMEM_TILE_INDEX(i+1) * CFG_MEM_LINK_BITS - 1
--
--  constant MEM_1_LO : integer := NMEM_0 * CFG_MEM_LINK_BITS;                -- CFG_NMEM_TILE_INDEX(i) * CFG_MEM_LINK_BITS - 1
--  constant MEM_1_HI : integer := (NMEM_0 + NMEM_1) * CFG_MEM_LINK_BITS - 1; -- CFG_NMEM_TILE_INDEX(i+1) * CFG_MEM_LINK_BITS - 1
--
--  constant V0_LO : integer := 0;  -- CFG_NMEM_TILE_CHIPLET_INDEX(i)
--  constant V0_HI : integer := NMEM_0 - 1; -- CFG_NMEM_TILE_CHIPLET_INDEX(i+1)-1
--
--  constant V1_LO : integer := NMEM_0; -- CFG_NMEM_TILE_CHIPLET_INDEX(i)
--  constant V1_HI : integer := NMEM_0 + NMEM_1 - 1;  -- CFG_NMEM_TILE_CHIPLET_INDEX(i+1)-1
  function iif(cond : boolean; a, b : integer) return integer is
  begin
    if cond then return a; else return b; end if;
  end function;

  signal ext_clk_int : std_logic;
  signal d2d_clk_int : std_logic;

  signal emdio_dummy : std_logic := '0';
--  signal fpga_data_dummy : std_logic_vector(CFG_NMEM_TILE_CHIPLET(chiplet_index) * CFG_MEM_LINK_BITS - 1 downto 0) := (others => '0');
  signal iolink_data_dummy : std_logic_vector(CFG_IOLINK_BITS - 1 downto 0) := (others => '0');

  signal chiplet_data_n_in    : coh_noc_flit_vector(WIRES_PER_CONNECTION * CFG_CHIPLET_NUM-1 downto 0);
  signal chiplet_data_s_in    : coh_noc_flit_vector(WIRES_PER_CONNECTION * CFG_CHIPLET_NUM-1 downto 0);
  signal chiplet_data_e_in    : coh_noc_flit_vector(WIRES_PER_CONNECTION * CFG_CHIPLET_NUM-1 downto 0);
  signal chiplet_data_w_in    : coh_noc_flit_vector(WIRES_PER_CONNECTION * CFG_CHIPLET_NUM-1 downto 0);
  signal chiplet_data_n_out   : coh_noc_flit_vector(WIRES_PER_CONNECTION * CFG_CHIPLET_NUM-1 downto 0);
  signal chiplet_data_s_out   : coh_noc_flit_vector(WIRES_PER_CONNECTION * CFG_CHIPLET_NUM-1 downto 0);
  signal chiplet_data_e_out   : coh_noc_flit_vector(WIRES_PER_CONNECTION * CFG_CHIPLET_NUM-1 downto 0);
  signal chiplet_data_w_out   : coh_noc_flit_vector(WIRES_PER_CONNECTION * CFG_CHIPLET_NUM-1 downto 0);
  signal chiplet_credit_in_n  : std_logic_vector(WIRES_PER_CONNECTION*CFG_CHIPLET_NUM-1 downto 0);
  signal chiplet_credit_in_s  : std_logic_vector(WIRES_PER_CONNECTION*CFG_CHIPLET_NUM-1 downto 0);
  signal chiplet_credit_in_e  : std_logic_vector(WIRES_PER_CONNECTION*CFG_CHIPLET_NUM-1 downto 0); 
  signal chiplet_credit_in_w  : std_logic_vector(WIRES_PER_CONNECTION*CFG_CHIPLET_NUM-1 downto 0); 
  signal chiplet_credit_out_n : std_logic_vector(WIRES_PER_CONNECTION*CFG_CHIPLET_NUM-1 downto 0);
  signal chiplet_credit_out_s : std_logic_vector(WIRES_PER_CONNECTION*CFG_CHIPLET_NUM-1 downto 0);
  signal chiplet_credit_out_e : std_logic_vector(WIRES_PER_CONNECTION*CFG_CHIPLET_NUM-1 downto 0); 
  signal chiplet_credit_out_w : std_logic_vector(WIRES_PER_CONNECTION*CFG_CHIPLET_NUM-1 downto 0); 
  signal chiplet_valid_in_n   : std_logic_vector(WIRES_PER_CONNECTION*CFG_CHIPLET_NUM-1 downto 0);
  signal chiplet_valid_in_s   : std_logic_vector(WIRES_PER_CONNECTION*CFG_CHIPLET_NUM-1 downto 0);
  signal chiplet_valid_in_e   : std_logic_vector(WIRES_PER_CONNECTION*CFG_CHIPLET_NUM-1 downto 0); 
  signal chiplet_valid_in_w   : std_logic_vector(WIRES_PER_CONNECTION*CFG_CHIPLET_NUM-1 downto 0); 
  signal chiplet_valid_out_n  : std_logic_vector(WIRES_PER_CONNECTION*CFG_CHIPLET_NUM-1 downto 0);
  signal chiplet_valid_out_s  : std_logic_vector(WIRES_PER_CONNECTION*CFG_CHIPLET_NUM-1 downto 0);
  signal chiplet_valid_out_e  : std_logic_vector(WIRES_PER_CONNECTION*CFG_CHIPLET_NUM-1 downto 0); 
  signal chiplet_valid_out_w  : std_logic_vector(WIRES_PER_CONNECTION*CFG_CHIPLET_NUM-1 downto 0);  

  constant WPC : integer := WIRES_PER_CONNECTION;

  attribute keep         : boolean;
  attribute syn_keep     : string;
  attribute keep of ext_clk_int : signal is true;
  attribute syn_keep of ext_clk_int : signal is "true";

begin  -- architecture rtl

  clk_emu_gen: if ESP_EMU /= 0 generate
    clk_emu_buf : ibufgds
      generic map(
        IBUF_LOW_PWR => FALSE
        )
      port map (
        I  => clk_emu_p,
        IB => clk_emu_n,
        O  => ext_clk_int
        );
  end generate clk_emu_gen;

  chip_clk_gen: if ESP_EMU = 0 generate
    ext_clk_int <= ext_clk;
  end generate chip_clk_gen;

  clk_d2d_buf : ibufgds
    generic map(
      IBUF_LOW_PWR => FALSE
      )
    port map (
      I  => clk_d2d_p,
      IB => clk_d2d_n,
      O  => d2d_clk_int
      );

  chipletmeshgen_y : for i in 0 to CFG_CHIPLET_ROWS-1 generate
    chipletmeshgen_x : for j in 0 to CFG_CHIPLET_COLS-1 generate
      chip_y_0 : if (i=0) generate
        -- North Port is not connected
        chiplet_data_n_in(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= (others => (others => '0'));
        chiplet_credit_in_n(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= (others => '0');
        chiplet_valid_in_n(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= (others => '0');
      end generate chip_y_0;
      chip_y_non_0 : if (i /= 0) generate
        chiplet_data_n_in(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= chiplet_data_s_out((i-1)*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto (i-1)*CFG_CHIPLET_COLS*WPC + WPC*j);
        chiplet_credit_in_n(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= chiplet_credit_out_s((i-1)*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto (i-1)*CFG_CHIPLET_COLS*WPC + WPC*j);
        chiplet_valid_in_n(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= chiplet_valid_out_s((i-1)*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto (i-1)*CFG_CHIPLET_COLS*WPC + WPC*j);
      end generate chip_y_non_0;
      chip_y_YLEN : if (i = CFG_CHIPLET_ROWS-1) generate
        chiplet_data_s_in(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= (others => (others => '0'));
        chiplet_credit_in_s(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= (others => '0');
        chiplet_valid_in_s(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= (others => '0');
      end generate chip_y_YLEN;
      chip_y_non_YLEN : if (i /= CFG_CHIPLET_ROWS-1) generate
        chiplet_data_s_in(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= chiplet_data_n_out((i+1)*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto (i+1)*CFG_CHIPLET_COLS*WPC + WPC*j);
        chiplet_credit_in_s(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= chiplet_credit_out_n((i+1)*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto (i+1)*CFG_CHIPLET_COLS*WPC + WPC*j);
        chiplet_valid_in_s(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= chiplet_valid_out_n((i+1)*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto (i+1)*CFG_CHIPLET_COLS*WPC + WPC*j);
      end generate chip_y_non_YLEN;
      chip_x_0 : if (j=0) generate
        chiplet_data_w_in(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= (others => (others => '0'));
        chiplet_credit_in_w(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= (others => '0');
        chiplet_valid_in_w(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= (others => '0');
      end generate chip_x_0;
      chip_x_non_0 : if (j /= 0) generate
        chiplet_data_w_in(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= chiplet_data_e_out(i*CFG_CHIPLET_COLS*WPC + WPC*(j)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*(j-1));
        chiplet_credit_in_w(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= chiplet_credit_out_e(i*CFG_CHIPLET_COLS*WPC + WPC*(j)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*(j-1));
        chiplet_valid_in_w(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= chiplet_valid_out_e(i*CFG_CHIPLET_COLS*WPC + WPC*(j)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*(j-1));
      end generate chip_x_non_0;
      chip_x_XLEN : if (j = CFG_CHIPLET_COLS-1) generate
        chiplet_data_e_in(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= (others => (others => '0'));
        chiplet_credit_in_e(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= (others => '0');
        chiplet_valid_in_e(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= (others => '0');
      end generate chip_x_XLEN;
      chip_x_non_XLEN : if (j /= CFG_CHIPLET_COLS-1) generate
        chiplet_data_e_in(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= chiplet_data_w_out(i*CFG_CHIPLET_COLS*WPC + WPC*(j+2)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*(j+1));
        chiplet_credit_in_e(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= chiplet_credit_out_w(i*CFG_CHIPLET_COLS*WPC + WPC*(j+2)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*(j+1));
        chiplet_valid_in_e(i*CFG_CHIPLET_COLS*WPC + WPC*(j+1)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*j) <= chiplet_valid_out_w(i*CFG_CHIPLET_COLS*WPC + WPC*(j+2)-1 downto i*CFG_CHIPLET_COLS*WPC + WPC*(j+1));
      end generate chip_x_non_XLEN;
    end generate chipletmeshgen_x;
  end generate chipletmeshgen_y;

  chip_gen : for i in 0 to CFG_CHIPLET_NUM - 1 generate
--    constant MEM_0_LO : integer := 0;                               -- CFG_NMEM_TILE_INDEX(i) * CFG_MEM_LINK_BITS - 1
--    constant MEM_0_HI : integer := NMEM_0 * CFG_MEM_LINK_BITS - 1;  -- CFG_NMEM_TILE_INDEX(i+1) * CFG_MEM_LINK_BITS - 1
--    constant MEM_1_LO : integer := NMEM_0 * CFG_MEM_LINK_BITS;                -- CFG_NMEM_TILE_INDEX(i) * CFG_MEM_LINK_BITS - 1
--    constant MEM_1_HI : integer := (NMEM_0 + NMEM_1) * CFG_MEM_LINK_BITS - 1; -- CFG_NMEM_TILE_INDEX(i+1) * CFG_MEM_LINK_BITS - 1
--    constant V0_LO : integer := 0;  -- CFG_NMEM_TILE_CHIPLET_INDEX(i)
--    constant V0_HI : integer := NMEM_0 - 1; -- CFG_NMEM_TILE_CHIPLET_INDEX(i+1)-1
--    constant V1_LO : integer := NMEM_0; -- CFG_NMEM_TILE_CHIPLET_INDEX(i)
--    constant V1_HI : integer := NMEM_0 + NMEM_1 - 1;  -- CFG_NMEM_TILE_CHIPLET_INDEX(i+1)-1
    constant ROW : integer := i / CFG_CHIPLET_COLS;
    constant COL : integer := i mod CFG_CHIPLET_COLS;
    constant D2D_CHANNELS_N : integer := iif(ROW = 0, 0, WPC);
    constant D2D_CHANNELS_S : integer := iif(ROW = CFG_CHIPLET_ROWS-1, 0, WPC);
    constant D2D_CHANNELS_E : integer := iif(COL = CFG_CHIPLET_COLS-1, 0, WPC);
    constant D2D_CHANNELS_W : integer := iif(COL = 0, 0, WPC);
    constant MEM_LO : integer := CFG_NMEM_TILE_BASE(i) * CFG_MEM_LINK_BITS;
    constant MEM_HI : integer := (CFG_NMEM_TILE_BASE(i) + CFG_NMEM_TILE_CHIPLET(i)) * CFG_MEM_LINK_BITS - 1;
    constant V_LO   : integer := CFG_NMEM_TILE_BASE(i);
    constant V_HI   : integer := (CFG_NMEM_TILE_BASE(i) + CFG_NMEM_TILE_CHIPLET(i)) - 1;
  begin
    io_tile_master_chip_gen : if (i = 0) generate
      chip_i  : ESP_ASIC_TOP
      generic map (
        SIMULATION      =>  SIMULATION,
        D2D_CHANNELS_N  =>  D2D_CHANNELS_N,
        D2D_CHANNELS_S  =>  D2D_CHANNELS_S,
        D2D_CHANNELS_E  =>  D2D_CHANNELS_E,
        D2D_CHANNELS_W  =>  D2D_CHANNELS_W,
        chiplet_index   =>  i)
      port map (
        reset              => reset,
        d2d_clk            => d2d_clk_int,
        ext_clk            => ext_clk_int,
        fpga_data          => fpga_data(MEM_HI downto MEM_LO),  --HI_LO NEED CHANGES
        fpga_valid_in      => fpga_valid_in(V_HI downto V_LO),
        fpga_valid_out     => fpga_valid_out(V_HI downto V_LO),
        fpga_clk_in        => fpga_clk_in(V_HI downto V_LO),
        fpga_clk_out       => fpga_clk_out(V_HI downto V_LO),
        fpga_credit_in     => fpga_credit_in(V_HI downto V_LO),
        fpga_credit_out    => fpga_credit_out(V_HI downto V_LO),
        iolink_data        => iolink_data,
        iolink_valid_in    => iolink_valid_in,
        iolink_valid_out   => iolink_valid_out,
        iolink_clk_in      => iolink_clk_in,
        iolink_clk_out     => iolink_clk_out,
        iolink_credit_in   => iolink_credit_in,
        iolink_credit_out  => iolink_credit_out,
        reset_o2           => reset_o2,
        etx_clk            => etx_clk,
        erx_clk            => erx_clk,
        erxd               => erxd,
        erx_dv             => erx_dv,
        erx_er             => erx_er,
        erx_col            => erx_col,
        erx_crs            => erx_crs,
        etxd               => etxd,
        etx_en             => etx_en,
        etx_er             => etx_er,
        emdc               => emdc,
        emdio              => emdio,
        uart_rxd           => uart_rxd,
        uart_txd           => uart_txd,
        uart_ctsn          => uart_ctsn,
        uart_rtsn          => uart_rtsn,
        tclk               => tclk,
        tms                => tms,
        tdi_io             => tdi_io,
        tdi_cpu            => tdi_cpu,
        tdi_mem            => tdi_mem,
        tdi_acc            => tdi_acc,
        tdo_io             => tdo_io,
        tdo_cpu            => tdo_cpu,
        tdo_mem            => tdo_mem,
        tdo_acc            => tdo_acc,
        chiplet_data_n_in     => chiplet_data_n_in(WPC*(i+1)-1 downto WPC*i),
        chiplet_data_s_in     => chiplet_data_s_in(WPC*(i+1)-1 downto WPC*i),
        chiplet_data_e_in     => chiplet_data_e_in(WPC*(i+1)-1 downto WPC*i),
        chiplet_data_w_in     => chiplet_data_w_in(WPC*(i+1)-1 downto WPC*i),
        chiplet_data_n_out    => chiplet_data_n_out(WPC*(i+1)-1 downto WPC*i),
        chiplet_data_s_out    => chiplet_data_s_out(WPC*(i+1)-1 downto WPC*i),
        chiplet_data_e_out    => chiplet_data_e_out(WPC*(i+1)-1 downto WPC*i),
        chiplet_data_w_out    => chiplet_data_w_out(WPC*(i+1)-1 downto WPC*i),
        chiplet_credit_in_n   => chiplet_credit_in_n(WPC*(i+1)-1 downto WPC*i),
        chiplet_credit_in_s   => chiplet_credit_in_s(WPC*(i+1)-1 downto WPC*i),
        chiplet_credit_in_e   => chiplet_credit_in_e(WPC*(i+1)-1 downto WPC*i),
        chiplet_credit_in_w   => chiplet_credit_in_w(WPC*(i+1)-1 downto WPC*i),
        chiplet_credit_out_n  => chiplet_credit_out_n(WPC*(i+1)-1 downto WPC*i),
        chiplet_credit_out_s  => chiplet_credit_out_s(WPC*(i+1)-1 downto WPC*i),
        chiplet_credit_out_e  => chiplet_credit_out_e(WPC*(i+1)-1 downto WPC*i),
        chiplet_credit_out_w  => chiplet_credit_out_w(WPC*(i+1)-1 downto WPC*i),
        chiplet_valid_in_n    => chiplet_valid_in_n(WPC*(i+1)-1 downto WPC*i),
        chiplet_valid_in_s    => chiplet_valid_in_s(WPC*(i+1)-1 downto WPC*i),
        chiplet_valid_in_e    => chiplet_valid_in_e(WPC*(i+1)-1 downto WPC*i),
        chiplet_valid_in_w    => chiplet_valid_in_w(WPC*(i+1)-1 downto WPC*i),
        chiplet_valid_out_n   => chiplet_valid_out_n(WPC*(i+1)-1 downto WPC*i),
        chiplet_valid_out_s   => chiplet_valid_out_s(WPC*(i+1)-1 downto WPC*i),
        chiplet_valid_out_e   => chiplet_valid_out_e(WPC*(i+1)-1 downto WPC*i),
        chiplet_valid_out_w   => chiplet_valid_out_w(WPC*(i+1)-1 downto WPC*i)
      );
    end generate io_tile_master_chip_gen;
    io_tile_slave_chip_gen : if (i /= 0) generate
      chip_i : ESP_ASIC_TOP
      generic map (
        SIMULATION      =>  SIMULATION,
        D2D_CHANNELS_N  =>  D2D_CHANNELS_N,
        D2D_CHANNELS_S  =>  D2D_CHANNELS_S,
        D2D_CHANNELS_E  =>  D2D_CHANNELS_E,
        D2D_CHANNELS_W  =>  D2D_CHANNELS_W,
        chiplet_index   => i)
      port map (
        reset              => reset,
        d2d_clk            => d2d_clk_int,
        ext_clk            => ext_clk_int,
        fpga_data          => fpga_data(MEM_HI downto MEM_LO),
        fpga_valid_in      => fpga_valid_in(V_HI downto V_LO),
        fpga_valid_out     => fpga_valid_out(V_HI downto V_LO),
        fpga_clk_in        => fpga_clk_in(V_HI downto V_LO),
        fpga_clk_out       => fpga_clk_out(V_HI downto V_LO),
        fpga_credit_in     => fpga_credit_in(V_HI downto V_LO),
        fpga_credit_out    => fpga_credit_out(V_HI downto V_LO),
        iolink_data        => iolink_data_dummy,
        iolink_valid_in    => '0',
        iolink_valid_out   => open,
        iolink_clk_in      => '0',
        iolink_clk_out     => open,
        iolink_credit_in   => '0',
        iolink_credit_out  => open,
        reset_o2           => open,
        etx_clk            => '0',
        erx_clk            => '0',
        erxd               => (others =>'0'),
        erx_dv             => '0',
        erx_er             => '0',
        erx_col            => '0',
        erx_crs            => '0',
        etxd               => open,
        etx_en             => open,
        etx_er             => open,
        emdc               => open,
        emdio              => emdio_dummy,
        uart_rxd           => '0',
        uart_txd           => open,
        uart_ctsn          => '0',
        uart_rtsn          => open,
        tclk               => '0',
        tms                => '0',
        tdi_io             => '0',
        tdi_cpu            => '0',
        tdi_mem            => '0',
        tdi_acc            => '0',
        tdo_io             => open,
        tdo_cpu            => open,
        tdo_mem            => open,
        tdo_acc            => open,
        chiplet_data_n_in     => chiplet_data_n_in(WPC*(i+1)-1 downto WPC*i),
        chiplet_data_s_in     => chiplet_data_s_in(WPC*(i+1)-1 downto WPC*i),
        chiplet_data_e_in     => chiplet_data_e_in(WPC*(i+1)-1 downto WPC*i),
        chiplet_data_w_in     => chiplet_data_w_in(WPC*(i+1)-1 downto WPC*i),
        chiplet_data_n_out    => chiplet_data_n_out(WPC*(i+1)-1 downto WPC*i),
        chiplet_data_s_out    => chiplet_data_s_out(WPC*(i+1)-1 downto WPC*i),
        chiplet_data_e_out    => chiplet_data_e_out(WPC*(i+1)-1 downto WPC*i),
        chiplet_data_w_out    => chiplet_data_w_out(WPC*(i+1)-1 downto WPC*i),
        chiplet_credit_in_n   => chiplet_credit_in_n(WPC*(i+1)-1 downto WPC*i),
        chiplet_credit_in_s   => chiplet_credit_in_s(WPC*(i+1)-1 downto WPC*i),
        chiplet_credit_in_e   => chiplet_credit_in_e(WPC*(i+1)-1 downto WPC*i),
        chiplet_credit_in_w   => chiplet_credit_in_w(WPC*(i+1)-1 downto WPC*i),
        chiplet_credit_out_n  => chiplet_credit_out_n(WPC*(i+1)-1 downto WPC*i),
        chiplet_credit_out_s  => chiplet_credit_out_s(WPC*(i+1)-1 downto WPC*i),
        chiplet_credit_out_e  => chiplet_credit_out_e(WPC*(i+1)-1 downto WPC*i),
        chiplet_credit_out_w  => chiplet_credit_out_w(WPC*(i+1)-1 downto WPC*i),
        chiplet_valid_in_n    => chiplet_valid_in_n(WPC*(i+1)-1 downto WPC*i),
        chiplet_valid_in_s    => chiplet_valid_in_s(WPC*(i+1)-1 downto WPC*i),
        chiplet_valid_in_e    => chiplet_valid_in_e(WPC*(i+1)-1 downto WPC*i),
        chiplet_valid_in_w    => chiplet_valid_in_w(WPC*(i+1)-1 downto WPC*i),
        chiplet_valid_out_n   => chiplet_valid_out_n(WPC*(i+1)-1 downto WPC*i),
        chiplet_valid_out_s   => chiplet_valid_out_s(WPC*(i+1)-1 downto WPC*i),
        chiplet_valid_out_e   => chiplet_valid_out_e(WPC*(i+1)-1 downto WPC*i),
        chiplet_valid_out_w   => chiplet_valid_out_w(WPC*(i+1)-1 downto WPC*i)
      ); 
    end generate io_tile_slave_chip_gen;
  end generate chip_gen;
end architecture rtl;
