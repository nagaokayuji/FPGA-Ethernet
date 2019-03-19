// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_3,Vivado 2018.3" *)
module fifo_9w16d(rst, wr_clk, rd_clk, din, wr_en, rd_en, dout, full, 
  empty, prog_full, prog_empty, wr_rst_busy, rd_rst_busy);
  input rst;
  input wr_clk;
  input rd_clk;
  input [8:0]din;
  input wr_en;
  input rd_en;
  output [8:0]dout;
  output full;
  output empty;
  output prog_full;
  output prog_empty;
  output wr_rst_busy;
  output rd_rst_busy;
endmodule
