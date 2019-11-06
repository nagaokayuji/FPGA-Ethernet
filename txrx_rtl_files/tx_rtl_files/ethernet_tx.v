// add CRC, add preamble, use ODDR

module ethernet_tx (
	input wire clk125MHz,
	input wire clk125MHz90,
	input wire [7:0] raw_data,
	input wire raw_data_valid,
	input wire raw_data_enable,
	input wire phy_ready,
	
	// output
	output wire [3:0] eth_txd,
	output wire eth_txck,
	output wire eth_txctl
);


wire [7:0] with_crc;
wire with_crc_valid;
wire with_crc_enable;


add_crc32 i_add_crc32(
	.clk(clk125MHz),
	.data_in(raw_data),
	.data_valid_in(raw_data_valid),
	.data_enable_in(raw_data_enable),
	.data_out(with_crc),
	.data_valid_out(with_crc_valid),
	.data_enable_out(with_crc_enable)
	);

wire [7:0] fully_framed;
wire fully_framed_valid;
wire fully_framed_enable;
wire fully_framed_err;
add_preamble i_add_preamble(
	.clk(clk125MHz),
	.data_in(with_crc),
	.data_valid_in(with_crc_valid),
	.data_enable_in(with_crc_enable),
	.data_out(fully_framed),
	.data_valid_out(fully_framed_valid),
	.data_enable_out(fully_framed_enable)
	);
rgmii_tx i_rgmii_tx(
	.clk(clk125MHz),
	.clk90(clk125MHz90),
	.phy_ready(1'b1),

	.data(fully_framed),
	.data_valid(fully_framed_valid),
	.data_enable(fully_framed_enable),
	.data_error(1'b0),
	.eth_txck(eth_txck),
	.eth_txctl(eth_txctl),
	.eth_txd(eth_txd)
	);



endmodule