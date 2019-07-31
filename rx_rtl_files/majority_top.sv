`timescale 1ns / 1ps


module majority_top #(parameter whereis_segment_num = 34, whereis_id = 36) (
    input  wire RST,
    input  wire [7:0] rx_data, // rx data
    input  wire rx_en, // rx enable
    input  wire dclk, // 125.25 MHz clock

    // MIG signals
    input  wire ui_clk, // 200 MHz clock used for MIG
    input  wire wr_busy,
    input  wire rd_busy,
    input  wire [255:0] rd_data,
    input  wire rd_data_valid,
    output wire wr_en,
    output wire rd_en,
    output wire [255:0] wr_data,
    output wire [24:0] wr_addr,
    output wire [24:0] rd_addr
    //
);

// convert to 256bit signals
wire [255:0] rx256b;
wire en256b;
wire [3:0] id256b;
wire [15:0] segnum256b;

pkt8to256out #(.whereis_segnum(34), .whereis_id(36)) pktcnv_i (
    .RST(RST),
    .rxd(rx_data),
    .clk(dclk), // 125MHz
    .rxen(rx_en),

    .out256b_r(rx256b),
    .en_out_r(en256b),
    .id_r(id256b),
    .segnum_r(segnum256b)
);

//==================================================
// ADDRESS MAP
//--------------------------------------------------
// addr[5:0] -> packetdata.  increment
// addr[7:6] -> past data.
// addr[23:8] -> segnum.
//===================================================
assign wr_addr[24] = 1'b0;
assign rd_addr[24] = 1'b0;
assign wr_addr[23:8] = segnum256b;
assign rd_addr[23:8] = segnum256b;



endmodule