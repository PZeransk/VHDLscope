

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity TOP is
    GENERIC(
    	C_data_i2c_length	: 	integer := 8;
		C_addr_length		: 	integer := 7;
		C_clk_speed 		: 	integer := 12000000; --current clock is 12 MHz may be changed later
		C_i2c_scl_speed 	: 	integer := 400000; -- can be also 100 kHz, 1.7 MHz and 3.4 MHz 
        C_clk_ratio 		: 	integer := 10;
        C_adc_data_len  	: 	integer := 10;
        C_data_length		:	integer := 12
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
		--i_enable_i2c	: in  std_logic;
		--i_addr_i2c 		: in  std_logic_vector(C_addr_length - 1 downto 0);
		--i_r_w_bit 		: in  std_logic;
		--i_data_0 		: in  std_logic_vector(C_data_i2c_length - 1 downto 0);
		--o_busy 			: out std_logic;
		--o_read_data_0	: out std_logic_vector(C_data_i2c_length - 1 downto 0);
		io_scl			: inout std_logic;
		io_sda 			: inout std_logic;

       --debug LED output
        --o_led 			: 	out std_logic
        --o_DCM_clk		: out std_logic;
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
-- Memory component generated with IP core
COMPONENT adc_mem
  PORT (
    clka : IN STD_LOGIC;
    rsta : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
    clkb : IN STD_LOGIC;
    rstb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
  );
END COMPONENT;


signal r_rx_data_0 	: std_logic_vector(C_adc_data_len - 1 downto 0) := (others => '0');
signal r_rx_data_1 	: std_logic_vector(C_adc_data_len - 1 downto 0) := (others => '0');
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
signal data_ok_spi		: std_logic := '0';
signal dummy_sig0	: std_logic := '0';
-- RAM signals
signal mem_enable 	: std_logic := '0';
signal wr_en_a		: std_logic_vector(0 downto 0) := (others => '0');
signal addr_a		: std_logic_vector(9 downto 0) := (others => '0');
signal data_in_a	: std_logic_vector(9 downto 0) := (others => '0');
signal data_out_a	: std_logic_vector(9 downto 0) := (others => '0');
signal enb 			: std_logic := '0';
signal wr_en_b 		: std_logic_vector(0 downto 0) := (others => '0');
signal addr_b		: std_logic_vector(9 downto 0) := (others => '0');
signal data_in_b 	: std_logic_vector(9 downto 0) := (others => '0');
signal data_out_b 	: std_logic_vector(9 downto 0) := (others => '0');
signal mem_reset	: std_logic := '0';
signal mem_ok_adc	: std_logic := '0';
signal data_to_mem_a :std_logic_vector(9 downto 0) := (others => '0');
signal data_to_mem_b :std_logic_vector(9 downto 0) := (others => '0');
-- i2c signals
    signal enable_i2c       :   std_logic :='0';
    signal addr_i2c         :   std_logic_vector(6 downto 0):="1100010"; --7 bit addr
    signal r_w_bit          :   std_logic :='0';
    signal data_0           :   std_logic_vector(7 downto 0):="10101010"; -- 8 bit data
    signal busy             :   std_logic :='0';
    signal read_data_0      :   std_logic_vector(7 downto 0); -- 8 bit data
    signal scl              :   std_logic :='0';
    signal sda              :   std_logic :='0';


begin


--reset <= NOT i_reset_n;
--o_DCM_clk <= DCM_clk_60;

-- DCM must have reset state active for at least 3 i_clk cycles
init_DCM_by_reset : process( i_clk, i_reset_n )
begin
	if (i_reset_n = '0') then
		init_reset_cnt <= 0;
		
	else

		if (rising_edge(i_clk) AND init_reset_cnt < 3) then

		init_reset_cnt <= init_reset_cnt + 1;

		end if;

		if(init_reset_cnt >= 3) then
			reset <= NOT i_reset_n;
		else
			reset <= '1';
		end if;

	end if;
end process ; -- init_reset

-- DCM instance
Inst_CLK: CLK 
PORT MAP(
		CLKIN_IN => i_clk,
		RST_IN => reset,
		CLKFX_OUT => DCM_clk_60,
		CLKIN_IBUFG_OUT => dummy_sig0,
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
	i_clk			=>DCM_clk_60,
	i_reset_n		=>i_reset_n,
	i_enable		=>spi_enable,
	i_params		=>int_data_trig,
	i_mem_ok		=>mem_ok_adc,
	i_miso_0		=>i_miso_0,
	i_miso_1		=>i_miso_1,

	o_busy			=>spi_busy,
	o_cs			=>o_cs,
	o_spi_clk		=>o_spi_clk,
	o_mosi_0		=>o_mosi_0,
	o_rx_data_0		=>r_rx_data_0,
	o_rx_data_1		=>r_rx_data_1,
	o_data_ok		=>data_ok_spi,
	o_led_dbg 		=>o_led_dbg
);


ADC_MEM_CONTROLLER: entity work.memory_controller
generic map(
	C_adc_data_len	=> C_adc_data_len,
	C_addr_len		=> 10
)
port map (
	i_clk			=>DCM_clk_60,
	i_reset_n		=>i_reset_n,
	--i_enable		=>
	i_adc_data_ok	=>data_ok_spi,
	i_adc_0_data	=>r_rx_data_0,
	i_adc_1_data	=>r_rx_data_1,
	o_addr_0		=>addr_a,
	o_addr_1		=>addr_b,
	o_data_to_mem_0 =>data_to_mem_a,
	o_data_to_mem_1 =>data_to_mem_b,
	o_we_0			=>wr_en_a,
	o_we_1			=>wr_en_b,
	o_mem_ok		=>mem_ok_adc,
	o_mem_rst		=>mem_reset,
	o_mem_enable	=>mem_enable
);

ADC_MEMORY: adc_mem
  PORT MAP (
    clka 	=> DCM_clk_60,
    rsta 	=> mem_reset,
    ena 	=> mem_enable,
    wea 	=> wr_en_a,
    addra 	=> addr_a,
    dina 	=> data_to_mem_a,
    douta 	=> data_out_a,
    clkb 	=> DCM_clk_60,
    rstb 	=> mem_reset,
    enb 	=> mem_enable,
    web 	=> wr_en_b,
    addrb 	=> addr_b,
    dinb 	=> data_to_mem_b,
    doutb 	=> data_out_b
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
	i_enable_i2c	=>enable_i2c,
	i_addr_i2c 		=>addr_i2c,
	i_r_w_bit 		=>r_w_bit,
	i_data_0 		=>data_0,
	o_busy 			=>busy,
	o_read_data_0	=>read_data_0,
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