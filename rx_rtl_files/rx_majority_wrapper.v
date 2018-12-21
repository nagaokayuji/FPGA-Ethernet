module rx_majority_wrapper #(parameter whereis_segment_num = 22, SEGMENT_NUM_MAX = 50 // maybe ok
)
(
	input wire clk125MHz,
	input wire reset,
	input wire rx_clk, // main
	input wire [7:0] rx_data,
	input wire rx_enable,
	output wire tmp,
	output wire loss_detected,
	input wire [5:0] switches,
	output wire en_out,
	output wire [7:0] data_out
);

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

	if (count_edge == whereis_segment_num) begin
		segment_num[15:8] <= rxdata;
	end
	else if (count_edge == whereis_segment_num +1) begin
		segment_num[7:0] <= rxdata;
		segment_num_en <= 1'b1;
	end
end


wire rx_enable_seg[SEGMENT_NUM_MAX - 1: 0];

wire [7:0] data_out_seg[SEGMENT_NUM_MAX - 1: 0];
wire en_out_seg[SEGMENT_NUM_MAX - 1: 0];

wire [7:0] data_out_seg_wire[SEGMENT_NUM_MAX - 1: 0];
wire [8:0] en_and_data[SEGMENT_NUM_MAX - 1: 0];
genvar i;

generate
for (i=0; i<SEGMENT_NUM_MAX; i=i+1) begin
	rx_majority rx_majority_inst(
		.clk125MHz(clk125MHz),
		.reset(reset),
		.rx_clk(rx_clk),
		.rx_data(rxdata),
		.rx_enable(rx_enable_seg[i]),
		.tmp(),
		.loss_detected(),
		.switches(switches),
		.en_out(en_out_seg[i]),
		.data_out(data_out_seg[i])
	);
	
	assign rx_enable_seg[i] = (segment_num_en && (segment_num == i));

	assign data_out_seg_wire[i] = (en_out_seg[i] == 1'b1) ? data_out_seg[i] : 0;
	assign en_and_data[i] = {en_out_seg[i],data_out_seg_wire[i]};
end
endgenerate
/*****
if (en[i]):
	data = data[i];
else if (en[i+1]):
	data = data[i];

*****************/

reg [15:0] sel = 0;
reg [7:0] data_out_seg_reg[SEGMENT_NUM_MAX - 1: 0];
reg en_out_seg_reg[SEGMENT_NUM_MAX - 1: 0];
reg [7:0] data_out_one;
reg en_out_one;
integer j;
always @(posedge rx_clk) begin
    for (j=0; j < SEGMENT_NUM_MAX; j=j+1) begin
        if (en_out_seg[j]) begin
            sel = j;
        end
        data_out_seg_reg[j] <= data_out_seg[j];
        en_out_seg_reg[j] <= en_out_seg[j];
    end
    data_out_one <= data_out_seg_reg[sel];
    en_out_one <= en_out_seg_reg[sel];
end
assign en_out = en_out_one;
assign data_out = data_out_one;


endmodule