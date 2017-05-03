-- ***************************************************************************************************
-- Company: APEL
-- Engineer: Charalampos Papadopoulos
--
-- Create Date: 2009.02.01, 2009.07.24
-- Design Name: rake_receiver (rake_receiver_frame.vhd)
-- Component Name: rake_receiver (rake_receiver_frame.vhd)
-- Target Device: xc4vsx35-10ff668
-- Tool versions: ISE 9.2, Modelsim 6.1f, Matlab R2007a

-- Description:
--		Declaration of the 3 basic sub-circuits of the system: 
--			1) Rake circuit 
--			2) Channel estimator
--			3) Rake control

-- Dependencies:
--    rake (rake.vhd)
--		channel_est (channel_estimator.vhd)
--		rake_control (FSM.vhd)

-- Revision:
--    <v1.0>

-- Additional Comments:
-- 	It is a structural implementation of the Complete Circuit
-- ***************************************************************************************************

-- Created and best viewed with Xilinx ISE 9.2 editor

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library work;
use work.rake_pack.all;

entity rake_receiver is
	generic	(	N																			: positive:=14;
					data_num																	: positive:=5);
	port		(	PN_code																	: in std_logic_vector(14 downto 0);
					clk,rst,en																: in std_logic;
					signal_real																: in std_logic_vector(N-1 downto 0);
					a_real																	: out arr;
					rake_en,rake_shift,estimation_en,estimation_shift,pn_set	: out std_logic;
					estimated_signal														: out std_logic_vector(13 downto 0));
end rake_receiver;

architecture str of rake_receiver is
    
	component rake
		generic	(	N								: positive:=14);
		port		(	signal_in					: in std_logic_vector(N-1 downto 0);
						coef_arr						: in arr;
						pn_code						: in std_logic_vector(14 downto 0);
						shift,clk,rst,pnset,en	: in std_logic;
						estimated_signal			: out std_logic_vector(13 downto 0));
	end component;
	
	component channel_est 
		generic	(	N								: positive:=14);
		port		(	PN_code						: in std_logic_vector(14 downto 0);
						clk,rst,pn_set,en,shift	: in std_logic;
						signal_in					: in std_logic_vector(N-1 downto 0);
						a								: out arr);
	end component;
	
	component rake_control 
		generic	(	data_num															: positive:=5);
		port		(	clk,rst,en														: in std_logic;
						rake_en,estimation_en										: out std_logic;
						rake_shift,estimation_shift,pn_set						: out std_logic;
						global_counter_pos,global_counter_neg,rake_counter	: buffer integer);
	end component;
	
	--Declaration of the signals used in the design. A name is asigned to every wire that isn't an input or...
	--...output of the rake_receiver entity.
	
	signal coefficients										: arr;
	signal r_en,r_shift,est_en,est_shift,pn_set_sig	: std_logic;
	signal c_global_pos,c_global_neg,c_rake			: integer;

--Connection of the subcircuits between them and with the inputs and outputs of the rake_receiver system.
begin
	
	rake_en				<= r_en;
	rake_shift			<= r_shift;
	estimation_en		<= est_en;
	estimation_shift	<= est_shift;
	a_real				<= coefficients;
	pn_set				<= pn_set_sig;

	r	:	rake 				port map(	signal_in => signal_real,
												coef_arr => coefficients,
												pn_code => PN_code,
												shift => r_shift,
												clk => clk,
												rst => rst,
												pnset => pn_set_sig,
												en => r_en,
												estimated_signal => estimated_signal);
					
	ce	:	channel_est		port map(	PN_code => PN_code,
												clk => clk,
												rst => rst,
												pn_set => pn_set_sig,
												en => est_en,
												shift => est_shift,
												signal_in => signal_real,
												a => coefficients);
										
	rc	:	rake_control	port map(	clk => clk,
												rst => rst,
												en => en,
												rake_en => r_en,
												estimation_en => est_en,
												rake_shift => r_shift,
												estimation_shift => est_shift,
												pn_set => pn_set_sig,
												global_counter_pos => c_global_pos,
												global_counter_neg => c_global_neg,
												rake_counter => c_rake);
end str;