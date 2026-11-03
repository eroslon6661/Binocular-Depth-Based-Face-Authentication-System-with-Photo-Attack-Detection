# Vitis 2026.1 XSDB usage: xsdb.bat program_jtag.tcl navigator|ax7020 <package_root> <cable_serial> ?<fresh_jtag_dir>?
if {[catch {
    if {$argc != 3 && $argc != 4} { error "Usage: navigator|ax7020 package_root cable_serial ?fresh_jtag_dir?" }
    lassign $argv role root serial override_dir
    if {$role ni {navigator ax7020}} { error "Unknown role: $role" }
    set root [file normalize $root]
    if {$argc == 4} {
        set images [file normalize $override_dir]
    } else {
        set images [file join $root board $role jtag]
    }
    foreach required {system.bit application.elf ps7_init.tcl} {
        if {![file exists [file join $images $required]]} { error "Missing JTAG input: $required" }
    }
    connect -url TCP:127.0.0.1:3121
    configparams jtag-default-frequency 1000000
    set apu_filter [format {jtag_cable_serial == "%s" && name == "APU"} $serial]
    set cpu_filter [format {jtag_cable_serial == "%s" && name == "ARM Cortex-A9 MPCore #0"} $serial]
    set pl_filter [format {jtag_cable_serial == "%s" && name == "xc7z020"} $serial]
    foreach filter [list $apu_filter $cpu_filter $pl_filter] {
        if {[llength [targets -filter $filter -target-properties]] != 1} {
            error "Expected exactly one target for $filter"
        }
    }
    puts "CHECKED_PROGRAM_BEGIN role=$role"
    targets -set -filter $apu_filter
    rst -system
    after 1000
    targets -set -filter $pl_filter
    fpga -file [file join $images system.bit]
    set pl_after_bit [fpga -state]
    puts "PL_AFTER_BIT=$pl_after_bit"
    if {[string match {*not configured*} $pl_after_bit]} { error "PL configuration failed" }
    targets -set -filter $cpu_filter
    catch {stop}
    source [file join $images ps7_init.tcl]
    ps7_init
    ps7_post_config
    rst -processor
    dow [file join $images application.elf]
    if {$role eq "navigator"} {
        set generation [expr {([clock microseconds] & 0x0fffffff) + 0x10000}]
        mwr 0x09000000 0x4f575631
        mwr 0x09000004 [format 0x%08x $generation]
        mwr 0x09000008 [format 0x%08x [expr {$generation ^ 0xffffffff}]]
    }
    con
    after 10000
    puts "CPU_AFTER_10S=[targets -filter $cpu_filter -target-properties]"
    targets -set -filter $pl_filter
    set pl_after_start [fpga -state]
    puts "PL_AFTER_10S=$pl_after_start"
    if {[string match {*not configured*} $pl_after_start]} { error "PL lost configuration" }
    puts "CHECKED_PROGRAM_COMPLETE=1 ROLE=$role"
    disconnect
} reason]} {
    puts stderr "CHECKED_PROGRAM_FAILED=$reason"
    catch {disconnect}
    exit 1
}
exit 0
