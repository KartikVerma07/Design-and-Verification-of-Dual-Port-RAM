interface intf(input logic clk, rst);
  
  logic [4:0] wr_addr;
  logic [4:0] rd_addr;
  logic [7:0] w_data;
  logic [7:0] r_data;
  bit         wr_en;
  bit         rd_en;

  // Driver clocking: drives on posedge, no skew
  clocking drv_cb @(posedge clk);
    output wr_en, rd_en, wr_addr, rd_addr, w_data;
  endclocking

  // Monitor clocking: samples on posedge after drives
  clocking mon_cb @(posedge clk);
    default input #1step output #0;
    input wr_en, rd_en, wr_addr, rd_addr, w_data, r_data;
  endclocking

  modport DRV (clocking drv_cb, input clk, rst);
  modport MON (clocking mon_cb, input clk, rst);
  
endinterface