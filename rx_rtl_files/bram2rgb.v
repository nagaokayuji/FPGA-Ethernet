`timescale 1ns / 1ps

module bram2rgb(
//input wire [19:0] addr,
//input wire [7:0] cdata,
//input wire pclk,
input wire clk,xrst,en,
(* mark_debug = "true" *) input wire [23:0] in_from_ram,
(* mark_debug = "true" *) output  reg [19:0] ram_addr=0,
(* mark_debug = "true" *) output  reg vd_2s,hd_2s,
(* mark_debug = "true" *) output  reg [23:0] rgb24bit=0,
(* mark_debug = "true" *) output   reg den_2s=0
    );
    
reg [1:0] den_shift;
//output reg [19:0] ram_addr=0,
 reg vd,hd;
 //reg [23:0] rgb24bit=0;
 reg den=0;
//assign den_2s = den_shift[1];
// addr : 0 ~ xmax*ymax*3 -1


//Vact TtlLines Vblank VFreq HFreq PixeFreq Httl Hact Hblank
// 480     525    45   60.0  31.50  25.200   800  640  160
//VGA 640x480   800x525x60=25.2MHz

  wire [15:0] hsync = 16'd96;
  wire [15:0] hbp   = 16'd48;
  wire [15:0] hdata = 16'd640;
  wire [15:0] hfp   = 16'd16;
  wire hsp   = 1;
  wire [15:0] vsync = 16'd2;
  wire [15:0] vbp   = 16'd33;
  wire [15:0] vdata = 16'd480;
  wire [15:0] vfp   = 16'd10;
  wire vsp   = 1;
  
  

  reg  [15:0] hcnt, vcnt;
  reg  [ 7:0] shift;

reg [17:0] ram_addr_ini = 0;
//  wire xrst = !RST;
//wire ram_addrw = (vcnt - 35) * hdata + hcnt - 145; // ok.



  always@(posedge clk or negedge xrst)
    begin//=
    
    den_shift <= {den_shift[0],den};
  
  if(!xrst) begin hcnt<=0; vcnt<=0; shift<=0; rgb24bit<=0; den<=0; hd<=0; vd<=0;ram_addr <= 0; end
  
  
  else if(en) begin
    

    
    if(hcnt<hsync+hbp+hdata+hfp-16'd1) begin // maybe hcnt:640~800.  hsync
    
      hcnt <= hcnt + 1;
    end
         else begin
            hcnt <= 0;
              if(vcnt<vsync+vbp+vdata+vfp-16'd1) begin
               vcnt <= vcnt + 1;
              
             end
           else begin
               //ram_addr <= 0;
               vcnt <= 0;
               shift <= shift + 0;  // stop to shifting
          end
         end
    
    if(hcnt<hsync) hd <= hsp; else hd <= !hsp; // synchronize signals
    if(vcnt<vsync) vd <= vsp; else vd <= !vsp;
    
    
    
    
    if (vd) begin ram_addr_ini <= 0; ram_addr <= 0;end
    
    if (hcnt == hsync - 1 && vcnt >= vsync + vbp)begin  if (ram_addr_ini < 57600) ram_addr_ini <= ram_addr_ini + 320; if (ram_addr < 57600) ram_addr <= ram_addr_ini; end

    if(hsync+hbp<=hcnt && hcnt<hsync+hbp+hdata && vsync+vbp<=vcnt && vcnt<vsync+vbp+vdata) begin// valid
        den <= 1;

                    
        if (hsync+hbp<=hcnt && hcnt< hsync+hbp+320+5 && vcnt < vsync+vbp+180+5)begin
            if (ram_addr < 57600)
                ram_addr <= ram_addr + 1;
            
            rgb24bit <= in_from_ram;
            
        end
        else rgb24bit <= 24'hff00ff;
    
    end
    else begin
      den <= 0;
      
    end
    
  end

    end//=
    
//    reg [19:0] ram_addr_1s = 0;
//    reg [19:0] ram_addr_2s = 0;
    reg vd_1s=0,hd_1s=0;
    reg [23:0] rgb24bit_1s=0;
    reg den_1s=0;
    always @(posedge clk) begin
        vd_1s <= vd;hd_1s<=hd;
        vd_2s <= vd_1s;hd_2s<=hd_1s;
        //rgb24bit_1s<=rgb24bit;rgb24bit_2s<=rgb24bit_1s;
        den_1s<=den;den_2s<=den_1s;
    end
endmodule
