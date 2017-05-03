-- ***************************************************************************************************
-- Company: APEL
-- Engineer: Charalampos Papadopoulos
--
-- Create Date: 2009.02.01, 2009.07.24
-- Design Name: rake_receiver (rake_receiver_frame.vhd)
-- Component Name: PNbuf (PNbuffer.vhd)
-- Target Device: xc4vsx35-10ff668
-- Tool versions: ISE 9.2, Modelsim 6.1f, Matlab R2007a

-- Description:
--    Behavioral implementation of a cyclic shift register which gives on estimator taps, the appropriate...
--		...PN sequence bits.

-- Dependencies:
--    channel_est (channel_estimator.vhd)

-- Revision:
--    <v1.0>

-- Additional Comments:
-- 	When pnset = 1, it is initalized and when pnset = 0, in every clock cycle it shifts the content...
--		...of the buffer by one position.
--		PN_CODE is given externally by the user.
-- ***************************************************************************************************

-- Created and best viewed with Xilinx ISE 9.2 editor

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity PNbuf is
	port(	PN_CODE				: in std_logic_vector(14 downto 0);
			clk,rst,pnset,en	: in std_logic;
			PN						: out std_logic_vector(14 downto 0));
end PNbuf;

architecture beh of PNbuf is
	signal pn_temp	: std_logic_vector(14 downto 0);
begin
	
	buf_p:
	process(clk,rst,en,PN_CODE,pn_temp,pnset)
	begin
		if (rst = '1') then
			pn_temp <= "000000000000000";
		elsif pnset = '1' then
			pn_temp <= PN_CODE ; 
		elsif clk'event and clk = '1' then
			if (en = '1') then
				pn_temp(0) <= pn_temp(14);
				pn_temp (14 downto 1) <= pn_temp(13 downto 0);
			end if;
		end if;
		pn <= pn_temp;
	end process;

end beh;