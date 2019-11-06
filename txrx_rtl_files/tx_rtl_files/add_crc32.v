module add_crc32(
	input wire clk,
	input wire [7:0] data_in,
	input wire data_valid_in,
	input wire data_enable_in,
	output reg [7:0] data_out = 8'b0,
	output reg data_valid_out = 1'b0,
	output reg data_enable_out = 1'b0
	//output reg almost_sent = 1'b0
	);

	reg [31:0] crc = 32'hffffffff;
	reg [3:0] trailer_left = 4'b0;

	reg [31:0] v_crc = 32'hffffffff;
   // reg [3:0] i = 4'b0; // for for loop
   integer i=0;


   always @* begin
		v_crc = 32'hffffffff;
   end
	always @(posedge clk) begin
		data_enable_out <= 1'b0;

		if (data_enable_in == 1'b1)
		begin
			data_enable_out <= 1'b1;
			if (data_valid_in == 1'b1)
			begin
				// pass the data through
				data_out <= data_in;
				data_valid_out <= 1'b1;
				// flag that we need to output 8bytes of CRC
				trailer_left <= 4'b1111;

				// update CRC
				v_crc = crc;
				for (i=0; i<8; i=i+1)
				begin
				if (data_in[i] == v_crc[31])
				v_crc = {v_crc[30:0],1'b0};
				else
				v_crc = {v_crc[30:0],1'b0} ^ 32'h04c11db7;
				end
				crc <= v_crc;
			end
			else if (trailer_left[3] == 1'b1)
			begin
				// append the CRC
				data_out <= ~({crc[24],crc[25],crc[26],crc[27],crc[28],crc[29],crc[30],crc[31]});
				//data_out <= 8'hca;
				crc <= {crc[23:0] ,8'b11111111};
				trailer_left <= {trailer_left[2:0],1'b0};
				data_valid_out <= 1'b1;
				
			end
			else begin
				// idle
				data_out <= 8'b00000000;
				data_valid_out <= 1'b0;
			end
		end
	end
endmodule
