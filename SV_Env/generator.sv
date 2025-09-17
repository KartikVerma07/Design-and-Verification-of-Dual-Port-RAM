class generator;
  virtual intf vif;
  mailbox #(transaction) gen_mbx;

  function new(virtual intf vif, mailbox #(transaction) gen2drv);
    this.vif    = vif;
    this.gen_mbx = gen2drv;
  endfunction

  task run();
    // wait for reset to deassert (active-high)
    @(posedge vif.clk);
    wait (vif.rst == 1'b0);

    // A) write-only bursts
    repeat (32) begin
      transaction tr = new();
      assert(tr.randomize() with { wr_en==1; rd_en==0; });
      gen_mbx.put(tr);
      //$display("[%0t] GEN  : WRITE  wa=%0d wd=0x%02h", $time, tr.wr_addr, tr.w_data);
      @(posedge vif.clk);
    end

    // B) read-only bursts (some may be unwritten → X/0 depending on mem init)
    repeat (32) begin
      transaction tr = new();
      assert(tr.randomize() with { wr_en==0; rd_en==1; });
      gen_mbx.put(tr);
      //$display("[%0t] GEN  : READ   ra=%0d", $time, tr.rd_addr);
      @(posedge vif.clk);
    end

    // C) read+write SAME address (RAW same-cycle; OLD data should appear)
    repeat (10) begin
      transaction tr = new();
      assert(tr.randomize() with { wr_en==1; rd_en==1; rd_addr==wr_addr; });
      gen_mbx.put(tr);
      //$display("[%0t] GEN  : SAW(Same addr) addr=%0d wd=0x%02h", $time, tr.wr_addr, tr.w_data);
      @(posedge vif.clk);
    end

    // D) read+write DIFF addresses (no RAW hazard)
    repeat (10) begin
      transaction tr = new();
      assert(tr.randomize() with { wr_en==1; rd_en==1; rd_addr!=wr_addr; });
      gen_mbx.put(tr);
      //$display("[%0t] GEN  : RW(D)  wa=%0d ra=%0d wd=0x%02h",$time, tr.wr_addr, tr.rd_addr, tr.w_data);
      @(posedge vif.clk);
    end

  endtask
endclass
