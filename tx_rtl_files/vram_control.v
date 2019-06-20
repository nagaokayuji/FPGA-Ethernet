
module vram_control (
input wire pclk,
input wire clk125MHz,
(* mark_debug = "true" *) input wire ena,
(* mark_debug = "true" *) input wire [15:0] bramaddr24b,
input wire [15:0] vramaddr,
input wire [2:0] vramaddr_c,
input wire [7:0] din_rgb_r,
input wire [7:0] din_rgb_g,
input wire [7:0] din_rgb_b,

output wire [7:0] doutb_first,
output wire [23:0] doutb_rgb
);



wire [7:0] doutb_r;
wire [7:0] doutb_g;
wire [7:0] doutb_b;

wire [7:0] rgb_r = din_rgb_r;
wire [7:0] rgb_g = din_rgb_g;
wire [7:0] rgb_b = din_rgb_b;
assign doutb_rgb = {doutb_r,doutb_g, doutb_b};

assign doutb_first = vramaddr_c == 0? 
			doutb_r: vramaddr_c==1? 
				doutb_g:vramaddr_c==2?
				 doutb_b:0; // ID == 1

vram vram_r(
	.clka(pclk),
	.clkb(clk125MHz),
	.wea(ena),
	.addra(bramaddr24b),
	.addrb(vramaddr),
	.dina(rgb_r),
	.douta(),
	.dinb(8'b0),
	.web(1'b0),
	.doutb(doutb_r)
);

vram vram_g(
	.clka(pclk),
	.clkb(clk125MHz),
	.wea(ena),
	.addra(bramaddr24b),
	.addrb(vramaddr),
	.dina(rgb_g),
	.douta(),
	.dinb(8'b0),
	.web(1'b0),
	.doutb(doutb_g)
);

vram vram_b(
	.clka(pclk),
	.clkb(clk125MHz),
	.wea(ena),
	.addra(bramaddr24b),
	.addrb(vramaddr),
	.dina(rgb_b),
	.douta(),
	.dinb(8'b0),
	.web(1'b0),
	.doutb(doutb_b)
);

endmodule