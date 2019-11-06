`timescale 1ns / 1ps
//----------------
// log:
// have to detect errors by 'aux' number.
// aux number: 8 bits length.
// --~~ -~ -> --~-~-~-~-~ : 1 clock 
// aux: 8bits. -> 0..255
//-------------------

/*
input signal:

output signal:
result-~-~-- === -~-~-~ === (count, ok, valid)


aux : same data * (segment_num_max)

function (prev_aux, aux):
	if nextcount(prev_aux) === aux :
		ok ++;
	elif 
	ry


	next && nowcount;;
	
	function next_aux;
		input [7:0] prev_aux; 
		input [7:0] samecount;
		input [7:0] maxaux;
		
		begin

		end
	
	endfunction

// calculate how many packets lost.
	function skip_count;
		input prev_aux;
		input samecount;
		input maxaux;

		begin

		end

*/
module detect_errors #(parameter whereis_aux = 0)(
	input wire clk,
	input wire rst,
	input wire [15:0] segment_number_max,
	(* mark_debug = "true" *) input wire [15:0] seg,
	(* mark_debug = "true" *) input wire rx_en,
	(* mark_debug = "true" *) input wire [7:0] rx_data,
	(* mark_debug = "true" *) output reg [31:0] count,
	(* mark_debug = "true" *) output reg [31:0] ok,
	(* mark_debug = "true" *) output reg [31:0] ng,
	(* mark_debug = "true" *) output reg [31:0] lostnum,
	(* mark_debug = "true" *) output reg valid,
	(* mark_debug = "true" *) output reg [2:0] state
);

localparam maxcount = 500000;
localparam maxaux = 8'b11111111;

reg [15:0] count_edge;
(* mark_debug = "true" *) reg [7:0] aux = maxaux;
(* mark_debug = "true" *) reg [7:0] aux_prev;
(* mark_debug = "true" *) reg [7:0] samecount;
reg [15:0] seg_prev,seg_tmp;

wire aux_on = (whereis_aux == count_edge && rx_en);// && valid;
wire aux_on_delay = (whereis_aux + 3 == count_edge);
wire aux_on_1 = (whereis_aux + 5 == count_edge);// && valid;
wire aux_on_2 = (whereis_aux + 6 == count_edge);
wire aux_on_3 = (whereis_aux + 7 == count_edge);

//wire [7:0] next_aux = (aux_prev == maxaux) ? 0 : (aux_prev + 1'b1);
//wire aux_ok = (aux == next_aux);
wire [7:0] next_samecount = (samecount == segment_number_max - 1)?
							0: samecount + 1;
							
reg count_on;
							

reg [31:0] cal_los_inter;
reg [31:0] cal_los__inter;
reg [31:0] cal_los___inter;
//-~-~-~-^ function ----------------
function [7:0] next_aux_func;
	input [7:0] aux_prev;
	input [7:0] samecount;
	input [15:0] segment_number_max;

	begin
		if (samecount == segment_number_max - 1) begin
			next_aux_func = aux_prev + 1'b1;
		end
		else begin
			next_aux_func = aux_prev;
		end
	end
endfunction
//-=-=-=-=
function [15:0] next_seg_func;
    input [7:0] aux_prev;
    input [7:0] aux;
    input [15:0] seg_prev;
   // input [15:0] seg;
    begin
        if (aux_prev == aux) begin
            next_seg_func = seg_prev + 1'b1;
        end
        else begin
            next_seg_func = 0;
        end
    end
endfunction


//-~-~-~-~-~
function [31:0] calculate_losts;
	input [7:0] aux_prev;
	input [7:0] samecount;
	input [7:0] aux;
	input [15:0] segment_number_max;

	begin
		if (aux > aux_prev) begin
			calculate_losts = (segment_number_max - samecount - 1) + (aux - aux_prev - 1)*segment_number_max;
		end
		else begin
			calculate_losts = (segment_number_max - samecount - 1) + (segment_number_max - aux_prev + aux) * segment_number_max;
		end
	end
endfunction
// -------function----------

//==============
// instantiate HLS IP : lostnum_0
//================
reg ap_start;
wire ap_idle = ~ap_start;
wire ap_done,ap_ready;
wire [31:0] ap_return;
reg [7:0] samecount_prev;
lostnum_0 lostnum_i (
    .ap_clk(clk),
    .ap_rst(rst),
    .ap_start(ap_start),
    .ap_done(ap_done),
    .ap_idle(ap_idle),
    .ap_ready(ap_ready),
    .ap_return(ap_return),
    .segment_num_max({16'h0000,segment_number_max}),
    .aux_pre({24'h000000,aux_prev}),
    .aux({24'h000000,aux}),
    .samecount({24'h000000,samecount_prev})
    );


localparam state_init = 0;
localparam state_started = 1;
localparam state_running = 2;
localparam state_run = 3;
localparam state_run_error1 = 4;
localparam state_run_error2 = 5;
localparam state_run_error3 = 6;
localparam state_finished = 7;

reg mem [65535:0];
wire [23:0] memaddr = {aux,seg[7:0]};
// count


localparam state_count_on = 5;
localparam stat_count_off = 4;
reg [7:0] aux_tmp;
always @(posedge clk) begin
	if (rst) begin
		count_edge <= 16'b0;
		count <= 0;
		ok <= 0;
		lostnum = 0;
		valid <= 1'b0;
		aux <= 0;
		aux_prev <= 0;
		ng <= 0;
		lostnum <= 0;
		samecount <= 0;
		ap_start = 0;
		count_on = 0;
		seg_prev = 0;
		state = state_init;
	end
	else begin //!rst
	
	//------- counting edge.------
		if (rx_en) begin
			count_edge <= count_edge + 1'b1;
			if (aux_on) begin
				aux_tmp <= rx_data;
				//aux_prev <= aux;
			end 
		end
		else begin
			count_edge <= 0;
		end
	//~~-~-~-~-~-~-~-~-~-~-~-~-~--
		case (state)
			state_init: begin
			 lostnum = 0;
			 ap_start = 0;
				if (aux_on_3 && aux_tmp == 0) begin
				    seg_prev = 0;
				    aux = 0;
				    aux_prev = 0;
					samecount = 0;
					state = state_run;
				end
			end

			state_run: begin
				if (aux_on_delay) begin
				    seg_tmp <= seg;
				    seg_prev <= seg_tmp;
				    
					aux <= aux_tmp;
					aux_prev <= aux;
				end
                
				else if (aux_on_1) begin
				    samecount_prev <= samecount;
					count <= count + 1'b1;
					if (aux_prev == aux)
						samecount <= next_samecount;
					else samecount <= 0;

					//if (next_aux_func(aux_prev, samecount, segment_number_max) == aux) begin
					if (next_seg_func(aux_prev,aux,seg_prev) == seg) begin
						ok <= ok + 1'b1;
						//samecount <= next_samecount;
					end
					else begin // not ok
						state <= state_run_error1;
						ng <= ng + 1'b1;
					end
				end
				if (count >= maxcount) state = state_finished;
			end // end of state_run

			state_run_error1:begin
			 ap_start = 1;
			 state = state_run_error2;
				
			end
			state_run_error2: begin
               ap_start = 0;
               if (ap_done) begin
                   lostnum <= lostnum + ap_return;
                   state = state_run;
               end 
			end
			state_run_error3: begin

			end

			state_finished: begin
			end
		endcase
	end
end
endmodule