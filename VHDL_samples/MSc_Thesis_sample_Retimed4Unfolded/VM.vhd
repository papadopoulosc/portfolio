library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use work.DataTypes.all;

Entity vector_merge Is
 Generic(N:integer:=8;LS:integer:=3);
 Port(a:in alpha(0 to (2**LS)-1);
      b,y:in std_logic_vector(N-1 downto 0);
      d:out std_logic_vector(0 to (2**LS)-1));
End vector_merge;

Architecture vector_merge Of vector_merge Is
Type inter Is array (0 to (2**LS)-1) of std_logic_vector(N+1 downto 0);
Signal pre_buf:inter;
Begin

OUTPUT: For i in 0 to (2**LS)-1 Generate
	 pre_buf(i)<=(a(i)(N-1) & a(i)(N-1) & a(i))+b+y;
	 d(i)<=not pre_buf(i)(N+1);
	End Generate OUTPUT; 


End vector_merge; 
 