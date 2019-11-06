module add_preamble(
	input wire clk,
	input wire [7:0] data_in,
	input wire data_valid_in,
	input wire data_enable_in,
	output reg [7:0] data_out = 8'b0,
	output reg data_valid_out = 1'b0,
	output reg data_enable_out = 1'b0
	);

	reg [63:0] delay_data = 64'b0;
	reg [7:0] delay_data_valid = 8'b0;

	always @(posedge clk) begin
		data_enable_out <= 1'b0;
		if (data_enable_in == 1'b1) begin
			data_enable_out <= 1'b1;

			if (delay_data_valid[7] == 1'b1) 
			begin
				// passing through data
				data_out <= delay_data[63:56];
				data_valid_out <= 1'b1;
			end 
			else if (delay_data_valid[6] == 1'b1)
				// SFD
			begin
				data_out <= 8'b11010101;
				data_valid_out <= 1'b1;
			end
			else if (data_valid_in == 1'b1) 
			begin
				// preamble nibbles
				data_out <= 8'b01010101;
				data_valid_out <= 1'b1;
			end

			else begin
				data_out <= 8'b00000000;
				data_valid_out <= 1'b0;
			end

			// move the data through the delay line
			delay_data <= {delay_data[55:0], data_in};
			delay_data_valid <= {delay_data_valid[7:0], data_valid_in};
			
		end
	end

endmodule