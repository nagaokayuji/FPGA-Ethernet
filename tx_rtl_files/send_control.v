/*
control output signals for byte_data


*/

module send_control(
	input wire clk125MHz,
	input wire [7:0] switches, // [7:6] : fragment, [5:4]: redundancy, [3:0]: speed
	input wire busy,

	// output
	output reg [15:0] segment_num_inter = 0,
	output reg [7:0] txid_inter = 1,
	output reg [7:0] aux = 0,
	output reg start_sending = 0
);
reg [15:0] segment_num = 0;
reg [7:0] txid = 1;
wire [15:0] segment_num_max; // switches[7:6]
wire [7:0] redundancy; // switches[5:4]
wire [27:0] max_count; // calculated by switches[3:0]
max_count_gen max_count_gen_i (
	.switches(switches[7:0]), //input
	.max_count(max_count), // output
	.segment_num_max(segment_num_max), // output
	.redundancy(redundancy) // output
);
parameter segment_num_init = 0;

reg [27:0] count=0, counter_samepacket = 0;

reg in_sending = 0;

// PSEUDOCODE
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



reg [3:0] state = 0;
parameter state_wait = 0;
parameter state_id_1 = 1;
parameter state_id_not_1 = 2;
parameter state_id_1_sent = 3;
parameter state_id_not_1_sent = 4;

wire timer_done = (count == max_count);

always @(posedge clk125MHz) begin
	if (timer_done) begin
		count <= 0;
	end
	else
	if (!busy) begin
		count <= count + 1'b1;
		counter_samepacket <= counter_samepacket + 1'b1;
	end else begin
		count <= 0;
		counter_samepacket <= 0;
	end

	case (state)
		state_wait: begin 
			state <= state_id_1;
			txid <= 1'b1;
			segment_num <= segment_num_init;
			aux <= 1'b0;
		end

		state_id_1: begin
			if (timer_done) begin
				segment_num_inter <= segment_num;
				txid_inter <= 1'b1;
				txid <= 1'b1;
				start_sending <= 1'b1;
				state <= state_id_1_sent;
			end 
			else begin  //============= NOT timer_done
				txid <= txid;
				aux <= aux;
				segment_num <= segment_num;
				start_sending <= 1'b0;
				end
		end // end of state_id_1
		
		state_id_1_sent: begin
			start_sending <= 1'b0;

			if (segment_num == segment_num_max - 1) begin
				state <= state_id_not_1;
				segment_num <= segment_num_init;
				txid <= txid + 1'b1;
				aux <= aux;
			end
			else begin
				state <= state_id_1;
				segment_num <= segment_num + 1'b1;
			end
		end // end off state_id_1_sent

		state_id_not_1: begin
			if (timer_done) begin
				segment_num_inter <= segment_num;
				txid_inter <= txid;
				start_sending <= 1'b1;
				state <= state_id_not_1_sent;
			end
			else begin
				start_sending <= 1'b0;
			end
		end

		state_id_not_1_sent: begin
			start_sending <= 1'b0;
			if (segment_num == segment_num_max - 1) begin
				if (txid == redundancy) begin
					state <= state_id_1;
					aux <= aux + 1'b1;
					segment_num <= segment_num_init;
					txid <= 1'b1;
				end
				else begin
					txid <= txid + 1'b1;
					segment_num <= segment_num_init;
					state <= state_id_not_1;
				end
			end
			else begin
				state <= state_id_not_1;
				segment_num <= segment_num + 1'b1;
			end
		end
		
	endcase
end

/*

always @(posedge clk125MHz) begin
if (in_sending) begin // send frame for redundancy times
	   txid <= send_times;
	if (send_times == redundancy) begin

		in_sending <= 1'b0; // end
		start_sending <= 1'b0;
		send_times <= 3'b0;
		counter_samepacket <= 17'b0;
	end
	else if (counter_samepacket >= max_count) begin
	   if (!busy) begin
			start_sending <= 1'b1; // STARTSENDING
			send_times <= send_times + 1'b1; // sending process
			counter_samepacket <= 17'b0;
	   end
	end
	else begin
        counter_samepacket <= counter_samepacket + 1'b1;
        start_sending <= 1'b0;
	end
end // end of if (in_sending)

else if (!busy) begin
	if (count == max_count) begin
		count <= 27'b0;
		send_times <= 1'b0;
		counter_samepacket <= 11'b0;
		//my_data <= my_data + 1'b1;
	
		in_sending <= 1'b1;
	end else begin
		count <= count + 1'b1; // kokonihaitteru
		start_sending <= 1'b0; 
		in_sending <= 1'b0;
	end
end
end
*/




endmodule