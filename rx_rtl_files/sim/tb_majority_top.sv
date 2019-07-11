`timescale 1ns / 1ps
`include "../majority_top.sv"
`include "../pkt8to256out.sv"
`include "../sync_fifo.v"
`include "../super_asyncFIFO.v"
`include "../asyncFIFO_glay.v"

module tb_majority_top;



reg RST,dclk,rx_en;
reg [7:0] rx_data;

reg ui_clk;
wire wr_busy,rd_busy,rd_data_valid;
wire  [255:0] rd_data;
wire wr_en,rd_en;
wire [24:0] wr_addr,rd_addr;
wire [255:0] wr_data;

parameter whereis_segnum = 34;
parameter whereis_id = 36;
localparam packetsize = 101;

localparam dc = 8; //clock period for dclk
localparam uc = 5; //clock period for ui_clk

always begin
    #(dc/4) dclk = !dclk;
    #(dc/4);
end
always begin
    #1 ui_clk = !ui_clk;
    #(uc/2 - 1);
end
integer i;
integer j,k,l;
reg [31:0] seed = 32'hdeadbeef;
task onepacket;
    input [3:0] id;
    input [15:0] segnum;
    input [7:0] incr;

    begin
        #dc;
        rx_en = 1'b1;

        for (i = 0; i < packetsize; i=i+1) begin
            if (i==whereis_id)
                rx_data = {4'd0,id};
            else if (i == whereis_segnum)
                rx_data = segnum[15:8];
            else if (i == whereis_segnum + 1'b1)
                rx_data = segnum[7:0];
            else if (i == packetsize - 1) begin
                rx_data = 8'haa;
            end
            else begin 
                rx_data = i+incr;
                end
            #dc;
        end
        rx_en = 1'b0;
        #(dc);
    end
endtask
majority_top uut (
    .RST(RST),
    .rx_data(rx_data),
    .rx_en(rx_en),
    .dclk(dclk),

    .ui_clk(ui_clk),
    .wr_busy(wr_busy),
    .rd_busy(rd_busy),
    .rd_data(rd_data),
    .rd_data_valid(rd_data_valid),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .wr_data(wr_data),
    .wr_addr(wr_addr),
    .rd_addr(rd_addr)

);

initial begin
    $dumpfile("wf_majority_top.vcd");
    $dumpvars(0,tb_majority_top);
    RST = 'h1;
    rx_data = 'h0;
    rx_en = 'h0;
    dclk = 'h0;
    ui_clk = 'h0;
    #(dc*25);
    RST = 'h0;

    for(i=0;i<5; i=i+1) begin
        l = 0;
        #(dc*2);
        for(j=1; j<=5;j=j+1) begin
            l = l + 1;
            onepacket(j,i,l);
        end
        #(dc*4);
    end

    #(dc * 2000);
    $finish;

end


endmodule