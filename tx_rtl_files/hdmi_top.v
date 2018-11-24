module hdmi_top(
	input wire hdmi_rx_clk_n,hdmi_rx_clk_p,
	input wire [2:0] hdmi_rx_n,
	input wire [2:0] hdmi_rx_p,
	inout wire hdmi_rx_scl,
	inout wire hdmi_rx_sda,
)
wire refclk;
wire hdmi_in_ddc_scl_i;
wire hdmi_in_ddc_scl_o;
wire hdmi_in_ddc_scl_t;
wire hdmi_in_ddc_sda_i;
wire hdmi_in_ddc_sda_o;
wire hdmi_in_ddc_sda_t;
IOBUF hdmi_in_ddc_scl_iobuf
     (.I(hdmi_in_ddc_scl_o),
      .IO(hdmi_rx_scl),
      .O(hdmi_in_ddc_scl_i),
      .T(hdmi_in_ddc_scl_t));
IOBUF hdmi_in_ddc_sda_iobuf
     (.I(hdmi_in_ddc_sda_o),
      .IO(hdmi_rx_sda),
      .O(hdmi_in_ddc_sda_i),
      .T(hdmi_in_ddc_sda_t));

clk_for_hdmi clk_for_hdmi_i(
	.clk_in1(clk100MHz),
	.clk_out1(refclk)
)

 (* mark_debug = "true" *) wire [23:0] pdata;
 (* mark_debug = "true" *) wire vde,hsync,vsync,pclk,pclk5x;
wire pclklocked;
    dvi2rgb_0 dvi2rgb (
    .TMDS_Clk_p(hdmi_rx_clk_p),
    .TMDS_Clk_n(hdmi_rx_clk_n),
    .TMDS_Data_p(hdmi_rx_p),
    .TMDS_Data_n(hdmi_rx_n),
    .SDA_I(hdmi_in_ddc_sda_i),
    .SDA_O(hdmi_in_ddc_sda_o),
    .SDA_T(hdmi_in_ddc_sda_t),
    .SCL_I(hdmi_in_ddc_scl_i),
    .SCL_O(hdmi_in_ddc_scl_o),
    .SCL_T(hdmi_in_ddc_scl_t),
    
    
    .RefClk(refclk),
    .aRst(1'b0),
    // output
    .vid_pData(pdata),
    .vid_pVDE(vde),
    .vid_pHSync(hsync),
    .vid_pVSync(vsync),
    .PixelClk(pclk),
  //  .SerialClk(pclk5x),
    .aPixelClkLckd(pclklocked),
    .pRst(rstb)
    );    
//===================================================================

 //===========
reg [23:0] pdata_vga = 0;
 (* mark_debug = "true" *)wire[7:0] pdata8bit;
reg pclkflash = 0;
reg [23:0] pclkflash_t = 0;
(* mark_debug = "true" *)wire [21:0] vga2bramaddr;
(* mark_debug = "true" *)wire ena;

wire [23:0] bramaddr24b;
wire [7:0] rgb_r,rgb_g,rgb_b;

rgb720to480 rgb720to480_i (
	.i_Clk(), //25.2MHz
	.i_Clk3x(pclk),
	.i_Hsync(hsync),
	.i_Vsync(vsync),
	.data24b(pdata),
	.vde(vde),
	.o_HSync(),
	.o_VSync(),
	.enout(ena),
	.bramaddr8b(vga2bramaddr),
	.data8b(),
	.o_Col_Count(), 
	.o_Row_Count(),
	.bramaddr24b(bramaddr24b),
	.rgb_r(rgb_r),
	.rgb_g(rgb_g),
	.rgb_b(rgb_b)
);  

  