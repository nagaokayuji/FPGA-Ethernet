module rx_majority (
  input wire clk,
  input wire clk125MHz,
  input wire reset,
  //input wire uart_rxd,
  //output wire uart_txd,
  input wire rx_clk,
 // input wire sfd_wait,
  input wire [7:0] rx_data,
  input wire rx_enable,
 // input wire rx_error,
  output wire tmp, // connected to led[5] // en_out
  (* mark_debug = "true" *) output wire loss_detected,
  input wire [5:0] switches,
 (* mark_debug = "true" *) output wire en_out,
 (* mark_debug = "true" *) output wire [7:0] data_out
  );













parameter id_location = 6'h22;
wire [2:0] redundancy = switches[5:4]==0? 1: switches[5:4]==1? 3 : switches[5:4]== 2 ? 5:0;


wire [7:0] data_out_1;
wire en_out_1,loss_detected_1;
one2one one2one_inst(
    .clk(rx_clk),
    .clk125MHz(clk125MHz),
    .rst(reset),
    .rx_en_w(rx_enable),//rx_enable && ~sfd_wait
    .rxdata_w(rx_data),
    .data_out(data_out_1),
    .en_out(en_out_1),
    .lost(loss_detected_1)
);

wire [7:0] data_out_3;
wire en_out_3,loss_detected_3;
three2one #(.whereisid(id_location)) three2one_inst(
	.clk(rx_clk),
	.clk125MHz(clk125MHz),
	.rst(reset),
	.rx_en_w(rx_enable),//rx_enable && ~sfd_wait
	.rxdata_w(rx_data),

	.data_out(data_out_3),
	.en_out(en_out_3),
	.lost(loss_detected_3)
);


wire [7:0] data_out_5;
wire en_out_5,loss_detected_5;
five2one #(.whereisid(id_location)) five2one_inst(
	.clk(rx_clk),
	.clk125MHz(clk125MHz),
	.rst(reset),
	.rx_en_w(rx_enable),//rx_enable && ~sfd_wait
	.rxdata_w(rx_data),
	.data_out(data_out_5),
	.en_out(en_out_5),
	.lost(loss_detected_5)
);



assign data_out = redundancy==1?data_out_1: redundancy==3? data_out_3: redundancy==5? data_out_5:0;
assign en_out = redundancy==1? en_out_1: redundancy==3? en_out_3: redundancy==5? en_out_5:0;
assign loss_detected = redundancy==1? loss_detected_1: redundancy==3? loss_detected_3: redundancy==5? loss_detected_5:0;
assign tmp = en_out;


endmodule
