-- ***************************************************************************************************
-- Company: APEL
-- Engineer: Charalampos Papadopoulos
--
-- Create Date: 2009.02.01, 2009.07.24
-- Design Name: rake_receiver (rake_receiver_frame.vhd)
-- Component Name: PN_rake (PNbuffer_rake.vhd)
-- Target Device: xc4vsx35-10ff668
-- Tool versions: ISE 9.2, Modelsim 6.1f, Matlab R2007a

-- Description:
--    Behavioral implementation of a cyclic shift register which gives on rake taps, the appropriate...
--		...PN sequence bits.

-- Dependencies:
--    rake (rake.vhd)

-- Revision:
--    <v1.0>

-- Additional Comments:
-- 	When pnset = 1, it is initalized and when pnset = 0, in every clock cycle it shifts the content...
--		...of the buffer by one position.
--		PN_CODE is given externally by the user.
-- 	The difference with channel estimator PN buffer is that every tap has a different bit of the PN sequence.
--		Here, the output of PN_rake is 1 bit that goes to all of the rake taps.
-- ***************************************************************************************************

-- Created and best viewed with Xilinx ISE 9.2 editor

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity PN_rake is
	port(	PN_CODE				: in std_logic_vector(14 downto 0);
			clk,rst,pnset,en	: in std_logic;
			PN_t					: out std_logic);
end PN_rake;

architecture beh of PN_rake is

	signal pn_temp	: std_logic_vector(14 downto 0);
	signal p			: std_logic;

begin

	buf_p:
	process(clk,rst,en,PN_CODE,pn_temp,pnset)
	begin
		if rst = '1' then
			pn_temp <= "000000000000000";
		else
			if pnset = '1' then
				pn_temp <= PN_CODE ;
			else
				if clk'event and clk = '1' then
					PN_t <= p;
					if en = '1' then
						pn_temp(0) <= pn_temp(14);
						pn_temp (14 downto 1) <= pn_temp(13 downto 0);
					end if;
				end if;
			end if;
		end if;
		p <= pn_temp(14);
	end process;

end beh;