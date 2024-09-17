----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:23:25 09/17/2024 
-- Design Name: 
-- Module Name:    dac_sim - Behavioral 
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

entity dac_sim is
    Port ( io_sda : inout  STD_LOGIC;
           io_scl : inout  STD_LOGIC);
end dac_sim;

architecture Behavioral of dac_sim is
	type T_dac_state is (
		IDLE,
		READ_ADDR, -- ack at the end
		READ_DATA, -- ack at the end
		STOP_STATE
		);

begin

-- data should be established before rising edge of the clock
-- so it can be read that way

rx_data : process(io_scl) is
	


begin
	

end process; -- rx_data

end Behavioral;

