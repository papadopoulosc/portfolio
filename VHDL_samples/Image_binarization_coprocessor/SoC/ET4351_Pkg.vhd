--------------------------------------------------------------------------------
--
--  Filename:    ET4351_Pkg.vhd
--  Description: Definitions regarding the MBL1c-ET4351 SoC
--  Author:      Huib Lincklaen Arriens
--  Date:        May, 2010
--  Modified:    
--  Remarks:     VHDL93, tested with ModelSim and Synplify_Pro
--
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;


--------------------------------------------------------------------------------
PACKAGE ET4351_Pkg IS
--------------------------------------------------------------------------------

    CONSTANT  C_8_ZEROS : STD_LOGIC_VECTOR ( 7 DOWNTO 0) := (OTHERS => '0');
    CONSTANT C_16_ZEROS : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
    CONSTANT C_24_ZEROS : STD_LOGIC_VECTOR (23 DOWNTO 0) := (OTHERS => '0');
    CONSTANT C_32_ZEROS : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');

    CONSTANT C_16_ONES  : STD_LOGIC_VECTOR (15 DOWNTO 0) := (OTHERS => '0');
    CONSTANT C_24_ONES  : STD_LOGIC_VECTOR (23 DOWNTO 0) := (OTHERS => '0');


----------------------------------------------------------------------------------------------
-- TYPE DEFINITIONS
----------------------------------------------------------------------------------------------

    TYPE memory_map_type IS ARRAY(NATURAL RANGE <>) OF STD_LOGIC_VECTOR (31 DOWNTO 0);

    TYPE c2dmemb_type IS RECORD
        ena : STD_LOGIC;
        adr : STD_LOGIC_VECTOR (31 DOWNTO 0);
        sel : STD_LOGIC_VECTOR ( 3 DOWNTO 0);
        wre : STD_LOGIC;
        dat : STD_LOGIC_VECTOR (31 DOWNTO 0);
    END RECORD;

    TYPE dmemb2c_type IS RECORD
        dat : STD_LOGIC_VECTOR (31 DOWNTO 0);
        ena : STD_LOGIC;
        int : STD_LOGIC;
    END RECORD;

    TYPE c2dmemb_array_type IS ARRAY(NATURAL RANGE <>) OF c2dmemb_type;
    TYPE dmemb2c_array_type IS ARRAY(NATURAL RANGE <>) OF dmemb2c_type;

    -- WB-master outputs to the wb-slaves
    TYPE mst2wb_type IS RECORD
        adr_o : STD_LOGIC_VECTOR (31 DOWNTO 0);  -- address bits
        dat_o : STD_LOGIC_VECTOR (31 DOWNTO 0);  -- databus output
        we_o  : STD_LOGIC;                       -- write enable output
        stb_o : STD_LOGIC;                       -- strobe signals
        cyc_o : STD_LOGIC;                       -- valid BUS cycle output
        sel_o : STD_LOGIC_VECTOR ( 3 DOWNTO 0);  -- Byte selector within 32-bit data
    END RECORD;

    -- WB-master inputs from the wb-slaves
    TYPE wb2mst_type IS RECORD
        dat_i : STD_LOGIC_VECTOR (31 DOWNTO 0);  -- databus input
        ack_i : STD_LOGIC;                       -- buscycle acknowledge input
        int_i : STD_LOGIC;                       -- interrupt request input
    END RECORD;

    TYPE mst2wb_array_type IS ARRAY(NATURAL RANGE <>) OF mst2wb_type;
    TYPE wb2mst_array_type IS ARRAY(NATURAL RANGE <>) OF wb2mst_type;

----------------------------------------------------------------------------------------------
-- COMPONENTS
----------------------------------------------------------------------------------------------

    COMPONENT mbl1c_core IS 
       GENERIC (
           -- The following value should match that used when
           -- creating imem(_init).vhd !!
           IMEM_ABITS_g : POSITIVE := 12                                   -- size in BYTES
           );
        PORT (
            clk_i       :  IN STD_LOGIC;
            rst_i       :  IN STD_LOGIC;
            ena_i       :  IN STD_LOGIC;
            int_i       :  IN STD_LOGIC;
            --
            imem_addr_o : OUT STD_LOGIC_VECTOR (IMEM_ABITS_g -1 DOWNTO 0);  -- BYTE adresses
            imem_data_i :  IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            --
            dmemb_o     : OUT c2dmemb_type;     -- towards data memory
            dmemb_i     :  IN dmemb2c_type;     -- from data memory
            --
            bri0_o      : OUT STD_LOGIC
            );
    END COMPONENT;

    COMPONENT imem IS
        GENERIC (
            WIDTH_g : POSITIVE := 32;
            ABITS_g : POSITIVE := 12                             -- size in WORDs
            );
        PORT (
            adr_i :  IN STD_LOGIC_VECTOR (ABITS_g -1 DOWNTO 0);  -- WORD adresses
            dat_o : OUT STD_LOGIC_VECTOR (WIDTH_g -1 DOWNTO 0)
            );
    END COMPONENT;

    COMPONENT dmem4 IS
        GENERIC (
            WIDTH_g : POSITIVE := 32;
            ABITS_g : POSITIVE := 12                             -- size in WORDs
            );
        PORT (
            clk_i :  IN STD_LOGIC;
            ce_i  :  IN STD_LOGIC;
            adr_i :  IN STD_LOGIC_VECTOR (ABITS_g -1 DOWNTO 0);  -- WORD adresses
            wre_i :  IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            dat_i :  IN STD_LOGIC_VECTOR (WIDTH_g -1 DOWNTO 0);
            dat_o : OUT STD_LOGIC_VECTOR (WIDTH_g -1 DOWNTO 0)
            );
    END COMPONENT;

    COMPONENT address_decoder IS
        GENERIC (
            MEMORY_MAP_g : memory_map_type(0 TO 1) := (X"00000000", X"FFFFFFFF")
            );
        PORT (
            c_dmemb_i :  IN c2dmemb_type;
            c_dmemb_o : OUT dmemb2c_type;
            x_dmemb_i :  IN dmemb2c_array_type (MEMORY_MAP_g'LENGTH -1 DOWNTO 0);
            x_dmemb_o : OUT c2dmemb_array_type (MEMORY_MAP_g'LENGTH -1 DOWNTO 0)
            );
    END COMPONENT;

    COMPONENT mst_wb_adapter IS
        PORT (
            x_dmemb_i :  IN c2dmemb_type;
            x_dmemb_o : OUT dmemb2c_type;
            mst_wb_i  :  IN wb2mst_type;
            mst_wb_o  : OUT mst2wb_type
            );
    END COMPONENT;

    COMPONENT clk_div IS
        GENERIC ( 
            DIV_FACTOR_g   : POSITIVE := 4;
            PERIODS_HIGH_g : POSITIVE := 2 
            );
        PORT ( 
            clk_in   :  IN STD_LOGIC;
            clk_out  : OUT STD_LOGIC 
            );
    END COMPONENT;

    COMPONENT debouncer IS
        GENERIC ( 
            MIN_DLY_CNT_g : POSITIVE := 100000  -- minimum contiguous periods, GE 2
            );
        PORT ( 
            clk_in    :  IN STD_LOGIC;
            button_in :  IN STD_LOGIC;
            clean_out : OUT STD_LOGIC
            );
    END COMPONENT;

END PACKAGE ET4351_Pkg;
