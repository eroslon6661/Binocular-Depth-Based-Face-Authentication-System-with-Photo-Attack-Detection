set here [file dirname [file normalize [info script]]]
if {$argc != 1} {error "Usage: vivado -mode batch -source recreate.tcl -tclargs NEW_OUTPUT_DIRECTORY"}
set out [file normalize [lindex $argv 0]]
if {[file exists $out]} {error "Output must not already exist: $out"}
if {[catch {
set_param general.maxThreads 4
create_project nav_v3 $out -part xc7z020clg400-2
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set_property ip_repo_paths [list [file join $here {ip_repo/camera}] [file join $here {ip_repo/rectify}] {F:/fpga_2026_1_work/hls_face_tile_compare/tile8_bram4_stride_shift_ip_repo}] [current_project]
update_ip_catalog -rebuild
add_files -norecurse [file join $here {inputs/08_es8388_i2s_tx_buffered.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/08_es8388_i2s_tx_buffered.v}]]
add_files -norecurse [file join $here {inputs/07_axis_rgb_to_green_oneway.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/07_axis_rgb_to_green_oneway.v}]]
add_files -norecurse [file join $here {inputs/33_axis_photo_tap.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/33_axis_photo_tap.v}]]
add_files -norecurse [file join $here {inputs/35_rgb_lcd_pins.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/35_rgb_lcd_pins.v}]]
add_files -norecurse [file join $here {inputs/34_gt911_pins.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/34_gt911_pins.v}]]
add_files -norecurse [file join $here {inputs/06_axis_rgb_to_green.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/06_axis_rgb_to_green.v}]]
add_files -norecurse [file join $here {inputs/12_census_hanming.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/12_census_hanming.v}]]
add_files -norecurse [file join $here {inputs/14_d64_cost_step2.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/14_d64_cost_step2.v}]]
add_files -norecurse [file join $here {inputs/16_line_buffer_3x3_bram.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/16_line_buffer_3x3_bram.v}]]
add_files -norecurse [file join $here {inputs/17_sgbm_agg_diag.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/17_sgbm_agg_diag.v}]]
add_files -norecurse [file join $here {inputs/18_sgbm_agg_lr.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/18_sgbm_agg_lr.v}]]
add_files -norecurse [file join $here {inputs/19_sgbm_agg_ud.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/19_sgbm_agg_ud.v}]]
add_files -norecurse [file join $here {inputs/20_sgbm_cost_aggregation_top.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/20_sgbm_cost_aggregation_top.v}]]
add_files -norecurse [file join $here {inputs/21_sgbm_depth_from_disp_lut.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/21_sgbm_depth_from_disp_lut.v}]]
add_files -norecurse [file join $here {inputs/22_sgbm_disp_to_gray_lut.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/22_sgbm_disp_to_gray_lut.v}]]
add_files -norecurse [file join $here {inputs/23_sgbm_median3x3.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/23_sgbm_median3x3.v}]]
add_files -norecurse [file join $here {inputs/24_sgbm_path_core_bus_tree_dropin.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/24_sgbm_path_core_bus_tree_dropin.v}]]
add_files -norecurse [file join $here {inputs/25_sgbm_uniqueness_check.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/25_sgbm_uniqueness_check.v}]]
add_files -norecurse [file join $here {inputs/26_sgbm_wta_65.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/26_sgbm_wta_65.v}]]
add_files -norecurse [file join $here {inputs/27_top_sgbm_cost.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/27_top_sgbm_cost.v}]]
add_files -norecurse [file join $here {inputs/28_top_sgbm_cost_aggr_clean_wta_only.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/28_top_sgbm_cost_aggr_clean_wta_only.v}]]
add_files -norecurse [file join $here {inputs/29_top_sgbm_uniqueness.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/29_top_sgbm_uniqueness.v}]]
add_files -norecurse [file join $here {inputs/30_top_sgbm_uniqueness_display_depth.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/30_top_sgbm_uniqueness_display_depth.v}]]
add_files -norecurse [file join $here {inputs/31_wta_merge.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/31_wta_merge.v}]]
add_files -norecurse [file join $here {inputs/32_xilinx_inferred_rams.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/32_xilinx_inferred_rams.v}]]
add_files -norecurse [file join $here {inputs/11_axis_stereo_sgbm_bridge.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/11_axis_stereo_sgbm_bridge.v}]]
add_files -norecurse [file join $here {inputs/10_axis_disparity_roi_scale.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/10_axis_disparity_roi_scale.v}]]
add_files -norecurse [file join $here {inputs/13_d64_cost.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/13_d64_cost.v}]]
add_files -norecurse [file join $here {inputs/15_es8388_i2s_tx.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/15_es8388_i2s_tx.v}]]
add_files -norecurse [file join $here {inputs/05_axis_green_to_rgb.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/05_axis_green_to_rgb.v}]]
add_files -norecurse [file join $here {inputs/09_vdma_frame_pointer_cdc.v}]
set_property USED_IN {synthesis implementation simulation} [get_files [file join $here {inputs/09_vdma_frame_pointer_cdc.v}]]
add_files -norecurse -fileset constrs_1 [file join $here {inputs/02_cursor_measure_key_2023_2.xdc}]
set_property USED_IN {synthesis implementation} [get_files [file join $here {inputs/02_cursor_measure_key_2023_2.xdc}]]
add_files -norecurse -fileset constrs_1 [file join $here {inputs/01_audio_pins.xdc}]
set_property USED_IN {implementation} [get_files [file join $here {inputs/01_audio_pins.xdc}]]
set_property PROCESSING_ORDER {LATE} [get_files [file join $here {inputs/01_audio_pins.xdc}]]
add_files -norecurse -fileset constrs_1 [file join $here {inputs/00_audio_fifo_cdc.xdc}]
set_property USED_IN {implementation} [get_files [file join $here {inputs/00_audio_fifo_cdc.xdc}]]
set_property PROCESSING_ORDER {LATE} [get_files [file join $here {inputs/00_audio_fifo_cdc.xdc}]]
add_files -norecurse -fileset constrs_1 [file join $here {inputs/04_retained_keys.xdc}]
set_property USED_IN {synthesis implementation} [get_files [file join $here {inputs/04_retained_keys.xdc}]]
add_files -norecurse -fileset constrs_1 [file join $here {inputs/03_j4_rgb_pins.xdc}]
set_property USED_IN {synthesis implementation} [get_files [file join $here {inputs/03_j4_rgb_pins.xdc}]]
update_compile_order -fileset sources_1
create_bd_design system
create_bd_intf_port -mode Master -vlnv {xilinx.com:interface:ddrx_rtl:1.0} {DDR}
create_bd_intf_port -mode Master -vlnv {xilinx.com:display_processing_system7:fixedio_rtl:1.0} {FIXED_IO}
create_bd_intf_port -mode Master -vlnv {xilinx.com:interface:gpio_rtl:1.0} {emio_sccb}
create_bd_intf_port -mode Master -vlnv {xilinx.com:interface:iic_rtl:1.0} {aud_iic}
create_bd_port -dir I {cam_pclk_0}
create_bd_port -dir I {cam_vsync_0}
create_bd_port -dir I {cam_href_0}
create_bd_port -dir I -from 7 -to 0 {cam_data_0}
create_bd_port -dir O -type rst {cam_rst_n_0}
set_property -dict [list CONFIG.POLARITY {ACTIVE_LOW}] [get_bd_ports {cam_rst_n_0}]
create_bd_port -dir O {cam_pwdn_0}
create_bd_port -dir I {cam_pclk_1}
create_bd_port -dir I {cam_vsync_1}
create_bd_port -dir I {cam_href_1}
create_bd_port -dir I -from 7 -to 0 {cam_data_1}
create_bd_port -dir O -type rst {cam_rst_n_1}
set_property -dict [list CONFIG.POLARITY {ACTIVE_LOW}] [get_bd_ports {cam_rst_n_1}]
create_bd_port -dir O {cam_pwdn_1}
create_bd_port -dir O {aud_bclk}
create_bd_port -dir O {aud_lrc}
create_bd_port -dir O {aud_dacdat}
create_bd_port -dir O -type clk {aud_mclk}
set_property -dict [list CONFIG.FREQ_HZ {12288000}] [get_bd_ports {aud_mclk}]
create_bd_port -dir I -from 2 -to 0 {key}
create_bd_port -dir O -from 23 -to 0 {lcd_rgb}
create_bd_port -dir O {lcd_de}
create_bd_port -dir O {lcd_hs}
create_bd_port -dir O {lcd_vs}
create_bd_port -dir O {lcd_clk}
create_bd_port -dir O {lcd_rst}
create_bd_port -dir O {lcd_bl}
create_bd_port -dir IO {touch_scl}
create_bd_port -dir IO {touch_sda}
create_bd_port -dir IO {touch_int}
create_bd_port -dir O {touch_rst}
puts {CREATE_CELL ov5640_capture_data_0}
create_bd_cell -type ip -vlnv {alientek.com:user:ov5640_capture_data:1.0} {ov5640_capture_data_0}
puts {CREATE_CELL ov5640_capture_data_1}
create_bd_cell -type ip -vlnv {alientek.com:user:ov5640_capture_data:1.0} {ov5640_capture_data_1}
puts {CREATE_CELL processing_system7_0}
create_bd_cell -type ip -vlnv {xilinx.com:ip:processing_system7:5.5} {processing_system7_0}
set_property -dict [list CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {666.666687} CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730} CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000} CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {100.000000} CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {142.857132} CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {40.000000} CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {200.000000} CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {100.000000} CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {10.000000} CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {100.000000} CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_APU_CLK_RATIO_ENABLE {6:2:1} CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {666.666666} CONFIG.PCW_CAN0_PERIPHERAL_CLKSRC {External} CONFIG.PCW_CAN0_PERIPHERAL_ENABLE {0} CONFIG.PCW_CAN1_PERIPHERAL_CLKSRC {External} CONFIG.PCW_CAN1_PERIPHERAL_ENABLE {0} CONFIG.PCW_CAN_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_CAN_PERIPHERAL_VALID {0} CONFIG.PCW_CLK0_FREQ {100000000} CONFIG.PCW_CLK1_FREQ {142857132} CONFIG.PCW_CLK2_FREQ {40000000} CONFIG.PCW_CLK3_FREQ {10000000} CONFIG.PCW_CPU_CPU_6X4X_MAX_RANGE {767} CONFIG.PCW_CPU_PERIPHERAL_CLKSRC {ARM PLL} CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {33.333333} CONFIG.PCW_DCI_PERIPHERAL_CLKSRC {DDR PLL} CONFIG.PCW_DCI_PERIPHERAL_FREQMHZ {10.159} CONFIG.PCW_DDR_PERIPHERAL_CLKSRC {DDR PLL} CONFIG.PCW_DDR_RAM_BASEADDR {0x00100000} CONFIG.PCW_DDR_RAM_HIGHADDR {0x3FFFFFFF} CONFIG.PCW_DM_WIDTH {4} CONFIG.PCW_DQS_WIDTH {4} CONFIG.PCW_DQ_WIDTH {32} CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} CONFIG.PCW_ENET0_RESET_ENABLE {0} CONFIG.PCW_ENET1_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {0} CONFIG.PCW_ENET_RESET_ENABLE {1} CONFIG.PCW_ENET_RESET_POLARITY {Active Low} CONFIG.PCW_ENET_RESET_SELECT {Share reset pin} CONFIG.PCW_EN_4K_TIMER {0} CONFIG.PCW_EN_CAN0 {0} CONFIG.PCW_EN_CAN1 {0} CONFIG.PCW_EN_CLK0_PORT {1} CONFIG.PCW_EN_CLK1_PORT {1} CONFIG.PCW_EN_CLK2_PORT {1} CONFIG.PCW_EN_CLK3_PORT {0} CONFIG.PCW_EN_CLKTRIG0_PORT {0} CONFIG.PCW_EN_CLKTRIG1_PORT {0} CONFIG.PCW_EN_CLKTRIG2_PORT {0} CONFIG.PCW_EN_CLKTRIG3_PORT {0} CONFIG.PCW_EN_DDR {1} CONFIG.PCW_EN_EMIO_CAN0 {0} CONFIG.PCW_EN_EMIO_CAN1 {0} CONFIG.PCW_EN_EMIO_CD_SDIO0 {0} CONFIG.PCW_EN_EMIO_CD_SDIO1 {0} CONFIG.PCW_EN_EMIO_ENET0 {0} CONFIG.PCW_EN_EMIO_ENET1 {0} CONFIG.PCW_EN_EMIO_GPIO {1} CONFIG.PCW_EN_EMIO_I2C0 {1} CONFIG.PCW_EN_EMIO_I2C1 {0} CONFIG.PCW_EN_EMIO_MODEM_UART0 {0} CONFIG.PCW_EN_EMIO_MODEM_UART1 {0} CONFIG.PCW_EN_EMIO_PJTAG {0} CONFIG.PCW_EN_EMIO_SDIO0 {0} CONFIG.PCW_EN_EMIO_SDIO1 {0} CONFIG.PCW_EN_EMIO_SPI0 {0} CONFIG.PCW_EN_EMIO_SPI1 {0} CONFIG.PCW_EN_EMIO_SRAM_INT {0} CONFIG.PCW_EN_EMIO_TRACE {0} CONFIG.PCW_EN_EMIO_TTC0 {0} CONFIG.PCW_EN_EMIO_TTC1 {0} CONFIG.PCW_EN_EMIO_UART0 {0} CONFIG.PCW_EN_EMIO_UART1 {0} CONFIG.PCW_EN_EMIO_WDT {0} CONFIG.PCW_EN_EMIO_WP_SDIO0 {0} CONFIG.PCW_EN_EMIO_WP_SDIO1 {0} CONFIG.PCW_EN_ENET0 {1} CONFIG.PCW_EN_ENET1 {0} CONFIG.PCW_EN_GPIO {1} CONFIG.PCW_EN_I2C0 {1} CONFIG.PCW_EN_I2C1 {0} CONFIG.PCW_EN_MODEM_UART0 {0} CONFIG.PCW_EN_MODEM_UART1 {0} CONFIG.PCW_EN_PJTAG {0} CONFIG.PCW_EN_PTP_ENET0 {0} CONFIG.PCW_EN_PTP_ENET1 {0} CONFIG.PCW_EN_QSPI {1} CONFIG.PCW_EN_RST0_PORT {1} CONFIG.PCW_EN_RST1_PORT {0} CONFIG.PCW_EN_RST2_PORT {0} CONFIG.PCW_EN_RST3_PORT {0} CONFIG.PCW_EN_SDIO0 {1} CONFIG.PCW_EN_SDIO1 {0} CONFIG.PCW_EN_SMC {0} CONFIG.PCW_EN_SPI0 {0} CONFIG.PCW_EN_SPI1 {0} CONFIG.PCW_EN_TRACE {0} CONFIG.PCW_EN_TTC0 {0} CONFIG.PCW_EN_TTC1 {0} CONFIG.PCW_EN_UART0 {1} CONFIG.PCW_EN_UART1 {0} CONFIG.PCW_EN_USB0 {0} CONFIG.PCW_EN_USB1 {0} CONFIG.PCW_EN_WDT {0} CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_FCLK1_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_FCLK2_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_FCLK3_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_FCLK_CLK0_BUF {TRUE} CONFIG.PCW_FCLK_CLK1_BUF {FALSE} CONFIG.PCW_FCLK_CLK2_BUF {TRUE} CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {150} CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {40} CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {50} CONFIG.PCW_FPGA_FCLK0_ENABLE {1} CONFIG.PCW_FPGA_FCLK1_ENABLE {1} CONFIG.PCW_FPGA_FCLK2_ENABLE {1} CONFIG.PCW_GP0_EN_MODIFIABLE_TXN {1} CONFIG.PCW_GP0_NUM_READ_THREADS {4} CONFIG.PCW_GP0_NUM_WRITE_THREADS {4} CONFIG.PCW_GP1_EN_MODIFIABLE_TXN {1} CONFIG.PCW_GP1_NUM_READ_THREADS {4} CONFIG.PCW_GP1_NUM_WRITE_THREADS {4} CONFIG.PCW_GPIO_BASEADDR {0xE000A000} CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {1} CONFIG.PCW_GPIO_EMIO_GPIO_IO {4} CONFIG.PCW_GPIO_EMIO_GPIO_WIDTH {4} CONFIG.PCW_GPIO_HIGHADDR {0xE000AFFF} CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} CONFIG.PCW_GPIO_PERIPHERAL_ENABLE {1} CONFIG.PCW_I2C0_BASEADDR {0xE0004000} CONFIG.PCW_I2C0_HIGHADDR {0xE0004FFF} CONFIG.PCW_I2C0_I2C0_IO {EMIO} CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1} CONFIG.PCW_I2C0_RESET_ENABLE {0} CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {0} CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {111.111115} CONFIG.PCW_I2C_RESET_ENABLE {1} CONFIG.PCW_I2C_RESET_POLARITY {Active Low} CONFIG.PCW_I2C_RESET_SELECT {Share reset pin} CONFIG.PCW_IMPORT_BOARD_PRESET {None} CONFIG.PCW_INCLUDE_ACP_TRANS_CHECK {0} CONFIG.PCW_IRQ_F2P_MODE {DIRECT} CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_0_PULLUP {enabled} CONFIG.PCW_MIO_0_SLEW {slow} CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_10_PULLUP {enabled} CONFIG.PCW_MIO_10_SLEW {slow} CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_11_PULLUP {enabled} CONFIG.PCW_MIO_11_SLEW {slow} CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_12_PULLUP {enabled} CONFIG.PCW_MIO_12_SLEW {slow} CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_13_PULLUP {enabled} CONFIG.PCW_MIO_13_SLEW {slow} CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_14_PULLUP {enabled} CONFIG.PCW_MIO_14_SLEW {slow} CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_15_PULLUP {enabled} CONFIG.PCW_MIO_15_SLEW {slow} CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_16_PULLUP {enabled} CONFIG.PCW_MIO_16_SLEW {slow} CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_17_PULLUP {enabled} CONFIG.PCW_MIO_17_SLEW {slow} CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_18_PULLUP {enabled} CONFIG.PCW_MIO_18_SLEW {slow} CONFIG.PCW_MIO_19_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_19_PULLUP {enabled} CONFIG.PCW_MIO_19_SLEW {slow} CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_1_PULLUP {enabled} CONFIG.PCW_MIO_1_SLEW {slow} CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_20_PULLUP {enabled} CONFIG.PCW_MIO_20_SLEW {slow} CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_21_PULLUP {enabled} CONFIG.PCW_MIO_21_SLEW {slow} CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_22_PULLUP {enabled} CONFIG.PCW_MIO_22_SLEW {slow} CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_23_PULLUP {enabled} CONFIG.PCW_MIO_23_SLEW {slow} CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_24_PULLUP {enabled} CONFIG.PCW_MIO_24_SLEW {slow} CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_25_PULLUP {enabled} CONFIG.PCW_MIO_25_SLEW {slow} CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_26_PULLUP {enabled} CONFIG.PCW_MIO_26_SLEW {slow} CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_27_PULLUP {enabled} CONFIG.PCW_MIO_27_SLEW {slow} CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_28_PULLUP {enabled} CONFIG.PCW_MIO_28_SLEW {slow} CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_29_PULLUP {enabled} CONFIG.PCW_MIO_29_SLEW {slow} CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_2_SLEW {slow} CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_30_PULLUP {enabled} CONFIG.PCW_MIO_30_SLEW {slow} CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_31_PULLUP {enabled} CONFIG.PCW_MIO_31_SLEW {slow} CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_32_PULLUP {enabled} CONFIG.PCW_MIO_32_SLEW {slow} CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_33_PULLUP {enabled} CONFIG.PCW_MIO_33_SLEW {slow} CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_34_PULLUP {enabled} CONFIG.PCW_MIO_34_SLEW {slow} CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_35_PULLUP {enabled} CONFIG.PCW_MIO_35_SLEW {slow} CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_36_PULLUP {enabled} CONFIG.PCW_MIO_36_SLEW {slow} CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_37_PULLUP {enabled} CONFIG.PCW_MIO_37_SLEW {slow} CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_38_PULLUP {enabled} CONFIG.PCW_MIO_38_SLEW {slow} CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_39_PULLUP {enabled} CONFIG.PCW_MIO_39_SLEW {slow} CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_3_SLEW {slow} CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_40_PULLUP {enabled} CONFIG.PCW_MIO_40_SLEW {slow} CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_41_PULLUP {enabled} CONFIG.PCW_MIO_41_SLEW {slow} CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_42_PULLUP {enabled} CONFIG.PCW_MIO_42_SLEW {slow} CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_43_PULLUP {enabled} CONFIG.PCW_MIO_43_SLEW {slow} CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_44_PULLUP {enabled} CONFIG.PCW_MIO_44_SLEW {slow} CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_45_PULLUP {enabled} CONFIG.PCW_MIO_45_SLEW {slow} CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_46_PULLUP {enabled} CONFIG.PCW_MIO_46_SLEW {slow} CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_47_PULLUP {enabled} CONFIG.PCW_MIO_47_SLEW {slow} CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_48_PULLUP {enabled} CONFIG.PCW_MIO_48_SLEW {slow} CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_49_PULLUP {enabled} CONFIG.PCW_MIO_49_SLEW {slow} CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_4_SLEW {slow} CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_50_PULLUP {enabled} CONFIG.PCW_MIO_50_SLEW {slow} CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_51_PULLUP {enabled} CONFIG.PCW_MIO_51_SLEW {slow} CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_52_PULLUP {enabled} CONFIG.PCW_MIO_52_SLEW {slow} CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 1.8V} CONFIG.PCW_MIO_53_PULLUP {enabled} CONFIG.PCW_MIO_53_SLEW {slow} CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_5_SLEW {slow} CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_6_SLEW {slow} CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_7_SLEW {slow} CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_8_SLEW {slow} CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 3.3V} CONFIG.PCW_MIO_9_PULLUP {enabled} CONFIG.PCW_MIO_9_SLEW {slow} CONFIG.PCW_MIO_PRIMITIVE {54} CONFIG.PCW_M_AXI_GP0_ENABLE_STATIC_REMAP {0} CONFIG.PCW_M_AXI_GP0_ID_WIDTH {12} CONFIG.PCW_M_AXI_GP0_SUPPORT_NARROW_BURST {0} CONFIG.PCW_M_AXI_GP0_THREAD_ID_WIDTH {12} CONFIG.PCW_NAND_CYCLES_T_AR {1} CONFIG.PCW_NAND_CYCLES_T_CLR {1} CONFIG.PCW_NAND_CYCLES_T_RC {11} CONFIG.PCW_NAND_CYCLES_T_REA {1} CONFIG.PCW_NAND_CYCLES_T_RR {1} CONFIG.PCW_NAND_CYCLES_T_WC {11} CONFIG.PCW_NAND_CYCLES_T_WP {1} CONFIG.PCW_NOR_CS0_T_CEOE {1} CONFIG.PCW_NOR_CS0_T_PC {1} CONFIG.PCW_NOR_CS0_T_RC {11} CONFIG.PCW_NOR_CS0_T_TR {1} CONFIG.PCW_NOR_CS0_T_WC {11} CONFIG.PCW_NOR_CS0_T_WP {1} CONFIG.PCW_NOR_CS0_WE_TIME {0} CONFIG.PCW_NOR_CS1_T_CEOE {1} CONFIG.PCW_NOR_CS1_T_PC {1} CONFIG.PCW_NOR_CS1_T_RC {11} CONFIG.PCW_NOR_CS1_T_TR {1} CONFIG.PCW_NOR_CS1_T_WC {11} CONFIG.PCW_NOR_CS1_T_WP {1} CONFIG.PCW_NOR_CS1_WE_TIME {0} CONFIG.PCW_NOR_SRAM_CS0_T_CEOE {1} CONFIG.PCW_NOR_SRAM_CS0_T_PC {1} CONFIG.PCW_NOR_SRAM_CS0_T_RC {11} CONFIG.PCW_NOR_SRAM_CS0_T_TR {1} CONFIG.PCW_NOR_SRAM_CS0_T_WC {11} CONFIG.PCW_NOR_SRAM_CS0_T_WP {1} CONFIG.PCW_NOR_SRAM_CS0_WE_TIME {0} CONFIG.PCW_NOR_SRAM_CS1_T_CEOE {1} CONFIG.PCW_NOR_SRAM_CS1_T_PC {1} CONFIG.PCW_NOR_SRAM_CS1_T_RC {11} CONFIG.PCW_NOR_SRAM_CS1_T_TR {1} CONFIG.PCW_NOR_SRAM_CS1_T_WC {11} CONFIG.PCW_NOR_SRAM_CS1_T_WP {1} CONFIG.PCW_NOR_SRAM_CS1_WE_TIME {0} CONFIG.PCW_OVERRIDE_BASIC_CLOCK {0} CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY0 {0.080} CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY1 {0.063} CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY2 {0.057} CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY3 {0.068} CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_0 {-0.047} CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_1 {-0.025} CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_2 {-0.006} CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_3 {-0.017} CONFIG.PCW_PACKAGE_NAME {clg400} CONFIG.PCW_PCAP_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_PCAP_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_PERIPHERAL_BOARD_PRESET {None} CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE {0} CONFIG.PCW_PLL_BYPASSMODE_ENABLE {0} CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V} CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} CONFIG.PCW_PS7_SI_REV {PRODUCTION} CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {0} CONFIG.PCW_QSPI_GRP_IO1_ENABLE {0} CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO {MIO 1 .. 6} CONFIG.PCW_QSPI_GRP_SS1_ENABLE {0} CONFIG.PCW_QSPI_INTERNAL_HIGHADDRESS {0xFCFFFFFF} CONFIG.PCW_QSPI_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} CONFIG.PCW_SD0_GRP_CD_ENABLE {1} CONFIG.PCW_SD0_GRP_CD_IO {MIO 10} CONFIG.PCW_SD0_GRP_POW_ENABLE {0} CONFIG.PCW_SD0_GRP_WP_ENABLE {0} CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} CONFIG.PCW_SD1_PERIPHERAL_ENABLE {0} CONFIG.PCW_SDIO0_BASEADDR {0xE0100000} CONFIG.PCW_SDIO0_HIGHADDR {0xE0100FFF} CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {100} CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} CONFIG.PCW_SINGLE_QSPI_DATA_MODE {x4} CONFIG.PCW_SMC_CYCLE_T0 {NA} CONFIG.PCW_SMC_CYCLE_T1 {NA} CONFIG.PCW_SMC_CYCLE_T2 {NA} CONFIG.PCW_SMC_CYCLE_T3 {NA} CONFIG.PCW_SMC_CYCLE_T4 {NA} CONFIG.PCW_SMC_CYCLE_T5 {NA} CONFIG.PCW_SMC_CYCLE_T6 {NA} CONFIG.PCW_SMC_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_SMC_PERIPHERAL_VALID {0} CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {0} CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {0} CONFIG.PCW_SPI_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_SPI_PERIPHERAL_VALID {0} CONFIG.PCW_S_AXI_HP0_DATA_WIDTH {64} CONFIG.PCW_S_AXI_HP0_ID_WIDTH {6} CONFIG.PCW_S_AXI_HP1_DATA_WIDTH {64} CONFIG.PCW_S_AXI_HP2_DATA_WIDTH {64} CONFIG.PCW_S_AXI_HP3_DATA_WIDTH {64} CONFIG.PCW_TPIU_PERIPHERAL_CLKSRC {External} CONFIG.PCW_TRACE_INTERNAL_WIDTH {2} CONFIG.PCW_TRACE_PERIPHERAL_ENABLE {0} CONFIG.PCW_TTC0_CLK0_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_TTC0_CLK0_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TTC0_CLK1_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_TTC0_CLK1_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TTC0_CLK2_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_TTC0_CLK2_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} CONFIG.PCW_TTC1_CLK0_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_TTC1_CLK0_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TTC1_CLK1_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_TTC1_CLK1_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TTC1_CLK2_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_TTC1_CLK2_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_TTC1_PERIPHERAL_ENABLE {0} CONFIG.PCW_UART0_BASEADDR {0xE0000000} CONFIG.PCW_UART0_BAUD_RATE {115200} CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} CONFIG.PCW_UART0_HIGHADDR {0xE0000FFF} CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} CONFIG.PCW_UART0_UART0_IO {MIO 14 .. 15} CONFIG.PCW_UART1_PERIPHERAL_ENABLE {0} CONFIG.PCW_UART_PERIPHERAL_CLKSRC {IO PLL} CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} CONFIG.PCW_UART_PERIPHERAL_VALID {1} CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {533.333374} CONFIG.PCW_UIPARAM_DDR_ADV_ENABLE {0} CONFIG.PCW_UIPARAM_DDR_AL {0} CONFIG.PCW_UIPARAM_DDR_BL {8} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.121} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.112} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.124} CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.110} CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {32 Bit} CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PACKAGE_LENGTH {54.563} CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PACKAGE_LENGTH {54.563} CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PACKAGE_LENGTH {54.563} CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PACKAGE_LENGTH {54.563} CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_CLOCK_STOP_EN {0} CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQS_0_PACKAGE_LENGTH {101.239} CONFIG.PCW_UIPARAM_DDR_DQS_0_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQS_1_PACKAGE_LENGTH {79.5025} CONFIG.PCW_UIPARAM_DDR_DQS_1_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQS_2_PACKAGE_LENGTH {60.536} CONFIG.PCW_UIPARAM_DDR_DQS_2_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQS_3_PACKAGE_LENGTH {71.7715} CONFIG.PCW_UIPARAM_DDR_DQS_3_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {0.203} CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {0.212} CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {0.105} CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {0.119} CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQ_0_PACKAGE_LENGTH {104.5365} CONFIG.PCW_UIPARAM_DDR_DQ_0_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQ_1_PACKAGE_LENGTH {70.676} CONFIG.PCW_UIPARAM_DDR_DQ_1_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQ_2_PACKAGE_LENGTH {59.1615} CONFIG.PCW_UIPARAM_DDR_DQ_2_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM {0} CONFIG.PCW_UIPARAM_DDR_DQ_3_PACKAGE_LENGTH {81.319} CONFIG.PCW_UIPARAM_DDR_DQ_3_PROPOGATION_DELAY {160} CONFIG.PCW_UIPARAM_DDR_ENABLE {1} CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {533.333333} CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP {Normal (0-85)} CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3 (Low Voltage)} CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41K256M16 RE-125} CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {0} CONFIG.PCW_UIPARAM_GENERATE_SUMMARY {NA} CONFIG.PCW_USB0_PERIPHERAL_ENABLE {0} CONFIG.PCW_USB1_PERIPHERAL_ENABLE {0} CONFIG.PCW_USB_RESET_ENABLE {1} CONFIG.PCW_USB_RESET_POLARITY {Active Low} CONFIG.PCW_USE_AXI_FABRIC_IDLE {0} CONFIG.PCW_USE_AXI_NONSECURE {0} CONFIG.PCW_USE_CORESIGHT {0} CONFIG.PCW_USE_CROSS_TRIGGER {0} CONFIG.PCW_USE_CR_FABRIC {1} CONFIG.PCW_USE_DDR_BYPASS {0} CONFIG.PCW_USE_DEBUG {0} CONFIG.PCW_USE_DMA0 {0} CONFIG.PCW_USE_DMA1 {0} CONFIG.PCW_USE_DMA2 {0} CONFIG.PCW_USE_DMA3 {0} CONFIG.PCW_USE_EXPANDED_IOP {0} CONFIG.PCW_USE_FABRIC_INTERRUPT {0} CONFIG.PCW_USE_HIGH_OCM {0} CONFIG.PCW_USE_M_AXI_GP0 {1} CONFIG.PCW_USE_M_AXI_GP1 {0} CONFIG.PCW_USE_PROC_EVENT_BUS {0} CONFIG.PCW_USE_PS_SLCR_REGISTERS {0} CONFIG.PCW_USE_S_AXI_ACP {0} CONFIG.PCW_USE_S_AXI_GP0 {0} CONFIG.PCW_USE_S_AXI_GP1 {0} CONFIG.PCW_USE_S_AXI_HP0 {1} CONFIG.PCW_USE_S_AXI_HP1 {1} CONFIG.PCW_USE_S_AXI_HP2 {1} CONFIG.PCW_USE_S_AXI_HP3 {1} CONFIG.PCW_USE_TRACE {0} CONFIG.PCW_VALUE_SILVERSION {3} CONFIG.PCW_WDT_PERIPHERAL_CLKSRC {CPU_1X} CONFIG.PCW_WDT_PERIPHERAL_DIVISOR0 {1} CONFIG.PCW_WDT_PERIPHERAL_ENABLE {0}] [get_bd_cells {processing_system7_0}]
puts {CREATE_CELL axi_vdma_0}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_vdma:6.3} {axi_vdma_0}
set_property -dict [list CONFIG.c_include_internal_genlock {0} CONFIG.c_include_mm2s {0} CONFIG.c_include_s2mm {1} CONFIG.c_num_fstores {3} CONFIG.c_s2mm_genlock_mode {0} CONFIG.c_s2mm_linebuffer_depth {2048} CONFIG.c_s2mm_max_burst_length {64}] [get_bd_cells {axi_vdma_0}]
puts {CREATE_CELL axi_vdma_1}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_vdma:6.3} {axi_vdma_1}
set_property -dict [list CONFIG.c_include_internal_genlock {0} CONFIG.c_include_mm2s {0} CONFIG.c_include_s2mm {1} CONFIG.c_num_fstores {3} CONFIG.c_s2mm_genlock_mode {0} CONFIG.c_s2mm_linebuffer_depth {2048} CONFIG.c_s2mm_max_burst_length {64}] [get_bd_cells {axi_vdma_1}]
puts {CREATE_CELL clk_wiz_0}
create_bd_cell -type ip -vlnv {xilinx.com:ip:clk_wiz:6.0} {clk_wiz_0}
set_property -dict [list CONFIG.AXI_DRP {false} CONFIG.CLKOUT1_DRIVES {BUFG} CONFIG.CLKOUT1_JITTER {128.710} CONFIG.CLKOUT1_PHASE_ERROR {91.100} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {75} CONFIG.CLKOUT2_DRIVES {BUFG} CONFIG.CLKOUT2_JITTER {95.380} CONFIG.CLKOUT2_PHASE_ERROR {91.100} CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {375} CONFIG.CLKOUT2_USED {true} CONFIG.CLKOUT3_DRIVES {BUFG} CONFIG.CLKOUT4_DRIVES {BUFG} CONFIG.CLKOUT5_DRIVES {BUFG} CONFIG.CLKOUT6_DRIVES {BUFG} CONFIG.CLKOUT7_DRIVES {BUFG} CONFIG.MMCM_CLKFBOUT_MULT_F {11.250} CONFIG.MMCM_CLKOUT0_DIVIDE_F {15.000} CONFIG.MMCM_CLKOUT1_DIVIDE {3} CONFIG.MMCM_DIVCLK_DIVIDE {1} CONFIG.NUM_OUT_CLKS {2} CONFIG.PHASE_DUTY_CONFIG {false} CONFIG.PRIM_SOURCE {No_buffer} CONFIG.SECONDARY_SOURCE {Single_ended_clock_capable_pin} CONFIG.USE_DYN_RECONFIG {false} CONFIG.USE_PHASE_ALIGNMENT {false}] [get_bd_cells {clk_wiz_0}]
puts {CREATE_CELL rst_ps7_0_100M}
create_bd_cell -type ip -vlnv {xilinx.com:ip:proc_sys_reset:5.0} {rst_ps7_0_100M}
puts {CREATE_CELL rst_ps7_0_150M}
create_bd_cell -type ip -vlnv {xilinx.com:ip:proc_sys_reset:5.0} {rst_ps7_0_150M}
puts {CREATE_CELL v_vid_in_axi4s_0}
create_bd_cell -type ip -vlnv {xilinx.com:ip:v_vid_in_axi4s:5.0} {v_vid_in_axi4s_0}
set_property -dict [list CONFIG.C_HAS_ASYNC_CLK {1}] [get_bd_cells {v_vid_in_axi4s_0}]
puts {CREATE_CELL v_vid_in_axi4s_1}
create_bd_cell -type ip -vlnv {xilinx.com:ip:v_vid_in_axi4s:5.0} {v_vid_in_axi4s_1}
set_property -dict [list CONFIG.C_HAS_ASYNC_CLK {1}] [get_bd_cells {v_vid_in_axi4s_1}]
puts {CREATE_CELL audio_clk_wiz}
create_bd_cell -type ip -vlnv {xilinx.com:ip:clk_wiz:6.0} {audio_clk_wiz}
set_property -dict [list CONFIG.CLKOUT1_JITTER {360.948} CONFIG.CLKOUT1_PHASE_ERROR {301.601} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {12.288} CONFIG.MMCM_CLKFBOUT_MULT_F {48.000} CONFIG.MMCM_CLKOUT0_DIVIDE_F {78.125} CONFIG.MMCM_DIVCLK_DIVIDE {5} CONFIG.PRIM_IN_FREQ {100.000} CONFIG.PRIM_SOURCE {No_buffer} CONFIG.USE_RESET {true}] [get_bd_cells {audio_clk_wiz}]
puts {CREATE_CELL axi_gpio_audio}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_gpio:2.0} {axi_gpio_audio}
set_property -dict [list CONFIG.C_ALL_INPUTS_2 {1} CONFIG.C_ALL_OUTPUTS {1} CONFIG.C_GPIO2_WIDTH {1} CONFIG.C_GPIO_WIDTH {17} CONFIG.C_IS_DUAL {1}] [get_bd_cells {axi_gpio_audio}]
puts {CREATE_CELL axi_gpio_key}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_gpio:2.0} {axi_gpio_key}
set_property -dict [list CONFIG.C_ALL_INPUTS {1} CONFIG.C_ALL_OUTPUTS_2 {1} CONFIG.C_GPIO2_WIDTH {32} CONFIG.C_GPIO_WIDTH {3} CONFIG.C_INTERRUPT_PRESENT {0} CONFIG.C_IS_DUAL {1}] [get_bd_cells {axi_gpio_key}]
puts {CREATE_CELL audio_i2s_tx}
create_bd_cell -type module -reference {es8388_i2s_tx_buffered} {audio_i2s_tx}
set_property -dict [list CONFIG.FREQ_HZ {100000000}] [get_bd_pins {audio_i2s_tx/control_clk}]
puts {CREATE_CELL frame_tag_left}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_gpio:2.0} {frame_tag_left}
set_property -dict [list CONFIG.C_ALL_INPUTS {1} CONFIG.C_ALL_INPUTS_2 {1} CONFIG.C_GPIO2_WIDTH {32} CONFIG.C_GPIO_WIDTH {32} CONFIG.C_IS_DUAL {1}] [get_bd_cells {frame_tag_left}]
puts {CREATE_CELL frame_tag_right}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_gpio:2.0} {frame_tag_right}
set_property -dict [list CONFIG.C_ALL_INPUTS {1} CONFIG.C_ALL_INPUTS_2 {1} CONFIG.C_GPIO2_WIDTH {32} CONFIG.C_GPIO_WIDTH {32} CONFIG.C_IS_DUAL {1}] [get_bd_cells {frame_tag_right}]
puts {CREATE_CELL axi_mem_intercon}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_interconnect:2.1} {axi_mem_intercon}
set_property -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_SI {2}] [get_bd_cells {axi_mem_intercon}]
puts {CREATE_CELL ps7_0_axi_periph}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_interconnect:2.1} {ps7_0_axi_periph}
set_property -dict [list CONFIG.NUM_MI {20} CONFIG.NUM_SI {1}] [get_bd_cells {ps7_0_axi_periph}]
puts {CREATE_CELL rectify_left}
create_bd_cell -type ip -vlnv {xilinx.com:hls:rectify_accel:1.0} {rectify_left}
puts {CREATE_CELL axi_mem_intercon_1}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_interconnect:2.1} {axi_mem_intercon_1}
set_property -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_SI {3}] [get_bd_cells {axi_mem_intercon_1}]
puts {CREATE_CELL rectify_right}
create_bd_cell -type ip -vlnv {xilinx.com:hls:rectify_accel:1.0} {rectify_right}
puts {CREATE_CELL axi_mem_intercon_2}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_interconnect:2.1} {axi_mem_intercon_2}
set_property -dict [list CONFIG.NUM_MI {1}] [get_bd_cells {axi_mem_intercon_2}]
puts {CREATE_CELL capture_green_left}
create_bd_cell -type module -reference {axis_rgb_to_green_oneway} {capture_green_left}
set_property -dict [list CONFIG.CLOCK_HZ {142857132}] [get_bd_cells {capture_green_left}]
set_property -dict [list CONFIG.FREQ_HZ {142857132}] [get_bd_pins {capture_green_left/aclk}]
puts {CREATE_CELL capture_green_right}
create_bd_cell -type module -reference {axis_rgb_to_green_oneway} {capture_green_right}
set_property -dict [list CONFIG.CLOCK_HZ {142857132}] [get_bd_cells {capture_green_right}]
set_property -dict [list CONFIG.FREQ_HZ {142857132}] [get_bd_pins {capture_green_right/aclk}]
puts {CREATE_CELL frame_clock}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_gpio:2.0} {frame_clock}
set_property -dict [list CONFIG.C_ALL_INPUTS {1} CONFIG.C_GPIO_WIDTH {32}] [get_bd_cells {frame_clock}]
puts {CREATE_CELL photo_tap_left}
create_bd_cell -type module -reference {axis_photo_tap} {photo_tap_left}
set_property -dict [list CONFIG.FREQ_HZ {142857132}] [get_bd_pins {photo_tap_left/aclk}]
puts {CREATE_CELL photo_left}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_vdma:6.3} {photo_left}
set_property -dict [list CONFIG.c_include_internal_genlock {0} CONFIG.c_include_mm2s {0} CONFIG.c_include_s2mm {1} CONFIG.c_m_axi_s2mm_data_width {64} CONFIG.c_num_fstores {3} CONFIG.c_s2mm_genlock_mode {0} CONFIG.c_s2mm_linebuffer_depth {4096}] [get_bd_cells {photo_left}]
puts {CREATE_CELL photo_arm_left}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_gpio:2.0} {photo_arm_left}
set_property -dict [list CONFIG.C_ALL_OUTPUTS {1} CONFIG.C_GPIO_WIDTH {1}] [get_bd_cells {photo_arm_left}]
puts {CREATE_CELL photo_tag_left}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_gpio:2.0} {photo_tag_left}
set_property -dict [list CONFIG.C_ALL_INPUTS {1} CONFIG.C_ALL_INPUTS_2 {1} CONFIG.C_GPIO2_WIDTH {32} CONFIG.C_GPIO_WIDTH {32} CONFIG.C_IS_DUAL {1}] [get_bd_cells {photo_tag_left}]
puts {CREATE_CELL photo_tap_right}
create_bd_cell -type module -reference {axis_photo_tap} {photo_tap_right}
set_property -dict [list CONFIG.FREQ_HZ {142857132}] [get_bd_pins {photo_tap_right/aclk}]
puts {CREATE_CELL photo_right}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_vdma:6.3} {photo_right}
set_property -dict [list CONFIG.c_include_internal_genlock {0} CONFIG.c_include_mm2s {0} CONFIG.c_include_s2mm {1} CONFIG.c_m_axi_s2mm_data_width {64} CONFIG.c_num_fstores {3} CONFIG.c_s2mm_genlock_mode {0} CONFIG.c_s2mm_linebuffer_depth {4096}] [get_bd_cells {photo_right}]
puts {CREATE_CELL photo_arm_right}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_gpio:2.0} {photo_arm_right}
set_property -dict [list CONFIG.C_ALL_OUTPUTS {1} CONFIG.C_GPIO_WIDTH {1}] [get_bd_cells {photo_arm_right}]
puts {CREATE_CELL photo_tag_right}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_gpio:2.0} {photo_tag_right}
set_property -dict [list CONFIG.C_ALL_INPUTS {1} CONFIG.C_ALL_INPUTS_2 {1} CONFIG.C_GPIO2_WIDTH {32} CONFIG.C_GPIO_WIDTH {32} CONFIG.C_IS_DUAL {1}] [get_bd_cells {photo_tag_right}]
puts {CREATE_CELL lcd_clock}
create_bd_cell -type ip -vlnv {xilinx.com:ip:clk_wiz:6.0} {lcd_clock}
set_property -dict [list CONFIG.CLKOUT1_JITTER {151.636} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50.000} CONFIG.MMCM_CLKOUT0_DIVIDE_F {20.000} CONFIG.PRIM_IN_FREQ {100.000} CONFIG.PRIM_SOURCE {No_buffer} CONFIG.USE_RESET {false}] [get_bd_cells {lcd_clock}]
puts {CREATE_CELL lcd_reset}
create_bd_cell -type ip -vlnv {xilinx.com:ip:proc_sys_reset:5.0} {lcd_reset}
puts {CREATE_CELL lcd_dma}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_vdma:6.3} {lcd_dma}
set_property -dict [list CONFIG.c_include_internal_genlock {0} CONFIG.c_include_mm2s {1} CONFIG.c_include_s2mm {0} CONFIG.c_m_axi_mm2s_data_width {64} CONFIG.c_m_axis_mm2s_tdata_width {24} CONFIG.c_mm2s_genlock_mode {0} CONFIG.c_mm2s_linebuffer_depth {512} CONFIG.c_num_fstores {3}] [get_bd_cells {lcd_dma}]
puts {CREATE_CELL lcd_video}
create_bd_cell -type ip -vlnv {xilinx.com:ip:v_axi4s_vid_out:4.0} {lcd_video}
set_property -dict [list CONFIG.C_HAS_ASYNC_CLK {1}] [get_bd_cells {lcd_video}]
puts {CREATE_CELL lcd_vtc}
create_bd_cell -type ip -vlnv {xilinx.com:ip:v_tc:6.2} {lcd_vtc}
set_property -dict [list CONFIG.enable_detection {false}] [get_bd_cells {lcd_vtc}]
puts {CREATE_CELL lcd_pins}
create_bd_cell -type module -reference {rgb_lcd_pins} {lcd_pins}
puts {CREATE_CELL touch_pins}
create_bd_cell -type module -reference {gt911_pins} {touch_pins}
puts {CREATE_CELL lcd_control}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_gpio:2.0} {lcd_control}
set_property -dict [list CONFIG.C_ALL_OUTPUTS {1} CONFIG.C_GPIO_WIDTH {2}] [get_bd_cells {lcd_control}]
puts {CREATE_CELL touch_gpio}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_gpio:2.0} {touch_gpio}
set_property -dict [list CONFIG.C_ALL_INPUTS_2 {1} CONFIG.C_ALL_OUTPUTS {1} CONFIG.C_GPIO2_WIDTH {4} CONFIG.C_GPIO_WIDTH {4} CONFIG.C_IS_DUAL {1}] [get_bd_cells {touch_gpio}]
puts {CREATE_CELL rgb_memory}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_interconnect:2.1} {rgb_memory}
set_property -dict [list CONFIG.NUM_MI {1} CONFIG.NUM_SI {3}] [get_bd_cells {rgb_memory}]
puts {CREATE_CELL face_int8_accel_0}
create_bd_cell -type ip -vlnv {xilinx.com:hls:face_int8_accel:1.0} {face_int8_accel_0}
puts {CREATE_CELL face_act_cc}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_clock_converter:2.1} {face_act_cc}
puts {CREATE_CELL face_param_cc}
create_bd_cell -type ip -vlnv {xilinx.com:ip:axi_clock_converter:2.1} {face_param_cc}
connect_bd_intf_net -intf_net {axi_mem_intercon_1_M00_AXI} [get_bd_intf_pins {axi_mem_intercon_1/M00_AXI}] [get_bd_intf_pins {processing_system7_0/S_AXI_HP1}]
connect_bd_intf_net -intf_net {axi_mem_intercon_2_M00_AXI} [get_bd_intf_pins {axi_mem_intercon_2/M00_AXI}] [get_bd_intf_pins {processing_system7_0/S_AXI_HP2}]
connect_bd_intf_net -intf_net {axi_mem_intercon_M00_AXI} [get_bd_intf_pins {axi_mem_intercon/M00_AXI}] [get_bd_intf_pins {processing_system7_0/S_AXI_HP0}]
connect_bd_intf_net -intf_net {axi_vdma_0_M_AXI_S2MM} [get_bd_intf_pins {axi_vdma_0/M_AXI_S2MM}] [get_bd_intf_pins {axi_mem_intercon/S00_AXI}]
connect_bd_intf_net -intf_net {axi_vdma_1_M_AXI_S2MM} [get_bd_intf_pins {axi_vdma_1/M_AXI_S2MM}] [get_bd_intf_pins {axi_mem_intercon/S01_AXI}]
connect_bd_intf_net -intf_net {capture_green_left_m_axis} [get_bd_intf_pins {capture_green_left/m_axis}] [get_bd_intf_pins {axi_vdma_0/S_AXIS_S2MM}]
connect_bd_intf_net -intf_net {capture_green_right_m_axis} [get_bd_intf_pins {capture_green_right/m_axis}] [get_bd_intf_pins {axi_vdma_1/S_AXIS_S2MM}]
connect_bd_intf_net -intf_net {face_act_cc_M_AXI} [get_bd_intf_pins {face_act_cc/M_AXI}] [get_bd_intf_pins {axi_mem_intercon_1/S01_AXI}]
connect_bd_intf_net -intf_net {face_int8_accel_0_m_axi_gmem_act} [get_bd_intf_pins {face_int8_accel_0/m_axi_gmem_act}] [get_bd_intf_pins {face_act_cc/S_AXI}]
connect_bd_intf_net -intf_net {face_int8_accel_0_m_axi_gmem_param} [get_bd_intf_pins {face_int8_accel_0/m_axi_gmem_param}] [get_bd_intf_pins {face_param_cc/S_AXI}]
connect_bd_intf_net -intf_net {face_param_cc_M_AXI} [get_bd_intf_pins {face_param_cc/M_AXI}] [get_bd_intf_pins {axi_mem_intercon_1/S02_AXI}]
connect_bd_intf_net -intf_net {lcd_dma_M_AXIS_MM2S} [get_bd_intf_pins {lcd_dma/M_AXIS_MM2S}] [get_bd_intf_pins {lcd_video/video_in}]
connect_bd_intf_net -intf_net {lcd_dma_M_AXI_MM2S} [get_bd_intf_pins {lcd_dma/M_AXI_MM2S}] [get_bd_intf_pins {rgb_memory/S02_AXI}]
connect_bd_intf_net -intf_net {lcd_vtc_vtiming_out} [get_bd_intf_pins {lcd_vtc/vtiming_out}] [get_bd_intf_pins {lcd_video/vtiming_in}]
connect_bd_intf_net -intf_net {ov5640_capture_data_0_cmos_rgb} [get_bd_intf_pins {ov5640_capture_data_0/cmos_rgb}] [get_bd_intf_pins {v_vid_in_axi4s_0/vid_io_in}]
connect_bd_intf_net -intf_net {ov5640_capture_data_1_cmos_rgb} [get_bd_intf_pins {ov5640_capture_data_1/cmos_rgb}] [get_bd_intf_pins {v_vid_in_axi4s_1/vid_io_in}]
connect_bd_intf_net -intf_net {photo_left_M_AXI_S2MM} [get_bd_intf_pins {photo_left/M_AXI_S2MM}] [get_bd_intf_pins {rgb_memory/S00_AXI}]
connect_bd_intf_net -intf_net {photo_right_M_AXI_S2MM} [get_bd_intf_pins {photo_right/M_AXI_S2MM}] [get_bd_intf_pins {rgb_memory/S01_AXI}]
connect_bd_intf_net -intf_net {photo_tap_left_m_axis} [get_bd_intf_pins {photo_tap_left/m_axis}] [get_bd_intf_pins {capture_green_left/s_axis}]
connect_bd_intf_net -intf_net {photo_tap_left_photo_axis} [get_bd_intf_pins {photo_tap_left/photo_axis}] [get_bd_intf_pins {photo_left/S_AXIS_S2MM}]
connect_bd_intf_net -intf_net {photo_tap_right_m_axis} [get_bd_intf_pins {photo_tap_right/m_axis}] [get_bd_intf_pins {capture_green_right/s_axis}]
connect_bd_intf_net -intf_net {photo_tap_right_photo_axis} [get_bd_intf_pins {photo_tap_right/photo_axis}] [get_bd_intf_pins {photo_right/S_AXIS_S2MM}]
connect_bd_intf_net -intf_net {processing_system7_0_DDR} [get_bd_intf_ports {DDR}] [get_bd_intf_pins {processing_system7_0/DDR}]
connect_bd_intf_net -intf_net {processing_system7_0_FIXED_IO} [get_bd_intf_ports {FIXED_IO}] [get_bd_intf_pins {processing_system7_0/FIXED_IO}]
connect_bd_intf_net -intf_net {processing_system7_0_GPIO_0} [get_bd_intf_ports {emio_sccb}] [get_bd_intf_pins {processing_system7_0/GPIO_0}]
connect_bd_intf_net -intf_net {processing_system7_0_IIC_0} [get_bd_intf_ports {aud_iic}] [get_bd_intf_pins {processing_system7_0/IIC_0}]
connect_bd_intf_net -intf_net {processing_system7_0_M_AXI_GP0} [get_bd_intf_pins {processing_system7_0/M_AXI_GP0}] [get_bd_intf_pins {ps7_0_axi_periph/S00_AXI}]
connect_bd_intf_net -intf_net {ps7_0_axi_periph_M00_AXI} [get_bd_intf_pins {ps7_0_axi_periph/M00_AXI}] [get_bd_intf_pins {axi_vdma_0/S_AXI_LITE}]
connect_bd_intf_net -intf_net {ps7_0_axi_periph_M01_AXI} [get_bd_intf_pins {ps7_0_axi_periph/M01_AXI}] [get_bd_intf_pins {axi_vdma_1/S_AXI_LITE}]
connect_bd_intf_net -intf_net {ps7_0_axi_periph_M02_AXI1} [get_bd_intf_pins {ps7_0_axi_periph/M02_AXI}] [get_bd_intf_pins {axi_gpio_audio/S_AXI}]
connect_bd_intf_net -intf_net {ps7_0_axi_periph_M03_AXI1} [get_bd_intf_pins {ps7_0_axi_periph/M03_AXI}] [get_bd_intf_pins {axi_gpio_key/S_AXI}]
connect_bd_intf_net -intf_net {ps7_0_axi_periph_M04_AXI1} [get_bd_intf_pins {ps7_0_axi_periph/M04_AXI}] [get_bd_intf_pins {frame_tag_left/S_AXI}]
connect_bd_intf_net -intf_net {ps7_0_axi_periph_M05_AXI1} [get_bd_intf_pins {ps7_0_axi_periph/M05_AXI}] [get_bd_intf_pins {frame_tag_right/S_AXI}]
connect_bd_intf_net -intf_net {ps7_0_axi_periph_M06_AXI1} [get_bd_intf_pins {ps7_0_axi_periph/M06_AXI}] [get_bd_intf_pins {rectify_left/s_axi_control}]
connect_bd_intf_net -intf_net {ps7_0_axi_periph_M07_AXI} [get_bd_intf_pins {ps7_0_axi_periph/M07_AXI}] [get_bd_intf_pins {rectify_right/s_axi_control}]
connect_bd_intf_net -intf_net {ps7_0_axi_periph_M08_AXI} [get_bd_intf_pins {ps7_0_axi_periph/M08_AXI}] [get_bd_intf_pins {frame_clock/S_AXI}]
connect_bd_intf_net -intf_net {ps7_0_axi_periph_M09_AXI} [get_bd_intf_pins {ps7_0_axi_periph/M09_AXI}] [get_bd_intf_pins {photo_left/S_AXI_LITE}]
connect_bd_intf_net -intf_net {ps7_0_axi_periph_M10_AXI} [get_bd_intf_pins {ps7_0_axi_periph/M10_AXI}] [get_bd_intf_pins {photo_arm_left/S_AXI}]
connect_bd_intf_net -intf_net {ps7_0_axi_periph_M11_AXI} [get_bd_intf_pins {ps7_0_axi_periph/M11_AXI}] [get_bd_intf_pins {photo_tag_left/S_AXI}]
connect_bd_intf_net -intf_net {ps7_0_axi_periph_M12_AXI} [get_bd_intf_pins {ps7_0_axi_periph/M12_AXI}] [get_bd_intf_pins {photo_right/S_AXI_LITE}]
connect_bd_intf_net -intf_net {ps7_0_axi_periph_M13_AXI} [get_bd_intf_pins {ps7_0_axi_periph/M13_AXI}] [get_bd_intf_pins {photo_arm_right/S_AXI}]
connect_bd_intf_net -intf_net {ps7_0_axi_periph_M14_AXI} [get_bd_intf_pins {ps7_0_axi_periph/M14_AXI}] [get_bd_intf_pins {photo_tag_right/S_AXI}]
connect_bd_intf_net -intf_net {ps7_0_axi_periph_M15_AXI} [get_bd_intf_pins {ps7_0_axi_periph/M15_AXI}] [get_bd_intf_pins {lcd_dma/S_AXI_LITE}]
connect_bd_intf_net -intf_net {ps7_0_axi_periph_M16_AXI} [get_bd_intf_pins {ps7_0_axi_periph/M16_AXI}] [get_bd_intf_pins {lcd_vtc/ctrl}]
connect_bd_intf_net -intf_net {ps7_0_axi_periph_M17_AXI} [get_bd_intf_pins {ps7_0_axi_periph/M17_AXI}] [get_bd_intf_pins {lcd_control/S_AXI}]
connect_bd_intf_net -intf_net {ps7_0_axi_periph_M18_AXI} [get_bd_intf_pins {ps7_0_axi_periph/M18_AXI}] [get_bd_intf_pins {touch_gpio/S_AXI}]
connect_bd_intf_net -intf_net {ps7_0_axi_periph_M19_AXI} [get_bd_intf_pins {ps7_0_axi_periph/M19_AXI}] [get_bd_intf_pins {face_int8_accel_0/s_axi_control}]
connect_bd_intf_net -intf_net {rectify_left_m_axi_memory} [get_bd_intf_pins {rectify_left/m_axi_memory}] [get_bd_intf_pins {axi_mem_intercon_1/S00_AXI}]
connect_bd_intf_net -intf_net {rectify_right_m_axi_memory} [get_bd_intf_pins {rectify_right/m_axi_memory}] [get_bd_intf_pins {axi_mem_intercon_2/S00_AXI}]
connect_bd_intf_net -intf_net {rgb_memory_M00_AXI} [get_bd_intf_pins {rgb_memory/M00_AXI}] [get_bd_intf_pins {processing_system7_0/S_AXI_HP3}]
connect_bd_intf_net -intf_net {v_vid_in_axi4s_0_video_out} [get_bd_intf_pins {v_vid_in_axi4s_0/video_out}] [get_bd_intf_pins {photo_tap_left/s_axis}]
connect_bd_intf_net -intf_net {v_vid_in_axi4s_1_video_out} [get_bd_intf_pins {v_vid_in_axi4s_1/video_out}] [get_bd_intf_pins {photo_tap_right/s_axis}]
connect_bd_net -net {Net} [get_bd_ports {touch_scl}] [get_bd_pins {touch_pins/touch_scl}]
connect_bd_net -net {Net1} [get_bd_ports {touch_sda}] [get_bd_pins {touch_pins/touch_sda}]
connect_bd_net -net {Net2} [get_bd_ports {touch_int}] [get_bd_pins {touch_pins/touch_int}]
connect_bd_net -net {audio_clk_wiz_clk_out1} [get_bd_pins {audio_clk_wiz/clk_out1}] [get_bd_ports {aud_mclk}] [get_bd_pins {audio_i2s_tx/audio_clk}]
connect_bd_net -net {audio_clk_wiz_locked} [get_bd_pins {audio_clk_wiz/locked}] [get_bd_pins {audio_i2s_tx/audio_locked}]
connect_bd_net -net {audio_i2s_tx_aud_bclk} [get_bd_pins {audio_i2s_tx/aud_bclk}] [get_bd_ports {aud_bclk}]
connect_bd_net -net {audio_i2s_tx_aud_dacdat} [get_bd_pins {audio_i2s_tx/aud_dacdat}] [get_bd_ports {aud_dacdat}]
connect_bd_net -net {audio_i2s_tx_aud_lrc} [get_bd_pins {audio_i2s_tx/aud_lrc}] [get_bd_ports {aud_lrc}]
connect_bd_net -net {audio_i2s_tx_gpio_ack} [get_bd_pins {audio_i2s_tx/gpio_ack}] [get_bd_pins {axi_gpio_audio/gpio2_io_i}]
connect_bd_net -net {axi_gpio_audio_gpio_io_o} [get_bd_pins {axi_gpio_audio/gpio_io_o}] [get_bd_pins {audio_i2s_tx/gpio_word}]
connect_bd_net -net {axi_gpio_key_gpio2_io_o} [get_bd_pins {axi_gpio_key/gpio2_io_o}]
connect_bd_net -net {cam_data_1} [get_bd_ports {cam_data_0}] [get_bd_pins {ov5640_capture_data_0/cam_data}]
connect_bd_net -net {cam_data_1_1} [get_bd_ports {cam_data_1}] [get_bd_pins {ov5640_capture_data_1/cam_data}]
connect_bd_net -net {cam_href_1} [get_bd_ports {cam_href_0}] [get_bd_pins {ov5640_capture_data_0/cam_href}]
connect_bd_net -net {cam_href_1_1} [get_bd_ports {cam_href_1}] [get_bd_pins {ov5640_capture_data_1/cam_href}]
connect_bd_net -net {cam_pclk_1} [get_bd_ports {cam_pclk_0}] [get_bd_pins {ov5640_capture_data_0/cam_pclk}]
connect_bd_net -net {cam_pclk_1_1} [get_bd_ports {cam_pclk_1}] [get_bd_pins {ov5640_capture_data_1/cam_pclk}]
connect_bd_net -net {cam_vsync_1} [get_bd_ports {cam_vsync_0}] [get_bd_pins {ov5640_capture_data_0/cam_vsync}]
connect_bd_net -net {cam_vsync_1_1} [get_bd_ports {cam_vsync_1}] [get_bd_pins {ov5640_capture_data_1/cam_vsync}]
connect_bd_net -net {capture_green_left_capture_clock_us} [get_bd_pins {capture_green_left/capture_clock_us}] [get_bd_pins {photo_tap_left/clock_us}] [get_bd_pins {photo_tap_right/clock_us}] [get_bd_pins {frame_clock/gpio_io_i}]
connect_bd_net -net {capture_green_left_safe_capture_us} [get_bd_pins {capture_green_left/safe_capture_us}] [get_bd_pins {frame_tag_left/gpio2_io_i}]
connect_bd_net -net {capture_green_left_safe_sequence} [get_bd_pins {capture_green_left/safe_sequence}] [get_bd_pins {frame_tag_left/gpio_io_i}]
connect_bd_net -net {capture_green_right_safe_capture_us} [get_bd_pins {capture_green_right/safe_capture_us}] [get_bd_pins {frame_tag_right/gpio2_io_i}]
connect_bd_net -net {capture_green_right_safe_sequence} [get_bd_pins {capture_green_right/safe_sequence}] [get_bd_pins {frame_tag_right/gpio_io_i}]
connect_bd_net -net {clk_wiz_0_clk_out1} [get_bd_pins {clk_wiz_0/clk_out1}]
connect_bd_net -net {clk_wiz_0_clk_out2} [get_bd_pins {clk_wiz_0/clk_out2}]
connect_bd_net -net {clk_wiz_0_locked} [get_bd_pins {clk_wiz_0/locked}] [get_bd_pins {ov5640_capture_data_0/rst_n}] [get_bd_pins {ov5640_capture_data_1/rst_n}]
connect_bd_net -net {gpio_io_i_0_1} [get_bd_ports {key}] [get_bd_pins {axi_gpio_key/gpio_io_i}]
connect_bd_net -net {lcd_clock_clk_out1} [get_bd_pins {lcd_clock/clk_out1}] [get_bd_pins {lcd_pins/pclk}] [get_bd_pins {lcd_reset/slowest_sync_clk}] [get_bd_pins {lcd_video/vid_io_out_clk}] [get_bd_pins {lcd_vtc/clk}]
connect_bd_net -net {lcd_clock_locked} [get_bd_pins {lcd_clock/locked}] [get_bd_pins {lcd_reset/dcm_locked}]
connect_bd_net -net {lcd_control_gpio_io_o} [get_bd_pins {lcd_control/gpio_io_o}] [get_bd_pins {lcd_pins/control}]
connect_bd_net -net {lcd_pins_lcd_bl} [get_bd_pins {lcd_pins/lcd_bl}] [get_bd_ports {lcd_bl}]
connect_bd_net -net {lcd_pins_lcd_clk} [get_bd_pins {lcd_pins/lcd_clk}] [get_bd_ports {lcd_clk}]
connect_bd_net -net {lcd_pins_lcd_de} [get_bd_pins {lcd_pins/lcd_de}] [get_bd_ports {lcd_de}]
connect_bd_net -net {lcd_pins_lcd_hs} [get_bd_pins {lcd_pins/lcd_hs}] [get_bd_ports {lcd_hs}]
connect_bd_net -net {lcd_pins_lcd_rgb} [get_bd_pins {lcd_pins/lcd_rgb}] [get_bd_ports {lcd_rgb}]
connect_bd_net -net {lcd_pins_lcd_rst} [get_bd_pins {lcd_pins/lcd_rst}] [get_bd_ports {lcd_rst}]
connect_bd_net -net {lcd_pins_lcd_vs} [get_bd_pins {lcd_pins/lcd_vs}] [get_bd_ports {lcd_vs}]
connect_bd_net -net {lcd_reset_peripheral_aresetn} [get_bd_pins {lcd_reset/peripheral_aresetn}] [get_bd_pins {lcd_vtc/resetn}]
connect_bd_net -net {lcd_reset_peripheral_reset} [get_bd_pins {lcd_reset/peripheral_reset}] [get_bd_pins {lcd_video/vid_io_out_reset}]
connect_bd_net -net {lcd_video_vid_active_video} [get_bd_pins {lcd_video/vid_active_video}] [get_bd_pins {lcd_pins/active}]
connect_bd_net -net {lcd_video_vid_data} [get_bd_pins {lcd_video/vid_data}] [get_bd_pins {lcd_pins/data}]
connect_bd_net -net {lcd_video_vtg_ce} [get_bd_pins {lcd_video/vtg_ce}] [get_bd_pins {lcd_vtc/gen_clken}]
connect_bd_net -net {ov5640_capture_data_0_cam_pwdn} [get_bd_pins {ov5640_capture_data_0/cam_pwdn}] [get_bd_ports {cam_pwdn_0}]
connect_bd_net -net {ov5640_capture_data_0_cam_rst_n} [get_bd_pins {ov5640_capture_data_0/cam_rst_n}] [get_bd_ports {cam_rst_n_0}]
connect_bd_net -net {ov5640_capture_data_0_cmos_frame_ce} [get_bd_pins {ov5640_capture_data_0/cmos_frame_ce}] [get_bd_pins {v_vid_in_axi4s_0/vid_io_in_ce}]
connect_bd_net -net {ov5640_capture_data_0_cmos_frame_clk} [get_bd_pins {ov5640_capture_data_0/cmos_frame_clk}] [get_bd_pins {v_vid_in_axi4s_0/vid_io_in_clk}]
connect_bd_net -net {ov5640_capture_data_1_cam_pwdn} [get_bd_pins {ov5640_capture_data_1/cam_pwdn}] [get_bd_ports {cam_pwdn_1}]
connect_bd_net -net {ov5640_capture_data_1_cam_rst_n} [get_bd_pins {ov5640_capture_data_1/cam_rst_n}] [get_bd_ports {cam_rst_n_1}]
connect_bd_net -net {ov5640_capture_data_1_cmos_frame_ce} [get_bd_pins {ov5640_capture_data_1/cmos_frame_ce}] [get_bd_pins {v_vid_in_axi4s_1/vid_io_in_ce}]
connect_bd_net -net {ov5640_capture_data_1_cmos_frame_clk} [get_bd_pins {ov5640_capture_data_1/cmos_frame_clk}] [get_bd_pins {v_vid_in_axi4s_1/vid_io_in_clk}]
connect_bd_net -net {photo_arm_left_gpio_io_o} [get_bd_pins {photo_arm_left/gpio_io_o}] [get_bd_pins {photo_tap_left/arm_toggle}]
connect_bd_net -net {photo_arm_right_gpio_io_o} [get_bd_pins {photo_arm_right/gpio_io_o}] [get_bd_pins {photo_tap_right/arm_toggle}]
connect_bd_net -net {photo_tap_left_capture_us} [get_bd_pins {photo_tap_left/capture_us}] [get_bd_pins {photo_tag_left/gpio2_io_i}]
connect_bd_net -net {photo_tap_left_status} [get_bd_pins {photo_tap_left/status}] [get_bd_pins {photo_tag_left/gpio_io_i}]
connect_bd_net -net {photo_tap_right_capture_us} [get_bd_pins {photo_tap_right/capture_us}] [get_bd_pins {photo_tag_right/gpio2_io_i}]
connect_bd_net -net {photo_tap_right_status} [get_bd_pins {photo_tap_right/status}] [get_bd_pins {photo_tag_right/gpio_io_i}]
connect_bd_net -net {processing_system7_0_FCLK_CLK0} [get_bd_pins {processing_system7_0/FCLK_CLK0}] [get_bd_pins {processing_system7_0/M_AXI_GP0_ACLK}] [get_bd_pins {audio_i2s_tx/control_clk}] [get_bd_pins {audio_clk_wiz/clk_in1}] [get_bd_pins {axi_gpio_audio/s_axi_aclk}] [get_bd_pins {axi_gpio_key/s_axi_aclk}] [get_bd_pins {axi_vdma_0/s_axi_lite_aclk}] [get_bd_pins {axi_vdma_1/s_axi_lite_aclk}] [get_bd_pins {clk_wiz_0/clk_in1}] [get_bd_pins {lcd_clock/clk_in1}] [get_bd_pins {lcd_control/s_axi_aclk}] [get_bd_pins {lcd_dma/s_axi_lite_aclk}] [get_bd_pins {lcd_vtc/s_axi_aclk}] [get_bd_pins {ps7_0_axi_periph/ACLK}] [get_bd_pins {ps7_0_axi_periph/S00_ACLK}] [get_bd_pins {ps7_0_axi_periph/M00_ACLK}] [get_bd_pins {ps7_0_axi_periph/M01_ACLK}] [get_bd_pins {ps7_0_axi_periph/M02_ACLK}] [get_bd_pins {ps7_0_axi_periph/M03_ACLK}] [get_bd_pins {ps7_0_axi_periph/M15_ACLK}] [get_bd_pins {ps7_0_axi_periph/M16_ACLK}] [get_bd_pins {ps7_0_axi_periph/M17_ACLK}] [get_bd_pins {ps7_0_axi_periph/M18_ACLK}] [get_bd_pins {rst_ps7_0_100M/slowest_sync_clk}] [get_bd_pins {touch_gpio/s_axi_aclk}] [get_bd_pins {ps7_0_axi_periph/M19_ACLK}] [get_bd_pins {face_act_cc/s_axi_aclk}] [get_bd_pins {face_param_cc/s_axi_aclk}] [get_bd_pins {face_int8_accel_0/ap_clk}]
connect_bd_net -net {processing_system7_0_FCLK_CLK1} [get_bd_pins {processing_system7_0/FCLK_CLK1}] [get_bd_pins {processing_system7_0/S_AXI_HP0_ACLK}] [get_bd_pins {rectify_left/ap_clk}] [get_bd_pins {processing_system7_0/S_AXI_HP1_ACLK}] [get_bd_pins {rectify_right/ap_clk}] [get_bd_pins {processing_system7_0/S_AXI_HP2_ACLK}] [get_bd_pins {capture_green_left/aclk}] [get_bd_pins {capture_green_right/aclk}] [get_bd_pins {photo_tap_left/aclk}] [get_bd_pins {processing_system7_0/S_AXI_HP3_ACLK}] [get_bd_pins {photo_tap_right/aclk}] [get_bd_pins {axi_mem_intercon/ACLK}] [get_bd_pins {axi_mem_intercon/S00_ACLK}] [get_bd_pins {axi_mem_intercon/M00_ACLK}] [get_bd_pins {axi_mem_intercon/S01_ACLK}] [get_bd_pins {axi_mem_intercon_1/ACLK}] [get_bd_pins {axi_mem_intercon_1/S00_ACLK}] [get_bd_pins {axi_mem_intercon_1/M00_ACLK}] [get_bd_pins {axi_mem_intercon_2/ACLK}] [get_bd_pins {axi_mem_intercon_2/S00_ACLK}] [get_bd_pins {axi_mem_intercon_2/M00_ACLK}] [get_bd_pins {axi_vdma_0/m_axi_s2mm_aclk}] [get_bd_pins {axi_vdma_0/s_axis_s2mm_aclk}] [get_bd_pins {axi_vdma_1/m_axi_s2mm_aclk}] [get_bd_pins {axi_vdma_1/s_axis_s2mm_aclk}] [get_bd_pins {frame_clock/s_axi_aclk}] [get_bd_pins {frame_tag_left/s_axi_aclk}] [get_bd_pins {frame_tag_right/s_axi_aclk}] [get_bd_pins {lcd_dma/m_axi_mm2s_aclk}] [get_bd_pins {lcd_dma/m_axis_mm2s_aclk}] [get_bd_pins {lcd_video/aclk}] [get_bd_pins {photo_arm_left/s_axi_aclk}] [get_bd_pins {photo_arm_right/s_axi_aclk}] [get_bd_pins {photo_left/s_axi_lite_aclk}] [get_bd_pins {photo_left/m_axi_s2mm_aclk}] [get_bd_pins {photo_left/s_axis_s2mm_aclk}] [get_bd_pins {photo_right/s_axi_lite_aclk}] [get_bd_pins {photo_right/m_axi_s2mm_aclk}] [get_bd_pins {photo_right/s_axis_s2mm_aclk}] [get_bd_pins {photo_tag_left/s_axi_aclk}] [get_bd_pins {photo_tag_right/s_axi_aclk}] [get_bd_pins {ps7_0_axi_periph/M04_ACLK}] [get_bd_pins {ps7_0_axi_periph/M05_ACLK}] [get_bd_pins {ps7_0_axi_periph/M06_ACLK}] [get_bd_pins {ps7_0_axi_periph/M07_ACLK}] [get_bd_pins {ps7_0_axi_periph/M08_ACLK}] [get_bd_pins {ps7_0_axi_periph/M09_ACLK}] [get_bd_pins {ps7_0_axi_periph/M10_ACLK}] [get_bd_pins {ps7_0_axi_periph/M11_ACLK}] [get_bd_pins {ps7_0_axi_periph/M12_ACLK}] [get_bd_pins {ps7_0_axi_periph/M13_ACLK}] [get_bd_pins {ps7_0_axi_periph/M14_ACLK}] [get_bd_pins {rgb_memory/ACLK}] [get_bd_pins {rgb_memory/S00_ACLK}] [get_bd_pins {rgb_memory/M00_ACLK}] [get_bd_pins {rgb_memory/S01_ACLK}] [get_bd_pins {rgb_memory/S02_ACLK}] [get_bd_pins {rst_ps7_0_150M/slowest_sync_clk}] [get_bd_pins {v_vid_in_axi4s_0/aclk}] [get_bd_pins {v_vid_in_axi4s_1/aclk}] [get_bd_pins {face_act_cc/m_axi_aclk}] [get_bd_pins {face_param_cc/m_axi_aclk}] [get_bd_pins {axi_mem_intercon_1/S01_ACLK}] [get_bd_pins {axi_mem_intercon_1/S02_ACLK}]
connect_bd_net -net {processing_system7_0_FCLK_CLK2} [get_bd_pins {processing_system7_0/FCLK_CLK2}]
connect_bd_net -net {processing_system7_0_FCLK_RESET0_N} [get_bd_pins {processing_system7_0/FCLK_RESET0_N}] [get_bd_pins {lcd_reset/ext_reset_in}] [get_bd_pins {rst_ps7_0_100M/ext_reset_in}] [get_bd_pins {rst_ps7_0_150M/ext_reset_in}]
connect_bd_net -net {rst_ps7_0_100M_peripheral_aresetn} [get_bd_pins {rst_ps7_0_100M/peripheral_aresetn}] [get_bd_pins {audio_i2s_tx/resetn}] [get_bd_pins {axi_gpio_audio/s_axi_aresetn}] [get_bd_pins {axi_gpio_key/s_axi_aresetn}] [get_bd_pins {axi_vdma_0/axi_resetn}] [get_bd_pins {axi_vdma_1/axi_resetn}] [get_bd_pins {lcd_control/s_axi_aresetn}] [get_bd_pins {lcd_dma/axi_resetn}] [get_bd_pins {lcd_vtc/s_axi_aresetn}] [get_bd_pins {ps7_0_axi_periph/ARESETN}] [get_bd_pins {ps7_0_axi_periph/S00_ARESETN}] [get_bd_pins {ps7_0_axi_periph/M00_ARESETN}] [get_bd_pins {ps7_0_axi_periph/M01_ARESETN}] [get_bd_pins {ps7_0_axi_periph/M02_ARESETN}] [get_bd_pins {ps7_0_axi_periph/M03_ARESETN}] [get_bd_pins {ps7_0_axi_periph/M15_ARESETN}] [get_bd_pins {ps7_0_axi_periph/M16_ARESETN}] [get_bd_pins {ps7_0_axi_periph/M17_ARESETN}] [get_bd_pins {ps7_0_axi_periph/M18_ARESETN}] [get_bd_pins {touch_gpio/s_axi_aresetn}] [get_bd_pins {ps7_0_axi_periph/M19_ARESETN}] [get_bd_pins {face_act_cc/s_axi_aresetn}] [get_bd_pins {face_param_cc/s_axi_aresetn}] [get_bd_pins {face_int8_accel_0/ap_rst_n}]
connect_bd_net -net {rst_ps7_0_100M_peripheral_reset} [get_bd_pins {rst_ps7_0_100M/peripheral_reset}] [get_bd_pins {audio_clk_wiz/reset}] [get_bd_pins {clk_wiz_0/reset}]
connect_bd_net -net {rst_ps7_0_150M_peripheral_aresetn} [get_bd_pins {rst_ps7_0_150M/peripheral_aresetn}] [get_bd_pins {rectify_left/ap_rst_n}] [get_bd_pins {rectify_right/ap_rst_n}] [get_bd_pins {capture_green_left/aresetn}] [get_bd_pins {capture_green_right/aresetn}] [get_bd_pins {photo_tap_left/aresetn}] [get_bd_pins {photo_tap_right/aresetn}] [get_bd_pins {axi_mem_intercon/ARESETN}] [get_bd_pins {axi_mem_intercon/S00_ARESETN}] [get_bd_pins {axi_mem_intercon/M00_ARESETN}] [get_bd_pins {axi_mem_intercon/S01_ARESETN}] [get_bd_pins {axi_mem_intercon_1/ARESETN}] [get_bd_pins {axi_mem_intercon_1/S00_ARESETN}] [get_bd_pins {axi_mem_intercon_1/M00_ARESETN}] [get_bd_pins {axi_mem_intercon_2/ARESETN}] [get_bd_pins {axi_mem_intercon_2/S00_ARESETN}] [get_bd_pins {axi_mem_intercon_2/M00_ARESETN}] [get_bd_pins {frame_clock/s_axi_aresetn}] [get_bd_pins {frame_tag_left/s_axi_aresetn}] [get_bd_pins {frame_tag_right/s_axi_aresetn}] [get_bd_pins {lcd_video/aresetn}] [get_bd_pins {photo_arm_left/s_axi_aresetn}] [get_bd_pins {photo_arm_right/s_axi_aresetn}] [get_bd_pins {photo_left/axi_resetn}] [get_bd_pins {photo_right/axi_resetn}] [get_bd_pins {photo_tag_left/s_axi_aresetn}] [get_bd_pins {photo_tag_right/s_axi_aresetn}] [get_bd_pins {ps7_0_axi_periph/M04_ARESETN}] [get_bd_pins {ps7_0_axi_periph/M05_ARESETN}] [get_bd_pins {ps7_0_axi_periph/M06_ARESETN}] [get_bd_pins {ps7_0_axi_periph/M07_ARESETN}] [get_bd_pins {ps7_0_axi_periph/M08_ARESETN}] [get_bd_pins {ps7_0_axi_periph/M09_ARESETN}] [get_bd_pins {ps7_0_axi_periph/M10_ARESETN}] [get_bd_pins {ps7_0_axi_periph/M11_ARESETN}] [get_bd_pins {ps7_0_axi_periph/M12_ARESETN}] [get_bd_pins {ps7_0_axi_periph/M13_ARESETN}] [get_bd_pins {ps7_0_axi_periph/M14_ARESETN}] [get_bd_pins {rgb_memory/ARESETN}] [get_bd_pins {rgb_memory/S00_ARESETN}] [get_bd_pins {rgb_memory/M00_ARESETN}] [get_bd_pins {rgb_memory/S01_ARESETN}] [get_bd_pins {rgb_memory/S02_ARESETN}] [get_bd_pins {face_act_cc/m_axi_aresetn}] [get_bd_pins {face_param_cc/m_axi_aresetn}] [get_bd_pins {axi_mem_intercon_1/S01_ARESETN}] [get_bd_pins {axi_mem_intercon_1/S02_ARESETN}]
connect_bd_net -net {touch_gpio_gpio_io_o} [get_bd_pins {touch_gpio/gpio_io_o}] [get_bd_pins {touch_pins/drive}]
connect_bd_net -net {touch_pins_sense} [get_bd_pins {touch_pins/sense}] [get_bd_pins {touch_gpio/gpio2_io_i}]
connect_bd_net -net {touch_pins_touch_rst} [get_bd_pins {touch_pins/touch_rst}] [get_bd_ports {touch_rst}]
create_bd_addr_seg -range {64K} -offset {0x41200000} [get_bd_addr_spaces {/processing_system7_0/Data}] [get_bd_addr_segs {/axi_gpio_audio/S_AXI/Reg}] {SEG_axi_gpio_audio_Reg}
create_bd_addr_seg -range {64K} -offset {0x41210000} [get_bd_addr_spaces {/processing_system7_0/Data}] [get_bd_addr_segs {/axi_gpio_key/S_AXI/Reg}] {SEG_axi_gpio_key_Reg}
create_bd_addr_seg -range {64K} -offset {0x43000000} [get_bd_addr_spaces {/processing_system7_0/Data}] [get_bd_addr_segs {/axi_vdma_0/S_AXI_LITE/Reg}] {SEG_axi_vdma_0_Reg}
create_bd_addr_seg -range {64K} -offset {0x43010000} [get_bd_addr_spaces {/processing_system7_0/Data}] [get_bd_addr_segs {/axi_vdma_1/S_AXI_LITE/Reg}] {SEG_axi_vdma_1_Reg}
create_bd_addr_seg -range {64K} -offset {0x40090000} [get_bd_addr_spaces {/processing_system7_0/Data}] [get_bd_addr_segs {/face_int8_accel_0/s_axi_control/Reg}] {SEG_face_int8_accel_0_Reg}
create_bd_addr_seg -range {64K} -offset {0x40020000} [get_bd_addr_spaces {/processing_system7_0/Data}] [get_bd_addr_segs {/frame_clock/S_AXI/Reg}] {SEG_frame_clock_Reg}
create_bd_addr_seg -range {64K} -offset {0x41220000} [get_bd_addr_spaces {/processing_system7_0/Data}] [get_bd_addr_segs {/frame_tag_left/S_AXI/Reg}] {SEG_frame_tag_left_Reg}
create_bd_addr_seg -range {64K} -offset {0x41230000} [get_bd_addr_spaces {/processing_system7_0/Data}] [get_bd_addr_segs {/frame_tag_right/S_AXI/Reg}] {SEG_frame_tag_right_Reg}
create_bd_addr_seg -range {64K} -offset {0x40070000} [get_bd_addr_spaces {/processing_system7_0/Data}] [get_bd_addr_segs {/lcd_control/S_AXI/Reg}] {SEG_lcd_control_Reg}
create_bd_addr_seg -range {64K} -offset {0x44A20000} [get_bd_addr_spaces {/processing_system7_0/Data}] [get_bd_addr_segs {/lcd_dma/S_AXI_LITE/Reg}] {SEG_lcd_dma_Reg}
create_bd_addr_seg -range {64K} -offset {0x44A30000} [get_bd_addr_spaces {/processing_system7_0/Data}] [get_bd_addr_segs {/lcd_vtc/ctrl/Reg}] {SEG_lcd_vtc_Reg}
create_bd_addr_seg -range {64K} -offset {0x40030000} [get_bd_addr_spaces {/processing_system7_0/Data}] [get_bd_addr_segs {/photo_arm_left/S_AXI/Reg}] {SEG_photo_arm_left_Reg}
create_bd_addr_seg -range {64K} -offset {0x40050000} [get_bd_addr_spaces {/processing_system7_0/Data}] [get_bd_addr_segs {/photo_arm_right/S_AXI/Reg}] {SEG_photo_arm_right_Reg}
create_bd_addr_seg -range {64K} -offset {0x44A00000} [get_bd_addr_spaces {/processing_system7_0/Data}] [get_bd_addr_segs {/photo_left/S_AXI_LITE/Reg}] {SEG_photo_left_Reg}
create_bd_addr_seg -range {64K} -offset {0x44A10000} [get_bd_addr_spaces {/processing_system7_0/Data}] [get_bd_addr_segs {/photo_right/S_AXI_LITE/Reg}] {SEG_photo_right_Reg}
create_bd_addr_seg -range {64K} -offset {0x40040000} [get_bd_addr_spaces {/processing_system7_0/Data}] [get_bd_addr_segs {/photo_tag_left/S_AXI/Reg}] {SEG_photo_tag_left_Reg}
create_bd_addr_seg -range {64K} -offset {0x40060000} [get_bd_addr_spaces {/processing_system7_0/Data}] [get_bd_addr_segs {/photo_tag_right/S_AXI/Reg}] {SEG_photo_tag_right_Reg}
create_bd_addr_seg -range {64K} -offset {0x40000000} [get_bd_addr_spaces {/processing_system7_0/Data}] [get_bd_addr_segs {/rectify_left/s_axi_control/Reg}] {SEG_rectify_left_Reg}
create_bd_addr_seg -range {64K} -offset {0x40010000} [get_bd_addr_spaces {/processing_system7_0/Data}] [get_bd_addr_segs {/rectify_right/s_axi_control/Reg}] {SEG_rectify_right_Reg}
create_bd_addr_seg -range {64K} -offset {0x40080000} [get_bd_addr_spaces {/processing_system7_0/Data}] [get_bd_addr_segs {/touch_gpio/S_AXI/Reg}] {SEG_touch_gpio_Reg}
create_bd_addr_seg -range {1G} -offset {0x00000000} [get_bd_addr_spaces {/axi_vdma_0/Data_S2MM}] [get_bd_addr_segs {/processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM}] {SEG_processing_system7_0_HP0_DDR_LOWOCM}
create_bd_addr_seg -range {1G} -offset {0x00000000} [get_bd_addr_spaces {/axi_vdma_1/Data_S2MM}] [get_bd_addr_segs {/processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM}] {SEG_processing_system7_0_HP0_DDR_LOWOCM}
create_bd_addr_seg -range {1G} -offset {0x00000000} [get_bd_addr_spaces {/rectify_left/Data_m_axi_memory}] [get_bd_addr_segs {/processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM}] {SEG_processing_system7_0_HP1_DDR_LOWOCM}
create_bd_addr_seg -range {1G} -offset {0x00000000} [get_bd_addr_spaces {/rectify_right/Data_m_axi_memory}] [get_bd_addr_segs {/processing_system7_0/S_AXI_HP2/HP2_DDR_LOWOCM}] {SEG_processing_system7_0_HP2_DDR_LOWOCM}
create_bd_addr_seg -range {1G} -offset {0x00000000} [get_bd_addr_spaces {/photo_left/Data_S2MM}] [get_bd_addr_segs {/processing_system7_0/S_AXI_HP3/HP3_DDR_LOWOCM}] {SEG_processing_system7_0_HP3_DDR_LOWOCM}
create_bd_addr_seg -range {1G} -offset {0x00000000} [get_bd_addr_spaces {/photo_right/Data_S2MM}] [get_bd_addr_segs {/processing_system7_0/S_AXI_HP3/HP3_DDR_LOWOCM}] {SEG_processing_system7_0_HP3_DDR_LOWOCM}
create_bd_addr_seg -range {1G} -offset {0x00000000} [get_bd_addr_spaces {/lcd_dma/Data_MM2S}] [get_bd_addr_segs {/processing_system7_0/S_AXI_HP3/HP3_DDR_LOWOCM}] {SEG_processing_system7_0_HP3_DDR_LOWOCM}
create_bd_addr_seg -range {1G} -offset {0x00000000} [get_bd_addr_spaces {/face_int8_accel_0/Data_m_axi_gmem_act}] [get_bd_addr_segs {/processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM}] {SEG_processing_system7_0_HP1_DDR_LOWOCM}
create_bd_addr_seg -range {1G} -offset {0x00000000} [get_bd_addr_spaces {/face_int8_accel_0/Data_m_axi_gmem_param}] [get_bd_addr_segs {/processing_system7_0/S_AXI_HP1/HP1_DDR_LOWOCM}] {SEG_processing_system7_0_HP1_DDR_LOWOCM}
save_bd_design
validate_bd_design
save_bd_design
write_bd_tcl -force [file join $out {rebuilt_system.tcl}]
generate_target all [get_files system.bd]
set wrapper [make_wrapper -files [get_files system.bd] -top]
add_files -norecurse $wrapper
set_property top system_wrapper [current_fileset]
update_compile_order -fileset sources_1
report_ip_status -file [file join $out {ip_status.rpt}]
puts "FULL_V3_GENERATION_PASS"
close_project
} reason options]} {
 puts stderr "FULL_V3_BUILD_FAILED=$reason"
 puts stderr [dict get $options -errorinfo]
 exit 1
}
exit 0
