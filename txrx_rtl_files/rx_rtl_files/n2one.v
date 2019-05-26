module n2one #(parameter whereisid = 0)(
	input wire clk,
	input wire rst,
	input wire [7:0] rxd,
	input wire rxen,
	input wire [7:0] redundancy,
	// output signals
	output reg en_out_reg,
	output reg [7:0] data_out_reg
);

wire en_out;
wire [7:0] data_out;

reg [7:0] rxd_reg;
reg rxen_reg;

always @(posedge clk) begin
	rxd_reg <= rxd;
	rxen_reg <= rxen;

	data_out_reg <= data_out;
	en_out_reg <= en_out;
end


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
bram_compare dpram2(
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

wire [7:0] data_out_5;
wire en_out_5;
wire [35:0] addra5;
wire [35:0] addrb5;
wire [23:0] dina5,douta5,doutb5;
wire [2:0] wea5;
five2one_v2 #(.whereisid(whereisid)) five2one_v2 (
	.clk(clk),
	.rst(rst),
	.rxen(rxen_reg),
	.rxd(rxd_reg),
	.data_out(data_out_5),
	.en_out(en_out_5),

	// BRAMs
	.dina(dina5),
	.douta(douta),
	.doutb(doutb),
	.addra(addra5),
	.addrb(addrb5),
	.wea(wea5)
);

// r=3
wire [7:0] data_out_3;
 wire en_out_3;
wire [35:0] addra3;
wire [35:0] addrb3;
wire [23:0] dina3,douta3,doutb3;
wire [2:0] wea3;
assign doutb3 = doutb;
assign douta3 = douta;
three2one_v2 #(.whereisid(whereisid))three2one_v2 (
	.clk(clk),
	.rst(rst),
	.rxen(rxen_reg),
	.rxd(rxd_reg),
	.data_out(data_out_3),
	.en_out(en_out_3),

	// BRAMs
	.dina(dina3),
	.douta(douta3),
	.doutb(doutb3),
	.addra(addra3),
	.addrb(addrb3),
	.wea(wea3)
);
assign {dina,addra,addrb,wea} = (redundancy == 3) ? 
		{dina3, addra3,addrb3,wea3} :
				{dina5,addra5,addrb5,wea5};

// r == 1
wire [7:0] data_out_1;
wire en_out_1,loss_detected_1;
one2one #(.whereisid(whereisid)) one2one_inst(
.clk(clk),
.clk125MHz(clk),
.rst(rst),
.rx_en_w(rxen_reg),//rx_enable && ~sfd_wait
.rxdata_w(rxd_reg),
.data_out(data_out_1),
.en_out(en_out_1)
);
assign {data_out,en_out} = (redundancy == 1) ?
		{data_out_1, en_out_1} : (redundancy == 3) ?
			{data_out_3, en_out_3} : (redundancy == 5) ?
				{data_out_5, en_out_5} : 0;




endmodule