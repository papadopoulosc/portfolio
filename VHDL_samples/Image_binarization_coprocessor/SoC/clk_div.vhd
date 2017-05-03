---------------------------------------------------------------------------------
--
--  Entity:      clk_div.vhd
--  Filename:    clk_div.vhd
--  Description: Divide the external clock to obtain a continuous system clock.
--               Parameters are 
--                   DIV_FACTOR_g   - the division factor ( DIV_FACTOR_g >= 2 ), 
--                   PERIODS_HIGH_g - the number of cycles of the external clock 
--                                    that the derived clock should stay high
--                                    ( 1 <= PERIODS_HIGH_g < DIV_FACTOR_g ).
--  Author:      H.J. Lincklaen Arriens
--  Date:            July, 2007
--  Modified:       April, 2008: Finally clock_enable used (good practice), Huib 
--                  March, 2009: CLOG2 function replaced with function NBITS
--               November, 2009: INTEGER instead of LOGIC_VECTOR for count_S, so
--                               references to NBITS removed
--               February, 2010: Single flip-flop if DIV_FACTOR_g == 2
--
--  Remarks:     VHDL93, tested with ModelSim and Synplify_Pro
--
---------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


--------------------------------------------------------------------------------
ENTITY clk_div IS
--------------------------------------------------------------------------------
    GENERIC ( 
        DIV_FACTOR_g   : POSITIVE := 4;
        PERIODS_HIGH_g : POSITIVE := 2 
        );
    PORT ( 
        clk_in  :  IN STD_LOGIC;
        clk_out : OUT STD_LOGIC 
        );
END ENTITY clk_div;


--------------------------------------------------------------------------------
ARCHITECTURE arch_clk_div OF clk_div IS
--------------------------------------------------------------------------------
    SIGNAL count_s : INTEGER RANGE 0 TO DIV_FACTOR_g -1;
    SIGNAL clkEn_s : STD_LOGIC; 
    SIGNAL Dc_s    : STD_LOGIC := '1'; 
    
BEGIN

divx:
    IF (DIV_FACTOR_g > 2) GENERATE
        clkEn_s <= '1' WHEN ((count_s = (DIV_FACTOR_g -1))  OR
                             (count_s = PERIODS_HIGH_g -1)) ELSE '0';
        Dc_s    <= '0' WHEN ( count_s < PERIODS_HIGH_g )    ELSE '1';
    
    main:
        PROCESS( clk_in, count_s )
        BEGIN
            IF RISING_EDGE( clk_in ) THEN
                IF (clkEn_s = '1') THEN
                    clk_out <= Dc_s;
                END IF;
                IF ( count_s = (DIV_FACTOR_g -1) ) THEN
                    count_s <= 0;
                ELSE
                    count_s <= count_s +1;
                END IF;
            END IF;
        END PROCESS;
    END GENERATE divx;

div2:
    IF (DIV_FACTOR_g = 2) GENERATE
        clk_out <= Dc_s;
    main:
        PROCESS( clk_in )
        BEGIN
            IF RISING_EDGE( clk_in ) THEN
                Dc_s <= NOT (Dc_s);
            END IF;
        END PROCESS;
    END GENERATE div2;

END ARCHITECTURE arch_clk_div;
    
