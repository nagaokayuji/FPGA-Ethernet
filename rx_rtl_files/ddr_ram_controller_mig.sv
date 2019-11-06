`timescale 1ns / 1ps
`define DATA_WIDTH 256
`define ADDR_WIDTH 25
`define DDR_DQ_WIDTH 32
`define DDR_DQS_WIDTH 4
`define DDR_MASK_WIDTH 16

module ddr_ram_controller_mig 
	(
	// User interface ports
    output						ui_clk,
    output						ui_clk_sync_rst,
    input	[ADDR_WIDTH-1:0]	wr_addr,
    input	[DATA_WIDTH-1:0]	wr_data,
    input	[ADDR_WIDTH-1:0]	rd_addr,
	output	[DATA_WIDTH-1:0]	rd_data,
    input						wr_en,
    input 						rd_en,
	output reg					wr_busy,
	output reg					rd_busy,
    output                      rd_data_valid,
    // Physical ports
    input                       clk,
    input                       clk_ref,
    input                       clk_p,
    input                       clk_n,
    input                       rst,
    output  [14:0]              ddr3_addr,
    output  [2:0]               ddr3_ba,
    output                      ddr3_cas_n,
    output                      ddr3_ck_n,
    output                      ddr3_ck_p,
    output                      ddr3_cke,
    output                      ddr3_ras_n,
    output                      ddr3_reset_n,
    output                      ddr3_we_n,
    inout   [DDR_DQ_WIDTH-1:0]  ddr3_dq,
    inout   [DDR_DQS_WIDTH-1:0] ddr3_dqs_n,
    inout   [DDR_DQS_WIDTH-1:0] ddr3_dqs_p,
    output                      ddr3_cs_n,
    output  [DDR_DQS_WIDTH-1:0] ddr3_dm,
    output                      ddr3_odt
    );

    // Memory interface MIG
    reg [28:0]                  app_addr;
    reg [2:0]                   app_cmd;
    reg                         app_en;
    reg  [DATA_WIDTH-1:0]       app_wdf_data;
    reg                         app_wdf_end;
    reg                         app_wdf_wren;
    wire [DATA_WIDTH-1:0]       app_rd_data;
    wire                        app_rd_data_end;
    wire                        app_rd_data_valid;
    wire                        app_rdy;
    wire                        app_wdf_rdy;
    wire                        app_sr_req;
    wire                        app_ref_req;
    wire                        app_zq_req;
    wire                        app_sr_active;
    wire                        app_ref_ack;
    wire                        app_zq_ack;
    wire [DDR_MASK_WIDTH-1:0]   app_wdf_mask;
    wire                        init_calib_complete;

        mig_7series_0 _mig (
            // Memory interface ports
            .ddr3_addr                      (ddr3_addr),
            .ddr3_ba                        (ddr3_ba),
            .ddr3_cas_n                     (ddr3_cas_n),
            .ddr3_ck_n                      (ddr3_ck_n),
            .ddr3_ck_p                      (ddr3_ck_p),
            .ddr3_cke                       (ddr3_cke),
            .ddr3_ras_n                     (ddr3_ras_n),
            .ddr3_reset_n                   (ddr3_reset_n),
            .ddr3_we_n                      (ddr3_we_n),
            .ddr3_dq                        (ddr3_dq),
            .ddr3_dqs_n                     (ddr3_dqs_n),
            .ddr3_dqs_p                     (ddr3_dqs_p),
            .ddr3_cs_n                      (ddr3_cs_n),
            .ddr3_dm                        (ddr3_dm),
            .ddr3_odt                       (ddr3_odt),
            // Application interface ports
            .app_addr                       (app_addr),
            .app_cmd                        (app_cmd),
            .app_en                         (app_en),
            .app_wdf_data                   (app_wdf_data),
            .app_wdf_end                    (app_wdf_end),
            .app_wdf_wren                   (app_wdf_wren),
            .app_rd_data                    (app_rd_data),
            .app_rd_data_end                (app_rd_data_end),
            .app_rd_data_valid              (app_rd_data_valid),
            .app_rdy                        (app_rdy),
            .app_wdf_rdy                    (app_wdf_rdy),
            .app_sr_req                     (app_sr_req),
            .app_ref_req                    (app_ref_req),
            .app_zq_req                     (app_zq_req),
            .app_sr_active                  (app_sr_active),
            .app_ref_ack                    (app_ref_ack),
            .app_zq_ack                     (app_zq_ack),
            .ui_clk                         (ui_clk),
            .ui_clk_sync_rst                (ui_clk_sync_rst),
            .app_wdf_mask                   (app_wdf_mask),
            .init_calib_complete            (init_calib_complete),
            // System Clock Ports
            //.sys_clk_p                       (clk_p),
            //.sys_clk_n                       (clk_n),
            .sys_clk_i                       (clk),
            .sys_rst                         (rst)
        );

    localparam CMD_WRITE = 3'b000;
    localparam CMD_READ  = 3'b001;

    assign app_sr_req = 1'b0;
    assign app_ref_req = 1'b0;
    assign app_zq_req = 1'b0;

    assign app_wdf_mask = 'b0; // All

    reg [ADDR_WIDTH-1:0]    rd_addr_int, rd_addr_int_next;
    reg [ADDR_WIDTH-1:0]    wr_addr_int, wr_addr_int_next;
	reg [DATA_WIDTH-1:0]    wr_data_int, wr_data_int_next;

    reg wr_queued, wr_queued_next;
    reg rd_queued, rd_queued_next;

    enum {
        CALIBRATION,
        IDLE,
        WRITE,
        READ
    } state = CALIBRATION, state_next;

    always @* begin
        state_next = CALIBRATION;
        rd_queued_next = 1'b0;
        wr_queued_next = 1'b0;
        rd_busy = 1'b0;
        wr_busy = 1'b0;
        app_en  = 1'b0;
        app_cmd = 3'b011;
        app_wdf_wren = 1'b0;
        app_wdf_end = 1'b0;
        app_addr = 'b0;
        app_wdf_data = 'b0;
        wr_addr_int_next = wr_addr_int;
        wr_data_int_next = wr_data_int;
        rd_addr_int_next = rd_addr_int;

        if (wr_en) begin
            wr_addr_int_next = wr_addr;
            wr_data_int_next = wr_data;
        end
        if (rd_en) begin
            rd_addr_int_next = rd_addr;
        end

        case (state)
            CALIBRATION:
            begin
                rd_busy = 1'b1;
                wr_busy = 1'b1;
                if (init_calib_complete) begin
                    state_next = IDLE;
                end
            end

            IDLE:
            begin
                // nothing happen
                state_next = IDLE;
                rd_queued_next = 1'b0;
                wr_queued_next = 1'b0;
                rd_busy = 1'b0;
                wr_busy = 1'b0;
                app_en  = 1'b0;
                app_cmd = 3'b011;
                app_wdf_wren = 1'b0;
                app_wdf_end = 1'b0;
                app_addr = 'b0;
                app_wdf_data = 'b0;
                //some request
                if (rd_en) begin
                    state_next = READ;
                    wr_queued_next = wr_en; // Read has precedence over write operations
                end else if (wr_en) begin
                    state_next = WRITE;
                end
            end

            READ:
            begin
                state_next = READ;
                rd_queued_next = 1'b0;
                wr_queued_next = wr_queued || wr_en;
                rd_busy = 1'b1;
                wr_busy = wr_queued;
                app_en = 1'b1;
                app_cmd = CMD_READ;
                app_wdf_wren = 1'b0;
                app_wdf_end = 1'b0;
                app_addr = {rd_addr_int,{(29-ADDR_WIDTH){1'b0}}};
                app_wdf_data = 'b0;
                if (app_rdy) begin // Read done
                    state_next = IDLE;
                    rd_busy = 1'b0; // Allows rd_en to be asserted on the same cycle
                    if (wr_queued) begin // Queued write
                        state_next = WRITE;
                        wr_queued_next = 1'b0;
                        rd_queued_next = rd_en;
                    end else if (rd_en) begin // Read request
                        state_next = READ;
                    end else if (wr_en) begin // Write request
                        state_next = WRITE;
                        wr_queued_next = 1'b0;
                    end
                end
            end

            WRITE:
            begin
                state_next = WRITE;
                rd_queued_next = rd_queued || rd_en;
                wr_queued_next = 1'b0;
                rd_busy = rd_queued;
                wr_busy = 1'b1;
                app_en = 1'b1;
                app_cmd = CMD_WRITE;
                app_wdf_wren = 1'b0; // app_wdf_wren is asserted when the write buffer is available
                app_wdf_end = 1'b0; // appapp_wdf_end is asserted when the write buffer is available
                app_addr = {wr_addr_int,{(29-ADDR_WIDTH){1'b0}}};
                app_wdf_data = wr_data_int;
                if (app_rdy && app_wdf_rdy) begin // Write operation
                    state_next = IDLE;
                    app_wdf_wren = 1'b1;
                    app_wdf_end = 1'b1;
                    wr_busy = 1'b0;
                    if (rd_en || rd_queued) begin
                        state_next = READ;
                        rd_queued_next = 1'b0;
                        wr_queued_next = wr_en;
                    end else if (wr_en) begin
                        state_next = WRITE;
                    end
                end
            end
        endcase
    end

    always @(posedge ui_clk) begin
        if (ui_clk_sync_rst) begin
            state       <= CALIBRATION;
            rd_addr_int <= 'd0;
            wr_addr_int <= 'd0;
            wr_data_int <= 'd0;
            wr_queued   <= 'b0;
            rd_queued   <= 'b0;
        end else begin
            state       <= state_next;
            rd_addr_int <= rd_addr_int_next;
            wr_addr_int <= wr_addr_int_next;
            wr_data_int <= wr_data_int_next;
            wr_queued   <= wr_queued_next;
            rd_queued   <= rd_queued_next;
        end
    end

    assign rd_data_valid    = app_rd_data_valid;
    assign rd_data          = app_rd_data;
endmodule
