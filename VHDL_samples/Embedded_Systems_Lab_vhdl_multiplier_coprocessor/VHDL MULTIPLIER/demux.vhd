library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

ENTITY demux is
 PORT (demux_sel,rst: in std_logic;
       mux_in: in std_logic_vector(15 downto 0);
       out1, out2:  out std_logic_vector(15 downto 0));
END demux;


ARCHITECTURE be OF demux IS
BEGIN
p:process (demux_sel, mux_in,rst)
begin 
	IF (rst = '1') THEN 
         for i in 0 to 15 loop
            out1(i) <= '0';
		 out2(i) <= '0';
         end loop;     
	else if demux_sel='1' then out2<=mux_in;
	else if sel='0' then out1<=mux_in;
	end if;
end process;
END be;
