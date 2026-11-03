# Navigator ES8388 pins, identical to the baseline voice_pin.xdc.
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33} [get_ports aud_iic_scl_io]
set_property -dict {PACKAGE_PIN F17 IOSTANDARD LVCMOS33} [get_ports aud_iic_sda_io]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33} [get_ports aud_mclk]
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports aud_bclk]
set_property -dict {PACKAGE_PIN L20 IOSTANDARD LVCMOS33} [get_ports aud_lrc]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports aud_dacdat]
