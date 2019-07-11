/* 非同期FIFO */
/*
    PORT changed: for Xilinx IP
    wclk    ->      wr_clk
    wen     ->      wr_en
    wdat    ->      din
    wfull   ->      full
    rclk    ->      rd_clk
    ren     ->      rd_en
    rdat    ->      dout
    rempty  ->      empty
*/
module super_asyncFIFO #(parameter WA=4,WD=256,FWFT_mode="TRUE")
    (input  wire            rst         // reset
    ,input  wire            wr_clk      // write clock
    ,input  wire            wr_en       // write enable
    ,input  wire [WD-1:0]   din         // write data
    ,output wire            almost_full
    ,output wire            full        // write full
    ,input  wire            rd_clk      // read clock
    ,input  wire            rd_en       // read enable
    ,output reg [WD-1:0]    dout        // read data
    ,output wire            empty       // read empty
    ,output wire            almost_empty
    );

reg  [WA:0]      wadr_reg;
reg  [WA:0]      radr_reg;
reg  [WA:0]      wptr_reg,wptr0_reg,wptr1_reg,wrbinary;
reg  [WA:0]      rptr_reg,rptr0_reg,rptr1_reg,rdbinary;
wire [WA:0]      next_wadr,next_wptr;
wire [WA:0]      next_radr,next_rptr;
reg  [WD-1:0]    ram [0:2**WA-1];
/**************************************************************
 * DPM
 *************************************************************/
always @(posedge wr_clk) begin
    if(wr_en) ram[wadr_reg[WA-1:0]] <= din;
end

/* Show-ahead mode / First-word Fall-through mode */

always @(posedge rd_clk) begin
    if (FWFT_mode == "TRUE")
        dout <= ram[radr_reg[WA-1:0]+(rd_en? 1'b1:1'b0)];
    else if (FWFT_mode == "FALSE")
        if (rd_en)
            dout <= ram[radr_reg[WA-1]];
    else dout<='hx;
end
    
/**************************************************************
 * wr_clk domain
 *************************************************************/
/* write address */
always @(posedge wr_clk or posedge rst) begin
    if(rst) begin
        wadr_reg <= {(WA+1){1'b0}};
        wptr_reg <= {(WA+1){1'b0}};
    end else if(wr_en) begin
        wadr_reg <= next_wadr;
        wptr_reg <= next_wptr;
    end
end

assign next_wadr = wadr_reg + (wr_en & ~full);     // binary
assign next_wptr = next_wadr ^ (next_wadr>>1'b1); // gray

// Read Gray Counterからのグレーコードをwr_clkで同期
always @(posedge wr_clk or posedge rst) begin
    if(rst) begin
        rptr1_reg <= {(WA+1){1'b0}};
        rptr0_reg <= {(WA+1){1'b0}};
    end else begin
        rptr1_reg <= rptr0_reg;
        rptr0_reg <= rptr_reg;
    end
end

// Read Gray Counterの値をバイナリ変換
always @* begin : READ_GRAY2BINARY
    integer j;
    for(j=WA; j>=0; j=j-1) begin
        if (j==WA)
         rdbinary[j] <= rptr1_reg[j];
        else
         rdbinary[j] <= rptr1_reg[j] ^ rdbinary[j+1];
    end
end

assign full       = (wadr_reg == {!rdbinary[WA],rdbinary[WA-1:0]}) ? 1'b1 : 1'b0;
assign almost_full = (wadr_reg == {!rdbinary[WA],(rdbinary[WA-1:0]-2'd2)}) ? 1'b1 : 1'b0;

/**************************************************************
 * rd_clk domain
 *************************************************************/

/* read address */
always @(posedge rd_clk or posedge rst) begin
    if(rst) begin
        radr_reg <= {(WA+1){1'b0}};
        rptr_reg <= {(WA+1){1'b0}};
    end else if(rd_en) begin
        radr_reg <= next_radr;
        rptr_reg <= next_rptr;
    end
end

assign next_radr = radr_reg + (rd_en & ~empty);    // binary
assign next_rptr = next_radr ^ (next_radr >> 1);  // gray

// Write Gray Counterからのグレーコードをrd_clkで同期
always @(posedge rd_clk or posedge rst) begin
    if(rst) begin
        wptr1_reg <= {(WA+1){1'b0}};
        wptr0_reg <= {(WA+1){1'b0}};
    end else begin
        wptr1_reg <= wptr0_reg;
        wptr0_reg <= wptr_reg;
    end
end

// Write Gray Counterの値をバイナリ変換
always @* begin : WRITE_GRAY2BINARY
    integer j;
    for(j=WA; j>=0; j=j-1) begin
        if (j==WA)
            wrbinary[j] <= wptr1_reg[j];
        else
            wrbinary[j] <= wptr1_reg[j] ^ wrbinary[j+1];
    end
end

assign empty = (wrbinary == radr_reg) ? 1'b1 : 1'b0;
assign almost_empty = (wrbinary-2'd2 == radr_reg) ? 1'b1 : 1'b0;


endmodule