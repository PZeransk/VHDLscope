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
    constant clk_time : time := 10 ns;
    constant cs_h : time := 30 ns;
    constant cs_l : time := 300 ns;

    signal clk  : std_logic := '0';
    signal miso_0 : std_logic := '0';
    signal cs   : std_logic := '0';

    signal i_clk			:   std_logic := '0';
    signal reset_n		:   std_logic := '1';
    signal enable		    :   std_logic := '1';

    signal miso_1           :   std_logic := '0';
    signal o_spi_clk        :   std_logic := '0';
    signal o_mosi_0         :   std_logic := '0';
    signal o_rx_data_0      :   std_logic_vector(C_data_length - 1 downto 0):=(others => '0');
    signal o_rx_data_1      :   std_logic_vector(C_data_length - 1 downto 0):=(others => '0');

begin


    TOP_ENT: entity work.TOP 
    GENERIC MAP(
        C_clk_ratio 	=>  10,
        C_data_length	=>	C_data_length
        )
    port map(
        i_clk			=>clk,
        i_reset_n		=>reset_n,
    
        i_enable		=>enable,
    
        i_miso_0		=>miso_0,
        i_miso_1		=>miso_1,
    
        o_cs			=>cs,
        o_spi_clk		=>o_spi_clk,
        o_mosi_0		=>o_mosi_0,
        o_rx_data_0		=>o_rx_data_0,
        o_rx_data_1		=>o_rx_data_1
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


end Behavioral;

