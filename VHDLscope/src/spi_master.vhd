----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:47:53 09/09/2024 
-- Design Name: 
-- Module Name:    spi_master - Behavioral 
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


entity spi_master is
GENERIC(
	C_clk_ratio 	: 	integer;
	C_data_length	:	integer;
  C_cmd_size   : integer := 8;
  C_data_size  : integer := 16
	);
PORT(
	i_clk			  :	in 	std_logic;
	i_reset_n		:	in 	std_logic;
	i_cs 			  :	in 	std_logic;
  i_spi_clk   : in  std_logic;
	i_enable		:	in 	std_logic;
  i_miso_stm    :   in  std_logic;
--	i_clk_polarity	:	in  std_logic;
--	i_clk_phase		:	in 	std_logic;
	i_miso_0		:	in 	std_logic;
	i_miso_1		:	in 	std_logic;
	--i_address		:	in 	std_logic_vector(C_data_length downto 0);
	o_cs			:	out std_logic;
	o_spi_clk		:	out std_logic;
	o_mosi_0		:	out	std_logic;
	o_rx_data_0		:	out std_logic_vector(C_data_length - 1 downto 0);
	o_rx_data_1		:	out std_logic_vector(C_data_length - 1 downto 0)
	);
end spi_master;

architecture Behavioral of spi_master is

    type T_spi_states is (IDLE_SPI,
        RECEIVE_CMD,
        TRANSFER);

SIGNAL r_current_state 	: T_spi_states 	:= IDLE_SPI;
SIGNAL r_cs_state		    : std_logic;
SIGNAL clk_cnt 			    : integer range 0 to C_data_length*2 + 1 := 0;
SIGNAL clk_cnt_ratio	  : integer range 0 to C_clk_ratio   := 0;
SIGNAL r_rx_register0	  : std_logic_vector(C_data_length - 1 downto 0) := (others => '0');
SIGNAL r_rx_register1	  : std_logic_vector(C_data_length - 1 downto 0) := (others => '0');
SIGNAL r_clk_state		  : std_logic := '0';
  
SIGNAL i_clk_polarity	  : std_logic := '1';
SIGNAL i_clk_phase		  : std_logic := '1';

SIGNAL w_miso_0 		    : std_logic;
SIGNAL w_miso_1 		    : std_logic;

SIGNAL cs 				      : std_logic := '1';
SIGNAL spi_clk 			    : std_logic := '1';

-- receive signals
SIGNAL rx_cmd           : std_logic_vector(C_cmd_size - 1 downto 0)  := (others => '0');
SIGNAL sample_cmd       : std_logic_vector(C_data_size - 1 downto 0) := (others => '0');
SIGNAL sample_cnt       : integer range 0 to 65535 := 0;
SIGNAL sample_max       : integer range 0 to 65535 := 0; -- max amount of samples from sample_cmd vector
SIGNAL rx_data          : std_logic_vector(C_cmd_size + C_data_size - 1 downto 0) := (others => '1');

begin

--o_cs <= cs;
o_spi_clk <= r_clk_state;

process(i_clk, i_reset_n, i_spi_clk, i_cs)
begin 
-- was =1

IF(i_reset_n = '0') then
o_cs <= '1';
o_rx_data_0 <= (others => '0');
o_rx_data_1 <= (others => '0');
--o_mosi <= 'Z';
clk_cnt_ratio <= 0;
r_current_state <= IDLE_SPI;
clk_cnt <= 0;
ELSIF(rising_edge(i_clk)) then


CASE r_current_state IS 
--------------------------------------------------------------------------------
--IDLE_SPI STATE
--------------------------------------------------------------------------------
when IDLE_SPI => 
o_cs <= '1';

--clk_cnt <= 0;
--r_rx_register0 <= (others => '0');
--r_rx_register1 <= (others => '0');
--o_rx_data_0 <= (others => '0');
--o_rx_data_1 <= (others => '0');
-- o_mosi <= 'Z';


--CS state is inverted (active high instad of low) on STM32 it will be changed later
IF i_cs = '1' then 
  r_current_state <= RECEIVE_CMD;
ELSIF rx_cmd = "00001000" and i_cs = '0' THEN 

  sample_max <= to_integer(unsigned(sample_cmd));
  r_clk_state <= i_clk_polarity;
  clk_cnt_ratio <= 0;
  clk_cnt <= 0;
  --o_spi_clk <= r_clk_state;
  r_current_state <= TRANSFER;
ELSE
  r_current_state <= IDLE_SPI;
END IF;

--------------------------------------------------------------------------------
--RECEIVE COMMAND STATE
--------------------------------------------------------------------------------
when RECEIVE_CMD =>


if i_cs = '0' then
  rx_cmd <= rx_data(rx_data'high downto rx_data'high - 7);
  sample_cmd <= rx_data(rx_data'high-8 downto 0);
  r_current_state <= IDLE_SPI;
end if;
--------------------------------------------------------------------------------
--TRANSFER STATE - transfers data from adc to spi master
--------------------------------------------------------------------------------

when TRANSFER =>
o_cs <= '0';

if sample_cnt < sample_max then 
    if(clk_cnt_ratio = C_clk_ratio - 1) then
      --o_spi_clk <= r_clk_state;
      clk_cnt <= clk_cnt + 1;
      clk_cnt_ratio <= 0;
      r_clk_state <= NOT r_clk_state;
      --o_spi_clk <= r_clk_state;
    
    
    
    
      if(r_clk_state = i_clk_phase AND clk_cnt <= C_data_length*2) then
      --if(clk_cnt <= C_data_length*2+1) then
        r_rx_register0 <= r_rx_register0(r_rx_register0'high - 1 downto r_rx_register0'low) & i_miso_0;
        r_rx_register1 <= r_rx_register1(r_rx_register1'high - 1 downto r_rx_register1'low) & i_miso_1;
      end if;
      
      if(clk_cnt = C_data_length*2+1) then
        clk_cnt <= 0;
        o_rx_data_0 <= r_rx_register0;
        o_rx_data_1 <= r_rx_register1;
        o_cs <= '1';
        sample_cnt <= sample_cnt + 1;
        --r_current_state <= IDLE_SPI;
      else
        
       -- r_current_state <= TRANSFER;
      end if;
    
    else
      clk_cnt_ratio <= clk_cnt_ratio + 1;
      --r_current_state <= TRANSFER;
    end if;
else
  -- reseting rx_cmd so it will be forced to wait for another tranfer from kernel
  rx_cmd <= (others => '0');
  r_current_state <= IDLE_SPI;
end if;

END CASE;

end if;


end process;


--------------------------------------------------------------------------------
--RECEIVE COMMAND PROCESS
--------------------------------------------------------------------------------
receive_data : process(i_spi_clk,r_current_state) is
begin
  if r_current_state = RECEIVE_CMD then

    if rising_edge(i_spi_clk) then 
      rx_data <= rx_data(rx_data'high - 1 downto rx_data'low) & i_miso_stm;
     -- w_miso_0 <= i_miso_stm; -- w_miso is only for debugging in simulation
    end if;
    
  end if;
end process; -- receive_data


end Behavioral;

