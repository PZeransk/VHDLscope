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

end TOP_SIM;

architecture Behavioral of TOP_SIM is
    constant clk_time : time := 10 ns;
    constant cs_h : time := 30 ns;
    constant cs_l : time := 300 ns;

    signal clk  : std_logic := '0';
    signal miso : std_logic := '0';
    signal cs   : std_logic := '0';


begin


    TOP_ENT: entity work.TOP 
    port map(
        i_clk => clk,
        i_cs    => cs,
        o_miso0 => miso
    );

    clk_sim: process
    begin
        clk <= '0';
        wait for clk_time;
        clk <= '1';
        wait for clk_time;
    end process;

    cs_sim: process
    begin
        cs <= '0';
        wait for cs_l;
        cs <= '1';
        wait for cs_h;
    end process;

end Behavioral;

