# Invoked by run_hls.py; arguments use environment because vitis-run has no --tclargs.
set out $::env(DELIVERY_HLS_OUTPUT)
set mode $::env(DELIVERY_HLS_MODE)
if {$mode ni {csim export}} {error "Unknown mode"}
if {[file exists $out]} {error "Output must be new"}
set root [file normalize [file join [file dirname [info script]] ../..]]
set source [file join $root src navigator hardware hls_src]
open_project $out
set_top face_int8_accel
add_files [file join $source face_int8_accel.cpp] -cflags {-DFACE_PARAM_CACHE_IMPL_BRAM=1}
add_files [file join $source reference.cpp]
add_files -tb [file join $source equivalence_tb.cpp] -cflags {-DFACE_PARAM_CACHE_IMPL_BRAM=1}
open_solution -reset solution1
set_part {xc7z020clg400-2}
create_clock -period 10 -name default
csim_design
if {$mode eq "export"} {
    csynth_design
    export_design -format ip_catalog -output [file join $out optimized_ip.zip]
}
exit
