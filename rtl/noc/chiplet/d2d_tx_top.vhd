-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

--/*
-- * Module: router
-- * Description: 5x5 router
-- *              The router has 1 port attached to the processor and 4 ports to route
-- *              data. The routing algorithm is XY Dimension Order.
-- *              The router uses a worm-hole flow-control at network level
-- *              and an ACK/NACK flow control at link level. It can be interfaced with
-- *              single state Relay Stations.
-- *              The router implements routing look-ahead, performing routing for the following hop
-- *              and carrying the routing result into the head flit of the worm.
-- *              In case of incoming head flit directed to a free output without contention
-- *              the flit is forwarded in a single clock cycle (low load hypotesys). In all the other
-- *              scenarios the worm is forwarded in two clock cycles, resolving contentions during
-- *              the added cycle.
-- * Author: Michele Petracca
-- * $ID$
-- * 
-- Mapping:
-- 0 = North
-- 1 = South
-- 2 = West
-- 3 = East
-- 4 = Processor
-- */

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.stdlib.all;
use work.nocpackage.all;



entity d2d_tx_top is
  generic (
    TXCHANNELS    : integer := 4;
    TILES         : integer := 3;
    flow_control  : integer := 0;  --0 = AN; 1 = CB
    chwidth       : integer := 66;
    cohwidth      : integer := 66;
    miscwidth     : integer := 66;
    dmawidth      : integer := 130
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
end d2d_tx_top;

architecture rtl of d2d_tx_top is

  function int_to_std_logic(i : integer) return std_logic is
  begin
    if i = 0 then
      return '0';
    else
      return '1';
    end if;
  end function;

  component d2d_tx_wrapper
    generic (
      TXCHANNELS    : integer;
      TILES         : integer;
      FlowControl   : std_logic;
      CHDataWidth   : integer;
      COHDataWidth  : integer;
      MISCDataWidth : integer;
      DMADataWidth  : integer
    );
    port (
      clk                 : in  std_ulogic;
      rst                 : in  std_ulogic;
      d2d_clk_in          : in  std_ulogic;
  
      -- D2D Tx --> D2D Rx
      d2d_snd_data_out    : out std_logic_vector(TXCHANNELS*CHDataWidth-1 downto 0);
      d2d_valid_out       : out std_logic_vector(TXCHANNELS-1 downto 0);
  
      -- D2D Rx --> D2D Tx
      d2d_credit_in       : in  std_logic_vector(TXCHANNELS-1 downto 0);
      
      -- NoC --> D2D
      noc1_data_in        : in  std_logic_vector(TILES*COHDataWidth-1 downto 0);
      noc2_data_in        : in  std_logic_vector(TILES*COHDataWidth-1 downto 0);
      noc3_data_in        : in  std_logic_vector(TILES*COHDataWidth-1 downto 0);
      noc4_data_in        : in  std_logic_vector(TILES*DMADataWidth-1 downto 0);
      noc5_data_in        : in  std_logic_vector(TILES*MISCDataWidth-1 downto 0);
      noc6_data_in        : in  std_logic_vector(TILES*DMADataWidth-1 downto 0);
      
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
  end component;

  signal d2d_snd_data_out_arr : std_logic_vector(TXCHANNELS*chwidth-1 downto 0);
  signal noc1_data_in_arr : std_logic_vector(TILES*cohwidth-1 downto 0);
  signal noc2_data_in_arr : std_logic_vector(TILES*cohwidth-1 downto 0);
  signal noc3_data_in_arr : std_logic_vector(TILES*cohwidth-1 downto 0);
  signal noc4_data_in_arr : std_logic_vector(TILES*dmawidth-1 downto 0);
  signal noc5_data_in_arr : std_logic_vector(TILES*miscwidth-1 downto 0);
  signal noc6_data_in_arr : std_logic_vector(TILES*dmawidth-1 downto 0);

begin

  flatten_1d : for i in 0 to TILES-1 generate
    noc1_data_in_arr(cohwidth*(i+1)-1 downto cohwidth*i) <= noc1_data_in(i);
    noc2_data_in_arr(cohwidth*(i+1)-1 downto cohwidth*i) <= noc2_data_in(i);
    noc3_data_in_arr(cohwidth*(i+1)-1 downto cohwidth*i) <= noc3_data_in(i);
    noc4_data_in_arr(dmawidth*(i+1)-1 downto dmawidth*i) <= noc4_data_in(i);
    noc5_data_in_arr(miscwidth*(i+1)-1 downto miscwidth*i) <= noc5_data_in(i);
    noc6_data_in_arr(dmawidth*(i+1)-1 downto dmawidth*i) <= noc6_data_in(i);
  end generate flatten_1d;
  build_2d  : for i in 0 to TXCHANNELS-1 generate
    d2d_snd_data_out(i) <= d2d_snd_data_out_arr((i+1)*chwidth-1 downto i*chwidth);
  end generate build_2d;

  

  d2d_tx_wrapper_i: d2d_tx_wrapper
    generic map (
      TXCHANNELS        => TXCHANNELS,
      TILES             => TILES,
      FlowControl       => int_to_std_logic(flow_control),
      CHDataWidth       => chwidth,
      COHDataWidth      => cohwidth,
      MISCDataWidth     => miscwidth,
      DMADataWidth      => dmawidth
    )
    port map (
      clk               => clk,
      rst               => rst,
      d2d_clk_in        => d2d_clk_in,
      d2d_snd_data_out  => d2d_snd_data_out_arr,
      d2d_valid_out     => d2d_valid_out,
      d2d_credit_in     => d2d_credit_in,
      noc1_data_in      => noc1_data_in_arr,
      noc2_data_in      => noc2_data_in_arr,
      noc3_data_in      => noc3_data_in_arr,
      noc4_data_in      => noc4_data_in_arr,
      noc5_data_in      => noc5_data_in_arr,
      noc6_data_in      => noc6_data_in_arr,
      noc1_data_void_in => noc1_data_void_in,
      noc2_data_void_in => noc2_data_void_in,
      noc3_data_void_in => noc3_data_void_in,
      noc4_data_void_in => noc4_data_void_in,
      noc5_data_void_in => noc5_data_void_in,
      noc6_data_void_in => noc6_data_void_in,
      noc1_stop_out     => noc1_stop_out,
      noc2_stop_out     => noc2_stop_out,
      noc3_stop_out     => noc3_stop_out,
      noc4_stop_out     => noc4_stop_out,
      noc5_stop_out     => noc5_stop_out,
      noc6_stop_out     => noc6_stop_out
    );     

end rtl;
