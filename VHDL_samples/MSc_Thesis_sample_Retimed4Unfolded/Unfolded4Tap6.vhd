library ieee;
use ieee.std_logic_1164.all;
use work.DataTypes.all;

Entity unfolded4 Is
  Generic(N:integer:=8;U:integer:=4;T:integer:=3);
  Port(y0,y1,y2,y3:in std_logic_vector(N-1 downto 0);
       a:in alpha(0 to 2*(2**T)-1);
       clk:in std_logic;
       d:out std_logic_vector(0 to U-1));
End unfolded4;

Architecture unfolded4 Of unfolded4 Is

Component Mmux3a Is
  Generic(N: integer:=8);
  Port(a:in alpha(0 to (2**3)-1);
       s0,s1,s2:in std_logic;
       d:out std_logic_vector(N-1 downto 0));
End Component;

Component Mmux3am Is
  Generic(N: integer:=8);
  Port(a:in alpha(0 to (2**3)-1);
       s0,s1,s2,clk:in std_logic;
       d:out std_logic_vector(N-1 downto 0));
End Component;

Component Smux3a Is
  Port(a:in std_logic_vector(0 to (2**3)-1);
       s0,s1,s2:in std_logic;
       d:out std_logic);
End Component;

Component Smux3am Is
  Port(a:in std_logic_vector(0 to (2**3)-1);
       s0,s1,s2,clk:in std_logic;
       d:out std_logic);
End Component;

Component dreg Is
 Generic(U:integer:=4);
 Port(d:in std_logic_vector(U-1 downto 0);
      clk:in std_logic;
      q:out std_logic_vector(U-1 downto 0));
End Component; 

Component dff Is
 Port(d,clk:in std_logic;
      q:out std_logic);
End Component; 

Component vector_merge Is
 Generic(N:integer:=8;LS:integer:=3);
 Port(a:in alpha(0 to (2**LS)-1);
      b,y:in std_logic_vector(N-1 downto 0);
      d:out std_logic_vector(0 to (2**LS)-1));
End Component;

Type buffered Is array(0 to U-1) of std_logic_vector(0 to (2**T)-1);
Signal dif: buffered;

Signal consta,constb: alpha(0 to (2**T)-1);
Signal bconst: alpha(0 to U-1);
Signal rbconst3:std_logic_vector(N-1 downto 0);

Signal pre: std_logic_vector(0 to U-1);
Signal r2,r3:std_logic;
Signal d1,d2:std_logic_vector(0 to (2**T)-1);

Begin
consta<=a(0 to (2**T)-1);
constb<=a((2**T) to 2*(2**T)-1);

DR2:dff port map(pre(2),clk,r2);
DR3:dff port map(pre(3),clk,r3);

B0:Smux3am port map(dif(0),pre(1),pre(2),r3,clk,pre(0));

B1:Smux3a port map(dif(1),r2,r3,pre(0),pre(1));--
B2:Smux3a port map(dif(2),r3,pre(0),pre(1),pre(2));--
B3:Smux3a port map(dif(3),pre(0),pre(1),pre(2),pre(3));--

A0:Mmux3am generic map(N) port map(constb,pre(2),r3,pre(0),clk,bconst(0));

A1:Mmux3a generic map(N) port map(constb,r3,pre(0),pre(1),bconst(1));--
A2:Mmux3a generic map(N) port map(constb,pre(0),pre(1),pre(2),bconst(2));--
A3:Mmux3a generic map(N) port map(constb,pre(1),pre(2),pre(3),bconst(3));--

DS1:dreg generic map(2**T) port map(d1,clk,dif(1));
DS2:dreg generic map(2**T) port map(d2,clk,dif(2));

RD3:dreg generic map(N) port map(bconst(3),clk,rbconst3);

VM0:vector_merge generic map (N,T) port map(consta,bconst(0),y0,dif(0));--
VM1:vector_merge generic map (N,T) port map(consta,bconst(1),y1,d1);--
VM2:vector_merge generic map (N,T) port map(consta,bconst(2),y2,d2);--
VM3:vector_merge generic map (N,T) port map(consta,rbconst3,y3,dif(3));--

d<=pre;	 
End unfolded4;

--a1	4(k-1)+3	4k	    	4k+1	    	4k+2
--a2	4(k-1)+2	4(k-1)+3	4k	      	4k+1
--a3	4(k-1)+1	4(k-1)+2	4(k-1)+3	4k

--a4	4(k-1)	 	4(k-1)+1	4(k-1)+2	4(k-1)+3
--a5	4(k-2)+3	4(k-1)	  	4(k-1)+1	4(k-1)+2
--a6	4(k-2)+2	4(k-2)+3	4(k-1)	  	4(k-1)+1

--a7	4(k-2)+1	4(k-2)+2	4(k-2)+3	4(k-1)
--a8	4(k-2)	 	4(k-2)+1	4(k-2)+2	4(k-2)+3
--a9	4(k-3)+3	4(k-2)	  	4(k-2)+1	4(k-2)+2
--a10	4(k-3)+2	4(k-3)+3	4(k-2)	  	4(k-2)+1
 