/*
ensure data correctly
*/

module tx_memory_control(
	input wire pclk, 	// pixel clock
	input wire clk125MHz, // ethernet tx clock
	input wire txid,  // ID
	input wire [7:0] segment_num, // segment_number. add next
	input wire ena,   // en signal for VRAMs A port
	input wire [7:0] rgb_r, // from hdmi_top
	input wire [7:0] rgb_g, // from hdmi_top
	input wire [7:0] rgb_b, // from hdmi_top
	input wire [23:0] bramaddr24b,
	input wire [2:0] vramaddr_c, // from byte_data
	input wire [12:0] count_for_bram,
	input wire [12:0] count_for_bram_b,
	input wire count_for_bram_en,

	// output
	output wire [7:0] doutb_first,
	output wire [7:0] doutb_not_first // txid > 1
);


wire [7:0] doutb_r,doutb_g,doutb_b;
assign doutb_first = vramaddr_c == 0? 
			doutb_r: vramaddr_c==2? 
				doutb_g:vramaddr_c==1?
				 doutb_b:0; // ID == 1

vram vram_r(
	.clka(pclk),
	.clkb(clk125MHz),
	.wea(ena),
	.addra(bramaddr24b),
	.addrb(addrb),
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
	.addrb(addrb),
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
	.addrb(addrb),
	.dina(rgb_b),//in:5bits
	.douta(),
	.dinb(1'b0),
	.web(1'b0),
	.doutb(doutb_b)//5bits
);

// txid >= 2 
assign doutb = txid==1? doutb_first: doutb_not_first;
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

endmodule