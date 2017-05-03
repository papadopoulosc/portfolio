library ieee;
use ieee.std_logic_1164.all;
use work.DataTypes.all;

Entity Mmux3am Is
  Generic(N: integer:=8);
  Port(a:in alpha(0 to (2**3)-1);
       s0,s1,s2,clk:in std_logic;
       d:out std_logic_vector(N-1 downto 0));
End Mmux3am;

Architecture Mmux3am Of Mmux3am Is
Signal b0,b1,b2,b3:std_logic_vector(N-1 downto 0); 
Begin

 Process(a,s0,clk)
 Variable q0,q1,q2,q3:Std_logic_vector(N-1 downto 0);
 Begin
 
  Case s0 Is
   when '0' =>q0:=a(0);q1:=a(2);q2:=a(4);q3:=a(6);
   when '1' =>q0:=a(1);q1:=a(3);q2:=a(5);q3:=a(7);   
   when others => Null;
  End Case; 

		If (clk'EVENT AND clk='1') Then
			b0 <= q0;b1<=q1;b2 <= q2;b3<=q3;
		End If;   
  
 End Process; 
	 
 Process(b0,b1,b2,b3,s1,s2)
 Variable sel:std_logic_vector(1 downto 0);
 Begin
 
  sel:=s2 & s1;
  
  Case sel Is
   when "00" =>d<=b0;
   when "01" =>d<=b1;
   when "10" =>d<=b2;
   when "11" =>d<=b3;
   when others => Null;
  End Case;
 
 End Process;
 
 
End Mmux3am;  