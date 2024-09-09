
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


entity adc_sim is
Generic(C_data_length	:	integer := 12
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
signal cs_changed       : std_logic := '0';
signal r_cs_hist        : std_logic_vector(1 downto 0) := (others => '0'); 
signal adc_data         : std_logic := '0';

begin

change_data: process (i_cs)
    begin
        if falling_edge(i_cs) then
            if r_cs_cycles = 0 then
                r_cs_cycles <= r_cs_cycles + 1;
            end if;
           -- data_byte_cnt <= 0;
            if(r_table_cnt = 127) then
                    r_table_cnt <= 0;
            else
                    r_table_cnt <= r_table_cnt + 1;
            end if;
                r_adc_data0 <= "00" & std_logic_vector(to_unsigned(C_sine_LUT(r_table_cnt),10));
        end if;
end process;


clk_cnt_process : process (i_clk)
begin
    if falling_edge(i_clk) and i_cs = '0'  then

        data_byte_cnt <= data_byte_cnt + 1;
                 
    elsif i_cs = '1' then  
        data_byte_cnt <= 0;
    end if;
end process;

send_data :process(i_clk)  

begin



if falling_edge(i_clk) then

    if  i_cs = '0' then

        if(data_byte_cnt >= C_data_length) then
        adc_data <= '0'; 
        else
           -- o_miso0 <= r_adc_data0(r_adc_data0'high);
           adc_data <= r_adc_data0(C_data_length-1-data_byte_cnt);
       --     data_byte_cnt <= data_byte_cnt + 1;
        end if;
    else
       -- data_byte_cnt <= 0;
    end if;

end if;

end process;
o_miso0 <= adc_data;

end Behavioral;