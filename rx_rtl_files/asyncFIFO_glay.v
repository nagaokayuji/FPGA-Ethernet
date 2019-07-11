/* 非同期FIFO */

module asyncFIFO_glay #(parameter WA=5,WD=256)

    (input  rst                 // reset

    ,input  wr_clk                // write clock

    ,input  wr_en                 // write enable

    ,input[WD-1:0] din         // write data

    ,output reg full           // write full

    ,input  rd_clk                // read clock

    ,input  rd_en                 // read enable

    ,output reg[WD-1:0] dout    // read data

    ,output reg empty          // read empty

    );

reg[WA:0] wadr_reg;

reg[WA:0] radr_reg;

reg[WA:0] wptr_reg,wptr0_reg,wptr1_reg;

reg[WA:0] rptr_reg,rptr0_reg,rptr1_reg;

wire[WA:0] next_wadr,next_wptr;

wire[WA:0] next_radr,next_rptr;

reg[WD-1:0] ram[0:2**WA-1];

/**************************************************************

 * DPM

 *************************************************************/

always @(posedge wr_clk)

    if(wr_en) ram[wadr_reg[WA-1:0]] <= din;

always @(posedge rd_clk)

    if(rd_en) dout <= ram[radr_reg[WA-1:0]];

/**************************************************************

 * wr_clk domain

 *************************************************************/

/* write address */

always @(posedge wr_clk or posedge rst)

    begin

    if(rst)

        {wadr_reg,wptr_reg} <= {{(WA+1){1'b0}},{(WA+1){1'b0}}};

    else if(wr_en)

        {wadr_reg,wptr_reg} <= {next_wadr, next_wptr};

    end

assign next_wadr = wadr_reg + (wr_en & ~full);     // binary

assign next_wptr = next_wadr ^ (next_wadr>>1'b1); // gray

/* cdc transfer of rptr */

always @(posedge wr_clk or posedge rst)

    begin

    if(rst)

        {rptr1_reg, rptr0_reg} <= {{(WA+1){1'b0}},{(WA+1){1'b0}}};

    else

        {rptr1_reg, rptr0_reg} <= {rptr0_reg, rptr_reg};

    end

/* full flag */

always @(posedge wr_clk or posedge rst)

    begin

    if(rst)

        full <= 1'b0;

    else if(next_wptr=={~rptr1_reg[WA:WA-1], rptr1_reg[WA-2:0]})

        full <= 1'b1;

    else

        full <= 1'b0;

    end

/**************************************************************

 * rd_clk domain

 *************************************************************/

/* read address */

always @(posedge rd_clk or posedge rst)

    begin

    if(rst)

        {radr_reg,rptr_reg} <= {{(WA+1){1'b0}},{(WA+1){1'b0}}};

    else if(rd_en)

        {radr_reg,rptr_reg} <= {next_radr, next_rptr};

    end

assign next_radr = radr_reg + (rd_en & ~empty);    // binary

assign next_rptr = next_radr ^ (next_radr >> 1);  // gray

/* cdc transfer of wptr */

always @(posedge rd_clk or posedge rst)

    begin

    if(rst)

        {wptr1_reg, wptr0_reg} <= {{(WA+1){1'b0}},{(WA+1){1'b0}}};

    else

        {wptr1_reg, wptr0_reg} <= {wptr0_reg, wptr_reg};

    end

/* empty flag */

always @(posedge rd_clk or posedge rst)

    begin

    if(rst)

        empty <= 1'b1;

    else if(next_rptr==wptr1_reg)

        empty <= 1'b1;

    else

        empty <= 1'b0;

    end

endmodule