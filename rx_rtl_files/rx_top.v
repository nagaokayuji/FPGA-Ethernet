module rx_top(
	input wire clk100MHz,
	input wire[7:0] switches,
	output wire [7:0] leds,
	input wire rstb,
	input wire btnl,
	input wire resetn,

	// uart
	input wire uart_rxd,
	output wire uart_txd,

	//ethernet
	input wire eth_int_b, //interrupt
	input wire eth_pme_b, //power management event
	output reg eth_rst_b = 0, // reset phy

	output reg eth_mdc = 1'b0,
	inout wire eth_mdio,
	input wire eth_rxck,
	input wire eth_rxctl,
	input wire [3:0] eth_rxd,

	output wire eth_txck,
	output wire eth_txctl,
	output wire [3:0] eth_txd,


	output wire hdmi_tx_clk_n,hdmi_tx_clk_p,
	output wire [2:0] hdmi_tx_n,
	output wire [2:0] hdmi_tx_p
    );
    
    wire eth_rxck_buf;
    BUFG ethclk(
    .I(eth_rxck),
    .O(eth_rxck_buf)
    );
parameter whereisid = 16'd25;
wire RST = !resetn;

reg [26:0] max_count = 27'b0;
reg [26:0] count = 27'b0;
reg [1:0] speed = 2'b11;
reg adv_data = 1'b0;
wire CLK100MHz_buffered;
reg [6:0] de_count = 7'b0;
reg start_sending = 1'b0;
reg [24:0] reset_counter = 25'b0;
reg [5:0] debug = 6'b0;
reg phy_ready = 1'b0;
reg user_data = 1'b0;

//clocking
wire clk50MHz;
wire clk125MHz;
wire clk125MHz90;// for the TX clock
wire clk25MHz;
// wire clkfb;

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

/*
// Control reseting the PHY
*/
// control reset
always @(posedge clk125MHz) begin
	if (reset_counter[24] == 1'b0)
		reset_counter <= reset_counter + 1'b1;
	eth_rst_b <= reset_counter[24] || reset_counter[23];
	phy_ready <= reset_counter[24];
end


wire link_10mb;
wire link_100mb;
wire link_1000mb;
wire link_full_duplex;
wire [7:0] rx_data;
wire rx_valid;
wire rx_enable;
wire rx_error;
// no meanings
rgmii_rx i_rgmii_rx(
	.rx_clk(eth_rxck_buf),
	//.switches5(switches[5]),
	.rx_ctl(eth_rxctl),
	.rx_data(eth_rxd),
	.link_10mb(link_10mb),
	.link_100mb(link_100mb),
	.link_1000mb(link_1000mb),
	.link_full_duplex(link_full_duplex),
	.raw_data(rx_data),
	.data_enable(rx_enable),
	.data_error(rx_error)
	);

wire sfd_wait;
ext_preamble i_ext_preamble (
	.rx_clk(eth_rxck_buf),
	.rx_data(rx_data),
	.rx_enable(rx_enable),
	.sfd_wait(sfd_wait)
	);


wire loss_detected;
wire tmp;

wire en_out;
wire [7:0] data_out;
/*
reg en_out;
reg [7:0] data_out;
*/
rx_majority i_rx_majority (
    .clk(clk100MHz),
    .clk125MHz(clk125MHz),
    .rx_clk(eth_rxck_buf),
	.reset(rstb),
//	.uart_rxd(uart_rxd),
//	.uart_txd(uart_txd),
    .rx_data(rx_data),
    .rx_enable(rx_enable),
    .rx_error(rx_error),
	.sfd_wait(sfd_wait),
	.loss_detected(loss_detected),
	.tmp(tmp),
	.switches(switches),
	.en_out(en_out),
	.data_out(data_out)
   // .gpio_o2(leds[7:4])
    );
//assign  = fourbit_from_mcs;


reg [26:0] count_led = 27'b0;
parameter max_for_led = 27'd71072000;

// LED5: tmp
// tmp : ====================en_out
reg [26:0] count_led3 = 27'b0;
reg led5 = 1'b0;
always @(posedge clk125MHz) begin
if (count_led3 >= max_for_led) begin
    count_led3 <= 27'b0;
    led5 <= 1'b0;
end
else if (tmp || count_led3 > 27'b0) begin
        count_led3 <= count_led3 + 1'b1;
        led5 <= 1'b1;
end
else begin
    count_led3 <= 27'b0;
    led5 <= 1'b0;
end
end

// LED6: LOSS_DETECT 
// LED7: 


reg [26:0] count_led2 = 27'b0;
reg led6 = 1'b0;
reg loss_detected_internal = 1'b0;
always @(posedge clk125MHz) begin
if (count_led2 >= max_for_led) begin
    count_led2 <= 27'b0;
    led6 <= 1'b0;
end
else if (loss_detected || count_led2 > 27'b0) begin
        count_led2 <= count_led2 + 1'b1;
        led6 <= 1'b1;
end
else begin
    count_led2 <= 27'b0;
    led6 <= 1'b0;
end
end

assign leds[5] = led5;
assign leds[6] = led6;



wire clk100MHz_buffered;
BUFG bufg_100(
.I(clk100MHz),
.O(clk100MHz_buffered)
);
// clock
wire clk10MHz;
clocking clocking_i(
    .clk_in1(clk100MHz_buffered),
    .clk_out1(clk125MHz),
    .clk_out2(clk10MHz),
    .clk_out3(clk25MHz),
    .clk_out4(clk125MHz90)
    );


reg [7:0] data_out_reg;
reg en_out_reg;

always @(posedge eth_rxck_buf) begin
    data_out_reg <= data_out;
    en_out_reg <= en_out;
end

wire [31:0] countp,okp;
wire finished,started,valid;
log log_1(
    .rst(RST),
    .rx_en(en_out_reg),
    .rx_data(data_out_reg),
    .clk125MHz(eth_rxck_buf),
    .countp(countp),
    .okp(okp),
    .finished(finished),
    .started(started),
    .valid(valid));

reg [31:0] count_led0 = 0;
reg led0 = 0;
always @(posedge clk125MHz) begin
    if (count_led0 >= max_for_led) begin
        count_led0 <= 27'b0;
        led0 <= 0;
   end
   else if (valid || count_led0 > 0) begin
    count_led0 <= count_led0 + 1;
    led0 <= 1'b1;
    end
    else begin
        count_led0 <= 27'b0;
        led0 <= 1'b0;
    end
 end
 assign leds[0] = led0;
 assign leds[1] = started;
 assign leds[2] = finished;


hdmi_top hdmi_top_i (
    .clk(clk100MHz_buffered),
    .RST(rstb),
    .dclk(eth_rxck_buf),
    .clk125MHz(clk125MHz),
   .data_in(data_out_reg),
   .data_en(en_out_reg),
    .hdmi_tx_clk_n(hdmi_tx_clk_n),
    .hdmi_tx_clk_p(hdmi_tx_clk_p),
    .hdmi_tx_n(hdmi_tx_n),
    .hdmi_tx_p(hdmi_tx_p)
    );




endmodule