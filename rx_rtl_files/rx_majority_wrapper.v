module rx_majority_wrapper #(parameter whereis_segment_num = 34, SEGMENT_NUM_MAX = 50 // maybe ok
)
(
	input wire clk125MHz,
	input wire reset,
	input wire [7:0] rx_data,
	input wire rx_enable,
	output wire tmp,
	(* mark_debug = "true" *) output wire loss_detected,
	input wire [7:0] redundancy,
	output wire en_out,
	output wire [7:0] data_out
);


(* mark_debug = "true" *) reg rx_en;
(* mark_debug = "true" *) reg [7:0] rxdata;
(* mark_debug = "true" *) reg [11:0] count_edge = 0;
(* mark_debug = "true" *) reg [15:0] segment_num = 0;
(* mark_debug = "true" *) reg segment_num_en = 0;
(* mark_debug = "true" *) reg [7:0] rx_id_fordebug;
(* mark_debug = "true" *) reg [7:0] aux_fordebug;


/*
have to validate.
IPaddr = 192.168.1.1
length = 1440
*/

//count = 26,27,28,29
localparam ip_src_addr = 32'hc0a80140; // 192.168.1.64
//count = 6,7,8,9,10,11
localparam eth_dst_mac = 48'hdeadbeef0123; //

(* mark_debug = "true" *) reg validation;


always @(posedge clk125MHz) begin
    if (reset) begin
        validation = 1;
        count_edge = 0;
        segment_num_en = 0;
        
    end

	rx_en <= rx_enable;
	rxdata <= rx_data;

	if (validation) begin
		case (count_edge)
			(6): begin
				if (eth_dst_mac[47:40] != rxdata)
					validation <= 0;
				end
			(7): begin
				if (eth_dst_mac[39:32] != rxdata)
					validation <= 0;
				end
			(8): begin
				if (eth_dst_mac[31:24] != rxdata)
					validation <= 0;
				end
			(9) : begin
				if (eth_dst_mac[23:16] != rxdata)
					validation <= 0;
				end
			(10) : begin
				if (eth_dst_mac[15:8] != rxdata)
					validation <= 0;
				end
			(11): begin
				if (eth_dst_mac[7:0] != rxdata)
					validation <= 0;
				end

			(26): begin
				if (ip_src_addr[31:24] != rxdata)
					validation <= 0;
				
			end
			(27): begin
				if (ip_src_addr[23:16] != rxdata)
					validation <= 0;
			end
			(28): begin
				if (ip_src_addr[15:8] != rxdata)
					validation <= 0;
					end
			
			(29): begin
				if (ip_src_addr[7:0] != rxdata)
					validation <= 0;
					end
			(32): begin
				if (8'h01 != rxdata)
					validation <= 0;
				end
			(33): begin
				if (8'h02) != rxdata)
					validation <= 0;
				end

		endcase
	end

	if (rx_en && rx_enable) begin // to reduce last one
		count_edge <= count_edge + 1'b1;
	end	else begin
		validation <= 1;
		count_edge <= 1'b0;
		segment_num <= 0;
		segment_num_en <= 0;
	end

	if (count_edge == whereis_segment_num) begin
		segment_num[15:8] <= rxdata;
	end
	else if (count_edge == whereis_segment_num +1 && validation) begin
		segment_num[7:0] <= rxdata;
		segment_num_en <= 1'b1;
	end
	else if (count_edge == whereis_segment_num + 2) begin
		rx_id_fordebug <= rxdata;
	end
	else if (count_edge == whereis_segment_num+3) begin
		aux_fordebug <= rxdata;
	end
end


wire rx_enable_seg[SEGMENT_NUM_MAX - 1: 0];

wire [7:0] data_out_seg[SEGMENT_NUM_MAX - 1: 0];
wire en_out_seg[SEGMENT_NUM_MAX - 1: 0];

wire [7:0] data_out_seg_wire[SEGMENT_NUM_MAX - 1: 0];
//wire [8:0] en_and_data[SEGMENT_NUM_MAX - 1: 0];

/*
reg [7:0] rxdata_s;
reg rx_enable_seg_s[SEGMENT_NUM_MAX - 1: 0];


integer k;
always @(posedge clk125MHz) begin
    for (k=0; k<SEGMENT_NUM_MAX; k=k+1) begin
        rx_enable_seg_s[k] = rx_enable_seg[k];
    end
    rxdata_s <= rxdata;
end
*/
wire loss_detected_seg[SEGMENT_NUM_MAX - 1: 0];
genvar i;
generate
for (i=0; i<SEGMENT_NUM_MAX; i=i+1) begin
	rx_majority rx_majority_inst(
		.clk125MHz(clk125MHz),
		.reset(reset),
		.rx_data(rxdata),
		.rx_enable(rx_enable_seg[i]),
		.loss_detected(loss_detected_seg[i]),
		.redundancy(redundancy),
		.en_out(en_out_seg[i]),
		.data_out(data_out_seg[i])
	);
	
	assign rx_enable_seg[i] = (segment_num_en && (segment_num == i));
	
	assign data_out_seg_wire[i] = (en_out_seg[i] == 1'b1) ? data_out_seg[i] : 0;
//	assign en_and_data[i] = {en_out_seg[i],data_out_seg_wire[i]};
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
reg loss_detected_one;
integer j;
always @(posedge clk125MHz) begin
    for (j=0; j < SEGMENT_NUM_MAX; j=j+1) begin
        if (en_out_seg[j]) begin
            sel = j;
        end
        data_out_seg_reg[j] <= data_out_seg[j];
        en_out_seg_reg[j] <= en_out_seg[j];
    end
    data_out_one <= data_out_seg_reg[sel];
    en_out_one <= en_out_seg_reg[sel];
    loss_detected_one <= loss_detected_seg[sel];
end
assign en_out = en_out_one;
assign data_out = data_out_one;
assign loss_detected = loss_detected_one;


endmodule