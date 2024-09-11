

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity TOP is
    GENERIC(
        C_clk_ratio 	: 	integer :=10;
        C_data_length	:	integer :=12
        );
    PORT(
        i_clk			:	in 	std_logic;
        i_reset_n		:	in 	std_logic;
        i_cs 			:	in 	std_logic;
        i_spi_clk 		: 	in  std_logic;
        i_enable		:	in 	std_logic;
        i_miso_stm		: 	in  std_logic;
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
end TOP;


architecture Behavioral of TOP is

begin

SPI_MASTER_0: entity work.spi_master
generic map(
    C_clk_ratio 	=> C_clk_ratio,
	C_data_length	=> C_data_length
)
port map(
	i_clk			=>i_clk	,
	i_reset_n		=>i_reset_n,
	i_cs            =>i_cs,
    i_spi_clk       =>i_spi_clk,
	i_enable		=>i_enable,
	i_miso_stm		=>i_miso_stm,
	i_miso_0		=>i_miso_0,
	i_miso_1		=>i_miso_1,

	o_cs			=>o_cs	,
	o_spi_clk		=>o_spi_clk,
	o_mosi_0		=>o_mosi_0,
	o_rx_data_0		=>o_rx_data_0,
	o_rx_data_1		=>o_rx_data_1
);


end architecture;