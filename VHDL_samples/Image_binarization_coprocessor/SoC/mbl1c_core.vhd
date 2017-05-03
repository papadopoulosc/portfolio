---------------------------------------------------------------------------------
--
--  Entity:      mbl1c_core
--  Filename:    mbl1c_core.vhd
--  Description: MB-Lite emulator, one cycle for each instruction
--  Author:      Huib Lincklaen Arriens
--  Date:        May, 2010
--  Modified:    
--  Remarks:     
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.std_logic_arith.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;
USE IEEE.NUMERIC_STD.ALL;
USE work.ET4351_Pkg.all;

 
----------------------------------------------------------
ENTITY mbl1c_core IS 
----------------------------------------------------------
    GENERIC (
    -- The following value should match that used when
    -- creating imem(_init).vhd !!
        IMEM_ABITS_g : POSITIVE := 12
        );
    PORT (
        clk_i       :  IN STD_LOGIC;
        rst_i       :  IN STD_LOGIC;
        ena_i       :  IN STD_LOGIC;
        int_i       :  IN STD_LOGIC;
        --
        imem_addr_o : OUT STD_LOGIC_VECTOR (IMEM_ABITS_g -1 DOWNTO 0);      -- BYTE addresses
        imem_data_i :  IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        --
        dmemb_o     : OUT c2dmemb_type;     -- towards data memory
        dmemb_i     :  IN dmemb2c_type;     -- from data memory
        --
        bri0_o      : OUT STD_LOGIC
        );
END ENTITY mbl1c_core;


----------------------------------------------------------
ARCHITECTURE rtl OF mbl1c_core IS
---------------------------------------------------------- 

    TYPE dSizeType IS ( BYTE, HALFWORD, WORD );
    TYPE signType  IS ( UNSGND, SGND );
        
    TYPE opcType IS ( 
        I_ADD,  I_RSUB,  I_ADDC,  I_RSUBC,  I_ADDK,  I_CMP,    I_ADDKC,  I_RSUBKC,
        I_ADDI, I_RSUBI, I_ADDIC, I_RSUBIC, I_ADDIK, I_RSUBIK, I_ADDIKC, I_RSUBIKC,
        I_MUL,  I_BS,    I_IDIV,  I_FSL,    I_RES00, I_RES01,  I_RES02,  I_RES03,
        I_MULI, I_BSI,   I_RES04, I_RES05,  I_RES06, I_RES07,  I_RES08,  I_RES09,
        I_OR,   I_AND,   I_XOR,   I_ANDN,   I_SEXT,  I_MFS,    I_BR,     I_BRNC, 
        I_ORI,  I_ANDI,  I_XORI,  I_ANDNI,  I_IMM,   I_RTBD,   I_BRI,    I_BRNI,
        I_LBU,  I_LHU,   I_LW,    I_RES10,  I_SB,    I_SH,     I_SW,     I_RES11,
        I_LBUI, I_LHUI,  I_LWI,   I_RES12,  I_SBI,   I_SHI,    I_SWI,    I_RES13   ); 

    TYPE aluActionType IS (
        A_ADD, A_CMP, A_CMPU, A_OR, A_AND, A_XOR, A_SHIFT, A_SEXT8, A_SEXT16, A_NOP );
    TYPE msrActionType IS ( KEEP_CARRY, UPDATE_CARRY );
    TYPE memActionType IS ( NO_MEM, RD_MEM, WR_MEM );
     
    TYPE gprfType IS ARRAY (INTEGER RANGE 31 DOWNTO 0) OF STD_LOGIC_VECTOR (31 DOWNTO 0);
    
    TYPE regType IS RECORD
        sync_rst0       : STD_LOGIC;
        sync_rst1       : STD_LOGIC;
        gprf_Ra         : gprfType;
        gprf_Rb         : gprfType;
        gprf_Rd         : gprfType;
        program_counter : STD_LOGIC_VECTOR (31 DOWNTO 0);   -- points to byte-addresses
        imm_Locked      : STD_LOGIC;
        Imm             : STD_LOGIC_VECTOR (15 DOWNTO 0);
        MSR_C           : STD_LOGIC;
        branch_target   : STD_LOGIC_VECTOR (31 DOWNTO 0);
        delayBit        : STD_LOGIC;
        do_branch       : STD_LOGIC;
        msr_int_enable  : STD_LOGIC;
        do_irq          : STD_LOGIC;
    END RECORD;

    SIGNAL dmemb_adr_s  : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL noLiteOpc_s  : STD_LOGIC;

    SIGNAL q_r : regType;
    SIGNAL d_s : regType;

    
BEGIN

    dmemb_o.adr <= dmemb_adr_s;
    -- signal <_exit>-code reached
    bri0_o <= '1' WHEN (imem_data_i = x"B8000000") ELSE '0';
        
comb_proc:
    PROCESS ( rst_i, q_r, imem_data_i, dmemb_i.dat, dmemb_adr_s, int_i )
        
        VARIABLE d_v           : regType;
        VARIABLE opCode_v      : opcType;
        VARIABLE opcIx_v       : STD_LOGIC_VECTOR ( 5 DOWNTO 0);
        VARIABLE instruction_v : STD_LOGIC_VECTOR (31 DOWNTO 0);
        VARIABLE Rd_v          : STD_LOGIC_VECTOR ( 4 DOWNTO 0);
        VARIABLE Ra_v          : STD_LOGIC_VECTOR ( 4 DOWNTO 0);
        VARIABLE Rb_v          : STD_LOGIC_VECTOR ( 4 DOWNTO 0);
        VARIABLE ixRd_v        : INTEGER RANGE 31 DOWNTO 0;
        VARIABLE ixRa_v        : INTEGER RANGE 31 DOWNTO 0;
        VARIABLE ixRb_v        : INTEGER RANGE 31 DOWNTO 0;
        VARIABLE code_x26_v    : STD_LOGIC_VECTOR ( 2 DOWNTO 0);
        VARIABLE Imm_v         : STD_LOGIC_VECTOR (15 DOWNTO 0);
        VARIABLE Imm_Sext16_v  : STD_LOGIC_VECTOR (31 DOWNTO 0);
        VARIABLE Imm32_v       : STD_LOGIC_VECTOR (31 DOWNTO 0);
        VARIABLE get_br_addr_v : STD_LOGIC;

        VARIABLE alu_Op1_v     : STD_LOGIC_VECTOR (31 DOWNTO 0);
        VARIABLE alu_Op2_v     : STD_LOGIC_VECTOR (31 DOWNTO 0);
        VARIABLE alu_Carry_I_v : STD_LOGIC;
        VARIABLE alu_Action_v  : aluActionType;
        VARIABLE alu_Out_v     : STD_LOGIC_VECTOR (31 DOWNTO 0);
        VARIABLE alu_Carry_O_v : STD_LOGIC;

        VARIABLE tmp_Rd_v      : STD_LOGIC_VECTOR (31 DOWNTO 0);
        VARIABLE msr_Action_v  : msrActionType;
        VARIABLE mem_Action_v  : memActionType;

        VARIABLE isZero_v      : STD_LOGIC;
        VARIABLE signBit_v     : STD_LOGIC;                      
        VARIABLE dSize_v       : dSizeType;
        VARIABLE set_int_rtn   : STD_LOGIC;
                           
                           
        ----------------- -------------------------------------------------------
        PROCEDURE decode IS
        BEGIN
            instruction_v := imem_data_i;
            opcIx_v       := instruction_v (31 DOWNTO 26);
            -- next variable only for opcode (base mnemonic) display 
--          opCode_v      := opcType'VAL(TO_INTEGER(UNSIGNED(opcIx_v)));
            Rd_v          := instruction_v (25 DOWNTO 21);
            Ra_v          := instruction_v (20 DOWNTO 16);
            Rb_v          := instruction_v (15 DOWNTO 11);
            ixRd_v        := TO_INTEGER(UNSIGNED(Rd_v));
            ixRa_v        := TO_INTEGER(UNSIGNED(Ra_v));
            ixRb_v        := TO_INTEGER(UNSIGNED(Rb_v));
            Imm_v         := instruction_v (15 DOWNTO  0);
            get_br_addr_v := '0';
            alu_Carry_I_v := '0'; 
            alu_Action_v  := A_NOP;
            msr_Action_v  := KEEP_CARRY;
            mem_Action_v  := NO_MEM;
            dSize_v       := WORD;
            -- for decoding SEXT16, SEXT8, SRC, SRC or SRL
            code_x26_v    := instruction_v(6) & instruction_v(5) & instruction_v(0);
            
            IF (Imm_v(15) = '0') THEN
                Imm_Sext16_v := x"0000" & Imm_v;
            ELSE
                Imm_Sext16_v := x"FFFF" & Imm_v;
            END IF;

            IF (d_v.imm_Locked = '1') THEN
                Imm32_v := q_r.Imm & Imm_v;
            ELSE
                Imm32_v := Imm_Sext16_v;
            END IF;

            tmp_Rd_v  := d_v.gprf_Rd(ixRd_v);
            alu_Op1_v := q_r.gprf_Ra(ixRa_v);
            IF (opcIx_v(3) = '0') THEN
                alu_Op2_v := q_r.gprf_Rb(ixRb_v);
            ELSE
                alu_Op2_v := Imm32_v;
            END IF;
         
            isZero_v       := '0';
            signBit_v      := '0';
            d_v.delayBit   := '0';
            d_v.imm_Locked := '0';
            noLiteOpc_s    <= '0';

            CASE opcIx_v (5 DOWNTO 4) IS

                WHEN "00" =>                                            -- ADD / RSUB / CMP
                    IF (opcIx_v(0) = '1') THEN                          -- RSUB / CMP
                        alu_Op1_v  := NOT alu_Op1_v;
                    END IF;
                    IF (opcIx_v(1) = '0') THEN                          -- xxx
                        alu_Carry_I_v := opcIx_v(0);
                    ELSE                                                -- xxxC
                        alu_Carry_I_v := q_r.MSR_C;
                    END IF;
                    IF ((opcIx_v(3 DOWNTO 0) = "0101") AND (Imm_v(0)= '1')) THEN
                    -- special CMP(U) and not RSUB(I)K
                        IF (Imm_v(1) = '1') THEN                        -- U-bit set, CMPU
                            alu_Action_v := A_CMPU;
                        ELSE
                            alu_Action_v := A_CMP;
                        END IF;
                    ELSE
                        alu_Action_v := A_ADD;
                        IF (opcIx_v(2) = '0') THEN
                            msr_Action_v := UPDATE_CARRY;
                        END IF;
                    END IF;

                WHEN "01" =>                                            -- MUL / BS / FSL
                    noLiteOpc_s <= '1';

                WHEN "10" =>
                    IF (opcIx_v (3 DOWNTO 0) = "0100") THEN 
                        CASE code_x26_v IS
                            WHEN "001" | "011" | "101" =>
                                CASE code_x26_v(2 DOWNTO 1) IS
                                    WHEN "00" =>                        -- SRA
                                        alu_Carry_I_v := alu_Op1_v(31);
                                    WHEN "01" =>                        -- SRC
                                        alu_Carry_I_v := q_r.MSR_C;
                                    WHEN "10" =>                        -- SRL
                                        alu_Carry_I_v := '0';
                                    WHEN OTHERS => NULL;
                                END CASE;
                                alu_Action_v := A_SHIFT;
                                msr_Action_v := UPDATE_CARRY;
                                
                            WHEN "110" =>                               -- SEXT8
                                alu_Action_v := A_SEXT8;
                            WHEN "111" =>                               -- SEXT16
                                alu_Action_v := A_SEXT16;
                            WHEN OTHERS  => 
                                    NULL;
                        END CASE;
                    ELSIF (opcIx_v (3 DOWNTO 0) = "1100") THEN          -- IMM
                        d_v.Imm        := Imm_v;
                        d_v.imm_Locked := '1';
                    ELSIF (opcIx_v (3 DOWNTO 0) = "1101") THEN 
                        CASE Rd_v IS
                            WHEN "10010" =>                             -- RTBD
                            WHEN "10001" =>                             -- RTID
                                d_v.msr_int_enable  := '1';
                            WHEN "10100" =>                             -- RTED
                            WHEN "10000" =>                             -- RTSD
                            WHEN OTHERS  =>
                        END CASE;
                        alu_Op2_v     := Imm_Sext16_v;
                        alu_Action_v  := A_ADD;
                        get_br_addr_v := '1';
                        d_v.do_branch := '1';
                        d_v.delayBit  := '1';
                    ELSE
                        CASE opcIx_v (2 DOWNTO 0) IS
                            WHEN "000" => 
                                alu_Action_v := A_OR;
                            WHEN "001" => 
                                alu_Action_v := A_AND;
                            WHEN "010" => 
                                alu_Action_v := A_XOR;
                            WHEN "011" => 
                                alu_Op2_v := NOT alu_Op2_v;
                                alu_Action_v := A_AND;
                            WHEN "110" => 
                                IF (Ra_v(2) = '1') THEN
                                    tmp_Rd_v  := d_v.program_counter;
                                END IF;
                                IF (Ra_v(3) = '1') THEN
                                    alu_Op1_v := (OTHERS => '0');
                                ELSE
                                    alu_Op1_v := d_v.program_counter;
                                END IF;
                                IF (Ra_v(4) = '1') THEN
                                    d_v.delayBit := '1';
                                END IF;
                                alu_Action_v  := A_ADD;
                                get_br_addr_v := '1';
                                d_v.do_branch := '1';
                            WHEN "111" =>
                                signBit_v     := alu_Op1_v(31);
                                IF (alu_Op1_v = C_32_ZEROS) THEN
                                    isZero_v := '1';
                                END IF;
                                CASE Rd_v(3 DOWNTO 0) IS
                                    WHEN "0000" =>                          -- BEQI
                                        d_v.do_branch := isZero_v;
                                    WHEN "0001" =>                          -- BNEI
                                        d_v.do_branch := NOT isZero_v;
                                    WHEN "0010" =>                          -- BLTI
                                        d_v.do_branch := signBit_v;
                                    WHEN "0011" =>                          -- BLEI
                                        d_v.do_branch := signBit_v OR isZero_v;
                                    WHEN "0100" =>                          -- BGTI
                                        d_v.do_branch := NOT (signBit_v OR isZero_v);
                                    WHEN "0101" =>                          -- BGEI
                                        d_v.do_branch := NOT signBit_v;
                                    WHEN OTHERS => NULL; 
                                END CASE;
                                IF (d_v.do_branch = '1') THEN
                                    alu_Op1_v     := d_v.program_counter;
                                    alu_Action_v  := A_ADD;
                                    get_br_addr_v := '1';
                                END IF;
                                d_v.delayBit := Rd_v(4);
                            WHEN OTHERS =>
                                NULL;
                        END CASE;
                    END IF;

                WHEN "11" =>
                    alu_Action_v :=  A_ADD;
                    CASE opcIx_v (1 DOWNTO 0) IS
                        WHEN "00"   => dSize_v := BYTE;
                        WHEN "01"   => dSize_v := HALFWORD;
                        WHEN "10"   => dSize_v := WORD;
                        WHEN OTHERS => noLiteOpc_s <= '1';
                    END CASE;
                    IF (opcIx_v(2) = '0') THEN
                        mem_Action_v := RD_MEM;
                    ELSE
                        mem_Action_v := WR_MEM;
                    END IF;

                WHEN OTHERS => NULL;

            END CASE;

        END PROCEDURE decode;

        ----------------- -------------------------------------------------------

        PROCEDURE exeq IS
            
            --------------------------------------------------------------------
            PROCEDURE ALU ( in1      :  IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                            in2      :  IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                            carry_i  :  IN STD_LOGIC;
                            action   :  IN aluActionType;
                            result   : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                            carry_o  : OUT STD_LOGIC  ) IS
                VARIABLE tmp      : STD_LOGIC_VECTOR (33 DOWNTO 0);
                VARIABLE tmp_24_v : STD_LOGIC_VECTOR (23 DOWNTO 0);
                VARIABLE tmp_16_v : STD_LOGIC_VECTOR (15 DOWNTO 0);                     
            BEGIN
                carry_o := '0';
                CASE action IS 
                    WHEN A_ADD | A_CMP | A_CMPU =>
                        tmp     := STD_LOGIC_VECTOR( UNSIGNED( '0' & in1 & '1' ) 
                                                        + UNSIGNED( '0' & in2 & carry_i ) );
                        result  := tmp(32 DOWNTO 1);
                        carry_o := tmp(33);
                        IF (action = A_CMPU) THEN
                            IF (in1(31) = in2(31)) THEN
                                result(31) := NOT in1(31);
                            END IF; 
                        ELSIF (action = A_CMP) THEN
                            IF (in1(31) = in2(31)) THEN
                                result(31) := in1(31);
                            END IF; 
                        END IF; 
                    WHEN A_OR     => 
                        result  := in1  OR in2;
                    WHEN A_AND    => 
                        result  := in1 AND in2;
                    WHEN A_XOR    => 
                        result  := in1 XOR in2;
                    WHEN A_SEXT8  =>
                        IF (in1(7) = '0') THEN
                            tmp_24_v := C_24_ZEROS;
                        ELSE
                            tmp_24_v := C_24_ONES;
                        END IF;
                        result  := tmp_24_v & in1( 7 DOWNTO 0);
                    WHEN A_SEXT16 =>
                        IF (in1(15) = '0') THEN
                            tmp_16_v := C_16_ZEROS;
                        ELSE
                            tmp_16_v := C_16_ONES;
                        END IF;
                        result  := tmp_16_v & in1(15 DOWNTO 0);
                    WHEN A_SHIFT  =>
                        result  := carry_i & in1(31 DOWNTO 1);
                        carry_o := in1(0);
                    WHEN OTHERS   => NULL;
                END CASE;
                
            END PROCEDURE ALU;
            --------------------------------------------------------------------
            PROCEDURE WR_DMEM ( dSize   : dSizeType; 
                                address : STD_LOGIC_VECTOR (31 DOWNTO 0);
                                data    : STD_LOGIC_VECTOR (31 DOWNTO 0) ) IS
            BEGIN
                dmemb_adr_s <= address;
                CASE dSize IS
                    WHEN BYTE     =>
                        CASE address(1 DOWNTO 0) IS
                            WHEN "00"   => 
                                dmemb_o.sel <= "1000";
                                dmemb_o.dat <= data( 7 DOWNTO 0) & C_24_ZEROS;
                            WHEN "01"   => 
                                dmemb_o.sel <= "0100";
                                dmemb_o.dat <=  C_8_ZEROS & data( 7 DOWNTO 0) & C_16_ZEROS;
                            WHEN "10"   => 
                                dmemb_o.sel <= "0010";
                                dmemb_o.dat <= C_16_ZEROS & data( 7 DOWNTO 0) &  C_8_ZEROS;
                            WHEN "11"   => 
                                dmemb_o.sel <= "0001";
                                dmemb_o.dat <= C_24_ZEROS & data( 7 DOWNTO 0);
                            WHEN OTHERS => NULL;
                        END CASE;
                    WHEN HALFWORD => 
                        CASE address(1) IS
                            WHEN '0'    => 
                                dmemb_o.sel <= "1100";
                                dmemb_o.dat <= data(15 DOWNTO 0) & C_16_ZEROS;
                            WHEN '1'    => 
                                dmemb_o.sel <= "0011";
                                dmemb_o.dat <= C_16_ZEROS & data(15 DOWNTO 0);
                            WHEN OTHERS => NULL;
                        END CASE;
                    WHEN OTHERS   =>
                        dmemb_o.dat <= data;
                        dmemb_o.sel <= "1111";
                END CASE;
                dmemb_o.wre <= '1';
                dmemb_o.ena <= '1';
            END PROCEDURE WR_DMEM;
            --------------------------------------------------------------------
            IMPURE FUNCTION RD_DMEM  ( dSize   : dSizeType; 
                                       address : STD_LOGIC_VECTOR (31 DOWNTO 0) ) 
                        RETURN STD_LOGIC_VECTOR IS
            BEGIN
                dmemb_adr_s <= address;
                dmemb_o.ena <= '1';
                CASE dSize IS
                    WHEN BYTE     =>
                        CASE address(1 DOWNTO 0) IS
                            WHEN "00"   => RETURN C_24_ZEROS & dmemb_i.dat(31 DOWNTO 24);
                            WHEN "01"   => RETURN C_24_ZEROS & dmemb_i.dat(23 DOWNTO 16);
                            WHEN "10"   => RETURN C_24_ZEROS & dmemb_i.dat(15 DOWNTO  8);
                            WHEN "11"   => RETURN C_24_ZEROS & dmemb_i.dat( 7 DOWNTO  0);
                            WHEN OTHERS => RETURN C_32_ZEROS;
                        END CASE;
                    WHEN HALFWORD => 
                        CASE address(1 DOWNTO 0) IS
                            WHEN "00"   => RETURN C_16_ZEROS & dmemb_i.dat(31 DOWNTO 16);
                            WHEN "10"   => RETURN C_16_ZEROS & dmemb_i.dat(15 DOWNTO  0);
                            WHEN OTHERS => RETURN C_32_ZEROS;
                        END CASE;
                    WHEN OTHERS   =>       RETURN dmemb_i.dat;
                END CASE;
            END FUNCTION RD_DMEM;
            --------------------------------------------------------------------
            
        BEGIN

            ALU ( alu_Op1_v, alu_Op2_v, alu_Carry_I_v, alu_Action_v, alu_Out_v, alu_Carry_O_v );

            IF (get_br_addr_v = '1') THEN
                d_v.branch_target := alu_Out_v;
            ELSIF (mem_Action_v = RD_MEM) THEN
                tmp_Rd_v := RD_DMEM ( dSize_v, alu_Out_v );
            ELSIF (mem_Action_v = WR_MEM) THEN
                WR_DMEM ( dSize_v, alu_Out_v, tmp_Rd_v );
            ELSIF (alu_Action_v /= A_NOP) THEN
                tmp_Rd_v := alu_Out_v;
            END IF;
            IF (msr_Action_v = UPDATE_CARRY) THEN
                d_v.MSR_C := alu_Carry_O_v;
            END IF;

        END PROCEDURE exeq;

        ------------------------------------------------------------------------
    
    BEGIN
        -- copy current registered values into variable d_v
        d_v := q_r;
        
        dmemb_adr_s <= (OTHERS => '0');
        dmemb_o.dat <= (OTHERS => '0');
        dmemb_o.sel <= "0000";
        dmemb_o.ena <= '1';
        dmemb_o.wre <= '0';

        set_int_rtn := '0';
        ixRd_v      :=  0 ;
        tmp_Rd_v    := (OTHERS => '0');
        IF ((q_r.sync_rst0 = '0') AND (q_r.sync_rst1 = '0')) THEN
            IF ((q_r.delayBit = '1') OR (q_r.imm_Locked = '1')) THEN
                d_v.program_counter := q_r.program_counter + 4;
            ELSE
                IF (q_r.do_branch = '1') THEN
                    d_v.program_counter := d_v.branch_target;
                    d_v.do_branch := '0';
                ELSE
                    d_v.program_counter := q_r.program_counter + 4;
                END IF;
                IF ((q_r.do_irq = '1') AND (q_r.msr_int_enable = '1')) THEN
                    ixRd_v              := 14;
                    tmp_Rd_v            := d_v.program_counter;
                    d_v.program_counter := x"00000010";
                    d_v.msr_int_enable  := '0';
                    set_int_rtn         := '1';
                END IF;
            END IF;
        END IF;
                    
        imem_addr_o  <= d_v.program_counter(IMEM_ABITS_g -1 DOWNTO 0);

        IF (set_int_rtn = '0') THEN
            decode;
            exeq;
        END IF;
        -- writeback
        d_v.gprf_Rd(ixRd_v) := tmp_Rd_v;
        d_v.gprf_Ra(ixRd_v) := tmp_Rd_v;
        d_v.gprf_Rb(ixRd_v) := tmp_Rd_v;
        set_int_rtn := '0';

        d_v.do_irq := int_i;

        -- override the above in case of a reset
        IF (rst_i = '1') THEN
            d_v.sync_rst1       := q_r.sync_rst0;
            d_v.sync_rst0       := '1';
            d_v.program_counter := (OTHERS => '0');
-- DIT MOET ALLEEN BIJ INIT
clear_gprf: FOR i IN 0 TO 31 LOOP
                d_v.gprf_Ra (i) := (OTHERS => '0');
                d_v.gprf_Rb (i) := (OTHERS => '0');
                d_v.gprf_Rd (i) := (OTHERS => '0');
            END LOOP;
            d_v.imm_Locked      := '0';
            d_v.Imm             := (OTHERS => '0');
            d_v.MSR_C           := '0';
            d_v.branch_target   := (OTHERS => '0');
            d_v.delayBit        := '0';
            d_v.do_branch       := '0';
            d_v.msr_int_enable  := '1';     -- MB-Lite different from MicroBlaze
        ELSE
            d_v.sync_rst1       := q_r.sync_rst0;
            d_v.sync_rst0       := '0';
        END IF; 

        -- copy new variables in d_v into signal d_s for transferring 
        -- to the 'register' process
        d_s <= d_v;
        
        
    END PROCESS comb_proc;
    
regd_proc:
    PROCESS (clk_i )
    BEGIN
        IF RISING_EDGE( clk_i ) THEN
            IF (ena_i = '1') THEN 
                -- now create registers and flip-flops for all variables in d_s
                q_r <= d_s;
            END IF;
        END IF;
    END PROCESS regd_proc;
    
END ARCHITECTURE rtl;



