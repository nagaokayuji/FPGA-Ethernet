`define use_ddr3

//`define nexys

module rx_top(
`ifdef nexys
	input wire clk100MHz,
`else
    input wire sysclk_n,
    input wire sysclk_p,
`endif
	input wire[7:0] switches,
	output wire [7:0] leds,
	//input wire rstb,
	input wire btnl,
	input wire btnu,
	input wire rstn,
	input wire btnr,
	input wire btnd,
	input wire btnc,

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
	
`ifdef use_ddr3
    //memmory signals
    ,output  [14:0] ddr3_addr,
    output  [2:0] ddr3_ba,
    output  ddr3_cas_n,
    output  ddr3_ck_n,
    output  ddr3_ck_p,
    output  ddr3_cke,
    output  ddr3_ras_n,
    output  ddr3_reset_n,
    output  ddr3_we_n,
    inout   [31:0] ddr3_dq,
    inout   [3:0] ddr3_dqs_n,
    inout   [3:0] ddr3_dqs_p,
    output  ddr3_cs_n,
    output  [3:0] ddr3_dm,
    output  ddr3_odt
 `else
 `endif
	
	);
	parameter SIMULATION = "FALSE";
		wire eth_rxck_buf,eth_rxck_buf_d;
		/*
	BUFG ethclk(
	.I(eth_rxck),
	.O(eth_rxck_buf)
	);
	*/
	make_rx_clk make_rx_clk_i (
	   .eth_rx_clk(eth_rxck_buf),
	   .locked(leds[7]),
	   .eth_rx_in(eth_rxck)
	   );
    assign leds[6:0] = 0;
	/*
	IDELAYE2 #(.IDELAY_TYPE("FIXED"), .IDELAY_VALUE(5))rxcdelay (
	.idatain(eth_rxck_buf),
	.dataout(eth_rxck_buf_d)
	);
	*/
parameter whereisid = 16'd25;
wire RST_raw = !rstn;


wire [31:0] countp,okp;
wire finished,started,valid;
wire [2:0] state_d_e;
wire [31:0] ngp,lostnum;


reg [26:0] max_count = 27'b0;
reg [26:0] count = 27'b0;
reg [1:0] speed = 2'b11;
reg adv_data = 1'b0;
wire CLK100MHz_buffered;
reg [6:0] de_count = 7'b0;
reg start_sending = 1'b0;
reg [24:0] reset_counter = 25'b0;
reg [5:0] debug = 6'b0;
wire phy_ready;
reg user_data = 1'b0;

//clocking
wire clk50MHz;
wire clk125MHz;
wire clk125MHz90;// for the TX clock
wire clk25MHz;
// wire clkfb;
wire clk200MHz;
wire clk400MHz;


wire [7:0] switches_vio;
wire btnl_vio,btnu_vio,RST_vio;
reg [31:0] speed_bps;





vio_0 vio (
.clk(clk125MHz),
.probe_in0(countp),
.probe_in1(okp),
.probe_in2(ngp),
.probe_in3(lostnum),
.probe_in4(speed_bps),
.probe_out0(switches_vio),
.probe_out1(btnl_vio),
.probe_out2(btnu_vio),
.probe_out3(RST_vio)
);



wire [7:0] switches_with_vio = switches ^ switches_vio;
wire btnl_with_vio = btnl ^ btnl_vio;
wire btnu_with_vio = btnu ^ btnu_vio;

wire RST = RST_raw ^ RST_vio;

wire [7:0] redundancy = (switches_with_vio[5:4]==2'b10)? 5 : (switches_with_vio[5:4]==2'b01) ? 3 : (switches_with_vio[5:4]==2'b00)? 1 : 111;
wire [7:0] segment_number_max = (switches_with_vio[7:6] == 2'b00)? 1 : (switches_with_vio[7:6] == 2'b01)? 50 : (switches_with_vio[7:6] == 2'b10) ? 100: 150;


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
    if (RST_vio) reset_counter <= 0;
    else begin
	   if (reset_counter[24] == 1'b0)
	   	   reset_counter <= reset_counter + 1'b1;
	   else reset_counter <= reset_counter;
	end
	eth_rst_b <= ( reset_counter[24] || reset_counter[23] ) ; // 1: reset completed. active low
end
assign phy_ready = !eth_rst_b;



wire link_10mb;
wire link_100mb;
wire link_1000mb;
wire link_full_duplex;
wire [7:0] raw_data_f;
wire rx_valid;
wire rx_enable_f;
wire rx_error;
// no meanings
rgmii_rx i_rgmii_rx(
    .rst(RST),
    .clk125MHz(clk125MHz),
	.rx_clk(eth_rxck_buf),//deleted: _buf
	//.clk200MHz(clk200MHz),
	
	//.switches5(switches[5]),
	.rx_ctl(eth_rxctl),
	.rx_data(eth_rxd),
	.link_10mb(link_10mb),
	.link_100mb(link_100mb),
	.link_1000mb(link_1000mb),
	.link_full_duplex(link_full_duplex),
	.raw_data_f(raw_data_f),
	.data_enable_f(rx_enable_f),
	.data_error(rx_error)
	);


(* mark_debug = "true" *) reg [26:0] cnt_en = 0;
reg [26:0] time_counter = 0;
(* mark_debug = "true" *) wire one_sec = (time_counter == 27'd124999999);
//wire [26:0] next_time_counter = one_sec ? (time_counter + 1'b1) : 0;
always @(posedge clk125MHz) begin
    //time_counter <= next_time_counter;
    if (RST) begin
        cnt_en = 0;
        time_counter = 0;
    end
    else begin
    
    if (one_sec) begin
        speed_bps <= (cnt_en);
        cnt_en <= 0;
        time_counter <= 0;
    end
    else begin
        if (rx_enable_f) begin
         cnt_en <= cnt_en + 1'b1;
        end
        
        time_counter <= time_counter + 1'b1;
    end
    end
end
/*
reg [7:0] eth_rxd_ff1, eth_rxd_ff2, eth_rxd_ff3;
reg eth_en_ff1, eth_en_ff2, eth_en_ff3;

always @(posedge clk125MHz) begin
eth_rxd_ff1 <= rx_data_source;
eth_rxd_ff2 <= eth_rxd_ff1;
eth_rxd_ff3 <= eth_rxd_ff2;

eth_en_ff1 <= rx_enable_source;
eth_en_ff2 <= eth_en_ff1;
eth_en_ff3 <= eth_en_ff2;
end
*/

wire [7:0] rx_data = raw_data_f;
wire rx_enable = rx_enable_f;


wire sfd_wait;
ext_preamble i_ext_preamble (
	.rx_clk(clk125MHz),
	.rx_data(rx_data),
	.rx_enable(rx_enable),
	.sfd_wait(sfd_wait)
	);

wire [7:0] rawdata;
wire raw_en;
ext_crc ext_crc_inst(
	.rx_clk(clk125MHz),
	.rx_data(rx_data),
	.rx_enable(rx_enable),
	.sfd_wait(sfd_wait),
	.rawdata(rawdata),
	.raw_en(raw_en)
);


wire loss_detected;
wire tmp;

wire en_out;
wire [7:0] data_out;
/*
reg en_out;
reg [7:0] data_out;
*/
wire [15:0] seg_out;
rx_majority_wrapper i_rx_majority_wrapper (
	.clk125MHz(clk125MHz),
	.reset(RST),
	.rx_data(rawdata),
	.rx_enable(raw_en),
	.tmp(tmp),
	.redundancy(redundancy),
	.en_out(en_out),
	.seg_out(seg_out),
	.data_out(data_out)
);


reg [26:0] count_led = 27'b0;
parameter max_for_led = 27'd71072000;




wire clk100MHz_buffered;
`ifdef nexys
BUFG bufg_100(
.I(clk100MHz),
.O(clk100MHz_buffered)
);
`else
make_single_clock make_single_clock_i(
    .clk_in1_p(sysclk_p),
    .clk_in1_n(sysclk_n),
    .clk_out1(clk100MHz_buffered),
    .clk200MHz(clk200MHz),
    .clk400MHz(clk400MHz)
   // .clk_out2(clk200MHz)
    );
`endif
// clock
wire clk10MHz;
//wire clk400MHz;
//`ifdef use_ddr3
/*
mig_clocking mig_clk(
.clk_in1_p(sysclk_p),
.clk_in1_n(sysclk_n),
.clk200MHz(clk200MHz)
);
*/

//`else
//`endif

/*
mig_clocking mig_clocking_i (
    .clk_in1_p(sysclk_p),
    .clk_in1_n(sysclk_n),
    .clk200MHz(clk200MHz));
*/
clocking clocking_i(
	.clk_in1(clk100MHz_buffered),
	.clk_out1(clk125MHz),
	.clk_out2(clk10MHz),
	.clk_out3(clk25MHz),
	.clk_out4(clk125MHz90)
//	.clk_out5(clk200MHz),
//	.clk_out6(clk400MHz)
	);

/*
`ifdef use_ddr3
 wire calib_done;

 (* mark_debug = "true" *) wire  [28:0] app_addr;
 (* mark_debug = "true" *) wire  [2:0]  app_cmd;
(* mark_debug = "true" *)  wire  app_en;
(* mark_debug = "true" *)  wire app_rdy;

(* mark_debug = "true" *)  wire  [127:0] app_wdf_data;
(* mark_debug = "true" *)  wire app_wdf_end;
(* mark_debug = "true" *)  wire  app_wdf_wren;
(* mark_debug = "true" *)  wire app_wdf_rdy;

(* mark_debug = "true" *)  wire [127:0] app_rd_data;
(* mark_debug = "true" *)  wire [15:0]  app_wdf_mask;
(* mark_debug = "true" *)  wire app_rd_data_end;
(* mark_debug = "true" *)  wire app_rd_data_valid;

wire app_sr_req = 0;
 wire app_ref_req = 0;
 wire app_zq_req = 0;
 wire app_sr_active;
 wire app_ref_ack;
 wire app_zq_ack;
 
wire ui_clk;
wire ui_clk_sync_rst;

// Instatiation of MIG core named `mem`
 mig_7series_0 memory_interface (
   // DDR3 Physical interface ports
   .ddr3_addr    (ddr3_addr),
   .ddr3_ba      (ddr3_ba),
   .ddr3_cas_n   (ddr3_cas_n),
   .ddr3_ck_n    (ddr3_ck_n),
   .ddr3_ck_p    (ddr3_ck_p),
   .ddr3_cke     (ddr3_cke),
   .ddr3_ras_n   (ddr3_ras_n),
   .ddr3_reset_n (ddr3_reset_n),
   .ddr3_we_n    (ddr3_we_n),
   .ddr3_dq      (ddr3_dq),
   .ddr3_dqs_n   (ddr3_dqs_n),
   .ddr3_dqs_p   (ddr3_dqs_p),
   //.ddr3_cs_n    (ddr3_cs_n),
   .ddr3_dm      (ddr3_dm),
   .ddr3_odt     (ddr3_odt),

   .init_calib_complete (calib_done),

   // User interface ports
   .app_addr     (app_addr),
   .app_cmd      (app_cmd),
   .app_en       (app_en),
   .app_wdf_data (app_wdf_data),
   .app_wdf_end  (app_wdf_end),
   .app_wdf_wren (app_wdf_wren),
   .app_rd_data  (app_rd_data),
   .app_rd_data_end (app_rd_data_end),
   .app_rd_data_valid (app_rd_data_valid),
   .app_rdy      (app_rdy),
   .app_wdf_rdy  (app_wdf_rdy),
   .app_sr_req   (app_sr_req),//0
   .app_ref_req  (app_ref_req),//0
   .app_zq_req   (app_zq_req),//0
   .app_sr_active(app_sr_active),//ignore
   .app_ref_ack  (app_ref_ack),//ignore
   .app_zq_ack   (app_zq_ack),//ignore
   .ui_clk       (ui_clk),
   .ui_clk_sync_rst (ui_clk_sync_rst),
   .app_wdf_mask (app_wdf_mask),
   // Clock and Reset input ports
   .sys_clk_i    (clk400MHz),
   .clk_ref_i (clk200MHz),
   .sys_rst      (!RST)
   );

`else
`endif
*/
`ifdef use_ddr3
    wire            ui_clk;
    wire [255:0]    rd_data;
    wire [255:0]    wr_data;
    wire            rd_busy;
    wire            wr_busy;
    wire            rd_data_valid;
    wire [24:0]      rd_addr;
    wire [24:0]      wr_addr;
    wire             rd_en;
    wire             wr_en;
    
    
    ddr_ram_controller_mig _ddr_ram_control_mig(
        // user interface signals
        .ui_clk         (ui_clk),
        //.ui_clk_sync_rst,
        .wr_addr        (wr_addr),
        .wr_data        (wr_data),
        .rd_addr        (rd_addr),
        .rd_data        (rd_data),
        .wr_en          (wr_en),
        .rd_en          (rd_en),
        .wr_busy        (wr_busy),
        .rd_busy        (rd_busy),
        .rd_data_valid  (rd_data_valid),
        // phy signals
        //.clk_p          (sysclk_p),
        //.clk_n          (sysclk_n),\
        .clk            (clk400MHz),
        .clk_ref         (clk200MHz),
        .rst            (!RST),// active low de OK
        .ddr3_addr      (ddr3_addr),  // output [14:0]        ddr3_addr
        .ddr3_ba        (ddr3_ba),  // output [2:0]        ddr3_ba
        .ddr3_cas_n     (ddr3_cas_n),  // output            ddr3_cas_n
        .ddr3_ck_n      (ddr3_ck_n),  // output [0:0]        ddr3_ck_n
        .ddr3_ck_p      (ddr3_ck_p),  // output [0:0]        ddr3_ck_p
        .ddr3_cke       (ddr3_cke),  // output [0:0]        ddr3_cke
        .ddr3_ras_n     (ddr3_ras_n),  // output            ddr3_ras_n
        .ddr3_reset_n   (ddr3_reset_n),  // output            ddr3_reset_n
        .ddr3_we_n      (ddr3_we_n),  // output            ddr3_we_n
        .ddr3_dq        (ddr3_dq),  // inout [31:0]        ddr3_dq
        .ddr3_dqs_n     (ddr3_dqs_n),  // inout [3:0]        ddr3_dqs_n
        .ddr3_dqs_p     (ddr3_dqs_p),  // inout [3:0]        ddr3_dqs_p
        .ddr3_cs_n      (ddr3_cs_n),  // output [0:0]        ddr3_cs_n
        .ddr3_dm        (ddr3_dm),  // output [3:0]        ddr3_dm
        .ddr3_odt       (ddr3_odt)  // output [0:0]        ddr3_odt
    );

`else
`endif

reg [7:0] data_out_reg;
reg en_out_reg;

always @(posedge clk125MHz) begin
	data_out_reg <= data_out;
	en_out_reg <= en_out;
end


detect_errors2 detect_errors_2 (
	.rst(RST ^ btnu_with_vio),
	.rx_en(en_out_reg),
	.rx_data(data_out_reg),
	.clk(clk125MHz),
	.segment_number_max(segment_number_max),
	.seg(seg_out),
	.count(countp),
	.ok(okp),
	.ng(ngp),
	.lostnum(lostnum),
	.valid(valid),
	.state(state_d_e));


// --- add microblaze here.




hdmi_top hdmi_top_i (
	.clk(clk100MHz_buffered),
	.RST(RST),
	.dclk(clk125MHz),
	.clk125MHz(clk125MHz),
	.data_in(data_out_reg),
	.data_en(en_out_reg),
	.hdmi_tx_clk_n(hdmi_tx_clk_n),
	.hdmi_tx_clk_p(hdmi_tx_clk_p),
	.hdmi_tx_n(hdmi_tx_n),
	.hdmi_tx_p(hdmi_tx_p)
);

/*
design_2_wrapper design2(
.Clk(clk100MHz_buffered),
.resetn(!RST),
.uart_rtl_0_rxd(uart_rxd),
.uart_rtl_0_txd(uart_txd),
.gpio_rtl_0_tri_i(ngp),
.gpio_rtl_1_tri_i(countp),
.interrupt(btnu)
);
*/
//assign leds = switches;

endmodule
