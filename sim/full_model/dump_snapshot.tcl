# Usage: xsdb dump_snapshot.tcl OUTPUT_DIRECTORY
# Reads explicitly flushed diagnostic DDR snapshots without stopping either CPU.
if {$argc != 1} {error "usage: dump_snapshot.tcl OUTPUT_DIRECTORY"}
set out [file normalize [lindex $argv 0]]
file mkdir $out
connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_serial == "210512180081" && name == "ARM Cortex-A9 MPCore #0"}
set before [mrd -value 0x1d500000 16]
puts "SNAPSHOT_METADATA=$before"
if {[lindex $before 0] != 0x56455231} {error "No completed snapshot; do not export stale memory"}
set yunet [lindex $before 2]
set mobile [lindex $before 3]
set raw [expr {[lindex $before 5]*[lindex $before 6]}]
set pipeline [lindex $before 7]
if {$yunet != 4746112 || $mobile != 4823680 || $raw > 4194304 || $pipeline != 38268} {error "Unexpected snapshot layout"}
foreach {name address bytes} [list yunet 0x1c000000 $yunet mobile 0x1c800000 $mobile raw_bgr 0x1d000000 $raw pipeline 0x1d400000 $pipeline] {
 puts "EXPORT_BEGIN $name $bytes"
 mrd -bin -file [file join $out ${name}.bin] $address [expr {($bytes+3)/4}]
 puts "EXPORT_DONE $name"
}
set after [mrd -value 0x1d500000 16]
if {$before ne $after} {error "Snapshot changed during export; discard this capture"}
set f [open [file join $out metadata.txt] w]
puts $f $before
close $f
puts "SNAPSHOT_EXPORT_COMPLETE frame=[lindex $before 1]"
disconnect
exit
