`timescale 1ns / 1ps


module cnv8to24(
    //input wire clk, // pck
    input wire [7:0] data8b,
    input wire en,
    //input wire [20:0] startaddr8b,
    input wire dclk,
    
    output reg [23:0] addr2vram = 0,
    output reg [1:0] count = 0,
    output reg [7:0] data_rgb,//data_r=0,data_g=0,data_b=0,
    output wire wea_r,wea_g,wea_b
);

reg [23:0] startaddr;
reg [7:0] data8b_reg;
reg en_reg;
reg [1:0] count_before;
reg [31:0] detect;
wire detect_on = (detect == 32'h05a80000);
reg [3:0] state;
localparam state_wait = 0;
localparam state_addr2=1;
localparam state_addr3=2;
localparam state_gotaddr=3;
localparam state_datain=4;

assign wea_r = (count==1);
assign wea_g = (count==2);
assign wea_b = (count==3);


always @(posedge dclk) begin
// edge alignment
	data8b_reg <= data8b;
	data_rgb <= data8b_reg;
	en_reg <= en;
	detect <= {detect[23:0],data8b_reg};


	if (en_reg) begin
		case (state)
			state_wait: begin
			count <= 0;
			startaddr <= 0;
				if (detect_on) begin
					startaddr[23:16] <= data8b_reg;
					state <= state_addr2;
				end
			end

			state_addr2: begin
				startaddr[15:8] <= data8b_reg;
				state <= state_addr3;
			end

			state_addr3: begin
				startaddr[7:0] <= data8b_reg;
				addr2vram <= {startaddr[23:8],data8b_reg};
				state <= state_gotaddr;
				count <= 0;
				count_before <= 0;
			end
			state_gotaddr: begin
				count_before <= count;
				count <= 1;
				state <= state_datain;
			end
			state_datain: begin
				count_before <= count;
				if (count == 3) begin
					addr2vram <= addr2vram + 1;
					count <= 1;
				end
				else begin
					count <= count + 1;
				end
			end
		endcase		
	end
	else begin
		state <= state_wait;
		count <= 0;


	end
	




	

end



/*
reg [23:0] addr8b = 0;

reg [55:0] detecting = 0;
reg isValid = 0;
reg [23:0] startaddr8b = 0;

reg [7:0] pipe0 = 0;

reg [22:0] devided = 0;
reg risen = 0;
reg [11:0] unkcounter = 0;
reg [11:0] count_detect = 0;
reg [18:0] addr24b_pipe = 0;
reg isValid_r = 0;
reg en_r = 0;
reg en_r_r = 0;
always @(posedge dclk) begin
    isValid_r <= isValid;
    pipe0 <= data8b;
    en_r <= en;
    en_r_r <= en_r;


    detecting <= {detecting[47:0],pipe0}; // shift
    
    if (en_r || en || en_r_r) begin
    unkcounter <= unkcounter + 1'b1;
 //   addr24b <= addr24b_pipe;

  
    if (isValid_r || isValid) begin
        data_rgb <= detecting[7:0];
         //addr8b <= addr8b + 1'b1;
                // if (addr8b % 3 == 2) begin
         if (count == 2) begin
              count <= 0;
              addr2vram <= addr2vram + 1;
          end
          else begin
              count <= count + 1;
             // enout <= 0; // ----------------- ayashii.
          end
         
        if (count_detect != 0 && (count_detect + 1 == unkcounter))begin
            risen <= 1;
        end else begin
        //risen <= 0;
        
        end // end of if (count_detect != 0 && (count_detect + 1 == unkcounter))begin
        
        case (count)
            0: begin wea_r<=1;wea_g<=0;wea_b<=0;end
            1: begin wea_r<=0;wea_g<=1;wea_b<=0;end
            2: begin wea_r<=0;wea_g<=0;wea_b<=1;end
            default:begin end
        endcase
    
    end
    else begin // ========!isValid
        if (detecting[31:0] == 32'h04400000) begin
            //addr8b <= detecting[55:32];
            count_detect <= unkcounter;
            isValid <= 1;
            startaddr8b <= detecting[55:32];
            addr2vram <= detecting[55:32];
        end
        //addr8b <= startaddr8b;
        count <= 0;
        //enout <= 0;
        
    end
   
   
    end// end (en)
    else begin
        isValid <= 0;
        unkcounter <= 0;
        count_detect <= 0;
        risen <= 0;
        count <= 0;
        addr2vram <= 0;
        wea_r <= 0;
        wea_g <= 0;
        wea_b <= 0;
//        enout <= 0;
    end 

end
*/
endmodule
