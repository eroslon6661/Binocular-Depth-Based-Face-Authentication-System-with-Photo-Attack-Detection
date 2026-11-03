# Red PL_RESET button is an input only in this design, not a fabric reset.
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33 PULLUP true} [get_ports {key[2]}]
