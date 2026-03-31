-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  Abbreviated I/O tile for Non-Main Chiplets
--  FEATURES:
--    1. No Local Masters (No CPU, Eth, JTAG).
--    2. Supports Incoming Configuration via NoC Plane 5 (CSRs, Soft Reset).
--    3. DCO Mappings match original tile_io (Tile=Pads, NoC=CSRs).
--    4. NoC Planes 1, 2, 3, 4, 6 are tied off (Unused).
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.esp_global.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.leon3.all;
use work.misc.all;
use work.net.all;
library unisim;
use unisim.all;
use work.monitor_pkg.all;
use work.esp_csr_pkg.all;
use work.nocpackage.all;
use work.tile.all;
use work.coretypes.all;
use work.grlib_config.all;
use work.socmap.all;

entity tile_io_abbrev is
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
    -- DCO config (Inputs from Pads/Top-Level)
    dco_freq_sel       : in std_logic_vector(1 downto 0);
    dco_div_sel        : in std_logic_vector(2 downto 0);
    dco_fc_sel         : in std_logic_vector(5 downto 0);
    dco_cc_sel         : in std_logic_vector(5 downto 0);
    dco_clk_sel        : in std_ulogic;
    dco_en             : in std_ulogic;  
    -- NOC Ports
    test1_output_port    : in coh_noc_flit_type;
    test1_data_void_out  : in std_ulogic;
    test1_stop_in        : in std_ulogic;
    test2_output_port    : in coh_noc_flit_type;
    test2_data_void_out  : in std_ulogic;
    test2_stop_in        : in std_ulogic;
    test3_output_port    : in coh_noc_flit_type;
    test3_data_void_out  : in std_ulogic;
    test3_stop_in        : in std_ulogic;
    test4_output_port    : in dma_noc_flit_type;
    test4_data_void_out  : in std_ulogic;
    test4_stop_in        : in std_ulogic;
    test5_output_port    : in misc_noc_flit_type;
    test5_data_void_out  : in std_ulogic;
    test5_stop_in        : in std_ulogic;
    test6_output_port    : in dma_noc_flit_type;
    test6_data_void_out  : in std_ulogic;
    test6_stop_in        : in std_ulogic;
    test1_input_port     : out coh_noc_flit_type;
    test1_data_void_in   : out std_ulogic;
    test1_stop_out       : out std_ulogic;
    test2_input_port     : out coh_noc_flit_type;
    test2_data_void_in   : out std_ulogic;
    test2_stop_out       : out std_ulogic;
    test3_input_port     : out coh_noc_flit_type;
    test3_data_void_in   : out std_ulogic;
    test3_stop_out       : out std_ulogic;
    test4_input_port     : out dma_noc_flit_type;
    test4_data_void_in   : out std_ulogic;
    test4_stop_out       : out std_ulogic;
    test5_input_port     : out misc_noc_flit_type;
    test5_data_void_in   : out std_ulogic;
    test5_stop_out       : out std_ulogic;
    test6_input_port     : out dma_noc_flit_type;
    test6_data_void_in   : out std_ulogic;
    test6_stop_out       : out std_ulogic;
    mon_noc              : in  monitor_noc_vector(1 to 6);
    mon_dvfs             : out monitor_dvfs_type
    );
end;

architecture rtl of tile_io_abbrev is

  signal rst : std_ulogic;
  signal tile_clk, dco_clk, dco_clk_lock, noc_clk_out_int : std_ulogic;
  
  -- NoC DCO Signals (Driven by CSRs)
  signal dco_noc_en, dco_noc_clk_sel : std_ulogic;
  signal dco_noc_cc_sel, dco_noc_fc_sel : std_logic_vector(5 downto 0);
  signal dco_noc_div_sel : std_logic_vector(2 downto 0);
  signal dco_noc_freq_sel : std_logic_vector(1 downto 0);

  -- Bus signals
  signal noc_apbi : apb_slv_in_type;
  signal noc_apbo : apb_slv_out_vector;

  -- ESPLink
  signal init_done, srst, soft_reset : std_ulogic;

  -- Proxies / Queue Signals
  signal apb_rcv_rdreq, apb_rcv_empty : std_ulogic;
  signal apb_rcv_data_out : misc_noc_flit_type;
  
  signal apb_snd_wrreq, apb_snd_full : std_ulogic;
  signal apb_snd_data_in : misc_noc_flit_type;

  -- Dummy zero signals for unused queue ports
  signal zero_misc_flit : misc_noc_flit_type;
  signal zero_dma_flit  : dma_noc_flit_type;
  signal zero_coh_flit  : coh_noc_flit_type;

  -- Monitor
  signal mon_dvfs_int : monitor_dvfs_type;
  signal tile_config_int : std_logic_vector(ESP_CSR_WIDTH - 1 downto 0);

  -- Location Constants
  constant this_local_y : local_yx := tile_y(io_tile_id(chiplet_index));
  constant this_local_x : local_yx := tile_x(io_tile_id(chiplet_index));
  constant this_local_chip_y : chip_yx := chip_y(io_tile_id(chiplet_index));
  constant this_local_chip_x : chip_yx := chip_x(io_tile_id(chiplet_index));
  constant this_csr_pindex : integer := tile_csr_pindex(io_tile_id(0));
  constant this_csr_pconfig : apb_config_type := fixed_apbo_pconfig(this_csr_pindex);

  -- Reduced APB Map
  function set_abbrev_apb_constants return std_logic_vector is
    variable apb : std_logic_vector(0 to NAPBSLV - 1);
  begin
      apb := (others => '0');
      apb(0) := '1'; -- CSRs
      apb(4) := '1'; -- ESPLink (Soft Reset)
      return apb;
  end function set_abbrev_apb_constants;

  constant this_local_apb_en : std_logic_vector(0 to NAPBSLV - 1) := set_abbrev_apb_constants;

begin

  -- Initialize dummy signals
  zero_misc_flit <= (others => '0');
  zero_dma_flit  <= (others => '0');
  zero_coh_flit  <= (others => '0');

  -- DCO and Reset Logic
  rst_gen: if this_has_dco = 1 generate
    tile_rstn_out_inst : rstgen generic map (acthigh => 1, syncin => 0)
      port map (tile_rst, dco_clk, dco_clk_lock, rst, open);
  end generate rst_gen;

  no_rst_gen: if this_has_dco /= 1 generate
    rst <= tile_rst;
  end generate no_rst_gen;
  tile_rstn_out <= rst;

  -- NoC DCO Config (Driven by CSRs, same as original tile_io)
  dco_noc_freq_sel <= tile_config_int(ESP_CSR_DCO_NOC_CFG_MSB downto ESP_CSR_DCO_NOC_CFG_MSB - 1);
  dco_noc_div_sel  <= tile_config_int(ESP_CSR_DCO_NOC_CFG_MSB - 2 downto ESP_CSR_DCO_NOC_CFG_MSB - 4);
  dco_noc_fc_sel   <= tile_config_int(ESP_CSR_DCO_NOC_CFG_MSB - 5 downto ESP_CSR_DCO_NOC_CFG_MSB - 10);
  dco_noc_cc_sel   <= tile_config_int(ESP_CSR_DCO_NOC_CFG_MSB - 11 downto ESP_CSR_DCO_NOC_CFG_MSB - 16);
  dco_noc_clk_sel  <= tile_config_int(ESP_CSR_DCO_NOC_CFG_LSB + 1);
  dco_noc_en       <= raw_rstn and tile_config_int(ESP_CSR_DCO_NOC_CFG_LSB);

  dco_gen: if this_has_dco /= 0 generate
    -- NoC DCO
    dco_noc_i : dco generic map (tech => CFG_FABTECH, enable_div2 => 0, dlog => 8)
      port map (raw_rstn, ext_clk_noc, dco_noc_en, dco_noc_clk_sel, dco_noc_cc_sel, dco_noc_fc_sel, dco_noc_div_sel, dco_noc_freq_sel, noc_clk_out_int, clk_div_noc, noc_clk_lock);
    noc_clk_out <= noc_clk_out_int;

    -- Tile DCO (Driven by Entity Inputs/Pads, same as original tile_io)
    dco_tile_gen : if this_has_dco = 1 generate
      dco_i: dco generic map (tech => CFG_FABTECH, enable_div2 => 0, dlog => 10)
        port map (raw_rstn, ext_clk, dco_en, dco_clk_sel, dco_cc_sel, dco_fc_sel, dco_div_sel, dco_freq_sel, dco_clk, clk_div, dco_clk_lock);
      tile_clk <= dco_clk;
    end generate dco_tile_gen;
  end generate dco_gen;

  no_dco_gen: if this_has_dco = 0 generate
    clk_div <= '0'; clk_div_noc <= '0';
    tile_clk <= ext_clk; noc_clk_out <= ext_clk_noc;
    dco_clk_lock <= '1'; noc_clk_lock <= '1';
  end generate no_dco_gen;
  
  no_tile_dco_gen: if this_has_dco = 2 generate
    clk_div <= '0';
    tile_clk <= noc_clk_out_int;
    dco_clk_lock <= '1';
  end generate no_tile_dco_gen;

  tile_clk_out <= tile_clk;

  -- Disable unused APB Slaves
  no_pslv_gen : for i in 0 to NAPBSLV - 1 generate
    gen_dis: if i /= 0 and i /= 4 generate -- Keep CSR and ESPLink
       noc_apbo(i) <= apb_none;
    end generate gen_dis;
  end generate no_pslv_gen;

  -- Self Configuration (Stub - no AHB bus, so no self-config, but needed for init_done)
  init_done <= '1'; -- Assume initialized as we have no boot process here

  -- ESPLink (Soft Reset)
  soft_reset <= (not srst) and rst;
  esplink_1: esplink generic map (APB_DW => 32, APB_AW => 32, REV_ENDIAN => 0)
    port map (tile_clk, rst, srst, noc_apbi.psel(4), noc_apbi.penable, noc_apbi.pwrite, noc_apbi.paddr, noc_apbi.pwdata, open, open, noc_apbo(4).prdata);
  noc_apbo(4).pirq <= (others => '0');
  noc_apbo(4).pconfig <= fixed_apbo_pconfig(4);
  noc_apbo(4).pindex <= 4;

  -- Monitor
  mon_dvfs_int.vf <= "1000"; mon_dvfs_int.transient <= '0'; mon_dvfs_int.clk <= tile_clk;
  mon_dvfs_int.acc_idle <= '0'; mon_dvfs_int.traffic <= '0'; mon_dvfs_int.burst <= '0';
  mon_dvfs <= mon_dvfs_int;

  -- CSRs
  io_tile_csr : esp_tile_csr generic map(pindex => 0)
    port map(tile_clk, rst, this_csr_pconfig, monitor_ddr_none, monitor_mem_none, mon_noc, monitor_cache_none, monitor_cache_none, monitor_acc_none, mon_dvfs_int, tile_config_int, open, open, noc_apbi, noc_apbo(0));

  -- Tile Queues 
  -- Using Named Association to safely tie off unused ports
  misc_tile_q_abbrev_1 : misc_tile_q_abbrev
    generic map (tech => CFG_FABTECH)
    port map (
      rst => rst,
      clk => tile_clk,
      
      -- Plane 5 (Misc) - ACTIVE for Configuration
      apb_rcv_rdreq => apb_rcv_rdreq,
      apb_rcv_data_out => apb_rcv_data_out,
      apb_rcv_empty => apb_rcv_empty,
      apb_snd_wrreq => apb_snd_wrreq,
      apb_snd_data_in => apb_snd_data_in,
      apb_snd_full => apb_snd_full,

      -- Plane 5 (Active)
      noc5_out_data => test5_output_port, 
      noc5_out_void => test5_data_void_out, 
      noc5_out_stop => test5_stop_out, 
      noc5_in_data => test5_input_port, 
      noc5_in_void => test5_data_void_in, 
      noc5_in_stop => test5_stop_in
    );

  -- Tie off entity ports for unused NoC planes
  test1_input_port <= (others => '0'); test1_data_void_in <= '1'; test1_stop_out <= '0';
  test2_input_port <= (others => '0'); test2_data_void_in <= '1'; test2_stop_out <= '0';
  test3_input_port <= (others => '0'); test3_data_void_in <= '1'; test3_stop_out <= '0';
  test4_input_port <= (others => '0'); test4_data_void_in <= '1'; test4_stop_out <= '0';
  test6_input_port <= (others => '0'); test6_data_void_in <= '1'; test6_stop_out <= '0';

  -- Only need noc2apb. This allows the Main Chiplet to write to our CSRs and ESPLink.
  -- Removed apb2noc because this tile has no local masters to initiate requests.
  noc2apb_1 : noc2apb 
    generic map (
        tech => CFG_FABTECH, 
        local_apb_en => this_local_apb_en
    )
    port map (
        rst => rst, 
        clk => tile_clk, 
        local_y => this_local_y, 
        local_x => this_local_x, 
        local_chip_y => this_local_chip_y, 
        local_chip_x => this_local_chip_x, 
        apbi => noc_apbi, 
        apbo => noc_apbo, 
        pready => '1', 
        apb_snd_wrreq => apb_snd_wrreq, 
        apb_snd_data_in => apb_snd_data_in, 
        apb_snd_full => apb_snd_full, 
        apb_rcv_rdreq => apb_rcv_rdreq, 
        apb_rcv_data_out => apb_rcv_data_out, 
        apb_rcv_empty => apb_rcv_empty
    );

end;
