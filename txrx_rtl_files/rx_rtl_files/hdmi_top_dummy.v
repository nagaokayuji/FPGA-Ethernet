//=======
// DUMMY MODULE FOR hdmi_top module.
//============


module hdmi_top_dummy (
	input clk,RST,clk125MHz,dclk,data_en,
	input [7:0] data_in,
	output hdmi_tx_clk_n,hdmi_tx_clk_p,
	output [2:0] hdmi_tx_n,hdmi_tx_p
);

assign hdmi_tx_clk_n = !hdmi_tx_clk_p;
assign hdmi_tx_clk_p = 1'b1;

assign hdmi_tx_n = ~hdmi_tx_p;
assign hdmi_tx_p = 3'b101;

endmodule