-- Copyright (c) 2011-2024 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.esp_global.all;
use work.nocpackage.all;

library unisim;
use unisim.VCOMPONENTS.all;

entity d2d_cable_frontend is
  generic (
    CLKIN_PERIOD_NS   : real;
    REF_JITTER1_UI    : real;
    PHASE_DEG         : real;
    CREDIT_CDC_N      : integer := 3;
    TX_ON_UPPER_PINS  : boolean := true;
    LINK_ACTIVE       : boolean := true
  );
  port (
    d2d_clk_int               : in    std_ulogic;
    d2d_rst                   : in    std_ulogic;
    d2d_rstn                  : in    std_ulogic;
    d2d_rstn_d2d              : in    std_ulogic;
    cable_clk_p               : out   std_logic;
    cable_clk_n               : out   std_logic;
    cable_clk_p_rcv           : in    std_logic;
    cable_clk_n_rcv           : in    std_logic;
    cable_io_data             : inout std_logic_vector(135 downto 0);
    d2d_data_tx               : in    std_logic_vector(67 downto 0);
    d2d_data_tx_io_dbg        : out   std_logic_vector(67 downto 0);
    d2d_data_rx_pipe          : out   std_logic_vector(67 downto 0);
    cable_clk_rcv_raw         : out   std_ulogic;
    cable_clk_rcv_core        : out   std_ulogic;
    d2d_rx_mmcm_locked        : out   std_ulogic;
    rx_run                    : out   std_ulogic;
    rx_core_run               : out   std_ulogic;
    credit_in_evt_pulse_d2d   : out   std_logic
  );
end entity d2d_cable_frontend;

architecture rtl of d2d_cable_frontend is
  component cdc_gray_pulse is
    generic (
      N : integer := 4
    );
    port (
      src_clk   : in  std_logic;
      dst_clk   : in  std_logic;
      src_rstn  : in  std_logic;
      dst_rstn  : in  std_logic;
      src_pulse : in  std_logic;
      dst_pulse : out std_logic
    );
  end component cdc_gray_pulse;

  signal d2d_data_tx_pipe_i   : std_logic_vector(67 downto 0);
  signal d2d_data_tx_io_i     : std_logic_vector(67 downto 0);
  signal d2d_data_rx_io_i     : std_logic_vector(67 downto 0);
  signal d2d_data_rx_iob_i    : std_logic_vector(67 downto 0) := (others => '0');
  signal d2d_data_rx_pipe_i   : std_logic_vector(67 downto 0) := (others => '0');
  signal cable_clk_fwd_int    : std_ulogic;
  signal cable_clk_rcv_raw_i  : std_ulogic;
  signal cable_clk_rcv_global : std_ulogic;
  signal cable_clk_rcv_core_i : std_ulogic;
  signal d2d_rx_mmcm_clkfb_out : std_ulogic;
  signal d2d_rx_mmcm_clkfb_in  : std_ulogic;
  signal d2d_rx_mmcm_clk_out   : std_ulogic;
  signal d2d_rx_mmcm_locked_i  : std_ulogic;
  signal rx_run_ff1, rx_run_ff2, rx_run_i : std_ulogic := '0';
  signal rx_core_run_ff1, rx_core_run_ff2, rx_core_run_i : std_ulogic := '0';
  signal credit_in_evt_rst_ff1, credit_in_evt_rst_ff2 : std_logic := '1';
  signal credit_in_evt_rstn : std_logic;

  attribute IOB : string;
  attribute ASYNC_REG : string;
  attribute DONT_TOUCH : string;
  attribute SHREG_EXTRACT : string;
  attribute IOB of d2d_data_tx_io_i : signal is "TRUE";
  attribute IOB of d2d_data_rx_iob_i : signal is "TRUE";
  attribute SHREG_EXTRACT of d2d_data_rx_iob_i  : signal is "NO";
  attribute SHREG_EXTRACT of d2d_data_rx_pipe_i : signal is "NO";
  attribute DONT_TOUCH of inst_bufgce_cap : label is "TRUE";
  attribute DONT_TOUCH of inst_bufgce_core : label is "TRUE";
  attribute ASYNC_REG of rx_run_ff1 : signal is "TRUE";
  attribute ASYNC_REG of rx_run_ff2 : signal is "TRUE";
  attribute ASYNC_REG of rx_core_run_ff1 : signal is "TRUE";
  attribute ASYNC_REG of rx_core_run_ff2 : signal is "TRUE";
  attribute ASYNC_REG of credit_in_evt_rst_ff1 : signal is "TRUE";
  attribute ASYNC_REG of credit_in_evt_rst_ff2 : signal is "TRUE";
  attribute SHREG_EXTRACT of rx_run_ff1 : signal is "NO";
  attribute SHREG_EXTRACT of rx_run_ff2 : signal is "NO";
  attribute SHREG_EXTRACT of rx_core_run_ff1 : signal is "NO";
  attribute SHREG_EXTRACT of rx_core_run_ff2 : signal is "NO";
  attribute SHREG_EXTRACT of credit_in_evt_rst_ff1 : signal is "NO";
  attribute SHREG_EXTRACT of credit_in_evt_rst_ff2 : signal is "NO";
begin
  credit_in_evt_rstn <= not credit_in_evt_rst_ff2;

  d2d_data_tx_io_dbg <= d2d_data_tx_io_i;
  d2d_data_rx_pipe <= d2d_data_rx_pipe_i;
  cable_clk_rcv_raw <= cable_clk_rcv_raw_i;
  cable_clk_rcv_core <= cable_clk_rcv_core_i;
  d2d_rx_mmcm_locked <= d2d_rx_mmcm_locked_i;
  rx_run <= rx_run_i;
  rx_core_run <= rx_core_run_i;

  gen_tx_upper_pins : if TX_ON_UPPER_PINS generate
    gen_bufs : for i in 0 to 67 generate
      tx_iobuf : IOBUF
        port map (
          O  => open,
          IO => cable_io_data(i + 68),
          I  => d2d_data_tx_io_i(i),
          T  => '0'
        );
      rx_iobuf : IOBUF
        port map (
          O  => d2d_data_rx_io_i(i),
          IO => cable_io_data(i),
          I  => '0',
          T  => '1'
        );
    end generate gen_bufs;
  end generate gen_tx_upper_pins;

  gen_tx_lower_pins : if not TX_ON_UPPER_PINS generate
    gen_bufs : for i in 0 to 67 generate
      tx_iobuf : IOBUF
        port map (
          O  => open,
          IO => cable_io_data(i),
          I  => d2d_data_tx_io_i(i),
          T  => '0'
        );
      rx_iobuf : IOBUF
        port map (
          O  => d2d_data_rx_io_i(i),
          IO => cable_io_data(i + 68),
          I  => '0',
          T  => '1'
        );
    end generate gen_bufs;
  end generate gen_tx_lower_pins;

  inst_oddr_clk_fwd : ODDRE1
    generic map (
      IS_C_INVERTED   => '1',
      IS_D1_INVERTED  => '0',
      IS_D2_INVERTED  => '0',
      SIM_DEVICE      => "ULTRASCALE_PLUS",
      SRVAL           => '0'
    )
    port map (
      Q  => cable_clk_fwd_int,
      C  => d2d_clk_int,
      D1 => '1',
      D2 => '0',
      SR => '0'
    );

  d2d_tx_sdr_regs : process (d2d_clk_int)
  begin
    if rising_edge(d2d_clk_int) then
      if d2d_rstn_d2d = '0' or d2d_rx_mmcm_locked_i = '0' then
        d2d_data_tx_io_i <= (others => '0');
        d2d_data_tx_pipe_i <= (others => '0');
      else
        d2d_data_tx_io_i <= d2d_data_tx_pipe_i;
        d2d_data_tx_pipe_i <= d2d_data_tx;
      end if;
    end if;
  end process d2d_tx_sdr_regs;

  inst_obufds_clk : OBUFDS
    generic map (
      IOSTANDARD => "LVDS"
    )
    port map (
      I  => cable_clk_fwd_int,
      O  => cable_clk_p,
      OB => cable_clk_n
    );

  inst_ibufds_rcv : IBUFDS
    generic map (
      DIFF_TERM    => TRUE,
      IBUF_LOW_PWR => FALSE,
      IOSTANDARD   => "LVDS"
    )
    port map (
      I  => cable_clk_p_rcv,
      IB => cable_clk_n_rcv,
      O  => cable_clk_rcv_raw_i
    );

  inst_mmcm_rcv : MMCME4_ADV
    generic map (
      BANDWIDTH            => "LOW",
      COMPENSATION         => "ZHOLD",
      DIVCLK_DIVIDE        => 1,
      CLKFBOUT_MULT_F      => 8.000,
      CLKFBOUT_PHASE       => 0.000,
      CLKOUT0_DIVIDE_F     => 8.000,
      CLKOUT0_DUTY_CYCLE   => 0.500,
      CLKOUT0_PHASE        => PHASE_DEG,
      CLKIN1_PERIOD        => CLKIN_PERIOD_NS,
      REF_JITTER1          => REF_JITTER1_UI,
      CLKFBOUT_USE_FINE_PS => "FALSE",
      CLKOUT0_USE_FINE_PS  => "FALSE",
      STARTUP_WAIT         => "FALSE"
    )
    port map (
      CLKIN1   => cable_clk_rcv_raw_i,
      CLKIN2   => '0',
      CLKINSEL => '1',
      RST      => d2d_rst,
      PWRDWN   => '0',
      CLKFBOUT => d2d_rx_mmcm_clkfb_out,
      CLKFBIN  => d2d_rx_mmcm_clkfb_in,
      CLKOUT0  => d2d_rx_mmcm_clk_out,
      LOCKED   => d2d_rx_mmcm_locked_i,
      DADDR    => (others => '0'),
      DCLK     => '0',
      DEN      => '0',
      DI       => (others => '0'),
      DWE      => '0',
      PSCLK    => '0',
      PSEN     => '0',
      PSINCDEC => '0',
      CDDCREQ  => '0'
    );

  inst_bufg_fb : BUFG
    port map (
      I => d2d_rx_mmcm_clkfb_out,
      O => d2d_rx_mmcm_clkfb_in
    );

  inst_bufgce_cap : BUFGCE
    port map (
      I  => d2d_rx_mmcm_clk_out,
      CE => '1',
      O  => cable_clk_rcv_global
    );

  inst_bufgce_core : BUFGCE
    port map (
      I  => d2d_rx_mmcm_clk_out,
      CE => '1',
      O  => cable_clk_rcv_core_i
    );

  rx_run_sync_p : process (cable_clk_rcv_global, d2d_rstn)
  begin
    if d2d_rstn = '0' then
      rx_run_ff1 <= '0';
      rx_run_ff2 <= '0';
    elsif rising_edge(cable_clk_rcv_global) then
      if d2d_rx_mmcm_locked_i = '0' then
        rx_run_ff1 <= '0';
        rx_run_ff2 <= '0';
      else
        rx_run_ff1 <= '1';
        rx_run_ff2 <= rx_run_ff1;
      end if;
    end if;
  end process rx_run_sync_p;
  rx_run_i <= rx_run_ff2;

  rx_core_run_sync_p : process (cable_clk_rcv_core_i, d2d_rstn)
  begin
    if d2d_rstn = '0' then
      rx_core_run_ff1 <= '0';
      rx_core_run_ff2 <= '0';
    elsif rising_edge(cable_clk_rcv_core_i) then
      if d2d_rx_mmcm_locked_i = '0' then
        rx_core_run_ff1 <= '0';
        rx_core_run_ff2 <= '0';
      else
        rx_core_run_ff1 <= '1';
        rx_core_run_ff2 <= rx_core_run_ff1;
      end if;
    end if;
  end process rx_core_run_sync_p;
  rx_core_run_i <= rx_core_run_ff2;

  credit_evt_rst_sync_p : process (cable_clk_rcv_core_i, d2d_rstn)
  begin
    if d2d_rstn = '0' then
      credit_in_evt_rst_ff1 <= '1';
      credit_in_evt_rst_ff2 <= '1';
    elsif rising_edge(cable_clk_rcv_core_i) then
      if d2d_rx_mmcm_locked_i = '0' then
        credit_in_evt_rst_ff1 <= '1';
        credit_in_evt_rst_ff2 <= '1';
      else
        credit_in_evt_rst_ff1 <= '0';
        credit_in_evt_rst_ff2 <= credit_in_evt_rst_ff1;
      end if;
    end if;
  end process credit_evt_rst_sync_p;

  rx_iob_regs_p : process (cable_clk_rcv_global)
  begin
    if rising_edge(cable_clk_rcv_global) then
      if d2d_rx_mmcm_locked_i = '0' or rx_run_i = '0' then
        d2d_data_rx_iob_i <= (others => '0');
      else
        d2d_data_rx_iob_i <= d2d_data_rx_io_i;
      end if;
    end if;
  end process rx_iob_regs_p;

  rx_core_regs_p : process (cable_clk_rcv_core_i)
  begin
    if rising_edge(cable_clk_rcv_core_i) then
      if d2d_rx_mmcm_locked_i = '0' or rx_core_run_i = '0' then
        d2d_data_rx_pipe_i <= (others => '0');
      else
        d2d_data_rx_pipe_i <= d2d_data_rx_iob_i;
      end if;
    end if;
  end process rx_core_regs_p;

  gen_credit_in_cdc : if LINK_ACTIVE generate
  begin
    credit_in_cdc_i : cdc_gray_pulse
      generic map (
        N => CREDIT_CDC_N
      )
      port map (
        src_clk   => cable_clk_rcv_core_i,
        dst_clk   => d2d_clk_int,
        src_rstn  => credit_in_evt_rstn,
        dst_rstn  => d2d_rstn_d2d,
        src_pulse => d2d_data_rx_pipe_i(66),
        dst_pulse => credit_in_evt_pulse_d2d
      );
  end generate gen_credit_in_cdc;

  no_credit_in_cdc : if not LINK_ACTIVE generate
  begin
    credit_in_evt_pulse_d2d <= '0';
  end generate no_credit_in_cdc;
end architecture rtl;

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.nocpackage.all;

entity d2d_cable_direction_map is
  generic (
    C0_IS_WEST   : boolean;
    C1_IS_NORTH  : boolean;
    ISOLATE_LINKS : boolean := false
  );
  port (
    c0_d2d_data_rx_pipe              : in  std_logic_vector(67 downto 0);
    c1_d2d_data_rx_pipe              : in  std_logic_vector(67 downto 0);
    c0_credit_in_evt_pulse_d2d       : in  std_logic;
    c1_credit_in_evt_pulse_d2d       : in  std_logic;
    cable_clk_rcv_core_0             : in  std_ulogic;
    cable_clk_rcv_core_1             : in  std_ulogic;
    chiplet_data_n_in                : out coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_in_n              : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_in_n               : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_s_in                : out coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_in_s              : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_in_s               : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_w_in                : out coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_in_w              : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_in_w               : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_e_in                : out coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_in_e              : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_in_e               : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_n_out               : in  coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_out_n              : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_s_out               : in  coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_out_s              : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_w_out               : in  coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_out_w              : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_e_out               : in  coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_out_e              : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_out_n_evt_pulse_d2d : in std_logic;
    chiplet_credit_out_s_evt_pulse_d2d : in std_logic;
    chiplet_credit_out_w_evt_pulse_d2d : in std_logic;
    chiplet_credit_out_e_evt_pulse_d2d : in std_logic;
    c0_d2d_data_tx                   : out std_logic_vector(67 downto 0);
    c1_d2d_data_tx                   : out std_logic_vector(67 downto 0);
    d2d_clk_n_in_int                 : out std_ulogic;
    d2d_clk_s_in_int                 : out std_ulogic;
    d2d_clk_w_in_int                 : out std_ulogic;
    d2d_clk_e_in_int                 : out std_ulogic
  );
end entity d2d_cable_direction_map;

architecture rtl of d2d_cable_direction_map is
begin
  gen_isolated : if ISOLATE_LINKS generate
    zero_loop : for i in 0 to WIRES_PER_CONNECTION-1 generate
      chiplet_data_n_in(i) <= (others => '0');
      chiplet_credit_in_n(i) <= '0';
      chiplet_valid_in_n(i) <= '0';
      chiplet_data_s_in(i) <= (others => '0');
      chiplet_credit_in_s(i) <= '0';
      chiplet_valid_in_s(i) <= '0';
      chiplet_data_w_in(i) <= (others => '0');
      chiplet_credit_in_w(i) <= '0';
      chiplet_valid_in_w(i) <= '0';
      chiplet_data_e_in(i) <= (others => '0');
      chiplet_credit_in_e(i) <= '0';
      chiplet_valid_in_e(i) <= '0';
    end generate zero_loop;

    c0_d2d_data_tx <= (others => '0');
    c1_d2d_data_tx <= (others => '0');
    d2d_clk_n_in_int <= '0';
    d2d_clk_s_in_int <= '0';
    d2d_clk_w_in_int <= '0';
    d2d_clk_e_in_int <= '0';
  end generate gen_isolated;

  gen_connected : if not ISOLATE_LINKS generate
    zero_loop : for i in 0 to WIRES_PER_CONNECTION-1 generate
      chiplet_data_n_in(i) <= c1_d2d_data_rx_pipe(65 downto 0) when C1_IS_NORTH else (others => '0');
      chiplet_credit_in_n(i) <= c1_credit_in_evt_pulse_d2d when C1_IS_NORTH else '0';
      chiplet_valid_in_n(i) <= c1_d2d_data_rx_pipe(67) when C1_IS_NORTH else '0';

      chiplet_data_s_in(i) <= c1_d2d_data_rx_pipe(65 downto 0) when not C1_IS_NORTH else (others => '0');
      chiplet_credit_in_s(i) <= c1_credit_in_evt_pulse_d2d when not C1_IS_NORTH else '0';
      chiplet_valid_in_s(i) <= c1_d2d_data_rx_pipe(67) when not C1_IS_NORTH else '0';

      chiplet_data_w_in(i) <= c0_d2d_data_rx_pipe(65 downto 0) when C0_IS_WEST else (others => '0');
      chiplet_credit_in_w(i) <= c0_credit_in_evt_pulse_d2d when C0_IS_WEST else '0';
      chiplet_valid_in_w(i) <= c0_d2d_data_rx_pipe(67) when C0_IS_WEST else '0';

      chiplet_data_e_in(i) <= c0_d2d_data_rx_pipe(65 downto 0) when not C0_IS_WEST else (others => '0');
      chiplet_credit_in_e(i) <= c0_credit_in_evt_pulse_d2d when not C0_IS_WEST else '0';
      chiplet_valid_in_e(i) <= c0_d2d_data_rx_pipe(67) when not C0_IS_WEST else '0';

      c1_d2d_data_tx(65 downto 0) <= chiplet_data_n_out(i) when C1_IS_NORTH else chiplet_data_s_out(i);
      c1_d2d_data_tx(66) <= chiplet_credit_out_n_evt_pulse_d2d when C1_IS_NORTH else chiplet_credit_out_s_evt_pulse_d2d;
      c1_d2d_data_tx(67) <= chiplet_valid_out_n(i) when C1_IS_NORTH else chiplet_valid_out_s(i);

      c0_d2d_data_tx(65 downto 0) <= chiplet_data_w_out(i) when C0_IS_WEST else chiplet_data_e_out(i);
      c0_d2d_data_tx(66) <= chiplet_credit_out_w_evt_pulse_d2d when C0_IS_WEST else chiplet_credit_out_e_evt_pulse_d2d;
      c0_d2d_data_tx(67) <= chiplet_valid_out_w(i) when C0_IS_WEST else chiplet_valid_out_e(i);
    end generate zero_loop;

    d2d_clk_n_in_int <= cable_clk_rcv_core_1 when C1_IS_NORTH else '0';
    d2d_clk_s_in_int <= cable_clk_rcv_core_1 when not C1_IS_NORTH else '0';
    d2d_clk_w_in_int <= cable_clk_rcv_core_0 when C0_IS_WEST else '0';
    d2d_clk_e_in_int <= cable_clk_rcv_core_0 when not C0_IS_WEST else '0';
  end generate gen_connected;
end architecture rtl;

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.nocpackage.all;

entity d2d_direction_link is
  generic (
    CHANNELS      : integer;
    TILES         : integer;
    D2D_POSITION  : std_logic_vector(1 downto 0);
    LOCAL_CHIP_Y  : chip_yx;
    LOCAL_CHIP_X  : chip_yx;
    MAX_DIM       : local_yx
  );
  port (
    clk                 : in  std_ulogic;
    rst                 : in  std_ulogic;
    d2d_rst             : in  std_ulogic;
    d2d_clk_tx_in       : in  std_ulogic;
    d2d_clk_rx_in       : in  std_ulogic;
    chiplet_data_in     : in  coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_in   : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_in    : in  std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_data_out    : out coh_noc_flit_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_credit_out  : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    chiplet_valid_out   : out std_logic_vector(WIRES_PER_CONNECTION-1 downto 0);
    tx_link_ready       : out std_logic;
    rx_link_ready       : out std_logic;
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
    bypass_data_in      : in  coh_noc_flit_type;
    bypass_data_void_in : in  std_logic;
    noc1_stop_out       : out std_logic_vector(TILES-1 downto 0);
    noc2_stop_out       : out std_logic_vector(TILES-1 downto 0);
    noc3_stop_out       : out std_logic_vector(TILES-1 downto 0);
    noc4_stop_out       : out std_logic_vector(TILES-1 downto 0);
    noc5_stop_out       : out std_logic_vector(TILES-1 downto 0);
    noc6_stop_out       : out std_logic_vector(TILES-1 downto 0);
    bypass_stop_out     : out std_logic;
    noc1_data_out       : out coh_noc_flit_vector(TILES-1 downto 0);
    noc2_data_out       : out coh_noc_flit_vector(TILES-1 downto 0);
    noc3_data_out       : out coh_noc_flit_vector(TILES-1 downto 0);
    noc4_data_out       : out dma_noc_flit_vector(TILES-1 downto 0);
    noc5_data_out       : out misc_noc_flit_vector(TILES-1 downto 0);
    noc6_data_out       : out dma_noc_flit_vector(TILES-1 downto 0);
    noc1_data_void_out  : out std_logic_vector(TILES-1 downto 0);
    noc2_data_void_out  : out std_logic_vector(TILES-1 downto 0);
    noc3_data_void_out  : out std_logic_vector(TILES-1 downto 0);
    noc4_data_void_out  : out std_logic_vector(TILES-1 downto 0);
    noc5_data_void_out  : out std_logic_vector(TILES-1 downto 0);
    noc6_data_void_out  : out std_logic_vector(TILES-1 downto 0);
    bypass_data_out     : out coh_noc_flit_type;
    bypass_data_void_out : out std_logic;
    noc1_stop_in        : in  std_logic_vector(TILES-1 downto 0);
    noc2_stop_in        : in  std_logic_vector(TILES-1 downto 0);
    noc3_stop_in        : in  std_logic_vector(TILES-1 downto 0);
    noc4_stop_in        : in  std_logic_vector(TILES-1 downto 0);
    noc5_stop_in        : in  std_logic_vector(TILES-1 downto 0);
    noc6_stop_in        : in  std_logic_vector(TILES-1 downto 0);
    bypass_stop_in      : in  std_logic
  );
end entity d2d_direction_link;

architecture rtl of d2d_direction_link is
  component d2d_tx_top is
    generic (
      TXCHANNELS   : integer;
      TILES        : integer;
      flow_control : integer;
      chwidth      : integer;
      cohwidth     : integer;
      miscwidth    : integer;
      dmawidth     : integer
    );
    port (
      clk                 : in  std_ulogic;
      rst                 : in  std_ulogic;
      d2d_rst             : in  std_ulogic;
      d2d_clk_in          : in  std_ulogic;
      d2d_snd_data_out    : out coh_noc_flit_vector(TXCHANNELS-1 downto 0);
      d2d_valid_out       : out std_logic_vector(TXCHANNELS-1 downto 0);
      d2d_link_ready      : out std_logic;
      d2d_credit_in       : in  std_logic_vector(TXCHANNELS-1 downto 0);
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
      d2d_position   : std_logic_vector(1 downto 0);
      local_chip_y   : chip_yx;
      local_chip_x   : chip_yx;
      max_dim        : local_yx;
      RXCHANNELS     : integer;
      TILES          : integer;
      flow_control   : integer;
      chwidth        : integer;
      cohwidth       : integer;
      miscwidth      : integer;
      dmawidth       : integer
    );
    port (
      clk                 : in  std_ulogic;
      rst                 : in  std_ulogic;
      d2d_rst             : in  std_ulogic;
      d2d_clk_in          : in  std_ulogic;
      d2d_rcv_data_in     : in  coh_noc_flit_vector(RXCHANNELS-1 downto 0);
      d2d_valid_in        : in  std_logic_vector(RXCHANNELS-1 downto 0);
      d2d_link_ready      : out std_logic;
      d2d_credit_out      : out std_logic_vector(RXCHANNELS-1 downto 0);
      noc1_data_out       : out coh_noc_flit_vector(TILES-1 downto 0);
      noc2_data_out       : out coh_noc_flit_vector(TILES-1 downto 0);
      noc3_data_out       : out coh_noc_flit_vector(TILES-1 downto 0);
      noc4_data_out       : out dma_noc_flit_vector(TILES-1 downto 0);
      noc5_data_out       : out misc_noc_flit_vector(TILES-1 downto 0);
      noc6_data_out       : out dma_noc_flit_vector(TILES-1 downto 0);
      bypass_data_out     : out coh_noc_flit_type;
      noc1_data_void_out  : out std_logic_vector(TILES-1 downto 0);
      noc2_data_void_out  : out std_logic_vector(TILES-1 downto 0);
      noc3_data_void_out  : out std_logic_vector(TILES-1 downto 0);
      noc4_data_void_out  : out std_logic_vector(TILES-1 downto 0);
      noc5_data_void_out  : out std_logic_vector(TILES-1 downto 0);
      noc6_data_void_out  : out std_logic_vector(TILES-1 downto 0);
      bypass_data_void_out : out std_logic;
      noc1_stop_in        : in std_logic_vector(TILES-1 downto 0);
      noc2_stop_in        : in std_logic_vector(TILES-1 downto 0);
      noc3_stop_in        : in std_logic_vector(TILES-1 downto 0);
      noc4_stop_in        : in std_logic_vector(TILES-1 downto 0);
      noc5_stop_in        : in std_logic_vector(TILES-1 downto 0);
      noc6_stop_in        : in std_logic_vector(TILES-1 downto 0);
      bypass_stop_in      : in std_logic
    );
  end component d2d_rx_top;
begin
  gen_link_present : if CHANNELS > 0 generate
  begin
    d2d_tx_i : d2d_tx_top
      generic map (
        TXCHANNELS   => CHANNELS,
        TILES        => TILES,
        flow_control => 0,
        chwidth      => COH_NOC_FLIT_SIZE,
        cohwidth     => COH_NOC_FLIT_SIZE,
        miscwidth    => MISC_NOC_FLIT_SIZE,
        dmawidth     => DMA_NOC_FLIT_SIZE
      )
      port map (
        clk                 => clk,
        rst                 => rst,
        d2d_rst             => d2d_rst,
        d2d_clk_in          => d2d_clk_tx_in,
        d2d_snd_data_out    => chiplet_data_out(CHANNELS-1 downto 0),
        d2d_valid_out       => chiplet_valid_out(CHANNELS-1 downto 0),
        d2d_link_ready      => tx_link_ready,
        d2d_credit_in       => chiplet_credit_in(CHANNELS-1 downto 0),
        noc1_data_in        => noc1_data_in,
        noc2_data_in        => noc2_data_in,
        noc3_data_in        => noc3_data_in,
        noc4_data_in        => noc4_data_in,
        noc5_data_in        => noc5_data_in,
        noc6_data_in        => noc6_data_in,
        bypass_data_in      => bypass_data_in,
        noc1_data_void_in   => noc1_data_void_in,
        noc2_data_void_in   => noc2_data_void_in,
        noc3_data_void_in   => noc3_data_void_in,
        noc4_data_void_in   => noc4_data_void_in,
        noc5_data_void_in   => noc5_data_void_in,
        noc6_data_void_in   => noc6_data_void_in,
        bypass_data_void_in => bypass_data_void_in,
        noc1_stop_out       => noc1_stop_out,
        noc2_stop_out       => noc2_stop_out,
        noc3_stop_out       => noc3_stop_out,
        noc4_stop_out       => noc4_stop_out,
        noc5_stop_out       => noc5_stop_out,
        noc6_stop_out       => noc6_stop_out,
        bypass_stop_out     => bypass_stop_out
      );

    d2d_rx_i : d2d_rx_top
      generic map (
        d2d_position => D2D_POSITION,
        local_chip_y => LOCAL_CHIP_Y,
        local_chip_x => LOCAL_CHIP_X,
        max_dim      => MAX_DIM,
        RXCHANNELS   => CHANNELS,
        TILES        => TILES,
        flow_control => 0,
        chwidth      => COH_NOC_FLIT_SIZE,
        cohwidth     => COH_NOC_FLIT_SIZE,
        miscwidth    => MISC_NOC_FLIT_SIZE,
        dmawidth     => DMA_NOC_FLIT_SIZE
      )
      port map (
        clk                  => clk,
        rst                  => rst,
        d2d_rst              => d2d_rst,
        d2d_clk_in           => d2d_clk_rx_in,
        d2d_rcv_data_in      => chiplet_data_in(CHANNELS-1 downto 0),
        d2d_valid_in         => chiplet_valid_in(CHANNELS-1 downto 0),
        d2d_link_ready       => rx_link_ready,
        d2d_credit_out       => chiplet_credit_out(CHANNELS-1 downto 0),
        noc1_data_out        => noc1_data_out,
        noc2_data_out        => noc2_data_out,
        noc3_data_out        => noc3_data_out,
        noc4_data_out        => noc4_data_out,
        noc5_data_out        => noc5_data_out,
        noc6_data_out        => noc6_data_out,
        bypass_data_out      => bypass_data_out,
        noc1_data_void_out   => noc1_data_void_out,
        noc2_data_void_out   => noc2_data_void_out,
        noc3_data_void_out   => noc3_data_void_out,
        noc4_data_void_out   => noc4_data_void_out,
        noc5_data_void_out   => noc5_data_void_out,
        noc6_data_void_out   => noc6_data_void_out,
        bypass_data_void_out => bypass_data_void_out,
        noc1_stop_in         => noc1_stop_in,
        noc2_stop_in         => noc2_stop_in,
        noc3_stop_in         => noc3_stop_in,
        noc4_stop_in         => noc4_stop_in,
        noc5_stop_in         => noc5_stop_in,
        noc6_stop_in         => noc6_stop_in,
        bypass_stop_in       => bypass_stop_in
      );
  end generate gen_link_present;

  gen_link_absent : if CHANNELS = 0 generate
  begin
    chiplet_data_out <= (others => (others => '0'));
    chiplet_valid_out <= (others => '0');
    chiplet_credit_out <= (others => '0');
    bypass_data_out <= (others => '0');
    bypass_data_void_out <= '1';
    bypass_stop_out <= '1';
    noc1_data_out <= (others => (others => '0'));
    noc2_data_out <= (others => (others => '0'));
    noc3_data_out <= (others => (others => '0'));
    noc4_data_out <= (others => (others => '0'));
    noc5_data_out <= (others => (others => '0'));
    noc6_data_out <= (others => (others => '0'));
    noc1_data_void_out <= (others => '1');
    noc2_data_void_out <= (others => '1');
    noc3_data_void_out <= (others => '1');
    noc4_data_void_out <= (others => '1');
    noc5_data_void_out <= (others => '1');
    noc6_data_void_out <= (others => '1');
    noc1_stop_out <= (others => '0');
    noc2_stop_out <= (others => '0');
    noc3_stop_out <= (others => '0');
    noc4_stop_out <= (others => '0');
    noc5_stop_out <= (others => '0');
    noc6_stop_out <= (others => '0');
    tx_link_ready <= '1';
    rx_link_ready <= '1';
  end generate gen_link_absent;
end architecture rtl;
