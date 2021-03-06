/*
control output signals for byte_data
*/
module send_control(
	input wire clk125MHz,
	input wire RST,
	input wire [7:0] switches, 
	input wire busy,
	(* mark_debug = "true" *)	input wire start_frame,
	(* mark_debug = "true" *)	input wire oneframe_done,
	(* mark_debug = "true" *)	input wire maxdetect, 

	// output
	(* mark_debug = "true" *)	output reg [15:0] segment_num_inter = 0,
	(* mark_debug = "true" *)	output reg [7:0] txid_inter = 1,
	(* mark_debug = "true" *)	output wire [7:0] aux_inter,
	(* mark_debug = "true" *)	output reg start_sending = 0,
	output reg [15:0] segment_num_max,
	output wire hdmimode,
	(* mark_debug = "true" *) output wire framemode,
	output wire [7:0] redundancy 
);

reg [7:0] aux = 0;
reg [15:0] segment_num = 0;
reg [7:0] txid = 1;
wire [27:0] max_count;
assign hdmimode = (switches[3:0] == 4'b0000);
assign framemode = (switches[7:6] == 2'b11);


wire [15:0] segment_num_max_normal;
max_count_gen max_count_gen_i (
	.switches(switches[7:0]), //input
	.max_count(max_count), // output
	.segment_num_max(segment_num_max_normal), // output
	.redundancy(redundancy) // output
);
parameter segment_num_init = 0;

reg [27:0] count=0, counter_samepacket = 0;
reg in_sending = 0;

// like this:
/*
while (true) {
	for (id in 1..n) {
		if (id == 1) {
			for (segment_num in 0...m) {
				data = DATA_FROM_VIDEO_RAM;
				RAM[segment_num] = data;
				send_frame(data);
			}
		}
		else { 			//===== id != 2
			for (segment_num in 0...m) {
				data = RAM[segment_num];
				send_frame(data);
			}
		}
	}
	aux++;
}

*/
(* mark_debug = "true" *) reg [3:0] state = 0;
localparam state_wait = 0;
localparam state_id_1 = 1;
localparam state_id_not_1 = 2;
localparam state_id_1_sent = 3;
localparam state_id_not_1_sent = 4;
localparam state_wait_for_frame = 5;

(* mark_debug = "true" *) wire timer_done = (count == max_count);//hdmimode ? () : (count == max_count) ;

(* mark_debug = "true" *)reg [1:0] hdmistate = 0;
localparam hdmi_wait = 0;
localparam hdmi_sending = 1;
localparam hdmi_sent = 2;

wire [7:0] txid_next = (txid <= redundancy) ? txid + 1 : 1 ;
wire [15:0] segment_num_next = (segment_num < segment_num_max) ? segment_num + 1 : segment_num_init;
reg oneframe_done_detected;
(* mark_debug = "true" *) reg maxdetected = 0;
reg [15:0] segment_num_framemode;
reg [7:0] aux_base = 0, aux_base_inter = 0;

assign aux_inter = aux_base_inter + segment_num_inter;

always @(posedge clk125MHz) begin
	if (RST) begin
		hdmistate = 0;
		maxdetected = 0;
		segment_num_framemode = 0;
		oneframe_done_detected = 0;
		state = 0;
		segment_num = 0;
		txid = 0;
		count = 0;
		in_sending = 0;
		segment_num_inter = 0;
		txid_inter = 0;
		aux_base = 0;
		aux = 0;
		segment_num_max = 150;

	end else begin
		if (!framemode) begin
			segment_num_max <= segment_num_max_normal;
		end

		if (oneframe_done && hdmimode) begin // oneframe_done is used only HERE. now lock sareteru
			oneframe_done_detected <= 1'b1;
		end

		if (timer_done) begin
			count <= 0;
		end
		else
		if (!busy && (!hdmimode || (hdmimode && hdmistate != hdmi_sent))) begin
			count <= count + 1'b1;
		end else begin
			count <= 0;
		end

		if (txid_inter == 1 && maxdetect && !maxdetected) begin 
			segment_num_max <= segment_num_inter + 1;
			maxdetected <= 1'b1;
		end
		if (!busy)

		case (state)
			state_wait: begin
				if (!hdmimode) begin 
					state <= state_id_1;
					txid <= 1'b1;
					segment_num <= segment_num_init;
					aux <= 1'b0;
					
				end else begin // if hdmimode.
					if (start_frame) begin
						oneframe_done_detected <= 1'b0;
						state <= state_id_1;
						txid <= 1'b1;
						segment_num <= segment_num_init;
						hdmistate <= hdmi_sending;
					end
				end
			end

			state_id_1: begin
				if (hdmimode) begin
					if (start_frame) begin
						hdmistate <= hdmi_sending;
					end
				end
				if (framemode && !maxdetected) begin
					segment_num_max <= 150;
				end

				if (timer_done) begin
					if (!hdmimode) begin
						segment_num_inter <= segment_num;
						txid_inter <= 1'b1;
						aux_base_inter <= aux_base;
						//aux_inter <= aux;
						txid <= 1'b1;
						start_sending <= 1'b1;
						state <= state_id_1_sent;
					end
					else begin // hdmimode
						if (oneframe_done_detected) state <= state_id_1_sent;
						else
						if (hdmistate != hdmi_sent) begin
							segment_num_inter <= segment_num;
							txid_inter <= 1'b1;
							aux_base_inter <= aux_base;
							//aux_inter <= aux;
							txid <= 1'b1;
							start_sending <= 1'b1;
							state <= state_id_1_sent;
							hdmistate <= hdmi_sending;
						end
						else begin
							start_sending <= 1'b0;
						end
					end
				end 
				else begin 
					txid <= txid;
					aux <= aux;
					segment_num <= segment_num;
					start_sending <= 1'b0;
					end
			end // end of state_id_1
			
			state_id_1_sent: begin
				start_sending <= 1'b0;
				if (hdmimode && oneframe_done_detected && txid >= redundancy && segment_num >= segment_num_max - 1) begin
					oneframe_done_detected <= 1'b0;
					hdmistate <= hdmi_sent;
					state <= state_wait;
					aux <= aux + 1'b1;
					txid_inter <= 1'b1;
					segment_num <= segment_num_init;
				end else begin
					if (segment_num >= segment_num_max - 1) begin
						if (txid >= redundancy) begin
							state <= state_id_1;
							aux <= aux + 1;
							aux_base <= aux_base + segment_num_max;
							segment_num <= segment_num_init;
						end else begin
							state <= state_id_not_1;
							segment_num <= segment_num_init;
							txid <= txid_next;
							aux <= aux;
						end
					end
					else begin
						state <= state_id_1;
						segment_num <= segment_num_next;
					end
				end
			end

			state_id_not_1: begin
				if (timer_done) begin
					if (oneframe_done_detected) state <= state_id_not_1_sent;
					else begin
						segment_num_inter <= segment_num;
						txid_inter <= txid;
						start_sending <= 1'b1;
						aux_base_inter <= aux_base;
						state <= state_id_not_1_sent;
					end
				end
				else begin
					start_sending <= 1'b0;
				end
			end

			state_id_not_1_sent: begin
				start_sending <= 1'b0;
				maxdetected <= 1'b0;
				if (hdmimode && oneframe_done_detected && txid >=redundancy && segment_num >= segment_num_max - 1) begin
					oneframe_done_detected <= 1'b0;
					hdmistate <= hdmi_sent;
					state <= state_wait;
					aux <= aux + 1'b1;
					txid_inter <= 1'b1;
					aux_base <= aux_base + segment_num_max;
					segment_num <= segment_num_init;
				end else begin
					if (segment_num >= segment_num_max - 1) begin 
						if (txid == redundancy) begin
							state <= state_id_1;
							aux <= aux + 1'b1;
							aux_base <= aux_base + segment_num_max;
							segment_num <= segment_num_init;
							txid <= 1'b1;
						end
						else begin
							txid <= txid_next;
							segment_num <= segment_num_init;
							state <= state_id_not_1;
						end
					end
					else begin
						state <= state_id_not_1;
						segment_num <= segment_num_next;
					end
				end
			end
			// start_frame: start signal
			// oneframe_done: frame send signal
			/*
			state_wait_for_frame: begin
				if (start_frame) begin
					state <= state_id_1;
				end
			end
			*/
		endcase
	end
end
endmodule