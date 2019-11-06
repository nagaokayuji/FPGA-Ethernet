`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2018/06/21 15:03:36
// Design Name:
// Module Name: ext_preamble
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


module ext_preamble(
    inout wire rx_clk,
//    input wire reset,
    input wire [7:0] rx_data,
    input wire rx_enable,
    //input wire rx_error,
    output reg sfd_wait

    );



// if 1: in preamble
 //   reg sfd_wait;
    //assign rx_after_sfd = ~sfd_wait;
    always @(posedge rx_clk) begin
      if (rx_enable == 1'b1) begin
        if (rx_data == 8'hd5) begin
          sfd_wait <= 1'b0;
        //else sfd_wait <= 1'b1;
        end
        if (sfd_wait == 1'b0)
          sfd_wait <= sfd_wait;
      end
      else sfd_wait <= 1'b1;// not in rx
    end
    
    // if (!sfd_wait && en) == data enable




endmodule
