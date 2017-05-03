-----------------------------------------------------------
--
--Function : 1-bit flipflop
--
--output <= input on clock high
--
-----------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY flipflop1b IS
	PORT(
		input		: IN	STD_LOGIC;
		clk			: IN	STD_LOGIC;
		output		: OUT 	STD_LOGIC);
	
END flipflop1b;

ARCHITECTURE arch OF flipflop1b IS

	SIGNAL	q	: STD_LOGIC;
	
BEGIN
	PROCESS (clk)
	BEGIN
		IF (clk'EVENT AND clk = '1') THEN
				q <= input;
		ELSE
				q <= q;
		END IF;
			
	END PROCESS;
			
	output <= q;
END arch;

