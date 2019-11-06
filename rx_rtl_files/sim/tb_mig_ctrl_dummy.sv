`timescale 1ns / 1ns
module tb_mig_ctrl_dummy;

reg wr_en,rd_en,clk,rst;
wire ui_clk,ui_clk_sync_rst,wr_busy,rd_busy;

reg [255:0] wr_data;
wire [255:0] rd_data;
reg [24:0] wr_addr,rd_addr;

mig_ctrl_dummy uut(
    .clk(clk),
    .rst(rst),
    .ui_clk(ui_clk),
    .ui_clk_sync_rst(ui_clk_sync_rst),
    .wr_addr(wr_addr),
    .wr_data(wr_data),
    .rd_addr(rd_addr),
    .rd_data(rd_data),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .wr_busy(wr_busy),
    .rd_busy(rd_busy),
    .rd_data_valid(rd_data_valid)
);
localparam cycle = 10;

task deassert_enable;
    begin
        if (rd_busy)
            rd_en = 1'b0;
        else if (wr_busy)
            wr_en = 1'b0;
    end
endtask


task read;
    input [24:0] addr;

    begin
        wait(!rd_busy);
        rd_en = 1'b1;
        wait(rd_busy);
        rd_en = 1'b0;
        rd_addr = addr;
        wait(rd_data_valid);
    end
endtask
task wait_busy;
    begin
        if (wr_busy)
            wr_en = 1'b0;
    end
endtask

task write;
    input [24:0] addr;
    input [255:0] data;
    begin
        wait(!wr_busy);
        #cycle;
        wr_en = 1'b1;
        wait(wr_busy);
        wr_en = 1'b0;
        wr_addr = addr;
        wr_data = data;
        #cycle;
        rd_en = 1'b0;
    end
endtask



always #5 begin
    clk = !clk;
end

integer i,j,k;
initial begin
$dumpfile("wf_mig_ctrl_dummy.vcd");
$dumpvars(0,uut);
rst = 0;
clk = 0;
#20;
rst = 1;
#400;
for (i = 0; i < 20; i = i + 1) begin
    write(i, i + (i<<3));
    #(cycle*2);
end
#(cycle*5);

for (i = 0; i < 20; i = i + 1) begin
    read(i);
    #(cycle*2);
end
wr_en = 1'b0;
rd_en = 1'b0;

wr_addr=0;
wr_data = {8{32'hdeadbeef}};
wr_en = 1'b1;
#cycle;
wr_en = 1'b0;
#150;
#1000;
rd_addr = 0;
rd_en = 1'b1;
#1000;
rd_en = 1'b0;


#2000;
#2000;
#2000;
$finish;
    
    
end



endmodule