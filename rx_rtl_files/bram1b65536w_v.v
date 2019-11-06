module bram_1b65536w
(
	input [0:0] dina, 
	input [15:0] addra, 
	input wea,clka,
	output reg [0:0] douta
);
	// Declare the RAM variable
	reg [0:0] ram[65536:0];
	
	// Port A
	always @ (posedge clka)
	begin
		if (wea) 
			ram[addra] <= dina;
			douta <= ram[addra];
	end
	
	// // Port B
	// always @ (posedge clkb)
	// begin
	// 	if (web)
	// 		ram[addrb] <= dinb;
	// 		doutb <= ram[addrb];
	// end

	// integer i;
	// initial begin
	// 	for (i=0; i<1500; i=i+1)
	// 	ram[i] = 8'hxx;
	// 	end
endmodule
