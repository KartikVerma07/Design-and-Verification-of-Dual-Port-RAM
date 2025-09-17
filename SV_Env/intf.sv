interface intf(input logic clk, input logic rst);
  // DUT signals
  logic        wr_en, rd_en;
  logic [4:0]  wr_addr, rd_addr;
  logic [7:0]  w_data;
  logic [7:0]  r_data;

  // Drive at posedge; sample (monitor) in the same delta after #1step
  clocking drv_cb @(posedge clk);
    output wr_en, rd_en, wr_addr, rd_addr, w_data;
    input  r_data;
  endclocking

  clocking mon_cb @(posedge clk);
    input wr_en, rd_en, wr_addr, rd_addr, w_data, r_data;
  endclocking

  // // Convenient reset of driven signals
   task automatic reset_signals();
     drv_cb.wr_en   <= 0;
     drv_cb.rd_en   <= 0;
     drv_cb.wr_addr <= '0;
     drv_cb.rd_addr <= '0;
     drv_cb.w_data  <= '0;
  endtask
endinterface
