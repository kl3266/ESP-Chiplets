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

entity relay_station is
    generic(
        width           :   integer := 66
    );
    port(
        clk             :   in  std_ulogic;
        rst             :   in  std_ulogic;
        data_in         :   in  std_logic_vector(width-1 downto 0);
        data_void_in    :   in  std_logic;
        stop_in         :   in  std_logic;
        data_out        :   out std_logic_vector(width-1 downto 0);
        data_void_out   :   out std_logic;
        stop_out        :   out std_logic
    );
end relay_station;

architecture rtl of relay_station is

    signal main_data, skid_data :   std_logic_vector(width-1 downto 0);
    signal main_void, skid_void :   std_logic;

begin
    data_out <= main_data;
    data_void_out <= main_void;

    stop_out <= not skid_void;

    process (clk, rst)
    begin
        if rst = '1' then
            main_void <= '1';
            skid_void <= '1';
            main_data <= (others => '0');
            skid_data <= (others => '0');
        elsif rising_edge(clk) then
            if stop_in = '0' then
                if skid_void = '0' then -- skidded data waiting --> move to main
                    main_data <= skid_data;
                    main_void <= '0';
                    -- if data_void_in = '0' then  -- data at input waiting --> move to skid
                    --     skid_data <= data_in;
                    --     skid_void <= '0';
                    -- else
                    --     skid_void <= '1';
                    -- end if;
                    skid_void <= '1';
                else    -- skid is empty --> pass input to output
                    main_data <= data_in;
                    main_void <= data_void_in;
                end if;
            else
                if main_void = '1' then
                    if data_void_in = '0' then
                        main_data <= data_in;
                        main_void <= '0';
                    end if;
                elsif skid_void = '1' then
                    if data_void_in = '0' then
                        skid_data <= data_in;
                        skid_void <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;
end rtl;
