`timescale 1ns/1ps
module tb_ext_crc;


reg rx_clk,rx_enable;
reg [7:0] rx_data;

wire [7:0] rawdata;
wire raw_en;

ext_crc uut (
	.rx_clk(rx_clk),
	.rx_data(rx_data),
	.rx_enable(rx_enable),
	.sfd_wait(1'b0), // 0

	.rawdata(rawdata),
	.raw_en(raw_en)
);


localparam CYCLE = 16;
localparam packetsize = 50;
localparam whereis_segment = 5;


task onepacket;
	input [15:0] segment_number;
	input [7:0]  id;
	input [7:0]  aux;

	integer i;
	begin
		rx_enable = 1;
		for (i=0; i < packetsize; i=i+1) begin
			if (i == whereis_segment)
			rx_data = segment_number[15:8];
			else if (i == whereis_segment + 1)
			rx_data = segment_number[7:0];
			else if (i == whereis_segment + 2)
			rx_data = id;
			else if (i == whereis_segment + 5)
			rx_data = aux;
			else if (i >= packetsize - 5)
			rx_data = (i * 15) % 16;
			else rx_data = 8'h55;
			#CYCLE;
		end
		rx_enable = 0;
		rx_data = 8'hxx;
	end
endtask

initial begin
rx_clk = 0;rx_enable = 0; rx_data = 0;
$dumpfile("tb_ext_crc.vcd");
$dumpvars(0,tb_ext_crc);

#(CYCLE*10);
onepacket(2,1,3);
#(CYCLE*7);
onepacket(4,5,6);
#(CYCLE*44);
$finish;
end


always begin
	#2 rx_clk = !rx_clk;
	#6;
end


endmodule