
module rgb2bram #(
 parameter ACTIVE_COLS = 320,//640, 
 parameter ACTIVE_ROWS = 180)//480) 

(
    input            clk125MHz, //25.2MHz
    input wire rst,
    (* mark_debug = "true" *)	input pclk,
    (* mark_debug = "true" *)	input wire i_Hsync,
    (* mark_debug = "true" *)	input wire i_Vsync,
    (* mark_debug = "true" *) input wire [23:0] data24b,
    (* mark_debug = "true" *)	input wire vde,
    //output           o_HSync,
    //output           o_VSync,
    (* mark_debug = "true" *) output reg enout,
    (* mark_debug = "true" *) output reg [15:0] bramaddr24b = 'd0,
    (* mark_debug = "true" *) output reg [7:0] rgb_r,rgb_g,rgb_b,
    (* mark_debug = "true" *) output wire start_frame
 );  

(* mark_debug = "true" *) reg [9:0] o_Row_Count = 'd0;
(* mark_debug = "true" *) reg [9:0] o_Col_Count = 'd0;

//(* mark_debug = "true" *) wire i_HSync = !i_Hsync;
//(* mark_debug = "true" *) wire i_VSync = !i_Vsync; // =============active reverse=========
// -> active low 

(* mark_debug  = "true" *) reg [15:0] mitai_address;
//assign mitai_address = bramaddr24b;
reg [15:0] bramaddr24b_ini = 'd0;
wire [15:0] bramaddr24b_ini_next = bramaddr24b_ini < (ACTIVE_COLS*(ACTIVE_ROWS-1'b1)) ? bramaddr24b_ini + ACTIVE_COLS : bramaddr24b_ini;



//(* mark_debug = "true" *) reg [11:0] hsync_count = 'd0;
(* mark_debug = "true" *) reg [13:0] row_count = 'd0;

wire hsync = i_Hsync;
wire vsync = i_Vsync;
reg [1:0] vsync_sr = 'b0;
reg [1:0] hsync_sr = 'b0;
wire hsyncf = (hsync_sr==2'b10);
wire vsyncf = (vsync_sr==2'b10);
reg [1:0] vsync_count = 'b0;
reg [1:0] pix_count = 'b0;
localparam pix_count_max = 2'b01;
wire [1:0] pix_count_next = ( pix_count == pix_count_max ? 2'b00 : pix_count + 1'b1);
wire pix_count_en = pix_count=='b0;
localparam vsync_count_max = 2'b10;
wire [1:0] vsync_count_next = (vsync_count==vsync_count_max ? 'b0 : vsync_count + 1'b1);
wire vsync_count_en = vsync_count=='b0;
reg [1:0] hsync_count = 'b0;
localparam hsync_count_max = 2'b01;
wire [1:0] hsync_count_next = ((hsync_count==hsync_count_max) ? 'b0 : hsync_count + 1'b1);
wire hsync_count_en = hsync_count=='b0;

// pix_count_en && vsync_count_en && hsync_count_en ->  enmask
reg [23:0] data_sampl;
reg [1:0] vsync_count_en_sr;
wire vsync_count_en_f = vsync_count_en_sr==2'b10;
reg [1:0] hsync_count_en_sr;
wire hsync_count_en_f = hsync_count_en_sr==2'b10;
(* mark_debug = "true" *) reg [2:0] cstate = 'd0;
localparam state_init = 0;
localparam state_start = 1;
localparam state_end = 2;

reg [8:0] col_count = 'd0; // to count 320 pix
wire [8:0] col_count_next = (col_count==ACTIVE_COLS-1'b1) ? col_count : col_count + 1'b1 ;
wire oneline_done = (col_count==(ACTIVE_COLS - 1'b1));



always @(posedge pclk) begin
    if (rst)begin


        rgb_r='d0;
        rgb_g='d0;
        rgb_b='d0;
        vsync_sr='d0;
        hsync_sr='d0;
        vsync_count='d0;
        pix_count='d0;
        hsync_count='d0;
        data_sampl='d0;
        vsync_count = 'd0;
        vsync_count_en_sr='d0;
        hsync_count_en_sr='d0;
        
    end
    else begin
    rgb_r <= data_sampl[23:16];
    rgb_g <= data_sampl[15:8];
    rgb_b <= data_sampl[7:0];
    mitai_address = bramaddr24b;
    data_sampl <= data24b;
    hsync_count_en_sr <= {hsync_count_en_sr[0],hsync_count_en};
    vsync_count_en_sr <= {vsync_count_en_sr[0],vsync_count_en};
    vsync_sr <= {vsync_sr[0],vsync};
    hsync_sr <= {hsync_sr[0],hsync};
    if (vde) begin
        pix_count <= pix_count_next;
    end
    if (vsyncf) begin
        vsync_count <= vsync_count_next;
    end
    if (!vsync) begin
        hsync_count <= 0;
        row_count <= 0;
    end
    else begin
        if (hsyncf) begin
            hsync_count <= hsync_count_next;
        end
        else begin
            if (!hsync) begin
                row_count <= 0;
            end
            else begin
                row_count <= row_count + 1'b1;
            end
        end
        
    end
end
end



always @(posedge pclk) begin
    if (rst) begin
        cstate='d0;
        bramaddr24b='d0;
        col_count='d0;
    end
    else begin
    case (cstate)
        state_init:
        begin
            enout <= 'b0;
            if (vsyncf) begin
                cstate <= state_start;
                bramaddr24b_ini <= 'd0;
                bramaddr24b <= 'd0;
                
            end
        end
        state_start:
        begin
            
            if ( bramaddr24b_ini == (ACTIVE_COLS * (ACTIVE_ROWS-1'b1)) && oneline_done) begin
                cstate <= state_end;
                enout<='b0;
                bramaddr24b_ini <= 'd0;
                col_count <= 'd0;
                
            end
            else begin
                if (hsync_count_en_f) begin
                    bramaddr24b_ini <= bramaddr24b_ini_next;
                    bramaddr24b <= bramaddr24b_ini;
                    col_count <= 'd0;
                end
                else begin
                    if (vde && hsync_count_en && pix_count_en) begin
                        enout <= 1'b1;
                        bramaddr24b <= bramaddr24b_ini + col_count;
                        col_count <= col_count_next;
                    end
                    else begin
                        enout <= 1'b0;
                    end
                end
            end
        end
        state_end:
        begin
            enout <= 'b0;
            if (vsyncf) begin
                cstate <= state_init;
            end
        end
    endcase
end
end


endmodule
/*


reg [1:0] vsync_fall;
reg start_frame_pck;
reg start_frame_reg;
reg start_frame_reg2;
reg [4:0] vsync_fall_count = 0;
localparam vsync_fall_count_max = 1;
wire [4:0] vsync_fall_count_next = (vsync_fall_count < vsync_fall_count_max ? vsync_fall_count + 1'b1 : 0);

wire hsync_revrev = i_Hsync;
wire vsync_revrev = i_Vsync;

always @(posedge clk125MHz) begin
    start_frame_reg <= start_frame_pck;
    start_frame_reg2 <= start_frame_reg;
end

assign start_frame = start_frame_reg2;

always @(posedge pclk) begin
    vsync_fall <= {vsync_fall[0],vsync_revrev};
    if (vsync_fall == 2'b01) begin
        vsync_fall_count <= vsync_fall_count_next;
    end
        start_frame_pck <= ( vsync_fall == 2'b01 && (vsync_fall_count == vsync_fall_count_max));
end
(* mark_debug = "true" *) reg [2:0] count_three = 0;
(* mark_debug = "true" *) wire three = (count_three == 2'b10);//=====================modified
(* mark_debug = "true" *) reg [23:0] data_sampling = 0;
(* mark_debug = "true" *) reg fallen_h = 0;
reg fallen_v = 0;
reg vclk = 0;
reg half = 0;
(* mark_debug = "true" *)reg [1:0] count_hsync = 0;
(* mark_debug = "true" *)reg [1:0] count_vsync = 0;
reg [1:0] count_cols = 0;
reg inaaaa = 0;
(* mark_debug = "true" *) reg [15:0] bramaddr24b_ini = 0;
always @(posedge pclk) begin
    if ((!hsync_revrev) || (!vsync_revrev) || (!vde)) begin // blank
        count_three <=0;
        enout <= 0;
        if (!vsync_revrev && !fallen_v && !vde) begin // next frame.
            bramaddr24b <= 0; // new logic 10/22
            bramaddr24b_ini <= 0;
            fallen_v <= 1;
            if (count_vsync == 1) begin 
                count_vsync<=0; // 20fps
            end 
            else begin
                count_vsync <= count_vsync + 1;
                count_three <= 0;
                o_Row_Count <= 0;
                o_Col_Count <= 0;// ichiou
                count_hsync <= 0;
            end
        end
        else if (!hsync_revrev && !fallen_h && !vde) begin
            o_Col_Count <= 0;
            fallen_h <= 1;
            if (count_hsync == 2) begin
                count_hsync <= 0;
            end
            else begin
                count_hsync <= count_hsync + 1;
            end

            if (o_Row_Count == ACTIVE_ROWS -1) begin
                o_Row_Count <= o_Row_Count;
            end
            else if (count_hsync == 2) begin
                o_Row_Count <= o_Row_Count + 1;
                bramaddr24b_ini <= bramaddr24b_ini + ACTIVE_COLS;//420
                bramaddr24b <= bramaddr24b_ini;
            end // next line.
            count_three <= 0;
        end
    end 
    else begin // =====not sync
        fallen_h <= 0;
        fallen_v <= 0;
        if (count_vsync == 0) begin
            if (count_hsync == 0) begin
                if (count_three == 0) begin 
                    data_sampling <= data24b;
                end
                if (three) begin
                    count_three <= 0;
                end
                else begin 
                    count_three <= count_three + 1'b1;
                end
                
                if (three) begin // ========row,col countup. 1/3 rate.
                    if (o_Col_Count == ACTIVE_COLS -1'b1) begin
                        o_Col_Count <= o_Col_Count;
                    end
                    else begin 
                        if (bramaddr24b < 57600) begin
                            bramaddr24b <= bramaddr24b + 1'b1;
                        end
                        o_Col_Count <= o_Col_Count + 1'b1;
                        enout <= 1'b1;
                        rgb_r <= data_sampling[23:16];
                        rgb_g <= data_sampling[15:8];
                        rgb_b <= data_sampling[7:0];
                    end
                end 
                else begin
                    enout <= 1'b0;// end if(three)
                end
            end  
        end  
    end
end

// assign o_HSync = o_Col_Count < ACTIVE_COLS ? 1'b1 : 1'b0;
// assign o_VSync = o_Row_Count < ACTIVE_ROWS ? 1'b1 : 1'b0;
 

 
endmodule
*/