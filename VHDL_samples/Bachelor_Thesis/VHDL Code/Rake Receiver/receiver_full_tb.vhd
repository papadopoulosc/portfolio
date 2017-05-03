-- Created and best viewed with Xilinx ISE 9.2 editor

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
--library work;
use work.rake_pack.all;

-- This testbench produced automatically by ISE, using as uut the file: rake_receiver_frame.vhd

entity receiver_full_tb_vhd is
end receiver_full_tb_vhd;

architecture behavior of receiver_full_tb_vhd is

	-- Component Declaration for the Unit Under Test (UUT)
	component rake_receiver
	port(
		PN_code				: in std_logic_vector(14 downto 0);
		clk					: in std_logic;
		rst					: in std_logic;
		en						: in std_logic;
		signal_real			: in std_logic_vector(13 downto 0);          
		a_real				: out arr;
		rake_en				: out std_logic;
		rake_shift			: out std_logic;
		estimation_en		: out std_logic;
		estimation_shift	: out std_logic;
		pn_set				: out std_logic;
		estimated_signal	: out std_logic_vector(13 downto 0)
		);
	end component;

	-- Inputs
	signal clk			: std_logic := '0';
	signal rst			: std_logic := '0';
	signal en			: std_logic := '0';
	signal PN_code 	: std_logic_vector(14 downto 0) := (others=>'0');
	signal signal_real: std_logic_vector(13 downto 0) := (others=>'0');

	-- Outputs
	signal a_real 				: arr;
	signal rake_en 			: std_logic;
	signal rake_shift 		: std_logic;
	signal estimation_en 	: std_logic;
	signal estimation_shift : std_logic;
	signal pn_set 				: std_logic;
	signal estimated_signal : std_logic_vector(13 downto 0);

begin

	-- Instantiate the Unit Under Test (UUT)
	uut: rake_receiver port map(	PN_code => PN_code,
											clk => clk,
											rst => rst,
											en => en,
											signal_real => signal_real,
											a_real => a_real,
											rake_en => rake_en,
											rake_shift => rake_shift,
											estimation_en => estimation_en,
											estimation_shift => estimation_shift,
											pn_set => pn_set,
											estimated_signal => estimated_signal);

	-- process for clock
	tb:
	process
	begin
		CLK <= not CLK;
		wait for 0.5 ns;
	end process;
	
	-- process for signal_real
	process
	begin
		EN <= '1';
		RST <= '1';
      wait for 1ns;
		  
		RST <= '0';
		PN_code <= "101100100011110";
		wait for 1ns;
		wait for 1ns;  signal_real <= "00000000011000";
		wait for 1ns;  signal_real <= "00000000001000";
		wait for 1ns;  signal_real <= "00000000010110";
		wait for 1ns;  signal_real <= "00000000100100";
		wait for 1ns;  signal_real <= "00000000010100";
		wait for 1ns;  signal_real <= "00000000000100";
		wait for 1ns;  signal_real <= "00000000010010";
		wait for 1ns;  signal_real <= "00000000000010";
		wait for 1ns;  signal_real <= "11111111110010";
		wait for 1ns;  signal_real <= "11111111100010";
		wait for 1ns;  signal_real <= "11111111110000";
		wait for 1ns;  signal_real <= "11111111111110";
		wait for 1ns;  signal_real <= "00000000001100";
		wait for 1ns;  signal_real <= "00000000011010";
		wait for 1ns;  signal_real <= "00000000001010";
		wait for 1ns;  signal_real <= "00000000011000";
		wait for 1ns;  signal_real <= "00000000001000";
		wait for 1ns;  signal_real <= "00000000010110";
		wait for 1ns;  signal_real <= "00000000100100";
		wait for 1ns;  signal_real <= "00000000010100";
		wait for 1ns;  signal_real <= "00000000000100";
		wait for 1ns;  signal_real <= "00000000010010";
		wait for 1ns;  signal_real <= "00000000000010";
		wait for 1ns;  signal_real <= "11111111110010";
		wait for 1ns;  signal_real <= "11111111100010";
		wait for 1ns;  signal_real <= "11111111110000";
		wait for 1ns;  signal_real <= "11111111111110";
		wait for 1ns;  signal_real <= "00000000001100";
		wait for 1ns;  signal_real <= "00000000011010";
		wait for 1ns;  signal_real <= "00000000001010";
		  
		wait for 1ns; signal_real <= "00000000011000";  --24			
		wait for 1ns; signal_real <= "00000000001000";  --8
		wait for 1ns; signal_real <= "00000000010110";  --22
		wait for 1ns; signal_real <= "00000000100100";  --36
		wait for 1ns; signal_real <= "00000000010100";  --20
		wait for 1ns; signal_real <= "00000000000100";  --4
		wait for 1ns; signal_real <= "00000000010010";  --18
		wait for 1ns; signal_real <= "00000000000010";  --2
		wait for 1ns; signal_real <= "11111111110010";  --minus 14
		wait for 1ns; signal_real <= "11111111100010";  --minus 30
		wait for 1ns; signal_real <= "11111111110000";  --minus 16
		wait for 1ns; signal_real <= "11111111111110";  --minus 2
		wait for 1ns; signal_real <= "00000000001100";  --12
		wait for 1ns; signal_real <= "00000000011010";  --26
		wait for 1ns; signal_real <= "00000000001010"; 	--10
		wait for 1ns; signal_real <= "11111111111010";  --minus 6
		wait for 1ns; signal_real <= "00000000001010";  --10
		wait for 1ns; signal_real <= "11111111111010";  --minus 6
		wait for 1ns; signal_real <= "11111111101100";  --minus 20
		wait for 1ns; signal_real <= "11111111111110";  --minus 2
		wait for 1ns; signal_real <= "00000000001110";  --14
		wait for 1ns; signal_real <= "11111111111110";  --minus 2 
		wait for 1ns; signal_real <= "00000000001110";  --14 
		wait for 1ns; signal_real <= "00000000011100";  --28
		wait for 1ns; signal_real <= "00000000101000";  --40
		wait for 1ns; signal_real <= "00000000010100";  --20
		wait for 1ns; signal_real <= "00000000000010";  --2
		wait for 1ns; signal_real <= "11111111110010";  --minus 14
		wait for 1ns; signal_real <= "11111111100100";  --minus 28 
		wait for 1ns; signal_real <= "11111111101100";  --minus 20
		wait for 1ns; signal_real <= "11111111101100";  --minus 20
		
		wait for 30ns;
					
	end process;

end;