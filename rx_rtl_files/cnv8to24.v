`timescale 1ns / 1ps


module cnv8to24(
    //input wire clk, // pck
    input wire [7:0] data8b,
    input wire en,
    //input wire [20:0] startaddr8b,
    input wire dclk,
    
    output reg [15:0] addr2vram = 0,
    output reg [1:0] count = 0,
    output reg [7:0] data_rgb,//data_r=0,data_g=0,data_b=0,
    output wire wea_r,wea_g,wea_b
);
localparam max_addr = 57600;

reg [23:0] startaddr;
reg [7:0] data8b_reg;
reg en_reg;
reg [1:0] count_before;
reg [31:0] detect;
wire detect_on = (detect == 32'h05a80000);
reg [3:0] state;
localparam state_wait = 0;
localparam state_addr2=1;
localparam state_addr3=2;
localparam state_gotaddr=3;
localparam state_datain=4;

assign wea_r = (count==1);
assign wea_g = (count==2);
assign wea_b = (count==3);

wire [15:0] next_addr2vram = (addr2vram < max_addr) ? addr2vram + 1'b1 : 0;
always @(posedge dclk) begin
// edge alignment
	data8b_reg <= data8b;
	data_rgb <= data8b_reg;
	en_reg <= en;
	detect <= {detect[23:0],data8b_reg};


	if (en_reg) begin
		case (state)
			state_wait: begin
			count <= 0;
			startaddr <= 0;
				if (detect_on) begin
					startaddr[23:16] <= data8b_reg;
					state <= state_addr2;
				end
			end

			state_addr2: begin
				startaddr[15:8] <= data8b_reg;
				state <= state_addr3;
			end

			state_addr3: begin
				startaddr[7:0] <= data8b_reg;
				addr2vram <= {startaddr[15:8],data8b_reg};
				state <= state_gotaddr;
				count <= 0;
				count_before <= 0;
			end
			state_gotaddr: begin
				count_before <= count;
				count <= 1;
				state <= state_datain;
			end
			state_datain: begin
				count_before <= count;
				if (count == 3) begin
					addr2vram <= next_addr2vram;
					count <= 1;
				end
				else begin
					count <= count + 1'b1;
				end
			end
		endcase		
	end
	else begin
		state <= state_wait;
		count <= 0;
	end

end

endmodule
