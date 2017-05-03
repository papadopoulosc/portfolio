LIBRARY IEEE;
USE IEEE.STD_LOGIC_UNSIGNED.all;
USE IEEE.STD_LOGIC_1164.all;
USE work.ET4351_Pkg.all;
USE work.wb_slave_Pkg.all;


ENTITY wb_soc IS
    GENERIC ( 
        -- sys_ctrl's clock generators
        -- 100Mhz ==> 25 MHz, 50% duty cycle as the AVR- and wb-clock
        MST_DIV_FACTOR_g    : POSITIVE :=      4;
        MST_PERIODS_HIGH_g  : POSITIVE :=      2;
        -- reset debounce 'time constant' value for SYNTHESIS
        MIN_RST_CNT_g       : POSITIVE := 100000;  -- minimum contiguous periods
        -- parameters for mbl1c setup
        MEMORY_MAP_g : memory_map_type := (X"00000000", X"00010000", X"FFFFFFC0", X"FFFFFFFF");
        -- The following values should match those used when
        -- creating imem(_init).vhd and dmem4(_init).vhd !!
        IMEM_ABITS_g        : POSITIVE :=     12;
        DMEM_ABITS_g        : POSITIVE :=     12;
        -- Slave's parameters for SYNTHESIS
        DLY_ACK_TICKS_g     :  NATURAL :=      0;  -- GE 0
        DLY_BUSY_TICKS_g    : POSITIVE :=      1   -- GE 1
        );
    PORT (
        pad_clk_ext   :    IN STD_LOGIC;
        pad_rst_btn   :    IN STD_LOGIC;
        -- external asynchronous data memory
        pad_xram_ce   :   OUT STD_LOGIC;
        pad_xram_addr :   OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        pad_xram_data : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0); 
        pad_xram_wr   :   OUT STD_LOGIC;
        -- 
        pad_done      :   OUT STD_LOGIC
        );
END ENTITY wb_soc;


ARCHITECTURE arch OF wb_soc IS

    COMPONENT sys_ctrl IS
        GENERIC ( 
            MST_DIV_FACTOR_g   : POSITIVE := 4;
            MST_PERIODS_HIGH_g : POSITIVE := 2;
            --
--          SLV_DIV_FACTOR_g   : POSITIVE := 4;
--          SLV_PERIODS_HIGH_g : POSITIVE := 2;
            --
            MIN_RST_CNT_g      : POSITIVE := 100000 -- minimum contiguous periods
            );
        PORT ( 
            clk_ext_i :  IN STD_LOGIC;
            rst_btn_i :  IN STD_LOGIC;
            clk_mst_o : OUT STD_LOGIC;      -- continuous master-clock
--          clk_slv_o : OUT STD_LOGIC;      -- continuous slave-clock
            rst_ext_o : OUT STD_LOGIC       -- debounced reset signal, active high,
                                                -- synchronous with trailing edges of clk_mst!
            );
    END COMPONENT;

    COMPONENT wb_mbl1c IS
        GENERIC (
            MEMORY_MAP_g : memory_map_type := (X"00000000", X"FFFFFFC0", X"FFFFFFFF");
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
    END COMPONENT;

--  Component declarations of Slaves are not needed since they should
--  have been described in their accompanying packages:
--  e.g. COMPONENT wb_slave_LCD defined in wbLCD_Pkg

    SIGNAL clk_mst_s     : STD_LOGIC;
--  SIGNAL clk_slv_s     : STD_LOGIC;
    SIGNAL rst_ext_s     : STD_LOGIC;

    SIGNAL wb_mst_in_s   : wb2mst_type;
    SIGNAL wb_mst_out_s  : mst2wb_type;
    SIGNAL wb_slv_in_s   : wb2slv32b_type;
    SIGNAL wb_slv_out_s  : slv32b2wb_type;

    SIGNAL xram_in_s     : dmemb2c_type;
    SIGNAL xram_out_s    : c2dmemb_type;

BEGIN
 
    pad_xram_ce   <= xram_out_s.ena;
    pad_xram_wr   <= xram_out_s.wre;
    --pad_xram_addr <= xram_out_s.adr (15 DOWNTO 0);
	pad_xram_addr <= xram_out_s.adr (15 DOWNTO 0);
    -- connect the external memory data bus signals to bidirectional pads
    pad_xram_data <= xram_out_s.dat WHEN (xram_out_s.wre = '1') ELSE (OTHERS => 'Z');
    xram_in_s.dat <= pad_xram_data;
    xram_in_s.ena <= '1';
    xram_in_s.int <= '0';
    
    wb_mst_in_s.dat_i <= wb_slv_out_s.dat_o;
    wb_mst_in_s.ack_i <= wb_slv_out_s.ack_o;
    wb_mst_in_s.int_i <= '0';

    wb_slv_in_s.adr_i <= "11" & wb_mst_out_s.adr_o (31 DOWNTO 2);
    wb_slv_in_s.dat_i <= wb_mst_out_s.dat_o;
    wb_slv_in_s.stb_i <= wb_mst_out_s.stb_o;
    wb_slv_in_s.cyc_i <= wb_mst_out_s.cyc_o;
    wb_slv_in_s.we_i  <= wb_mst_out_s.we_o;
    wb_slv_in_s.sel_i <= (OTHERS => '1');       -- no byte selection for this slave
    


--==============================================================================
--  Connect the sys_ctrl component that this design needs ..... 
--==============================================================================
SYSCTRL:  
    sys_ctrl
        GENERIC MAP ( 
            MST_DIV_FACTOR_g, MST_PERIODS_HIGH_g,
--          SLV_DIV_FACTOR_g, SLV_PERIODS_HIGH_g,
            MIN_RST_CNT_g
            )
        PORT MAP (
            clk_ext_i => pad_clk_ext,
            rst_btn_i => pad_rst_btn,
            clk_mst_o => clk_mst_s,
--          clk_slv_o => clk_slv_s,
            rst_ext_o => rst_ext_s
            );

--==============================================================================
--  Connect the wb_master component ..... 
--==============================================================================
WB_MST: 
    wb_mbl1c
          GENERIC MAP ( MEMORY_MAP_g, IMEM_ABITS_g, DMEM_ABITS_g )
          PORT MAP (
              clk_i     => clk_mst_s,
              rst_i     => rst_ext_s,
              int_i     => '0',
              --
              xmem1_i   => xram_in_s,
              xmem1_o   => xram_out_s,
              --
              mst_wb1_i => wb_mst_in_s,
              mst_wb1_o => wb_mst_out_s,
              --
              bri0_o    => pad_done
              );


--==============================================================================
--  Connect slaves now ..... 
--==============================================================================
WB_SLV:
    wb_slave_ex32b
        GENERIC MAP ( 
            DLY_ACK_TICKS_g, DLY_BUSY_TICKS_g
            )
        PORT MAP (
            clk_i      => clk_mst_s,
            rst_i      => rst_ext_s,
            -- wishbone signals
            wb_slv_in  => wb_slv_in_s,
            wb_slv_out => wb_slv_out_s
            );

END ARCHITECTURE arch;
