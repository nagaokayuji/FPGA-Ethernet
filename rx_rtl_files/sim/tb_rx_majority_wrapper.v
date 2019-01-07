module tb_rx_majority_wrapper;


parameter CYCLE = 16;
parameter packetsize = 55;
parameter whereis_segment = 5;
parameter segment_num_max = 3;
reg clk125MHz,rst,rx_clk,rx_enable;
reg [7:0] rx_data;

wire tmp,loss_detected,en_out;
wire [7:0] data_out;
rx_majority_wrapper #(.whereis_segment_num(whereis_segment), .SEGMENT_NUM_MAX(segment_num_max)) uut (
	.clk125MHz(clk125MHz),
	.reset(rst),
	.rx_clk(rx_clk),
	.rx_data(rx_data),
	.rx_enable(rx_enable),
	.tmp(tmp),
	.loss_detected(loss_detected),
	.redundancy(8'd5),
	.en_out(en_out),
	.data_out(data_out)
);


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
			else if (i == whereis_segment + 3)
			rx_data = aux;
			else rx_data = 8'h55;
			#CYCLE;
		end
		rx_enable = 0;
		rx_data = 8'hxx;
	end
endtask

integer each_id,each_seg,aux;




initial begin
	$dumpfile("tb_rx_majority_wrapper.vcd");
	$dumpvars(0,tb_rx_majority_wrapper);
	clk125MHz=0;rst=0;rx_clk=0;rx_enable=0;rx_data=8'hxx;
	#(CYCLE*2);
	rst = 1;
	#CYCLE;
	rst = 0;
	#CYCLE;

	for (aux = 0; aux < 5; aux = aux + 1) begin
		for (each_id = 1; each_id <= 3; each_id = each_id + 1) begin
			for (each_seg = 0; each_seg < segment_num_max; each_seg = each_seg + 1) begin
				#(CYCLE*10);
				onepacket(each_seg,each_id,aux);
			end
			#(CYCLE*30);
		end
	end

	#(CYCLE*50);
	$finish;

end
always  begin
	#2 rx_clk = !rx_clk;
	#1 clk125MHz = !clk125MHz;
	#5;
end

endmodule