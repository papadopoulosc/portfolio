-- ***************************************************************************************************
-- Company: APEL
-- Engineer: Charalampos Papadopoulos
--
-- Create Date: 2009.02.01, 2009.07.24
-- Design Name: rake_receiver (rake_receiver_frame.vhd)
-- Component Name: fadd1, adder (adder_simple.vhd)
-- Target Device: xc4vsx35-10ff668
-- Tool versions: ISE 9.2, Modelsim 6.1f, Matlab R2007a

-- Description:
-- 	fadd1: 	adder of two 1-bit numbers with carry-in (Full Adder)
-- 				It is used by the Full Adder 14-bit below
--		adder:	The code of adder is a structural implementation of a 14-bit adder by using 14 Full Adders...
--					...of 1-bit (fadd1)

-- Dependencies:
--    taps_estimator (tap_estimator.vhd)
--		taps_rake (tap_rake.vhd)

-- Revision:
--    <v1.0>

-- Additional Comments:
-- 	It would be better to be implemented behaviorally.
--		When synthesizer translates this into hardware it comes out the best possible 14-bit adder
-- ***************************************************************************************************

-- Created and best viewed with Xilinx ISE 9.2 editor

-------------------------FULL ADDER 1-BIT--------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fadd1 is
	port(	a,b,cin,rst,en	: in std_logic;
			s,cout			: out std_logic);
end fadd1;

architecture str1 of fadd1 is
begin
	
	process(rst,en,a,b,cin)
	begin
		if rst = '1' then
			cout <= '0';
			s <= '0';
		else
			if en = '1' then
				s <= (a xor b) xor cin;
				cout <= ((a and b)or((a or b)and cin));
			end if;
		end if;
	end process;

end str1;


-------------------------FULL ADDER 14 BITS--------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity adder is
	generic	(	N			: positive:=14);
	port		(	a,b		: in std_logic_vector (N-1 downto 0);
					ci,rst,en: in std_logic;
					sum		: out std_logic_vector (N-1 downto 0);
					co			: out std_logic);
end adder;

architecture struct of adder is

	component fadd1
	port(	a,b,cin,rst,en	: in std_logic;
			s,cout			: out std_logic);
	end component;
 
	signal ca: std_logic_vector (N downto 0);
 
begin
	 
	ca(0) <= ci;
	co 	<= ca(N);
	
	ad	:	for i in 0 to N-1 generate
				g:	fadd1 port map (a(i),b(i),ca(i),rst,en,sum(i),ca(i+1));
			end generate;
 
end struct;