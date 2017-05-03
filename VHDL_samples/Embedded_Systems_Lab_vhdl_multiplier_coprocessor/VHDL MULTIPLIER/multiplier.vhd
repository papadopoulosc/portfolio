library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity multiplier is
    Generic ( N  : INTEGER := 8);  
 
    port( clk,rst,op_sel: in std_logic;
          x: in std_logic_vector(N-1 downto 0);
          y_final: out std_logic_vector(N-1 downto 0));	 

end multiplier;


architecture Behavioral of multiplier is

component basic_component 

   Generic ( N : INTEGER := 8);  
   Port ( 
	        clk,rst : IN  STD_LOGIC;                               
           en      : IN  STD_LOGIC;                               
			  A,B,X   : in  STD_LOGIC_VECTOR (N-1 downto 0);
           P     : out  STD_LOGIC_VECTOR (N-1 downto 0)); 
end component;

component mux2to1 
	generic (N:INTEGER:=8);
	port(s1,s0:in std_logic_vector(N-1 downto 0);
		sel:in std_logic;
		sout:out std_logic_vector(N-1 downto 0));
end component;

component control 
port(clk,rst,op_sel:in std_logic;
	  en,clk_1st_2nd:out std_logic);
end component;

component coef_buffer 
    Port ( clk,rst,en: in std_logic;
	        A0 : in  std_logic_vector (N-1 downto 0);
           A1 : in  std_logic_vector (N-1 downto 0);
           A2 : in  std_logic_vector (N-1 downto 0);
           A3 : in  std_logic_vector (N-1 downto 0);
           A4 : in  std_logic_vector (N-1 downto 0);
           Ai : out  std_logic_vector (N-1 downto 0));
end component;

signal y_buf,mux1_out,mux2_out,coef_out,A_in,B_in: std_logic_vector (N-1 downto 0);
signal A_sig,B_sig,C_sig,A0_sig,A1_sig,A2_sig,A3_sig,A4_sig: std_logic_vector (N-1 downto 0);
signal clk_1st_2nd_sig,en_sig: std_logic;

begin

A_sig<= "11110000";
B_sig<= "01000000";
C_sig<= "00000110";
A0_sig<= "01000000";
A1_sig<= "00100000";
A2_sig<= "00100000";
A3_sig<= "00010000";
A4_sig<= "11000000";
y_final<=y_buf;

b_c: basic_component port map (
           clk=>clk,
           rst=>rst,                              
           en=>en_sig,                                
			  A=>A_in,    
           B=>B_in,    
           X=>x,   
           P=>y_buf);   

mux1: mux2to1 port map(
           s1=>C_sig,
			  s0=>B_sig,
		     sel=>clk_1st_2nd_sig,
		     sout=>mux1_out);
			  
mux2: mux2to1 port map(
           s1=>y_buf,
			  s0=>A_sig,
		     sel=>clk_1st_2nd_sig,
		     sout=>mux2_out);
			  
mux3: mux2to1 port map(
           s1=>y_buf,
			  s0=>mux1_out,
		     sel=>op_sel,
		     sout=>B_in);
			  
mux4: mux2to1 port map(
           s1=>coef_out,
			  s0=>mux2_out,
		     sel=>op_sel,
		     sout=>A_in);
			  

coef_buf: coef_buffer port map(
           clk=>clk,
			  rst=>rst,
			  en=>en_sig,
	        A0=>A0_sig,
           A1=>A1_sig,
           A2=>A2_sig, 
           A3=>A3_sig, 
           A4=>A4_sig, 
           Ai=>coef_out);
			  
ctrl: control port map(
           clk=>clk,
			  en=>en_sig,
			  rst=>rst,
			  op_sel=>op_sel,
			  clk_1st_2nd=>clk_1st_2nd_sig);

end Behavioral;

