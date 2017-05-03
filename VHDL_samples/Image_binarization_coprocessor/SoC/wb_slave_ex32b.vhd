LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.std_logic_unsigned.all;
USE work.ET4351_Pkg.all;
USE work.wb_slave_Pkg.all;
USE work.otsu_Pkg.all;

ENTITY wb_slave_ex32b IS
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
END ENTITY wb_slave_ex32b;


ARCHITECTURE arch_wb_slave_ex32b OF wb_slave_ex32b IS

    -- Wishbone bus specific signals
    SIGNAL wb_adr_i  : STD_LOGIC_VECTOR (31 DOWNTO 0);   -- lower address bits
    SIGNAL wb_dat_i  : STD_LOGIC_VECTOR (31 DOWNTO 0);   -- Databus input
    SIGNAL wb_dat_o  : STD_LOGIC_VECTOR (31 DOWNTO 0);   -- Databus output
    SIGNAL wb_we_i   : STD_LOGIC;                        -- Write enable input
    SIGNAL wb_stb_i  : STD_LOGIC;                        -- Strobe signal / core select signal
    SIGNAL wb_cyc_i  : STD_LOGIC;                        -- Valid bus cycle input
    SIGNAL wb_sel_i  : STD_LOGIC_VECTOR ( 3 DOWNTO 0);   -- Select data byte within 32-bit word
    SIGNAL wb_ack_o  : STD_LOGIC;                        -- Acknowledge handshake output

    -- constants and signals concerning this particular slave	
	CONSTANT CTRL_ADDR     : STD_LOGIC_VECTOR ( 4 DOWNTO 0) := "00000";  -- 0x"0"  
    CONSTANT STAT_ADDR     : STD_LOGIC_VECTOR ( 4 DOWNTO 0) := "00001";  -- 0x"1"
   
    CONSTANT REG0_ADDR     : STD_LOGIC_VECTOR ( 4 DOWNTO 0) := "00010";  -- 0x"2"
    CONSTANT REG1_ADDR     : STD_LOGIC_VECTOR ( 4 DOWNTO 0) := "00011";  -- 0x"3"  
    CONSTANT REG2_ADDR     : STD_LOGIC_VECTOR ( 4 DOWNTO 0) := "00100";  -- 0x"4"  
    CONSTANT REG3_ADDR     : STD_LOGIC_VECTOR ( 4 DOWNTO 0) := "00101";  -- 0x"5"  
    CONSTANT REG4_ADDR     : STD_LOGIC_VECTOR ( 4 DOWNTO 0) := "00110";  -- 0x"6"  
	-------------------------------------------------------
	CONSTANT REG5_ADDR     : STD_LOGIC_VECTOR ( 4 DOWNTO 0) := "00111";  -- 0x"7"  
	CONSTANT REG6_ADDR     : STD_LOGIC_VECTOR ( 4 DOWNTO 0) := "01000";  -- 0x"8"  
	CONSTANT REG7_ADDR     : STD_LOGIC_VECTOR ( 4 DOWNTO 0) := "01001";  -- 0x"9"  
	CONSTANT REG8_ADDR     : STD_LOGIC_VECTOR ( 4 DOWNTO 0) := "01010";  -- 0x"10"  
	CONSTANT REG9_ADDR     : STD_LOGIC_VECTOR ( 4 DOWNTO 0) := "01011";  -- 0x"11"  
	CONSTANT REG10_ADDR    : STD_LOGIC_VECTOR ( 4 DOWNTO 0) := "01100";  -- 0x"12"  
	CONSTANT REG11_ADDR    : STD_LOGIC_VECTOR ( 4 DOWNTO 0) := "01101";  -- 0x"13"  
	CONSTANT REG12_ADDR    : STD_LOGIC_VECTOR ( 4 DOWNTO 0) := "01110";  -- 0x"14"  
	CONSTANT REG13_ADDR    : STD_LOGIC_VECTOR ( 4 DOWNTO 0) := "01111";  -- 0x"15"  
	CONSTANT REG14_ADDR    : STD_LOGIC_VECTOR ( 4 DOWNTO 0) := "10000";  -- 0x"16"  
	CONSTANT REG15_ADDR    : STD_LOGIC_VECTOR ( 4 DOWNTO 0) := "10001";  -- 0x"17"  
	CONSTANT Thresh_ADDR   : STD_LOGIC_VECTOR ( 4 DOWNTO 0) := "10010";  -- 0x"18"  
	
    -- CONSTANT LAST_ADDR     : STD_LOGIC_VECTOR ( 2 DOWNTO 0) := "110";  -- 0x"6"  
    CONSTANT LAST_ADDR     : STD_LOGIC_VECTOR ( 4 DOWNTO 0) := "10010";  -- 0x"18"  

    
    SIGNAL Ctrl_r          : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL Stat_r          : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL REG0_r          : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL REG1_r          : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL REG2_r          : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL REG3_r          : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL REG4_r          : STD_LOGIC_VECTOR (31 DOWNTO 0);
	-------------------------------------------------------
    SIGNAL REG5_r          : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL REG6_r          : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL REG7_r          : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL REG8_r          : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL REG9_r          : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL REG10_r          : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL REG11_r          : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL REG12_r          : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL REG13_r          : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL REG14_r          : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL REG15_r          : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL Thresh_r          : STD_LOGIC_VECTOR (31 DOWNTO 0);

    SIGNAL Start_s         : STD_LOGIC;
    SIGNAL Done_s          : STD_LOGIC;

    SIGNAL bus_active_s    : STD_LOGIC;
    --SIGNAL addr_sel_s      : STD_LOGIC_VECTOR ( 2 DOWNTO 0);
    SIGNAL addr_sel_s      : STD_LOGIC_VECTOR ( 4 DOWNTO 0);
    SIGNAL in_addr_range_s : STD_LOGIC;
    SIGNAL thisSlave_s     : STD_LOGIC;
    SIGNAL stb_cnt_r       : INTEGER RANGE 0 TO  DLY_ACK_TICKS_g;
    SIGNAL busy_cnt_r      : INTEGER RANGE 0 TO DLY_BUSY_TICKS_g;
    SIGNAL int_ack_s       : STD_LOGIC;
    SIGNAL irq_s           : STD_LOGIC;

	COMPONENT otsu is
		generic ( NHIST : integer := 16 );
		port ( 	clk        : in  std_logic;	
			en         : in  std_logic;	
			ready	   : out  std_logic;
			hist       : in  vector_array;
			thres      : out std_logic_vector ( 31 downto 0) );
	end COMPONENT;
	
	SIGNAL histogram : vector_array;
	SIGNAL otsu_en : std_logic := '0';
	SIGNAL otsu_ready : std_logic := '0';
	SIGNAL threshold : std_logic_vector(31 downto 0) := (OTHERS => '0');
	
BEGIN

    wb_adr_i <= wb_slv_in.adr_i;
    wb_dat_i <= wb_slv_in.dat_i;
    wb_we_i  <= wb_slv_in.we_i;
    wb_stb_i <= wb_slv_in.stb_i;
    wb_cyc_i <= wb_slv_in.cyc_i;
    wb_sel_i <= wb_slv_in.sel_i;    -- not effective in this slave

    bus_active_s    <= wb_cyc_i AND wb_stb_i;
    addr_sel_s      <= wb_adr_i(4 DOWNTO 0);
    in_addr_range_s <= '1' WHEN (addr_sel_s <= LAST_ADDR) ELSE '0';
    thisSlave_s     <= bus_active_s AND in_addr_range_s;

    Start_s   <= Ctrl_r(0);
    -- this example slave needs DLY_BUSY_TICKS_g clock cycles before it raises Done_s
    Done_s    <= '1' WHEN (busy_cnt_r = DLY_BUSY_TICKS_g) ELSE '0';
    Stat_r(0) <= irq_s;

--  --============ read from slave, i.e. write to WB ==============================
    wb_dat_o <= REG0_r WHEN (addr_sel_s = REG0_ADDR) ELSE
                REG1_r WHEN (addr_sel_s = REG1_ADDR) ELSE
                REG2_r WHEN (addr_sel_s = REG2_ADDR) ELSE
                REG3_r WHEN (addr_sel_s = REG3_ADDR) ELSE
                REG4_r WHEN (addr_sel_s = REG4_ADDR) ELSE
                REG5_r WHEN (addr_sel_s = REG5_ADDR) ELSE
                REG6_r WHEN (addr_sel_s = REG6_ADDR) ELSE
                REG7_r WHEN (addr_sel_s = REG7_ADDR) ELSE
                REG8_r WHEN (addr_sel_s = REG8_ADDR) ELSE
                REG9_r WHEN (addr_sel_s = REG9_ADDR) ELSE
                REG10_r WHEN (addr_sel_s = REG10_ADDR) ELSE
                REG11_r WHEN (addr_sel_s = REG11_ADDR) ELSE
                REG12_r WHEN (addr_sel_s = REG12_ADDR) ELSE
                REG13_r WHEN (addr_sel_s = REG13_ADDR) ELSE
                REG14_r WHEN (addr_sel_s = REG14_ADDR) ELSE
                REG15_r WHEN (addr_sel_s = REG15_ADDR) ELSE
                Thresh_r WHEN (addr_sel_s = Thresh_ADDR) ELSE
                Stat_r WHEN (addr_sel_s = STAT_ADDR) ELSE
                (OTHERS => '0');
--  --============ end of read from slave, i.e. write to WB =======================

    -- generate ack_o depending on DLY_ACK_TICKS_g
    int_ack_s <= '1' WHEN (stb_cnt_r = DLY_ACK_TICKS_g) ELSE '0';  
    wb_ack_o  <= int_ack_s AND wb_stb_i;
    wb_slv_out.ack_o <= wb_ack_o;
    -- data out put on bus as long as ack_o is high
    wb_slv_out.dat_o <= wb_dat_o WHEN ((wb_ack_o AND NOT(wb_we_i)) = '1') ELSE (OTHERS => 'Z');
    wb_slv_out.int_o <= irq_s;      -- reflected in Stat_r(0);

gen_irq:
    PROCESS( Start_s, Done_s )
    BEGIN
        IF Start_s = '0' THEN
            irq_s <= '0';
        ELSIF RISING_EDGE( Done_s ) THEN
            irq_s <= '1';
        END IF;
    END PROCESS gen_irq;

	histogram(0) <= REG0_r;
	histogram(1) <= REG1_r;
	histogram(2) <= REG2_r;
	histogram(3) <= REG3_r;
	histogram(4) <= REG4_r;
	histogram(5) <= REG5_r;
	histogram(6) <= REG6_r;
	histogram(7) <= REG7_r;
	histogram(8) <= REG8_r;
	histogram(9) <= REG9_r;
	histogram(10) <= REG10_r;
	histogram(11) <= REG11_r;
	histogram(12) <= REG12_r;
	histogram(13) <= REG13_r;
	histogram(14) <= REG14_r;
	histogram(15) <= REG15_r;
	
	otsu_cmp : otsu generic map ( 16 )
			port map(clk=> clk_i,
				en=> Ctrl_r(2),
				ready=> otsu_ready,
				hist=> histogram,
				thres=> Thresh_r);
	
	
main:
    PROCESS ( clk_i, rst_i, stb_cnt_r, Ctrl_r )

        PROCEDURE clear_all_regs_proc IS
        BEGIN
            REG0_r       <= (OTHERS => '0');
            REG1_r       <= (OTHERS => '0');
            REG2_r       <= (OTHERS => '0');
            REG3_r       <= (OTHERS => '0');
            REG4_r       <= (OTHERS => '0');
            REG5_r       <= (OTHERS => '0');
            REG6_r       <= (OTHERS => '0');
            REG7_r       <= (OTHERS => '0');
            REG8_r       <= (OTHERS => '0');
            REG9_r       <= (OTHERS => '0');
            REG10_r       <= (OTHERS => '0');
            REG11_r       <= (OTHERS => '0');
            REG12_r       <= (OTHERS => '0');
            REG13_r       <= (OTHERS => '0');
            REG14_r       <= (OTHERS => '0');
            REG15_r       <= (OTHERS => '0');
	    Ctrl_r <= (OTHERS => '0');
            stb_cnt_r    <=  0;
            busy_cnt_r   <=  0;
            Stat_r (31 DOWNTO 1) <= (OTHERS => '0');
        END PROCEDURE clear_all_regs_proc;
    
    BEGIN
        IF RISING_EDGE( clk_i ) THEN
            IF ( rst_i = '1' ) THEN
                clear_all_regs_proc;
            ELSE
                IF ( Ctrl_r(1) = '1' ) THEN     -- software reset 
                    clear_all_regs_proc;        
                    Ctrl_r(1) <= '0';           -- also clear the sw_rst bit itself
                END IF;
		if (Ctrl_r(2) = '1') then
			Ctrl_r(2) <= '0';
		end if;
		
		Stat_r(1) <= otsu_ready;		
			
                IF ( (Start_s AND NOT(irq_s)) = '1' ) THEN
                    busy_cnt_r <= busy_cnt_r + 1; 
                ELSE
                    busy_cnt_r <= 0;
                END IF;
				
				
                IF ( thisSlave_s = '1' ) THEN
                    IF ( stb_cnt_r = DLY_ACK_TICKS_g ) THEN
                        stb_cnt_r <= 0;
                    ELSE
                        stb_cnt_r <= stb_cnt_r + 1;
                    END IF;
                    IF ( (wb_we_i AND wb_ack_o) = '1' ) THEN
    --============ write to slave, i.e. read from WB ==============================
                        IF    (addr_sel_s = REG0_ADDR) THEN REG0_r <= wb_dat_i;
                        ELSIF (addr_sel_s = REG1_ADDR) THEN REG1_r <= wb_dat_i;
                        ELSIF (addr_sel_s = REG2_ADDR) THEN REG2_r <= wb_dat_i;
                        ELSIF (addr_sel_s = REG3_ADDR) THEN REG3_r <= wb_dat_i;
                        ELSIF (addr_sel_s = REG4_ADDR) THEN REG4_r <= wb_dat_i;
                        ELSIF (addr_sel_s = REG5_ADDR) THEN REG5_r <= wb_dat_i;
                        ELSIF (addr_sel_s = REG6_ADDR) THEN REG6_r <= wb_dat_i;
                        ELSIF (addr_sel_s = REG7_ADDR) THEN REG7_r <= wb_dat_i;
                        ELSIF (addr_sel_s = REG8_ADDR) THEN REG8_r <= wb_dat_i;
                        ELSIF (addr_sel_s = REG9_ADDR) THEN REG9_r <= wb_dat_i;
                        ELSIF (addr_sel_s = REG10_ADDR) THEN REG10_r <= wb_dat_i;
                        ELSIF (addr_sel_s = REG11_ADDR) THEN REG11_r <= wb_dat_i;
                        ELSIF (addr_sel_s = REG12_ADDR) THEN REG12_r <= wb_dat_i;
                        ELSIF (addr_sel_s = REG13_ADDR) THEN REG13_r <= wb_dat_i;
                        ELSIF (addr_sel_s = REG14_ADDR) THEN REG14_r <= wb_dat_i;
                        ELSIF (addr_sel_s = REG15_ADDR) THEN REG15_r <= wb_dat_i;
                        ELSIF (addr_sel_s = CTRL_ADDR) THEN Ctrl_r <= wb_dat_i;
                        END IF;
    --============ end of write to slave, i.e. read from WB =======================
                    END IF;   -- wb_we_i = '1'
                ELSE
                    stb_cnt_r <= 0;
                END IF;     -- thisSlave_s = '1'
            END IF;         -- rst_i
        END IF;             -- RISING_EDGE( clk_i )
    END PROCESS; 

END ARCHITECTURE arch_wb_slave_ex32b;
