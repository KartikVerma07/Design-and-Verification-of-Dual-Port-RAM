import uvm_pkg::*; 
`include "uvm_macros.svh"

// --------------------------------------
// Core TB infrastructure
// --------------------------------------
`include "transaction.sv"     // sequence item
`include "intf.sv"            // DUT interface
`include "sequencer.sv"       // sequencer for transactions
`include "driver.sv"          // drives DUT
`include "monitor.sv"         // samples DUT outputs
`include "dp_agent.sv"        // bundles driver+monitor+sequencer
`include "scoreboard.sv"      // reference model checker
`include "dp_cov_subscriber.sv" // coverage subscriber
`include "dp_env.sv"          // environment (agent + scb + cov)

// --------------------------------------
// Stimulus sequences
// --------------------------------------
`include "seq_base.sv"
`include "seq_write.sv"
`include "seq_read.sv"
`include "seq_mixed.sv"
`include "seq_raw_next_cycle.sv"

// --------------------------------------
// Tests (use env + sequences)
// --------------------------------------
`include "dp_test.sv"

// --------------------------------------
// DUT
// --------------------------------------
`include "dp_ram_design.sv"

module top;
  dp_env env;
  
  bit clk=0;
  bit rst;
  always #5 clk = !clk;
  
  intf pif(clk,rst);
  
  dp_ram_design DUT(.clk(pif.clk), 
                 .rst(pif.rst),
                 .wr_en(pif.wr_en),
                 .rd_en(pif.rd_en),
                 .wr_addr(pif.wr_addr),
                 .rd_addr(pif.rd_addr),
                 .w_data(pif.w_data),
                 .r_data(pif.r_data));
  initial begin
    rst = 1;
    repeat (4) @(negedge clk);
    rst = 0;
  end
  initial begin
    uvm_config_db#(virtual intf.DRV)::set(null,"uvm_test_top.env.agt.drv","vif",pif);
    uvm_config_db#(virtual intf.MON)::set(null,"uvm_test_top.env.agt.mon","vif",pif);
  end

  initial run_test("dp_test");

endmodule