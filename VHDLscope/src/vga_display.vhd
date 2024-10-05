----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:29:00 10/05/2024 
-- Design Name: 
-- Module Name:    vga_display - Behavioral 
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

entity vga_display is
generic (
	x_res 		: integer := 640;
	y_res 		: integer := 480;
	f_porch		: integer := 16;
	b_porch		: integer := 48;
	sync_pulse	: integer := 96;
	line_len	: integer := 800
);
port (
	i_pxl_clk 	: 	in  std_logic;
	i_reset_n	:	in  std_logic;
	o_h_sync	:	out std_logic;
	o_v_sync 	:	out std_logic;
	o_blue		:	out std_logic_vector(1 downto 0); --magic numbers are based on how
	o_green		: 	out std_logic_vector(2 downto 0); --vga is connected in hardware
	o_red		:	out std_logic_vector(2 downto 0) --check ElbertV2 schematic for reference
);

end vga_display;

architecture Behavioral of vga_display is

begin


end Behavioral;

