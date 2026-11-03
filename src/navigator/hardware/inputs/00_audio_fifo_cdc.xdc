# Gray-pointer skew assertions remain active across the baseline asynchronous
# audio clock groups (AMD UG903, About Bus Skew Constraints).
# Use implementation-only so registers exist after module synthesis.
set db_audio_write_gray [get_cells -hier -regexp {.*audio_i2s_tx.*/write_gray_reg\[[0-9]+\]}]
set db_audio_write_meta [get_cells -hier -regexp {.*audio_i2s_tx.*/write_meta_reg\[[0-9]+\]}]
set db_audio_read_gray [get_cells -hier -regexp {.*audio_i2s_tx.*/read_gray_reg\[[0-9]+\]}]
set db_audio_read_meta [get_cells -hier -regexp {.*audio_i2s_tx.*/read_meta_reg\[[0-9]+\]}]
set db_control_clock [get_clocks -of_objects [get_pins -of_objects $db_audio_write_gray -filter {REF_PIN_NAME == C}]]
set db_audio_clock [get_clocks -of_objects [get_pins -of_objects $db_audio_write_meta -filter {REF_PIN_NAME == C}]]
set_clock_groups -asynchronous -group $db_control_clock -group $db_audio_clock
# 10 ns is the faster control-clock period; constrain both directions.
set_bus_skew 10.0 -from $db_audio_write_gray -to $db_audio_write_meta
set_bus_skew 10.0 -from $db_audio_read_gray -to $db_audio_read_meta
