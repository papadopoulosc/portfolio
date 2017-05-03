-- ***************************************************************************************************
-- Company: APEL
-- Engineer: Charalampos Papadopoulos
--
-- Create Date: 2009.02.01, 2009.07.24
-- Design Name: rake_receiver (rake_receiver_frame.vhd)
-- Component Name: adder_15 (adder_15.vhd)
-- Target Device: xc4vsx35-10ff668
-- Tool versions: ISE 9.2, Modelsim 6.1f, Matlab R2007a

-- Description:
-- 	Behavioral implementation.
-- 	It is used only for the procedures of rake receiver.
-- 	It sums all outputs of the 15 taps of the rake circuit (rake.vhd).
-- 	Its output is the final output of the total rake system (rake_receiver_frame.vhd) and drives the... 
--		...decision circuit.

-- Dependencies:
--    rake (rake.vhd)

-- Revision:
--    <v1.0>

-- Additional Comments:
-- 	WARNING: 2 problems (view comments below)
-- ***************************************************************************************************

-- Created and best viewed with Xilinx ISE 9.2 editor

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--library work;
use work.rake_pack.all;

entity adder_15 is 
	generic	(	N				: positive:=14); -- 14 bits
	port		(	rst,en,clk	: in std_logic;
					taps_outputs: in arr;
					sum_15taps	: out std_logic_vector(13 downto 0));	
end adder_15;

architecture behav of adder_15 is
begin
	
	po: 
	process (clk,taps_outputs,rst,en)
		variable sum_15 : std_logic_vector(13 downto 0) := (others => '0'); 
	begin 
		if rising_edge(clk) then
			if (en = '1') then
				if(rst = '1') then -- This reset is better to be before if (en = '1')
					sum_15 := "00000000000000";
				elsif (rst = '0') then
					sum_15 := "00000000000000"; -- Maybe not necessary
					for i in 0 to 14 loop
						sum_15 := sum_15 + taps_outputs(i);
					end loop;
				end if;
			end if;
			sum_15taps <= sum_15;
		end if;	
	end process;

end architecture behav;        