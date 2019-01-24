module rx_majority (
	input wire clk,
	input wire rst,
	input wire [7:0] rxd,
	input wire rxen,
	input wire [7:0] redundancy,
	// output signals
	output wire loss_detected,
	output wire en_out,
	output wire [7:0] data_out
);

parameter id_location = 6'h0;




// place brams & comparators

wire [35:0] addra;
wire [35:0] addrb;
wire [23:0] dina,douta,doutb;
wire [2:0] wea;

bram_compare dpram1(
	.dina(dina[7:0]),
	.dinb(8'b0),
	.addra(addra[11:0]),
	.addrb(addrb[11:0]),
	.douta(douta[7:0]),
	.doutb(doutb[7:0]),
	.wea(wea[0:0]),
	.web(1'b0),
	.clka(clk),
	.clkb(clk)
);
bram_compare dpram3(
	.dina(dina[15:8]),
	.dinb(8'b0),
	.addra(addra[23:12]),
	.addrb(addrb[23:12]),
	.douta(douta[15:8]),
	.doutb(doutb[15:8]),
	.wea(wea[1:1]),
	.web(1'b0),
	.clka(clk),
	.clkb(clk)
);
bram_compare dpram3(
	.dina(dina[23:16]),
	.dinb(8'b0),
	.addra(addra[35:24]),
	.addrb(addrb[35:24]),
	.douta(douta[23:16]),
	.doutb(doutb[23:16]),
	.wea(wea[2:2]),
	.web(1'b0),
	.clka(clk),
	.clkb(clk)
);
/* use like this?
wire [7:0] dina_0 = dina[7:0], dina_1 = dina[15:8], dina_2 = dina[23:16],
				douta_0 = douta[7:0], douta_1 = douta[15:8], douta_2 = douta[23:16];
*/




// r == 1
wire [7:0] data_out_1;
wire en_out_1,loss_detected_1;
one2one #(.whereisid(id_location)) one2one_inst(
.clk(clk),
.clk125MHz(clk),
.rst(rst),
.rx_en_w(rxen),//rx_enable && ~sfd_wait
.rxdata_w(rxd),
.data_out(data_out_1),
.en_out(en_out_1),
.lost(loss_detected_1)
);


endmodule