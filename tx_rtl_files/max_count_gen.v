module max_count_gen (
	input wire [7:0] switches,
	output reg [27:0] max_count,
	output wire [15:0] segment_num_max,
	output wire [7:0] redundancy
);


reg [16:0] max_counter_samepacket = 17'd30;
// define speed & how fast
always @(switches) begin
	case (switches[3:0])
		4'b0000:	max_count <= 27'd124999999; // 1 pps
		4'b0001:	max_count <= 27'd62499999; // 2 pps
		4'b0010:	max_count <= 27'd12499999; // 10 pps
		4'b0011:	max_count <= 27'd6249999; //20 pps
		4'b0100:	max_count <= 27'd2499999; // 50 pps
		4'b0101:	max_count <= 27'd1249999; //100 pps
		4'b0110:	max_count <= 27'd624999; // 200pps
		4'b0111:	max_count <= 27'd249999; //500 pps
		4'b1000:	max_count <= 27'd124999; // 1000 pps
		4'b1001:	max_count <= 27'd62499; //2000 pps
		4'b1010:	max_count <= 27'd24999; //5000 pps
		4'b1011:	max_count <= 27'd12499; //10000 pps
		4'b1100:	max_count <= 27'd6249; //20000 pps
		4'b1101:	max_count <= 27'd2499; //50000 pps
		4'b1110:	max_count <= 27'd1249; //100000pps
		default:	max_count <= 27'd30; //ok? 
	endcase
	/*
	    case (switches[7:6])
        2'b00: max_counter_samepacket = 17'd30;
        2'b01: max_counter_samepacket = 17'd1249;   // 100000 pps
        2'b10: max_counter_samepacket = 17'd12499;  // 10000pps
        2'b11: max_counter_samepacket = 17'd124999; // 1000pps
     endcase
		*/
end

assign segment_num_max = (switches[7:6] == 2'b00) ? 1:
															switches[7:6] == 2'b01 ? 5:
															switches[7:6] == 2'b10 ? 50:
															switches[7:6] == 2'b11 ? 100 : 1;
assign redundancy = switches[5:4] == 2'b00 ? 1:
												switches[5:4] == 2'b01 ? 3:
												switches[5:4] == 2'b10 ? 5:
												switches[5:4] == 2'b11 ? 7 : 1;

endmodule