library ieee ;
use ieee.std_logic_1164.all ;

Package DataTypes Is
Type alpha Is Array (Natural Range <>) of
 std_logic_vector(15 downto 0);
End DataTypes;