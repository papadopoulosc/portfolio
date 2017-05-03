-- ***************************************************************************************************
-- Company: APEL
-- Engineer: Charalampos Papadopoulos
--
-- Create Date: 2009.02.01, 2009.07.24
-- Design Name: rake_receiver (rake_receiver_frame.vhd)
-- Component Name: accumulator (channel_estimator.vhd)
-- Target Device: xc4vsx35-10ff668
-- Tool versions: ISE 9.2, Modelsim 6.1f, Matlab R2007a

-- Description:
-- 	Behavioral implementation
-- 	It is used only for the procedures of channel estimator.
-- 	It is used at the beginning of estimation and runs only for 15 clock cycles.... 
--		...It adds the signals Rj, j=1-15. Rj is the signal after passing through the channel.
-- 	This component is called in channel_estimator.vhd
-- 	It consists of only 1 entity: accumulator with architecture: Behavioral.

-- Dependencies:
--    channel_est (channel_estimator.vhd)

-- Revision:
--    <v1.0>

-- Additional Comments:
-- 	The use of signals: signal_in, shift, rst, clk, sum_R can be viewed on the analysis given on the text.
-- ***************************************************************************************************

-- Created and best viewed with Xilinx ISE 9.2 editor

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity accumulator is
	generic	(	N			: positive:=14);
	port 		(	signal_in: in std_logic_vector (N-1 downto 0);
					shift 	: in std_logic;
					rst,clk 	: in std_logic;
					en 		: in std_logic;
					sum_R 	: out std_logic_vector (N-1 downto 0));
end accumulator;

architecture Behavioral of accumulator is

begin
	
	process(rst,clk)
		variable sum_of_signals,sum_of_signals_out: signed(N-1 downto 0);
	begin
		if rst = '1' then
			sum_of_signals 	:= (others => '0');
			sum_of_signals_out:= (others => '0');					
		elsif en = '1' then
			if rising_edge(clk) then
				if shift = '0' then 
					sum_of_signals 	:= sum_of_signals + signed(signal_in);
				else 
					sum_of_signals 	:= sum_of_signals + signed(signal_in);
					sum_of_signals_out:= sum_of_signals;	
					sum_of_signals 	:= (others=>'0');						 
				end if;
			end if;
		elsif en = '0' then
			sum_of_signals		:= (others => '0');
			sum_of_signals_out:= (others => '0');
		end if;
		sum_R <= std_logic_vector(sum_of_signals_out);
	end process;
 
end Behavioral;