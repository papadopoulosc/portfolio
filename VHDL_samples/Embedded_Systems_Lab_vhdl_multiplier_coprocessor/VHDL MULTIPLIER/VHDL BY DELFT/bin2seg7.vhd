------------------------------------------------------------------
--
-- Function : 7 LED-segment driver
--
--
--
-------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY bin2seg7 IS
	PORT
	(
        data  		: in std_logic_vector(3 downto 0);
	    dec_punt	: in std_logic;
	  	seg7		: out std_logic_vector(6 downto 0);
		punt	    : out std_logic
	);
END bin2seg7;


ARCHITECTURE arch OF bin2seg7 IS
begin
  process(data)
    begin
      case data is
--		    					gfedcba			
        when "0000" => seg7 <= "1000000"; -- 0  
	    when "0001" => seg7 <= "1111001"; -- 1  
		when "0010" => seg7 <= "0100100"; -- 2  
		when "0011" => seg7 <= "0110000"; -- 3  
		when "0100" => seg7 <= "0011001"; -- 4  
		when "0101" => seg7 <= "0010010"; -- 5  
		when "0110" => seg7 <= "0000010"; -- 6  
		when "0111" => seg7 <= "1111000"; -- 7  
		when "1000" => seg7 <= "0000000"; -- 8  
		when "1001" => seg7 <= "0010000"; -- 9  
    	when "1010" => seg7 <= "0001000"; -- A  
    	when "1011" => seg7 <= "0000011"; -- B  
    	when "1100" => seg7 <= "1000110"; -- C  
    	when "1101" => seg7 <= "0100001"; -- D  
    	when "1110" => seg7 <= "0000110"; -- E  
    	when "1111" => seg7 <= "0001110"; -- F  
        when others => seg7 <= "0110110"; -- Error 
     end case;
   end process;
  punt <= not(dec_punt);
END arch;





