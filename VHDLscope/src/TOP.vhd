

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity TOP is
port(
    i_clk   :   in  std_logic;
    o_miso0 :   out std_logic
);
end TOP;


architecture Behavioral of TOP is

signal cs       : std_logic                     :=      '1';
signal miso0    : std_logic                     :=      '1';
begin
ADC_SIM_TOP: entity work.adc_sim
port map(
i_clk   => i_clk,
i_cs    => cs,
o_miso0 => o_miso0
);


end architecture;