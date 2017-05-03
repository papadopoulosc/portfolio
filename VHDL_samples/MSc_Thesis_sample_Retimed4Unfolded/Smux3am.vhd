library ieee;
use ieee.std_logic_1164.all;

Entity Smux3am Is
  Port(a:in std_logic_vector(0 to (2**3)-1);
       s0,s1,s2,clk:in std_logic;
       d:out std_logic);
End Smux3am;

Architecture Smux3am Of Smux3am Is
Signal b0,b1:std_logic; 
Begin
	 
 Process(a,s0,s1,clk)
 Variable sel:std_logic_vector(1 downto 0);
 Variable q0,q1:std_logic;
 Begin
 
  sel:=s1 & s0;
  
  Case sel Is
   when "00" =>q0:=a(0);q1:=a(4);
   when "01" =>q0:=a(1);q1:=a(5);
   when "10" =>q0:=a(2);q1:=a(6);
   when "11" =>q0:=a(3);q1:=a(7);
   when others => Null;
  End Case;
  
		If (clk'EVENT AND clk='1') Then
			b0 <= q0;b1<=q1;
		End If;  
 
 End Process;
 
 Process(b0,b1,s2)
 Begin
 
  Case s2 Is
   when '0' =>d<=b0;
   when '1' =>d<=b1;   
   when others => Null;
  End Case; 
 
 End Process;
 
 
End Smux3am;  