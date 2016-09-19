transcript on

if {[file exists rtl_work]} {
   vdel -lib rtl_work -all
}

vlib rtl_work
vmap work rtl_work

vlog     -work work {../rtl/spiSLave.sv}
vlog     -work work {tb_spiSlave.sv}

vsim -t 1ns -L altera_mf_ver -L work -voptargs="+acc" tb_spiSlave

add wave *

view structure
view signals
run 5 us
wave zoomfull