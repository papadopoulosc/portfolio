library IEEE;
use IEEE.std_logic_1164.all;
--use ieee.std_logic_unsigned.ALL;
--use ieee.std_logic_arith.ALL;
use ieee.numeric_std.all;

-- The following entity implements an FSM. You can change the signals to your needs.
-- Try to use descriptive names for the signals and states. The StateOut can be used
-- to debug the hardware (by displaying the current state on the 7-segment display.

entity FSM is
  port (clk 			: in std_logic;
		reset			: in std_logic;
        A   			: in std_logic;
        B   			: in std_logic;
        C   			: out std_logic;
        D   			: out std_logic;
		StateOut		: out std_logic_vector(7 downto 0));
end FSM;

architecture behaviour of FSM is
   type StateType is (State1, State2, State3, State4);
   signal CurrentState, NextState : StateType;
begin
  

-- This process is used to generate a synchronus state machine. Also
-- the reset is implemented by this process.
state_register: process (reset, clk)
  begin
	if (reset = '1') then
	  CurrentState <= State1;
	elsif ((clk = '1') and clk'event) then 
	  CurrentState <= NextState;
	end if;
  end process state_register;


-- This process is used to determine the output signals based upon
-- the current state.
output_decode_logic: process (CurrentState)
  begin
	-- set state default values --
    C 			<= '0';
	D			<= '0';
	
	StateOut		<= std_logic_vector(to_unsigned(0,8));
		      
	-- calculate outputs for every state which are different from the default --
    case CurrentState is
	  ------ read byte a1 ------
		when State1 			=>
	  	  StateOut 			<= std_logic_vector(to_unsigned(1,8));
		when State2		 		=>
		  D 		<= '1';			
	  	  StateOut 			<= std_logic_vector(to_unsigned(2,8));
		when State3				=>
		  C			<= '1';
		  D			<= '1';
	  	  StateOut 			<= std_logic_vector(to_unsigned(3,8));
		when State4			 	=>
		  D			<= '1';
	  	  StateOut 			<= std_logic_vector(to_unsigned(4,8));
		when others =>
	  	  null;	
    end case;
  end process output_decode_logic;



-- In this process the new state is calculated based upon the inputs of the 
-- state machine. Remenber to put all used input signals in the sensitivity list
-- of the process. 
state_decode_logic: process (CurrentState, A, B) -- add all required inputs here --  
  begin
    -- stay in current state by default (you may want to change this behaviour)
	NextState <= CurrentState;

	-- determine next state depending on the input signals
	case CurrentState is
		when State1 			=>
	  	  if (A = '1') and (B = '1') then
			NextState	<=	State3;
		  elsif (A = '1') then
			NextState 	<=	State2;
		  else
			NextState	<= 	State4;
		  end if; 
		when State2		 		=>
	  	  if (A = '1') then
			NextState	<=	State3;
		  elsif (B = '1') then
			NextState 	<=	State2;
		  end if; 
		when State3				=>
  		  NextState	<=	State2;
		when State4			 	=>
		  if (A = '0') and (B = '1') then
    	    NextState	<=	State2;
		  end if;
	end case;
  end process state_decode_logic;
end behaviour;


