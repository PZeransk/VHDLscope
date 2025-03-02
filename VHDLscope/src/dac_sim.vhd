
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--! Entity for simulating 12-bit DAC with I2C interfave.
--! For any information regarding register addresses see datasheet.

--! \param  C_write_vol_size 	 Command size for volitate DAC register write
--! \param  C_write_vol_reg_size Command size for writing to volitale memory
--! \param  C_write_vol_conf 	 Command size for writing volitale configuration bits
--! \param  C_write_all_meme 	 Command size for writing to all memory
--! \param  C_addr_len 			 I2C address length
--! \param  C_data_len 			 I2C data length
--! \param  io_sda 				 Data port of I2C
--! \param  i_scl  	  			 Clock port of I2C
--! \param  i_dev_addr 			 Port for setting custom device address, should be in generics section


entity dac_sim is
	generic (
		C_write_vol_size 		: integer := 36;
		C_write_vol_reg_size 	: integer := 27;
		C_write_vol_conf 		: integer := 18;
		C_write_all_meme 		: integer := 36;
		C_addr_len 				: integer := 7;
		C_data_len 				: integer := 8
	);
    Port ( io_sda 		: inout  std_logic;
           i_scl  	  	: in     std_logic;
           i_dev_addr 	: in std_logic_vector(C_addr_len - 1 downto 0)
           );
end dac_sim;

architecture Behavioral of dac_sim is
	type T_dac_state is (
		IDLE,
		READ_ADDR, -- ack at the end 
		--SLV_ACK, -- should be active on falling egde of the scl
		WRITE_DATA, -- ack at the end, write data to vol register
		READ_DATA, -- ack at the end, read data from memory and send it back to master
		STOP_STATE
		);

	signal r_dac_state 		: T_dac_state := IDLE;
	signal scl_cnt 			: integer range 0 to C_write_vol_size := 0; -- the biggest size
	signal scl_state 		: std_logic;
	-- first 8 bits are address and rw bit
	signal addr_reg 		: std_logic_vector(C_addr_len - 1 downto 0) := (others => '0');
	signal rw_bit 			: std_logic := '0';
	--according to datasheet there should be three 8 bit words, which makes up to 24 bit
	signal write_data_reg	: std_logic_vector(23 downto 0) := (others => '0');
	signal cmd_reg 			: std_logic_vector(C_data_len - 1 downto 0) := (others => '0');
	signal data_reg_0 		: std_logic_vector(C_data_len - 1 downto 0) := (others => '0');
	signal data_reg_1		: std_logic_vector(C_data_len - 1 downto 0) := (others => '0');
	-- integer value for voltage output
	--signal voltage 			: integer range 0 to 2048 := 0;
--
	signal start_ok 		: std_logic := '0';
	signal sda_drive 		: std_logic := '0'; -- should be 1 to drive sda ack
	signal ack_ok 			: std_logic := '0';
	--signal start_cond 		: std_logic_vector(1 downto 0):= "00";
begin


start_proc : process(io_sda, i_scl) is
begin

	if (falling_edge(io_sda) and i_scl = '1') and start_ok = '0' then
		start_ok <= '1';
	elsif start_ok = '0' then -- this latches start_ok into right state
		start_ok <= '0';
	end if;
end process; -- start_proc



-- data should be established before rising edge of the clock
-- so it can be read that way
rx_data : process(i_scl) is
begin
	--if rising_edge(i_scl) then
		case r_dac_state is 
			when IDLE =>
				--scl_cnt <= 0;
				sda_drive <= '0';
				if start_ok = '1' then
					r_dac_state <= READ_ADDR;
					--start_ok <= '0'; -- resets start_ok value
				end if;
			when READ_ADDR =>
				sda_drive <= '0';
			if rising_edge(i_scl) then	
				if scl_cnt <= 6 then
					addr_reg <=addr_reg(addr_reg'high - 1 downto addr_reg'low)&io_sda;
					r_dac_state <= READ_ADDR;
					
				elsif scl_cnt = 7 then
					rw_bit <= io_sda;
				elsif (scl_cnt = 8) then
						if addr_reg = i_dev_addr then
							sda_drive <= '1';
							ack_ok <= '1';
							--io_sda <= '0';
							if rw_bit = '0' then
								r_dac_state <= WRITE_DATA;
							elsif rw_bit = '1' then
								r_dac_state <= READ_DATA;
							end if;
						else 
							ack_ok <= '0';
							r_dac_state <= IDLE;
						end if;
				end if;
			end if;

			when READ_DATA =>
			if rising_edge(i_scl) then
				if scl_cnt <= 9 then
					addr_reg <=addr_reg(addr_reg'high - 1 downto addr_reg'low)&io_sda;
					r_dac_state <= READ_ADDR;
					sda_drive <= '0';
				elsif (scl_cnt = 17 and addr_reg =  i_dev_addr) then
					--io_sda <= '0';
					r_dac_state <= READ_DATA;	
				end if;
			end if;
			when WRITE_DATA => 
				sda_drive <= '0';
			if rising_edge(i_scl) then
				if scl_cnt >= 9 then

					write_data_reg <=write_data_reg(write_data_reg'high - 1 downto write_data_reg'low)&io_sda;
					r_dac_state <= WRITE_DATA;	
				end if;
			end if;
			when STOP_STATE =>
				
				
		end case;
	--end if;

end process;

	
scl_counter : process(i_scl) is

begin	
	if rising_edge(i_scl) and start_ok = '1' then
		if scl_cnt <= C_write_vol_size then
			scl_cnt <= scl_cnt + 1;
		else 
			scl_cnt <= 0;
		end if;
	else 
		--scl_cnt <= 0;
	end if;


end process; -- scl_counter

io_sda <= 'Z' when (sda_drive = '0') else NOT ack_ok; -- ack active is 0 on sda, but 1 in code, should be reversed

--i_scl <= i_scl;

end Behavioral;

