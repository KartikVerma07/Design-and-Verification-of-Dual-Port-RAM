class cov;
  transaction tx;
  mailbox mon2cov;
  
  covergroup CovPort;
    address : coverpoint tx.wr_addr {
      bins low    = {[20'h00000 : 20'h55555]};
      bins med    = {[20'h55556 : 20'hAAAAA]};
      bins high   = {[20'hAAAAB : 20'hFFFFF]};
    }
    data : coverpoint  tx.w_data {
      bins low  = {[8'h00 : 8'h55]}; //   0.. 85
      bins med  = {[8'h56 : 8'hAA]}; //  86..170
      bins high = {[8'hAB : 8'hFF]}; // 171..255
    }
	endgroup
  
  function new(mailbox mon2cov);
    CoverPort = new();
    this.mon2cov = mon2cov;
  endfunction
  
  task run();
    while(1) begin
      $display("%t, COVER::RUN PHASE",$time);
      mon2cov.get(tx);
      CoverPort.sample();
    end
  endtask
  
endclass