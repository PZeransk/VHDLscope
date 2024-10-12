----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:51:09 10/12/2024 
-- Design Name: 
-- Module Name:    spi_slave - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_slave is
GENERIC(
	C_data_length	:	integer := 8;
  	C_cmd_size   	: 	integer := 8;
  	C_data_size  	: 	integer := 16
	);
PORT(
	i_clk			:	in 	std_logic;
	i_reset_n		:	in 	std_logic; -- active low
	i_cs 			:	in 	std_logic; -- cs from master
 	i_spi_clk   	: 	in  std_logic; -- clock from master
	i_mosi			:	in 	std_logic; -- data from master	
	i_data_tx		: 	in 	std_logic_vector(C_data_length - 1 downto 0); -- data to send to master
	
	o_data			:	out std_logic_vector(C_data_length - 1 downto 0);-- data received from master
	o_miso			: 	out std_logic;
	o_data_rx_valid	: 	out std_logic -- rx data flag '1' when data was fully received

	);

end spi_slave;

architecture Behavioral of spi_slave is

	type T_spi_slave_states is (
		SLV_IDLE,
		SLV_RECEIVE_DATA,
		TRANSFER_DATA_TO_MASTER
		);
	signal r_slave_state	:	T_spi_slave_states 	:= SLV_IDLE;
	signal master_data		: 	std_logic_vector(C_data_length - 1 downto 0) := (others => '0');
	signal slope_detected	: 	std_logic 	:= '0';
	signal clk_probe		: 	std_logic_vector(1 downto 0) :="00"; -- 2 bit clk detector
	signal rx_cnt			:	integer range 0 to C_data_length := 0;
begin


spi_clk_slope_detect : process(i_spi_clk, i_clk) is
begin
	if (i_reset_n = '0') then
		slope_detected <='0';

	elsif rising_edge(i_clk) then
		clk_probe <= clk_probe(clk_probe'high -1 downto 0) & i_spi_clk;

		if clk_probe = "01" then --"01" for rising edge "10" for falling edge
			slope_detected <= '1';
		else 
			slope_detected <= '0';
		end if;

	end if;
end process; -- spi_clk_slope_detect


main : process(i_spi_clk, i_reset_n) is
begin
	
if i_reset_n = '0' then
	r_slave_state	<= SLV_IDLE;
	master_data   	<= (others => '0');
	rx_cnt			<= 0;
elsif rising_edge(i_clk) then -- 
	case (r_slave_state) is

		when SLV_IDLE =>
			rx_cnt	<= 0;
		when SLV_RECEIVE_DATA =>

	    	if slope_detected = '1' then
	    		if rx_cnt < C_data_length then
	    		master_data <= master_data(master_data'high-1 downto 0)&i_mosi;
	    		rx_cnt <= rx_cnt + 1;
	    		else
	    		rx_cnt <= 0;
	    		end if;
	    	end if;

		when TRANSFER_DATA_TO_MASTER =>

	end case;
end if;

end process; -- main


end Behavioral;

