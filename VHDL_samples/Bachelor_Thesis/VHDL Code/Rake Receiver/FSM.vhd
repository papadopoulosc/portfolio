-- ***************************************************************************************************
-- Company: APEL
-- Engineer: Charalampos Papadopoulos
--
-- Create Date: 2009.02.01, 2009.07.24
-- Design Name: rake_receiver (rake_receiver_frame.vhd)
-- Component Name: rake_control (FSM.vhd)
-- Target Device: xc4vsx35-10ff668
-- Tool versions: ISE 9.2, Modelsim 6.1f, Matlab R2007a

-- Description:
--    One of the 3 subcircuits: The control circuit. It provides the other two subcircuits with the correct...
--		...timing signals. Three countes are used:
-- 	1) The global_counter_pos counts the positive edges of the clock.
-- 	2) The global_counter_neg counts the negative edges of the clock and is essential because some signals...
--   		...MUST change their value at the negative edge of the clock. 
-- 	3) The rake_counter is used in the normal operation of the rake circuit and counts again and again until...
--   		...the channel has to be estimated again. If this counter wasn't used, then the other two counters would...
--   		...reach very high values and would require registers of many bits, wasting a significant amount of area.
-- 	The above counters control the following signals:
-- 		a) rake_en           : It enables the rake circuit
-- 		b) rake_shift        : It tells the flip flops of the rake circuit when to reset
-- 		c) estimation_en     : It enables the estimation circuit
-- 		d) estimation_shift	: It tells the flip flops of the estimator when to reset
-- 		e) pn_set            : It defines when the PN registes should be loaded.

-- Dependencies:
--    rake_receiver (rake_receiver_frame.vhd)

-- Revision:
--    <v1.0>

-- Additional Comments:
-- 	It is like GP FSM (with a global counter). CM FSM (state machines) was not synthesizable.
-- 	The first process (count) increments counters, whereas the second (finale), depending on counters' value alters the control signals.
-- 	The third counter (rake_counter) starts working after 45(3[PN]x15)+2(reset) = 47 clock cycles. Every 15 clocks it gets zero.
-- ***************************************************************************************************

-- Created and best viewed with Xilinx ISE 9.2 editor
		
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity rake_control is
	generic	(	data_num															: positive:=5); -- 5 is random and is the number of symbols before repeating channel estimation
	port		(	clk,rst,en														: in std_logic;
					rake_en,estimation_en										: out std_logic;
					rake_shift,estimation_shift,pn_set						: out std_logic;
					global_counter_pos,global_counter_neg,rake_counter	: buffer integer);
end rake_control;

architecture beh of rake_control is
begin

	counts: 
	process(clk,rst,en,global_counter_pos,global_counter_neg,rake_counter)
	begin
		if rst = '1' then
			global_counter_pos <= 0;
			global_counter_neg <= 0;
			rake_counter <= 0;
		else
			-- Positive counter
			if clk'event and clk = '1' then
				if en = '1' then
					if global_counter_pos = data_num*15 then
						global_counter_pos <= 0;
					end if;
					global_counter_pos <= global_counter_pos+1;
				end if;            
			end if;

			-- Negative counter
			if clk'event and clk = '0' then
				if en = '1' then
					if global_counter_neg = data_num*15 then
						global_counter_neg <= 0;
					end if;
					if global_counter_neg >= 47 then
						rake_counter <= rake_counter+1;
					end if;
					if rake_counter = 15 then
						rake_counter <= 1;
					end if;
				  	global_counter_neg <= global_counter_neg+1;
				end if;
			end if;
		end if;
	end process;


	finale: 
	process(global_counter_pos,global_counter_neg,rake_counter,clk)
	begin
	------------------
		if global_counter_pos = 0 then
			rake_en				<= '0';
			rake_shift			<= '0';
			estimation_en		<= '0';
			estimation_shift	<= '0';
			pn_set				<= '0';
		end if;
	------------------
		if global_counter_pos = 1 then
			rake_en				<= '0';
			rake_shift			<= '1';
			estimation_en		<= '0';
			estimation_shift	<= '1';
			pn_set				<= '1';
		end if;
	------------------
		if global_counter_pos = 2 then
			rake_en				<= '0';
			rake_shift			<= '0';
			estimation_en		<= '1';
			estimation_shift	<= '0';
			pn_set				<= '0';
		end if;
	------------------
		if global_counter_neg = 16 then
			rake_en				<= '0';
			rake_shift			<= '0';
			estimation_en		<= '1';
			estimation_shift	<= '1';
			pn_set				<= '0';
		end if;
	------------------
		if global_counter_neg = 17 then
			rake_en				<= '0';
			rake_shift			<= '0';
			estimation_en		<= '1';
			estimation_shift	<= '0';
			pn_set				<= '0';
		end if;
	------------------
		if global_counter_pos = 32 then
			rake_en				<= '1';
			rake_shift			<= '0';
			estimation_en		<= '1';
			estimation_shift	<= '1';
			pn_set				<= '0';
		end if;
	------------------
		if global_counter_pos = 33 then
			rake_en				<= '1';
			rake_shift			<= '1';
			estimation_en		<= '0';
			estimation_shift	<= '0';
			pn_set				<= '0';
		end if;
	------------------ 
		if global_counter_pos = 34 then
			rake_en				<= '1';
			rake_shift			<= '0';
			estimation_en		<= '0';
			estimation_shift	<= '0';
			pn_set				<= '0';
		end if;
	------------------
		if global_counter_neg = 47 then
			rake_en				<= '1';
			rake_shift			<= '1';
			estimation_en		<= '0';
			estimation_shift	<= '0';
			pn_set				<= '0';
		end if;
	------------------
		if rake_counter = 1 then
			rake_en				<= '1';
			rake_shift			<= '0';
			estimation_en		<= '0';
			estimation_shift	<= '0';
			pn_set				<= '0';
		end if;
	------------------
		if rake_counter = 15 then
			rake_en				<= '1';
			rake_shift			<= '1';
			estimation_en		<= '0';
			estimation_shift	<= '0';
			pn_set				<= '0';
		end if;
	------------------

	end process;

end beh;