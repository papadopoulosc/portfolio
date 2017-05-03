-- ***************************************************************************************************
-- Company: APEL
-- Engineer: Charalampos Papadopoulos
--
-- Create Date: 2009.02.01, 2009.07.24
-- Design Name: rake_receiver (rake_receiver_frame.vhd)
-- Component Name: channel_est (channel_estimator.vhd)
-- Target Device: xc4vsx35-10ff668
-- Tool versions: ISE 9.2, Modelsim 6.1f, Matlab R2007a

-- Description:
-- 	One of the 3 subcircuits: the channel estimator. It is made up of the following components:
-- 	1) accumulator		: It accumulates the inputs of the system, as the estimator algorithm dictates.
-- 	2) PNbuf				: It contains the PN sequence
-- 	3) taps_estimator	: It is the computational heart of the estimator. 15 of those components are used.

-- Dependencies:
--    rake_receiver (rake_receiver_frame.vhd)
--		accumulator (accumulator.vhd)
--		taps_estimator (tap_estimator.vhd)
--		PNbuf (PNbuffer.vhd)

-- Revision:
--    <v1.0>

-- Additional Comments:
-- 	Structural implementation of channel estimator
-- 	It is used by rake_receiver_frame.vhd
-- ***************************************************************************************************

-- Created and best viewed with Xilinx ISE 9.2 editor

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.rake_pack.all;

entity channel_est is
	generic	(	N								: positive:=14);
	port		(	PN_code						: in std_logic_vector(14 downto 0); -- it is given by the user externally
					clk,rst,pn_set,en,shift	: in std_logic;
					signal_in					: in std_logic_vector(N-1 downto 0);
					a								: out arr); -- a is a bus with channel coefficients
end channel_est;

architecture struct of channel_est is

	component accumulator
		generic	(	N						: positive:=14);
		port		(	signal_in			: in std_logic_vector (N-1 downto 0);
						shift,rst,clk,en	: in std_logic;
						sum_R					: out std_logic_vector (N-1 downto 0));
	end component;
	
	component taps_estimator  
		generic	(	N							: positive:=14);
		port		(	in_num					: in std_logic_vector(N-1 downto 0);
						sum_R						: in std_logic_vector(N-1 downto 0);
						pn,shift,rst,clk,en	: in std_logic;  
						out_num					: out std_logic_vector(N-1 downto 0));
	end component;
	
	component PNbuf 
		port(	PN_CODE				: in std_logic_vector(14 downto 0);
				clk,rst,pnset,en	: in std_logic;
				PN						: out std_logic_vector(14 downto 0));
	end component;

	signal sum_R	: std_logic_vector(N-1 downto 0); -- Accumulator output
	signal pncode	: std_logic_vector(14 downto 0); -- PNbuffer initialization
	signal o			: std_logic;
	signal b			: arr; -- It is not necessary (in case it is deleted, delete also a <= b; in the end and b(i) in up: must be a(i)

begin
	o<='0';

	pn_b	:	PNbuf 		port map(PN_code,clk,rst,pn_set,en,pncode);
	acc	:	accumulator port map(signal_in,shift,rst,clk,en,sum_R);
	
	g		:	for i in 0 to 14 generate
					up:taps_estimator port map(signal_in,sum_R,pncode(i),shift,rst,clk,en,b(i));
				end generate;
	
	a <= b;

end struct;