/*
ensure data correctly
outputs after 3 clocks
*/

module tx_memory_control #(parameter SEGMENT_NUMBER_MAX = 1)//125
(
	input wire pclk, 	// pixel clock
	input wire rst,
	input wire clk125MHz, // ethernet tx clock
	input wire [7:0] txid,  // ID
	input wire [15:0] segment_num, // segment_number. add next
	input wire [7:0] redundancy,
	input wire [15:0] segment_num_max,
	input wire ena,   // en signal for VRAMs A port
	input wire [7:0] rgb_r, // from hdmi_top
	input wire [7:0] rgb_g, // from hdmi_top
	input wire [7:0] rgb_b, // from hdmi_top
	input wire [15:0] bramaddr24b,

	input wire [11:0] byte_data_counter,

	input wire data_user, 
	input wire hdmimode,
	

	// output
	output reg [15:0] startaddr = 0,
	output wire oneframe_done,
	output wire maxdetect,

	output wire [7:0] doutb
);

/*
 delete startaddr & lastaddr @ byte_data.
 '''
 use count_for_bram LIKE same address for any txid.
 switch automatically @ out of byte_data.
 '''
*/
reg [2:0] vramaddr_c;
(* mark_debug = "true" *) reg [15:0] vramaddr;
localparam start_with_latency = 46 - 3 ;
localparam start_pixel = 46;
localparam payload = 1440 - 3;
localparam max_vramaddr = (320*180);
assign maxdetect = (txid == 1) && (vramaddr >= max_vramaddr - 1);



reg [1:0] data_user_reg = 2'b0;


reg [3:0] state = 0;
reg count_for_bram_en;
reg [11:0] count_for_bram;
reg [15:0] startaddr_ram [SEGMENT_NUMBER_MAX - 1: 0];
localparam state_default = 0;
localparam id1 = 1;
localparam id_not1 = 2;
reg [7:0] id_prev;

wire [2:0] next_vramaddr_c = (vramaddr_c == 2) ? 0: vramaddr_c + 1;

reg [2:0] vramaddr_d3; // three times use// 0,1,2,0,1,2,...
wire [15:0] next_vramaddr = (vramaddr_d3 == 2) ? 
					((vramaddr < max_vramaddr - 1'b1) ? vramaddr + 1: 0): vramaddr;
wire [2:0] next_vramaddr_d3 = (vramaddr_d3 == 2) ?
		0: (vramaddr_d3 + 1);

(* mark_debug = "true" *) reg addr_overed, addr_overed_before;
reg resetplease;
assign oneframe_done = (redundancy == 1) ? 
	(vramaddr >= max_vramaddr - 1) : 
	( addr_overed && ( txid >= redundancy) && (segment_num == segment_num_max - 1));

wire data_user_neg = (data_user_reg == 2'b10);
always @(posedge clk125MHz) begin
	if (rst) begin
		addr_overed = 0;
		state = 0;
		vramaddr = 0;
		vramaddr_c = 0;
		startaddr = 0;
		resetplease = 0;
	end
	else begin

			case (state)
				state_default: begin
					if (txid != 1) state = id_not1;
					else if (txid == 1) state = id1;

					vramaddr_c <= 0;
					vramaddr <= 0;
					vramaddr_d3 <= 0;
				end
				id1: begin
					if (txid != 1) state = id_not1;

					if (hdmimode /*&& (redundancy != 1)*/ && (vramaddr >= max_vramaddr - 1 )) begin
						addr_overed <= 1'b1;
					end


						if (data_user_neg && !addr_overed) begin
							vramaddr_c = 0;
							vramaddr <= vramaddr + 1;
						end

						if (byte_data_counter == start_with_latency - 6) begin
							startaddr <= vramaddr;
							startaddr_ram[segment_num] = vramaddr;
						end
						if (byte_data_counter >= start_with_latency && (byte_data_counter < start_with_latency + payload)) begin
							vramaddr <= next_vramaddr;
							if (byte_data_counter != start_with_latency)
								vramaddr_d3 <= next_vramaddr_d3;
						end
						else begin
							vramaddr_d3 <= 0;
						end

						vramaddr_c <= vramaddr_d3;
						if (byte_data_counter >= start_pixel  && (byte_data_counter < start_pixel + payload ))begin
							count_for_bram_en <= 1;
							if (count_for_bram_en) begin
								count_for_bram <= (byte_data_counter - start_pixel);
								end
						end
						else begin
							count_for_bram_en <= 0;
							count_for_bram <= 0;
						end
			//		end
				end
				id_not1: begin
					vramaddr_c <= 0;
					vramaddr_d3 <= 0;
					if (byte_data_counter == start_with_latency - 6) begin
						startaddr <= startaddr_ram[segment_num];
					end
					if (txid == 1) begin
						if (addr_overed) begin
							state = state_default;
							addr_overed <= 1'b0;
						end
						else begin
							state = id1;
						end
					end
				end
			endcase
	end
end

always @(posedge clk125MHz) begin
	// shift
	data_user_reg <= {data_user_reg[0] ,data_user};

end


wire [7:0] doutb_r,doutb_g,doutb_b;
wire [7:0] doutb_first;
wire [7:0] doutb_not_first;


vram_control vram_control_i(
	.pclk(pclk),
	.clk125MHz(clk125MHz),
	.ena(ena),
	.bramaddr24b(bramaddr24b),
	.vramaddr(vramaddr),
	.vramaddr_c(vramaddr_c),
	.din_rgb_r(rgb_r),
	.din_rgb_g(rgb_g),
	.din_rgb_b(rgb_b),
	.doutb_first(doutb_first),
	.doutb_rgb({doutb_r,doutb_g,doutb_b})
);


wire wea_bram1080 = (txid == 1) && count_for_bram_en;
reg [7:0] doutb_first_reg;
reg [7:0] doutb_first__reg,doutb_first___reg;
reg [7:0] doutb_not_one_reg[SEGMENT_NUMBER_MAX - 1 : 0];
reg [0:0] wea_bram_not_one_reg[SEGMENT_NUMBER_MAX - 1: 0];
reg [12:0] count_for_bram_reg;

wire [7:0] doutb_not_one[SEGMENT_NUMBER_MAX - 1 : 0];
wire [0:0] wea_bram_not_one[SEGMENT_NUMBER_MAX - 1 : 0]; 
wire [7:0] doutb_muxed = doutb_not_one_reg[segment_num];

// doutb: 
assign doutb = (txid==1) ? 
				doutb_first_reg: doutb_muxed;

integer m;
always @(posedge clk125MHz) begin

	for (m = 0; m < SEGMENT_NUMBER_MAX; m = m + 1) begin
		doutb_not_one_reg[m] <= doutb_not_one[m];
		wea_bram_not_one_reg[m] <= wea_bram_not_one[m];
	end
	count_for_bram_reg <= count_for_bram;
	doutb_first_reg <= doutb_first;
	doutb_first__reg <= doutb_first_reg;
	doutb_first___reg <= doutb_first__reg;
end

genvar i;
wire [12:0] addrb_not_one = (byte_data_counter >= start_with_latency + 1)? (byte_data_counter - start_with_latency - 1) : 0;
generate
	for (i=0; i < SEGMENT_NUMBER_MAX; i = i + 1) begin
		bram_1080 bram_1080_inst(
			.clka(clk125MHz),
			.wea(wea_bram_not_one_reg[i]),
			.addra(count_for_bram_reg),
			.dina(doutb_first___reg),
			.clkb(clk125MHz),
			.addrb(addrb_not_one),
			.doutb(doutb_not_one[i])
		);
	end
endgenerate

function dmux;
	input [15:0] j;
	input [15:0] segment_num;
	input wea;
		if (j == segment_num) begin
			dmux = wea;
		end 
		else begin
			dmux = 1'b0;
		end
endfunction

genvar k;
generate
	for (k = 0; k < SEGMENT_NUMBER_MAX; k = k + 1) begin
		assign wea_bram_not_one[k] = dmux(k,segment_num,wea_bram1080);
	end
endgenerate


endmodule