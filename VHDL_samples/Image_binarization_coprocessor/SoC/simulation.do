vsim -t 1ns work.tb_wb_soc
add wave \
{tb_wb_soc/clk_ext_tb } \
{tb_wb_soc/rst_btn_tb } \
{tb_wb_soc/xram_ix_s } \
{tb_wb_soc/xram_ce_s } \
{tb_wb_soc/xram_addr_s } \
{tb_wb_soc/xram_data_s } \
{tb_wb_soc/xram_wr_s } \
{tb_wb_soc/xram_wrdly_s } \
{tb_wb_soc/soc/wb_slv/ctrl_r } \
{tb_wb_soc/soc/wb_slv/reg0_r } \
{tb_wb_soc/soc/wb_slv/reg1_r } \
{tb_wb_soc/soc/wb_slv/reg2_r } \
{tb_wb_soc/soc/wb_slv/reg3_r } \
{tb_wb_soc/soc/wb_slv/reg4_r } \
{tb_wb_soc/soc/wb_slv/reg5_r } \
{tb_wb_soc/soc/wb_slv/reg6_r } \
{tb_wb_soc/soc/wb_slv/reg7_r } \
{tb_wb_soc/soc/wb_slv/reg8_r } \
{tb_wb_soc/soc/wb_slv/reg9_r } \
{tb_wb_soc/soc/wb_slv/reg10_r } \
{tb_wb_soc/soc/wb_slv/reg11_r } \
{tb_wb_soc/soc/wb_slv/reg12_r } \
{tb_wb_soc/soc/wb_slv/reg13_r } \
{tb_wb_soc/soc/wb_slv/reg14_r } \
{tb_wb_soc/soc/wb_slv/reg15_r } \
{tb_wb_soc/soc/wb_slv/thresh_r } \
{tb_wb_soc/soc/wb_slv/stat_r }
for {set i 0} {$i< 78} {incr i 1} {run 1ms}
