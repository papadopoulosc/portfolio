LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.ET4351_Pkg.ALL;

ENTITY wb_mbl1c IS
    GENERIC (
        MEMORY_MAP_g : memory_map_type := (X"00000000", X"FFFFFFFF");
        -- The following values should match those used when
        -- creating imem(_init).vhd and dmem4(_init).vhd !!
        IMEM_ABITS_g : POSITIVE := 12;
        DMEM_ABITS_g : POSITIVE := 12
        );
    PORT (
        clk_i     :  IN STD_LOGIC;
        rst_i     :  IN STD_LOGIC;
        int_i     :  IN STD_LOGIC;
        --
        xmem1_i   :  IN dmemb2c_type;
        xmem1_o   : OUT c2dmemb_type;
        --
        mst_wb1_i :  IN wb2mst_type;
        mst_wb1_o : OUT mst2wb_type;
        --
        bri0_o    : OUT STD_LOGIC
        );
END ENTITY wb_mbl1c;


ARCHITECTURE arch_wb_mbl1c OF wb_mbl1c IS

    SIGNAL imem_addr_s : STD_LOGIC_VECTOR (IMEM_ABITS_g -1 DOWNTO 0);
    SIGNAL imem_data_s : STD_LOGIC_VECTOR (31 DOWNTO 0);

    SIGNAL c2dmemb_s   : c2dmemb_type;
    SIGNAL dmemb2c_s   : dmemb2c_type;

    SIGNAL dmemb2x_s   : dmemb2c_array_type (MEMORY_MAP_g'LENGTH -2 DOWNTO 0);
    SIGNAL x2dmemb_s   : c2dmemb_array_type (MEMORY_MAP_g'LENGTH -2 DOWNTO 0);
    
    SIGNAL dlyd_sel_s  : STD_LOGIC_VECTOR (3 DOWNTO 0);

BEGIN

    -- external data ram
    dmemb2x_s(1) <= xmem1_i;
    xmem1_o      <= x2dmemb_s(1);
    
I_IMEM: 
    imem
        GENERIC MAP ( 32, IMEM_ABITS_g )
        PORT MAP (
            adr_i => imem_addr_s (IMEM_ABITS_g -1 DOWNTO 0),
            dat_o => imem_data_s
            );

    dlyd_sel_s <= x2dmemb_s(0).sel WHEN (c2dmemb_s.wre = '1') ELSE (OTHERS => '0');
I_DMEM: 
    dmem4
        GENERIC MAP ( 32, DMEM_ABITS_g )
        PORT MAP (
            clk_i => clk_i,
            ce_i  => x2dmemb_s(0).ena,
            adr_i => x2dmemb_s(0).adr (DMEM_ABITS_g -1 DOWNTO 0),
            wre_i => dlyd_sel_s,
            dat_i => x2dmemb_s(0).dat,
            dat_o => dmemb2x_s(0).dat
            );

I_WB_MBL1C: 
    mbl1c_core
        GENERIC MAP ( IMEM_ABITS_g )
        PORT MAP (
            clk_i       => clk_i,
            rst_i       => rst_i,
            ena_i       => dmemb2c_s.ena,
            int_i       => int_i,
            --
            imem_addr_o => imem_addr_s,
            imem_data_i => imem_data_s,
            --
            dmemb_o     => c2dmemb_s,
            dmemb_i     => dmemb2c_s,
            --
            bri0_o      => bri0_o
            );

I_DECODER:
    address_decoder
        GENERIC MAP ( MEMORY_MAP_g )
        PORT MAP (
            c_dmemb_i => c2dmemb_s,
            c_dmemb_o => dmemb2c_s,
            x_dmemb_i => dmemb2x_s,
            x_dmemb_o => x2dmemb_s
            );
    
I_WB_PORT1:
    mst_wb_adapter
        PORT MAP (
            x_dmemb_i => x2dmemb_s(2),
            x_dmemb_o => dmemb2x_s(2),
            mst_wb_i  => mst_wb1_i,
            mst_wb_o  => mst_wb1_o
            );

END arch_wb_mbl1c;
