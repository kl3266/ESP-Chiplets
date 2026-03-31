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

entity relay_station_agg is
    generic (
        tiles           :   integer := 2
    );
    port (
        clk                 :   in  std_ulogic;
        rst                 :   in  std_ulogic;
        noc1_data_in        :   in  coh_noc_flit_vector(tiles-1 downto 0);
        noc1_data_void_in   :   in  std_logic_vector(tiles-1 downto 0);
        noc1_stop_in        :   in  std_logic_vector(tiles-1 downto 0);
        noc1_data_out       :   out coh_noc_flit_vector(tiles-1 downto 0);
        noc1_data_void_out  :   out std_logic_vector(tiles-1 downto 0);
        noc1_stop_out       :   out std_logic_vector(tiles-1 downto 0);
        noc2_data_in        :   in  coh_noc_flit_vector(tiles-1 downto 0);
        noc2_data_void_in   :   in  std_logic_vector(tiles-1 downto 0);
        noc2_stop_in        :   in  std_logic_vector(tiles-1 downto 0);
        noc2_data_out       :   out coh_noc_flit_vector(tiles-1 downto 0);
        noc2_data_void_out  :   out std_logic_vector(tiles-1 downto 0);
        noc2_stop_out       :   out std_logic_vector(tiles-1 downto 0);
        noc3_data_in        :   in  coh_noc_flit_vector(tiles-1 downto 0);
        noc3_data_void_in   :   in  std_logic_vector(tiles-1 downto 0);
        noc3_stop_in        :   in  std_logic_vector(tiles-1 downto 0);
        noc3_data_out       :   out coh_noc_flit_vector(tiles-1 downto 0);
        noc3_data_void_out  :   out std_logic_vector(tiles-1 downto 0);
        noc3_stop_out       :   out std_logic_vector(tiles-1 downto 0);
        noc4_data_in        :   in  dma_noc_flit_vector(tiles-1 downto 0);
        noc4_data_void_in   :   in  std_logic_vector(tiles-1 downto 0);
        noc4_stop_in        :   in  std_logic_vector(tiles-1 downto 0);
        noc4_data_out       :   out dma_noc_flit_vector(tiles-1 downto 0);
        noc4_data_void_out  :   out std_logic_vector(tiles-1 downto 0);
        noc4_stop_out       :   out std_logic_vector(tiles-1 downto 0);
        noc5_data_in        :   in  misc_noc_flit_vector(tiles-1 downto 0);
        noc5_data_void_in   :   in  std_logic_vector(tiles-1 downto 0);
        noc5_stop_in        :   in  std_logic_vector(tiles-1 downto 0);
        noc5_data_out       :   out misc_noc_flit_vector(tiles-1 downto 0);
        noc5_data_void_out  :   out std_logic_vector(tiles-1 downto 0);
        noc5_stop_out       :   out std_logic_vector(tiles-1 downto 0);
        noc6_data_in        :   in  dma_noc_flit_vector(tiles-1 downto 0);
        noc6_data_void_in   :   in  std_logic_vector(tiles-1 downto 0);
        noc6_stop_in        :   in  std_logic_vector(tiles-1 downto 0);
        noc6_data_out       :   out dma_noc_flit_vector(tiles-1 downto 0);
        noc6_data_void_out  :   out std_logic_vector(tiles-1 downto 0);
        noc6_stop_out       :   out std_logic_vector(tiles-1 downto 0)
    );
end relay_station_agg;

architecture rtl of relay_station_agg is
  component relay_station is
    generic (
      width : integer
    );
    port (
      clk           : in  std_ulogic;
      rst           : in  std_ulogic;
      data_in       : in  std_logic_vector(width-1 downto 0);
      data_void_in  : in  std_logic;
      stop_in       : in  std_logic;
      data_out      : out std_logic_vector(width-1 downto 0);
      data_void_out : out std_logic;
      stop_out      : out std_logic
    );
  end component relay_station;

begin

  gen_rs : for i in 0 to tiles-1 generate
    relay_station_noc1  : relay_station
      generic map (
        width         =>  COH_NOC_FLIT_SIZE
      )
      port map (
        clk           =>  clk,
        rst           =>  rst,
        data_in       =>  noc1_data_in(i),
        data_void_in  =>  noc1_data_void_in(i),
        stop_in       =>  noc1_stop_in(i),
        data_out      =>  noc1_data_out(i),
        data_void_out =>  noc1_data_void_out(i),
        stop_out      =>  noc1_stop_out(i)
      );
    relay_station_noc2  : relay_station
      generic map (
        width         =>  COH_NOC_FLIT_SIZE
      )
      port map (
        clk           =>  clk,
        rst           =>  rst,
        data_in       =>  noc2_data_in(i),
        data_void_in  =>  noc2_data_void_in(i),
        stop_in       =>  noc2_stop_in(i),
        data_out      =>  noc2_data_out(i),
        data_void_out =>  noc2_data_void_out(i),
        stop_out      =>  noc2_stop_out(i)
      );
    relay_station_noc3  : relay_station
      generic map (
        width         =>  COH_NOC_FLIT_SIZE
      )
      port map (
        clk           =>  clk,
        rst           =>  rst,
        data_in       =>  noc3_data_in(i),
        data_void_in  =>  noc3_data_void_in(i),
        stop_in       =>  noc3_stop_in(i),
        data_out      =>  noc3_data_out(i),
        data_void_out =>  noc3_data_void_out(i),
        stop_out      =>  noc3_stop_out(i)
      );
    relay_station_noc4  : relay_station
      generic map (
        width         =>  DMA_NOC_FLIT_SIZE
      )
      port map (
        clk           =>  clk,
        rst           =>  rst,
        data_in       =>  noc4_data_in(i),
        data_void_in  =>  noc4_data_void_in(i),
        stop_in       =>  noc4_stop_in(i),
        data_out      =>  noc4_data_out(i),
        data_void_out =>  noc4_data_void_out(i),
        stop_out      =>  noc4_stop_out(i)
      );
    relay_station_noc5  : relay_station
      generic map (
        width         =>  MISC_NOC_FLIT_SIZE
      )
      port map (
        clk           =>  clk,
        rst           =>  rst,
        data_in       =>  noc5_data_in(i),
        data_void_in  =>  noc5_data_void_in(i),
        stop_in       =>  noc5_stop_in(i),
        data_out      =>  noc5_data_out(i),
        data_void_out =>  noc5_data_void_out(i),
        stop_out      =>  noc5_stop_out(i)
      );
    relay_station_noc6  : relay_station
      generic map (
        width         =>  DMA_NOC_FLIT_SIZE
      )
      port map (
        clk           =>  clk,
        rst           =>  rst,
        data_in       =>  noc6_data_in(i),
        data_void_in  =>  noc6_data_void_in(i),
        stop_in       =>  noc6_stop_in(i),
        data_out      =>  noc6_data_out(i),
        data_void_out =>  noc6_data_void_out(i),
        stop_out      =>  noc6_stop_out(i)
      );
    end generate gen_rs;
end rtl;
