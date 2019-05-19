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
	
BEGIN
	
END rtl;


