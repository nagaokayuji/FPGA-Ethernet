module rgmii_rx (
    input wire rst,
    input wire clk125MHz,
	input wire rx_clk,
	input wire rx_ctl,
	input wire [3:0] rx_data,
	output reg link_10mb,
	output reg link_100mb,
	output reg link_1000mb,
	output reg link_full_duplex,
	output wire [7:0] raw_data_f,
	output wire data_enable_f,
	output wire data_error
	);
 wire [7:0] raw_data;
wire data_enable;



wire [1:0] raw_ctl;
assign data_enable = raw_ctl[0];
assign data_error = raw_ctl[0] ^ raw_ctl[1];

//	wire [7:0] raw_data;


/*
		data_valid <= raw_ctl[0];
data_error <= raw_ctl[0] ^ raw_ctl[1];
data <= raw_data;
*/
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

//=========================
//        FIFO
//=========================


wire wr_en,rd_en,full,empty, prog_empty, prog_full;
wire en_fifo_out;

wire [7:0] data_fifo_out;


 wire matte = !en_fifo_out && prog_empty;


reg [1:0] matte_rise_detect;
reg [9:0] waitcount = 0;
reg wait_on = 0;
reg [9:0] waitcount_wr = 0;
reg coldwrite_on = 0;
wire matte_rise = matte_rise_detect == 2'b01;
localparam wait_max = 60;
always @(posedge clk125MHz) begin
    if (rst) begin
        matte_rise_detect = 0;
        waitcount = 0;
        wait_on = 0;
        coldwrite_on = 0;
        waitcount_wr = 0;
    end


    matte_rise_detect = {matte_rise_detect[0],matte};
    if (matte_rise) begin
        wait_on <= 1;
    end
    
    if (wait_on) begin
        if (waitcount >= wait_max) begin
            waitcount <= 0;
            wait_on <= 0;
        end
        else begin
            wait_on <= 1;
            waitcount <= waitcount + 1;
        end
     end
 
    if (prog_full) begin
        coldwrite_on <= 1;
    end
    
    if (coldwrite_on) begin
        if (waitcount_wr >= wait_max) begin
            waitcount_wr <= 0;
            coldwrite_on <= 0;
        end
        else begin
            coldwrite_on <= 1;
            waitcount_wr <= waitcount_wr + 1;
        end
    end
end


assign rd_en = !wait_on; // -> en_fifo_out || !prog_empty
assign wr_en = !prog_full;


fifo_9w16d rx_fifo (
.rst(rst),
.wr_clk(rx_clk),
.rd_clk(clk125MHz),
.din({data_enable, raw_data}),
.wr_en(wr_en),
.rd_en(rd_en),
.dout({en_fifo_out,data_fifo_out}),
.full(full),
.prog_full(prog_full),
.prog_empty(prog_empty),
.empty(empty)
);

assign raw_data_f = data_fifo_out;
assign data_enable_f = en_fifo_out;
	
	always @(posedge rx_clk) begin
	/*
		data_valid <= raw_ctl[0];
		data_error <= raw_ctl[0] ^ raw_ctl[1];
		data <= raw_data;
    */
		// check for inter-frame with matching upper and lower nibble
		if (raw_ctl == 2'b00 && raw_data[3:0] == raw_data[7:4]) begin
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