#Clock Signal
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS33} [get_ports clk100MHz]

## LEDs
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS25} [get_ports {leds[0]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS25} [get_ports {leds[1]}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS25} [get_ports {leds[2]}]
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS25} [get_ports {leds[3]}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS25} [get_ports {leds[4]}]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS25} [get_ports {leds[5]}]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS25} [get_ports {leds[6]}]
set_property -dict {PACKAGE_PIN Y13 IOSTANDARD LVCMOS25} [get_ports {leds[7]}]

# Buttons
set_property -dict {PACKAGE_PIN B22 IOSTANDARD LVCMOS12} [get_ports rstb]
#set_property -dict { PACKAGE_PIN D22 IOSTANDARD LVCMOS12 } [get_ports { btnd }]; #IO_L22N_T3_16 Sch=btnd
set_property -dict {PACKAGE_PIN C22 IOSTANDARD LVCMOS12} [get_ports btnl]
#set_property -dict { PACKAGE_PIN D14 IOSTANDARD LVCMOS12 } [get_ports { btnr }]; #IO_L6P_T0_16 Sch=btnr
#set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS12 } [get_ports { btnu }]; #IO_0_16 Sch=btnu
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS15} [get_ports resetn]


#Switches
set_property -dict {PACKAGE_PIN E22 IOSTANDARD LVCMOS12} [get_ports {switches[0]}]
set_property -dict {PACKAGE_PIN F21 IOSTANDARD LVCMOS12} [get_ports {switches[1]}]
set_property -dict {PACKAGE_PIN G21 IOSTANDARD LVCMOS12} [get_ports {switches[2]}]
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS12} [get_ports {switches[3]}]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS12} [get_ports {switches[4]}]
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS12} [get_ports {switches[5]}]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS12} [get_ports {switches[6]}]
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS12} [get_ports {switches[7]}]

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

# UART
#set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports uart_rxd]
set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports uart_rxd]
#set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports uart_rxd]
#set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports uart_rxd]
#set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports uart_rxd]
#set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports uart_rxd]
#//set_property -dict { PACKAGE_PIN AA19  IOSTANDARD LVCMOS33 } [get_ports { uart_rxd }]; #IO_L15P_T2_DQS_RDWR_B_14 Sch=uart_rx_out
#set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33} [get_ports uart_txd]
set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33} [get_ports uart_txd]
#set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33} [get_ports uart_txd]
#set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33} [get_ports uart_txd]
#set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33} [get_ports uart_txd]
#set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33} [get_ports uart_txd]
#//set_property -dict { PACKAGE_PIN V18   IOSTANDARD LVCMOS33 } [get_ports { uart_txd }]; #IO_L14P_T2_SRCC_14 Sch=uart_tx_in





set_property -dict {PACKAGE_PIN U1 IOSTANDARD TMDS_33} [get_ports hdmi_tx_clk_n]
set_property -dict {PACKAGE_PIN T1 IOSTANDARD TMDS_33} [get_ports hdmi_tx_clk_p]
#set_property -dict { PACKAGE_PIN AB13  IOSTANDARD LVCMOS25 } [get_ports { hdmi_tx_hpd }]; #IO_L3N_T0_DQS_13 Sch=hdmi_tx_hpd
#set_property -dict { PACKAGE_PIN U3    IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_rscl }]; #IO_L6P_T0_34 Sch=hdmi_tx_rscl
#set_property -dict { PACKAGE_PIN V3    IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_rsda }]; #IO_L6N_T0_VREF_34 Sch=hdmi_tx_rsda
set_property -dict {PACKAGE_PIN Y1 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_n[0]}]
set_property -dict {PACKAGE_PIN W1 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_p[0]}]
set_property -dict {PACKAGE_PIN AB1 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_n[1]}]
set_property -dict {PACKAGE_PIN AA1 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_p[1]}]
set_property -dict {PACKAGE_PIN AB2 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_n[2]}]
set_property -dict {PACKAGE_PIN AB3 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_p[2]}]

create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk100MHz]
create_clock -period 8.000 -name eth_rx_clk_pin -waveform {0.000 4.000} -add [get_ports eth_rxck]

#
#========================================================================================================
#  DEBUG
#========================================================================================================









connect_debug_port u_ila_0/probe8 [get_nets [list {i_rgmii_rx/data_fifo_out[0]} {i_rgmii_rx/data_fifo_out[1]} {i_rgmii_rx/data_fifo_out[2]} {i_rgmii_rx/data_fifo_out[3]} {i_rgmii_rx/data_fifo_out[4]} {i_rgmii_rx/data_fifo_out[5]} {i_rgmii_rx/data_fifo_out[6]} {i_rgmii_rx/data_fifo_out[7]}]]
connect_debug_port u_ila_0/probe10 [get_nets [list {i_rgmii_rx/raw_data[0]} {i_rgmii_rx/raw_data[1]} {i_rgmii_rx/raw_data[2]} {i_rgmii_rx/raw_data[3]} {i_rgmii_rx/raw_data[4]} {i_rgmii_rx/raw_data[5]} {i_rgmii_rx/raw_data[6]} {i_rgmii_rx/raw_data[7]}]]
connect_debug_port u_ila_0/probe18 [get_nets [list {i_rx_majority_wrapper/genblk1[0].rx_majority_inst/three2one_inst/compares[0]} {i_rx_majority_wrapper/genblk1[0].rx_majority_inst/three2one_inst/compares[1]} {i_rx_majority_wrapper/genblk1[0].rx_majority_inst/three2one_inst/compares[2]}]]
connect_debug_port u_ila_0/probe21 [get_nets [list i_rgmii_rx/data_enable]]
connect_debug_port u_ila_0/probe23 [get_nets [list i_rgmii_rx/en_fifo_out]]



connect_debug_port u_ila_0/probe4 [get_nets [list {i_rx_majority_wrapper/genblk1[2].rx_majority_inst/three2one_inst/compares[0]} {i_rx_majority_wrapper/genblk1[2].rx_majority_inst/three2one_inst/compares[1]} {i_rx_majority_wrapper/genblk1[2].rx_majority_inst/three2one_inst/compares[2]}]]
connect_debug_port u_ila_0/probe5 [get_nets [list {i_rx_majority_wrapper/genblk1[4].rx_majority_inst/three2one_inst/compares[0]} {i_rx_majority_wrapper/genblk1[4].rx_majority_inst/three2one_inst/compares[1]} {i_rx_majority_wrapper/genblk1[4].rx_majority_inst/three2one_inst/compares[2]}]]
connect_debug_port u_ila_0/probe7 [get_nets [list {i_rx_majority_wrapper/genblk1[1].rx_majority_inst/three2one_inst/compares[0]} {i_rx_majority_wrapper/genblk1[1].rx_majority_inst/three2one_inst/compares[1]} {i_rx_majority_wrapper/genblk1[1].rx_majority_inst/three2one_inst/compares[2]}]]
connect_debug_port u_ila_0/probe11 [get_nets [list {i_rx_majority_wrapper/genblk1[3].rx_majority_inst/three2one_inst/compares[0]} {i_rx_majority_wrapper/genblk1[3].rx_majority_inst/three2one_inst/compares[1]} {i_rx_majority_wrapper/genblk1[3].rx_majority_inst/three2one_inst/compares[2]}]]



connect_debug_port u_ila_0/probe7 [get_nets [list {i_rx_majority_wrapper/genblk1[0].rx_majority_inst/three2one_inst/compares[0]} {i_rx_majority_wrapper/genblk1[0].rx_majority_inst/three2one_inst/compares[1]} {i_rx_majority_wrapper/genblk1[0].rx_majority_inst/three2one_inst/compares[2]}]]


connect_debug_port u_ila_0/probe15 [get_nets [list i_rgmii_rx/matte_rise]]


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
connect_debug_port u_ila_0/probe0 [get_nets [list {detect_errors_i/aux_prev[0]} {detect_errors_i/aux_prev[1]} {detect_errors_i/aux_prev[2]} {detect_errors_i/aux_prev[3]} {detect_errors_i/aux_prev[4]} {detect_errors_i/aux_prev[5]} {detect_errors_i/aux_prev[6]} {detect_errors_i/aux_prev[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 8 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {detect_errors_i/rx_data[0]} {detect_errors_i/rx_data[1]} {detect_errors_i/rx_data[2]} {detect_errors_i/rx_data[3]} {detect_errors_i/rx_data[4]} {detect_errors_i/rx_data[5]} {detect_errors_i/rx_data[6]} {detect_errors_i/rx_data[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 8 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {i_rx_majority_wrapper/aux_fordebug[0]} {i_rx_majority_wrapper/aux_fordebug[1]} {i_rx_majority_wrapper/aux_fordebug[2]} {i_rx_majority_wrapper/aux_fordebug[3]} {i_rx_majority_wrapper/aux_fordebug[4]} {i_rx_majority_wrapper/aux_fordebug[5]} {i_rx_majority_wrapper/aux_fordebug[6]} {i_rx_majority_wrapper/aux_fordebug[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 12 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {i_rx_majority_wrapper/count_edge[0]} {i_rx_majority_wrapper/count_edge[1]} {i_rx_majority_wrapper/count_edge[2]} {i_rx_majority_wrapper/count_edge[3]} {i_rx_majority_wrapper/count_edge[4]} {i_rx_majority_wrapper/count_edge[5]} {i_rx_majority_wrapper/count_edge[6]} {i_rx_majority_wrapper/count_edge[7]} {i_rx_majority_wrapper/count_edge[8]} {i_rx_majority_wrapper/count_edge[9]} {i_rx_majority_wrapper/count_edge[10]} {i_rx_majority_wrapper/count_edge[11]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 8 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {detect_errors_i/samecount[0]} {detect_errors_i/samecount[1]} {detect_errors_i/samecount[2]} {detect_errors_i/samecount[3]} {detect_errors_i/samecount[4]} {detect_errors_i/samecount[5]} {detect_errors_i/samecount[6]} {detect_errors_i/samecount[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 8 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {i_rx_majority_wrapper/rxdata[0]} {i_rx_majority_wrapper/rxdata[1]} {i_rx_majority_wrapper/rxdata[2]} {i_rx_majority_wrapper/rxdata[3]} {i_rx_majority_wrapper/rxdata[4]} {i_rx_majority_wrapper/rxdata[5]} {i_rx_majority_wrapper/rxdata[6]} {i_rx_majority_wrapper/rxdata[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 16 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {i_rx_majority_wrapper/segment_num[0]} {i_rx_majority_wrapper/segment_num[1]} {i_rx_majority_wrapper/segment_num[2]} {i_rx_majority_wrapper/segment_num[3]} {i_rx_majority_wrapper/segment_num[4]} {i_rx_majority_wrapper/segment_num[5]} {i_rx_majority_wrapper/segment_num[6]} {i_rx_majority_wrapper/segment_num[7]} {i_rx_majority_wrapper/segment_num[8]} {i_rx_majority_wrapper/segment_num[9]} {i_rx_majority_wrapper/segment_num[10]} {i_rx_majority_wrapper/segment_num[11]} {i_rx_majority_wrapper/segment_num[12]} {i_rx_majority_wrapper/segment_num[13]} {i_rx_majority_wrapper/segment_num[14]} {i_rx_majority_wrapper/segment_num[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 8 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {i_rx_majority_wrapper/rx_id_fordebug[0]} {i_rx_majority_wrapper/rx_id_fordebug[1]} {i_rx_majority_wrapper/rx_id_fordebug[2]} {i_rx_majority_wrapper/rx_id_fordebug[3]} {i_rx_majority_wrapper/rx_id_fordebug[4]} {i_rx_majority_wrapper/rx_id_fordebug[5]} {i_rx_majority_wrapper/rx_id_fordebug[6]} {i_rx_majority_wrapper/rx_id_fordebug[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 8 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {detect_errors_i/aux[0]} {detect_errors_i/aux[1]} {detect_errors_i/aux[2]} {detect_errors_i/aux[3]} {detect_errors_i/aux[4]} {detect_errors_i/aux[5]} {detect_errors_i/aux[6]} {detect_errors_i/aux[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 3 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {detect_errors_i/state[0]} {detect_errors_i/state[1]} {detect_errors_i/state[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list i_rx_majority_wrapper/loss_detected]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list detect_errors_i/rx_en]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list i_rx_majority_wrapper/rx_en]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list i_rx_majority_wrapper/segment_num_en]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list detect_errors_i/valid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list i_rx_majority_wrapper/validation]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk125MHz]
