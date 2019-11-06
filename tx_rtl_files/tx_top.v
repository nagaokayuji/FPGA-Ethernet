`define difclk;

module tx_top(

`ifdef difclk
    input wire sysclk_n,
    input wire sysclk_p,
`else
	input wire clk100MHz,
`endif
	input wire[7:0] switches,
	input wire rstn, // active low
	input wire btnu,
	output wire [7:0] leds,

	//ethernet
	input wire eth_int_b, //interrupt
	input wire eth_pme_b, //power management event
	output reg eth_rst_b, // reset phy
	output reg eth_mdc = 1'b0,
	inout wire eth_mdio,
	input wire eth_rxck,
	input wire eth_rxctl,
	input wire [3:0] eth_rxd,
	output wire eth_txck,
	output wire eth_txctl,
	output wire [3:0] eth_txd,
	
	 //HDMI out
//		output wire hdmi_tx_clk_n,hdmi_tx_clk_p,
//	output wire [2:0] hdmi_tx_n,
//	output wire [2:0] hdmi_tx_p,
	
	// HDMI in
	input wire hdmi_rx_clk_n,hdmi_rx_clk_p,
	input wire [2:0] hdmi_rx_n,
	input wire [2:0] hdmi_rx_p,
	inout wire hdmi_rx_scl,
	inout wire hdmi_rx_sda,
	//output wire hdmi_rx_txen,
	output wire hdmi_rx_hpa
	);


wire rstb = !rstn;
wire start_frame;
wire oneframe_done;
reg [1:0] speed = 2'b11;
reg adv_data = 1'b0;
wire CLK100MHz_buffered;
reg [6:0] de_count = 7'b0;
reg [24:0] reset_counter = 25'b0;
reg [5:0] debug = 6'b0;
wire phy_ready;
reg user_data = 1'b0;

//clocking
wire clk50MHz;
wire clk125MHz;
wire clk125MHz90;// for the TX clock
wire clk25MHz;

wire [7:0] switches_vio;
wire RST_vio,btnu_vio;
wire [7:0] qos;

vio_0 vio (
  .clk(clk125MHz),
  .probe_out0(switches_vio),// switches
  .probe_out1(RST_vio), // rst
  .probe_out2(btnu_vio),
  .probe_out3(qos)
);

wire [7:0] sw_with_vio = switches ^ switches_vio;
wire rst_with_vio = rstb ^ RST_vio;
wire btnu_with_vio = btnu ^ btnu_vio;
assign leds[4] = rst_with_vio;



always @(posedge clk125MHz) begin
	if (de_count == 7'b0)
		adv_data <= 1'b1;
	else
		adv_data <= 1'b0;

	case (speed)
		2'b00:	de_count <= 7'b1111111;
		2'b01:	begin
				if (de_count > 7'd98) de_count <= 7'b0;
				else de_count <= de_count + 1'b1;
				end
		2'b10:	begin
				if (de_count > 7'd8) de_count <= 7'b0;
				else de_count <= de_count + 1'b1;
				end
		default: de_count <= 7'b0;
	endcase
end

wire [7:0] raw_data;
wire raw_data_user;
wire raw_data_valid;
wire raw_data_enable;
//=====================
// tx module
//===================
ethernet_tx ethernet_tx_i (
	.clk125MHz(clk125MHz),
	.clk125MHz90(clk125MHz90),
	.raw_data(raw_data),
	.raw_data_valid(raw_data_valid),
	.raw_data_enable(raw_data_enable),
	.phy_ready(phy_ready),
	// output
	.eth_txd(eth_txd),
	.eth_txck(eth_txck),
	.eth_txctl(eth_txctl)
);

wire [7:0] index_clone;
wire busy;
wire [15:0] startaddr;
wire [15:0] lastaddr;

/*
// Control reseting the PHY
*/
// control reset
always @(posedge clk125MHz) begin
    if (rst_with_vio) reset_counter <= 0;
    else begin
	   if (reset_counter[24] == 1'b0)
	   	   reset_counter <= reset_counter + 1'b1;
	   else reset_counter <= reset_counter;
	end
	eth_rst_b <= ( reset_counter[24] || reset_counter[23] )  ; // 1: reset completed. active low
end
assign phy_ready = !eth_rst_b;


wire[7:0] rx_fully_framed;
wire rx_fully_framed_valid;
wire rx_fully_framed_enable;
wire rx_fully_framed_err;

wire link_10mb;
wire link_100mb;
wire link_1000mb;
wire link_full_duplex;
rgmii_rx i_rgmii_rx(
	.rx_clk(eth_rxck),
	.rx_ctl(eth_rxctl),
	.rx_data(eth_rxd),
	.link_10mb(link_10mb),
	.link_100mb(link_100mb),
	.link_1000mb(link_1000mb),
	.link_full_duplex(link_full_duplex),
	.data(rx_fully_framed),
	.data_valid(rx_fully_framed_valid),
	.data_enable(rx_fully_framed_enable),
	.data_error(rx_fully_framed_err)
	);
assign leds[0] = link_10mb;
assign leds[1] = link_100mb;
assign leds[2] = link_1000mb;
assign leds[3] = link_full_duplex;

// choose TX speed
always @(posedge clk125MHz) begin
	if (link_1000mb == 1'b1)
		speed <= 2'b11;
	else if (link_100mb == 1'b1)
		speed <= 2'b10;
	else if (link_10mb == 1'b1)
		speed <= 2'b01;
end
wire clk100MHz_buffered;
wire clk200MHz;
`ifdef difclk
make_single_clock make_single_clock_i(
.clk_in1_p(sysclk_p),
.clk_in1_n(sysclk_n),
.clk100MHz(clk100MHz_buffered),
.clk200MHz(clk200MHz)
);
`else
BUFG bufg_100(
	.I(clk100MHz),
	.O(clk100MHz_buffered)
);
`endif
// clock
clocking clocking_i(
	.clk_in1(clk100MHz_buffered),
	.clk_out1(clk125MHz),
	.clk_out2(clk50MHz),
	.clk_out3(clk25MHz),
	.clk_out4(clk125MHz90)
);

//===============
// STATE CONTROL
//=====================
wire [15:0] segment_num;
wire [7:0] txid;
wire [15:0] aux;
wire start_sending;
wire [7:0] redundancy;
wire [15:0] segment_num_max;
wire hdmimode, framemode, maxdetect;
send_control send_control_i (
	.clk125MHz(clk125MHz),
	.RST(rst_with_vio),
	.irst(btnu_with_vio),
	.switches(sw_with_vio),
	.busy(busy),
	.start_frame(start_frame),
	.oneframe_done(oneframe_done),
	.maxdetect(maxdetect),
	
	// output
	.segment_num_inter(segment_num), // segment number
	.txid_inter(txid), // id
	.segment_num_max(segment_num_max),
	.aux_inter(aux), // auxiliary number
	.start_sending(start_sending),
	.hdmimode(hdmimode),
	.framemode(framemode),
	.redundancy(redundancy)
);


//========================
// HDMI
//========================

wire pclk;
wire ena;
wire [23:0] bramaddr24b;
wire [7:0] rgb_r,rgb_g,rgb_b;
hdmi_top hdmi_top_i (
	// clk,rst
	.clk100MHz(clk100MHz_buffered),
	.clk125MHz(clk125MHz),
	.clk200MHz(clk200MHz),
	.rstb(rst_with_vio), // active HIGH
	// hdmi
	.hdmi_rx_clk_n(hdmi_rx_clk_n),
	.hdmi_rx_clk_p(hdmi_rx_clk_p),
	.hdmi_rx_n(hdmi_rx_n),
	.hdmi_rx_p(hdmi_rx_p),
	.hdmi_rx_scl(hdmi_rx_scl),
	.hdmi_rx_sda(hdmi_rx_sda),
// output
    .pclk(pclk),
	.hdmi_rx_hpa(hdmi_rx_hpa),
	//.hdmi_rx_txen(hdmi_rx_txen),
	.ena(ena),
	.bramaddr24b(bramaddr24b),
	.rgb_r(rgb_r),
	.rgb_g(rgb_g),
	.rgb_b(rgb_b),
	.start_frame(start_frame),
	.pclklocked(leds[5])
	
	// HDMI TX
//    .hdmi_tx_clk_n(hdmi_tx_clk_n),
//	.hdmi_tx_clk_p(hdmi_tx_clk_p),
//	.hdmi_tx_n(hdmi_tx_n),
//	.hdmi_tx_p(hdmi_tx_p)
);


wire [7:0] doutb,dina,doutb_first;
//wire [19:0] addrb,addra;
  
//wire [7:0] out_from_vram =doutb;
wire [12:0] count_for_bram;
wire [12:0] count_for_bram_b;
wire [1:0] vramaddr_c;
wire count_for_bram_en;
wire [11:0] byte_data_counter;
reg [15:0] m = 0;
byte_data data(
	.clk(clk125MHz),
	.start(start_sending),
	.advance(adv_data),
	.startaddr(startaddr),
	.vramdata(doutb),
	.qos(qos),
	.busy(busy),
	.data(raw_data),
	//.mydata(my_data),
	.aux(aux), // auxiliary number
	.segment_num(segment_num),
	.index_clone(txid),
	.data_user(raw_data_user),
	.data_enable(raw_data_enable),
	.data_valid(raw_data_valid),
	.counter(byte_data_counter)
	);


tx_memory_control tx_memory_control_i (
	.pclk(pclk),
	.clk125MHz(clk125MHz),
	.rst(rst_with_vio),
	.txid(txid),
	.segment_num(segment_num), // segment_num,  8bits
	.redundancy(redundancy),
	.segment_num_max(segment_num_max),
	.hdmimode(hdmimode),
	//.framemode(framemode),
	.ena(ena),
	.rgb_r(rgb_r),
	.rgb_g(rgb_g),
	.rgb_b(rgb_b),
	.bramaddr24b(bramaddr24b), // input
	.byte_data_counter(byte_data_counter),
	.data_user(raw_data_user),


	// output
	.doutb(doutb),
	.startaddr(startaddr),
	.oneframe_done(oneframe_done),
	.maxdetect(maxdetect)
);

endmodule