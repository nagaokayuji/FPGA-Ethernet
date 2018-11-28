/*
//=================
//  now only 1gbps to reduce timing error
//==================
*/

module rgmii_tx (
    input wire clk,
    input wire clk90,
    input wire phy_ready,
    input wire[7:0] data,
    input wire data_valid,
    input wire data_enable,
    input wire data_error,
    
    output wire eth_txck,
    output wire eth_txctl,
    output wire [3:0] eth_txd
    );
    
    reg [6:0] enable_count = 7'b0000000;
    reg [6:0] enable_frequency = 7'b1111111;
    wire [8:0] times_3;// = 9'b000000000;
    reg [6:0] first_quarter = 7'b0000000;
    reg [6:0] second_quarter = 7'b00000000;
    reg [6:0] third_quarter = 7'b0000000;

     reg [7:0] dout = 8'b00000000;
     reg [1:0] doutctl = 2'b00;
     reg [1:0] doutclk = 2'b00;
    reg [7:0] hold_data;
    reg hold_valid;
    reg hold_error;
    reg ok_to_send = 1'b0;
    reg tx_ready;
    reg tx_ready_meta;

    assign times_3 = {1'b0,enable_frequency,1'b0} + {2'b00,enable_frequency};



always @(posedge clk) begin
    first_quarter <= {2'b00 , enable_frequency[6:2]};
    second_quarter <= {1'b0 , enable_frequency[6:1]};
    third_quarter <= times_3[8:2];
    if (data_enable == 1'b1) begin
        enable_frequency <= enable_count + 1'b1;
        enable_count <= 7'b0000000;
    end 
    
    else if (enable_count != 7'b1111111) begin
        enable_count <= enable_count + 1'b1;
    end

    if (data_enable == 1'b1) begin
        hold_data <= data;
        hold_valid <= data_valid;
        hold_error <= data_error;
        /*
        // enable_frequency == 7'b1111111 ???
        */
        if (enable_frequency == 1) begin // Double data transfer at full frequency
            //dout <= data;
            dout[3:0] <= data[3:0];
            dout[7:4] <= data[7:4];
            doutctl[0] <= ok_to_send && data_valid;
            doutctl[1] <= ok_to_send && (data_valid ^ data_error);
            //doutclk <= 2'b01;
            doutclk[0] <= 1'b1;
            doutclk[1] <= 1'b0;
        end else begin
            // Send the low nibble
            dout[3:0] <= data[3:0];
            dout[7:4] <= data[3:0];
            doutctl[0] <= ok_to_send && data_valid;
            doutctl[1] <= ok_to_send && data_valid;
            doutclk[0] <= 1'b1;
            doutclk[1] <= 1'b1;

        end
   end 
   else if (enable_count == first_quarter - 1'b1) begin
        if (enable_frequency[1] == 1'b1) begin
            // Send the high nibble and valid signal for the last half of this cycle
            doutctl[1] <= ok_to_send && (hold_valid ^ hold_error);
            doutclk[1] <= 1'b0;
        end else begin
            doutctl[0] <= ok_to_send && (hold_valid ^ hold_error);
            doutctl[1] <= ok_to_send && (hold_valid ^ hold_error);
            doutclk[0] <= 1'b0;
            doutclk[1] <= 1'b0;
        end
    end
    else if (enable_count == first_quarter) begin
        doutctl[0] <= ok_to_send && (hold_valid ^ hold_error);
        doutctl[1] <= ok_to_send && (hold_valid ^ hold_error);
        doutclk[0] <= 1'b0;
        doutclk[1] <= 1'b0;
    end
    else if (enable_count == second_quarter - 1) begin
        dout[3:0] <= hold_data[7:4];
        dout[7:4] <= hold_data[7:4];
        // Send the high nibble and valid signal for the last half of this cycle
        doutclk[0] <= 1'b1;
        doutclk[1] <= 1'b1;
        doutctl[0] <= ok_to_send && hold_valid;
        doutctl[1] <= ok_to_send && hold_valid;
    end
    else if (enable_count == third_quarter - 1) begin
        if (enable_frequency[1] == 1'b1) begin
            doutctl[1] <= ok_to_send && (hold_valid ^ hold_error);
            doutclk[1] <= 1'b0;
        end
        else begin
            doutctl[0] <= ok_to_send && (hold_valid ^ hold_error);
            doutctl[1] <= ok_to_send && (hold_valid ^ hold_error);
            doutclk[0] <= 1'b0;
            doutclk[1] <= 1'b0;
        end
    end
    else if (enable_count == third_quarter) begin
        doutclk[0] <= 1'b0;
        doutclk[1] <= 1'b0;
        doutctl[0] <= ok_to_send & (hold_valid ^ hold_error);
        doutctl[1] <= ok_to_send & (hold_valid ^ hold_error);
    end
end


//
// DDR output registers
//
ODDR #(.DDR_CLK_EDGE("SAME_EDGE"),
    .INIT(1'b0),
    .SRTYPE("SYNC")
    ) tx_d0 (
    .Q(eth_txd[0]),
    .C(clk),
    .CE(1'b1),
    .R(1'b0),
    .S(1'b0),
    .D1(dout[0]),
    .D2(dout[4])
    );

ODDR #(.DDR_CLK_EDGE("SAME_EDGE"),
    .INIT(1'b0),
    .SRTYPE("SYNC")
    ) tx_d1 (
    .Q(eth_txd[1]),
    .C(clk),
    .CE(1'b1),
    .R(1'b0),
    .S(1'b0),
    .D1(dout[1]),
    .D2(dout[5])
    );
ODDR #(.DDR_CLK_EDGE("SAME_EDGE"),
        .INIT(1'b0),
        .SRTYPE("SYNC")
        ) tx_d2 (
    .Q(eth_txd[2]),
    .C(clk),
    .CE(1'b1),
    .R(1'b0),
    .S(1'b0),
    .D1(dout[2]),
    .D2(dout[6])
    );
ODDR #(.DDR_CLK_EDGE("SAME_EDGE"),
        .INIT(1'b0),
        .SRTYPE("SYNC")
        ) tx_d3 (
    .Q(eth_txd[3]),
    .C(clk),
    .CE(1'b1),
    .R(1'b0),
    .S(1'b0),
    .D1(dout[3]),
    .D2(dout[7])
    );
ODDR #(.DDR_CLK_EDGE("SAME_EDGE"),
        .INIT(1'b0),
        .SRTYPE("SYNC")
        ) tx_ctl (
    .Q(eth_txctl),
    .C(clk),
    .CE(1'b1),
    .R(1'b0),
    .S(1'b0),
    .D1(doutctl[0]),
    .D2(doutctl[1])
    );
ODDR #(.DDR_CLK_EDGE("SAME_EDGE"),
        .INIT(1'b0),
        .SRTYPE("SYNC")
        ) tx_c (
    .Q(eth_txck),
    .C(clk90),
    .CE(1'b1),
    .R(1'b0),
    .S(1'b0),
    .D1(1'b1),
    .D2(1'b0)
    );

always @(posedge clk) begin
    tx_ready <= tx_ready_meta;
    tx_ready_meta <= phy_ready;
    if ((tx_ready == 1'b1) && (data_valid == 1'b0) && (data_enable == 1'b1)) 
        ok_to_send <= 1'b1;
end

endmodule