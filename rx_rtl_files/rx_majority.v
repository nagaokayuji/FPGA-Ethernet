module rx_majority (
  //input wire clk,
  input wire clk125MHz,
  input wire reset,
  //input wire uart_rxd,
  //output wire uart_txd,
 // input wire sfd_wait,
  input wire [7:0] rx_data,
  input wire rx_enable,
 // input wire rx_error,

  output wire loss_detected,
  input wire [7:0] redundancy,
 output wire en_out,
 output wire [7:0] data_out
  );



reg [7:0] rx_data_ff1, rx_data_ff2;
reg rx_enable_ff1, rx_enable_ff2;
always @(posedge clk125MHz) begin
    rx_data_ff1 <= rx_data;
    rx_data_ff2 <= rx_data_ff1;
    
    rx_enable_ff1 <= rx_enable;
    rx_enable_ff2 <= rx_enable_ff1;
end

wire [7:0] rx_data_al = rx_data_ff2;
wire rx_enable_al = rx_enable_ff2;








parameter id_location = 6'h0;


wire [7:0] data_out_1;
wire en_out_1,loss_detected_1;
one2one #(.whereisid(id_location)) one2one_inst(
    .clk(clk125MHz),
    .clk125MHz(clk125MHz),
    .rst(reset),
    .rx_en_w(rx_enable_al),//rx_enable && ~sfd_wait
    .rxdata_w(rx_data_al),
    .data_out(data_out_1),
    .en_out(en_out_1),
    .lost(loss_detected_1)
);

wire [7:0] data_out_3;
wire en_out_3,loss_detected_3;
three2one #(.whereisid(id_location)) three2one_inst(
	.clk(clk125MHz),
	.rst(reset),
	.rx_en_w(rx_enable_al),//rx_enable && ~sfd_wait
	.rxdata_w(rx_data_al),

	.data_out(data_out_3),
	.en_out(en_out_3),
	.lost(loss_detected_3)
);


wire [7:0] data_out_5;
wire en_out_5,loss_detected_5;
five2one #(.whereisid(id_location)) five2one_inst(
	.clk(clk125MHz),
	.rst(reset),
	.rx_en_w(rx_enable_al),//rx_enable && ~sfd_wait
	.rxdata_w(rx_data_al),
	.data_out(data_out_5),
	.en_out(en_out_5),
	.lost(loss_detected_5)
);



wire [7:0] data_out_c = redundancy==1?data_out_1: redundancy==3? data_out_3: redundancy==5? data_out_5:0;
wire en_out_c = redundancy==1? en_out_1: redundancy==3? en_out_3: redundancy==5? en_out_5:0;
wire loss_detected_c = redundancy==1? loss_detected_1: redundancy==3? loss_detected_3: redundancy==5? loss_detected_5:0;

reg [7:0] data_out_ff;
reg en_out_ff,loss_detected_ff;

always @(posedge clk125MHz) begin
    data_out_ff <= data_out_c;
    en_out_ff <= en_out_c;
    loss_detected_ff <= loss_detected_c;
end
assign data_out = data_out_ff;
assign en_out = en_out_ff;
assign loss_detected = loss_detected_ff;


endmodule
