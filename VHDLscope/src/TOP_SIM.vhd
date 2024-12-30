----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:52:35 09/07/2024 
-- Design Name: 
-- Module Name:    TOP_SIM - Behavioral 
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

entity TOP_SIM is
    generic (
        C_data_length : integer := 12
    );
end TOP_SIM;

architecture Behavioral of TOP_SIM is
-- timings constants
    constant clk_time       : time := 41.667 ns;
    constant cs_h           : time := 30 ns;
    constant cs_l           : time := 300 ns;
--TOP SIGNALS
    signal clk              : std_logic := '0';
    signal miso_0           : std_logic := '0';
    signal cs               : std_logic := '0';

    signal i_clk			:   std_logic := '0';
    signal reset_n		    :   std_logic := '1';
    signal enable		    :   std_logic := '0';

    signal miso_1           :   std_logic := '0';
    signal o_spi_clk        :   std_logic := '0';
    signal o_mosi_0         :   std_logic := '0';
    signal led_dbg          :   std_logic_vector(7 downto 0);
   -- signal o_rx_data_0      :   std_logic_vector(C_data_length - 1 downto 0):=(others => '0');
   -- signal o_rx_data_1      :   std_logic_vector(C_data_length - 1 downto 0):=(others => '0');
-- STM SIM signals
    signal stm_mosi         :   std_logic :='0';
    signal stm_cs           :   std_logic :='0';
    signal stm_spi_clk      :   std_logic :='0';
    signal stm_miso         :   std_logic :='0';
    signal trigger          :   std_logic :='1';
-- i2c signals
    signal enable_i2c       :   std_logic :='0';
    signal addr_i2c         :   std_logic_vector(6 downto 0):="1100010"; --7 bit addr
    signal r_w_bit          :   std_logic :='0';
    signal data_0           :   std_logic_vector(7 downto 0):="10101010"; -- 8 bit data
    signal busy             :   std_logic :='0';
    signal read_data_0      :   std_logic_vector(7 downto 0); -- 8 bit data
    signal scl              :   std_logic :='0';
    signal sda              :   std_logic :='0';

-- i2c dac sim signals
    signal MCP4726A2_addr   :   std_logic_vector(6 downto 0):="1100010";
    signal sda_nc           : std_logic := '0';
    signal scl_nc           : std_logic := '0';
begin
    

    -- i_cmd_sel cheat sheet for STM32_SIM entity
    -- "00" - measure signal
    -- "01" - start function generator
    -- "10" - not used
    -- "11" - not used

    STM32_SIM : entity work.master_board_spi
    generic map (
        C_clk_div   => 6,
        C_cmd_size  => 8,
        C_data_size => 16
    )
    port map (
        o_mosi      =>stm_mosi,
        o_cs        =>stm_cs,
        o_spi_clk   =>stm_spi_clk,
        i_cmd_sel   =>"00",
        i_miso      =>stm_miso,
        i_clk       =>clk,
        i_trigger   =>trigger,
        i_reset_n   =>reset_n
    );

    TOP_ENT: entity work.TOP 
    GENERIC MAP(
        C_clk_ratio 	=>  10,
        C_data_length	=>	C_data_length
        )
    port map(
        i_clk			=>clk,
        i_reset_n		=>reset_n,
        i_cs            =>stm_cs,
        i_spi_clk       =>stm_spi_clk,
        i_enable		=>enable,
        i_mosi_stm      =>stm_mosi,
        i_miso_0		=>miso_0,
        i_miso_1		=>miso_1,
    
        o_cs			=>cs,
        o_spi_clk		=>o_spi_clk,
        o_mosi_0		=>o_mosi_0,
        o_miso_stm      =>stm_miso,
        --o_rx_data_0		=>o_rx_data_0,
        --o_rx_data_1		=>o_rx_data_1
        i_enable_i2c    =>enable_i2c,
        i_addr_i2c      =>addr_i2c,
        i_r_w_bit       =>r_w_bit,
        i_data_0        =>data_0,
        o_busy          =>busy,
        o_read_data_0   =>read_data_0,
        io_scl          =>scl,
        io_sda          =>sda,

        o_DCM_clk       =>open,
        o_led_dbg       =>led_dbg
    );

    DAC_SIM_0: entity work.dac_sim 
    port map (
        io_sda      => sda,
        i_scl      => scl,
        i_dev_addr => MCP4726A2_addr
    );


    ADC_SIM_0: entity work.adc_sim
    port map(
        i_clk   => o_spi_clk,
        i_cs    => cs,
        o_miso0 => miso_0
    );

    ADC_SIM_1: entity work.adc_sim
    port map(
        i_clk   => o_spi_clk,
        i_cs    => cs,
        o_miso0 => miso_1
    );

    clk_sim: process
    begin
        clk <= '0';
        wait for clk_time;
        clk <= '1';
        wait for clk_time;
    end process;

    reset_n <= '0', '1' after 100 ns;
    trigger <= '0','1' after 300 ns;
    enable_i2c <= '1','0' after 20000 ns;

end Behavioral;

