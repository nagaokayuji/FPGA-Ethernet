module bram_compare
(
	input [7:0] dina, dinb,
	input [11:0] addra, addrb,
	input wea, web, clka,clkb,
	output reg [7:0] douta, doutb
);
	// Declare the RAM variable
	reg [7:0] ram[1500:0];
	
	// Port A
	always @ (posedge clka)
	begin
		if (wea) 
			ram[addra] <= dina;
			douta <= ram[addra];
	end
	
	// Port B
	always @ (posedge clkb)
	begin
		if (web)
			ram[addrb] <= dinb;
			doutb <= ram[addrb];
	end

	integer i;
	initial begin
		for (i=0; i<1500; i=i+1)
		ram[i] = 8'hxx;
		end
endmodule
