library ieee;
use ieee.std_logic_1164.all;
use work.DataTypes.all;

Entity Mmux3a Is
  Generic(N: integer:=8);
  Port(a:in alpha(0 to (2**3)-1);
       s0,s1,s2:in std_logic;
       d:out std_logic_vector(N-1 downto 0));
End Mmux3a;

Architecture Mmux3a Of Mmux3a Is
Begin
	 
 Process(a,s0,s1,s2)
 Variable sel:std_logic_vector(2 downto 0);
 Begin
 
  sel:=s2 & s1 & s0;
  
  Case sel Is
   when "000" =>d<=a(0);
   when "001" =>d<=a(1);
   when "010" =>d<=a(2);
   when "011" =>d<=a(3);
   when "100" =>d<=a(4);
   when "101" =>d<=a(5);
   when "110" =>d<=a(6);
   when "111" =>d<=a(7);
   when others => Null;
  End Case;
 
 End Process;
 
 
End Mmux3a;  