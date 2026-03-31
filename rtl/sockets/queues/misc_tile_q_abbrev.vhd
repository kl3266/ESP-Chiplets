-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

-----------------------------------------------------------------------------
--  Abbreviated Misc Tile Queue
--  Purpose: Handles NoC Plane 5 (Misc) traffic for Configuration only.
--  Removes: DMA, AHB, IRQ, and Coherence queues.
--  Interfaces: Connects NoC Plane 5 <-> APB Bridge (noc2apb).
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.amba.all;
use work.stdlib.all;
use work.sld_devices.all;
use work.devices.all;
use work.gencomp.all;
use work.genacc.all;
use work.nocpackage.all;
use work.tile.all;

entity misc_tile_q_abbrev is
  generic (
    tech : integer := virtex7);
  port (
    rst                 : in  std_ulogic;
    clk                 : in  std_ulogic;
    -- Incoming Requests (NoC5 -> APB Bridge)
    apb_rcv_rdreq       : in  std_ulogic;
    apb_rcv_data_out    : out misc_noc_flit_type;
    apb_rcv_empty       : out std_ulogic;
    -- Outgoing Responses (APB Bridge -> NoC5)
    apb_snd_wrreq       : in  std_ulogic;
    apb_snd_data_in     : in  misc_noc_flit_type;
    apb_snd_full        : out std_ulogic;
    -- NoC Plane 5 Interface
    noc5_out_data       : in  misc_noc_flit_type;
    noc5_out_void       : in  std_ulogic;
    noc5_out_stop       : out std_ulogic;
    noc5_in_data        : out misc_noc_flit_type;
    noc5_in_void        : out std_ulogic;
    noc5_in_stop        : in  std_ulogic
  );
end misc_tile_q_abbrev;

architecture rtl of misc_tile_q_abbrev is

  signal fifo_rst : std_ulogic;

  -- Internal Queue Signals
  signal apb_rcv_wrreq   : std_ulogic;
  signal apb_rcv_data_in : misc_noc_flit_type;
  signal apb_rcv_full    : std_ulogic;

  signal apb_snd_rdreq    : std_ulogic;
  signal apb_snd_data_out : misc_noc_flit_type;
  signal apb_snd_empty    : std_ulogic;

  -- FSM States
  type noc5_packet_fsm is (none, packet_apb_rcv);
  signal noc5_fifos_current, noc5_fifos_next : noc5_packet_fsm;

  type to_noc5_packet_fsm is (none, packet_apb_snd);
  signal to_noc5_fifos_current, to_noc5_fifos_next : to_noc5_packet_fsm;

  -- Packet Parsing
  signal noc5_msg_type : noc_msg_type;
  signal noc5_preamble : noc_preamble_type;

begin

  fifo_rst <= rst;

  -----------------------------------------------------------------------------
  -- INPUT HANDLING: NoC 5 -> Tile (Configuration Requests)
  -----------------------------------------------------------------------------
  noc5_msg_type <= get_msg_type(MISC_NOC_FLIT_SIZE, misc_noc_flit_pad & noc5_out_data);
  noc5_preamble <= get_preamble(MISC_NOC_FLIT_SIZE, misc_noc_flit_pad & noc5_out_data);

  -- FSM State Register
  process (clk, rst)
  begin
    if rst = '0' then
      noc5_fifos_current <= none;
    elsif clk'event and clk = '1' then
      noc5_fifos_current <= noc5_fifos_next;
    end if;
  end process;

  -- FSM Next State Logic
  noc5_fifos_get_packet : process (noc5_out_data, noc5_out_void, noc5_msg_type,
                                   noc5_preamble, noc5_fifos_current, apb_rcv_full)
  begin
    apb_rcv_wrreq <= '0';
    apb_rcv_data_in <= noc5_out_data;
    noc5_fifos_next <= noc5_fifos_current;
    noc5_out_stop   <= '0';

    case noc5_fifos_current is
      when none =>
        if noc5_out_void = '0' then
          -- Check for Register Read/Write Request (REQ_REG_RD / REQ_REG_WR)
          if ((noc5_msg_type = REQ_REG_RD or noc5_msg_type = REQ_REG_WR) 
               and noc5_preamble = PREAMBLE_HEADER) then
            if apb_rcv_full = '0' then
              apb_rcv_wrreq   <= '1';
              noc5_fifos_next <= packet_apb_rcv;
            else
              noc5_out_stop <= '1'; -- Backpressure if queue is full
            end if;
          else
            -- If packet type is not recognized/supported (e.g., DMA/IRQ msg sent by mistake),
            -- we sink it (stop='0') so it doesn't block the NoC, but we don't write it to any queue.
            -- Effectively dropping the packet.
          end if;
        end if;

      when packet_apb_rcv =>
        -- Continue receiving body flits
        apb_rcv_wrreq <= not noc5_out_void and (not apb_rcv_full);
        noc5_out_stop <= apb_rcv_full and (not noc5_out_void);
        
        if (noc5_preamble = PREAMBLE_TAIL and noc5_out_void = '0' and apb_rcv_full = '0') then
          noc5_fifos_next <= none;
        end if;

      when others =>
        noc5_fifos_next <= none;
    end case;
  end process noc5_fifos_get_packet;

  -- APB Receive Queue (NoC -> Bridge)
  fifo_7 : fifo0
    generic map (
      depth => 3,
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => apb_rcv_rdreq,
      wrreq    => apb_rcv_wrreq,
      data_in  => apb_rcv_data_in,
      empty    => apb_rcv_empty,
      full     => apb_rcv_full,
      data_out => apb_rcv_data_out);

  -----------------------------------------------------------------------------
  -- OUTPUT HANDLING: Tile -> NoC 5 (Configuration Responses)
  -----------------------------------------------------------------------------
  
  -- FSM State Register
  process (clk, rst)
  begin
    if rst = '0' then
      to_noc5_fifos_current <= none;
    elsif clk'event and clk = '1' then
      to_noc5_fifos_current <= to_noc5_fifos_next;
    end if;
  end process;

  -- FSM Next State Logic
  to_noc5_select_packet : process (noc5_in_stop, to_noc5_fifos_current,
                                   apb_snd_data_out, apb_snd_empty)
    variable to_noc5_preamble : noc_preamble_type;
  begin
    noc5_in_data      <= (others => '0');
    noc5_in_void      <= '1';
    apb_snd_rdreq     <= '0';
    to_noc5_fifos_next <= to_noc5_fifos_current;
    to_noc5_preamble   := "00"; -- Default

    case to_noc5_fifos_current is
      when none =>
        -- Check if APB bridge has a response to send
        if apb_snd_empty = '0' then
          noc5_in_data <= apb_snd_data_out;
          if noc5_in_stop = '0' then
            noc5_in_void       <= '0'; -- Valid
            apb_snd_rdreq      <= '1';
            to_noc5_fifos_next <= packet_apb_snd;
          end if;
        end if;

      when packet_apb_snd =>
        to_noc5_preamble := get_preamble(MISC_NOC_FLIT_SIZE, misc_noc_flit_pad & apb_snd_data_out);
        if (noc5_in_stop = '0' and apb_snd_empty = '0') then
          noc5_in_data  <= apb_snd_data_out;
          noc5_in_void  <= '0';
          apb_snd_rdreq <= '1';
          if to_noc5_preamble = PREAMBLE_TAIL then
            to_noc5_fifos_next <= none;
          end if;
        end if;

      when others =>
        to_noc5_fifos_next <= none;
    end case;
  end process to_noc5_select_packet;

  -- APB Send Queue (Bridge -> NoC)
  fifo_10 : fifo0
    generic map (
      depth => 2,
      width => MISC_NOC_FLIT_SIZE)
    port map (
      clk      => clk,
      rst      => fifo_rst,
      rdreq    => apb_snd_rdreq,
      wrreq    => apb_snd_wrreq,
      data_in  => apb_snd_data_in,
      empty    => apb_snd_empty,
      full     => apb_snd_full,
      data_out => apb_snd_data_out);

end rtl;