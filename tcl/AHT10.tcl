
package require ::quartus::project


set_location_assignment PIN_E15 -to rst_n
set_location_assignment PIN_E1 -to clk


set_location_assignment PIN_A4 -to seg_sel[0]
set_location_assignment PIN_B4 -to seg_sel[1]
set_location_assignment PIN_A3 -to seg_sel[2]
set_location_assignment PIN_B3 -to seg_sel[3]
set_location_assignment PIN_A2 -to seg_sel[4]
set_location_assignment PIN_B1 -to seg_sel[5]
set_location_assignment PIN_B7 -to seg_dig[0]
set_location_assignment PIN_A8 -to seg_dig[1]
set_location_assignment PIN_A6 -to seg_dig[2]
set_location_assignment PIN_B5 -to seg_dig[3]
set_location_assignment PIN_B6 -to seg_dig[4]
set_location_assignment PIN_A7 -to seg_dig[5]
set_location_assignment PIN_B8 -to seg_dig[6]
set_location_assignment PIN_A5 -to seg_dig[7]

set_location_assignment PIN_C9 -to scl
set_location_assignment PIN_D9 -to sda

set_location_assignment PIN_M2 -to rx
set_location_assignment PIN_G1 -to tx
