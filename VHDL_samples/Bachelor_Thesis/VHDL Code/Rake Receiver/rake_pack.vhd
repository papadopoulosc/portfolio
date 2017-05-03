-- ***************************************************************************************************
-- Company: APEL
-- Engineer: Christos Thomos, Charalampos Papadopoulos
--
-- Create Date: 2009.02.01, 2009.07.24
-- Design Name: rake_receiver (rake_receiver_frame.vhd)
-- Component Name: rake_pack (rake_pack.vhd)
-- Target Device: xc4vsx35-10ff668
-- Tool versions: ISE 9.2, Modelsim 6.1f, Matlab R2007a

-- Description:
--		Package with type arr numbers

-- Dependencies:
--		<N/A>

-- Revision:
--    <v1.0>

-- Additional Comments:
--		<No>
-- ***************************************************************************************************

-- Created and best viewed with Xilinx ISE 9.2 editor

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
	   
package rake_pack is
--	generic(N:positive:=20);
	type arr is array (14 downto 0) of std_logic_vector (13 downto 0);
--	type arr10 is array (13 downto 0) of std_logic_vector (13 downto 0);
--	type arr48 is array (14 downto 0) of std_logic_vector (19 downto 0);
--	type arr48_10 is array (13 downto 0) of std_logic_vector (19 downto 0);
end rake_pack;