`timescale 1ns / 1ns
module tb_five2one;

reg clk,rst,rx_en;
reg [7:0] rxdata;
wire [7:0] out1,out2;
//wire [11:0] out3;

initial
  begin
      // wave.vcd という名前で波形データファイルを出力
      $dumpfile("wf_five2one.vcd");
      // 全てのポートを波形データに含める
      $dumpvars(0, tb_five2one);
      // シミュレータ実行時に counter_1 のポート COUNT を
      // モニタする（値が変化した時に表示）
      $monitor(rxdata,": %h %h %h %b", rxdata,out1,out2,rx_en);
	end

//wire comp_result1,comp_result2,comp_valid1,comp_valid2;
wire lost,en_out;
wire [7:0] data_out;
wire [3:0] rx_id;
wire [3:0] rx_id_inter;
wire [2:0] comp3bit;
reg [3:0] switches = 4'b1;
reg clk125MHz;
//reg [11:0] addr_b = 12'b0;
parameter whereis_id = 0;
five2one #(.whereisid(whereis_id)) uut (
	.clk(clk),
	.rst(rst),
	.rx_en_w(rx_en),
	.rxdata_w(rxdata),
	.en_out(en_out),
	//.whereisid(6'h23),
	.data_out(data_out),
	.lost(lost)
);

integer i,j,k;
parameter cycle = 16;
parameter packetsize = 35;

task onepacket;
	input [7:0] id;
	input [31:0] seed;
begin
	#cycle;
	rx_en = 1;
	for (i=0; i < packetsize; i=i+1) begin
		if (i == whereis_id)
			rxdata = id;
		//else rxdata = (seed * seed + i * i * 4 + packetsize * 111) % 255;
		 else	rxdata = ((seed+3) * packetsize *33)%255;
		#cycle;
	end
	rx_en = 0;
	#cycle;

end
endtask

always begin
	#3 clk = !clk;
	#5 ;
end

initial begin
clk=0;rx_en=0;rxdata=0;rst=0;
#cycle;
rst = 1;
#cycle;
rst = 0;
#cycle;


#(cycle*20);

for (k=1; k<=8; k=k+1) begin
	for (j=1; j<=5; j=j+1) begin
		if (j+1 != k && j+2 != k) 
			onepacket(j,k);
		#(cycle*20);
	end

	#(cycle*30);
end

for (k=1; k<=8; k=k+1) begin
	for (j=1; j<=5; j=j+1) begin
		if (j != k && j+2 != k) 
			onepacket(j,k);
		#(cycle*20);
	end
	#(cycle*30);
end

for (k=1; k<=8; k=k+1) begin
	for (j=1; j<=5; j=j+1) begin
		if (j != k && j+3 != k) 
			onepacket(j,k);
		#(cycle*20);
	end
	#(cycle*30);
end
for (k=1; k<=8; k=k+1) begin
	for (j=1; j<=5; j=j+1) begin
		if (j != k && j+3 != k && j+1 != k) 
			onepacket(j,k);
		#(cycle*20);
	end
	#(cycle*30);
end

$finish;
end
endmodule