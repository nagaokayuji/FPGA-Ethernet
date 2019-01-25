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
	.redundancy(8'd3),

	.en_out_reg(en_out),
	.data_out_reg(data_out)
);

parameter step = 16;
parameter packetsize = 10;
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
		else if (i == packetsize - 1)
			rxd = 8'hef;
		else rxd = ((seed+3)*packetsize * 33) % 255;
		#step;
	end
	rxen = 0;
	#(step*7);
end
endtask


always begin
	#8 clk = !clk;
	
end

integer j,k,l;
initial begin
	$dumpfile("wf_n2one.vcd");
	$dumpvars(0, tb_n2one);
	clk = 0; rst = 0; rxd = 0; rxen = 0;

	#step;
	rst = 1;
	#step;
	rst = 0;
	#step;
	l=1;
	for (k = 0; k <= 6; k=k+1) begin
		for (j = 1; j <= 5; j=j+1) begin
			onepacket(j,k);
			#(step*5);
		end
		#(step*10);
	end

	#(step*100);
	
	l=2;
	for (k = 0; k <= 6; k=k+1) begin
		for (j = 1; j <= 5; j=j+1) begin
			if (k == j)
			onepacket(j,k*k);
			else
			onepacket(j,k);

			#(step*5);
		end
		#(step*10);
	end
	l=3;

	#(step*100);
// 2 packets loss
	for (k = 0; k <= 7; k=k+1) begin
		for (j = 1; j <= 5; j=j+1) begin
			if (k == j || k == j+1)
			onepacket(j,k*k);
			else 
			onepacket(j,k);
			#(step*5);
		end
		#(step*10);
	end
	l=4;

	#(step*100);
	for (k = 0; k <= 8; k=k+1) begin
		for (j = 1; j <= 5; j=j+1) begin
			if (k == j && k == j+2)
			onepacket(j,k*k);
			else
			onepacket(j,k);
			#(step*5);
		end
		#(step*10);
	end
	#(step*100);
	l=5;
	for (k = 0; k <= 9; k=k+1) begin
		for (j = 1; j <= 5; j=j+1) begin
			if (k != j && k != j+3)
			onepacket(j,k);
			#(step*5);
		end
		#(step*10);
	end
#(step*33);
	$finish;

end
endmodule