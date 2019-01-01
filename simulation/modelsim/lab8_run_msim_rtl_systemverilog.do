transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/UIUCFall2018/ECE385/Exp8/Lab8_provided {C:/UIUCFall2018/ECE385/Exp8/Lab8_provided/vga_clk.v}
vlog -vlog01compat -work work +incdir+C:/UIUCFall2018/ECE385/Exp8/Lab8_provided/db {C:/UIUCFall2018/ECE385/Exp8/Lab8_provided/db/vga_clk_altpll.v}
vlog -sv -work work +incdir+C:/UIUCFall2018/ECE385/Exp8/Lab8_provided {C:/UIUCFall2018/ECE385/Exp8/Lab8_provided/VGA_controller.sv}
vlog -sv -work work +incdir+C:/UIUCFall2018/ECE385/Exp8/Lab8_provided {C:/UIUCFall2018/ECE385/Exp8/Lab8_provided/HexDriver.sv}
vlog -sv -work work +incdir+C:/UIUCFall2018/ECE385/Exp8/Lab8_provided {C:/UIUCFall2018/ECE385/Exp8/Lab8_provided/health.sv}
vlog -sv -work work +incdir+C:/UIUCFall2018/ECE385/Exp8/Lab8_provided {C:/UIUCFall2018/ECE385/Exp8/Lab8_provided/frameCounter.sv}
vlog -sv -work work +incdir+C:/UIUCFall2018/ECE385/Exp8/Lab8_provided {C:/UIUCFall2018/ECE385/Exp8/Lab8_provided/platform (4).sv}
vlog -sv -work work +incdir+C:/UIUCFall2018/ECE385/Exp8/Lab8_provided {C:/UIUCFall2018/ECE385/Exp8/Lab8_provided/enemy_health4.sv}
vlog -sv -work work +incdir+C:/UIUCFall2018/ECE385/Exp8/Lab8_provided {C:/UIUCFall2018/ECE385/Exp8/Lab8_provided/enemy4Hit.sv}
vlog -sv -work work +incdir+C:/UIUCFall2018/ECE385/Exp8/Lab8_provided {C:/UIUCFall2018/ECE385/Exp8/Lab8_provided/ball4.sv}
vlog -sv -work work +incdir+C:/UIUCFall2018/ECE385/Exp8/Lab8_provided {C:/UIUCFall2018/ECE385/Exp8/Lab8_provided/Color_Mapper4Sprite.sv}
vlog -sv -work work +incdir+C:/UIUCFall2018/ECE385/Exp8/Lab8_provided {C:/UIUCFall2018/ECE385/Exp8/Lab8_provided/ram.sv}
vlog -sv -work work +incdir+C:/UIUCFall2018/ECE385/Exp8/Lab8_provided {C:/UIUCFall2018/ECE385/Exp8/Lab8_provided/top_level_pball.sv}
vlib lab8_soc
vmap lab8_soc lab8_soc

vlog -sv -work work +incdir+C:/UIUCFall2018/ECE385/Exp8/Lab8_provided {C:/UIUCFall2018/ECE385/Exp8/Lab8_provided/testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -L lab8_soc -voptargs="+acc"  testbench

add wave *
view structure
view signals
run 10000 ns
