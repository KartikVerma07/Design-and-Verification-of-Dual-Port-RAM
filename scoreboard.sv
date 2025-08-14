class scoreboard;
  transaction tx, tx_ref;
  mailbox mbx;
  
  function new(mailbox mon2scb);
    this.mbx = mon2scb;
  endfunction
  task run();
    mbx.get(tx);
    tx.display("SCOREBOARD");
    
    tx_ref = new();
    tx_ref.wr_en = tx.wr_en;
    tx_ref.rd_en = tx.rd_en;
    tx_ref.wr_addr = tx.wr_addr;
    tx_ref.rd_addr = tx.rd_addr;
    tx_ref.w_data = tx.w_data;
  endtask
    
endclass