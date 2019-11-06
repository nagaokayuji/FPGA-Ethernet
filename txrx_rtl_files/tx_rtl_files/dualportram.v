`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/30 22:16:36
// Design Name: 
// Module Name: dualportram
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

module dpram(clka,clkb, wea, addra, addrb, dina,douta,doutb);
 parameter DWIDTH=8,AWIDTH=20,WORDS=1048576;

 input clka,clkb,wea;
 input [AWIDTH-1:0] addra,addrb;
 input [DWIDTH-1:0] dina;
 output reg [DWIDTH-1:0] douta,doutb;
// reg [DWIDTH-1:0] q1,q2;
 reg [DWIDTH-1:0] mem [WORDS-1:0];

 always @(posedge clka)
   begin
     if(wea) mem[addra] <= dina;
     douta <= mem[addra];
  end

 always @(posedge clkb)
   begin
     doutb <= mem[addrb];
  end


integer i;
integer j;
integer k;
integer adr;
initial begin

		for (i=0; i < 480; i=i+1) begin
		   for (j=0; j < 640; j=j+1)	begin
			for (k=0; k < 3; k=k+1) begin
			adr = (j + (i*640))*3 +k;
			
			if ((i-240) * (i-240) +(j-320) * (j-320) <= 3000)
			 begin
                       if (k == 0)//red
                        mem[adr] = 8'hff;
                       else
                        mem[adr] = 0;
            end
			else if  ((i-340) * (i-340) +(j-520) * (j-520) <= 1600) begin
			if (k == 0) mem[adr] = 8'h00;
			else mem[adr] = 8'hff;
			end else
			 if (j < 320) begin
			     if (k==1)//green
			     mem[adr] = 8'hff;
			     else
			     mem[adr] = 0;
			 end
			 else begin
			     if (k==2) //blue
			     mem[adr] = 8'hff;
			     else
			     mem[adr] = 0;
			end
                        
			end//k
		end//j
	end//i
 end
/*
initial begin
	for (i=0; i < 640; i=i+1)	begin
		for (j=0; j < 480; j=j+1) begin
			for (k=0; k < 3; k=k+1) begin
			adr = (i + (j*640))*3 + k;
				if (k==0) begin // red
					if (i < 320 && j < 240) mem[adr] = 8'hff;
					else mem[adr] = 0;
				end
				if (k==1) begin // green
					if (i >= 320 && j < 240) mem[adr] = 8'hff;
					else mem[adr] = 0;
				end
				if (k==2) begin // blue
					if (i < 320 && j >= 240) mem[adr] = 8'hff;
					else mem[adr] = 0;
				end
			end//k
		end//j
	end//i
 end
*/
endmodule