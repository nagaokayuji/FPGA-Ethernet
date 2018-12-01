module rx_majority_wrapper(
	input wire clk,
	input wire clk125MHz,
	input wire reset,
	input wire rx_clk,
	input wire [7:0] rx_data,
	input wire rx_enable,
	output wire tmp,
	output wire loss_detected,
	input wire [5:0] switches,
	output wire en_out,
	output wire [7:0] data_out
);

localparam whereis_segment_num = 22; // maybe ok
localparam SEGMENT_NUM_MAX = 50;

reg rx_en;
reg [7:0] rxdata;
reg [11:0] count_edge = 0;
reg [15:0] segment_num = 0;
reg segment_num_en = 0;
always @(posedge rx_clk) begin
	rx_en <= rx_enable;
	rxdata <= rx_data;

	if (rx_en) begin
		count_edge <= count_edge + 1'b1;
	end	else begin
		count_edge <= 1'b0;
		segment_num <= 0;
		segment_num_en <= 0;
	end

	if (count_edge == whereis_segment_num - 1) begin
		segment_num[15:8] <= rxdata;
	end
	else if (count_edge == whereis_segment_num) begin
		segment_num[7:0] <= rxdata;
		segment_num_en <= 1'b1;
	end
end


wire rx_enable_seg[SEGMENT_NUM_MAX - 1: 0];
wire [7:0] data_out_seg[SEGMENT_NUM_MAX - 1: 0];
wire en_out_seg[SEGMENT_NUM_MAX - 1: 0];


genvar i;
generate
for (i=0; i<SEGMENT_NUM_MAX; i=i+1) begin
	rx_majority rx_majority_inst(
		.clk(clk),
		.clk125MHz(clk125MHz),
		.reset(reset),
		.rx_clk(rx_clk),
		.rx_data(rx_data),
		.rx_enable(rx_enable_seg[i]),
		.tmp(),
		.loss_detected(),
		.switches(switches),
		.en_out(en_out_seg[i]),
		.data_out(data_out_seg[i])
	);
end
endgenerate

endmodule