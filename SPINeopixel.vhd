LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- this is just a wrapper for my DE0 devboar atm.

ENTITY SPINeopixel IS
  PORT (
    CLOCK_50   : IN  STD_LOGIC;
    KEY    		: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    SW 			: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
	 GPIO_0		: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	 LEDG   		: OUT  STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END SPINeopixel;
 
ARCHITECTURE rtl OF SPINeopixel IS
	COMPONENT NeopixelRGB IS
	  port (
		 clk   	: IN STD_LOGIC;
		 rst		: IN STD_LOGIC;
		 load		: IN STD_LOGIC;
		 r			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 g			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 b			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 TX_Done : OUT STD_LOGIC;
		 z			: OUT STD_LOGIC;
		 stateIndicator	: OUT integer RANGE 0 TO 8 := 0);
	END COMPONENT NeopixelRGB;
 
	
 	SIGNAL clk_divider : INTEGER := 0;
	SIGNAL secClk : STD_LOGIC := '0';
	
	SIGNAL quadClkDiv : INTEGER := 0;
	SIGNAL quadClk : STD_LOGIC := '0';
	
	SIGNAL r : STD_LOGIC_VECTOR(7 DOWNTO 0) := "10000000";
	SIGNAL g : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01000000";
	SIGNAL b : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00100000";
	SIGNAL inv : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	SIGNAL rgbRst  : STD_LOGIC;
	SIGNAL rgbLoad : STD_LOGIC;
	SIGNAL rgbDone : STD_LOGIC;
	SIGNAL rgbZ 	: STD_LOGIC;
	
	CONSTANT bufDefVal : INTEGER := 2;
	SIGNAL buf : INTEGER := bufDefVal;
	
	SIGNAL com : STD_LOGIC := '0';
BEGIN
	RGB : NeopixelRGB PORT MAP(CLOCK_50, rgbRst, rgbLoad, r, g, b, rgbDone, rgbZ, OPEN);
	
	inv(7) <= SW(0);
	inv(6) <= SW(1);
	inv(5) <= SW(2);
	inv(4) <= SW(3);
	inv(3) <= SW(4);
	inv(2) <= SW(5);
	inv(1) <= SW(6);
	inv(0) <= SW(7);
	
	p_clk: PROCESS(CLOCK_50)
	BEGIN
		IF(RISING_EDGE(CLOCK_50)) THEN
			IF KEY(2) = '0' THEN
				CASE SW(9 DOWNTO 8) IS
					WHEN "00" =>
						LEDG(7 DOWNTO 0) <= r;
					WHEN "01" =>
						LEDG(7 DOWNTO 0) <= g;
					WHEN "10" =>
						LEDG(7 DOWNTO 0) <= b;
					WHEN "11" =>
						LEDG(7 DOWNTO 0) <= (OTHERS => '0');
				END CASE;
			END IF;
			
			IF KEY(1) = '0' THEN
				CASE SW(9 DOWNTO 8) IS
					WHEN "00" =>
						r <= inv(7 DOWNTO 0);
					WHEN "01" =>
						g <= inv(7 DOWNTO 0);
					WHEN "10" =>
						b <= inv(7 DOWNTO 0);
					WHEN "11" =>
						r <= inv(7 DOWNTO 0);
						g <= inv(7 DOWNTO 0);
						b <= inv(7 DOWNTO 0);
				END CASE;
			END IF;
			
			clk_divider <= clk_divider + 1;
			IF clk_divider > 1000000 THEN -- 50000000
				clk_divider <= 0;
				secClk <= NOT secClk;
			END IF;
			
			quadClkDiv <= quadClkDiv + 1;
			IF quadClkDiv > 4 THEN
				quadClkDiv <= 0;
				quadClk <= NOT quadClk;
			END IF;
			
		END IF;
	END PROCESS p_clk;
	
	
	PROCESS(secClk)
	BEGIN
		IF RISING_EDGE(secCLk) THEN
			IF KEY(0) = '0' THEN
				com <= '1';
			ELSE 
				com <= '0';
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS(quadClk)
	BEGIN
		IF RISING_EDGE(quadClk) THEN
			IF com = '1' THEN
				rgbRst <= '0';
				rgbLoad <= '1';
				GPIO_0(22) <= rgbZ;
			ELSIF rgbDone = '0' THEN
				GPIO_0(22) <= rgbZ;
				rgbRst <= '0';
				rgbLoad <= '0';
			ELSE
				GPIO_0(22) <= '0';
				rgbRst <= '1';
				rgbLoad <= '0';
			END IF;
		END IF;
	END PROCESS;
END rtl;


