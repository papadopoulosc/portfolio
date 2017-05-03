LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

ENTITY reg16b IS

	PORT
	(
		datain		: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		clk			: IN STD_LOGIC;
		load		      : IN STD_LOGIC;
		rst             : IN STD_LOGIC;
		dataout		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
	
END reg16b;

ARCHITECTURE arch OF reg16b IS

	SIGNAL	q	: STD_LOGIC_VECTOR(15 DOWNTO 0);
	
BEGIN

	PROCESS (clk)
	BEGIN

          IF (rst = '1') THEN 
            for i in 0 to 15 loop
                q(i) <= '0';
		      data_out(i)<= '0';
            end loop;	
            product:= (others=>'0');		
	
		else if (clk'EVENT AND clk = '1') THEN
		
			IF load = '1' THEN
			
				q <= datain;
			
			ELSE
			
				q <= q;
				
			END IF;
			
		END IF;
		
	END PROCESS;
			
	dataout <= q;
	
END arch;

