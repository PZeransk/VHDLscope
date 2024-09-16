----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:55:35 09/15/2024 
-- Design Name: 
-- Module Name:    i2c_master - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity i2c_master is
	generic (
		C_data_length	: integer := 8;
		C_addr_length	: integer := 7;
		C_clk_speed 	: integer :=12000000; --current clock is 12 MHz may be changed later
		C_i2c_scl_speed : integer := 400000 -- can be also 100 kHz, 1.7 MHz and 3.4 MHz 
	);
	port (
	i_clk 			: in  std_logic;
	i_reset_n 		: in  std_logic;
	i_enable_i2c	: in  std_logic;
	i_addr_i2c		: in  std_logic_vector(C_addr_length - 1 downto 0);
	i_r_w_bit 		: in  std_logic;
	i_data_0 		: in  std_logic_vector(C_data_length - 1 downto 0);
	o_busy 			: out std_logic;
	o_read_data_0	: out std_logic_vector(C_data_length - 1 downto 0);
	io_scl			: inout std_logic;
	io_sda 			: inout std_logic
	);
end i2c_master;

architecture Behavioral of i2c_master is
	type T_i2c_state is (
		IDLE,
		START,
		ADRESS,
		SLV_ACK_1,
		I2C_WRITE,
		I2C_READ,
		SLV_ACK_2,
		I2C_FINISH
		);

	signal r_current_i2c_state : T_i2c_state := IDLE;
	signal scl_state : std_logic := '1';
	signal sda_state : std_logic := '1';
-- setup and hold time for start stop condition
-- for MCP47x6 should be 600 ns for 400kHz and 160 ns for 1.7 MHz and 3.4 MHz

-- data should change when clock state is low
	constant clk_divider 	: integer range 0 to 100 := C_clk_speed/C_i2c_scl_speed/4;
	signal in_clk_cnt 	: integer range 0 to clk_divider := 0;
	signal div_cnt 		: integer range 0 to 4 :=0; -- 4 because clk_divider should be counted 4 times for one full sequence
	signal clk_ena 		: std_logic := '0';
--MCP4726Ax adresses are in datasheet on page 46
	signal r_dummy_data : std_logic_vector(C_data_length - 1 downto 0):="10101010";
	signal r_addr_A0 	: std_logic_vector(C_addr_length - 1 downto 0):="1100000";
	signal r_addr_A2 	: std_logic_vector(C_addr_length - 1 downto 0):="1100010";

begin

i2c_gen_clk : process(i_clk) is
begin

	if i_reset_n = '0' then

	elsif rising_edge(i_clk) then
		
		if clk_ena = '1' then
			if in_clk_cnt = clk_divider - 1 then
				div_cnt <= div_cnt + 1;
				in_clk_cnt <= 0;
					if div_cnt = 3 then
						div_cnt <= 0;
					end if;
			else
				in_clk_cnt <= in_clk_cnt + 1;
			end if;

			if div_cnt = 0 then
				scl_state <= '0';
			elsif div_cnt = 1 then
				scl_state <= '1';
			elsif div_cnt = 2 then
				scl_state <= '1';
			elsif div_cnt = 3 then
				
				scl_state <= '0';
			end if;
	
	
		else 
			scl_state <= '1';
		end if;
	end if;

end process; -- i2c_gen_clk

process(i_clk, i_reset_n) is
begin
	if i_reset_n = '0' then
		r_current_i2c_state <= IDLE;
	elsif rising_edge(i_clk) then
		CASE r_current_i2c_state IS 

		when IDLE => 
		-- idle should be active for setup/hold time if I2C_FINISH state didnt happen
		--scl_state <= '1';
		sda_state <= '1';

		if i_enable_i2c = '1' then
		-- pulling sda to zero before scl is a start condition
			
			r_current_i2c_state <= START;
		end if;

		when START =>
		--pulling scl low after SDA low completes start condition

			sda_state <= '0';

			--scl_state <= '0'; -- pull to zero after and goto nex state after setup tiem
			r_current_i2c_state <= ADRESS;
			-- enable scl clock generation process
			clk_ena <= '1';

		when ADRESS => 


			-- clock cycle divided into 4 parts
			if div_cnt = 0 then

				sda_state <= r_addr_A0(r_addr_A0'high);
				r_addr_A0 <= r_addr_A0(r_addr_A0'high-1 downto r_addr_A0'low)&r_addr_A0(r_addr_A0'high);

			elsif div_cnt = 1 then
				
			elsif div_cnt = 2 then
				
			elsif div_cnt = 3 then

			end if;
		when SLV_ACK_1 =>

		-- if ack is ok, go to state described with R/W bit

		when I2C_READ =>

		-- currently not needed

		when I2C_WRITE =>

		-- write data to DAC then wait for 

		when SLV_ACK_2 =>

		-- if OK go back to I2C_WRITE untill data stream isnt finished or some
		-- other stop condition isnt met

		when I2C_FINISH =>

		-- pull SCL high
		-- wait for hold/setup time
		-- pull SDA high
		-- go to I2C_IDLE

		end CASE;
	end if;
	
end process; -- 


io_sda <= sda_state;
io_scl <= scl_state;



end Behavioral;

