

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
        i_mosi_stm		: 	in  std_logic;
    --	i_clk_polarity	:	in  std_logic;
    --	i_clk_phase		:	in 	std_logic;
        i_miso_0		:	in 	std_logic;
        i_miso_1		:	in 	std_logic;
        --i_address		:	in 	std_logic_vector(C_data_length downto 0);
        o_cs			:	out std_logic;
        o_spi_clk		:	out std_logic;
        o_mosi_0		:	out	std_logic;
        o_miso_stm		:	out std_logic;

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
        o_DCM_clk		: out std_logic;
        o_led_dbg 		: out std_logic_vector(7 downto 0)
        );
end TOP;


architecture Behavioral of TOP is

-- VHDL Instantiation Created from source file CLK.vhd -- 22:43:40 12/29/2024
	COMPONENT CLK
	PORT(
		CLKIN_IN : IN std_logic;
		RST_IN : IN std_logic;          
		CLKFX_OUT : OUT std_logic;
		CLKIN_IBUFG_OUT : OUT std_logic;
		CLK0_OUT : OUT std_logic;
		CLK0_OUT1 : OUT std_logic;
		LOCKED_OUT : OUT std_logic;
		STATUS_OUT : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;


signal r_rx_data_0 	: std_logic_vector(C_data_length - 1 downto 0) := (others => '0');
signal r_rx_data_1 	: std_logic_vector(C_data_length - 1 downto 0) := (others => '0');
signal ack_err 		: std_logic:='0';
signal data_tx_dummy	: std_logic_vector(7 downto 0) := "11111111";
signal master_rx_data	: std_logic_vector(7 downto 0) :=(others => '0');
signal data_valid 		: std_logic :='0';
signal int_data_trig 	: std_logic_vector(15 downto 0)	:=(others =>'0');
signal int_cmd   	: std_logic_vector(7 downto 0)	:=(others =>'0');
signal finish_flag  : std_logic := '0';
signal spi_enable	: std_logic := '0';
signal spi_busy		: std_logic := '0';
signal DCM_clk_60	: std_logic := '0';
signal DCM_locked	: std_logic := '0';
signal DCM_status	: std_logic_vector(7 downto 0) := (others => '0');
signal DDR_DCM_clk	: std_logic := '0';
signal DCM_clk0_out	: std_logic := '0';
signal DCM_clk0_out1	: std_logic := '0';
signal reset 		: std_logic := '0';
signal init_reset_cnt	: integer range 0 to 3 :=0;
begin


--reset <= NOT i_reset_n;
o_DCM_clk <= DCM_clk_60;

-- DCM must have reset state active for at least 3 i_clk cycles
init_DCM_by_reset : process( i_clk, i_reset_n )
begin
	if (i_reset_n = '0') then
		init_reset_cnt <= 0;
		
	else
		if (rising_edge(i_clk) AND init_reset_cnt < 3) then
		reset <= '1';
		init_reset_cnt <= init_reset_cnt + 1;
		elsif(init_reset_cnt >= 3) then

		reset <= NOT i_reset_n;

		end if;
	end if;
end process ; -- init_reset

-- DCM instance
Inst_CLK: CLK 
PORT MAP(
		CLKIN_IN => i_clk,
		RST_IN => reset,
		CLKFX_OUT => DCM_clk_60,
		CLKIN_IBUFG_OUT => open,
		CLK0_OUT => DCM_clk0_out,
		CLK0_OUT1 => DCM_clk0_out1,
		LOCKED_OUT => DCM_locked,
		STATUS_OUT => DCM_status
	);

SPI_SLAVE_0: entity work.spi_slave
generic map(
	C_data_length	=>8,
  	C_cmd_size   	=>8,
  	C_data_size  	=>16
)
port map(
	i_clk			=>DCM_clk_60,
	i_reset_n		=>i_reset_n,
	i_cs            =>i_cs,
    i_spi_clk       =>i_spi_clk,
    i_mosi			=>i_mosi_stm,
	i_data_tx		=>data_tx_dummy,
	o_finish_flag   =>finish_flag,
	o_data			=>master_rx_data,
	o_miso			=>o_miso_stm,
	o_data_rx_ready	=>data_valid
);

SPI_SLAVE_CONTROLLER: entity work.slave_controller 
generic map(
	C_data_length	=>8,
  	C_cmd_size   	=>8,
  	C_data_size  	=>16
	)
port map(
	i_clk				=> DCM_clk_60,
	i_reset_n			=> i_reset_n,
	i_rx_data 			=> master_rx_data,
	i_rx_data_ready 	=> data_valid,
	i_data_cnt_reset	=> '0',
	i_finish			=> finish_flag,
	i_master_busy 		=> spi_busy,
	o_en_trigger		=> spi_enable,
	o_cmd 				=> int_cmd,
	o_data_trig			=> int_data_trig

	);

SPI_MASTER_0: entity work.spi_master
generic map(
    C_clk_ratio 	=> C_clk_ratio,
	C_data_length	=> C_data_length
)
port map(
	i_clk			=>DCM_clk_60	,
	i_reset_n		=>i_reset_n,
	i_enable		=>spi_enable,
	i_params		=>int_data_trig,
	i_miso_0		=>i_miso_0,
	i_miso_1		=>i_miso_1,

	o_busy			=>spi_busy,
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
	i_clk 			=>DCM_clk_60,
	i_reset_n 		=>i_reset_n,
	i_enable_i2c	=>i_enable_i2c,
	i_addr_i2c 		=>i_addr_i2c,
	i_r_w_bit 		=>i_r_w_bit,
	i_data_0 		=>i_data_0,
	o_busy 			=>o_busy,
	o_read_data_0	=>o_read_data_0,
	o_ack_err 		=>ack_err,
	io_scl			=>io_scl,
	io_sda 			=>io_sda
);

--LED_INDICATOR: entity work.led_indicator
--port map (
--	i_clk => i_clk,
--	o_led => o_led
--);

end architecture;