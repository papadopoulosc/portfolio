------------------------------------------------------------------------------------
--
-- Entity:      address_decoder
-- File:        address_decoder.vhd
-- Author:      Tamar Kranenburg, Huib Lincklaen Arriens
-- Description: Divides data memory bus and control signals according to
--              specified MEMORY_MAP_g.
-- Date:        May, 2010
-- Modified:    
-- Remarks:		
--
------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE work.ET4351_Pkg.all;


----------------------------------------------------------
ENTITY address_decoder IS
----------------------------------------------------------
    GENERIC (
        MEMORY_MAP_g : memory_map_type := (X"00000000", X"FFFFFFFF")
        );
    PORT (
        c_dmemb_i :  IN c2dmemb_type;
        c_dmemb_o : OUT dmemb2c_type;
		x_dmemb_i :  IN dmemb2c_array_type (MEMORY_MAP_g'LENGTH -2 DOWNTO 0);
		x_dmemb_o : OUT c2dmemb_array_type (MEMORY_MAP_g'LENGTH -2 DOWNTO 0)
        );
END ENTITY address_decoder;


----------------------------------------------------------
ARCHITECTURE rtl OF address_decoder IS
----------------------------------------------------------

    FUNCTION demux (xmemb_i : dmemb2c_array_type; ce_s : STD_LOGIC_VECTOR)
    													      RETURN dmemb2c_type IS
        VARIABLE dmemb_o : dmemb2c_type;
        VARIABLE ce_flag : BOOLEAN := FALSE;
    BEGIN
        FOR i IN MEMORY_MAP_g'LENGTH -2 DOWNTO 1 LOOP
            IF (ce_s(i) = '1') THEN			-- only one ce_s(i) can be '1' at a time
                dmemb_o.dat := xmemb_i(i).dat;
                dmemb_o.ena := xmemb_i(i).ena;
                dmemb_o.int := xmemb_i(i).int;
                ce_flag     := TRUE;
            END IF;
        END LOOP;
        IF (ce_flag = FALSE) THEN
            dmemb_o.dat := xmemb_i(0).dat;
            dmemb_o.ena := '1';
            dmemb_o.int := '0';
        END IF;
        RETURN dmemb_o;
    END FUNCTION;

    SIGNAL ce_s     : STD_LOGIC_VECTOR(MEMORY_MAP_g'LENGTH -2 DOWNTO 0);

BEGIN

get_index:
	FOR i IN MEMORY_MAP_g'LENGTH -2 DOWNTO 0 GENERATE
        ce_s(i) <= '1' WHEN (c_dmemb_i.adr >= MEMORY_MAP_g(i) AND 
        								c_dmemb_i.adr < MEMORY_MAP_g(i+1)) ELSE '0';
	END GENERATE;

    c_dmemb_o <= demux (x_dmemb_i, ce_s);

ext_devs:
    FOR i IN MEMORY_MAP_g'LENGTH -2 DOWNTO 0 GENERATE
    BEGIN
        x_dmemb_o(i).dat <= c_dmemb_i.dat;
        x_dmemb_o(i).adr <= c_dmemb_i.adr;
        x_dmemb_o(i).sel <= c_dmemb_i.sel WHEN (ce_s(i) = '1') ELSE (OTHERS => '0');
        x_dmemb_o(i).wre <= c_dmemb_i.wre AND ce_s(i);
        x_dmemb_o(i).ena <= c_dmemb_i.ena AND ce_s(i);
    END GENERATE;

END ARCHITECTURE rtl;
