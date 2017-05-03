-- ***************************************************************************************************
-- Company: APEL
-- Engineer: Charalampos Papadopoulos
--
-- Create Date: 2009.02.01, 2009.07.24
-- Design Name: rake_receiver (rake_receiver_frame.vhd)
-- Component Name: rake (rake.vhd)
-- Target Device: xc4vsx35-10ff668
-- Tool versions: ISE 9.2, Modelsim 6.1f, Matlab R2007a

-- Description:
--		The most important of the 3 subcircuits: the rake circuit. It is made up of the following components:
--			1) signal_buf	: It contains the current and past values of the input signal.
--			2) PN_rake		: It contains the PN sequence.
--			3) taps_rake	: It is the heart of computations of the circuit. 15 of those components are used.
--			4) adder_15		: It sums the 15 outputs of the above 15 components.

-- Dependencies:
--    rake_receiver (rake_receiver_frame.vhd)
--		signal_buf (signal_buffer.vhd)
--		PN_rake (PNbuffer_rake.vhd)
--		taps_rake (tap_rake.vhd)
--		adder_15	(adder_15.vhd)

-- Revision:
--    <v1.0>

-- Additional Comments:
-- 	It is a structural implementation
-- 	In contrary to the estimator taps, rake taps use a different input signal, and thus...
--		...we use the signal buffer: signal_buf
-- ***************************************************************************************************

-- Created and best viewed with Xilinx ISE 9.2 editor

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--library work;
use work.rake_pack.all;

entity rake is 
	generic	(	N								: positive:=14);
	port		(	signal_in					: in std_logic_vector(N-1 downto 0);
					coef_arr						: in arr;
					pn_code						: in std_logic_vector(14 downto 0);
					shift,clk,rst,pnset,en	: in std_logic;
					estimated_signal			: out std_logic_vector(13 downto 0));
end rake;

architecture struct of rake is
    
	component signal_buf 
		generic	(	N				: positive:=14);
		port		(	signal_in	: in std_logic_vector(N-1 downto 0);
						clk,rst,en	: in std_logic;
						buf_out		: out arr);
	end component;
	
	component PN_rake 
		port(	PN_CODE				: in std_logic_vector(14 downto 0);
				clk,rst,pnset,en	: in std_logic;
				PN_t					: out std_logic);
	end component;
	
	component taps_rake  
		generic	(	N							: positive:=14);
		port		(	signal_in				: in std_logic_vector(N-1 downto 0);
						coefficient				: in std_logic_vector(N-1 downto 0);
						pn,shift,rst,clk,en	: in std_logic; 
						signal_out				: out std_logic_vector(N-1 downto 0));
	end component;
	
	component adder_15
		generic	(	N				: positive:=14);
		port		(	rst,en,clk	: in std_logic;
						taps_outputs: in arr;
						sum_15taps	: out std_logic_vector(N-1 downto 0));	
	end component;
	
	signal s_r				: arr;
	signal taps_outputs	: arr;
	signal pn,o				: std_logic;
	signal sum_15taps		: std_logic_vector(N-1 downto 0);

begin

	o <= '0'; -- The first carryin of the adder is 0
	
	sig_b		:	signal_buf 	port map(signal_in,clk,rst,en,s_r);
	pn1		:	PN_rake 		port map(pn_code,clk,rst,pnset,en,pn);
	f1			:	for i in 14 downto 0 generate
						u1: taps_rake generic map(N => N) port map(s_r(i),coef_arr(i),pn,shift,rst,clk,en,taps_outputs(i));
					end generate;
	add_real	:	adder_15 generic map(N => N) port map(rst,en,clk,taps_outputs,sum_15taps);
	
	estimated_signal <= sum_15taps;

end struct;