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
