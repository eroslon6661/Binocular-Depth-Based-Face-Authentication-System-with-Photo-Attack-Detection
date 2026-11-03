# Time the second stage normally; constrain only the first Gray synchronizer.
set db_display_gray_src [get_cells -hier -regexp {.*sgbm_result_vdma.*/.*cdc2top_frame_ptr_out_reg\[[0-9]+\]}]
set db_display_gray_dst [get_cells -hier -regexp {.*display_frame_pointer_cdc.*/gray_meta_reg\[[0-9]+\]}]
set_max_delay -datapath_only 7.0 -from $db_display_gray_src -to $db_display_gray_dst
set_bus_skew 7.0 -from $db_display_gray_src -to $db_display_gray_dst
