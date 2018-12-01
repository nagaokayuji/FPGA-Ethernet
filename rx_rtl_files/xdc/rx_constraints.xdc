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
