-------------------------------------------------------------------------------
--
--Function : 16-bit 2 to 1 multiplexer
--
--selmux = 1 means outputmux <= inputmuxb
--selmux = 0 means outputmux <= inputmuxa
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library WORK;
use WORK.all;

entity mux2to1 is port (
      inputmuxa : in STD_LOGIC_VECTOR(15 DOWNTO 0);
	  inputmuxb : in STD_LOGIC_VECTOR(15 DOWNTO 0);	
	  selmux : in std_logic;
	  outputmux : out STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
end mux2to1;

architecture archmux of mux2to1 is
begin  

	outputmux <= inputmuxa when (selmux = '0') else inputmuxb;

end archmux;


