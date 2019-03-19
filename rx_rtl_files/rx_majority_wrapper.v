module rx_majority_wrapper #(parameter whereis_segment_num = 34,whereisid = 0, SEGMENT_NUM_MAX = 5 // maybe ok
)
(
	input wire clk125MHz,
	input wire reset,
	input wire [7:0] rx_data,
	input wire rx_enable,
	output wire tmp,
	input wire [7:0] redundancy,
	output reg [15:0] seg_out,
	output wire en_out,
	output wire [7:0] data_out
);


(* mark_debug = "true" *) reg rx_en;
(* mark_debug = "true" *) reg [7:0] rxdata;
(* mark_debug = "true" *) reg [11:0] count_edge = 0;
(* mark_debug = "true" *) reg [15:0] segment_num = 0;
reg segment_num_en = 0;
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
				if (8'h02 != rxdata)
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

genvar i;
reg rxen_seg_reg [SEGMENT_NUM_MAX - 1 : 0];
reg [7:0] rxdata_reg;

generate
for (i=0; i<SEGMENT_NUM_MAX; i=i+1) begin
	n2one #(.whereisid(whereisid)) n2one_inst(
		.clk(clk125MHz),
		.rst(reset),
		.rxd(rxdata),
		.rxen(rx_enable_seg[i]),
		.redundancy(redundancy),
		.en_out_reg(en_out_seg[i]),
		.data_out_reg(data_out_seg[i])
	);
	
	assign rx_enable_seg[i] = (segment_num_en && (segment_num == i));
	


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
reg [7:0] data_out_one_reg,data_out_one_reg_reg;
reg en_out_one_reg, en_out_one_reg_reg;

integer j;

(* mark_debug = "true" *) reg [2:0] state = 0;
/*
always @(posedge clk125MHz) begin
    if (reset) state = 0;
    else begin
    for (j=0; j < SEGMENT_NUM_MAX; j=j+1) begin
        if (en_out_seg[j]) begin
            sel = j;
            state = 1;
        end
        else sel = sel;
        
        data_out_seg_reg[j] <= data_out_seg[j];
        en_out_seg_reg[j] <= en_out_seg[j];
    end
    data_out_one <= data_out_seg_reg[sel];
    en_out_one <= en_out_seg_reg[sel];
    
    data_out_one_reg <= data_out_one;
    en_out_one_reg <= en_out_one;
    
    data_out_one_reg_reg <= data_out_one_reg;
    en_out_one_reg_reg <= en_out_one_reg;
    
    end
end
assign en_out = en_out_one_reg_reg;
assign data_out = data_out_one_reg_reg;
*/
localparam state_max = 2;
wire [2:0] state_next = (state == state_max) ? 3'b0 : (state + 1'b1);
integer k;
always @(posedge clk125MHz) begin
	if (reset) begin
		state = 0;
		en_out_one = 0;
		data_out_one = 8'hff;
	end
	else begin
		for (k=0; k<SEGMENT_NUM_MAX; k=k+1) begin
			en_out_seg_reg[k] <= en_out_seg[k];
			data_out_seg_reg[k] <= data_out_seg[k];
		end

		case (state)
			0: // get sel
				begin
					for (j=0; j < SEGMENT_NUM_MAX; j=j+1) begin
						if (en_out_seg[j]) begin
							sel = j;
							state <= 1;
						end
						else begin
							sel = sel;
						end
					end
				end
			1: // one
				begin
					if (en_out_seg_reg[sel]) begin
					    seg_out <= sel;
						data_out_one <= data_out_seg_reg[sel];
						en_out_one <= en_out_seg_reg[sel];
					end
					else begin
						data_out_one <= 8'hff;
						en_out_one <= 0;
						state <= 0;
					end
				end
			2:
				begin
				end
			3:
				begin
				end
			4:
				begin


				end

			5:
				begin
				end
			6:
				begin
				end
			default:
				begin
				end
		endcase
	end
end

assign data_out = data_out_one;
assign en_out = en_out_one;

endmodule