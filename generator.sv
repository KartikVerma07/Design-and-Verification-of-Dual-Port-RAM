class generator;
  transaction tx,t;
  mailbox gen2drv;
  	
  logic [4:0] temp_addr;
  logic [7:0] temp_data;
  
  function new(mailbox gen2drv);
    this.gen2drv = gen2drv;
  endfunction
  
  task write();
    tx = new();
    tx.wr_en = 1;  
    tx.rd_en = 0;
    
    // randomizes only rand fields (wr_addr, w_data)
    tx.rd_addr.rand_mode(0);
    assert(tx.randomize());
    tx.rd_addr.rand_mode(1);
    
    gen2drv.put(tx);
    tx.display("GEN: WRITE");
  endtask
  
  task read();
    tx = new();
    tx.wr_en = 0;  
    tx.rd_en = 1;
    
    // randomizes only rand fields (rd_addr)
    tx.wr_addr.rand_mode(0);
    tx.w_data.rand_mode(0);
    assert(tx.randomize());
    tx.wr_addr.rand_mode(1);
    tx.w_data.rand_mode(1);
    
    gen2drv.put(tx);
    t.display("GEN: READ");
  endtask
  
  task write_read_same_addr();
    tx = new();
    tx.wr_en = 0;  
    tx.rd_en = 1;
    
    tx.wr_addr.rand_mode(0);
    assert(tx.randomize());                // sets wr_addr, w_data
    tx.wr_addr.rand_mode(1);
    temp_data = tx.w_data;
    temp_addr = tx.rd_addr;
    gen2drv.put(tx);
    tx.display("GEN: READ in WRITE_READ");
    
    #20;
    t = new();
    t.wr_en = 1;  
    t.rd_en = 0;
    
    t.w_data = temp_data;
    t.wr_addr = temp_addr;                // same address as write
    gen2drv.put(t);
    t.display("GEN: WRITE in WRITE_READ");
  endtask
  
endclass