class env;
  generator gen;
  driver drv;
  monitor mon;
  scoreboard scb;
  cov cvr;
  
  mailbox gen2drv = new();
  mailbox mon2scb = new();
  mailbox mon2cov = new();
  
  virtual intf vif;
  
  function new(virtual intf vif);
    this.vif = vif;
    gen = new(gen2drv);
    drv = new(gen2drv, vif);
    mon = new(mon2scb, mon2cov, vif);
    scb = new(mon2scb);
    cvr = new(mon2cov);
  endfunction
  
  task run();
    fork
      gen.write();
      drv.run();
      mon.run();
      scb.run();
    join
    #50	fork
      gen.read();
      drv.run();
      mon.run();
      scb.run();
    join
    #50	fork
      gen.write_read_same_addr();
      drv.run();
      mon.run();
      scb.run();
    join
  endtask
endclass
      