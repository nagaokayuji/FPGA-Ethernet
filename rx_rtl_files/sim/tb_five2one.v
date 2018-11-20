`timescale 1ns / 1ns
`include "./dpramtest.2.v"
`include "./true_dpram_sclk.v"
`include "./comparator.v"

module tb_dpramtest;

reg clk,reset,rx_en;
reg [7:0] rxdata;
wire [7:0] out1,out2;
//wire [11:0] out3;

initial
  begin
      // wave.vcd という名前で波形データファイルを出力
      $dumpfile("aaaaaa.vcd");
      // 全てのポートを波形データに含める
      $dumpvars(0, dpramtest);
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
dpramtest dpramtest(
	.clk(clk),
	.rst(reset),
	.rx_en_w(rx_en),
	.rxdata_w(rxdata),
	.en_out(en_out),
	//.whereisid(6'h23),
	.data_out(data_out),
	.lost(lost),
	.clk125MHz(clk125MHz)
);

initial begin
#2;
clk125MHz = 0;
forever begin
#5 clk125MHz <= ~clk125MHz;
end
end
integer i,j,k;
parameter i_max = 12'h40;

initial begin
	#3;
	clk = 0;
	forever begin
	#5 clk <= ~clk;
	end
end

initial begin

	#5;
	#2;
	switches = 4'b0000;
	for (k = 1; k <= 7; k=k+1) begin
	switches = 0;
	#600;
	#3600;
	for (j=1; j <= 4'd3; j=j+1) begin
		rx_en = 1'b1;
	for (i = 0; i <= i_max; i=i+1) begin
		if (j != k) begin
		if (j !=(k+1) )begin
		if (i < 12'h3 ) begin
		rxdata = 8'h0a;#10;
		end
		else if (i == 12'h3) begin
		rxdata = j;#10;
		end
		else if (i == 12'h4) begin
		rxdata = 8'hff;#10;
		end
		else if (i == 12'h5) begin
		rxdata = 8'hee;#10;
		end
		else if (i <= 12'h27) begin
		rxdata = i % 8'h3;#10;
		end
		else if (i <= 12'h33) begin
		rxdata = 8'h00;#10;
		end
		else if (i <= 12'h35) begin
		rxdata = k;#10;
		end
		else if (i <= i_max - 12'd9) begin
			rxdata = 8'hff;#10;
		end
		else if (i <= i_max - 12'd7) begin
			rxdata = 8'hed;#10;
		end
		else if (i <= i_max - 12'd4) begin
		rxdata = 8'h00;#10;
		end
		else if (i == i_max - 2) begin
			rxdata = 8'hee;#10;
		end
		else if (i == i_max-1) begin
			rxdata = 8'hee;#10;
		end
		else if (i <= i_max) begin
		rxdata = 8'hdd;#10;
		end
		
		end
		else begin
			if (i == 12'h3) begin
				rxdata = j;#10;
			end
			else begin
				rxdata = 8'h55;
				#10;
			end

		end
		end

		end // i
		rx_en = 1'b0;
		rxdata = 8'h00;
		#60;
		#300;
		end
		#60;
		end


#300;
$finish;
end




initial begin
reset = 0;
rx_en = 0;
rxdata = 0;
end

endmodule