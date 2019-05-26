module vram
(
	input [7:0] dina, dinb,
	input [23:0] addra, addrb,
	input wea, web, clka,clkb,
	output reg [7:0] douta, doutb
);
	// Declare the RAM variable
	reg [7:0] ram[57599:0];
	
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
		for (i=0; i<57600; i=i+1)
		ram[i] = (1 + i*11)%255;
		end
endmodule


module bram_1080
(
	input [7:0] dina, 
	input [12:0] addra, addrb,
	input wea,  clka,clkb,
	output reg [7:0]  doutb
);
	// Declare the RAM variable
	reg [7:0] ram[1439:0];
	
	// Port A
	always @ (posedge clka)
	begin
		if (wea) 
			ram[addra] <= dina;
	end
	
	// Port B
	always @ (posedge clkb)
	begin
		doutb <= ram[addrb];
	end

	integer i;
	initial begin
		for (i=0; i<1440; i=i+1)
		ram[i] = 8'h19;
		end
endmodule
