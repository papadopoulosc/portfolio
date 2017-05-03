library ieee;
use ieee.std_logic_1164.all;

Entity dff Is
 Port(d,clk:in std_logic;
      q:out std_logic);
End dff;      

Architecture dff Of dff Is
Begin
	Process (clk)
	Begin
		If (clk'EVENT AND clk='1') Then
			q <= d;
		End If;
	End Process;
End dff;
