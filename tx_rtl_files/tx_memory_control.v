/*
ensure data correctly
*/

module tx_memory_control #(parameter SEGMENT_NUMBER_MAX = 500)
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
	//output wire [7:0] doutb_first,
	//output wire [7:0] doutb_not_first // txid > 1
	output reg [23:0] startaddr = 0,
	output wire [7:0] doutb
);


reg [1:0] data_user_reg = 2'b0;
wire data_user_neg = (data_user_reg == 2'b10);

// ID == 1 -=-=> startaddr -- lastaddr;

always @(posedge clk125MHz) begin
	data_user_reg <= {data_user_reg[0] ,data_user};
	if (data_user_neg && ( txid == redundancy)) begin
		startaddr <= lastaddr;
	end
end


wire [7:0] doutb_r,doutb_g,doutb_b;
wire [7:0] doutb_first;
wire [7:0] doutb_not_first;


// vramaddr_c : selector. r,g,b.
assign doutb_first = vramaddr_c == 0? 
			doutb_r: vramaddr_c==2? 
				doutb_g:vramaddr_c==1?
				 doutb_b:0; // ID == 1

vram vram_r(
	.clka(pclk),
	.clkb(clk125MHz),
	.wea(ena),
	.addra(bramaddr24b),
	.addrb(vramaddr),
	.dina(rgb_r),//in:5bits
	.douta(),
	.dinb(1'b0),
	.web(1'b0),
	.doutb(doutb_r)
);

vram vram_g(
	.clka(pclk),
	.clkb(clk125MHz),
	.wea(ena),
	.addra(bramaddr24b),
	.addrb(vramaddr),
	.dina(rgb_g),//in:5bits
	.douta(),
	.dinb(1'b0),
	.web(1'b0),
	.doutb(doutb_g)//5bits
);

vram vram_b(
	.clka(pclk),
	.clkb(clk125MHz),
	.wea(ena),
	.addra(bramaddr24b),
	.addrb(vramaddr),
	.dina(rgb_b),//in:5bits
	.douta(),
	.dinb(1'b0),
	.web(1'b0),
	.doutb(doutb_b)//5bits
);

// txid >= 2 
wire wea_bram1080 = (txid == 1) && count_for_bram_en;

bram_1080 bram_1080(
	.clka(clk125MHz),
	.wea(wea_bram1080),
	.addra(count_for_bram),
	.dina(doutb_first),
	.clkb(clk125MHz),
	.addrb(count_for_bram_b),
	.doutb(doutb_not_first)
);

/*
//=====================
//-- segment_number
//=====================
ID==1 -> ok.

if (segment_num == i)
	wea_bram_not_one[i] = 1'b1;
else
	wea_bram_not_one[i] = 1'b0;
*/



genvar i;
wire [7:0] doutb_not_one[SEGMENT_NUMBER_MAX - 1 : 0];
wire [0:0] wea_bram_not_one[SEGMENT_NUMBER_MAX - 1 : 0]; 
wire [7:0]  doutb_muxed = doutb_not_one[segment_num];
assign doutb = txid==1? doutb_first: doutb_muxed;


generate
for (i=0; i < SEGMENT_NUMBER_MAX; i = i + 1) begin
	bram_1080 bram_1080_inst(
		.clka(clk125MHz),
		.wea(wea_bram_not_one[i]),
		.addra(count_for_bram),
		.dina(doutb_first),
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
	end else begin
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