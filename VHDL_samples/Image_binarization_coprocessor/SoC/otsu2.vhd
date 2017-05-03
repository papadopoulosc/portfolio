library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

use IEEE.NUMERIC_STD.ALL;

library work;
use work.otsu_Pkg.all;

entity otsu is
	generic ( NHIST : integer := 16 );
	port ( 	clk    : in  std_logic;	
		en         : in  std_logic;
		ready	   : out  std_logic;
		hist       : in  vector_array;
		thres      : out std_logic_vector ( 31 downto 0) );
end otsu;

architecture Behavioral of otsu is

	signal internal_ready : std_logic := '0';
	signal internal_thres : std_logic_vector(31 downto 0) := (OTHERS => '0');
begin

	ready <= internal_ready;
	thres <= internal_thres;

	process
		type int_array is array (0 to NHIST-1) of integer;
		variable hist_var : int_array;
		
		variable sum : integer := 0;
		variable sumB : integer := 0;
		variable wB : integer := 0;
		variable wF : integer := 0;
		variable mB : integer := 0;
		variable mF : integer := 0;
		variable max : integer := 0;
		variable between : integer := 0;
		variable threshold1 : integer := 0;
		variable threshold2 : integer := 0;
		
		variable i : integer :=0;

		variable tmp : integer := 0;

		constant total : integer := 38400;
	begin
		
		wait until (clk'event and clk = '1' and en='1');
		for i in 0 to (NHIST-1) loop
				hist_var(i) := to_integer(unsigned(hist(i)));
		end loop;
			
		for i in 0 to (NHIST-1) loop
			sum := sum + i*hist_var(i);
		end loop;

		main:for i in 0 to (NHIST-1) loop
			wait until( clk'event and clk = '1' and en='1');
			wb := wb + hist_var(i);
			
			wF := total - wB;
			exit main when wF = 0;
			
			sumB := sumB + i*hist_var(i);
			mB := to_integer(divide(to_unsigned(sumB,32),to_unsigned(wB,32)));
			mF := to_integer(divide(to_unsigned((sum - sumB),32),to_unsigned(wF,32)));
			
			wait until( clk'event and clk = '1' and en='1');
			
			between := wB * wF * (mB - mF) * (mB - mF);
			
			if between >= max then
				threshold1 := i;
				if between > max then
					threshold2 := i;
				end if ;
				max := between;            
			end if;
    
			--return ( threshold1 + threshold2 ) / 2.0;
		end loop main;
		
		tmp := ( threshold1 + threshold2 );
		internal_thres <= std_logic_vector(to_unsigned(tmp,32) srl 2);
		internal_ready <= '1';
	end process;

end Behavioral;

