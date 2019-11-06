`timescale 1ns / 1ps

`include "../pkt8to256out.sv"
`include "../sync_fifo.v"
`include "../super_asyncFIFO.v"
`include "../asyncFIFO_glay.v"

module tb_pkt8to256out;

reg RST,clk,rxen;
reg [7:0] rxd;

wire en_out;
wire [255:0] out256b;
wire [3:0] id;
wire [15:0] segnum;

parameter whereis_segnum = 4;
parameter whereis_id = 6;

pkt8to256out #(.whereis_segnum(whereis_segnum), .whereis_id(whereis_id)) uut (
    .RST(RST),
    .rxd(rxd),
    .clk(clk),
    .rxen(rxen),

    .out256b_r(out256b),
    .en_out_r(en_out),
    .id_r(id),
    .segnum_r(segnum)
);
localparam CYCLE = 8;
localparam cycle = 8;
//localparam packetsize = 96;
integer packetsize = 96;


integer i;
reg [31:0] seed = 32'hdeadbeef;
task onepacket;
    input [3:0] id;
    input [15:0] segnum;
    input [7:0] incr;

    begin
        #cycle;
        rxen = 1'b1;

        for (i = 0; i < packetsize; i=i+1) begin
            if (i==whereis_id)
                rxd = {4'd0,id};
            else if (i == whereis_segnum)
                rxd = segnum[15:8];
            else if (i == whereis_segnum + 1'b1)
                rxd = segnum[7:0];
            else if (i == packetsize - 1) begin
                rxd = 8'haa;
            end
            else begin 
                rxd = i+incr;
                end
            #cycle;
        end
        rxen = 1'b0;
        #(cycle);
    end
endtask

always begin
    #1;
    clk = !clk;
    #3;
end

integer j,k,l;
initial begin
    $dumpfile("wf_pkt8to256out.vcd");
    $dumpvars(0, uut);
    RST = 1;
    clk = 0;
    rxd = 0;
    rxen = 0;
    #(CYCLE*10);
    RST = 0;
    #(CYCLE*4);
    #1;
    #1;
    #(CYCLE * 20);

    l = 0; 
    for (j = 1; j <= 6; j=j+1) begin
        for (k = 0; k < 10; k=k+1) begin
            packetsize = packetsize + k;
            l = l+1;
            onepacket(j,k,l);
            #(CYCLE*20);
        end
    end

    $finish;
end

endmodule