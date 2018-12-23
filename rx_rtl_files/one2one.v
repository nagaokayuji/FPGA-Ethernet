// one 2 one module.
// outputs 2 clocks later.

module one2one(
    input wire clk,rst,rx_en_w,clk125MHz, // clk, rst, en, clk for output
   (* mark_debug = "true" *)  input wire [7:0] rxdata_w, // input data, wire --> aligned: rx_data
    //input wire [3:0] switches, // input switches 
	// (* mark_debug = "true" *)	output reg [3:0] rx_id_inter=3, // for debug. maybe deleted soon
   (* mark_debug = "true" *)  output wire [7:0] data_out, // output data
  (* mark_debug = "true" *)   output wire en_out,		// output enable
  (* mark_debug = "true" *)   output wire lost		// loss detected. 
 //(* mark_debug = "true" *)   output wire[2:0] comp3bit // for debug. maybe deleted soon
    );
    localparam whereisid = 6'h22;
    
    reg [7:0] rxdata=0;
    reg rx_en = 0;
    reg [11:0] addr = 0;
    reg [3:0] rx_id = 0;
    reg en_after_id = 0;
    reg [7:0] shift1_rxdata;
    always @(posedge clk) begin
        rx_en <= rx_en_w;
        rxdata <= rxdata_w;
        shift1_rxdata <= rxdata;
     
     if (rx_en) begin
        addr <= addr + 1'b1;
     end
     else begin
        addr <= 1'b0;
        rx_id <= 4'b0;
     end
        
     if (addr == whereisid) begin
        rx_id <= rxdata[3:0];
      end
      else if (addr > whereisid) begin
        if (rx_id == 1'b1) begin
            en_after_id <= rx_en;
        end
     end
    end
    
    assign data_out = shift1_rxdata;
    assign en_out = en_after_id;
    assign lost = 1'b0;
    
     
     
endmodule
