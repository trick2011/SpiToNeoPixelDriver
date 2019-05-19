LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
ENTITY NeopixelRGB IS
  PORT (
    clk   	: IN STD_LOGIC;
	 rst		: IN STD_LOGIC;
	 load		: IN STD_LOGIC;
    r			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	 g			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	 b			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	 TX_Done : OUT STD_LOGIC;
	 z			: OUT STD_LOGIC;
	 stateIndicator	: OUT integer RANGE 0 TO 8 := 0
    );
END NeopixelRGB;
 
ARCHITECTURE rtl OF NeopixelRGB IS
	COMPONENT NeopixelByte IS
		PORT(
			load				: IN STD_LOGIC := '1';
			rst				: IN STD_LOGIC := '0';
			clk				: IN STD_LOGIC;
			byte				: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			r_TX_Done 		: OUT STD_LOGIC := '0';
			tr_Clk_Count 	: OUT integer;
			t1					: OUT integer;
			t0					: OUT integer;
			to1				: OUT STD_LOGIC;
			to0				: OUT STD_LOGIC;
			stateIndicator	: OUT integer RANGE 0 TO 8 := 0;
			Z		 			: OUT STD_LOGIC);
	END COMPONENT NeopixelByte;
 
	
 	TYPE t_PRGB IS (s_Idle, s_R, s_G, s_B);
	SIGNAL r_RGB_Main : t_PRGB := s_Idle;
	
	SIGNAL ByteLoad : STD_LOGIC := '0';
	SIGNAL ByteReset : STD_LOGIC := '0';
	SIGNAL data : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL ByteDone : STD_LOGIC;
	SIGNAL ByteOut : STD_LOGIC;
	
	CONSTANT bufDefVal : INTEGER := 2;
	SIGNAL buf : INTEGER := bufDefVal;
BEGIN
	ByteGen : NeopixelByte PORT MAP(ByteLoad,ByteReset,clk,data,ByteDone,OPEN,OPEN,OPEN,OPEN,OPEN,OPEN,ByteOut);
	z <= ByteOut;
	p_RGB: PROCESS(clk, rst, r_RGB_Main)
	BEGIN
		IF rst = '1' AND r_RGB_Main = s_Idle THEN
			r_RGB_Main <= s_Idle;
			ByteReset <= '1';
		ELSIF RISING_EDGE(clk) THEN
			CASE r_RGB_Main IS
				WHEN s_Idle =>
					stateIndicator <= t_PRGB'POS(r_RGB_Main);
					data <= r;					
					IF load = '1' THEN
						r_RGB_Main <= s_R;
						TX_Done <= '0';
						ByteReset <= '0';
						ByteLoad <= '1';
					ELSE
						r_RGB_Main <= s_Idle;
						TX_Done <= '1';
  						ByteReset <= '1';
  						ByteLoad <= '1';
  					END IF;
				WHEN s_R =>
					stateIndicator <= t_PRGB'POS(r_RGB_Main);
  					data <= g;
  					ByteReset <= '0';
  					ByteLoad <= '1';
  					IF buf > 0 THEN
						buf <= buf - 1;
					ELSIF ByteDone = '1' THEN
						r_RGB_Main <= s_G;
  						ByteLoad <= '1';
						buf <= bufDefVal;
  					END IF;
				WHEN s_G =>
					stateIndicator <= t_PRGB'POS(r_RGB_Main);
  					data <= b;
  					ByteReset <= '0';
  					ByteLoad <= '1';
  					IF buf > 0 THEN
						buf <= buf - 1;
					ELSIF ByteDone = '1' THEN
						r_RGB_Main <= s_B;
  						ByteLoad <= '1';
						buf <= bufDefVal;
  					END IF;
				WHEN s_B =>
					stateIndicator <= t_PRGB'POS(r_RGB_Main);
  					data <= r;
  					ByteReset <= '0';
  					ByteLoad <= '1';
  					IF buf > 0 THEN
						buf <= buf - 1;
					ELSIF ByteDone = '1' THEN
						r_RGB_Main <= s_Idle;
  						ByteReset <= '1';
  						ByteLoad <= '0';
  						TX_Done <= '1';
						buf <= bufDefVal;
  					END IF;
			END CASE;
		END IF;
	END PROCESS p_RGB;
END rtl;


