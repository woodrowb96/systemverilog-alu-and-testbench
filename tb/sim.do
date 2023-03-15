add wave -radix decimal sim:/tb_top/i_intf/clk
add wave -radix decimal sim:/tb_top/i_intf/reset
add wave -radix decimal sim:/tb_top/i_intf/alu_op
add wave -radix decimal sim:/tb_top/i_intf/in_a
add wave -radix decimal sim:/tb_top/i_intf/in_b
add wave -radix decimal sim:/tb_top/i_intf/result

config wave -signalnamewidth 1
run -all

