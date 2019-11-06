module sys_top(
	input wire clk100MHz, // sys_clock
	input wire [7:0] switches,
	input wire resetn,
	input wire btnl,
	input wire btnu,
	input wire btnc,
	input wire btnr,
	input wire btnu,
	input wire eth_int_b, // interrupt
	
)