------------------------------------------------------------------------------------
--
-- Entity:       mst_wb_adapter
-- File:         mst_wb_adapter.vhd
-- Description:  Interface for connecting a master's extended memory i/o port 
--               to a Wishbone slave 
-- Author:       H.J. Lincklaen Arriens
-- Date:         April, 2010
-- Modified:    
-- Remarks:     
--
------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE work.ET4351_Pkg.all;


----------------------------------------------------------
ENTITY mst_wb_adapter IS
----------------------------------------------------------
    PORT (
        x_dmemb_i :  IN c2dmemb_type;
        x_dmemb_o : OUT dmemb2c_type;
        mst_wb_i  :  IN wb2mst_type;
        mst_wb_o  : OUT mst2wb_type
        );
END ENTITY mst_wb_adapter;


----------------------------------------------------------
ARCHITECTURE rtl OF mst_wb_adapter IS
----------------------------------------------------------

    SIGNAL cyc_s : STD_LOGIC;
    
BEGIN
  
    mst_wb_o.adr_o  <= x_dmemb_i.adr;
    mst_wb_o.dat_o  <= x_dmemb_i.dat;
    mst_wb_o.we_o   <= x_dmemb_i.wre;
   	mst_wb_o.sel_o  <= x_dmemb_i.sel;
    cyc_s           <= x_dmemb_i.ena;
    mst_wb_o.cyc_o  <= cyc_s;   
    mst_wb_o.stb_o  <= cyc_s;   
    
    x_dmemb_o.ena <= '0' WHEN ((cyc_s = '1') AND (mst_wb_i.ack_i = '0')) ELSE
                     '1';
    x_dmemb_o.dat <= mst_wb_i.dat_i;
    x_dmemb_o.int <= mst_wb_i.int_i;

END ARCHITECTURE rtl;
