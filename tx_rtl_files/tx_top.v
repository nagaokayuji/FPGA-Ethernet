module tx_top(
	input wire clk100MHz,
	input wire[7:0] switches,
	input wire rstb, // active high
	output wire [7:0] leds,

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
	
	// HDMI in
	input wire hdmi_rx_clk_n,hdmi_rx_clk_p,
	input wire [2:0] hdmi_rx_n,
	input wire [2:0] hdmi_rx_p,
	inout wire hdmi_rx_scl,
	inout wire hdmi_rx_sda,
	output wire hdmi_rx_txen,
	output wire hdmi_rx_hpa
    );
		parameter m = 3;
	  assign hdmi_rx_hpa = 1'b1;
    assign hdmi_rx_txen = 1'b1;
		
wire [2:0] redundancy = {switches[5],switches[4],1'b1}; //3bit, takes value of 1,3,5,7
reg [17:0] counter_samepacket = 18'b0;

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

assign leds[4] = rstb;
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



wire [7:0] raw_data;
wire raw_data_user;
wire raw_data_valid;
wire raw_data_enable;

//reg [7:0] index_clone;
wire [7:0] index_clone;
wire almost_sent;
wire busy;
reg [19:0] startaddr = 0;
wire [19:0] lastaddr;


wire [7:0] with_crc;
wire with_crc_valid;
wire with_crc_enable;


add_crc32 i_add_crc32(
	.clk(clk125MHz),
	.data_in(raw_data),
	.data_valid_in(raw_data_valid),
	.data_enable_in(raw_data_enable),
	.data_out(with_crc),
	.data_valid_out(with_crc_valid),
	.data_enable_out(with_crc_enable)
	);

wire [7:0] fully_framed;
wire fully_framed_valid;
wire fully_framed_enable;
wire fully_framed_err;
add_preamble i_add_preamble(
	.clk(clk125MHz),
	.data_in(with_crc),
	.data_valid_in(with_crc_valid),
	.data_enable_in(with_crc_enable),
	.data_out(fully_framed),
	.data_valid_out(fully_framed_valid),
	.data_enable_out(fully_framed_enable)
	);
rgmii_tx i_rgmii_tx(
	.clk(clk125MHz),
	.clk90(clk125MHz90),
	.phy_ready(1'b1),

	.data(fully_framed),
	.data_valid(fully_framed_valid),
	.data_enable(fully_framed_enable),
	.data_error(1'b0),
	.eth_txck(eth_txck),
	.eth_txctl(eth_txctl),
	.eth_txd(eth_txd)
	);

/*
// Control reseting the PHY
*/
// control reset
always @(posedge clk125MHz) begin
	if (reset_counter[24] == 1'b0)
		reset_counter <= reset_counter + 1'b1;
	eth_rst_b <= reset_counter[24] || reset_counter[23] && !rstb; // 1: resset completed
	phy_ready <= reset_counter[24] && !rstb;
end

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
BUFG bufg_100(
.I(clk100MHz),
.O(clk100MHz_buffered)
);
// clock
clocking clocking_i(
    .clk_in1(clk100MHz_buffered),
    .clk_out1(clk125MHz),
    .clk_out2(clk50MHz),
    .clk_out3(clk25MHz),
    .clk_out4(clk125MHz90)
    );
    
    reg [16:0] max_counter_samepacket = 17'd30;

// define speed & how fast
always @(posedge clk125MHz) begin
	case (switches[3:0])
		4'b0000:	max_count <= 27'd124999999; // 1 pps
		4'b0001:	max_count <= 27'd62499999; // 2 pps
		4'b0010:	max_count <= 27'd12499999; // 10 pps
		4'b0011:	max_count <= 27'd6249999; //20 pps
		4'b0100:	max_count <= 27'd2499999; // 50 pps
		4'b0101:	max_count <= 27'd1249999; //100 pps
		4'b0110:	max_count <= 27'd624999; // 200pps
		4'b0111:	max_count <= 27'd249999; //500 pps
		4'b1000:	max_count <= 27'd124999; // 1000 pps
		4'b1001:	max_count <= 27'd62499; //2000 pps
		4'b1010:	max_count <= 27'd24999; //5000 pps
		4'b1011:	max_count <= 27'd12499; //10000 pps
		4'b1100:	max_count <= 27'd6249; //20000 pps
		4'b1101:	max_count <= 27'd2499; //50000 pps
		4'b1110:	max_count <= 27'd1249; //100000pps
		default:	max_count <= 27'd30; //ok? 
	endcase
	    case (switches[7:6])
        2'b00: max_counter_samepacket = 17'd30;
        2'b01: max_counter_samepacket = 17'd1249;   // 100000 pps
        2'b10: max_counter_samepacket = 17'd12499;  // 10000pps
        2'b11: max_counter_samepacket = 17'd124999; // 1000pps
     endcase
end

// sending logic
// -> how fast??
// added counter_samepacket,mydata(?)
// parameter: redundancy(now: 3)
//reg [10:0] max_counter_samepacket = 11'd30;//prev:1000. if it is too small, does not work


(* mark_debug = "true" *) reg [2:0] send_times = 3'b0;
reg in_sending = 1'b0;
//wire [7:0] index_clone;
//assign index_clone = send_times + 1'b1;
(* mark_debug = "true" *) reg [7:0] txid = 8'b0;// 7/20 logic
assign index_clone = txid;

//===============
// STATE CONTROL
//=====================
reg [3:0] state = 0;
//localparam 

always @(posedge clk125MHz) begin
//if (my_data == 16'hffff || rstb == 1'b1) my_data <= 16'b0; // max


if (in_sending) begin // send frame for redundancy times
	   txid <= send_times;
	//   startaddr <= lastaddr;
/*
	if (send_times == 1'b0) begin
		start_sending <= 1'b0;
		counter_samepacket <= 11'b0;
	end else 
*/
	if (send_times == redundancy) begin

		in_sending <= 1'b0; // end
		start_sending <= 1'b0;
		send_times <= 3'b0;
		counter_samepacket <= 17'b0;
	end
	else if (counter_samepacket >= max_counter_samepacket) begin
	   if (!busy) begin
			start_sending <= 1'b1; // STARTSENDING
			send_times <= send_times + 1'b1; // sending process
			counter_samepacket <= 17'b0;
	   end
	end
	else begin
        counter_samepacket <= counter_samepacket + 1'b1;
        start_sending <= 1'b0;
	end
end // end of if (in_sending)

else if (!busy) begin
	if (count == max_count) begin
		count <= 27'b0;
		send_times <= 1'b0;
		counter_samepacket <= 11'b0;
		//my_data <= my_data + 1'b1;
	
		if (lastaddr >= 57600)// 
			startaddr <= 0;
		else startaddr <= lastaddr;
		in_sending <= 1'b1;
	end else begin
		count <= count + 1'b1; // kokonihaitteru
		start_sending <= 1'b0; 
		in_sending <= 1'b0;
	end
end
end

//========================
// HDMI
//========================
hdmi_top (
	.hdmi_rx_clk_n(hdmi_rx_clk_n),
	.hdmi_rx_clk_p(hdmi_rx_clk_p),
	.hdmi_rx_n(hdmi_rx_n),
	.hdmi_rx_p(hdmi_rx_p),
	.hdmi_rx_scl(hdmi_rx_scl),
	.hdmi_rx_sda(hdmi_rx_sda),
// output
	.ena(ena),
	.bramaddr24b(bramaddr24b),
	.rgb_r(rgb_r),
	.rgb_g(rgb_g),
	.rgb_b(rgb_b)
)

assign leds[5] = vde;
wire [7:0] doutb,dina,doutb_first;
wire [19:0] addrb,addra;
  
//wire [7:0] out_from_vram =doutb;
wire [12:0] count_for_bram;
wire [12:0] count_for_bram_b;
wire [1:0] vramaddr_c;
wire count_for_bram_en;
reg [15:0] m = 0;
byte_data data(
	.clk(clk125MHz),
	.start(start_sending),
	.advance(adv_data),
	.startaddr(startaddr),
	.vramdata(doutb),
	.vramaddr(addrb),
	.vramaddr_c(vramaddr_c),
	.lastaddr(lastaddr),
	.busy(busy),
	.data(raw_data),
	//.mydata(my_data),
	.m(m),
	.index_clone(index_clone),
	.data_user(raw_data_user),
	.data_enable(raw_data_enable),
	.data_valid(raw_data_valid),
	.almost_sent(almost_sent),
	.count_for_bram(count_for_bram), // output
	.count_for_bram_b(count_for_bram_b),
	.count_for_bram_en(count_for_bram_en)
	);


tx_memory_control tx_memory_control_i (
	.pclk(pclk),
	.clk125MHz(clk125MHz),
	.txid(txid),
	.segment_num(), // segment_num,  8bits
	.ena(ena),
	.rgb_r(rgb_r),
	.rgb_g(rgb_g),
	.rgb_b(rgb_b),
	.bramaddr24b(bramaddr24b),
	.vramaddr_c(bramaddr_c),
	.count_for_bram(count_for_bram), // input
	.count_for_bram_b(count_for_bram), // input
	.count_for_bram_en(count_for_bram_en), // 

	// output
	.doutb_first(dtoutb_first),
	.doutb_not_first(doutb_not_first) // txid> 1
);

endmodule