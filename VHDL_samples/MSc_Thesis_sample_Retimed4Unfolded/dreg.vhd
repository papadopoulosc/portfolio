library ieee;
use ieee.std_logic_1164.all;

Entity dreg Is
 Generic(U:integer:=4);
 Port(d:in std_logic_vector(U-1 downto 0);
      clk:in std_logic;
      q:out std_logic_vector(U-1 downto 0));
End dreg;      

Architecture dreg Of dreg Is
Begin
	Process (clk)
	Begin
		If (clk'EVENT AND clk='1') Then
			q <= d;
		End If;
	End Process;
End dreg;
