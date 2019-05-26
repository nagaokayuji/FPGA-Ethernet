`timescale 1ns / 1ps
//----------------
// log:
// have to detect errors by 'aux' number.
// aux number: 8 bits length.
// --~~ -~ -> --~-~-~-~-~ : 1 clock 
//-------------------

module log #(parameter whereisaux = 0)(
   (* mark_debug = "true" *) input wire rx_en,
   (* mark_debug = "true" *) input wire [7:0] rx_data,
   (* mark_debug = "true" *) input wire rst,
    input wire clk125MHz,
   (* mark_debug = "true" *) output reg [31:0] countp=0,
   (* mark_debug = "true" *) output reg [31:0] okp=0,
   (* mark_debug = "true" *) output reg finished=0,
   (* mark_debug = "true" *) output reg started=0,
   (* mark_debug = "true" *) output wire valid
    
    );
    parameter startplace = 12'd15;
    parameter index_max = 500000;
     (* mark_debug = "true" *) reg [11:0] rxcounter = 0;
    (* mark_debug = "true" *)  reg [23:0] index = 0;
    reg [23:0] index_prev = 0;
    reg en_instant = 0;
    reg rx_en_prev = 0;
    (* mark_debug = "true" *) reg [10:0] ngcount = 0;
   (* mark_debug = "true" *) reg valid_data = 0;
    (* mark_debug = "true" *) reg ng = 0;
    
    
    reg validation = 1'b0;
    //wire validation1 = (rxcounter == 0 && rx_data == 8'h00);
    //wire validation2 = 1'b1;//(rxcounter == 2 && rx_data == 8'hff);
    //wire validation3 = (rxcounter == 3 && rx_data == 8'h04);
    //wire validation4 = (rxcounter == 4 && rx_data == 8'h40);
    //wire validation5 = (rxcounter == 14 && rx_data == 8'h45);
    //wire validation = validation1 && validation2 && validation3 && validation4 && validation5;
    assign valid = validation;
    
    always @(posedge clk125MHz) begin
        if (rst) begin
            validation <= 0;countp<=0;okp<=0;finished<=0;started<=0;validation<=0;ng=0;valid_data=0;ngcount=0;rx_en_prev=0;en_instant=0;index_prev = 0; index = 0;
        end
    
    
        if (rx_en) begin
            rxcounter <= rxcounter + 1'b1;
            if (!rx_en_prev) en_instant <= 1;
            else en_instant <= 0;
            
            if (rxcounter == 0) begin 
                valid_data <= 1;
                validation <= 1;
            end
            else if (!validation)
                valid_data <= 0;
            
        end
        else begin
            valid_data <= 0;
            rxcounter <= 0;
            index_prev <= index;
            
        end
        
//        if (rxcounter == 1)
//            if (rx_data!=8'h00) validation=0;
        if (rxcounter == 3)
            if (rx_data!=8'h01) validation=0;
        if (rxcounter == 4)
            if (rx_data!=8'h70) validation=0;
    
    
        if (!finished && valid_data) begin
        
        if (rxcounter == startplace-2)  begin
            index[23:16] <= rx_data;
        end
        else if (rxcounter == startplace-1) begin
            index[15:8] <= rx_data;
        end
        else if (rxcounter == startplace) begin
            index[7:0] <= rx_data;
        end
        else if (rxcounter == startplace+1) begin
            if (index==0) started <= 1;
            else if (index == index_max && started) finished <= 1;
        end
        
        
        if ((rxcounter == startplace+1) && started && !finished) begin
            if (en_instant) countp <= countp + 1;
            if (index ==  index_prev + 1'b1) begin 
                okp <= okp + 1;
                ng <= 0;
            end
            else begin ng <= 1; ngcount <= ngcount + 1;end
            
        end
        
        
        
        
        end
        
        
        
        
    
    end
    
    
    
endmodule
