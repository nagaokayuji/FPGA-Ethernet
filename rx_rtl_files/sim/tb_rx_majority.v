`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/12 21:51:17
// Design Name: 
// Module Name: tb_rx_majority
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


module tb_rx_majority;

localparam clknum = 80;
localparam step = 10;
localparam step125 = 8;

reg clk;
reg reset;
reg rx_clk;
reg [7:0] rx_data;
reg rx_enable;
reg sfd_wait;
wire [7:0] out1;
wire [7:0] out2;
wire [11:0] out3;


rx_majority rx_majority(
    .clk(clk),
    .reset(reset),
    .uart_rxd(),
    .uart_txd(),
    .rx_clk(rx_clk),
    .sfd_wait(sfd_wait),
    .rx_data(rx_data),
    .rx_enable(rx_enable),
    .rx_error(),
    .out1(out1),
    .out2(out2),
    .out3(out3)
    );
    
    
 always begin
    clk = 0;    #(step/2);
    clk = 1;    #(step/2);
 end
 always begin
    rx_clk = 0; #(step125/2);
    rx_clk = 1; #(step125/2);
 end
 
 always begin
 rx_data = 8'hde;#(step125);
 rx_data = 8'had; #(step125);
 rx_data = 8'hbe; #(step125);
 rx_data = 8'hef; #(step125);
 end
 always begin
    rx_enable = 0; #(step125 * 4);
    rx_enable = 1; #(step125 * 4);
 end
 
 initial begin
 reset = 0;
 rx_enable <= 0;
 rx_data <= 0;
 #(step) reset=1;
 #(step) reset=0;
 sfd_wait = 0;
 /*
 #(step*5);
 rx_enable = 1'b1;
 rx_data = 8'hde;
 #(step125);
 rx_data = 8'had;
 #(step125);
 rx_data = 8'hbe;
 #(step125);
 rx_data = 8'hef;
// rx_enable = 1'b0;
 
 #(step*3);
 #(step125);
 rx_enable = 1'b1;
 rx_data = 8'hde;
  #(step125);
 rx_data = 8'had;
 #(step125);
 rx_data = 8'hbe;
 #(step125);
 rx_data = 8'hef;
 rx_enable = 1'b0;
 
  #(step125);
 rx_data = 8'had;
 #(step125);
 rx_data = 8'hbe;
 #(step125);
 rx_data = 8'hef;
  rx_enable = 1'b1;
 rx_data = 8'hde;
 #(step125);
 rx_data = 8'had;
 #(step125);
 rx_data = 8'hbe;
 #(step125);
 rx_data = 8'hef;
// rx_enable = 1'b0;
 
 #(step*3);
 #(step125);
 rx_enable = 1'b1;
 rx_data = 8'hde;
  #(step125);
 rx_data = 8'had;
 #(step125);
 rx_data = 8'hbe;
 #(step125);
 rx_data = 8'hef;
 rx_enable = 1'b0;
 
  #(step125);
 rx_data = 8'had;
 #(step125);
 rx_data = 8'hbe;
 #(step125);
 rx_data = 8'hef;
   #(step125);
rx_data = 8'had;
#(step125);
rx_data = 8'hbe;
#(step125);
rx_data = 8'hef;
 rx_enable = 1'b1;
rx_data = 8'hde;
#(step125);
rx_data = 8'had;
#(step125);
rx_data = 8'hbe;
#(step125);
rx_data = 8'hef;
// rx_enable = 1'b0;

#(step*3);
#(step125);
rx_enable = 1'b1;
rx_data = 8'hde;
 #(step125);
rx_data = 8'had;
#(step125);
rx_data = 8'hbe;
#(step125);
rx_data = 8'hef;
rx_enable = 1'b0;
#20;
rx_data = 8'had;
#(step125);
rx_data = 8'hbe;
#(step125);
rx_data = 8'hef;
 */
 #(step125*60);
 $finish;
 end
    
endmodule