
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

--! SPI slave controller. Used to connect spi_slave to rest of the design.
--! It decides what action to take according to received command.

--! \param C_data_length	Length of data in one SPI block
--! \param C_cmd_size   	Size of command
--! \param C_data_size  	Size of data following command

entity slave_controller is
GENERIC(
	C_data_length	:	integer := 8;
  	C_cmd_size   	: 	integer := 8;
  	C_data_size  	: 	integer := 16
	);
PORT(
	i_clk			:	in 	std_logic;  --! Input clock
	i_reset_n		:	in 	std_logic;  --! Reset Active low
	i_rx_data 		:	in  std_logic_vector(C_data_length - 1 downto 0); --! Data received from master
	i_rx_data_ready :	in 	std_logic; --! High if data from master was received by FPGA
	i_data_cnt_reset: 	in  std_logic; --! Resets counter

	i_finish		: 	in std_logic; --! Finish flag
	
	i_master_busy 	: 	in std_logic; --! Busy flag

	--o_data_ok 		:   out std_logic;
	o_en_gen  		:	out std_logic; --! Enables function generator
	o_data_gen 		: 	out std_logic_vector(2*C_data_length - 1 downto 0); --! Data to function generator
	o_en_trigger	:	out std_logic; --! Triggers ADC measurment
	o_en_read 		: 	out std_logic; --! Enables read from memory
	o_cmd 			: 	out std_logic_vector(C_cmd_size - 1 downto 0); --! Output command
	o_data_trig		:	out std_logic_vector(2*C_data_length - 1 downto 0)--! Data received from master
	);
end slave_controller;

architecture Behavioral of slave_controller is



constant C_trigger_cmd : std_logic_vector(C_cmd_size - 1 downto 0)  := "00001000"; 
constant C_fun_gen_cmd : std_logic_vector(C_cmd_size - 1 downto 0)  := "00001001";
constant C_read_mem    : std_logic_vector(C_cmd_size - 1 downto 0)  := "00001010"; 	
constant array_size : integer := C_data_size/C_data_length; 

type T_rx_array is array (0 to array_size - 1) of std_logic_vector(C_data_length - 1 downto 0);


SIGNAL rx_array : T_rx_array;
SIGNAL rx_data 	: std_logic_vector(C_data_size - 1 downto 0) := (others => '0');

SIGNAL rx_cmd	: std_logic_vector(C_cmd_size - 1 downto 0) := (others => '0');
SIGNAL data_cnt : integer range 0 to 3 := 0;
SIGNAL data_ok 	: std_logic := '0'; 
signal en_read 	: std_logic := '0';
begin


-----------------------------------------------------
-- Get data from slave when o_data_rx_ready is high
-----------------------------------------------------
process(i_clk, i_reset_n, i_rx_data_ready)
begin


if i_reset_n = '0' then -- or data_reset is high
	data_cnt <= 0;
	rx_data <= (others => '0');
elsif rising_edge(i_clk) then -- active only when cs is high
	if i_finish = '0' then
		if(i_rx_data_ready = '1' AND data_ok = '0') then
			if(data_cnt = 0) then
				rx_cmd <= i_rx_data;
			else
				rx_array(data_cnt - 1) <= i_rx_data;
			end if;
				data_cnt <= data_cnt + 1;
				data_ok <= '1';
			elsif (i_rx_data_ready = '0' AND data_ok = '1') then
				data_ok <= '0';
				
		end if;
	else
		data_cnt <= 0;
		rx_cmd <= (others => '0');
		rx_data <= (others => '0');
	end if;

end if ;



end process;

---------------------------------------------------
-- send data accordingly to command
---------------------------------------------------
process(i_clk)
begin

if i_reset_n = '0' then -- or data_reset is high
	en_read <= '0';
	o_en_trigger <= '0';
	o_en_gen <= '0';
elsif rising_edge(i_clk) then
	if((rx_cmd = C_trigger_cmd AND data_cnt = 3 ) OR i_master_busy = '1') then
		o_en_trigger <= '1';
		o_en_gen <= '0';
		o_data_trig <= rx_array(0)&rx_array(1);
	else 
		o_en_trigger <= '0';
		o_en_gen <= '0';
	end if;

	if (rx_cmd = C_fun_gen_cmd AND data_cnt = 3) then
	--to sig gen
		o_en_trigger <= '0';
		o_en_gen <= '1';
		o_data_gen<= rx_array(0)&rx_array(1);

	end if;


	if (rx_cmd = C_read_mem AND data_cnt = 3) then
	--to sig gen
		en_read <= '1';

	end if;

end if;

o_en_read <= en_read;

end process;




read_mem_and_send_to_master : process( i_clk )
begin
	
	if i_reset_n = '0' then -- or data_reset is high

	elsif rising_edge(i_clk) then
		if(en_read = '1') then
			
		end if;

	end if;
end process ; -- read_mem_and_send_to_master

end Behavioral;

