/*
control output signals for byte_data
*/

module send_control(
	input wire clk125MHz,
	input wire [7:0] switches, // [7:6] : fragment, [5:4]: redundancy, [3:0]: speed
	input wire busy,

	// output
	output reg [7:0] aux,
	output reg [15:0] segment_num,
	output reg [7:0] txid,
	output reg start_sending
);

wire [15:0] segment_num_max; // switches[7:6]
wire [7:0] redundancy; // switches[5:4]
wire [27:0] max_count; // calculated by switches[3:0]
max_count_gen max_count_gen_i (
	.switches(switches[3:0]), //input
	.max_count(max_count), // output
	.segment_num_max(segment_num_max), // output
	.redundancy(redundancy) // output
);

reg [3:0] state = 0;
parameter in_sendingnostate = 1;
parameter not_busy = 2;

reg [27:0] count=0, counter_samepacket = 0;

reg [3:0] send_times = 0;
reg in_sending = 0;

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





endmodule