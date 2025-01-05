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
  C_i_clk_freq    : integer;
  C_max_spi_freq  : integer;
	C_clk_ratio 	  : integer;
	C_data_length	  :	integer;
  C_adc_data_len  : integer := 10;
  C_cmd_size      : integer := 8;
  C_data_size     : integer := 16
	);
PORT(
	i_clk			    :	in 	std_logic;
	i_reset_n		  :	in 	std_logic;
	i_enable		  :	in 	std_logic;
  i_params      : in  std_logic_vector(C_data_size - 1 downto 0);
--	i_clk_polarity	:	in  std_logic;
--	i_clk_phase		:	in 	std_logic;
  i_mem_ok      : in  std_logic;
	i_miso_0		  :	in 	std_logic;
	i_miso_1		  :	in 	std_logic;
	--i_address		:	in 	std_logic_vector(C_data_length downto 0);
  o_busy        : out std_logic;
	o_cs			    :	out std_logic;
	o_spi_clk		  :	out std_logic;
	o_mosi_0		  :	out	std_logic;
	o_rx_data_0		:	out std_logic_vector(C_adc_data_len- 1 downto 0);
	o_rx_data_1		:	out std_logic_vector(C_adc_data_len - 1 downto 0);
  o_data_ok     : out std_logic;
  --debug leds output, should display received command
  o_led_dbg     : out std_logic_vector(C_cmd_size - 1 downto 0)
	);
end spi_master;

architecture Behavioral of spi_master is
-- Constant to not excede maximum spi freq of ADC
constant C_clk_min_div : integer range 0 to 100 := C_i_clk_freq/C_max_spi_freq + 1; 

    type T_spi_states is (IDLE_SPI,
        TRANSFER,
        TRANSFER_DONE,
        FINISHED);

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

SIGNAL clk_ratio    : integer range 0 to 1000 := C_clk_ratio;

-- receive signals
SIGNAL rx_cmd           : std_logic_vector(C_cmd_size - 1 downto 0)  := (others => '0');
SIGNAL sample_cmd       : std_logic_vector(C_data_size - 1 downto 0) := "0000000000001000";
SIGNAL sample_cnt       : integer range 0 to 65535 := 0;
SIGNAL sample_max       : integer range 0 to 65535 := 0; -- max amount of samples from sample_cmd vector
SIGNAL rx_data          : std_logic_vector(C_cmd_size + C_data_size - 1 downto 0) := (others => '1');

begin

--o_cs <= cs;
o_spi_clk <= r_clk_state;

process(i_clk, i_reset_n)
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
o_busy <= '0';
ELSIF(rising_edge(i_clk)) then


CASE r_current_state IS 
--------------------------------------------------------------------------------
--IDLE_SPI STATE
--------------------------------------------------------------------------------
when IDLE_SPI => 
o_cs <= '1';
o_data_ok <= '0';
--clk_cnt <= 0;
--r_rx_register0 <= (others => '0');
--r_rx_register1 <= (others => '0');
--o_rx_data_0 <= (others => '0');
--o_rx_data_1 <= (others => '0');
-- o_mosi <= 'Z';


--CS state is inverted (active high instad of low) on STM32 it will be changed later
IF i_enable = '1' THEN 
  -- i_params is split for clk divider and samples count
  sample_max <= to_integer(unsigned(i_params(C_data_size - 7 downto 0)));
  r_clk_state <= i_clk_polarity;
  clk_ratio <= to_integer(unsigned(i_params(C_data_size - 1 downto C_data_size - 6)))+C_clk_min_div;
  --clk_ratio <= clk_ratio + 1; -- to avoid dividing with zero

  clk_cnt_ratio <= 0;
  clk_cnt <= 0;
  sample_cnt <= 0;
  o_cs <= '0';
  o_busy <= '1';
  --o_spi_clk <= r_clk_state;
  r_current_state <= TRANSFER;
ELSE
  o_busy <= '0';
  r_current_state <= IDLE_SPI;
END IF;


--------------------------------------------------------------------------------
--TRANSFER STATE - transfers data from adc to spi master
--------------------------------------------------------------------------------

when TRANSFER =>

    o_data_ok <= '0';
--if sample_cnt < sample_max then 
    if(clk_cnt_ratio = clk_ratio - 1) then
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
        o_rx_data_0 <= r_rx_register0(C_adc_data_len - 1 downto 0);
        o_rx_data_1 <= r_rx_register1(C_adc_data_len - 1 downto 0);
        o_cs <= '1';
        --sample_cnt <= sample_cnt + 1;
        r_current_state <= TRANSFER_DONE;
      else
        o_cs <= '0';
       -- r_current_state <= TRANSFER;
      end if;
    
    else
      clk_cnt_ratio <= clk_cnt_ratio + 1;
      --r_current_state <= TRANSFER;
    end if;
--else
  -- reseting rx_cmd so it will be forced to wait for another tranfer from kernel
  -- without this cs becomes a clock, comment if you want to see 
  -- something on debug LEDs

  --rx_cmd <= (others => '0');
  --o_busy <= '0';
  --r_current_state <= FINISHED;
--end if;


when TRANSFER_DONE =>
  --o_data_ok <= '1';
  if(i_mem_ok = '1') then
    if(sample_cnt < sample_max-1) then 
      
      sample_cnt <= sample_cnt + 1;
      r_current_state <= TRANSFER;
    else 

      rx_cmd <= (others => '0');
      o_busy <= '0';
      r_current_state <= FINISHED;
    end if;
    o_data_ok <= '0';
  else
    o_data_ok <= '1';
  end if;

when FINISHED =>

  o_busy <= '0';
  o_data_ok <= '0';
  if(i_enable = '0') then
    r_current_state <= IDLE_SPI;
  else
    r_current_state <= FINISHED;
  end if;
END CASE;

end if;


end process;

-- Display command on LED
o_led_dbg <= rx_cmd;


end Behavioral;

