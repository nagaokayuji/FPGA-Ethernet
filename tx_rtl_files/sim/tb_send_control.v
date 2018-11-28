`timescale 1ns / 1ns
//`include "../send_control.v"
//`include "../max_count_gen.v"


module tb_send_control;

reg clk,busy;
wire [15:0] segment_num;
wire [7:0] txid,txid_inter,aux;
wire start_sending;

send_control uut(
	.clk125MHz(clk),
	.switches(8'b01011111),
	.busy(busy),

	.segment_num(segment_num),
	.txid_inter(txid_inter),
	.aux(aux),
	.start_sending(start_sending)
);

initial begin
	$dumpfile("send_control.vcd");
	$dumpvars(0,tb_send_control);
end

initial begin
	clk = 0;
	busy = 0;
	#30000;
	$finish;
end

always #4 begin
	clk <= !clk;
end



endmodule