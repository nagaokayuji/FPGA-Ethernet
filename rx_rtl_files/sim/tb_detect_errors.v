`timescale 1ns / 1ps
module tb_detect_errors;

parameter CYCLE = 16;
parameter whereis_aux = 0;
parameter packetsize = 33;
parameter segment_number_max = 16'd50;


reg rx_en=0,clk=0, rst = 0;
reg [7:0] rx_data=0;

wire [31:0] count,ok,ng,lostnum;
wire valid;
wire [2:0] state;
reg [15:0] segment_number;

detect_errors2 #(.whereis_aux(whereis_aux)) detect_errors_i(
	.clk(clk),
	.rst(rst),
	.seg(segment_number),
	.segment_number_max(segment_number_max),
	.rx_en(rx_en),
	.rx_data(rx_data),
	.count(count),
	.ok(ok),
	.ng(ng),
	.lostnum(lostnum),
	.valid(valid),
	.state(state)
);

always begin // create clock 125MHz
	#3 clk = !clk;
	#5;
end

task onepacket;
	input [7:0] aux;

	integer i;
	integer j;
	begin
		rx_en = 1'b1;
		for (i = 0; i < packetsize; i = i+1) begin
				case (i)
					whereis_aux: rx_data = aux;
					default: rx_data = 8'h12;
				endcase
			#CYCLE;
		end // end for
		rx_en = 1'b0;
		rx_data = 8'hxx;
	end
endtask



integer i;
integer j;
integer k;
initial begin
	$dumpfile("tb_detect_errors.vcd");
	$dumpvars(0,tb_detect_errors);

	clk = 0;
	rst = 0;
	rx_en = 0;
	rx_data = 8'hxx;
	#(CYCLE * 2);
	rst = 1;
	#CYCLE;
	rst = 0;
	#(CYCLE * 3);
	#(CYCLE * 30);
	#(CYCLE * 16'hffff);
	for (k=0;k<10;k=k+1) begin
	for (i=0; i<=255; i=i+1) begin
		for (j=0;j<segment_number_max;j=j+1) begin
			segment_number = j;
			if ((k != 2 || k != 5) && j != 2)
			onepacket(i);
			#(CYCLE*10);
		end
		#(CYCLE*3);
	end
	#(CYCLE*9);
	end
	
	

	for (i=0; i<=255; i=i+1) begin
		for (j=0;j<segment_number_max;j=j+1) begin
			segment_number = j;
		
			if (!((i==3&&j>=39) || i==4 || (i==5&&j<13)))
			onepacket(i);
			#(CYCLE*10);
		end
		#(CYCLE*3);
	end
	
	onepacket(2);
	#(CYCLE*10);
	onepacket(1);
	
	

	#(CYCLE*100);


	#(CYCLE*40);
	$finish;
	
	
end


endmodule
