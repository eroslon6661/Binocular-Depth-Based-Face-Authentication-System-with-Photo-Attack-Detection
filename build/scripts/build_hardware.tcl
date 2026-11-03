# Vivado 2026.1: project.xpr NEW_REPORT_DIR navigator|ax7020
if {$argc != 3} {error "Usage: project.xpr NEW_REPORT_DIR navigator|ax7020"}
lassign $argv project_file output_dir role
if {$role ni {navigator ax7020}} {error "Unknown role"}
if {![string match 2026.1* [version -short]]} {error "Requires Vivado 2026.1"}
if {[file exists $output_dir]} {error "Output must be new"}
file mkdir $output_dir
open_project $project_file
update_compile_order -fileset sources_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {error "Synthesis failed"}
open_run synth_1
report_utilization -file [file join $output_dir synthesis_utilization.rpt]
close_design
if {$role eq "navigator"} {
    launch_runs impl_1 -to_step opt_design -jobs 4
    wait_on_run impl_1
    set opt_dcp [file join [get_property DIRECTORY [get_runs impl_1]] system_wrapper_opt.dcp]
    if {![file exists $opt_dcp]} {error "opt_design checkpoint missing"}
    close_project
    open_checkpoint $opt_dcp
    create_pblock compact_slices
    resize_pblock [get_pblocks compact_slices] -add {SLICE_X28Y0:SLICE_X113Y149}
    resize_pblock [get_pblocks compact_slices] -add {SLICE_X26Y50:SLICE_X27Y99}
    set cells [get_cells -hierarchical -filter {PRIMITIVE_GROUP == CARRY || PRIMITIVE_GROUP == DMEM || PRIMITIVE_GROUP == FLOP_LATCH || PRIMITIVE_GROUP == LUT || PRIMITIVE_GROUP == MUXFX}]
    if {[llength [get_sites -of_objects [get_pblocks compact_slices] -filter {SITE_TYPE =~ SLICE*}]] > 11970} {error "Slice region exceeds budget"}
    add_cells_to_pblock -quiet -clear_locs [get_pblocks compact_slices] $cells
    set_property IS_SOFT false [get_pblocks compact_slices]
    place_design -directive Explore
    phys_opt_design -directive AggressiveExplore
    route_design -directive Explore
    phys_opt_design -directive AggressiveExplore
} else {
    launch_runs impl_1 -to_step write_bitstream -jobs 4
    wait_on_run impl_1
    if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} {error "Implementation failed"}
    open_run impl_1
}
report_utilization -file [file join $output_dir utilization.rpt]
report_utilization -hierarchical -hierarchical_depth 3 -file [file join $output_dir utilization_hierarchical.rpt]
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 20 -file [file join $output_dir timing_summary.rpt]
report_drc -file [file join $output_dir drc.rpt]
report_bus_skew -warn_on_violation -file [file join $output_dir bus_skew.rpt]
write_checkpoint -force [file join $output_dir system_routed.dcp]
write_bitstream -force [file join $output_dir system.bit]
write_hw_platform -fixed -include_bit -force -file [file join $output_dir system.xsa]
puts "HARDWARE_BUILD_PASS role=$role output=$output_dir"
exit 0
