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