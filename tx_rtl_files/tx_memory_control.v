/*
ensure data correctly
outputs after 3 clocks
*/

module tx_memory_control #(parameter SEGMENT_NUMBER_MAX = 150)
(
	input wire pclk, 	// pixel clock
	input wire clk125MHz, // ethernet tx clock
	input wire [7:0] txid,  // ID
	input wire [15:0] segment_num, // segment_number. add next
	input wire [7:0] redundancy,
	input wire ena,   // en signal for VRAMs A port
	input wire [7:0] rgb_r, // from hdmi_top
	input wire [7:0] rgb_g, // from hdmi_top
	input wire [7:0] rgb_b, // from hdmi_top
	input wire [23:0] bramaddr24b,
	input wire [23:0] vramaddr,
	input wire [2:0] vramaddr_c, // from byte_data
	input wire [12:0] count_for_bram,
	input wire [12:0] count_for_bram_b,
	input wire count_for_bram_en,
	input wire data_user, // use for make startaddr. negedge.
	input wire [23:0] lastaddr,

	// output
	output reg [23:0] startaddr = 0,
	//output reg [7:0] doutb_reg
	output wire [7:0] doutb
);

/*
 new plan.
 a
 

 delete startaddr & lastaddr @ byte_data.
 use count_for_bram LIKE same address for any txid.
 switch automatically @ out of byte_data.
*/


// data_user : from byte_data, active high when data enable
reg [1:0] data_user_reg = 2'b0;

// detect negedge
wire data_user_neg = (data_user_reg == 2'b10);

// ID == 1 -=-=> startaddr -- lastaddr;
always @(posedge clk125MHz) begin
	// shift
	data_user_reg <= {data_user_reg[0] ,data_user};
	if (data_user_neg && ( txid == redundancy)) begin
		startaddr <= lastaddr;
	end
end


wire [7:0] doutb_r,doutb_g,doutb_b;
wire [7:0] doutb_first;
wire [7:0] doutb_not_first;


vram_control vram_control_i(
	.pclk(pclk),
	.clk125MHz(clk125MHz),
	.ena(ena),
	.bramaddr24b(bramaddr24b),
	.vramaddr(vramaddr),
	.vramaddr_c(vramaddr_c),
	.din_rgb_r(rgb_r),
	.din_rgb_g(rgb_g),
	.din_rgb_b(rgb_b),
	.doutb_first(doutb_first),
	.doutb_rgb({doutb_r,doutb_g,doutb_b})
);


// txid >= 2 
// send and save data
wire wea_bram1080 = (txid == 1) && count_for_bram_en;

/*
	count_for_bram: addrb for bram1080.


	<< about latency>>


*/
reg [7:0] doutb_first_reg;
reg [7:0] doutb_not_one_reg[SEGMENT_NUMBER_MAX - 1 : 0];
reg [0:0] wea_bram_not_one_reg[SEGMENT_NUMBER_MAX - 1: 0];
reg [12:0] count_for_bram_reg;

wire [7:0] doutb_not_one[SEGMENT_NUMBER_MAX - 1 : 0];
wire [0:0] wea_bram_not_one[SEGMENT_NUMBER_MAX - 1 : 0]; 
wire [7:0]  doutb_muxed = doutb_not_one_reg[segment_num];

// doutb: 
assign doutb = (txid==1) ? 
				doutb_first_reg: doutb_muxed;

integer m;
always @(posedge clk125MHz) begin
/*
	wea,addra,dina: 1 clock delay
*/
	for (m = 0; m < SEGMENT_NUMBER_MAX; m = m + 1) begin
		doutb_not_one_reg[m] <= doutb_not_one[m];
		wea_bram_not_one_reg[m] <= wea_bram_not_one[m];
	end
	count_for_bram_reg <= count_for_bram;
	doutb_first_reg <= doutb_first;
end

genvar i;
generate
	for (i=0; i < SEGMENT_NUMBER_MAX; i = i + 1) begin
		bram_1080 bram_1080_inst(
			.clka(clk125MHz),
			.wea(wea_bram_not_one_reg[i]),
			.addra(count_for_bram_reg),
			.dina(doutb_first_reg),
			.clkb(clk125MHz),
			.addrb(count_for_bram_b),
			.doutb(doutb_not_one[i])
		);
	end
endgenerate

function dmux;
	input [15:0] j;
	input [15:0] segment_num;
	input wea;
		if (j == segment_num) begin
			dmux = wea;
		end 
		else begin
			dmux = 1'b0;
		end
endfunction

genvar k;
generate
	for (k = 0; k < SEGMENT_NUMBER_MAX; k = k + 1) begin
		assign wea_bram_not_one[k] = dmux(k,segment_num,wea_bram1080);
	end
endgenerate


endmodule