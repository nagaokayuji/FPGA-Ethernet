module five2one_v2 #(parameter whereisid = 0) (
	input wire clk,rst,rxen,
	input wire [7:0] rxd,
	output wire [7:0] data_out,
	output wire en_out,
	//output wire lost,

	// BRAMs
	output wire [23:0] dina,
	input wire [23:0] douta,doutb,
	output wire [35:0] addra,addrb,
	output wire [2:0] wea
);
localparam r = 5;

wire [7:0]  douta_0 = douta[7:0], douta_1 = douta[15:8], douta_2 = douta[23:16];
reg [4:0] rx_id, rx_id_inter,rx_id_prev;
reg [11:0] addrcount, countedge, packet_length;
reg [7:0] rxd_s1,rxd_s2,rxd_s3, rxd_s4;
reg  rxen_s1, rxen_s2;//, rxen_s3, rxen_s4;
//wire [11:0] addrcount = countedge - whereisid; // test. work ?
reg [11:0] toaddra,toaddra_s1,toaddra_s2;//,toaddra_s3;
reg toena, toena_s1, toena_s2,  toena_s3;
wire toena_negedge = {toena,toena_s1} == 2'b01;
always @(posedge clk) begin
	if (rst) begin
		addrcount = 0; countedge = 0;
		toena = 0;toaddra = 0; rx_id = 0;
	end else begin
		rxd_s1 <= rxd; rxd_s2 <= rxd_s1; rxd_s3 <= rxd_s2; rxd_s4 <= rxd_s3;
		rxen_s1 <= rxen; rxen_s2 <= rxen_s1;// rxen_s3 <= rxen_s2; rxen_s4 <= rxen_s3;
		toaddra_s1 <= toaddra; toaddra_s2 <= toaddra_s1;// toaddra_s3 <= toaddra_s2;
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
			if (toena) begin
				toaddra <= toaddra + 1'b1;
			end
			else begin 
				toaddra <= 0;
			end
		end
		if (toena_negedge)
			packet_length = toaddra;

		if (rxen) begin
			countedge <= countedge + 1'b1;
		end else begin
			countedge <= 0;
			rx_id <= 0; // important.
		end
	end
end

assign addra = {toaddra_s2, toaddra_s1, toaddra};
assign dina = {douta[15:8], douta[7:0], rxd_s1};
assign wea = {toena_s2, toena_s1, toena};


/*
 place 3 comparators 
*/
wire comp_valid0,comp_valid1, comp_valid2, comp_result0, comp_result1, comp_result2;
wire [2:0] results = {comp_result2, comp_result1, comp_result0};
comparator comp0(
	.clk(clk),
	.rxdata(rxd_s2),
	.en(toena_s1),
	.bramout(douta_0),
	.valid(comp_valid0),
	.result(comp_result0)
);

comparator comp1(
	.clk(clk),
	.rxdata(rxd_s3),
	.en(toena_s2),
	.bramout(douta_1),
	.valid(comp_valid1),
	.result(comp_result1)
);
comparator comp2(
	.clk(clk),
	.rxdata(rxd_s4),
	.en(toena_s3),
	.bramout(douta_2),
	.valid(comp_valid2),
	.result(comp_result2)
);

//====================
// END of PLACEMENT
//=====================
// STATE CONTROL
//===================
localparam state_wait = 4'd0;
localparam state_got3 = 4'd1;
localparam state_got4 = 4'd2;
localparam state_got5 = 4'd3;
localparam state_sent3 = 4'd4;
localparam state_sent4 = 4'd5;
localparam state_sent5 = 4'd6;
localparam state_datalost = 4'd7;
reg [11:0] results_all;
reg [3:0] state = state_wait;
reg start = 0;
reg [2:0] whichone = 0;
function check;
input [11:0] results_all;
begin
	casex(results_all)
		12'bxxx_xxx_xxx_x11: check = 1; // 1
		12'bxxx_xxx_x1x_xx1: check = 1; // 2
		12'bxxx_xxx_1xx_xx1: check = 1; // 5

		12'bxxx_xx1_xxx_x1x: check = 1; // 3
		12'bxxx_x1x_xxx_x1x: check = 1; // 4
		12'bxx1_xxx_xxx_1xx: check = 1; // 6
		
		


		default: check = 0;
	endcase
end
endfunction

wire [2:0] valids = {comp_valid0, comp_valid1, comp_valid2};
wire allvalid = (valids === 3'b111);
reg [1:0] allvalid_reg;
wire allvalid_posedge = allvalid_reg == 2'b01;
reg allvalid_posedge_1s;
always @(posedge clk) begin
	allvalid_reg <= {allvalid_reg[0],allvalid};
	allvalid_posedge_1s <= allvalid_posedge;
	if (start_inter) begin
		results_all <= 0;
	end
	else if (allvalid_posedge) begin
		results_all <= {results_all[8:0],results};
	end
end
wire state_on = (!toena && (allvalid_reg[1]) && !rxen_s1);
always @(posedge clk) begin
	if (state_on) begin
		case (state)
			state_wait:	begin //=================4'd0
				start <= 0;
				case (rx_id_inter)
					3: state <= state_got3;
					4: state <= state_got4;
					5: state <= state_got5;
					default: state <= state;
				endcase
			end

			state_got3: begin
				if (results[1:0] == 2'b11) begin
					start <= 1;
					state <= state_sent3; // already sent. 
					whichone <= 0; // any one is ok
				end
				else begin 
					start <= 0;
					case (rx_id_inter)
						4: state <= state_got4;
						5: state <= state_got5;
						default: state <= state;
					endcase
				end
			end

			state_got4: begin
				if (results[1:0] == 2'b11) begin
					start <= 1;
					whichone <= 0;
					state <= state_sent4;
				end
				else if (results[2:0] == 3'b101 || results == 3'b011 || results == 3'b110) begin
					start <= 1;
					whichone <= 0;
					state <= state_sent4;
				end
				else begin 
					start <= 0;
					case (rx_id_inter)
						3: state <= state_got3;
						4: state <= state;
						5: state <= state_got5;
						default: state <= state_wait;
					endcase
				end
			end

			state_got5: begin
				// same to past 2 packets
				if (results[1:0] == 2'b11) begin
					start <= 1;
					whichone <= 0;
					state <= state_sent5;
				end
				// same to past 2 of 3 packets
				else if (results[2:0] == 3'b101 || results == 3'b011 || results == 3'b110) begin
					start <= 1;
					whichone <= 0;
					state <= state_sent5;
				end
				else if (check(results_all)) begin
					start <= 1;
					whichone <= 0;
					state <= state_sent5;
				end
				else begin
					start <= 0;
					case (rx_id_inter)
						3: state <= state_got3;
						4: state <= state_got4;
						5: state <= state;
						default: state <= state_wait;
					endcase
				end
			end

			state_sent3: begin
				start <= 0;
				case (rx_id_inter)
					3: state <= state;
					4: state <= state_sent4;
					5: state <= state_sent5;
				default: state <= state_wait;
				endcase
			end

			state_sent4: begin
				start <= 0;
				case (rx_id_inter)
					4: state <= state;
					5: state <= state_sent5;
					default: state <= state_wait;
				endcase
			end

			state_sent5: begin
				start <= 0;
				case (rx_id_inter)
					5: state <= state;
					default: state <= state_wait;
				endcase
			end
		endcase // end of case(state)

	end 
	else begin 
		state <= state;
	end
end
//=========================
// end of STATE CONTROL
//====================


// lets start
reg start_inter;
reg start_inter_1s;
reg [11:0] count_addrb;
reg en_out_reg;

always @(posedge clk)  begin
	if (rst) begin
		start_inter = 0;
		count_addrb = 0;
		en_out_reg = 0;
	end else begin
		start_inter_1s <= start_inter;
		if (start) begin
			start_inter <= 1;
		end else begin
			if (count_addrb >= packet_length) begin
				start_inter <= 0;
				count_addrb <= 0;
				en_out_reg <= 0;
			end
			else begin
				if (start_inter) begin
					start_inter <= 1;
					en_out_reg <= 1;
					count_addrb <= count_addrb + 1'b1;
				end
			end
		end
	end
end //end of always

assign addrb = {3{count_addrb}};
assign en_out = en_out_reg;
assign data_out = (whichone == 0) ? doutb[7:0] : (whichone == 1) ? doutb[15:8] : (whichone == 2) ? doutb[23:16] : 8'hxx;
endmodule