
module rgb2bram #(
 parameter ACTIVE_COLS = 320,//640, 
 parameter ACTIVE_ROWS = 180)//480) 

(
    input            clk125MHz, //25.2MHz
    (* mark_debug = "true" *)	input pclk,
    (* mark_debug = "true" *)	input wire i_Hsync,
    (* mark_debug = "true" *)	input wire i_Vsync,
    (* mark_debug = "true" *) input wire [23:0] data24b,
    (* mark_debug = "true" *)	input wire vde,
    //output           o_HSync,
    //output           o_VSync,
    (* mark_debug = "true" *) output reg enout,
    (* mark_debug = "true" *) output reg [15:0] bramaddr24b = 0,
    (* mark_debug = "true" *) output reg [7:0] rgb_r,rgb_g,rgb_b,
    (* mark_debug = "true" *) output wire start_frame
 );  

(* mark_debug = "true" *) reg [9:0] o_Row_Count = 0;
(* mark_debug = "true" *) reg [9:0] o_Col_Count = 0;

(* mark_debug = "true" *) wire i_HSync = !i_Hsync;
(* mark_debug = "true" *) wire i_VSync = !i_Vsync; // =============active reverse=========
// -> active low 

reg [1:0] vsync_fall;
reg start_frame_pck;
reg start_frame_reg;
reg start_frame_reg2;
reg [4:0] vsync_fall_count = 0;
localparam vsync_fall_count_max = 2;
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
(* mark_debug = "true" *) wire three = (count_three == 2'b11);//=====================modified
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
            if (count_vsync == 2) begin 
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
            if (count_hsync == 3) begin
                count_hsync <= 0;
            end
            else begin
                count_hsync <= count_hsync + 1;
            end

            if (o_Row_Count == ACTIVE_ROWS -1) begin
                o_Row_Count <= o_Row_Count;
            end
            else if (count_hsync == 3) begin
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