`include "intf.sv"
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "cov.sv"
`include "env.sv"
 
module top;
  env env;
  
  bit clk, rst;
  always #5 clk = !clk;
  
  initial begin
    rst = 0;
    @(negedge clk);
    rst = 1;
    #1000 $finish;
  end
  
  intf pif(clk,rst);
  
  dp_ram DUT(.clk(pif.clk), 
                 .rst(pif.rst),
                 .wr_en(pif.wr_en),
                 .rd_en(pif.rd_en),
                 .wr_addr(pif.wr_addr),
                 .rd_addr(pif.rd_addr),
                 .w_dataa(pif.w_data),
                 .r_data(pif.r_data));
  initial begin
    env = new(pif);
    env.run();
  end
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule