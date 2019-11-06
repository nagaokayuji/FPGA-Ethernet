`timescale 1ns / 1ps
module tb_rx_majority;

parameter step = 16;
parameter packetsize = 10;
parameter whereisid = 0;


reg clk;
reg rst;
reg rx_clk;
reg [7:0] rxd;
reg rxen;
wire [7:0] data_out;
wire en_out;

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
		else rxd = ((seed+3)*packetsize * 33 + i) % 255;
		#step;
	end
	rxen = 0;
	#(step*7);
end
endtask


integer j,k,l;
rx_majority rx_majority(
    .reset(rst),
    .clk125MHz(clk),
    .rx_data(rxd),
    .rx_enable(rxen),
		.redundancy(8'd5),
		.en_out(en_out),
		.data_out(data_out),
		.loss_detected()
    );
    
		always begin
			#8 clk = !clk;
		end
	
	initial begin
		$dumpfile("wf_tb_rx_majority.vcd");
		$dumpvars(0,tb_rx_majority);
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