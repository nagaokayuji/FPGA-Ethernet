// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_2,Vivado 2018.3" *)
module vram(clka, wea, addra, dina, clkb, addrb, doutb);
  input clka;
  input [0:0]wea;
  input [15:0]addra;
  input [7:0]dina;
  input clkb;
  input [15:0]addrb;
  output [7:0]doutb;
endmodule
