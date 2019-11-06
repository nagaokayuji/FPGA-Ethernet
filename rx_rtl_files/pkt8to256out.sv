`timescale 1ns / 1ps

/*
    
    inputs    8 bits data + rxen
    outputs 256 bits data + enable
                    + id + segnum
*/

module pkt8to256out #(parameter whereis_segnum = 34, whereis_id = 36) (
    input wire          RST,
    input wire [7:0]    rxd,
    input wire          clk,
    input wire          rxen,
    
    input wire          ui_clk,

    output reg [255:0]  out256b_r,
    output reg          en_out_r,
    output reg [3:0]    id_r,
    output reg [15:0]   segnum_r
);

localparam read_async = "TRUE";

wire [255:0]    out256b;
wire            en_out;
wire [3:0]      id;
wire [15:0]     segnum;


parameter [255:0] sentinel = 
    {   64'hffff_0000_ffff_0000,
        64'habcd_abcd_abcd_abcd,
        64'h81af_19fa_1331_dead,
        64'h0cee_70d0_8ab3_ffff };

reg [15:0]      segnum_got,segnum_save;
reg [3:0]       id_got,id_save;

reg [12:0]      en_counter = 0;
reg [255:0]     shift_reg_rxd = 'b0;
reg [4:0]       shift_count = 'b0;

wire            empty,full;
reg             rd_en,wr_en;
wire [255:0]    dout;
wire [255:0]    din;
/*
fifo256 fifo256_i(
    .clk(clk),
    .din(din),
    .rd_en(rd_en && !empty),
    .wr_en(wr_en && !full),
    .dout(dout),
    .RST(RST),
    .empty(empty),
    .full(full)
);
*/

/*
localparam use_async_fifo = "TRUE";
generate
    if (use_async_fifo = "TRUE") begin
    */

generate
    if( read_async == "TRUE") begin
        asyncFIFO_glay asyncFIFO_i (
            .wr_clk(clk),

            .rd_clk(ui_clk),
            .rst(RST),
            .din(din),
            .rd_en(rd_en /*&& !empty*/),
            .wr_en(wr_en && !full),
            .dout(dout),
            .empty(empty),
            .full(full)
        );
    end
    else begin
        asyncFIFO_glay asyncFIFO_bsync (
            .wr_clk(clk),
            .rd_clk(clk),
            .rst(RST),
            .din(din),
            .rd_en(rd_en /*&& !empty*/),
            .wr_en(wr_en && !full),
            .dout(dout),
            .empty(empty),
            .full(full)
        );
        )
    end
endgenerate
        /*
    end
    else begin

        FIFO_memory_256 fifo_256_i(
            .clk(clk),
            .reset(RST),
            .din(din),
            .read(rd_en && !empty),
            .write(wr_en && !full),
            .dout(dout),
            .empty(empty),
            .full(full)
        );
    end
endgenerate
*/

reg     wr_en_force = 1'b0;
assign  wr_en = 
        ((wstate == WRITING) && shift_count == 5'b11111) || wr_en_force;

reg     wr_sentinel = 0;

// emtnl
wire [255:0] shift_reg_shiftc =  
        shift_reg_rxd << ((256-8) - ((shift_count<<3)));
reg     wr_shiftc = 0;

assign      din = (wr_sentinel)? sentinel:
                    (wr_shiftc)? shift_reg_shiftc:
                                 shift_reg_rxd;

reg         output_en;
reg [255:0] output_data;
reg [3:0]   output_id;
reg [15:0]  output_segnum;
assign      en_out = output_en;
assign      id = output_id;
assign      segnum = output_segnum;
assign      out256b = output_data;

enum {WINIT,WRITING,WRITE_END
    ,WRITE_SENTINEL} wstate = WINIT;

enum {RINIT,RWAIT,RSTART,READING,REND} rstate = RINIT;
reg [3:0] rwaitcount = 0;

enum {RXINIT,RXSTART,RXWAIT,RXEND} rxstate = RXINIT;

always @(posedge clk) begin
    if (RST) begin
        //rwaitcount = 'h0;
        //output_data = 'h0;
        //output_id = 'h0;
        //output_segnum = 'h0;
        id_got = 'h0;
        //id_save = 'h0;
        segnum_got = 'h0;
        output_en = 'h0;
        segnum_save = 'h0;
        wr_en_force = 1'b0;
        wr_sentinel = 1'b0;
        wstate = WINIT;
        //rstate = RINIT;
        rxstate = RXINIT;
        en_counter = 0;
        shift_reg_rxd = 'b0;
        shift_count = 'b0;
    end
    else begin
        case (wstate)
            WINIT:
                begin
                    wr_shiftc = 1'b0;
                    wr_en_force = 1'b0;
                    wr_sentinel = 1'b0;
                    if (rxen) wstate <= WRITING;
                end
            WRITING:
                begin
                    wr_shiftc = 1'b0;
                    wr_en_force = 1'b0;
                    wr_sentinel = 1'b0;
                    if (!rxen)
                        begin
                            if (shift_count == 'h1f)
                                wstate <= WRITE_SENTINEL;
                            else 
                                wstate <= WRITE_END;
                        end
                end
            WRITE_END:
                begin
                    wr_en_force = 1'b1;
                    wr_shiftc = 1'b1;

                    wr_sentinel = 1'b0;
                    wstate <= WRITE_SENTINEL;
                end
            WRITE_SENTINEL:
                begin
                    wr_shiftc = 1'b0;
                    wr_en_force = 1'b1;
                    wr_sentinel = 1'b1;
                    wstate <= WINIT;
                end
            default:;
        endcase
        // make en_counter here.
        if (rxen) begin
            en_counter <= en_counter + 1'b1;
        end
        else begin
            en_counter <= 'h0;
        end
        
        //enum {RXINIT,RXSTART,RXWAIT,RXEND} rxstate = RXINIT;
        case (rxstate)
        RXINIT:
            begin
                if (rxen) begin
                    shift_count <= 'h0;
                    rxstate <= RXSTART;
                    shift_reg_rxd <= {shift_reg_rxd[255-8:0],rxd};
                end
                else begin
                    rxstate <= RXINIT;
                    shift_reg_rxd <= 'h0;
                    shift_count <= 'h0;
                end
            end
        RXSTART:
            begin
                if (rxen) begin
                    shift_reg_rxd <= {shift_reg_rxd[255-8:0], rxd};
                    shift_count <= shift_count + 1'b1;
                    if (en_counter == whereis_segnum) begin
                        segnum_got[15:8] <= rxd;
                    end
                    else if (en_counter == whereis_segnum + 1'b1) begin
                        segnum_got[7:0] <= rxd;
                    end
                    else if (en_counter == whereis_id) begin
                        id_got <= rxd[3:0];
                    end
                    
                    if (shift_count == 5'h1f) begin
                        shift_reg_rxd[255:8] <= 'h0;
                    end
                end
                else begin
                    rxstate <= RXWAIT;
                    //shift_reg_rxd[255:8] <= 'h0;
                end
            end
        RXWAIT:
            begin
                shift_reg_rxd <= shift_reg_rxd;
                rxstate <= RXEND;
            end
        RXEND:
            begin
                // do something
                shift_count <= 'h0;
                rxstate <= RXINIT;
                shift_reg_rxd <= 'h0;
            end
        endcase
    end

    
end


always @(posedge ui_clk) begin
    if (RST) begin
        rstate = RINIT;
        rwaitcount = 'h0;
        output_data = 'h0;
        output_id = 'h0;
        output_segnum = 'h0;
        id_save = 'h0;

    end
    else begin
        out256b_r <= out256b;
        en_out_r <= en_out;
        id_r <= id;
        segnum_r <= segnum;
    
        case (rstate)
            RINIT:
                begin
                    if (wstate == WRITE_SENTINEL) 
                    begin
                        rwaitcount <= 'h0;
                        rstate <= RWAIT;
                    end
                    else begin
                        rd_en = 1'b0;
                    end
                end
            RWAIT:
                begin
                    if (rwaitcount + 1'b0 == 0) begin
                        rd_en = 1'b1;
                        rstate <= RSTART;
                        id_save <= id_got;
                        segnum_save <= segnum_got;
                    end
                    else rwaitcount <= rwaitcount + 1'b1;
                end
            RSTART:
                begin
                    if (!empty) begin
                        //output_data <= dout;
                        //output_en <= 1'b1;
                        output_id <= id_save;
                        output_segnum <= segnum_save;
                        rstate <= READING;
                    end
                    else begin
                        rstate <= RINIT;
                    end
                end
            READING:
                begin
                    if (dout !=sentinel) begin
                            output_data <= dout;
                            output_en <= 1'b1;
                            output_id <= id_save;
                            output_segnum <= segnum_save;
                    end
                    else begin
                        output_en <= 1'b0;
                        //output_id <= 'h0;
                        //output_segnum <= 'h0;
                        rstate <= RINIT;
                    end
                end
            REND:
                begin
                    // do nothing;
                end
            default:
                rstate <= RINIT;
        endcase



endmodule