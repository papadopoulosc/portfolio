library IEEE;
use IEEE.std_logic_1164.ALL;

entity pdiv is
   port(c25mhz: in  std_logic;
        p2mhz : out std_logic);
end pdiv;

architecture behaviour of pdiv is
begin
   plbl1:
   process(c25mhz)
      variable nbr: integer range 0 to 16;
   begin
      if (c25mhz'event and c25mhz = '1') then
         if nbr < 6 then
            p2mhz <= '0';
         elsif nbr >= 12 then
            nbr := 0;
            p2mhz <= '0';
         else
            p2mhz  <= '1';
         end if;
         nbr := nbr+1;
      end if;
   end process;
end behaviour;












