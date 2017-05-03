-------------------------------------------------------------------------------
--
--  Function : 8-bit 4 to 1 multiplexer
--
--  muxselect = 00 means outputmux <= inputmuxa
--  muxselect = 01 means outputmux <= inputmuxb
--  muxselect = 10 means outputmux <= inputmuxc
--  muxselect = 11 means outputmux <= inputmuxd
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library WORK;
use WORK.all;

entity mux4to1 is port (
      inputmuxa : in STD_LOGIC_VECTOR(7 DOWNTO 0);
	  inputmuxb : in STD_LOGIC_VECTOR(7 DOWNTO 0);
	  inputmuxc : in STD_LOGIC_VECTOR(7 DOWNTO 0);
	  inputmuxd : in STD_LOGIC_VECTOR(7 DOWNTO 0);	
	  muxselect : in std_logic_vector(1 DOWNTO 0);
	  outputmux : out STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
end mux4to1;

architecture archmux of mux4to1 is
begin  
  outputmux <= 	inputmuxa when (muxselect = "00") else 
    			inputmuxb when (muxselect = "01") else 
    			inputmuxc when (muxselect = "10") else 
    			inputmuxd;
end archmux;


