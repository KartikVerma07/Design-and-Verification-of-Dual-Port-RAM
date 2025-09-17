`timescale 1ns/1ps

// includes
`include "intf.sv"
`include "transaction.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "cov.sv"
`include "generator.sv"
`include "env.sv"

// DUT
`include "dp_ram_design.sv"

module top;
  // clock & reset (active-high reset)
  logic clk = 0;
  logic rst = 1;

  always #5 clk = ~clk;     // 100 MHz

  initial begin
    // hold reset high for a few cycles, then release
    repeat (3) @(posedge clk);
    rst = 0;
  end

  // Interface instance
  intf pif(.clk(clk), .rst(rst));

  // DUT hookup
  dp_ram_design dut (
    .clk    (pif.clk),
    .rst    (pif.rst),
    .wr_en  (pif.wr_en),
    .rd_en  (pif.rd_en),
    .wr_addr(pif.wr_addr),
    .rd_addr(pif.rd_addr),
    .w_data (pif.w_data),
    .r_data (pif.r_data)
  );

  // Plain-SV environment
  env e;

  initial begin
    e = new(pif);       // pass the interface to all components
    e.run(clk, rst);    // start all threads
  end
  
  initial begin
    repeat (10_000) @(posedge clk);
    $display("[TB] TIMEOUT! Forcing finish.");
    $finish;
  end
endmodule
