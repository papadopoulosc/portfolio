---------------------------------------------------------------------------------
--
--  Entity:      debouncer
--  Filename:    debouncer.vhd
--  Purpose:     Translate a 'bouncing' pressed button signal or signal from
--               a toggled switch into a clean signal (active high) 
--  Author:      H.J. Lincklaen Arriens
--  Date:        July, 2007
--  Modified:    April, 2010 -- int_count_s changed into INTEGER type (Huib)
--  Remarks:     VHDL93, tested with ModelSim and Synplify_Pro
--               Needs CLOG2 function in work.misc_numeric_pkg.all as defined in
--               misc_numeric_pkg.vhd 
--
-- Description:  The generic variable MIN_DLY_CNT_g determines the minimum number
--               of input clock periods that the pressed button signal should remain
--               stable before an output pulse is delivered. 
--  Remarks:     Given a external input clock of 100MHz (10 ns period), 
--               a MIN_DLY_CNT_g of 100000, needs a clean input signal of at least
--               1 ms and also the resulting pulse will be delayed 1 ms. 
--               Since the input signal is simply integrated, a 'noisy' input signal
--               needs a pulse width longer than this minimum 1 ms.
--               ( for 10 ms, MIN_DLY_CNT_g = 10^6 ).
--
---------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


--------------------------------------------------------------------------------
ENTITY debouncer IS
--------------------------------------------------------------------------------
    GENERIC ( 
        MIN_DLY_CNT_g : POSITIVE := 100000  -- minimum contiguous periods, GE 2
        );
    PORT ( 
        clk_in    :  IN STD_LOGIC;
        button_in :  IN STD_LOGIC;
        clean_out : OUT STD_LOGIC
        );
END ENTITY debouncer;


--------------------------------------------------------------------------------
ARCHITECTURE arch_debouncer OF debouncer IS
--------------------------------------------------------------------------------

    SIGNAL int_count_s : INTEGER RANGE 0 TO MIN_DLY_CNT_g := 0;
    SIGNAL logic_lvl_s : STD_LOGIC;
    SIGNAL enable_s    : STD_LOGIC;

BEGIN
    
    logic_lvl_s <= '1' WHEN (int_count_s >= MIN_DLY_CNT_g/2)   -- floor(x/2)
                       ELSE '0';
    enable_s    <= '1' WHEN ((int_count_s = 0) OR (int_count_s = MIN_DLY_CNT_g)) 
                       ELSE '0';

integrate:
    PROCESS( clk_in )
    BEGIN
        IF RISING_EDGE( clk_in ) THEN
            IF ( (button_in = '1') AND (int_count_s /= MIN_DLY_CNT_g) ) THEN
                int_count_s <= int_count_s + 1;
            ELSIF ( (button_in = '0') AND (int_count_s /= 0) ) THEN
                int_count_s <= int_count_s - 1;
            END IF;
            IF enable_s = '1' THEN
                clean_out <= logic_lvl_s;
            END IF;
        END IF;
    
    END PROCESS integrate;
    
END ARCHITECTURE arch_debouncer;
                