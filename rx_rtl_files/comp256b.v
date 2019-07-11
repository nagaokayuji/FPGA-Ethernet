`timescale 1ns / 1ps
module comp256b(
    input wire clk,
    //input wire [10:0] addr, //not needed...
    input wire [255:0] rxdata,
    input wire en,
    input wire [255:0] bramout,
    output reg valid,
    output reg result = 1'b0
);

reg firstprocessed = 1'b0;
always @(posedge clk) begin
    if (en) begin
        valid <= 1'b0;
        if (!firstprocessed) begin
            firstprocessed <= 1'b1;
            if (rxdata != bramout)
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
    end
end
endmodule