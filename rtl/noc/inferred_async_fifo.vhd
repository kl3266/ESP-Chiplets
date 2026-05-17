-- Copyright (c) 2011 CERN
-- SPDX-License-Identifier: LGPL-3.0-only

-------------------------------------------------------------------------------
-- Title      : Parametrizable asynchronous FIFO (Generic version)
-- Project    : Generics RAMs and FIFOs collection
-------------------------------------------------------------------------------
-- File       : generic_async_fifo.vhd
-- Author     : Tomasz Wlostowski
-- Company    : CERN BE-CO-HT
-- Created    : 2011-01-25
-- Last update: 2019-04-03
-- Platform   :
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Dual-clock asynchronous FIFO.
-- - configurable data width and size
-- - configurable full/empty/almost full/almost empty/word count signals
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2011-01-25  1.0      twlostow        Created
-- 2015-01-22  1.0.1    pmantovani      Adapted for ESP NoC (Columbia University)
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.genram_pkg.all;

entity inferred_async_fifo is

  generic (
    g_data_width : natural := 32;
    g_size       : natural := 8
    );

  port (
    -- write port
    rst_wr_n_i   : in std_logic := '1';
    clk_wr_i     : in std_logic;
    we_i         : in std_logic;
    d_i          : in std_logic_vector(g_data_width-1 downto 0);
    wr_full_o    : out std_logic;

    -- read port
    rst_rd_n_i   : in  std_logic := '1';
    clk_rd_i     : in  std_logic;
    rd_i         : in  std_logic;
    q_o          : out std_logic_vector(g_data_width-1 downto 0);
    rd_empty_o   : out std_logic
    );

end inferred_async_fifo;


architecture syn of inferred_async_fifo is

  function f_bin2gray(bin : unsigned) return unsigned is
  begin
    return bin(bin'left) & (bin(bin'left-1 downto 0) xor bin(bin'left downto 1));
  end f_bin2gray;

  function f_gray2bin(gray : unsigned) return unsigned is
    variable bin : unsigned(gray'left downto 0);
  begin
    -- gray to binary
    for i in 0 to gray'left loop
      bin(i) := '0';
      for j in i to gray'left loop
        bin(i) := bin(i) xor gray(j);
      end loop;  -- j
    end loop;  -- i
    return bin;
  end f_gray2bin;

  subtype t_counter is unsigned(f_log2_size(g_size) downto 0);

  type t_counter_block is record
    bin, bin_next, gray, gray_next : t_counter;
    bin_x                          : t_counter;
  end record;

  type   t_mem_type is array (0 to g_size-1) of std_logic_vector(g_data_width-1 downto 0);
  signal mem : t_mem_type;

  signal rcb, wcb                          : t_counter_block;
  signal rcb_gray_x, rcb_gray_xm           : t_counter;
  signal wcb_gray_x, wcb_gray_xm           : t_counter;

  attribute ASYNC_REG : string;
--  attribute ASYNC_REG of wcb: signal is "TRUE";
--  attribute ASYNC_REG of rcb: signal is "TRUE";
  attribute ASYNC_REG of rcb_gray_xm, rcb_gray_x : signal is "TRUE";
  attribute ASYNC_REG of wcb_gray_xm, wcb_gray_x : signal is "TRUE";

  signal full_int, empty_int               : std_logic;
  signal going_full                        : std_logic;

  signal wr_count, rd_count : t_counter;
  signal rd_int, we_int : std_logic;

--  signal wr_empty_xm, wr_empty_x : std_logic;
--  signal rd_full_xm, rd_full_x   : std_logic;

begin  -- syn

  rd_int <= rd_i and not empty_int;
  we_int <= we_i and not full_int;

  p_mem_write : process(clk_wr_i)
  begin
    if rising_edge(clk_wr_i) then
      if(we_int = '1') then
        mem(to_integer(wcb.bin(wcb.bin'left-1 downto 0))) <= d_i;
      end if;
    end if;
  end process;

  q_o <= mem(to_integer(rcb.bin(rcb.bin'left-1 downto 0)));

  wcb.bin_next  <= wcb.bin + 1;
  wcb.gray_next <= f_bin2gray(wcb.bin_next);

  p_write_ptr : process(clk_wr_i, rst_wr_n_i)
  begin
    if rst_wr_n_i = '0' then
      wcb.bin  <= (others => '0');
      wcb.gray <= (others => '0');
    elsif rising_edge(clk_wr_i) then
      if(we_int = '1') then
        wcb.bin  <= wcb.bin_next;
        wcb.gray <= wcb.gray_next;
      end if;
    end if;
  end process;

  rcb.bin_next  <= rcb.bin + 1;
  rcb.gray_next <= f_bin2gray(rcb.bin_next);

  p_read_ptr : process(clk_rd_i, rst_rd_n_i)
  begin
    if rst_rd_n_i = '0' then
      rcb.bin  <= (others => '0');
      rcb.gray <= (others => '0');
    elsif rising_edge(clk_rd_i) then
      if(rd_int = '1') then
        rcb.bin  <= rcb.bin_next;
        rcb.gray <= rcb.gray_next;
      end if;
    end if;
  end process;

  p_sync_read_ptr : process(clk_wr_i)
  begin
    if rising_edge(clk_wr_i) then
      rcb_gray_xm <= rcb.gray;
      rcb_gray_x  <= rcb_gray_xm;
    end if;
  end process;


  p_sync_write_ptr : process(clk_rd_i)
  begin
    if rising_edge(clk_rd_i) then
      wcb_gray_xm <= wcb.gray;
      wcb_gray_x  <= wcb_gray_xm;
    end if;
  end process;

  wcb.bin_x <= f_gray2bin(wcb_gray_x);
  rcb.bin_x <= f_gray2bin(rcb_gray_x);

  p_gen_empty : process(clk_rd_i, rst_rd_n_i)
  begin
    if rst_rd_n_i = '0' then
      empty_int <= '1';
    elsif rising_edge (clk_rd_i) then
      if(rcb.gray = wcb_gray_x or (rd_int = '1' and (wcb_gray_x = rcb.gray_next))) then
        empty_int <= '1';
      else
        empty_int <= '0';
      end if;
    end if;
  end process;

  rd_empty_o <= empty_int;

--  p_sync_empty : process(clk_wr_i)
--  begin
--    if rising_edge(clk_wr_i) then
--      wr_empty_xm <= empty_int;
--      wr_empty_x  <= wr_empty_xm;
--    end if;
--  end process;

  p_gen_going_full : process(we_int, wcb, rcb)
  begin
    if ((wcb.bin (wcb.bin'left-1 downto 0) = rcb.bin_x(rcb.bin_x'left-1 downto 0))
        and (wcb.bin(wcb.bin'left) /= rcb.bin_x(rcb.bin_x'left))) then
      going_full <= '1';
    elsif (we_int = '1'
           and (wcb.bin_next(wcb.bin'left-1 downto 0) = rcb.bin_x(rcb.bin_x'left-1 downto 0))
           and (wcb.bin_next(wcb.bin'left) /= rcb.bin_x(rcb.bin_x'left))) then
      going_full <= '1';
    else
      going_full <= '0';
    end if;
  end process;

  p_register_full : process(clk_wr_i, rst_wr_n_i)
  begin
    if rst_wr_n_i = '0' then
      full_int <= '0';
    elsif rising_edge (clk_wr_i) then
      full_int <= going_full;
    end if;
  end process;

--  p_sync_full : process(clk_rd_i)
--  begin
--    if rising_edge(clk_rd_i) then
--      rd_full_xm <= full_int;
--      rd_full_x  <= rd_full_xm;
--    end if;
--  end process p_sync_full;

  wr_full_o <= full_int;


end syn;

-- library ieee;
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
--
-- entity inferred_async_fifo is
--   generic (
--     g_data_width : positive := 32;
--     g_size       : positive := 12 -- Usable capacity is g_size - 1. MUST BE EVEN.
--   );
--   port (
--     -- Write Domain
--     rst_wr_n_i : in  std_logic;
--     clk_wr_i   : in  std_logic;
--     we_i       : in  std_logic;
--     d_i        : in  std_logic_vector(g_data_width-1 downto 0);
--     wr_full_o  : out std_logic;
--
--     -- Read Domain
--     rst_rd_n_i : in  std_logic;
--     clk_rd_i   : in  std_logic;
--     rd_i       : in  std_logic;
--     q_o        : out std_logic_vector(g_data_width-1 downto 0);
--     rd_empty_o : out std_logic
--   );
-- end inferred_async_fifo;
--
-- architecture rtl of inferred_async_fifo is

--   -- =========================================================================
--   -- 1. Helper Functions
--   -- =========================================================================
--   function f_log2_ceil(val : natural) return natural is
--     variable temp : natural := val;
--     variable res  : natural := 0;
--   begin
--     if temp <= 1 then return 0; end if;
--     temp := temp - 1;
--     while temp > 0 loop
--       temp := temp / 2;
--       res  := res + 1;
--     end loop;
--     return res;
--   end function;

--   constant c_ptr_width  : natural := f_log2_ceil(g_size);
  
--   -- Modulo-Gray Offset Calculation
--   -- Centers the Gray codes in the power-of-2 range to ensure Hamming Dist = 1 at wrap.
--   constant c_max_seq    : natural := 2**c_ptr_width;
--   constant c_offset     : natural := (c_max_seq - g_size) / 2;
--   constant c_offset_u   : unsigned(c_ptr_width-1 downto 0) := to_unsigned(c_offset, c_ptr_width);
--   constant c_depth_u    : unsigned(c_ptr_width-1 downto 0) := to_unsigned(g_size-1, c_ptr_width);

--   -- Gray Encoders/Decoders
--   function f_bin2gray(bin : unsigned) return unsigned is
--   begin
--     return bin xor shift_right(bin, 1);
--   end f_bin2gray;

--   function f_gray2bin(gray : unsigned) return unsigned is
--     variable bin : unsigned(gray'range);
--   begin
--     bin(bin'left) := gray(gray'left);
--     for i in gray'left-1 downto 0 loop
--       bin(i) := bin(i+1) xor gray(i);
--     end loop;
--     return bin;
--   end f_gray2bin;

--   -- Reset Gray Value: Logical '0' is Physical 'Offset'
--   constant c_reset_gray_val : unsigned(c_ptr_width-1 downto 0) 
--            := f_bin2gray(c_offset_u);

--   -- =========================================================================
--   -- 2. Signals (Initialized to prevent 'U' propagation in Sim)
--   -- =========================================================================
--   type t_mem is array (0 to g_size-1) of std_logic_vector(g_data_width-1 downto 0);
--   signal mem : t_mem := (others => (others => '0'));

--   -- Write Domain
--   signal wr_bin       : unsigned(c_ptr_width-1 downto 0) := (others => '0');
--   signal wr_bin_next  : unsigned(c_ptr_width-1 downto 0) := (others => '0');
--   signal wr_bin_plus1 : unsigned(c_ptr_width-1 downto 0) := (others => '0');
--   signal wr_gray      : unsigned(c_ptr_width-1 downto 0) := c_reset_gray_val;
--   signal wr_gray_next : unsigned(c_ptr_width-1 downto 0) := c_reset_gray_val;
--   signal wr_full_int  : std_logic := '0';
--   signal wr_en        : std_logic := '0';

--   -- Read Domain
--   signal rd_bin       : unsigned(c_ptr_width-1 downto 0) := (others => '0');
--   signal rd_bin_next  : unsigned(c_ptr_width-1 downto 0) := (others => '0');
--   signal rd_gray      : unsigned(c_ptr_width-1 downto 0) := c_reset_gray_val;
--   signal rd_gray_next : unsigned(c_ptr_width-1 downto 0) := c_reset_gray_val;
--   signal rd_empty_int : std_logic := '1';
--   signal rd_en        : std_logic := '0';

--   -- CDC Synchronizers (Initialize to SAFE Offset)
--   signal wr_gray_meta, wr_gray_sync : unsigned(c_ptr_width-1 downto 0) := c_reset_gray_val;
--   signal rd_gray_meta, rd_gray_sync : unsigned(c_ptr_width-1 downto 0) := c_reset_gray_val;

--   -- Registered Binary Pointers (Pipeline stage for glitch removal)
--   signal wr_bin_synced : unsigned(c_ptr_width-1 downto 0) := (others => '0');
--   signal rd_bin_synced : unsigned(c_ptr_width-1 downto 0) := (others => '0');

--   -- Synthesis Attributes
--   attribute ASYNC_REG : string;
--   attribute ASYNC_REG of wr_gray_meta : signal is "TRUE";
--   attribute ASYNC_REG of wr_gray_sync : signal is "TRUE";
--   attribute ASYNC_REG of rd_gray_meta : signal is "TRUE";
--   attribute ASYNC_REG of rd_gray_sync : signal is "TRUE";

-- begin

--   -- Safety Checks
--   assert (g_size mod 2 = 0) report "g_size must be EVEN" severity failure;
--   assert (g_size >= 2) report "g_size must be >= 2" severity failure;

--   -- =========================================================================
--   -- WRITE DOMAIN
--   -- =========================================================================
  
--   -- Look-ahead for Next Pointer (Modulo Depth)
--   process(wr_bin)
--   begin
--     if wr_bin = c_depth_u then
--       wr_bin_plus1 <= (others => '0');
--     else
--       wr_bin_plus1 <= wr_bin + 1;
--     end if;
--   end process;

--   -- Full Logic: Uses REGISTERED rd_bin_synced (Glitch Free)
--   -- If (Next Write == Synced Read), we stop. Leaves 1 slot empty.
--   wr_full_int <= '1' when (wr_bin_plus1 = rd_bin_synced) else '0';
--   wr_full_o   <= wr_full_int;
  
--   wr_en <= we_i and not wr_full_int;

--   -- Next State Logic
--   wr_bin_next  <= wr_bin_plus1 when wr_en = '1' else wr_bin;
--   wr_gray_next <= f_bin2gray(wr_bin_next + c_offset_u);

--   -- Registers
--   process(clk_wr_i, rst_wr_n_i)
--     variable v_rd_bin_raw : unsigned(c_ptr_width-1 downto 0);
--   begin
--     if rst_wr_n_i = '0' then
--       wr_bin  <= (others => '0');
--       wr_gray <= c_reset_gray_val;
      
--       rd_gray_meta <= c_reset_gray_val;
--       rd_gray_sync <= c_reset_gray_val;
--       rd_bin_synced <= (others => '0'); -- Reset to Bin(0)

--     elsif rising_edge(clk_wr_i) then
--       -- 1. Update Pointers
--       wr_bin  <= wr_bin_next;
--       wr_gray <= wr_gray_next;
      
--       -- 2. Write Memory
--       if wr_en = '1' then
--         mem(to_integer(wr_bin)) <= d_i;
--       end if;

--       -- 3. Sync Read Pointer (2-stage FF)
--       rd_gray_meta <= rd_gray;
--       rd_gray_sync <= rd_gray_meta;

--       -- 4. Pipeline the Decoder (Critical Glitch Fix)
--       -- This register stage isolates combinational XOR glitches from the Full logic
--       v_rd_bin_raw := f_gray2bin(rd_gray_sync);
      
--       -- Clamp logic prevents underflow if SEU/Init glitch occurs
--       if v_rd_bin_raw < c_offset_u then
--          rd_bin_synced <= (others => '0'); 
--       else
--          rd_bin_synced <= v_rd_bin_raw - c_offset_u;
--       end if;
--     end if;
--   end process;


--   -- =========================================================================
--   -- READ DOMAIN
--   -- =========================================================================

--   -- Empty Logic: Uses REGISTERED wr_bin_synced (Glitch Free)
--   rd_empty_int <= '1' when (rd_bin = wr_bin_synced) else '0';
--   rd_empty_o   <= rd_empty_int;
  
--   rd_en <= rd_i and not rd_empty_int;

--   -- Next State Logic
--   process(rd_bin, rd_en)
--   begin
--     if rd_en = '1' then
--       if rd_bin = c_depth_u then
--         rd_bin_next <= (others => '0');
--       else
--         rd_bin_next <= rd_bin + 1;
--       end if;
--     else
--       rd_bin_next <= rd_bin;
--     end if;
--   end process;
  
--   rd_gray_next <= f_bin2gray(rd_bin_next + c_offset_u);

--   -- Registers
--   process(clk_rd_i, rst_rd_n_i)
--     variable v_wr_bin_raw : unsigned(c_ptr_width-1 downto 0);
--   begin
--     if rst_rd_n_i = '0' then
--       rd_bin  <= (others => '0');
--       rd_gray <= c_reset_gray_val;

--       wr_gray_meta <= c_reset_gray_val;
--       wr_gray_sync <= c_reset_gray_val;
--       wr_bin_synced <= (others => '0'); -- Reset to Bin(0)

--     elsif rising_edge(clk_rd_i) then
--       -- 1. Update Pointers
--       rd_bin  <= rd_bin_next;
--       rd_gray <= rd_gray_next;

--       -- 2. Sync Write Pointer (2-stage FF)
--       wr_gray_meta <= wr_gray;
--       wr_gray_sync <= wr_gray_meta;

--       -- 3. Pipeline the Decoder (Critical Glitch Fix)
--       v_wr_bin_raw := f_gray2bin(wr_gray_sync);
      
--       if v_wr_bin_raw < c_offset_u then
--          wr_bin_synced <= (others => '0');
--       else
--          wr_bin_synced <= v_wr_bin_raw - c_offset_u;
--       end if;
--     end if;
--   end process;

--   -- Async Read (Distributed RAM Inference)
--   q_o <= mem(to_integer(rd_bin));

-- end rtl;

-- ==============================================================================
-- Module: inferred_async_fifo
-- Description: A robust, arbitrary-depth Asynchronous FIFO with First-Word 
--              Fall-Through (FWFT) read semantics.
--              Capacity is EXACTLY g_size (RAM is g_size-1, FWFT Reg is 1).
-- ==============================================================================
--
-- ==============================================================================
-- Module: inferred_async_fifo
-- Description: A robust, arbitrary-depth Asynchronous FIFO with First-Word 
--              Fall-Through (FWFT) read semantics.
--              Capacity is EXACTLY g_size (RAM is g_size-1, FWFT Reg is 1).
-- ==============================================================================

-- library ieee;
-- use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
--
-- entity inferred_async_fifo is
--   generic (
--     g_data_width : positive := 32;
--     g_size       : positive := 16  -- Exact usable capacity from write to read
--   );
--   port (
--     -- Write Domain
--     rst_wr_n_i : in  std_logic;
--     clk_wr_i   : in  std_logic;
--     we_i       : in  std_logic;
--     d_i        : in  std_logic_vector(g_data_width-1 downto 0);
--     wr_full_o  : out std_logic;
--
--     -- Read Domain
--     rst_rd_n_i : in  std_logic;
--     clk_rd_i   : in  std_logic;
--     rd_i       : in  std_logic; -- Acknowledges current data, pops next
--     q_o        : out std_logic_vector(g_data_width-1 downto 0);
--     rd_empty_o : out std_logic
--   );
-- end inferred_async_fifo;
--
-- architecture rtl of inferred_async_fifo is
--
--   -- =========================================================================
--   -- 1. Helper Functions
--   -- =========================================================================
--   function f_log2_ceil(val : natural) return natural is
--     variable temp : natural := val;
--     variable res  : natural := 0;
--   begin
--     if temp <= 1 then return 0; end if;
--     temp := temp - 1;
--     while temp > 0 loop
--       temp := temp / 2;
--       res  := res + 1;
--     end loop;
--     return res;
--   end function;
--
--   function f_bin2gray(bin : unsigned) return unsigned is
--   begin
--     return bin xor shift_right(bin, 1);
--   end function;
--
--   function f_gray_full_cmp(gray : unsigned) return unsigned is
--     variable cmp : unsigned(gray'range);
--   begin
--     cmp := gray;
--     cmp(gray'left)   := not gray(gray'left);
--     cmp(gray'left-1) := not gray(gray'left-1);
--     return cmp;
--   end function;
--
--   function f_is_pow2(n : natural) return boolean is
--     variable v : natural := n;
--   begin
--     if v = 0 then
--       return false;
--     end if;
--     while (v mod 2) = 0 loop
--       v := v / 2;
--     end loop;
--     return (v = 1);
--   end function;
--
--   -- =========================================================================
--   -- 2. Pointer Geometry
--   -- =========================================================================
--   constant c_addr_bits : natural := f_log2_ceil(g_size);
--   subtype t_ptr is unsigned(c_addr_bits downto 0);
--
--   -- =========================================================================
--   -- 3. Storage
--   -- =========================================================================
--   type t_mem is array (0 to g_size-1) of std_logic_vector(g_data_width-1 downto 0);
--   signal mem : t_mem := (others => (others => '0'));
--
--   -- =========================================================================
--   -- 4. Signals
--   -- =========================================================================
--
--   signal wbin, wbin_next : t_ptr := (others => '0');
--   signal rbin, rbin_next : t_ptr := (others => '0');
--   signal wgray, wgray_next : t_ptr := (others => '0');
--   signal rgray, rgray_next : t_ptr := (others => '0');
--
--   signal rgray_w1, rgray_w2 : t_ptr := (others => '0');
--   signal wgray_r1, wgray_r2 : t_ptr := (others => '0');
--
--   signal full_int : std_logic := '0';
--   signal empty_int : std_logic := '1';
--   signal wfull_next, rempty_next : std_logic := '0';
--   signal we_int, rd_int : std_logic := '0';
--
--   -- Synthesis Attributes
--   attribute ASYNC_REG : string;
--   attribute SHREG_EXTRACT : string;
--   attribute ASYNC_REG of rgray_w1 : signal is "TRUE";
--   attribute ASYNC_REG of rgray_w2 : signal is "TRUE";
--   attribute ASYNC_REG of wgray_r1 : signal is "TRUE";
--   attribute ASYNC_REG of wgray_r2 : signal is "TRUE";
--   attribute SHREG_EXTRACT of rgray_w1, rgray_w2, wgray_r1, wgray_r2 : signal is "NO";
--
-- begin
--
--   assert (g_size >= 2) report "inferred_async_fifo: g_size must be >= 2" severity failure;
--   assert f_is_pow2(g_size) report "inferred_async_fifo: g_size must be power-of-two" severity failure;
--
--   we_int <= we_i and not full_int;
--   rd_int <= rd_i and not empty_int;
--
--   wbin_next  <= wbin + 1 when we_int = '1' else wbin;
--   wgray_next <= f_bin2gray(wbin_next);
--
--   rbin_next  <= rbin + 1 when rd_int = '1' else rbin;
--   rgray_next <= f_bin2gray(rbin_next);
--
--   wfull_next  <= '1' when (wgray_next = (not rgray_w2(rgray_w2'left) &
--						not rgray_w2(rgray_w2'left-1) &
--							rgray_w2(rgray_w2'left-2 downto 0))) else '0';
--   rempty_next <= '1' when (rgray_next = wgray_r2) else '0';
--
--   p_mem_write : process(clk_wr_i)
--   begin
--     if rising_edge(clk_wr_i) then
--       if we_int = '1' then
--         mem(to_integer(wbin(c_addr_bits-1 downto 0))) <= d_i;
--       end if;
--     end if;
--   end process;
--
--   p_write_domain : process(clk_wr_i, rst_wr_n_i)
--   begin
--     if rst_wr_n_i = '0' then
--       wbin <= (others => '0');
--       wgray <= (others => '0');
----       rgray_w1 <= (others => '0');
----       rgray_w2 <= (others => '0');
--       full_int <= '0';
--     elsif rising_edge(clk_wr_i) then
--       wbin <= wbin_next;
--       wgray <= wgray_next;
--       rgray_w1 <= rgray;
--       rgray_w2 <= rgray_w1;
--       full_int <= wfull_next;
--     end if;
--   end process;
--
--   p_read_domain : process(clk_rd_i, rst_rd_n_i)
--   begin
--     if rst_rd_n_i = '0' then
--       rbin <= (others => '0');
--       rgray <= (others => '0');
----       wgray_r1 <= (others => '0');
----       wgray_r2 <= (others => '0');
--       empty_int <= '1';
--     elsif rising_edge(clk_rd_i) then
--       rbin <= rbin_next;
--       rgray <= rgray_next;
--       wgray_r1 <= wgray;
--       wgray_r2 <= wgray_r1;
--       empty_int <= rempty_next;
--     end if;
--   end process;
--
--   q_o <= mem(to_integer(rbin(c_addr_bits-1 downto 0)));
--   wr_full_o <= full_int;
--   rd_empty_o <= empty_int;
--
-- end rtl;
