-- ***************************************************************************************************
-- Company: APEL
-- Engineer: Charalampos Papadopoulos
--
-- Create Date: 2009.02.01, 2009.07.24
-- Design Name: rake_receiver (rake_receiver_frame.vhd)
-- Component Name: signal_buf (signal_buffer.vhd)
-- Target Device: xc4vsx35-10ff668
-- Tool versions: ISE 9.2, Modelsim 6.1f, Matlab R2007a

-- Description:
--		Behavioral implementation of a shift register which contains tha input signal and its previous values

-- Dependencies:
--    rake (rake.vhd)

-- Revision:
--    <v1.0>

-- Additional Comments:
-- 	Library work must be used because rake_pack is used
-- ***************************************************************************************************

-- Created and best viewed with Xilinx ISE 9.2 editor

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--library work;
use work.rake_pack.all;

entity signal_buf is
	generic	(	N				: positive:=14);
	port		(	signal_in	: in std_logic_vector(N-1 downto 0);
					clk,rst,en	: in std_logic;
					buf_out		: out arr);
end signal_buf;

architecture beh of signal_buf is

	signal temp_real:arr; --14 bit signal, intermediate signal used in the shifting algorithm

begin

	p:
	process(signal_in,clk,rst,en)
	begin
		if rst = '1' then
			for i in 0 to 14 loop
				temp_real(i) <= (others=>'0');
			end loop;
		elsif clk'event and clk = '1' then
			if en = '1' then
				temp_real(13 downto 0)	<= temp_real(14 downto 1);  
				temp_real(14)				<= signal_in;           
				buf_out						<= temp_real;
			end if;
		end if;
	end process;

end beh;