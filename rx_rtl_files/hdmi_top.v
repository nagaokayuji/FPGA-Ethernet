
module hdmi_top(
input wire clk,//100MHz system clock
input wire RST,
input wire clk125MHz,
input wire dclk,// 125MHz ethernet clock 
input wire [7:0] data_in,
input wire data_en,
output wire hdmi_tx_clk_n,hdmi_tx_clk_p,
output wire [2:0] hdmi_tx_n,
output wire [2:0] hdmi_tx_p

    );
    
  wire clk125MHz_buffered;
    BUFG bufg_125(
    .I(clk125MHz),
    .O(clk125MHz_buffered)
    );
    
    
    // generate pck, 25.2MHz,
    wire pck, pck5x;//,CLKFBOUT,LOCKED;

    wire clk125MHz_2;
    clk_hdmi_top clk_hdmi_top_i(
    .clk_out1(clk125MHz_2),
    .clk_out2(pck),
    .clk_out3(pck5x),
    .clk_in1(clk)
    );
    
    //wire [7:0] red,grn,blu;

    
    wire [23:0] data24b;
    wire [18:0] addr24b;
    wire enout2bram;
    
       wire [15:0] addr2vram;
    wire [7:0] data_r,data_g,data_b,dout_r,dout_g,dout_b;
    wire wea_r,wea_g,wea_b;
    wire [7:0] data_rgb;
    wire [1:0] rgbcount;
    cnv8to24 cnv8to24 (
   // .clk(pck),
    .dclk(dclk/*clk125MHz_buffered*/),//===============
    .data8b(data_in),
    .en(data_en),
   // .startaddr8b(start_addr),
   
    .addr2vram(addr2vram),
    .count(rgbcount),
    .data_rgb(data_rgb),
    .wea_r(wea_r),
    .wea_g(wea_g),
    .wea_b(wea_b)
   
   );
    
    
    
//        output reg [16:0] addr2vram = 0,
//   output reg [1:0] count = 0,
//   output reg [7:0] data_rgb,//data_r=0,data_g=0,data_b=0,
//   output reg wea_r,wea_g,wea_b
    
    
   wire [23:0] from_ram;
   wire [15:0] ram_addr;
   wire [23:0] bram_douta;
   //reg [23:0] bramout_fordebug;
//   assign data_r = rgbcount == 0 ? data_rgb:0;
//   assign data_g = rgbcount == 1 ? data_rgb:0;
//   assign data_b = rgbcount == 2 ? data_rgb:0;
   
   // ========================
   // NEW VRAM 10/22
   // ============================

   vram vram_r(
   .clka(dclk), // dck but 1/3 speed
   .wea(wea_r),
   .addra(addr2vram),
   .dina(data_rgb),
   .clkb(pck),// ---------- port B is for pixel
   .addrb(ram_addr),//  correspond to coordinate of pix
   .doutb(dout_r)//24bits
   );
   
   vram vram_g(
   .clka(dclk), // dck but 1/3 speed
   .wea(wea_g),
   .addra(addr2vram),
   .dina(data_rgb),
   .clkb(pck),// ---------- port B is for pixel
   .addrb(ram_addr),//  correspond to coordinate of pix
   .doutb(dout_g)//24bits
   );
   
   vram vram_b(
   .clka(dclk), // dck but 1/3 speed
   .wea(wea_b),
   .addra(addr2vram),
   .dina(data_rgb),
   .clkb(pck),// ---------- port B is for pixel
   .addrb(ram_addr),//  correspond to coordinate of pix
   .doutb(dout_b)//24bits
   );
   assign from_ram = {dout_r,dout_g,dout_b};
   
   /*
   
   bram_24bit bram_24bit_i (
   .clka(dclk), // dck but 1/3 speed
   .ena(1'b1),
   .wea(enout2bram),
   .addra(addr24b),
   .dina(data24b),//24bits
   .douta(bram_douta),
   .clkb(pck),// ---------- port B is for pixel
   .enb(1'b1),
   .web(1'b0),
   .addrb(ram_addr),//  correspond to coordinate of pix
   .dinb(0),
   .doutb(from_ram)//24bits
   );
    */
    
    wire [23:0] rgb24bit;
    wire hd,vd,den;
		reg RST_pck;
		reg RST__pck;
		always @(posedge pck) begin
			RST__pck <= RST_pck;
			RST_pck <= RST;
		end

    bram2rgb bram2rgb_i (
        .clk(pck),
        .xrst(!RST__pck),
        .en(1'b1),
        .in_from_ram(from_ram),
        .ram_addr(ram_addr),
        .vd_2s(vd),
        .hd_2s(hd),
        .rgb24bit(rgb24bit),
        .den_2s(den)
    );
    
    rgb2dvi_0 rgb2dvi (
    .TMDS_Clk_p(hdmi_tx_clk_p),
    .TMDS_Clk_n(hdmi_tx_clk_n),
    .TMDS_Data_p(hdmi_tx_p),
    .TMDS_Data_n(hdmi_tx_n),
    .aRst(RST),
    .vid_pData({rgb24bit[23:16],rgb24bit[15:8],rgb24bit[7:0]}), // modified
    .vid_pVDE(den),
    .vid_pHSync(hd),
    .vid_pVSync(vd),
    .PixelClk(pck),
    .SerialClk(pck5x)
    );
    

    
    
endmodule
