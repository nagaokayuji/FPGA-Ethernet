`timescale 1ns / 1ps

/*
asynchronous. i_hsync,i_vsync -> like reset signals
always @(opsedge i_clk or negedge i_hsync or negedge i_vsync) // ----important?

*/
module rgb2bram #(
 parameter ACTIVE_COLS = 320,//640, 
 parameter ACTIVE_ROWS = 180)//480) 

(
	input            clk125MHz, //25.2MHz
	input pclk,
	input wire i_Hsync,
	input wire i_Vsync,
	input wire [23:0] data24b,
	input wire vde,
	output           o_HSync,
	output           o_VSync,
	output reg enout,
	output reg  [21:0] bramaddr8b,
	output reg [7:0] data8b,
	output reg [9:0] o_Col_Count = 0, 
	output reg [9:0] o_Row_Count = 0,
	output reg [31:0] bramaddr24b = 0,
	output reg [7:0] rgb_r,rgb_g,rgb_b,
	(* mark_debug = "true" *) output wire start_frame
 );  
 
 wire i_HSync = !i_Hsync;
 wire i_VSync = !i_Vsync; // =============active reverse=========
// -> active low 

reg [1:0] vsync_fall;
reg start_frame_pck;
reg start_frame_reg;
reg start_frame_reg2;
reg [4:0] vsync_fall_count = 0;
localparam vsync_fall_count_max = 2;
wire [4:0] vsync_fall_count_next = (vsync_fall_count < vsync_fall_count_max ? vsync_fall_count + 1'b1 : 0);

always @(posedge clk125MHz) begin
	start_frame_reg <= start_frame_pck;
	start_frame_reg2 <= start_frame_reg;
end
assign start_frame = start_frame_reg2;

always @(posedge pclk) begin
	vsync_fall <= {vsync_fall[0],i_VSync};
	if (vsync_fall == 2'b10) begin
		vsync_fall_count <= vsync_fall_count_next;
	end
	start_frame_pck <= ( vsync_fall == 2'b10 && (vsync_fall_count == vsync_fall_count_max));
 end
reg [2:0] count_three = 0;
 wire three = (count_three == 2'b11);//=====================modified
reg [23:0] data_sampling = 0;
 reg fallen_h = 0;
 reg fallen_v = 0;
 reg vclk = 0;
 reg half = 0;
 reg [1:0] count_hsync = 0;
 reg [1:0] count_vsync = 0;
 reg [1:0] count_cols = 0;
 reg inaaaa = 0;
 reg [20:0] bramaddr24b_ini = 0;
 always @(posedge pclk/* or negedge i_HSync or negedge i_VSync*/) // 25.2MHz
 begin
 //half <= !half;
 //bramaddr8b <= (o_Col_Count + o_Row_Count * ACTIVE_COLS)*3 + (count_three);
 //if (half) begin
 
 if ((!i_HSync) || (!i_VSync) || (!vde)) begin // blank
  inaaaa = 1;

 
 count_three <=0;
 
 enout <= 0;
 
  if (!i_VSync && !fallen_v && !vde) begin // next frame.
    bramaddr24b <= 0; // new logic 10/22
    bramaddr24b_ini <= 0;
    fallen_v <= 1;
    if (count_vsync == 2) count_vsync<=0; // 20fps
     else count_vsync <= count_vsync + 1;
    count_three <= 0;
    o_Row_Count <= 0;
    o_Col_Count <= 0;// ichiou
    count_hsync <= 0;
end   
else if (!i_HSync && !fallen_h && !vde) begin
    //vclk <= !vclk;
    o_Col_Count <= 0;
    fallen_h <= 1;
    if (count_hsync == 3) count_hsync <= 0;
    else count_hsync <= count_hsync + 1;
    //if (vclk) begin
    if (o_Row_Count == ACTIVE_ROWS -1)
           o_Row_Count <= o_Row_Count;
    else if (count_hsync == 3) begin o_Row_Count <= o_Row_Count + 1;
    bramaddr24b_ini <= bramaddr24b_ini + ACTIVE_COLS;//420
    bramaddr24b <= bramaddr24b_ini;
        //bramaddr24b <= bramaddr24b + 1;
        end // next line.
    //end
    count_three <= 0;
 end


end else begin // =====not sync
inaaaa = 0;
fallen_h <= 0;
fallen_v <= 0;
if (count_vsync == 0) begin
if (count_hsync == 0) begin

if (count_three == 0) data_sampling <= data24b;

 if (three) begin
 
    count_three <= 0;
 /*   if (count_cols == 2) begin
        count_cols <= 0;
    end
    else begin count_cols <= count_cols + 1;end
 */
 end
 else begin count_three <= count_three + 1'b1;end
 
 if (three) begin // ========row,col countup. 1/3 rate.
   if (o_Col_Count == ACTIVE_COLS -1)
   o_Col_Count <= o_Col_Count;
   else begin 
    if (bramaddr24b < 57600)
        bramaddr24b <= bramaddr24b + 1;
    o_Col_Count <= o_Col_Count + 1'b1;
    enout <= 1;
    rgb_r <= data_sampling[23:16];
    rgb_g <= data_sampling[15:8];
    rgb_b <= data_sampling[7:0];
   end
    
  /*
   if (o_Row_Count == ACTIVE_ROWS -1)
       o_Row_Count <= o_Row_Count;
   */
   
   
   
 end else enout <= 0;// end if(three)
 
 
// //========= create data==========\
// if (count_three == 1) data8b <= data_sampling[7:0];
// if (count_three == 2) data8b <= data_sampling[15:8];
// if (count_three == 0) data8b <= data_sampling[23:16];
 
 
 end  
 end  
end
end
//assign bramaddr24b = (o_Col_Count + o_Row_Count * ACTIVE_COLS);
 //assign bramaddr8b = (o_Col_Count + o_Row_Count * ACTIVE_COLS)*3 + (count_three);
 assign o_HSync = o_Col_Count < ACTIVE_COLS ? 1'b1 : 1'b0;
 assign o_VSync = o_Row_Count < ACTIVE_ROWS ? 1'b1 : 1'b0;
 

 
endmodule