module true_dpram_sclk
(
	input [7:0] data_a, data_b,
	input [11:0] addr_a, addr_b,
	input we_a, we_b, clk,
	output reg [7:0] q_a, q_b
);
	// Declare the RAM variable
	reg [7:0] ram[4095:0];
	
	// Port A
	always @ (posedge clk)
	begin
		if (we_a) 
			ram[addr_a] <= data_a;
			q_a <= ram[addr_a];
	end
	
	// Port B
	always @ (posedge clk)
	begin
		if (we_b)
			ram[addr_b] <= data_b;
			q_b <= ram[addr_b];
	end

	integer i;
	initial begin
		for (i=0; i<4096; i=i+1)
		ram[i] = 8'h0a;
		end
endmodule
