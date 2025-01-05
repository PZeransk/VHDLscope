----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:35:54 09/10/2024 
-- Design Name: 
-- Module Name:    master_board_spi - Behavioral 
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

entity master_board_spi is
    generic (
        C_delay      : integer := 100;
        C_clk_div    : integer := 6; -- is around 8 MHz with 50 MHz input clk
        C_cmd_size   : integer := 8;
        C_data_size  : integer := 16 -- because stm32mp157 can send only multiplied 8 bit word size
    );
    Port ( o_mosi      : out STD_LOGIC;
           o_cs        : out STD_LOGIC;
           o_spi_clk   : out STD_LOGIC;
           i_cmd_sel   : in  std_logic_vector(1 downto 0); -- should make selecting commands easier
           i_miso      : in  STD_LOGIC;
           i_clk       : in  STD_LOGIC; -- it will be internal STM32MP157 clock
           i_trigger   : in  STD_LOGIC; -- trigger is only for simulation, this will be carried out by kernel command
           i_reset_n   : in  std_logic
           );
end master_board_spi;

architecture Behavioral of master_board_spi is

type T_spi_states is (
  SPI_IDLE,
  SPI_PRE_TRANSFER,
  SPI_TRANSFER,
  SPI_POST_TRANSFER
  );

constant r_trigger_cmd    : std_logic_vector(C_cmd_size-1 downto 0)  := "00001000";
constant r_fun_gen_cmd    : std_logic_vector(C_cmd_size-1 downto 0)  := "00001001";

signal r_current_state  : T_spi_states  := SPI_IDLE;

signal sample_size_cmd  : std_logic_vector(C_data_size-1 downto 0) := "0000000000000111";
signal cmd_to_send      : std_logic_vector(C_cmd_size+C_data_size-1 downto 0) := (others => '0');
signal clk_cnt          : integer range 0 to C_clk_div := 0;
signal total_size       : integer range 0 to C_cmd_size+C_data_size := C_cmd_size+C_data_size;
signal spi_clk_state    : std_logic := '0';
signal spi_clk_cnt      : integer range 0 to total_size*2 := 0;
signal i_clk_polarity   : std_logic := '1';
signal i_clk_phase      : std_logic := '1';
signal spi_send_reg     : std_logic_vector(total_size - 1 downto 0) := (others => '0');
signal delay_cnt        : integer range 0 to C_delay := 0;

begin

spi_process : process(i_clk) is
begin

if i_reset_n = '0' then
  clk_cnt <= 0;
  spi_clk_cnt <= 0;
  o_cs <= '0';
  cmd_to_send <= r_trigger_cmd&sample_size_cmd;
  r_current_state <= SPI_IDLE;
elsif rising_edge(i_clk) then

case r_current_state IS
--------------------------------------------------------------------------------
-- IDLE state
--------------------------------------------------------------------------------

  when SPI_IDLE =>
    o_cs <= '0';
    clk_cnt <= 0;
    spi_clk_cnt <= 0;
    if i_cmd_sel = "00" then
      cmd_to_send <= r_trigger_cmd&sample_size_cmd;
    elsif i_cmd_sel = "01" then
      cmd_to_send <= r_fun_gen_cmd&sample_size_cmd;
    end if;

    if i_trigger = '0' then
      r_current_state <= SPI_PRE_TRANSFER;


    end if;
--------------------------------------------------------------------------------
-- on stm board data is being transfered long after CS activation
--------------------------------------------------------------------------------


  when SPI_PRE_TRANSFER =>
  o_cs <= '1';

  if delay_cnt <= C_delay-1 then
    delay_cnt <= delay_cnt + 1;
  else
    delay_cnt <= 0;
    r_current_state <= SPI_TRANSFER;
  end if;

--------------------------------------------------------------------------------
-- data transfer
--------------------------------------------------------------------------------

  when SPI_TRANSFER =>
  o_cs <= '1';

  if clk_cnt = C_clk_div-1 then
    clk_cnt <= 0;
    spi_clk_state <= NOT spi_clk_state;
    spi_clk_cnt <= spi_clk_cnt + 1;

  

      if spi_clk_state = i_clk_phase and spi_clk_cnt < total_size*2 then 
      -- push zero to command to avoid double sending
        cmd_to_send <= cmd_to_send(cmd_to_send'high - 1 downto cmd_to_send'low)&'0';
       
      end if;
    
      if spi_clk_cnt = total_size*2 then
        spi_clk_state <= '0'; 
        r_current_state <= SPI_POST_TRANSFER;
      end if;
  else

    clk_cnt <= clk_cnt + 1;
  end if;

--------------------------------------------------------------------------------
-- on stm board CS state is held long after data transfer
--------------------------------------------------------------------------------


  when SPI_POST_TRANSFER =>
  o_cs <= '1';
  spi_clk_state <= '0';
  if delay_cnt <= C_delay-1 then
    delay_cnt <= delay_cnt + 1;
  else
    delay_cnt <= 0;
    r_current_state <= SPI_IDLE;
  end if;


end case;

end if;

end process; -- spi_process
o_spi_clk <= spi_clk_state;
 o_mosi <= cmd_to_send(cmd_to_send'high);
end Behavioral;

