`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/10/24 20:59:43
// Design Name: 
// Module Name: ext_crc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ext_crc(
input wire rx_clk,
input wire [7:0] rx_data,
input wire rx_enable,
input wire sfd_wait,

output  [7:0] rawdata,
output  raw_en

    );
    
    wire en_exp = !sfd_wait && rx_enable;
    reg [3:0] en_shift = 0;
    reg [7:0] data_shift1,data_shift2,data_shift3,data_shift4;
    reg en_rise = 0;
    always @(posedge rx_clk) begin
        en_shift <= {en_shift[2:0],en_exp};
        data_shift1 <= rx_data;data_shift2 <= data_shift1;data_shift3<=data_shift2;data_shift4 <= data_shift3;
        
        
   
    
    end
    
    assign rawdata = data_shift4;
    assign raw_en = en_exp && en_shift[3];
    
endmodule
