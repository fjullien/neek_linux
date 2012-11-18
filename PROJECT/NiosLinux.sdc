# Constrain clock port clk with a 20-ns requirement

create_clock -period 20 [get_ports CLOCK_50]
create_clock -period 40 [get_ports HC_TX_CLK]
create_clock -period 40 [get_ports HC_RX_CLK]

# Automatically apply a generate clock on the output of phase-locked loops (PLLs)
# This command can be safely left in the SDC even if no PLLs exist in the design

derive_pll_clocks

# Create altera_reserved_tck clock

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}]
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}]

# You may see hold time violations to this node in the Quartus® II software if you
# are using an IP product in OpenCore Plus evaluation mode. This hold time violation
# does note occur if you are using the IP with a valid license. This hold time
# violation does not affect device operation.
# http://www.altera.com/support/kdb/solutions/rd11072011_828.html

set_false_path -to [get_registers *|pzdyqx_impl:pzdyqx_impl_inst|FNUJ6967]
set_false_path -from {pzdyqx:nabboc|pzdyqx_impl:pzdyqx_impl_inst|XWDE0671[0]} -to {pzdyqx:nabboc|pzdyqx_impl:pzdyqx_impl_inst|PZMU7345:HHRH5434|ATKJ2101[5]}