module three2one
(
    input wire clk,rst,rx_en_w,clk125MHz, // clk, rst, en, clk for output
   (* mark_debug = "true" *)  input wire [7:0] rxdata_w, // input data, wire --> aligned: rx_data
    //input wire [3:0] switches, // input switches 
	// (* mark_debug = "true" *)	output reg [3:0] rx_id_inter=3, // for debug. maybe deleted soon
   (* mark_debug = "true" *)  output wire [7:0] data_out, // output data
  (* mark_debug = "true" *)   output reg en_out,		// output enable
  (* mark_debug = "true" *)   output wire lost		// loss detected. 
// (* mark_debug = "true" *)   output wire[2:0] comp3bit // for debug. maybe deleted soon
);
localparam whereisid = 6'h22; //default:6'h23(src port)
localparam r = 3;


reg [3:0] rx_id=0;
(* mark_debug = "true" *) reg [3:0] rx_id_inter = 3;
reg [3:0] rx_id_prev=3;
reg datalost = 0;
assign lost = datalost; // not important

(* mark_debug = "true" *) reg [11:0] addr = 12'b0; // address for array
reg [11:0]addr_after_id = 12'b0; // count up after ID detected
reg en_after_id = 1'b0; // enable signal after ID detected
(* mark_debug = "true" *) reg rx_en; // D-FF edge alignment
(* mark_debug = "true" *) reg [7:0] rxdata; // D-FF
reg [7:0] shift1_rxdata = 0;
//reg [23:0] startaddr = 0; // coordinate

// INPUT SIGNAL WIRES TO REGISTERS 
always @(posedge clk) begin
	rx_en <= rx_en_w; // wire -> register
	rxdata <= rxdata_w; // wire -> register
	shift1_rxdata <= rxdata;
end

// making addresses: addr, addr_after_id. 
// addr_after_id: 
// detect rx_id.
always @(posedge clk) begin
  if (rx_en)  // reg
    addr <= addr + 1'b1;
  else begin
    addr <= 1'b0;
	rx_id <= 4'b0; //id: initial number.
  end

// id process
    if (addr == whereisid) begin
        rx_id <= rxdata[3:0];
		addr_after_id <= 12'b0;
		rx_id_prev <= rx_id_inter;
	end
	else if (addr > whereisid) begin
		if (rx_id > 0 && rx_id < 4)
			en_after_id <= rx_en;
		if (en_after_id)
			addr_after_id <= addr_after_id + 1'b1;
		else addr_after_id <= 12'b0;
	end
end


// above: almost correct!

wire [7:0] q_b1,q_b2,q_b3;
reg [11:0] addr_b = 12'b0;
wire [7:0] out1,out2,out3;
wire comp_valid1,comp_valid2,comp_result1,comp_result2,comp_valid3,comp_result3;
always @(posedge clk) begin
	if (rx_id != 3'b0) begin
	rx_id_inter <= rx_id;
	end
	else rx_id_inter <= rx_id_inter;
end
wire en_after_id1 = rx_id == 1? en_after_id: 0;
wire en_after_id2 = rx_id == 2? en_after_id: 0;
wire en_after_id3 = rx_id == 3? en_after_id: 0;

reg [11:0] lastaddr1=0,lastaddr2=0,lastaddr3=0;
reg en_after_id1_pre=0,en_after_id2_pre=0,en_after_id3_pre=0;
always @(posedge clk) begin
	en_after_id1_pre <= en_after_id1;
	en_after_id2_pre <= en_after_id2;
	en_after_id3_pre <= en_after_id3;
	//1
	if (en_after_id1 && !en_after_id1_pre) begin
		lastaddr1 <= 0;
	end
	else if (en_after_id1) begin
		lastaddr1 <= lastaddr1 + 1'b1;
	end
	else lastaddr1 <= lastaddr1;
//2	
	if (en_after_id2 && !en_after_id2_pre) begin
		lastaddr2 <= 0;
	end
	else if (en_after_id2) begin
		lastaddr2 <= lastaddr2 + 1'b1;
	end
	else lastaddr2 <= lastaddr2;

//3
	if (en_after_id3 && !en_after_id3_pre) begin
		lastaddr3<= 0;
	end
	else if (en_after_id3) begin
		lastaddr3 <= lastaddr3 + 1'b1;
	end
	else lastaddr3 <= lastaddr3;
end
bram_compare dpram1(
	.dina(shift1_rxdata),
	.dinb(0),
	.addra(addr_after_id),
	.addrb(addr_b),
	.douta(out1),
	.doutb(q_b1),
	.wea(en_after_id1),
	.web(0),
	.clka(clk),
	.clkb(clk)
);
bram_compare dpram2(
	.dina(shift1_rxdata),
	.dinb(0),
	.addra(addr_after_id),
	.addrb(addr_b),
	.douta(out2),
	.doutb(q_b2),
	.wea(en_after_id2),
	.web(0),
	.clka(clk),
	.clkb(clk)
);
bram_compare dpram3(
	.dina(shift1_rxdata),
	.dinb(0),
	.addra(addr_after_id),
	.addrb(addr_b),
	.douta(out3),
	.doutb(q_b3),
	.wea(en_after_id3),
	.web(0),
	.clka(clk),
	.clkb(clk)
);

comparator comp1(
	.clk(clk),
	.rxdata(out1),
	.en(en_after_id),
	.bramout(out2),
	.valid(comp_valid1),
	.result(comp_result1),
	.shift4_result(0)
);

comparator comp2(
	.clk(clk),
	.rxdata(out1),
	.en(en_after_id),
	.bramout(out3),
	.valid(comp_valid2),
	.result(comp_result2),
	.shift4_result()
);

comparator comp3(
	.clk(clk),
	.rxdata(out2),
	.en(en_after_id),
	.bramout(out3),
	.valid(comp_valid3),
	.result(comp_result3),
	.shift4_result()
);
//=====================
// STATE CONTROL
//========================


localparam state_wait = 4'd0;
localparam state_got1 = 4'd1;
localparam state_lost_got1 = 4'd2;
localparam state_lost1_got2 = 4'd3;
localparam state_got1_got2 = 4'd4;
localparam state_done = 4'd5;
localparam state_lost1_got2_got3 = 4'd6;
localparam state_got1_lost2_got3 = 4'd7;
localparam state_datalost = 4'd8;
localparam state_got1_got2_got3 = 4'd9;

reg [3:0] state = state_wait;
reg start = 0;
always @(posedge clk) begin
	if (!en_after_id) begin
	case (state)
		state_wait:	begin //=================4'd0
			start <= 0;
			if (rx_id_inter == 1)	begin
				if (rx_id_prev == r) begin
					state <= state_got1; //=====4'd1
				end
				else begin
					state <= state_lost_got1; //=====4'd2
				end
			end
			else if (rx_id_inter == 2) begin
				state <= state_lost1_got2; //=======4'd3
			end
			else if (rx_id_inter == 3) begin
				state <= state_datalost;
			end
			else begin
				state <= state_wait;
			end
		end
		

		state_got1: begin  // =======4'd1
			start <= 0;
			if (rx_id_inter == 1) begin
				state <= state;
			end
			else if (rx_id_inter == 2) begin
				state <= state_got1_got2; // ====4'd4
			end
			else if (rx_id_inter == 3) begin
				state <= state_got1_lost2_got3; // ====4'd7
			end
			else begin
				state <= state;
			end
		end
			
		// start sending AND get next condition
		state_lost_got1: begin// ======4'd2
			start <= 1; // refresh and go to state_got1
			state <= state_got1;
		end

		state_lost1_got2: begin // ====4'd3
			start <= 0;
			if (rx_id_inter == 1) begin
				state <= state_lost_got1;
			end		
			else if (rx_id_inter == 2) begin
				state <= state;
			end
			else if (rx_id_inter == 3) begin
				state <= state_lost1_got2_got3; // ====4'd6 
			end
			else state <= state;
		end

		state_got1_got2: begin // =====4'd4
			start <= 0;
			if (rx_id_inter == 1) begin
				state <= state_lost_got1;
			end
			else if (rx_id_inter == 2) begin
				state <= state;
			end
			else if (rx_id_inter == 3) begin
				state <= state_got1_got2_got3; // ========4'd9
			end
		end

		state_done: begin //=====4'd5
			start <= 1;
			state <= state_wait;
		end

		state_lost1_got2_got3: begin// ====4'd6
		//comparing wait for one packet
			start <= 0;
			if (rx_id_inter == 1) begin
				state <= state_lost_got1;
			end
			else if (rx_id_inter == 2) begin
				state <= state_lost1_got2;
			end
			else if (rx_id_inter == 3) begin
				state <= state;
			end
			else  begin
				state <= state;
			end
		end

		state_got1_lost2_got3: begin // =============4'd7
			start <= 0;
			if (rx_id_inter == 1) begin
				state <= state_lost_got1; // start sending
			end
			else if (rx_id_inter == 2) begin
				state <= state_datalost;
			end
			else if (rx_id_inter == 3) begin
				state <= state;
			end
			else begin
				state <= state;
			end
		end

		state_datalost: begin //===========4'd8
		start <= 0;
		state <= state_wait;
		end

		state_got1_got2_got3: begin // =============4'd9
			start <= 0;
			if (rx_id_inter == 1) begin
				state <= state_done;
			end
			else if (rx_id_inter == 2) begin
				state <= state_done;
			end
			else if (rx_id_inter == 3) begin
				state <= state;
			end
			else begin
				state <= state;
			end
		end




		default: state <= state_wait;
	endcase
	end else state <= state;
end

//=========================
// end of STATE CONTROL
//====================

/*
reg comp1_2 = 1'b0,comp1_3 = 1'b0,comp2_3 = 1'b0;
wire comp_valid1_v = comp_valid1 && !en_after_id;
wire comp_valid2_v = comp_valid2 && !en_after_id;
wire comp_valid3_v = comp_valid3 && !en_after_id;

*/


// state machine controls only START signal.
// comparations are always run
reg start_inter=0;
reg [2:0] which_one = 0; // 1,2,3
wire [2:0] compares = {comp_result1,comp_result3,comp_result2}; // 1_2,2_3,1_3
reg [11:0] lastaddress = 0;
//wire [2:0] comp3bit = compares;
always @(posedge clk) begin
	if (state == state_datalost) begin
		datalost <= 1;
	end else begin
		datalost <= 0;
	end

	if (start) begin
		case (compares)
			3'b111: begin
				which_one <= 1; // anything is ok
				lastaddress <= lastaddr1;
				end
			3'b010: begin
				which_one <= 3; // 1 is incorrect
				lastaddress <= lastaddr3;
				end
			3'b001: begin
				which_one <= 1; // 2 is incorrect
				lastaddress <= lastaddr1;
				end
			3'b100: begin
				which_one <= 2; // 3 is incorrect
				lastaddress <= lastaddr2;
				end
			default: begin
				which_one <= 0;
				datalost <= 1;
			end
		endcase
	end
	datalost <= 0;
end

// sender logic
reg started = 0;
// correct_data from bram B port
wire [7:0] data_correct = which_one == 0? 0: which_one == 1? q_b1: which_one == 2? q_b2: which_one == 3? q_b3:0;
reg [7:0] data_correct_shift1 = 0;
always @(posedge clk) begin
	data_correct_shift1 <= data_correct;
	if (start) begin
		started <= 1;
	end
	else begin
		started <= 0;
	end
	if (addr_b > lastaddress) begin
		start_inter <= 1'b0;
		addr_b <= 0;
	end
	else begin
		start_inter <= started || start_inter;
	end

	if (start_inter || started) begin
		addr_b <= addr_b + 1'b1;
	end
	if (start_inter) begin
		en_out <= 1'b1;
	end
	else begin
		en_out <= 1'b0;
	end

		
end

assign data_out = data_correct_shift1;






endmodule