----------------------------------------------------------------------------
--
--Function : Bidirectional 8-bits bus
--
--Bidir are the in/output pins
--On inp you get the incoming signals from the databus
--On outp you can set the outgoin signas to the databus
--
----------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY biport IS
    PORT(
        bidir   : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        oe, clk : IN STD_LOGIC;
        inp     : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        outp    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
END biport;

ARCHITECTURE maxpld OF biport IS
SIGNAL  a  : STD_LOGIC_VECTOR (7 DOWNTO 0);  -- DFF that stores 
                                             -- value from input.
SIGNAL  b  : STD_LOGIC_VECTOR (7 DOWNTO 0);  -- DFF that stores 
BEGIN                                        -- feedback value.
    PROCESS(clk)
    BEGIN
    IF clk = '1' AND clk'EVENT THEN  -- Creates the flipflops
        a <= inp;                    
        outp <= b;                  
        END IF;
    END PROCESS;    
    PROCESS (oe, bidir, a)          -- Behavioral representation 
        BEGIN                    -- of tri-states.
        IF( oe = '0') THEN
            bidir <= "ZZZZZZZZ";
            b <= bidir;
        ELSE
            bidir <= a; 
            b <= bidir;
        END IF;
    END PROCESS;
END maxpld;

