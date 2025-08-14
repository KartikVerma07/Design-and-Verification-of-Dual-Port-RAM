class monitor;
  transaction tx;
  mailbox mon2scb, mon2cov;
  
  virtual intf vif;
  
  function new(mailbox mon2scb,  mailbox mon2cov, virtual intf vif);
    this.mon2scb = mon2scb;
    this.mon2cov = mon2cov;
    this.vif = vif;
  endfunction
  
  task run();
    tx = new();
    
    tx.wr_en = vif.wr_en;  
    tx.rd_en = vif.rd_en; 
    tx.wr_addr = vif.wr_addr; 
    tx.rd_addr = vif.rd_addr;
    tx.w_data = vif.w_data;
    tx.r_data = vif.r_data;
    
    tx.display("COLLECTED IN MONITOR");
    mon2scb.put(tx);
    mon2cov.put(tx);
  endtask
endclass