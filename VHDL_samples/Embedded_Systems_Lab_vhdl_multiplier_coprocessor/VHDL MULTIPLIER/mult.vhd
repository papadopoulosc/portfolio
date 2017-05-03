LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

LIBRARY WORK;
USE WORK.ALL;

    PORT (    
        RST     : IN  STD_LOGIC;                       
        A       : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);   
        B       : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
        C       : OUT  STD_LOGIC_VECTOR (31 DOWNTO 0));
END multiplier;


ARCHITECTURE behavioural OF multiplier IS

BEGIN
    PROCESS(RST,A,B) BEGIN
        IF (RST = '1') THEN 
            for i in 0 to 31 loop
                C(i) <= '0';
            end loop;
        
         ELSE 
            C <= CONV_STD_LOGIC_VECTOR(CONV_INTEGER(SIGNED(A))*CONV_INTEGER(SIGNED(B)),32);
         END IF;
        
    END PROCESS;
    
END behavioural;