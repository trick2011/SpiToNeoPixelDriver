LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ClkDivider IS
	PORT(
		Clk	: IN STD_LOGIC;
		ClkHalf: OUT STD_LOGIC);
END;

ARCHITECTURE ClkDivider_arch OF ClkDivider IS
	SIGNAL clk_divider : UNSIGNED(0 downto 0);
BEGIN
	PROCESS(Clk)
	BEGIN
		IF(RISING_EDGE(Clk)) THEN
			clk_divider <= clk_divider + 1;
		END IF;
	END PROCESS;
	
	ClkHalf <= clk_divider(0);	
END ClkDivider_arch;