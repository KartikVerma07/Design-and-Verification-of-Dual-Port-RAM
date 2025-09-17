class monitor;
  virtual intf vif;
  mailbox #(transaction) mon2scb;
  mailbox #(transaction) mon2cov; // second tap for coverage
  
  transaction tr;
  transaction tr_cov;

  function new(virtual intf vif,
               mailbox #(transaction) mon2scb,
               mailbox #(transaction) mon2cov);
    this.vif     = vif;
    this.mon2scb = mon2scb;
    this.mon2cov = mon2cov;
  endfunction

  task run();
    // wait for reset deassertion (active-high reset)
    while (vif.rst) @(vif.mon_cb);

    forever begin
      @(vif.mon_cb);
      tr = new();
      tr.wr_en   = vif.mon_cb.wr_en;
      tr.rd_en   = vif.mon_cb.rd_en;
      tr.wr_addr = vif.mon_cb.wr_addr;
      tr.rd_addr = vif.mon_cb.rd_addr;
      tr.w_data  = vif.mon_cb.w_data;
      tr.r_data  = vif.mon_cb.r_data;

      mon2scb.put(tr);

      if (mon2cov != null) begin
        // shallow clone for coverage tap
        tr_cov = new();
        tr_cov.wr_en=tr.wr_en; tr_cov.rd_en=tr.rd_en;
        tr_cov.wr_addr=tr.wr_addr; tr_cov.rd_addr=tr.rd_addr;
        tr_cov.w_data=tr.w_data; tr_cov.r_data=tr.r_data;
        mon2cov.put(tr_cov);
      end
    end
  endtask
endclass
