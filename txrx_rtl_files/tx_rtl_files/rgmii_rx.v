module rgmii_rx (
	input wire rx_clk,
	input wire rx_ctl,
	input wire [3:0] rx_data,
	output reg link_10mb,
	output reg link_100mb,
	output reg link_1000mb,
	output reg link_full_duplex,
	output reg [7:0] data,
	output reg data_valid,
	output reg data_enable,
	output reg data_error
	);
	

	wire [1:0] raw_ctl;
	wire [7:0] raw_data;

	/* IDDR (is it ok?)
	*/

	IDDR #(
		.DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
		.INIT_Q1(1'b0),
		.INIT_Q2(1'b0),
		.SRTYPE("SYNC")
		) ddr_rx_ctl (
		.Q1(raw_ctl[0]),
		.Q2(raw_ctl[1]),
		.C(rx_clk),
		.CE(1'b1),
		.D(rx_ctl),
		.R(1'b0),
		.S(1'b0)
		);

	IDDR #(
		.DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
		.INIT_Q1(1'b0),
		.INIT_Q2(1'b0),
		.SRTYPE("SYNC")
		) ddr_rxd0 (
		.Q1(raw_data[0]),
		.Q2(raw_data[4]),
		.C(rx_clk),
		.CE(1'b1),
		.D(rx_data[0]),
		.R(1'b0),
		.S(1'b0)
		);

	IDDR #(
		.DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
		.INIT_Q1(1'b0),
		.INIT_Q2(1'b0),
		.SRTYPE("SYNC")
		) ddr_rxd1 (
		.Q1(raw_data[1]),
		.Q2(raw_data[5]),
		.C(rx_clk),
		.CE(1'b1),
		.D(rx_data[1]),
		.R(1'b0),
		.S(1'b0)
		);
	IDDR #(
		.DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
		.INIT_Q1(1'b0),
		.INIT_Q2(1'b0),
		.SRTYPE("SYNC")
		) ddr_rxd2 (
		.Q1(raw_data[2]),
		.Q2(raw_data[6]),
		.C(rx_clk),
		.CE(1'b1),
		.D(rx_data[2]),
		.R(1'b0),
		.S(1'b0)
		);
	IDDR #(
		.DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
		.INIT_Q1(1'b0),
		.INIT_Q2(1'b0),
		.SRTYPE("SYNC")
		) ddr_rxd3 (
		.Q1(raw_data[3]),
		.Q2(raw_data[7]),
		.C(rx_clk),
		.CE(1'b1),
		.D(rx_data[3]),
		.R(1'b0),
		.S(1'b0)
		);


	
	always @(posedge rx_clk) begin
		data_valid <= raw_ctl[0];
		data_error <= raw_ctl[0] ^ raw_ctl[1];
		data <= raw_data;
		// check for inter-frame with matching upper and lower nibble
		if (raw_ctl == 2'b00 && raw_data[3:0] == raw_data[7:4]) begin
		// 10101010.... -> preambles
			link_10mb <= 1'b0;
			link_100mb <= 1'b0;
			link_1000mb <= 1'b0;
			link_full_duplex <= 1'b0;

			case (raw_data[2:0])
				3'b001:begin link_10mb <= 1'b1; link_full_duplex <= raw_data[3];end
				3'b011: begin link_100mb <= 1'b1; link_full_duplex <= raw_data[3];end
				3'b101: begin link_1000mb <= 1'b1; link_full_duplex <= raw_data[3];end
				default: ;
		 endcase
	end
	end
endmodule