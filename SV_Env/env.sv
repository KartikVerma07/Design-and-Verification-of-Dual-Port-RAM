class env;
  // shared channels
  mailbox #(transaction) gen2drv;
  mailbox #(transaction) mon2scb;
  mailbox #(transaction) mon2cov;

  // components
  driver           d;
  monitor          m;
  scoreboard       s;
  cov              c;
  generator        g;

  function new(virtual intf vif);
    gen2drv = new();
    mon2scb = new();
    mon2cov = new();

    d = new(vif, gen2drv);
    m = new(vif, mon2scb, mon2cov);
    s = new(mon2scb);
    c = new(mon2cov);
    g = new(vif, gen2drv);
  endfunction

  task run(ref logic clk, ref logic rst);
    fork
      d.run();
      m.run();
      s.run();
      c.run();
      g.run();
    join_none
  endtask
endclass
