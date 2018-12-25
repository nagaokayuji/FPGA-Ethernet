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

*/
module detect_errors #(parameter whereis_aux = 0)(
	input wire clk,
	input wire rst,
	(* mark_debug = "true" *) input wire rx_en,
	(* mark_debug = "true" *) input wire [7:0] rx_data,
	(* mark_debug = "true" *) output reg [31:0] count,
	(* mark_debug = "true" *) output reg [31:0] ok,
	(* mark_debug = "true" *) output reg valid,
	(* mark_debug = "true" *) output reg [2:0] state
);

localparam maxcount = 100000;
localparam maxaux = 8'b11111111;

localparam validation_max = 3;
reg [7:0] validation_rom [validation_max - 1: 0];
reg [15:0] count_edge;
reg [7:0] aux = maxaux;
reg [7:0] aux_prev;

wire aux_on = (whereis_aux == count_edge) && valid;
wire aux_on_1 = (whereis_aux + 1'b1 == count_edge) && valid;
wire [7:0] next_aux = (aux_prev == maxaux) ? 0 : (aux_prev + 1'b1);
wire aux_ok = (aux == next_aux);

localparam state_init = 0;
localparam state_started = 1;
localparam state_running = 2;
localparam state_finished = 7;

always @(posedge clk) begin
	if (rst) begin
		count_edge <= 16'b0;
		count <= 0;
		ok <= 0;
		valid <= 1'b0;
		aux <= maxaux;
		aux_prev <= 0;
		state = state_init;
	end
	else begin
		if (rx_en) begin
			count_edge <= count_edge + 1'b1;
		end else begin
			count_edge <= 0;

		end

	case (state)
		state_init: begin
			state = state_started;
		end

		state_started: begin
			if (rx_en) begin
				valid <= 1'b1;
				if (aux_on) begin
					if (rx_data === 8'h00) begin
						aux <= rx_data;
						aux_prev <= aux;
						count <= count + 1'b1;
						ok <= ok + 1'b1;
						state <= state_running;
					end
				end
			end else begin
				valid <= 0;
			end
		end

		state_running: begin
			if (rx_en) begin
				valid <= 1'b1;
				if (aux_on) begin // 1 clock enable.
					aux <= rx_data;
					aux_prev <= aux;
				end
				else if (aux_on_1) begin
					count = count + 1'b1;
					if (aux_ok) begin
						ok = ok + 1'b1;
					end
				end
			end // END of " if (rx_en) "
			else begin // if !rx_en
				valid <= 0;
				if (count == maxcount) begin
					state <= state_finished;
				end
			end
		end // end of this state.

		state_finished: begin
			state = state_finished;
		end
	endcase
	end // end of !rst
end // end of always block
endmodule