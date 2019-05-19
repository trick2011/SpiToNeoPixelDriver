LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY NeopixelByte IS -- WRONG ENTITY NAME
	GENERIC (
		CLK_OFFSET_MUL : integer := 2);
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
END NeopixelByte;
ARCHITECTURE behave OF NeopixelByte IS
	COMPONENT NeopixelBit IS
		PORT(
			clk		: IN STD_LOGIC;
			rst		: IN STD_LOGIC;
			ready		: OUT STD_LOGIC;
			z 			: OUT STD_LOGIC;
			onTime 	: IN integer;
			offTime	: IN integer);
	END COMPONENT NeopixelBit;
	
	SIGNAL output_one		: STD_LOGIC;
	SIGNAL one_reset		: STD_LOGIC := '1';
	SIGNAL output_zero	: STD_LOGIC;
	SIGNAL zero_reset		: STD_LOGIC := '1';
	
	SIGNAL current_bit	: integer := 0;
	SIGNAL counter 		: UNSIGNED(20	downto 0) := (OTHERS => '0');
	SIGNAL counter2 		: UNSIGNED(10	downto 0) := (OTHERS => '0');
	
	CONSTANT T0H 	: integer := 10*CLK_OFFSET_MUL;
	CONSTANT T0L 	: integer := 20*CLK_OFFSET_MUL;
	CONSTANT T0T 	: integer := T0H + T0L;
	
	CONSTANT T1H	: integer := 20*CLK_OFFSET_MUL;
	CONSTANT T1L	: integer := 15*CLK_OFFSET_MUL;
	CONSTANT T1T 	: integer := T1H + T1L;
	
	CONSTANT endCycle 	: integer := 280*3*1;
	
	SIGNAL output			: STD_LOGIC;
	
	TYPE t_SM_Main IS (s_Idle, s_Start, s_TX1, s_TX0, s_Cleanup);
	SIGNAL r_SM_Main : t_SM_Main := s_Idle;
	
	SIGNAL r_Clk_Count : integer RANGE 0 TO 128 := 0;
	SIGNAL r_Bit_Index : integer RANGE 0 TO 7 := 0;
	SIGNAL r_TX_Data : STD_LOGIC_VECTOR(7 downto 0) := (OTHERS => '0');
BEGIN
	Z <= output;
	
	tr_Clk_Count <= r_Clk_Count;
	t1 <= T1T;
	t0 <= T0T;
	One  : NeopixelBit PORT MAP(clk,one_reset, one_ready, output_one, T1H,T1L);
	Zero : NeopixelBit PORT MAP(clk,zero_reset,zero_ready,output_zero,T0H,T0L);
	
	to1 <= output_one;
	to0 <= output_zero;
	p_NEOPIXEL_TX : PROCESS(clk,rst)
	BEGIN
		IF rst = '1' THEN
			r_SM_Main <= s_Idle;
			r_TX_Done <= '1';
			r_TX_Data <= (OTHERS => '0');
			r_Clk_Count <= 0;
			r_Bit_Index <= 0;
			output <= '0';
		ELSIF RISING_EDGE(clk) THEN
			CASE r_SM_Main IS
				WHEN s_Idle =>
					stateIndicator	<= 0;
					output <= '0';
					r_TX_Done <= '1';
					r_Clk_Count <= 0;
					r_Bit_Index <= 0;
					IF load = '1' THEN
						r_TX_Data <= byte;
						r_SM_Main <= s_Start;
					ELSE
						r_SM_Main <= s_Idle;
					END IF;
				WHEN s_Start =>
					stateIndicator	<= 1;
					r_TX_Done <= '0';
					output <= '0';
					IF r_TX_Data(r_Bit_Index) = '1' THEN
						one_reset <= '0';
						zero_reset <= '1';
						r_SM_Main <= s_TX1;
					ELSE
						one_reset <= '1';
						zero_reset <= '0';
						r_SM_Main <= s_TX0;
					END IF;
				WHEN s_TX1 =>
					one_reset <= '0';
					stateIndicator	<= 2;
					output <= output_one;
					--output <= '1';
					
					IF r_Clk_Count < T1T THEN
						r_Clk_Count <= r_Clk_Count + 1;
					ELSE
						r_Clk_Count <= 0;
						r_Bit_Index <= r_Bit_Index + 1;
						r_TX_Done <= '0';
						
						IF r_Bit_Index = 7 THEN
							r_SM_Main <= s_Cleanup;
							output <= '0';
						ELSE 
							output <= '0';
							IF r_TX_Data(r_Bit_Index+1) = '1' THEN
								one_reset <= '1';
								zero_reset <= '1';
								r_SM_Main <= s_TX1;
							ELSE
								one_reset <= '1';
								zero_reset <= '1';
								r_SM_Main <= s_TX0;
							END IF;
						END IF;
					END IF;
				WHEN s_TX0 =>
					stateIndicator	<= 3;
					zero_reset <= '0';
					output <= output_zero;
					--output <= '1';
					
					IF r_Clk_Count < T0T THEN
						r_Clk_Count <= r_Clk_Count + 1;
					ELSE
						r_Clk_Count <= 0;
						r_Bit_Index <= r_Bit_Index + 1;
						r_TX_Done <= '0';
						
						IF r_Bit_Index = 7 THEN
							r_SM_Main <= s_Cleanup;
							output <= '0';
						ELSE 
							output <= '0';
							IF r_TX_Data(r_Bit_Index+1) = '1' THEN
								one_reset <= '1';
								zero_reset <= '1';
								r_SM_Main <= s_TX1;
							ELSE
								one_reset <= '1';
								zero_reset <= '1';
								r_SM_Main <= s_TX0;
							END IF;
						END IF;
					END IF;
				WHEN s_Cleanup =>
					stateIndicator	<= 4;
					
					one_reset <= '1';
					zero_reset <= '1';
					r_TX_Done <= '1';
					
					r_Clk_Count <= 0;
					r_Bit_Index <= 0;
					r_SM_Main <= s_Idle;
			END CASE;
		END IF;
	END PROCESS p_NEOPIXEL_TX;
END behave;