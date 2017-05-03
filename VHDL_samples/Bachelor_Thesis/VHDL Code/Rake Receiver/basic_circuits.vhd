-- ***************************************************************************************************
-- Company: APEL
-- Engineer: Charalampos Papadopoulos
--
-- Create Date: 2009.02.01, 2009.07.24
-- Design Name: rake_receiver (rake_receiver_frame.vhd)
-- Component Name: dff, twoscomp, mux2to1, PNmult (basic_circuits.vhd)
-- Target Device: xc4vsx35-10ff668
-- Tool versions: ISE 9.2, Modelsim 6.1f, Matlab R2007a

-- Description:
-- 	dff		: 	Behavioral implementation of a 14-bit Register
-- 					It is used on estimator taps (tap_estimator.vhd) and rake taps (tap_rake.vhd)
--		twoscomp	:	twoscomp computes the 2's complement of a 14-bit number that is used when...
--						...multiplying with -1 numbers of the PN sequence
--						It is used by PNmult below
--		mux2to1	:	Behavioral implementation of a multiplexor 2to1 of 14-bit numbers. 
--						Depending on 1 or -1 of PN sequence it chooses the number or its complement
-- 					It is used by PNmult below
--		PNmult	:	Structural implementation of the PN multiplication circuit
--						It is not a classic multiplier, since you ve got to choose between two numbers,...
--						...the number itself or its complement
-- 					Basically it is a multiplication with 1 or -1
-- 					It uses the two above mentioned components, twoscomp and mux2to1
-- 					It is used on tap_estimator.vhd, tap_rake.vhd

-- Dependencies:
--    taps_estimator (tap_estimator.vhd)
--		taps_rake (tap_rake.vhd)

-- Revision:
--    <v1.0>

-- Additional Comments:
-- 	<No>
-- ***************************************************************************************************

-- Created and best viewed with Xilinx ISE 9.2 editor

------------------ D FLIP FLOP 14 ------------------ 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity dff is 
	generic	(	N				: positive:=14);
	port		(	d				: in std_logic_vector(N-1 downto 0);
					clk,rst,en	: in std_logic;
					q				: out std_logic_vector(N-1 downto 0));
end dff;

architecture be of dff is
begin
	process(clk,rst,en)
	begin
		if rst = '1' then
			q <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then			
				q <= d;
			end if;
		end if;
	end process;
end be;


------------------ 2'S COMPLEMENT 14 BITS ------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity twoscomp is
	generic	(	N				: positive:=14);
	port		(	innum			: in std_logic_vector (N-1 downto 0);
					rst,enable	: in std_logic;
					twosc			: out std_logic_vector (N-1 downto 0));
end twoscomp;

architecture st of twoscomp is
	
	component adder 
		generic	(	N			: positive:=14);
		port		(	a,b		: in std_logic_vector (N-1 downto 0);
						ci,rst,en: in std_logic;
						sum		: out std_logic_vector (N-1 downto 0);
						co			: out std_logic ) ;
	end component;

	signal temp,temp2	: std_logic_vector(N-1 downto 0);
	signal temp1		: std_logic_vector(N-2 downto 0);
	signal o				: std_logic;

begin

	temp	<= not innum;
	temp1 <= (others=>'0');
	o		<= '0';
	temp2	<= temp1&'1';
	
	ad	:	adder generic map (N=>N) port map (temp,temp2,o,rst,enable,twosc,co=>open);

end st;


------------------ MULTIPLEXOR 2 TO 1  14 BITS ------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mux2to1 is
	generic	(	N		: positive:=14);
	port		(	s1,s0	: in std_logic_vector(N-1 downto 0);
					sel	: in std_logic;
					sout	: out std_logic_vector(N-1 downto 0));
end mux2to1;

architecture be of mux2to1 is
begin
	
	p:
	process(s1,s0,sel)
	begin
		if sel='1' then sout<=s1;
		else if sel='0' then sout<=s0;
		end if;
		end if;
	end process;

end be;


------------------ PN MULTIPLICATION CIRCUIT ------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity PNmult is
	generic	(	N			: positive:= 14);
	port		(	a			: in std_logic_vector (N-1 downto 0);
					pn,rst,en: in std_logic;
					exodos	: out std_logic_vector (N-1 downto 0));
end PNmult;

architecture str of PNmult is
	
	component twoscomp
		generic	(	N				: positive:=14);
		port		(	innum			: in std_logic_vector (N-1 downto 0);
						rst,enable	: in std_logic;
						twosc			: out std_logic_vector (N-1 downto 0));
	end component;
	
	component mux2to1 
		generic	(	N		: positive:=14);
		port		(	s1,s0	: in std_logic_vector(N-1 downto 0);
						sel	: in std_logic;
						sout	: out std_logic_vector(N-1 downto 0));
	end component;
	
	signal compa	: std_logic_vector(N-1 downto 0); -- compa: 2's complement tou a

begin

	tc	:	twoscomp generic map (N=>14) port map (a,rst,en,compa);
	mux:	mux2to1 	generic map (N=>14) port map (a,compa,pn,exodos);

-- If PN = 0 (-1) then it gets out the negative of a, that is compa (complement a)
end str;