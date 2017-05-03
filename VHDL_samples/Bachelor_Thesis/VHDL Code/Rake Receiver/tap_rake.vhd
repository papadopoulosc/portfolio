-- ***************************************************************************************************
-- Company: APEL
-- Engineer: Charalampos Papadopoulos
--
-- Create Date: 2009.02.01, 2009.07.24
-- Design Name: rake_receiver (rake_receiver_frame.vhd)
-- Component Name: taps_rake (tap_rake.vhd)
-- Target Device: xc4vsx35-10ff668
-- Tool versions: ISE 9.2, Modelsim 6.1f, Matlab R2007a

-- Description:
--		Computations for signal detection.
--		The taps_rake component. It is the heart of computations of the rake circuit. It is made up of:
-- 		1) The PN multiplier. It multiplies the input of the circuit with the correct value of the PN sequence.
--			2) The adder
-- 		3) Two dff's COMMENT: The adder together with the two D flip flops form an accumulator.
--			4) The multipilier: It multiplies the output of the accumulator with the correct channel coefficient.

-- Dependencies:
--    rake (rake.vhd)
--		PNmult (basic_circuits.vhd)
-- 	adder (adder_simple.vhd)
--		dff (basic_circuits.vhd)
--		multiplier (multiplier.vhd)

-- Revision:
--    <v1.0>

-- Additional Comments:
-- 	Structural implementation of the rake tap.
--		We have the same problem with negative clock edges as in estimator tap. Details on the text.
--		In comparison to the taps_estimator component, here we also have the multiplier since we multiply with...
--		...the corresponding channel coefficient
-- ***************************************************************************************************

-- Created and best viewed with Xilinx ISE 9.2 editor

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--library work;
use work.rake_pack.all;

entity taps_rake is 
	generic	(	N							: positive:=14);
	port		(	signal_in				: in std_logic_vector(N-1 downto 0);
					coefficient				: in std_logic_vector(N-1 downto 0);
					pn,shift,rst,clk,en	: in std_logic; 
					signal_out				: out std_logic_vector(N-1 downto 0));
end taps_rake;

architecture str of taps_rake is
	
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
	
	component multiplier    
		generic	(	N 	: positive := 14);
		port		(	RST: in std_logic;                               
						EN	: in std_logic;                               
						A	: in std_logic_vector (N-1 downto 0);   
						B	: in std_logic_vector (N-1 downto 0);
						C	: out std_logic_vector (2*N-1 downto 0));
	end component;
	
	signal p,su,q,sum	: std_logic_vector(N-1 downto 0);
	signal product		: std_logic_vector(2*N-1 downto 0);
	signal o,shift2	: std_logic;

begin
	
	o <= '0'; -- The first carryin of the adder is 0
	
	pnmu_r: PNmult 		port map(signal_in,pn,rst,en,p);
	add	: adder 			generic map (N=>N) port map(q,p,o,rst,en,su,co=>open);
	din	: dff 			generic map (N=>N) port map(su,clk,shift,en,q);
	dout	: dff 			generic map (N=>N) port map(su,shift,rst,en,sum);
	mult	: multiplier 	generic map (N=>N) port map(rst,en,sum,coefficient,product);
	
	signal_out <= product(13 downto 0); -- We keep only the 14 LSB.

end str;
