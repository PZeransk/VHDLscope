----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:54:55 11/25/2024 
-- Design Name: 
-- Module Name:    slave_controller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity slave_controller is
GENERIC(
	C_data_length	:	integer := 8;
  	C_cmd_size   	: 	integer := 8;
  	C_data_size  	: 	integer := 16
	);
PORT(
	i_clk			:	in 	std_logic;
	i_reset_n		:	in 	std_logic; -- active low
	i_rx_data 		:	in  std_logic_vector(C_data_length - 1 downto 0);
	i_rx_data_ready :	in 	std_logic; -- cs from master
	i_data_cnt_reset: 	in  std_logic;
	
	o_cmd 			: 	out std_logic_vector(C_cmd_size - 1 downto 0);
	o_data			:	out std_logic_vector(2*C_data_length - 1 downto 0)-- data received from master
	);
end slave_controller;

architecture Behavioral of slave_controller is

SIGNAL rx_data 	: std_logic_vector(C_data_length - 1 downto 0) := (others => '0');
SIGNAL data_cnt : integer range 0 to 3 := 0;

begin


-----------------------------------------------------
-- Get data from slave when o_data_rx_ready is high
-----------------------------------------------------
process(i_clk, i_reset_n, i_rx_data_ready)
begin

if i_reset_n = '0' then -- or data_reset is high
	data_cnt <= 0;
	rx_data <= (others => '0');
elsif rising_edge(i_clk) then
	if(i_rx_data_ready = '1') then
		rx_data <= i_rx_data;
	end if;

end if ;



end process;

---------------------------------------------------
-- send data accordingly to command
---------------------------------------------------


end Behavioral;

