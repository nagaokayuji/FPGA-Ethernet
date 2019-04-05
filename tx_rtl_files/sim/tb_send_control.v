`timescale 1ns / 1ns
//`include "../send_control.v"
//`include "../max_count_gen.v"


module tb_send_control;

reg clk,busy,rst;
wire [15:0] segment_num;
wire [7:0] txid,txid_inter,aux;
wire start_sending;
reg start_frame, oneframe_done;

send_control uut(
	.clk125MHz(clk),
	.RST(rst),
	.switches(8'b01010000),
//	.switches(8'b01010000),
	.busy(busy),
	.start_frame(start_frame),
	.oneframe_done(oneframe_done),

	// output
	.segment_num_inter(segment_num),
	.txid_inter(txid_inter),
	.aux_inter(aux),
	.redundancy(),
	.start_sending(start_sending)
);

initial begin
	$dumpfile("send_control.vcd");
	$dumpvars(0,tb_send_control);
end

initial begin
	clk = 0;
	busy = 0;
	oneframe_done = 0;
	start_frame = 0;
	rst=0;
	#20;
	start_frame = 1;
	#8;
	start_frame = 0;
	#4000;
	oneframe_done = 1;
	#8;
	oneframe_done = 0;

	#4000;// stop here.
	#20;
	start_frame = 1;
	#8;
	start_frame = 0;
	#4000;
	oneframe_done = 1;
	#8;
	oneframe_done = 0;
	#2000;
	$finish;
end

always #4 begin
	clk <= !clk;
end



endmodule