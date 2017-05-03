-- ***************************************************************************************************
-- Company: APEL
-- Engineer: Charalampos Papadopoulos
--
-- Create Date: 2009.02.01, 2009.07.24
-- Design Name: rake_receiver (rake_receiver_frame.vhd)
-- Component Name: taps_estimator (tap_estimator.vhd)
-- Target Device: xc4vsx35-10ff668
-- Tool versions: ISE 9.2, Modelsim 6.1f, Matlab R2007a

-- Description:
--		Computations for channel coefficient estimator
--		The taps_estimator component. It is the heart of computations of the estimator. It is made up of:
-- 		1) The PN multiplier. It multiplies the input of the circuit with the correct value of the PN sequence.
-- 		2) The adder
-- 		3) Two dff's

-- Dependencies:
--    channel_est (channel_estimator.vhd)
--		PNmult (basic_circuits.vhd)
-- 	adder (adder_simple.vhd)
--		dff (basic_circuits.vhd)
--		mux2to1 (basic_circuits.vhd)

-- Revision:
--    <v1.0>

-- Additional Comments:
-- 	Structural implementation of the estimator tap.
-- 	Shift signal is activated at negative clock edges. See in text for details.
-- 	Also:
--			a) The adder together with the two D flil flops form an accumulator.
--			b) At the end of the circuit we need a division with N+1=16. Instead of using a divider, we...
--         	... omit the 4 least significant digits.
-- ***************************************************************************************************

-- Created and best viewed with Xilinx ISE 9.2 editor

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity taps_estimator is 
	generic	(	N							: positive:=14);
	port		(	in_num					: in std_logic_vector(N-1 downto 0);
					sum_R						: in std_logic_vector(N-1 downto 0);
					pn,shift,rst,clk,en	: in std_logic;
					out_num					: out std_logic_vector(N-1 downto 0));
end taps_estimator;

architecture structural of taps_estimator is
	
	component PNmult 
		generic	(	N			: positive:= 14);
		port		(	a			: in std_logic_vector (N-1 downto 0);
						pn,rst,en: in std_logic;
						exodos	: out std_logic_vector (N-1 downto 0));
	end component;
	
	component adder 
		generic	(	N			: positive:=14);
		port		(	a,b		: in std_logic_vector (N-1 downto 0);
						ci,rst,en: in std_logic;
						sum		: out std_logic_vector (N-1 downto 0);
						co			: out std_logic);
	end component;
	
	component dff 
		generic	(	N				: positive:=14);
		port		(	d				: in std_logic_vector(N-1 downto 0);
						clk,rst,en	: in std_logic;
						q				: out std_logic_vector(N-1 downto 0));
	end component; 
	
	component mux2to1 
		generic	(	N		: positive:=14);
		port		(	s1,s0	: in std_logic_vector(N-1 downto 0);
						sel	: in std_logic;
						sout	: out std_logic_vector(N-1 downto 0));
	end component;
	
	signal signal_out14,signal_out10,p,q,add1_out: std_logic_vector(N-1 downto 0);
	signal o													: std_logic;
	
begin
	o <= '0'; -- The first carryin of the adder is 0
	
	pnmu	: PNmult port map(in_num,pn,rst,en,p);
	add	: adder 	port map(q,p,o,rst,en,add1_out,co=>open);
	din	: dff 	port map(add1_out,clk,shift,en,q);
	add2	: adder 	port map(sum_R,add1_out,o,rst,en,signal_out14,co=>open);

	--The following is equivalent to a division by N+1 = 16.

	signal_out10(9 downto 0) <= signal_out14(13 downto 4);
	
	signal_out10(10) <= signal_out14(13);
	signal_out10(11) <= signal_out14(13);
	signal_out10(12) <= signal_out14(13);
	signal_out10(13) <= signal_out14(13);
	
	dout: dff generic map (N=>N) port map(signal_out10,shift,rst,en,out_num);

end structural;