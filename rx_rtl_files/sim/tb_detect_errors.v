`timescale 1ns / 1ps
module tb_detect_errors;

parameter CYCLE = 16;
parameter whereis_aux = 3;
parameter packetsize = 12;


reg rx_en=0,clk=0, rst = 0;
reg [7:0] rx_data=0;

wire [31:0] count,ok;
wire valid;
wire [2:0] state;

detect_errors #(.whereis_aux(whereis_aux)) detect_errors_i(
	.clk(clk),
	.rst(rst),
	.rx_en(rx_en),
	.rx_data(rx_data),
	.count(count),
	.ok(ok),
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
	begin
		rx_en = 1'b1;
		for (i = 0; i < packetsize; i = i+1) begin
			case (i)
				whereis_aux: rx_data = aux;
				default: rx_data = 8'h99;
			endcase
			#CYCLE;
		end // end for
		rx_en = 1'b0;
		rx_data = 8'hxx;
	end
endtask



integer i;
initial begin
	$dumpfile("tb_detect_errors.vcd");
	$dumpvars(0,detect_errors_i);


	clk = 0;
	rst = 0;
	rx_en = 0;
	rx_data = 8'hxx;
	#(CYCLE * 2);
	rst = 1;
	#CYCLE;
	rst = 0;
	#(CYCLE * 3);

	for (i=0; i<300; i=i+1) begin
		onepacket(i);
		#(CYCLE*10);
	end
	rst = 1;
	#CYCLE;
	rst = 0;
	#CYCLE;
	#(CYCLE*100);

	for (i=5; i<55; i=i+1) begin
		onepacket(i);
		#(CYCLE*10);
	end

	#(CYCLE*40);
	$finish;
	
	
end


endmodule
