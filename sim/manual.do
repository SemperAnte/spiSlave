transcript on

if {[file exists rtl_work]} {
   vdel -lib rtl_work -all
}

vlib rtl_work
vmap work rtl_work

vlog     -work work {../rtl/spiSync.sv}
vlog     -work work {../rtl/spiCore.sv}
vlog     -work work {../rtl/spiSlave.sv}
vlog     -work work {tb_spiSlave.sv}

vsim -t 1ns -L altera_mf_ver -L work -voptargs="+acc" tb_spiSlave

add wave *

view structure
view signals
run 3 us
wave zoomfull