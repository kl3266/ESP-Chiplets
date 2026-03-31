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



entity d2d_rx_top is
  generic (
    d2d_position      : std_logic_vector(1 downto 0)                          := (others => '0'); -- 0 N; 1 S; 2 W; 3 E
    local_chip_y      : chip_yx                                               := (others => '0');
    local_chip_x      : chip_yx                                               := (others => '0');
    max_dim           : local_yx                                              := "0010";
    RXCHANNELS        : integer                                               := 4;
    TILES             : integer                                               := 3;
    flow_control      : integer                                               := 0;
    chwidth           : integer                                               := 66;
    cohwidth          : integer                                               := 66;
    miscwidth         : integer                                               := 66;
    dmawidth          : integer                                               := 130
  );
  port (
    clk               : in  std_ulogic;
    rst               : in  std_ulogic;
    d2d_rst           : in  std_ulogic;

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
end d2d_rx_top;

architecture rtl of d2d_rx_top is

  function int_to_std_logic(i : integer) return std_logic is
  begin
    if i = 0 then
      return '0';
    else
      return '1';
    end if;
  end function;

  component d2d_rx_wrapper
    generic (
      d2d_position      : std_logic_vector(1 downto 0); -- 0 N; 1 S; 2 E; 3 W
      local_chip_y      : chip_yx;
      local_chip_x      : chip_yx;
      max_dim           : local_yx;
      RXCHANNELS        : integer;
      TILES             : integer;
      FlowControl       : std_logic;
      CHDataWidth       : integer;
      COHDataWidth      : integer;
      MISCDataWidth     : integer;
      DMADataWidth      : integer
    );
    port (
      clk               : in  std_ulogic;
      rst               : in  std_ulogic;
      d2d_rst           : in  std_ulogic;
  
      -- D2D Tx --> D2D Rx
      d2d_clk_in        : in  std_ulogic;
      d2d_rcv_data_in   : in  std_logic_vector(RXCHANNELS*CHDataWidth-1 downto 0);
      d2d_valid_in      : in  std_logic_vector(RXCHANNELS-1 downto 0);
      d2d_link_ready    : out std_logic;
  
      -- D2D Rx --> D2D Tx
      d2d_credit_out    : out std_logic_vector(RXCHANNELS-1 downto 0);
      
      -- D2D --> NoC
      noc1_data_out     : out std_logic_vector(TILES*COHDataWidth-1 downto 0);
      noc2_data_out     : out std_logic_vector(TILES*COHDataWidth-1 downto 0);
      noc3_data_out     : out std_logic_vector(TILES*COHDataWidth-1 downto 0);     
      noc4_data_out     : out std_logic_vector(TILES*DMADataWidth-1 downto 0);     
      noc5_data_out     : out std_logic_vector(TILES*MISCDataWidth-1 downto 0);     
      noc6_data_out     : out std_logic_vector(TILES*DMADataWidth-1 downto 0);
      bypass_data_out   : out std_logic_vector(CHDataWidth-1 downto 0);
      
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
  end component;

  signal noc1_data_out_arr : std_logic_vector(TILES*COH_NOC_FLIT_SIZE-1 downto 0);
  signal noc2_data_out_arr : std_logic_vector(TILES*COH_NOC_FLIT_SIZE-1 downto 0);
  signal noc3_data_out_arr : std_logic_vector(TILES*COH_NOC_FLIT_SIZE-1 downto 0);
  signal noc4_data_out_arr : std_logic_vector(TILES*DMA_NOC_FLIT_SIZE-1 downto 0);
  signal noc5_data_out_arr : std_logic_vector(TILES*MISC_NOC_FLIT_SIZE-1 downto 0);
  signal noc6_data_out_arr : std_logic_vector(TILES*DMA_NOC_FLIT_SIZE-1 downto 0);
  signal d2d_rcv_data_in_arr : std_logic_vector(RXCHANNELS*COH_NOC_FLIT_SIZE-1 downto 0);

begin

  flatten_1d : for i in 0 to RXCHANNELS-1 generate
    d2d_rcv_data_in_arr((i+1)*COH_NOC_FLIT_SIZE-1 downto i*COH_NOC_FLIT_SIZE) <= d2d_rcv_data_in(i);
  end generate flatten_1d;
  build_2d : for i in 0 to TILES-1 generate
    noc1_data_out(i) <= noc1_data_out_arr((i+1)*COH_NOC_FLIT_SIZE-1 downto i*COH_NOC_FLIT_SIZE);
    noc2_data_out(i) <= noc2_data_out_arr((i+1)*COH_NOC_FLIT_SIZE-1 downto i*COH_NOC_FLIT_SIZE);
    noc3_data_out(i) <= noc3_data_out_arr((i+1)*COH_NOC_FLIT_SIZE-1 downto i*COH_NOC_FLIT_SIZE);
    noc4_data_out(i) <= noc4_data_out_arr((i+1)*DMA_NOC_FLIT_SIZE-1 downto i*DMA_NOC_FLIT_SIZE);
    noc5_data_out(i) <= noc5_data_out_arr((i+1)*MISC_NOC_FLIT_SIZE-1 downto i*MISC_NOC_FLIT_SIZE);
    noc6_data_out(i) <= noc6_data_out_arr((i+1)*DMA_NOC_FLIT_SIZE-1 downto i*DMA_NOC_FLIT_SIZE);
  end generate build_2d;

  d2d_rx_wrapper_i: d2d_rx_wrapper
    generic map (
      d2d_position    => d2d_position,
      local_chip_y    => local_chip_y,
      local_chip_x    => local_chip_x,
      max_dim         => max_dim,
      RXCHANNELS      => RXCHANNELS,
      TILES           => TILES,
      FlowControl     => int_to_std_logic(flow_control),
      CHDataWidth     => chwidth,
      COHDataWidth    => cohwidth,
      MISCDataWidth   => miscwidth,
      DMADataWidth    => dmawidth
    )
    port map (
      clk                 => clk,
      rst                 => rst,
      d2d_rst             => d2d_rst,
      d2d_clk_in          => d2d_clk_in,
      d2d_rcv_data_in     => d2d_rcv_data_in_arr,
      d2d_valid_in        => d2d_valid_in,
      d2d_link_ready      => d2d_link_ready,
      d2d_credit_out      => d2d_credit_out,
      noc1_data_out       => noc1_data_out_arr,
      noc2_data_out       => noc2_data_out_arr,
      noc3_data_out       => noc3_data_out_arr,
      noc4_data_out       => noc4_data_out_arr,
      noc5_data_out       => noc5_data_out_arr,
      noc6_data_out       => noc6_data_out_arr,
      bypass_data_out     => bypass_data_out,
      noc1_data_void_out  => noc1_data_void_out,
      noc2_data_void_out  => noc2_data_void_out,
      noc3_data_void_out  => noc3_data_void_out,
      noc4_data_void_out  => noc4_data_void_out,
      noc5_data_void_out  => noc5_data_void_out,
      noc6_data_void_out  => noc6_data_void_out,
      bypass_data_void_out  => bypass_data_void_out,
      noc1_stop_in        => noc1_stop_in,
      noc2_stop_in        => noc2_stop_in,
      noc3_stop_in        => noc3_stop_in,
      noc4_stop_in        => noc4_stop_in,
      noc5_stop_in        => noc5_stop_in,
      noc6_stop_in        => noc6_stop_in,
      bypass_stop_in      => bypass_stop_in
    );     

end rtl;
