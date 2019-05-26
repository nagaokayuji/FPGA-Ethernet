`timescale 1ns / 1ps

module tb_cnv8to24;

reg [7:0] rx_data;
reg rx_en,dclk;

wire [23:0] addr2vram;
wire [1:0] count;
wire [7:0] data_rgb;
wire wea_r,wea_g,wea_b;

cnv8to24 uut (
	.data8b(rx_data),
	.en(rx_en),
	.dclk(dclk),

	.addr2vram(addr2vram),
	.count(count),
	.data_rgb(data_rgb),
	.wea_r(wea_r),
	.wea_g(wea_g),
	.wea_b(wea_b)
);

parameter packetsize = 33;
parameter whereis_addr = 4;
parameter CYCLE = 16;

task onepacket;
	input [23:0] addr;

	integer i;
	integer j;
	begin
		rx_en = 1'b1;
		for (i = 0; i < packetsize; i = i+1) begin
				case (i)
					0:rx_data = 8'h05;
					1: rx_data = 8'ha8;
					2: rx_data = 0;
					3: rx_data = 0;
					whereis_addr : rx_data = addr[23:16];
					whereis_addr+1: rx_data = addr[15:8];
					whereis_addr+2: rx_data = addr[7:0];
					default: rx_data = ((i+333)*37)%255;
				endcase
			#CYCLE;
		end // end for
		rx_en = 1'b0;
		rx_data = 8'hxx;
	end
endtask

always begin
#3 dclk = !dclk;
#5;
end

initial begin
	$dumpfile("tb_cnv8to24.vcd");
	$dumpvars(0,tb_cnv8to24);
	rx_data = 0;
	rx_en = 0;
	dclk = 0;

#(CYCLE*13);
onepacket(0);
#(CYCLE*10);
onepacket(50);
#(CYCLE*6);
onepacket(100);

#(CYCLE*22);

$finish;
	

end


endmodule