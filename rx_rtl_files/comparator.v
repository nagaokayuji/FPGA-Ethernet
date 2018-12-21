`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/09 16:39:36
// Design Name: 
// Module Name: comparator
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


module comparator(
    input wire clk,
    //input wire [10:0] addr, //not needed...
    input wire [7:0] rxdata,
    /*
    input wire start_sign,// just a moment
    input wire end_sign, // for a while 
    */
    input wire en,
    input wire [7:0] bramout,
    output reg valid,
    output reg result = 1'b0,
		output wire shift4_result
    );
// valid: 00: invalid 01: in progress  11: valid result
/* 
// inter_ssign: start_sign検知でhigh,endまで．
*/
/*
reg inter_ssign;
    always @(posedge clk) begin
        if (!end_sign)
            inter_ssign <= start_sign || inter_ssign;
        else
            inter_ssign <= 1'b0;
    end 

// ijou
reg started;
    always @(posedge clk) begin
        if (start_sign) 
            started <= 1'b1;
        if (end_sign) 
            started <= 1'b0;
    end
    // rising detection...
    // it appeals the FIRST rizing start_sign


    always @(posedge clk) begin
        if (started) begin
      //      inter_ssign <= 1'b1;
            valid <= 1'b0;
            if (rxdata != bramout)
                result <= 1'b0;
            else result <= 1'b1;
        end else if (end_sign) begin
            valid <= 1'b1;
            result <= result;
        end else begin
            if (rxdata == bramout) begin
                result <= result;
            end else begin
                result <= 1'b0;
            end
        end
    end
*/
    //
    //
    /*

   //
   //
   */
   reg firstprocessed = 1'b0;
	 reg [4:0] shift_result = 5'b0;
	 assign shift4_result = shift_result[3];
   always @(posedge clk) begin
    if (en) begin
				shift_result <= {shift_result[3:0],result};
        valid <= 1'b0;
        if (!firstprocessed) begin
            firstprocessed <= 1'b1;
            if (rxdata !== bramout)
                result <= 1'b0;
            else
                result <= 1'b1;
        end
        else begin // (from second data)
            if (rxdata !== bramout)
                result <= 1'b0;
            else result <= result;
        end
    end
    else begin
        firstprocessed <= 1'b0;
        valid <= 1'b1;
        result <= result;
				shift_result <= shift_result;
    end
    end
    





endmodule