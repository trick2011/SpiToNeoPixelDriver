LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY NeopixelBit IS
	PORT(
		clk		: IN STD_LOGIC;
		rst		: IN STD_LOGIC;
		ready		: OUT STD_LOGIC;
		z 			: OUT STD_LOGIC;
		onTime 	: IN integer;
		offTime	: IN integer);
END;


ARCHITECTURE behave OF NeopixelBit IS
	SIGNAL counter : UNSIGNED(10 downto 0) := (OTHERS => '0');
BEGIN
	p_counter: PROCESS(clk, rst)
	BEGIN
		IF(rst = '1') THEN
			z <='0';
			ready <= '1';
			counter <= (OTHERS=>'0');
		ELSIF(RISING_EDGE(clk)) THEN
			counter <= counter + 1;
			IF(counter < onTime) THEN
				z <= '1';
				ready <= '0';
			ELSIF(counter >= onTime) THEN
				z <= '0';
				ready <= '0';
				IF(counter >= onTime+offTime) THEN				
					counter <= (OTHERS=>'0');
					ready <= '1';
				END IF;
			END IF;
		END IF;
	END PROCESS p_counter;
END;