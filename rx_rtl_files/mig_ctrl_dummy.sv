`timescale 1ns / 1ns
module mig_ctrl_dummy 
    (
    // User interface ports
    output	reg					ui_clk,
    output	reg					ui_clk_sync_rst,
    input	[25-1:0]	wr_addr,
    input	[256-1:0]	wr_data,
    input	[25-1:0]	rd_addr,
    output	reg [256-1:0]	rd_data,
    input						wr_en,
    input 						rd_en,
    output reg					wr_busy,
    output reg					rd_busy,
    output reg                  rd_data_valid,
    // Physical ports
    input                       clk,
    input                       clk_ref,
    input                       clk_p,
    input                       clk_n,
    input                       rst,
    output  [14:0]              ddr3_addr,
    output  [2:0]               ddr3_ba,
    output                      ddr3_cas_n,
    output                      ddr3_ck_n,
    output                      ddr3_ck_p,
    output                      ddr3_cke,
    output                      ddr3_ras_n,
    output                      ddr3_reset_n,
    output                      ddr3_we_n,
    inout   [32-1:0]  ddr3_dq,
    inout   [4-1:0] ddr3_dqs_n,
    inout   [4-1:0] ddr3_dqs_p,
    output                      ddr3_cs_n,
    output  [4-1:0] ddr3_dm,
    output                      ddr3_odt
    );

/* control these signals. 
output						ui_clk,
output						ui_clk_sync_rst,
input	[ADDR_WIDTH-1:0]	wr_addr,
input	[DATA_WIDTH-1:0]	wr_data,
input	[ADDR_WIDTH-1:0]	rd_addr,
output	[DATA_WIDTH-1:0]	rd_data,
input						wr_en,
input 						rd_en,
output reg					wr_busy,
output reg					rd_busy,
output                      rd_data_valid
*/

//reg ui_clk = 0;
always @(posedge clk) begin
    ui_clk = !ui_clk;
end
assign ui_clk_sync_rst = !rst;//actv h

reg [255:0] mem[33554431:0];
integer jj;
initial begin
    for (jj=0; jj<1000;jj = jj + 1'b1) begin
        mem[jj] = 0;
    end
end
/*
reg [4:0] state = 0;
localparam INIT = 0;
localparam READ = 1;
localparam READ_WAIT = 2;
localparam READ_DONE = 3;
localparam WRITE = 4;
localparam WRITE_WAIT = 5;
localparam WRITE_DONE = 6;
*/


enum {
    INIT,
    READ,
    READ_WAIT,
    READ_DONE,
    WRITE,
    WRITE_WAIT,
    WRITE_DONE
} state;




/*
initial begin
$dumpvars(0,mig_ctrl_dummy);
$dumpfile("mig_ctrl_dummy.vcd");
ui_clk = 0;

#2000;
$finish;
end
*/

class rand_val;
    rand reg [4:0] rndp;
endclass
reg [6:0] rnd=0;
reg [6:0] count = 0;
reg [31:0] seed = 0;
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        ui_clk = 0;
        count = 0;
        rnd = 0;
        seed = 0;
        state = INIT;
        rd_busy = 1'b0;
        wr_busy = 1'b0;
        rd_data_valid = 1'b0;
    end
    else begin
        seed <= 32'hf1a47bda + (seed * 11) ;
       // rnd <= {seed[0],seed[1],seed[0],seed[2]};
        
        case (state)
        /*
            input	[ADDR_WIDTH-1:0]	wr_addr,
            input	[DATA_WIDTH-1:0]	wr_data,
            input	[ADDR_WIDTH-1:0]	rd_addr,
            output	[DATA_WIDTH-1:0]	rd_data,
            input						wr_en,
            input 						rd_en,
            output reg					wr_busy,
            output reg					rd_busy,
            output                      rd_data_valid
        */
            INIT:
                begin
                    wr_busy = 1'b0;
                    rd_busy = 1'b0;
                    rd_data_valid = 1'b0;
                    if (wr_en) begin
                        state <= WRITE;
                    end
                    else if (rd_en) begin
                        state <= READ;
                    end
                end
            READ:
                begin
                    rd_busy = 1'b1;
                    rd_data_valid = 1'b0;
                    rd_data = 256'hx;
                    state = READ_WAIT;
                    count = 0;

                    //rnd = $random(seed);
                    rnd <= {seed[0],seed[1],seed[0],seed[2],seed[10],seed[29]} ^ {seed[11],seed[21],seed[9],seed[18],seed[19]};
                end

            READ_WAIT:
                begin
                    count <= count + 1'b1;
                    if (count >= rnd) state <= READ_DONE;
                end
            READ_DONE:
                begin
                    rd_data_valid = 1'b1;
                    rd_data = mem[rd_addr];
                    state <= INIT;
                    rd_busy <= 1'b0;
                end
            WRITE:
                begin
                    wr_busy = 1'b1;
                    mem[wr_addr] = wr_data;
                    count = 0;
                    //rnd = $random(seed);
                    rnd <= {seed[6],seed[3],seed[1],seed[7],seed[22]} ^ {seed[23],seed[30],seed[10],seed[5],seed[12]};
                    state = WRITE_WAIT;
                end
            WRITE_WAIT:
                begin
                    count <= count + 1'b1;
                    if (count >= rnd) state <= WRITE_DONE;
                end
            WRITE_DONE:
                begin
                    wr_busy = 1'b0;
                    state <= INIT;
                end
            default:
            begin
            end
        endcase
    end



end

endmodule