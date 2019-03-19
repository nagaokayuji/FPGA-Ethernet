//note: only works under seg <= 255.

module detect_errors2 #(parameter whereis_aux = 0)(
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
//localparam maxaux = 8'd5;
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

reg count_on;
localparam state_init = 0;
localparam state_started = 1;
localparam state_running = 2;
localparam state_initram = 3;
localparam state_count_off = 4;
localparam state_count_on = 5;
localparam state_ref = 6;
localparam state_finished = 7;

//reg [0:0] mem [65535:0];　
reg mem [65535:0];
reg [15:0] memaddr_reg;
reg mem_late;
wire [15:0] memaddr = {aux,seg[7:0]};
always @(posedge clk) begin
    memaddr_reg <= memaddr;
end
integer i;
reg [7:0] aux_tmp;
reg [15:0] addr;
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
		addr <= 0;
 
		count_on = 0;
		seg_prev = 0;
		state = state_initram;
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
		    state_initram: begin
		      addr <= addr + 1'b1;
		      mem[addr] <= 0;
		      if (addr == 16'hffff) begin
					state <= state_init;
					addr <= 0;
			 end
		    end
		
			state_init: begin
			 lostnum = 0;

				if (aux_on_3 && aux_tmp == 0) begin
				    seg_prev = 0;
				    aux = 0;
				    aux_prev = 0;
					state = state_count_off;
				end
			end
			state_count_off: begin
				//for (i = 0; i < 65535; i = i + 1) begin
				//	mem[i] = 1'b0;
				//end
                if (aux_on_delay) begin
                    aux <= aux_tmp;
                 end
				if ((seg == segment_number_max - 1 && aux == maxaux && aux_on_3))
					state <= state_count_on;

			end
			state_count_on: begin
				if (aux_on_delay) begin
					seg_tmp <= seg;
					seg_prev <= seg_tmp;
					aux <= aux_tmp;
					aux_prev <= aux;
				end
				if (aux_on_2) begin
					mem[memaddr_reg] <= 1'b1;
				end
				if ((seg == segment_number_max - 1 && aux == maxaux && aux_on_3)) begin
					addr <= 0;
					state <= state_ref;
				end
			end // end of state_count_on

			state_ref: begin
			    mem_late <= mem[addr];

				addr <= addr + 1'b1;
				if ((0 <= addr[15:8] && addr[15:8] <= maxaux) && (0 <= addr[7:0] && addr[7:0] < segment_number_max)) begin
					if (count >= maxcount) begin
						state <= state_finished;
					end
					count <= count + 1'b1;
					if (mem_late == 1'b1) begin
						ok <= ok + 1'b1;
					end
					else begin
						ng <= ng + 1'b1;
					end
				end
				
				mem[addr] <= 1'b0;
				if (addr[15:8] == maxaux && addr[7:0] == segment_number_max - 1'b1) begin
					state <= state_count_off;
					addr <= 0;
				end
			
			end

			state_finished: begin
			end
		endcase
	end
end

endmodule