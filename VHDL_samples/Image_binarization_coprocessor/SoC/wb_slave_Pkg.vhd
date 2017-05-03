LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.ET4351_Pkg.all;

PACKAGE wb_slave_Pkg IS

    --  8-bit WB-slave inputs, from the WB-bus
    -- TYPE wb2slv8b_type IS RECORD
        -- adr_i     : STD_LOGIC_VECTOR ( 7 DOWNTO 0); -- address bits
        -- dat_i     : STD_LOGIC_VECTOR ( 7 DOWNTO 0); -- Databus input
        -- we_i      : STD_LOGIC;                      -- Write enable input
        -- stb_i     : STD_LOGIC;                      -- strobe signals / core select signal
        -- cyc_i     : STD_LOGIC;                      -- valid BUS cycle input
    -- END RECORD;

    -- -- 8-bit WB-slave outputs to the WB-bus
    -- TYPE slv8b2wb_type IS RECORD
        -- dat_o     : STD_LOGIC_VECTOR ( 7 DOWNTO 0); -- Databus output
        -- ack_o     : STD_LOGIC;                      -- Bus cycle acknowledge output
        -- int_o     : STD_LOGIC;                      -- interrupt request output
    -- END RECORD;

    -- -- 16-bit WB-slave inputs, from the WB-bus
    -- TYPE wb2slv16b_type IS RECORD
        -- adr_i     : STD_LOGIC_VECTOR (15 DOWNTO 0); -- address bits
        -- dat_i     : STD_LOGIC_VECTOR (15 DOWNTO 0); -- Databus input
        -- we_i      : STD_LOGIC;                      -- Write enable input
        -- stb_i     : STD_LOGIC;                      -- strobe signals / core select signal
        -- cyc_i     : STD_LOGIC;                      -- valid BUS cycle input
        -- sel_i     : STD_LOGIC_VECTOR ( 1 DOWNTO 0); -- Byte selector within 16-bit data
    -- END RECORD;

    -- -- 16-bit WB-slave outputs to the WB-bus
    -- TYPE slv16b2wb_type IS RECORD
        -- dat_o     : STD_LOGIC_VECTOR (15 DOWNTO 0); -- Databus output
        -- ack_o     : STD_LOGIC;                      -- Bus cycle acknowledge output
        -- int_o     : STD_LOGIC;                      -- interrupt request output
    -- END RECORD;

    --  32-bit WB-slave inputs, from the WB-bus
    TYPE wb2slv32b_type IS RECORD
        adr_i     : STD_LOGIC_VECTOR (31 DOWNTO 0); -- address bits
        dat_i     : STD_LOGIC_VECTOR (31 DOWNTO 0); -- Databus input
        we_i      : STD_LOGIC;                      -- Write enable input
        stb_i     : STD_LOGIC;                      -- strobe signals / core select signal
        cyc_i     : STD_LOGIC;                      -- valid BUS cycle input
        sel_i     : STD_LOGIC_VECTOR ( 3 DOWNTO 0); -- Byte selector within 32-bit data
    END RECORD;

    --  32-bit WB-slave outputs to the WB-bus
    TYPE slv32b2wb_type IS RECORD
        dat_o     : STD_LOGIC_VECTOR (31 DOWNTO 0); -- Databus output
        ack_o     : STD_LOGIC;                      -- Bus cycle acknowledge output
        int_o     : STD_LOGIC;                      -- interrupt request output
    END RECORD;


    -- COMPONENT wb_slave_ex8b IS
        -- GENERIC ( 
            -- DLY_ACK_TICKS_g  :  NATURAL := 0;   -- GE 0
            -- DLY_BUSY_TICKS_g : POSITIVE := 1    -- GE 1
            -- );
        -- PORT (
            -- clk_i      : STD_LOGIC;             -- master clock input
            -- rst_i      : STD_LOGIC;             -- synchronous active high reset
            -- --wishbone signals
            -- wb_slv_in  :  IN wb2slv8b_type;
            -- wb_slv_out : OUT slv8b2wb_type
            -- );
    -- END COMPONENT wb_slave_ex8b;

    -- COMPONENT wb_slave_ex16b IS
        -- GENERIC ( 
            -- DLY_ACK_TICKS_g  :  NATURAL := 0;   -- GE 0
            -- DLY_BUSY_TICKS_g : POSITIVE := 1    -- GE 1
            -- );
        -- PORT (
            -- clk_i      : STD_LOGIC;             -- master clock input
            -- rst_i      : STD_LOGIC;             -- synchronous active high reset
            -- --wishbone signals
            -- wb_slv_in  :  IN wb2slv16b_type;
            -- wb_slv_out : OUT slv16b2wb_type
            -- );
    -- END COMPONENT wb_slave_ex16b;

    COMPONENT wb_slave_ex32b IS
        GENERIC ( 
            DLY_ACK_TICKS_g  :  NATURAL := 0;   -- GE 0
            DLY_BUSY_TICKS_g : POSITIVE := 1    -- GE 1
            );
        PORT (
            clk_i      : STD_LOGIC;             -- master clock input
            rst_i      : STD_LOGIC;             -- synchronous active high reset
            -- wishbone signals
            wb_slv_in  :  IN wb2slv32b_type;
            wb_slv_out : OUT slv32b2wb_type
            );
    END COMPONENT wb_slave_ex32b;

END PACKAGE wb_slave_Pkg;
