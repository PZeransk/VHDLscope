
-- VHDL Instantiation Created from source file CLK.vhd -- 11:54:00 12/30/2024
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

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

	Inst_CLK: CLK PORT MAP(
		CLKIN_IN => ,
		RST_IN => ,
		CLKFX_OUT => ,
		CLKIN_IBUFG_OUT => ,
		CLK0_OUT => ,
		CLK0_OUT1 => ,
		LOCKED_OUT => ,
		STATUS_OUT => 
	);


