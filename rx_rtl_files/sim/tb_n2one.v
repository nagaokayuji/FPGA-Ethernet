`timescale 1ns / 1ps
module tb_n2one;


reg clk,rst,rxen;
reg [7:0] rxd;

wire loss,en_out;
wire [7:0] data_out;
n2one uut(
	.clk(clk),
	.rst(rst),
	.rxd(rxd),
	.rxen(rxen),
	.redundancy(8'd5),

	.loss_detected(loss),
	.en_out(en_out),
	.data_out(data_out)
);

parameter step = 16;
parameter packetsize = 30;
parameter whereisid = 0;
integer i;
task onepacket;
	input [7:0] id;
	input [31:0] seed;
begin
	#step;
	rxen = 1;
	for (i=0; i<packetsize; i=i+1) begin
		if (i==whereisid)
			rxd = id;
		else rxd = ((seed+3)*packetsize * 33) % 255;
		#step;
	end
	rxen = 0;
	#step;
end
endtask


always begin
	#2 clk = !clk;
	#6;
end

initial begin
	$dumpfile("wf_n2one.vcd");
	$dumpvars(0, tb_n2one);
	clk = 0; rst = 0; rxd = 0; rxen = 0;

	#step;

	onepacket(1,22);
	#step;
	onepacket(2,22);

	#step;
	onepacket(3,22);
	#step;
	onepacket(4,22);

	#1000;
	$finish;

end
endmodule