

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity TOP is
    GENERIC(
    	C_data_i2c_length	: 	integer := 8;
		C_addr_length	: 	integer := 7;
		C_clk_speed 	: 	integer :=12000000; --current clock is 12 MHz may be changed later
		C_i2c_scl_speed : 	integer := 400000; -- can be also 100 kHz, 1.7 MHz and 3.4 MHz 
        C_clk_ratio 	: 	integer :=10;
        C_data_length	:	integer :=12
        );
    PORT(
        i_clk			:	in 	std_logic;
        i_reset_n		:	in 	std_logic;
    -- SPI signals
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
       -- o_rx_data_0		:	out std_logic_vector(C_data_length - 1 downto 0);
       -- o_rx_data_1		:	out std_logic_vector(C_data_length - 1 downto 0)
    -- I2C signal
		i_enable_i2c	: in  std_logic;
		i_addr_i2c 		: in  std_logic_vector(C_addr_length - 1 downto 0);
		i_r_w_bit 		: in  std_logic;
		i_data_0 		: in  std_logic_vector(C_data_i2c_length - 1 downto 0);
		o_busy 			: out std_logic;
		o_read_data_0	: out std_logic_vector(C_data_i2c_length - 1 downto 0);
		io_scl			: inout std_logic;
		io_sda 			: inout std_logic;

       --debug LED output
        --o_led 			: 	out std_logic
        o_led_dbg 		: out std_logic_vector(7 downto 0)
        );
end TOP;


architecture Behavioral of TOP is

signal r_rx_data_0 : std_logic_vector(C_data_length - 1 downto 0) := (others => '0');
signal r_rx_data_1 : std_logic_vector(C_data_length - 1 downto 0) := (others => '0');
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
	o_rx_data_0		=>r_rx_data_0,
	o_rx_data_1		=>r_rx_data_1,
	o_led_dbg 		=>o_led_dbg
);

I2C_MASTER_0: entity work.i2c_master 
generic map (
	C_data_length	=> 8,
	C_addr_length	=> 7,
	C_clk_speed 	=> 12000000,
	C_i2c_scl_speed => 400000
)
port map (
	i_clk 			=>i_clk,
	i_reset_n 		=>i_reset_n,
	i_enable_i2c	=>i_enable_i2c,
	i_addr_i2c 		=>i_addr_i2c,
	i_r_w_bit 		=>i_r_w_bit,
	i_data_0 		=>i_data_0,
	o_busy 			=>o_busy,
	o_read_data_0	=>o_read_data_0,
	io_scl			=>io_scl,
	io_sda 			=>io_sda
);

--LED_INDICATOR: entity work.led_indicator
--port map (
--	i_clk => i_clk,
--	o_led => o_led
--);

end architecture;