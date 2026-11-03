# Existing scaler: low-rate GPIO levels -> cursor_meta -> cursor_sync ->
# frame-boundary latch. Only constrain entry into its ASYNC_REG first stage;
# retain normal timing on both following stages. This bus controls the overlay,
# not the ARM measurement coordinates or DMA addresses.
set db_cursor_src [get_cells -hier -regexp {.*axi_gpio_key.*/.*gpio2_Data_Out_reg\[[0-9]+\].*}]
set db_cursor_dst [get_cells -hier -regexp {.*disparity_roi_scale_0.*/cursor_meta_reg\[[0-9]+\]}]
set_max_delay -datapath_only 7.0 -from $db_cursor_src -to $db_cursor_dst
set_bus_skew 1.0 -from $db_cursor_src -to $db_cursor_dst
