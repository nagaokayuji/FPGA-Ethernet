`timescale 1ns / 1ps
module tb_log;


reg rx_en=0,clk125MHz=0;
reg [7:0] rx_data=0;

wire [31:0] countp,okp;
wire finished,started;

log uut(
	.rx_en(rx_en),
	.clk125MHz(clk125MHz),
	.rx_data(rx_data),
	.countp(countp),
	.okp(okp),
	.finished(finished),
	.started(started)
);

integer i,j,k;

always #10 begin
	clk125MHz <= !clk125MHz;
end

initial begin
	for (j=0;j<80;j=j+1) begin #20;
		rx_en = 1;
		for (i=0;i<30;i=i+1) begin
			if (i==3)
				rx_data=0;
			else if (i==4) 
				rx_data=0;
			else if (i==5)
			if (j<40)
				rx_data = j;
			else
				rx_data = 30;
			else rx_data = 8'hde;
			#20;
		end
		rx_en=0;
		#80;
	end
end
		

endmodule
