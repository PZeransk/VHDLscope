--! Use standard library
library IEEE;
--! Use logic elements
use IEEE.STD_LOGIC_1164.ALL;

--! SPI slave entity. It
--! connects with STM32MP157 board and receives commands from it.
--! After receiving data is transfered to slave_controller entity for 
--! further operations.

--! \param C_data_length	Length of data in one SPI block
--! \param C_cmd_size   	Size of command
--! \param C_data_size  	Size of data following command



entity spi_slave is
GENERIC(
	C_data_length	:	integer := 8;
  	C_cmd_size   	: 	integer := 8;
  	C_data_size  	: 	integer := 16
	);
PORT(
	i_clk			:	in 	std_logic; --! Input clock
	i_reset_n		:	in 	std_logic; --! Reset Active low
	i_cs 			:	in 	std_logic; --! CS from master
 	i_spi_clk   	: 	in  std_logic; --! SPI clock from master
	i_mosi			:	in 	std_logic; --! Data from master	
	i_data_tx		: 	in 	std_logic_vector(C_data_length - 1 downto 0); --! Data to be send to master
	o_finish_flag	:   out std_logic; --! Flag for signaling end of master transmission
	o_data			:	out std_logic_vector(C_data_length - 1 downto 0);--! Data received from master
	o_miso			: 	out std_logic;--! Data to master
	o_data_rx_ready	: 	out std_logic --! rx data flag '1' when data was fully received

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

	elsif falling_edge(i_clk) then
		clk_probe <= clk_probe(clk_probe'high -1 downto 0) & i_spi_clk;

		if clk_probe = "01" then --"01" for rising edge "10" for falling edge
			slope_detected <= '1';
		else
			slope_detected <= '0';
		end if;

	end if;
end process; -- spi_clk_slope_detect


main : process(i_clk, i_spi_clk, i_reset_n, i_cs, slope_detected) is
begin
	
if i_reset_n = '0' then
	r_slave_state	<= SLV_IDLE;
	--master_data   	<= (others => '0');

	--o_data_rx_ready <= '0';
elsif rising_edge(i_clk) then --

	case (r_slave_state) is

		when SLV_IDLE =>
		--o_data_rx_ready <= '0';
			if i_cs = '0' then
				--rx_cnt	<= 0;
				r_slave_state <= SLV_IDLE;
				o_finish_flag <= '1';
			elsif i_cs = '1' then
				--rx_cnt	<= 0;
				o_finish_flag <= '0';
				r_slave_state <= SLV_RECEIVE_DATA;
			end if;

		when SLV_RECEIVE_DATA =>
		if i_cs = '1' then    
	    	r_slave_state <= SLV_RECEIVE_DATA;
	    else
	    	r_slave_state <= SLV_IDLE;
	    end if;

		when TRANSFER_DATA_TO_MASTER =>

	end case;
end if;

end process; -- main



--------------------------------------------------------------------------------
--RECEIVE DATA PROCESS
--------------------------------------------------------------------------------
receive_data : process(i_spi_clk,r_slave_state,i_mosi) is
begin
  if r_slave_state = SLV_RECEIVE_DATA then
  	if rising_edge(i_spi_clk) then

	   if rx_cnt < C_data_length  then
	   	master_data <= master_data(master_data'high-1 downto 0)&i_mosi;
	   	rx_cnt <= rx_cnt + 1;
	   	--o_data_rx_ready <= '0';

	   else
	   	master_data <= master_data(master_data'high-1 downto 0)&i_mosi;

	   	rx_cnt <= 1; -- because when starting from 0 data had 9bit length
	   end if;

    end if;
  else 
  	--o_data_rx_ready <= '0';
	rx_cnt <= 0;
  end if;
end process; -- receive_data

--------------------------------------------------------------------------------
-- data ready process
--------------------------------------------------------------------------------
ready_flag : process(i_spi_clk,r_slave_state) is
begin
  if r_slave_state = SLV_RECEIVE_DATA then
  	if falling_edge(i_spi_clk) then
  		if rx_cnt = C_data_length then
  		o_data <= master_data;
  		o_data_rx_ready <= '1';
  		else
  		o_data_rx_ready <= '0';
  		end if;
    end if;
  else 
  	--o_data_rx_ready <= '0';
	o_data_rx_ready <= '0';
  end if;
end process; -- ready_flag

end Behavioral;

