----------------------------------------------------------------------------------
-- Description: Module to indicate if fpga is working via blinking LED
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity led_indicator is
	Generic(
		C_divider : integer := 1200000 -- there is 12MHz clock currently 
		);
    Port ( i_clk : in  STD_LOGIC;
           o_led : out  STD_LOGIC);
end led_indicator;

architecture Behavioral of led_indicator is

signal cnt 			: integer range 0 to C_divider := 0;
signal clk_state 	: std_logic := '0';

begin

counter : process(i_clk) is
begin
	if rising_edge(i_clk) then
		if cnt < C_divider then
		cnt <= cnt + 1;
		else 
		cnt <=0;
		clk_state <= NOT clk_state;
		end if;

	end if;
end process; -- counter

o_led <= clk_state;

end Behavioral;

