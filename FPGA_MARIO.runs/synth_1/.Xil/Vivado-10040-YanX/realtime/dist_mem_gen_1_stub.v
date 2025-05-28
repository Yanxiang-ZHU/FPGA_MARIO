// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dist_mem_gen_v8_0_14,Vivado 2023.2" *)
module dist_mem_gen_1(a, d, dpra, clk, we, spo, dpo);
  input [11:0]a;
  input [5:0]d;
  input [11:0]dpra;
  input clk /* synthesis syn_isclock = 1 */;
  input we;
  output [5:0]spo;
  output [5:0]dpo;
endmodule
