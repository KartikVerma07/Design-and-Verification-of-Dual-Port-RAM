class driver;
  transaction tx;
  mailbox gen2drv;
  
  virtual intf vif;
  
  function new(mailbox gen2drv, virtual intf vif);
    this.gen2drv = gen2drv;
    this.vif = vif;
  endfunction
  
  task run();
    gen2drv.get(tx);

    // Drive one operation for exactly one clock edge
    vif.wr_en   = tx.wr_en;
    vif.rd_en   = tx.rd_en;
    vif.wr_addr = tx.wr_addr;
    vif.rd_addr = tx.rd_addr;
    vif.w_data  = tx.w_data;
    
    tx.display("DRIVER WITH O/P");
  endtask
endclass
  