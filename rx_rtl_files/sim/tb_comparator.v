`timescale 1ns / 1ns
`include "./comparator.v"

module tb_comparator;

initial begin
	$dumpfile("comparator.vcd");
	$dumpvars(0,comp);

end

reg clk = 0;
reg [7:0] rxdata;
//reg ssign,esign = 0;
reg en=0;
reg [7:0] bramout;
wire valid,result;
wire shift4_result;

comparator comp(
	.clk(clk),
	.rxdata(rxdata),
	//.start_sign(ssign),
	//.end_sign(esign),
	.en(en),
	.bramout(bramout),
	.valid(valid),
	.result(result),
	.shift4_result(shift4_result)
);

always begin
	clk = !clk;#5;
end

integer i;
integer j;
integer k;
initial begin
for (k=0; k<2; k = k+1) begin
for (j=0; j<7; j = j+1) begin
for (i=0; i < 7; i = i + 1) begin
#10;
en=1'b1;
rxdata = 8'hde;
bramout = 8'hde;
#10;
rxdata = 8'had;
bramout = 8'had;
#10;
rxdata = 8'hbe;
bramout = 8'hbe;
#10;
rxdata = 8'hef;
bramout = 8'hef;
end
for (i=0; i<4+k; i = i+1) begin
#10;
rxdata = 8'haa;
bramout = i%2'b10;

end
#10;
en=1'b0;#120;
end
end

#500;
$finish;
end

/*
#10;	
	//#7;
	//ssign = 1'b1;
	en=1'b1;
	rxdata = 8'hde;
	bramout = 8'had;
	#10;
	//ssign = 1'b0;
	rxdata = 8'had;
	bramout = 8'had;
	#10;
	rxdata = 8'hbe;
	bramout = 8'hbe;
	#10;
	rxdata = 8'hbe;
	bramout = 8'hbf;
	#10;
	//esign = 1'b1;
	en = 1'b0;
	#20;
	//esign = 1'b0;

	#10;
	en = 1'b1;
	//ssign = 1'b1;
	rxdata = 8'hde;
	bramout = 8'hde;
	#10;
	//ssign = 1'b0;
	rxdata = 8'had;
	bramout = 8'had;
	#10;
	rxdata = 8'hbe;
	bramout = 8'hbe;
	#10;
	rxdata = 8'hbe;
	bramout = 8'hbe;
	#10;
	//esign = 1'b1;
	en = 1'b0;
	//esign = 1'b0;

	#10;
	en = 1'b1;
	//ssign = 1'b1;
	rxdata = 8'hde;
	bramout = 8'hde;
	#10;
	//ssign = 1'b0;
	rxdata = 8'had;
	bramout = 8'had;
	#10;
	rxdata = 8'hbe;
	bramout = 8'hbe;
	#10;
	rxdata = 8'hbe;
	bramout = 8'hbe;
	#10;
	//esign = 1'b1;
	en = 1'b0;
	//esign = 1'b0;


	#10;
	en = 1'b1;
	//ssign = 1'b1;
	rxdata = 8'hde;
	bramout = 8'hde;
	#10;
	//ssign = 1'b0;
	rxdata = 8'had;
	bramout = 8'had;
	#10;
	rxdata = 8'hbe;
	bramout = 8'hbe;
	#10;
	rxdata = 8'hbe;
	bramout = 8'hbe;
	#10;
	//esign = 1'b1;
	en = 1'b0;
	//esign = 1'b0;




	#10;
	en = 1'b1;
	//ssign = 1'b1;
	rxdata = 8'hde;
	bramout = 8'hde;
	#10;
	//ssign = 1'b0;
	rxdata = 8'had;
	bramout = 8'had;
	#10;
	rxdata = 8'hbe;
	bramout = 8'hbe;
	#10;
	rxdata = 8'hbe;
	bramout = 8'hbe;
	#10;
	//esign = 1'b1;
	en = 1'b0;
	//esign = 1'b0;

	end 


*/

endmodule