module five2one_v2 #(parameter whereisid = 0) (
	input wire clk,rst,rxen,
	input wire [7:0] rxd,
	output wire [7:0] data_out,
	output wire en_out,
	output wire lost,

	// BRAMs
	output wire [23:0] dina,
	input wire [23:0] douta,doutb,
	output wire [35:0] addra,addrb,
	output wire [2:0] wea
);
localparam r = 5;


wire [7:0] dina_0 = dina[7:0], dina_1 = dina[15:8], dina_2 = dina[23:16],
				douta_0 = douta[7:0], douta_1 = douta[15:8], douta_2 = douta[23:16];

reg [4:0] rx_id, rx_id_inter,rx_id_prev;
reg [11:0] addrcount, countedge, packet_length;
reg [7:0] rxd_s1,rxd_s2,rxd_s3;
reg  rxen_s1, rxen_s2, rxen_s3, rxen_s4;
//wire [11:0] addrcount = countedge - whereisid; // test. work ?
reg [11:0] toaddra,toaddra_s1,toaddra_s2,toaddra_s3;
reg toena, toena_s1, toena_s2, toena_s3;
always @(posedge clk) begin
	if (rst) begin
		addrcount = 0; countedge = 0;
		toena = 0;toaddra = 0; rx_id = 0;

	end else begin
		rxd_s1 <= rxd; rxd_s2 <= rxd_s1; rxd_s3 <= rxd_s2;
		rxen_s1 <= rxen; rxen_s2 <= rxen_s1; rxen_s3 <= rxen_s2; rxen_s4 <= rxen_s3;
		toaddra_s1 <= toaddra; toaddra_s2 <= toaddra_s1; toaddra_s3 <= toaddra_s2;
		toena_s1 <= toena; toena_s2 <= toena_s1; toena_s3 <= toena_s2;
		if (rx_id != 0) begin
			rx_id_inter <= rx_id;
		end else begin
			rx_id_inter <= rx_id_inter;
		end

		if (countedge == whereisid && rxen) begin
			rx_id <= rxd[3:0];
			toaddra <= 0;
			rx_id_prev <= rx_id_inter;
		end
		else if (countedge > whereisid) begin
			if (rx_id > 0 && rx_id < r + 1)
				toena <= rxen;
			if (toena)
				toaddra <= toaddra + 1'b1;
			else toaddra <= 0;
		end

		if (rxen) begin
			countedge <= countedge + 1'b1;
		end else begin
			countedge <= 0;
			rx_id <= 0; // important.
		end
	end
end

assign addra = {toaddra_s2, toaddra_s1, toaddra};
assign dina = {douta[15:8], douta[7:0], rxd};
assign wea = {toena_s2, toena_s1, toena};


/*
 place 3 comparators 
*/
wire comp_valid0,comp_valid1, comp_valid2, comp_result0, comp_result1, comp_result2;
wire [2:0] results = {comp_result2, comp_result1, comp_result0};
comparator comp0(
	.clk(clk),
	.rxdata(rxd_s1),
	.en(toena),
	.bramout(douta_0),
	.valid(comp_valid0),
	.result(comp_result0),
	.shift4_result()
);

comparator comp1(
	.clk(clk),
	.rxdata(rxd_s2),
	.en(toena_s1),
	.bramout(douta_1),
	.valid(comp_valid1),
	.result(comp_result1),
	.shift4_result()
);

comparator comp2(
	.clk(clk),
	.rxdata(rxd_s3),
	.en(toena_s2),
	.bramout(douta_2),
	.valid(comp_valid2),
	.result(comp_result2),
	.shift4_result()
);

//====================
// END of PLACEMENT
//=====================
// STATE MACHINE LOGIC
//===================
localparam state_wait = 0, state_got1 = 1;
reg [3:0] state = state_wait;
reg start = 0;

always @(posedge clk) begin
if (rst) begin
	state = 0;
	start = 0;
end else
if (!toena) begin
	case (state)
		state_wait: begin
			start <= 0;
			if (rx_id_inter == 1) begin
				state = state_got1;
			end
		end
		state_got1: begin
			

		end
	endcase

end
end

endmodule