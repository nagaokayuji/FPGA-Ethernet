`timescale 1ns / 1ps
//`include "../detect_errors2.v"
//`include "../loss_calculator.sv"
//`include "../bram1b65536w_v.v"
module tb_detect_errors;

parameter CYCLE = 16;
parameter whereis_aux = 0;
parameter packetsize = 33;
parameter segment_number_max = 16'd5;
parameter maxaux = 'd16;


reg rx_en=0,clk=0, rst = 0;
reg [7:0] rx_data=0;

wire [31:0] count,ok,ng,lostnum;
wire valid;
wire [2:0] state;
reg [15:0] segment_number;

detect_errors2 #(.whereis_aux(whereis_aux), .maxaux(maxaux),.maxaux_bits('d4)) uut(
    .clk(clk),
    .rst(rst),
    .segment_number_max(segment_number_max),
    .seg(segment_number),
    .rx_en(rx_en),
    .rx_data(rx_data),
    .count(count),
    .ok(ok),
    .ng(ng),
    .lostnum(lostnum),
    .valid(valid),
    .state(state)
);

always begin // create clock 125MHz
    #3 clk = !clk;
    #5;
end

task onepacket;
    input [15:0] aux;

    integer i;
    integer j;
    begin
        rx_en = 1'b1;
        for (i = 0; i < packetsize; i = i+1) begin
                case (i)
                    whereis_aux: rx_data = aux[15:8];
                    whereis_aux+5: rx_data = aux[7:0];
                    default: rx_data = 8'h12;
                endcase
            #CYCLE;
        end // end for
        rx_en = 1'b0;
        rx_data = 8'hxx;
    end
endtask



integer i;
integer j;
integer k;
wire [15:0] segment_number_next = (segment_number + 1'b1 == segment_number_max) ? 'd0 : segment_number + 1'b1;
reg [15:0] a;
wire [15:0] a_next = (a==maxaux) ? 0 : a+1'b1;

initial begin
    $dumpfile("tb_detect_errors.vcd");
    $dumpvars(0,uut);

    clk = 0;
    rst = 0;
    segment_number = 0;
    rx_en = 0;
    rx_data = 8'hxx;
    #(CYCLE * 2);
    rst = 1;
    #CYCLE;
    rst = 0;
    #(CYCLE * 3);
    a = 0;
    #(CYCLE * 30);
    for (k=0;k<5;k=k+1) begin
        for (i=0; i<=88; i=i+1) begin
            // if (i>13 && i<29)   begin
            //    a = a_next; 
            // end
            // else if (i==50) begin
            //     a = a - 'd2;
            // end
           // else begin
                onepacket(a);
                segment_number = segment_number_next;
                a = a_next;
                #(CYCLE*6);
            //end


        end
        #(CYCLE*80);
    end


    #(CYCLE*40);
    $finish;


end


endmodule
