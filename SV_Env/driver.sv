class driver;
  virtual intf vif;
  mailbox #(transaction) gen2drv;

  function new(virtual intf vif, mailbox #(transaction) gen2drv);
    this.vif     = vif;
    this.gen2drv = gen2drv;
  endfunction

  task run();
    // hold lines inactive
    vif.reset_signals();

    forever begin
      transaction tr;
      gen2drv.get(tr);                   // wait for next item

      // Drive for exactly one clock
      @(vif.drv_cb);
      vif.drv_cb.wr_en   <= tr.wr_en;
      vif.drv_cb.rd_en   <= tr.rd_en;
      vif.drv_cb.wr_addr <= tr.wr_addr;
      vif.drv_cb.rd_addr <= tr.rd_addr;
      vif.drv_cb.w_data  <= tr.w_data;

      @(vif.drv_cb);
      // deassert enables; addresses/data can stay (don’t care)
      vif.drv_cb.wr_en   <= 0;
      vif.drv_cb.rd_en   <= 0;
    end
  endtask
endclass
