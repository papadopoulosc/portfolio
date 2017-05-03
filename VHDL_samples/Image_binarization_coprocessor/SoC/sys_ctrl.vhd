---------------------------------------------------------------------------------
--
--  Entity:      sys_ctrl
--  Filename:    sys_ctrl.vhd
--  Description: Combines all clock generators, debouncing of buttons and/or
--               switches and control hardware in the System_on_Chip 
--  Author:      H.J. Lincklaen Arriens
--  Date:        July, 2007
--  Modified:    
--  Remarks:     VHDL93, tested with ModelSim and Synplify_Pro
--
--               In this template file, a master clock, a clock for a single slave
--               (that in this template is derived from the master clock!) and    
--               a debouncing circuit for the reset signals (synchronised with the
--               falling edge of the master clock) is  described.                 
--               SKIP WHAT YOU DO NOT NEED AND ADD WHAT IS NEEDED ....
---------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;
USE work.ET4351_Pkg.all;


--------------------------------------------------------------------------------
ENTITY sys_ctrl IS
--------------------------------------------------------------------------------
    GENERIC ( 
        MST_DIV_FACTOR_g   : POSITIVE := 4;
        MST_PERIODS_HIGH_g : POSITIVE := 2;
--        SLV_DIV_FACTOR_g   : POSITIVE := 4;
--        SLV_PERIODS_HIGH_g : POSITIVE := 2;
        MIN_RST_CNT_g      : POSITIVE := 100000 -- minimum contiguous periods for reset
        );
    PORT ( 
        clk_ext_i :  IN STD_LOGIC;
        rst_btn_i :  IN STD_LOGIC;
        clk_mst_o : OUT STD_LOGIC;   -- continuous master-clock
--        clk_slv_o : OUT STD_LOGIC;   -- continuous slave-clock
        rst_ext_o : OUT STD_LOGIC    -- debounced reset signal, active high,
                                   -- synchronous with trailing edges of clk_mst!
        );
END ENTITY sys_ctrl;


--------------------------------------------------------------------------------
ARCHITECTURE arch_sys_ctrl OF sys_ctrl IS
--------------------------------------------------------------------------------
   
    -- component declarations can be found in the ET4351_Pkg

    SIGNAL clk_mst_s    : STD_LOGIC; 
    SIGNAL rst_pulse_s  : STD_LOGIC; 
    SIGNAL rst_shftd_s  : STD_LOGIC; 

BEGIN

    clk_mst_o <= clk_mst_s;
    rst_ext_o <= rst_shftd_s;

I_MST_CLK: 
    COMPONENT clk_div
        GENERIC MAP ( MST_DIV_FACTOR_g, MST_PERIODS_HIGH_g )
        PORT MAP (
            clk_in  => clk_ext_i,
            clk_out => clk_mst_s
            );

--I_SLV_CLK: 
--    COMPONENT clk_div
--        GENERIC MAP ( SLV_DIV_FACTOR_g, SLV_PERIODS_HIGH_g )
--        PORT MAP (
--            clk_in  => clk_mst_s,
--            clk_out => clk_slv_o
--            );

I_DEBOUNCED_RST:
    COMPONENT debouncer
        GENERIC MAP ( MIN_RST_CNT_g )
        PORT MAP ( 
            clk_in    => clk_ext_i,
            button_in => rst_btn_i,
            clean_out => rst_pulse_s
            );
            
RST_SHIFT:          
    PROCESS ( clk_mst_s, rst_pulse_s )
    BEGIN
        IF FALLING_EDGE( clk_mst_s ) THEN
            IF ( rst_pulse_s = '1') THEN
                rst_shftd_s <= '1';
            ELSE
                rst_shftd_s <= '0';
            END IF;
         END IF;
    END PROCESS RST_SHIFT;

END ARCHITECTURE arch_sys_ctrl;
 