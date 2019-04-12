#Clock Signal
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports clk100MHz]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk100MHz]

## LEDs
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS25} [get_ports {leds[0]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS25} [get_ports {leds[1]}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS25} [get_ports {leds[2]}]
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS25} [get_ports {leds[3]}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS25} [get_ports {leds[4]}]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS25} [get_ports {leds[5]}]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS25} [get_ports {leds[6]}]
set_property -dict {PACKAGE_PIN Y13 IOSTANDARD LVCMOS25} [get_ports {leds[7]}]

#buttons
set_property -dict {PACKAGE_PIN D22 IOSTANDARD LVCMOS25} [get_ports rstb]


#Switches
set_property -dict {PACKAGE_PIN E22 IOSTANDARD LVCMOS25} [get_ports {switches[0]}]
set_property -dict {PACKAGE_PIN F21 IOSTANDARD LVCMOS25} [get_ports {switches[1]}]
set_property -dict {PACKAGE_PIN G21 IOSTANDARD LVCMOS25} [get_ports {switches[2]}]
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS25} [get_ports {switches[3]}]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS25} [get_ports {switches[4]}]
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS25} [get_ports {switches[5]}]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS25} [get_ports {switches[6]}]
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS25} [get_ports {switches[7]}]


#Ethernet
set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVCMOS25} [get_ports eth_int_b]
set_property -dict {PACKAGE_PIN AA16 IOSTANDARD LVCMOS25} [get_ports eth_mdc]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS25} [get_ports eth_mdio]
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS25} [get_ports eth_pme_b]
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS33} [get_ports eth_rst_b]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS25} [get_ports eth_rxck]
set_property -dict {PACKAGE_PIN W10 IOSTANDARD LVCMOS25} [get_ports eth_rxctl]
set_property -dict {PACKAGE_PIN AB16 IOSTANDARD LVCMOS25} [get_ports {eth_rxd[0]}]
set_property -dict {PACKAGE_PIN AA15 IOSTANDARD LVCMOS25} [get_ports {eth_rxd[1]}]
set_property -dict {PACKAGE_PIN AB15 IOSTANDARD LVCMOS25} [get_ports {eth_rxd[2]}]
set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS25} [get_ports {eth_rxd[3]}]
set_property -dict {PACKAGE_PIN AA14 IOSTANDARD LVCMOS25} [get_ports eth_txck]
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS25} [get_ports eth_txctl]
set_property -dict {PACKAGE_PIN Y12 IOSTANDARD LVCMOS25} [get_ports {eth_txd[0]}]
set_property -dict {PACKAGE_PIN W12 IOSTANDARD LVCMOS25} [get_ports {eth_txd[1]}]
set_property -dict {PACKAGE_PIN W11 IOSTANDARD LVCMOS25} [get_ports {eth_txd[2]}]
set_property -dict {PACKAGE_PIN Y11 IOSTANDARD LVCMOS25} [get_ports {eth_txd[3]}]
create_clock -period 8.000 -name eth_rx_clk_pin -waveform {0.000 4.000} -add [get_ports eth_rxck]

# HDMI in
#set_property -dict { PACKAGE_PIN AA5   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_cec }]; #IO_L10P_T1_34 Sch=hdmi_rx_cec
set_property -dict {PACKAGE_PIN W4 IOSTANDARD TMDS_33} [get_ports hdmi_rx_clk_n]
set_property -dict {PACKAGE_PIN V4 IOSTANDARD TMDS_33} [get_ports hdmi_rx_clk_p]
create_clock -period 12.500 -waveform {0.000 6.250} [get_ports hdmi_rx_clk_p]
set_property -dict {PACKAGE_PIN AB12 IOSTANDARD LVCMOS25} [get_ports hdmi_rx_hpa]
set_property -dict {PACKAGE_PIN Y4 IOSTANDARD LVCMOS33} [get_ports hdmi_rx_scl]
set_property -dict {PACKAGE_PIN AB5 IOSTANDARD LVCMOS33} [get_ports hdmi_rx_sda]
set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports hdmi_rx_txen]
set_property -dict {PACKAGE_PIN AA3 IOSTANDARD TMDS_33} [get_ports {hdmi_rx_n[0]}]
set_property -dict {PACKAGE_PIN Y3 IOSTANDARD TMDS_33} [get_ports {hdmi_rx_p[0]}]
set_property -dict {PACKAGE_PIN Y2 IOSTANDARD TMDS_33} [get_ports {hdmi_rx_n[1]}]
set_property -dict {PACKAGE_PIN W2 IOSTANDARD TMDS_33} [get_ports {hdmi_rx_p[1]}]
set_property -dict {PACKAGE_PIN V2 IOSTANDARD TMDS_33} [get_ports {hdmi_rx_n[2]}]
set_property -dict {PACKAGE_PIN U2 IOSTANDARD TMDS_33} [get_ports {hdmi_rx_p[2]}]


set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]









create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 32768 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 1 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clocking_i/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 8 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {data/data[0]} {data/data[1]} {data/data[2]} {data/data[3]} {data/data[4]} {data/data[5]} {data/data[6]} {data/data[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 24 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {tx_memory_control_i/vramaddr[0]} {tx_memory_control_i/vramaddr[1]} {tx_memory_control_i/vramaddr[2]} {tx_memory_control_i/vramaddr[3]} {tx_memory_control_i/vramaddr[4]} {tx_memory_control_i/vramaddr[5]} {tx_memory_control_i/vramaddr[6]} {tx_memory_control_i/vramaddr[7]} {tx_memory_control_i/vramaddr[8]} {tx_memory_control_i/vramaddr[9]} {tx_memory_control_i/vramaddr[10]} {tx_memory_control_i/vramaddr[11]} {tx_memory_control_i/vramaddr[12]} {tx_memory_control_i/vramaddr[13]} {tx_memory_control_i/vramaddr[14]} {tx_memory_control_i/vramaddr[15]} {tx_memory_control_i/vramaddr[16]} {tx_memory_control_i/vramaddr[17]} {tx_memory_control_i/vramaddr[18]} {tx_memory_control_i/vramaddr[19]} {tx_memory_control_i/vramaddr[20]} {tx_memory_control_i/vramaddr[21]} {tx_memory_control_i/vramaddr[22]} {tx_memory_control_i/vramaddr[23]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 16 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {send_control_i/segment_num_inter[0]} {send_control_i/segment_num_inter[1]} {send_control_i/segment_num_inter[2]} {send_control_i/segment_num_inter[3]} {send_control_i/segment_num_inter[4]} {send_control_i/segment_num_inter[5]} {send_control_i/segment_num_inter[6]} {send_control_i/segment_num_inter[7]} {send_control_i/segment_num_inter[8]} {send_control_i/segment_num_inter[9]} {send_control_i/segment_num_inter[10]} {send_control_i/segment_num_inter[11]} {send_control_i/segment_num_inter[12]} {send_control_i/segment_num_inter[13]} {send_control_i/segment_num_inter[14]} {send_control_i/segment_num_inter[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 2 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {send_control_i/hdmistate[0]} {send_control_i/hdmistate[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 8 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {send_control_i/txid_inter[0]} {send_control_i/txid_inter[1]} {send_control_i/txid_inter[2]} {send_control_i/txid_inter[3]} {send_control_i/txid_inter[4]} {send_control_i/txid_inter[5]} {send_control_i/txid_inter[6]} {send_control_i/txid_inter[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 8 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {send_control_i/aux_inter[0]} {send_control_i/aux_inter[1]} {send_control_i/aux_inter[2]} {send_control_i/aux_inter[3]} {send_control_i/aux_inter[4]} {send_control_i/aux_inter[5]} {send_control_i/aux_inter[6]} {send_control_i/aux_inter[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 4 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {send_control_i/state[0]} {send_control_i/state[1]} {send_control_i/state[2]} {send_control_i/state[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 24 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {tx_memory_control_i/vram_control_i/bramaddr24b[0]} {tx_memory_control_i/vram_control_i/bramaddr24b[1]} {tx_memory_control_i/vram_control_i/bramaddr24b[2]} {tx_memory_control_i/vram_control_i/bramaddr24b[3]} {tx_memory_control_i/vram_control_i/bramaddr24b[4]} {tx_memory_control_i/vram_control_i/bramaddr24b[5]} {tx_memory_control_i/vram_control_i/bramaddr24b[6]} {tx_memory_control_i/vram_control_i/bramaddr24b[7]} {tx_memory_control_i/vram_control_i/bramaddr24b[8]} {tx_memory_control_i/vram_control_i/bramaddr24b[9]} {tx_memory_control_i/vram_control_i/bramaddr24b[10]} {tx_memory_control_i/vram_control_i/bramaddr24b[11]} {tx_memory_control_i/vram_control_i/bramaddr24b[12]} {tx_memory_control_i/vram_control_i/bramaddr24b[13]} {tx_memory_control_i/vram_control_i/bramaddr24b[14]} {tx_memory_control_i/vram_control_i/bramaddr24b[15]} {tx_memory_control_i/vram_control_i/bramaddr24b[16]} {tx_memory_control_i/vram_control_i/bramaddr24b[17]} {tx_memory_control_i/vram_control_i/bramaddr24b[18]} {tx_memory_control_i/vram_control_i/bramaddr24b[19]} {tx_memory_control_i/vram_control_i/bramaddr24b[20]} {tx_memory_control_i/vram_control_i/bramaddr24b[21]} {tx_memory_control_i/vram_control_i/bramaddr24b[22]} {tx_memory_control_i/vram_control_i/bramaddr24b[23]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list tx_memory_control_i/addr_overed]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list tx_memory_control_i/addr_overed_before]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list data/busy]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list data/data_valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list tx_memory_control_i/vram_control_i/ena]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list hdmi_top_i/rgb720to320/enout]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list hdmi_top_i/rgb720to320/i_Hsync]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list hdmi_top_i/rgb720to320/i_Vsync]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list send_control_i/oneframe_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list hdmi_top_i/rgb720to320/start_frame]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list send_control_i/start_sending]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list send_control_i/timer_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list hdmi_top_i/rgb720to320/vde]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk125MHz]
