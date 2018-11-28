`timescale 1ns / 1ns

module tb_tx_memory_control;

reg clk,ena,count_for_bram_en,data_user;
reg [7:0] txid,redundancy;
reg [15:0] segment_num;
reg [23:0] bramaddr24b,vramaddr;
reg [1:0] vramaddr_c;
reg [12:0] count_for_bram,count_for_bram_b;

wire [23:0] startaddr;
wire [7:0] doutb;
tx_memory_control uut(
	.pclk(),
	.clk125MHz(clk),
	.txid(txid),
	.segment_num(segment_num),
	.redundancy(redundancy),
	.ena(ena),
	.rgb_r(),
	.rgb_b(),
	.rgb_g(),
	.bramaddr24b(bramaddr24b),
	.vramaddr(vramaddr),
	.vramaddr_c(vramaddr_c),
	.count_for_bram(count_for_bram),
	.count_for_bram_b(count_for_bram_b),
	.count_for_bram_en(count_for_bram_en),
	.data_user(data_user),
	.lastaddr(),
	.startaddr(startaddr),
	.doutb(doutb)
);

initial begin
	clk = 0;
	txid = 0;
	redundancy = 3;

end

always begin
	#4 clk = !clk;
end

endmodule