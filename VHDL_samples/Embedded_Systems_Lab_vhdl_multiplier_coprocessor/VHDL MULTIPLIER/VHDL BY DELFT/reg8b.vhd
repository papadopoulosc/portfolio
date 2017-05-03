------------------------------------------------------------------
--
--Function : 8-bit register
--
--load = 1 means load register on high clock
--
-------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use WORK.all;

ENTITY reg8b IS

	PORT
	(
		datain		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		clk			: IN STD_LOGIC;
		load		: IN STD_LOGIC;
		dataout		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
	
END reg8b;

ARCHITECTURE arch OF reg8b IS

	SIGNAL	q	: STD_LOGIC_VECTOR(7 DOWNTO 0);
	
BEGIN

	PROCESS (clk)
	BEGIN
	
		IF (clk'EVENT AND clk = '1') THEN
		
			IF load = '1' THEN
			
				q <= datain;
			
			ELSE
			
				q <= q;
				
			END IF;
			
		END IF;
		
	END PROCESS;
			
	dataout <= q;
	
END arch;

