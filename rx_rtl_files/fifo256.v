`timescale 1ns / 1ps
// synchronous fifo 256 bits width

module fifo256( 
    input wire clk, 
    input wire [255:0] din, 
    input wire rd_en, 
    input wire wr_en, 
    output reg [255:0] dout, 
    input wire RST,
    output wire empty, 
    output wire full 
); 


localparam cmax = 254;


reg [7:0]  Count = 0;  // 256 depth

reg [255:0] FIFO [0:256]; 
reg [7:0]  readCounter = 0;
reg [7:0] writeCounter = 0; 
assign empty = (Count==0)? 1'b1:1'b0; 
assign full = (Count>=cmax-1'b1)? 1'b1:1'b0; 

always @ (posedge clk) 
begin 
    if (RST) begin 
        readCounter = 0; 
        writeCounter = 0; 
    end 
    else if (rd_en ==1'b1 && Count!=0) begin 
        dout  = FIFO[readCounter]; 
        readCounter = readCounter+1; 
    end 
    else if (wr_en==1'b1 && Count<cmax) begin
        FIFO[writeCounter]  = din; 
        writeCounter  = writeCounter+1; 
    end 
    else; 

    if (writeCounter==cmax) 
        writeCounter=0; 
    else if (readCounter==cmax) 
        readCounter=0; 
    else;

    if (readCounter > writeCounter) begin 
        Count=readCounter-writeCounter; 
    end 
    else if (writeCounter > readCounter) 
        Count=writeCounter-readCounter; 
    else;
end 
endmodule