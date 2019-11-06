`timescale 1ns / 1ns

module tb_tx_memory_control;

reg clk,ena,rst;
wire data_user;
wire [7:0] txid,redundancy;
wire [15:0] segment_num;
wire  [23:0] bramaddr24b,vramaddr;
wire [1:0] vramaddr_c;
wire [11:0] byte_data_counter;
wire hdmimode;
wire [23:0] startaddr;

wire [7:0] doutb;
wire [7:0] aux;
wire start_frame,oneframe_done;

wire framemode;
wire maxdetect;
send_control send_control_i (
	.clk125MHz(clk),
	.RST(rst),
	.switches(8'b11011111),
	.busy(busy),
	.start_frame(start_frame),
	.oneframe_done(oneframe_done),
	.maxdetect(maxdetect),

	.segment_num_inter(segment_num),
	.txid_inter(txid),
	.aux_inter(aux),
	.start_sending(start_sending),
	.hdmimode(hdmimode),
	.framemode(framemode),
	.redundancy(redundancy)
);

byte_data byte_data_i(
	.clk(clk),
	.start(start_sending),
	.advance(1'b1),
	.aux(aux),
	.segment_num(segment_num),
	.index_clone(txid),
	.vramdata(doutb),
	.startaddr(startaddr),
	// output
	.busy(busy),
	.data(),
	.counter(byte_data_counter),
	.data_user(data_user),
	.data_valid(),
	.data_enable()
);
reg pclk;
VGA_Sync_Pulses vga(
	.i_Clk(pclk),
	.o_HSync(HSync),
	.o_VSync(VSync),
	.o_Col_Count(),
	.o_Row_Count()
);

tx_memory_control #(.SEGMENT_NUMBER_MAX(5))uut(
	.pclk(),
	.rst(rst),
	.clk125MHz(clk),
	.txid(txid),
	.hdmimode(hdmimode),
//	.framemode(framemode),
	.segment_num(segment_num),
	.redundancy(redundancy),
	.ena(ena),
	.rgb_r(8'haa),
	.rgb_b(8'hbb),
	.rgb_g(8'hcc),
	.byte_data_counter(byte_data_counter),
	.bramaddr24b(bramaddr24b),
	.data_user(data_user),

	.startaddr(startaddr),
	.oneframe_done(oneframe_done),
	.maxdetect(maxdetect),
	.doutb(doutb)
);



localparam cycle = 16;
initial begin
	$dumpfile("tb_tx_memory_control.vcd");
	$dumpvars(0,tb_tx_memory_control);
	clk = 0;
	ena = 0;
	rst = 1;
	#cycle;
	rst = 0;


#(cycle*700000);
$finish;
end

always begin
	#12 pclk = !pclk;
end
always begin
	#8 clk = !clk;
end

endmodule