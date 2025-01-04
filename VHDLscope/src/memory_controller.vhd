----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:57:49 01/02/2025 
-- Design Name: 
-- Module Name:    memory_controller - Behavioral 
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
-- User guide, starts at page 165
-- https://docs.amd.com/v/u/en-US/ug331
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

entity memory_controller is
GENERIC(
	C_adc_data_len	: integer := 10;
	C_addr_len			: integer := 10
	);
PORT(
	i_clk			:	in 	std_logic;
	i_reset_n		:	in 	std_logic;
	--i_enable		:	in 	std_logic;
	i_adc_data_ok	:	in  std_logic;
  	i_adc_0_data	: 	in  std_logic_vector(C_adc_data_len - 1 downto 0);
  	i_adc_1_data	: 	in  std_logic_vector(C_adc_data_len - 1 downto 0);
  	o_addr_0		: 	out std_logic_vector(C_addr_len - 1 downto 0);
  	o_addr_1		: 	out std_logic_vector(C_addr_len - 1 downto 0);
  	o_we_0			: 	out std_logic_vector(0 downto 0);
  	o_we_1			: 	out std_logic_vector(0 downto 0);
  	o_mem_ok		: 	out std_logic;
	o_mem_rst		: 	out std_logic;
	o_mem_enable	:	out std_logic
	);


end memory_controller;

architecture Behavioral of memory_controller is
	
	constant addr_max : std_logic_vector(C_addr_len - 1 downto 0) := (others => '1'); 
	constant addr_min : std_logic_vector(C_addr_len - 1 downto 0) := (others => '0'); 
	type T_mem_states is(
		IDLE,
		MEM_WRITE,
		MEM_READ
		);
	signal current_state	:	T_mem_states := IDLE;

	signal temp_addr_0 : std_logic_vector(C_addr_len - 1 downto 0) := (others => '0');
	signal temp_addr_1 : std_logic_vector(C_addr_len - 1 downto 0) := (others => '0');



begin

memory_state_machine : process( i_clk, i_reset_n )
begin
o_mem_rst <= NOT i_reset_n;

if i_reset_n = '0' then
  o_we_0 <= "0";
  o_we_1 <= "0";
  o_addr_0 <= (others => '0');
  o_addr_1 <= (others => '0');
  o_mem_enable <= '0';
  current_state <= IDLE;
  o_mem_ok <= '0';
elsif rising_edge(i_clk) then
	case current_state is
		when IDLE =>
			--o_we_0 <= "0";
  			--o_we_1 <= "0";
  			--o_mem_enable <= '0';
  			if i_adc_data_ok = '1' then
  				o_mem_ok <= '1';
  				current_state <= MEM_WRITE;
  			else 
  				o_mem_ok <= '0';
  				current_state <= IDLE;
  			end if;

  			

		when MEM_WRITE =>
			--o_we_0 <= "1";
  			--o_we_1 <= "1";
  			--o_mem_enable <= '1';
  			
  			o_mem_ok <= '0';
  			current_state <= IDLE;
		when MEM_READ =>
			--o_we_0 <= "0";
  			--o_we_1 <= "0";
  			--o_mem_enable <= '1';
  			o_mem_ok <= '0';
  			current_state <= IDLE;

end case;

end if;
end process ; -- memory_state_machine

write_memory : process( i_clk, i_adc_data_ok )
begin
	
end process ; -- write_memory

end Behavioral;

