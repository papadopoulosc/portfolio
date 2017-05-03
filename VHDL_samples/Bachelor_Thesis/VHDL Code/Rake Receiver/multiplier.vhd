-- ***************************************************************************************************
-- Company: APEL
-- Engineer: Charalampos Papadopoulos
--
-- Create Date: 2009.02.01, 2009.07.24
-- Design Name: rake_receiver (rake_receiver_frame.vhd)
-- Component Name: multiplier (multiplier.vhd)
-- Target Device: xc4vsx35-10ff668
-- Tool versions: ISE 9.2, Modelsim 6.1f, Matlab R2007a

-- Description:
--    Behavioral implementation of a 14-bit multiplier. The result is 28-bits
--		It is used only in the rake circuit (tap_rake.vhd)

-- Dependencies:
--    taps_rake (tap_rake.vhd)

-- Revision:
--    <v1.0>

-- Additional Comments:
-- 	<No>
-- ***************************************************************************************************

-- Created and best viewed with Xilinx ISE 9.2 editor

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.all;

entity multiplier is
	generic	(	N	: integer:=14); -- data width
	port		(	RST: in std_logic; -- reset
					EN	: in std_logic; -- enable
					A	: in std_logic_vector (N-1 downto 0);   
					B	: in std_logic_vector (N-1 downto 0);
					C	: out std_logic_vector (2*N-1 downto 0));
end multiplier;

architecture behavioural of multiplier is

begin

	process(RST,A,B)
	begin
		if (RST = '1') then
			for i in 1 to 2*N loop
				C(i-1) <= '0';
			end loop;
		elsif (EN = '1') then
				C <= conv_std_logic_vector(conv_integer(signed(A))*conv_integer(signed(B)),2*N);
		end if;
	end process;

end behavioural;