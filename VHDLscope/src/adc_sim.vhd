
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


entity adc_sim is
Generic(C_data_length	:	integer := 10
	);
Port (
	i_clk 	: in 	std_logic;
 	i_cs 	: in 	std_logic;
 	o_miso0	: out 	std_logic
    );
end adc_sim;

architecture Behavioral of adc_sim is
type 	t_sine_table is array (127 downto 0) of integer range 0 to 4096;
constant C_sine_LUT : t_sine_table := (
512 ,537 ,562 ,587 ,612 ,637 ,661 ,685 ,709 ,732 , 
754 ,776 ,798 ,818 ,838 ,857 ,875 ,893 ,909 ,925 , 
939 ,952 ,965 ,976 ,986 ,995 ,1002 ,1009 ,1014 ,1018 , 
1021 ,1023 ,1023 ,1022 ,1020 ,1016 ,1012 ,1006 ,999 ,990 , 
981 ,970 ,959 ,946 ,932 ,917 ,901 ,884 ,866 ,848 , 
828 ,808 ,787 ,765 ,743 ,720 ,697 ,673 ,649 ,624 , 
600 ,575 ,549 ,524 ,499 ,474 ,448 ,423 ,399 ,374 , 
350 ,326 ,303 ,280 ,258 ,236 ,215 ,195 ,175 ,157 , 
139 ,122 ,106 ,91 ,77 ,64 ,53 ,42 ,33 ,24 , 
17 ,11 ,7 ,3 ,1 ,0 ,0 ,2 ,5 ,9 , 
14 ,21 ,28 ,37 ,47 ,58 ,71 ,84 ,98 ,114 , 
130 ,148 ,166 ,185 ,205 ,225 ,247 ,269 ,291 ,314 , 
338 ,362 ,386 ,411 ,436 ,461 ,486 ,512); 

signal r_adc_data0 		: std_logic_vector(C_data_length - 1 downto 0) := (others => '0');
signal r_adc_shift		: std_logic_vector(C_data_length - 1 downto 0) := (others => '0');
signal r_cs_cycles      : integer RANGE 0 TO 127 := 0;
signal r_data_byte 		: std_logic;
signal r_table_cnt		: integer RANGE 0 TO 127 := 0;
signal data_byte_cnt	: integer RANGE 0 TO C_data_length := 0; -- 15 bitowy wektor
signal r_cal_vec        : std_logic_vector(15 downto 0) := (others => '0');

begin
process(i_clk)  

begin
if(rising_edge(i_cs)) then
    -- first CS cycle is a calibration cycle it lasts 16 clk cycles SDO is a 0 vector
        if r_cs_cycles = 0 then
        r_cs_cycles <= r_cs_cycles + 1;
        end if;

        o_miso0 <= 'Z';
        if(r_table_cnt = 127) then
            r_table_cnt <= 0;
        else
            r_table_cnt <= r_table_cnt + 1;
        end if;
        data_byte_cnt <= 0;
        r_adc_data0 <= "00" & std_logic_vector(to_unsigned(C_sine_LUT(r_table_cnt),10));
        r_adc_shift(C_data_length -1 downto 0) 	<= std_logic_vector(to_unsigned(C_sine_LUT(r_table_cnt),10));
end if;



if (i_cs = '0') then
if (rising_edge(i_clk)) then
if(data_byte_cnt = C_data_length) then

else
	o_miso0 <= r_adc_data0(r_adc_data0'high);
	r_adc_data0 <= r_adc_data0(r_adc_data0'high - 1 downto r_adc_data0'low) & '0';
	data_byte_cnt <= data_byte_cnt + 1;
end if;

end if;
end if;

end process;


end Behavioral;