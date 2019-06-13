onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /mp2_tb/clk
add wave -noupdate -radix hexadecimal /mp2_tb/pmem_resp
add wave -noupdate -radix hexadecimal /mp2_tb/pmem_read
add wave -noupdate -radix hexadecimal /mp2_tb/pmem_write
add wave -noupdate -radix hexadecimal /mp2_tb/pmem_address
add wave -noupdate -radix hexadecimal /mp2_tb/pmem_wdata
add wave -noupdate -radix hexadecimal /mp2_tb/pmem_rdata
add wave -noupdate -radix hexadecimal /mp2_tb/write_data
add wave -noupdate -radix hexadecimal /mp2_tb/write_address
add wave -noupdate -radix hexadecimal /mp2_tb/write
add wave -noupdate -radix hexadecimal /mp2_tb/halt
add wave -noupdate -radix hexadecimal /mp2_tb/dut/ewb/state
add wave -noupdate -radix hexadecimal -childformat {{{/mp2_tb/dut/cpu/datapath/regfile/data[0]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[1]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[2]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[3]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[4]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[5]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[6]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[7]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[8]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[9]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[10]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[11]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[12]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[13]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[14]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[15]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[16]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[17]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[18]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[19]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[20]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[21]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[22]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[23]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[24]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[25]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[26]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[27]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[28]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[29]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[30]} -radix hexadecimal} {{/mp2_tb/dut/cpu/datapath/regfile/data[31]} -radix hexadecimal}} -subitemconfig {{/mp2_tb/dut/cpu/datapath/regfile/data[0]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[1]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[2]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[3]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[4]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[5]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[6]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[7]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[8]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[9]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[10]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[11]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[12]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[13]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[14]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[15]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[16]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[17]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[18]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[19]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[20]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[21]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[22]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[23]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[24]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[25]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[26]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[27]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[28]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[29]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[30]} {-height 16 -radix hexadecimal} {/mp2_tb/dut/cpu/datapath/regfile/data[31]} {-height 16 -radix hexadecimal}} /mp2_tb/dut/cpu/datapath/regfile/data
add wave -noupdate /mp2_tb/dut/L2_resp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {310656 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 166
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {2459100 ps}
