class cov;
  mailbox #(transaction) mon2cov;
  transaction tr;

  // track which addresses have ever been written
  bit written [logic[4:0]];

  event sample_ev;

  covergroup cg @(sample_ev);
    option.per_instance = 1;
    option.name = "dp_cov_cg";

    // Address ranges
    cp_wr_addr : coverpoint tr.wr_addr { bins low={[0:10]}; bins mid={[11:21]}; bins high={[22:31]}; }
    cp_rd_addr : coverpoint tr.rd_addr { bins low={[0:10]}; bins mid={[11:21]}; bins high={[22:31]}; }

    // Only sample data bins when it was a write
    cp_wdata : coverpoint tr.w_data iff (tr.wr_en) {
      bins low  = {[8'h00:8'h54]};
      bins mid  = {[8'h55:8'hAA]};
      bins high = {[8'hAB:8'hFF]};
    }

    // Operation mix and hazards
    cp_op : coverpoint {tr.wr_en, tr.rd_en} {
      bins idle  = {2'b00};
      bins read  = {2'b01};
      bins write = {2'b10};
      bins both  = {2'b11};
    }

    cp_same_addr : coverpoint (tr.wr_addr == tr.rd_addr) iff (tr.wr_en || tr.rd_en) {
      bins same = {1'b1};
      bins diff = {1'b0};
    }

    cp_hazard : coverpoint (tr.wr_en && tr.rd_en && (tr.wr_addr == tr.rd_addr)) {
      bins no  = {0};
      bins yes = {1};
    }

    cp_unwritten_read : coverpoint (tr.rd_en && !written.exists(tr.rd_addr)) {
      bins no  = {0};
      bins yes = {1};
    }

    // Useful crosses
    x_op_same     : cross cp_op, cp_same_addr;
    x_hazard_wd   : cross cp_hazard, cp_wdata;
    x_rdaddr_unwr : cross cp_rd_addr, cp_unwritten_read;
  endgroup

  function new(mailbox #(transaction) mon2cov);
    this.mon2cov = mon2cov;
    cg = new();
  endfunction

  task run();
    forever begin
      mon2cov.get(tr);
      -> sample_ev;                    // sample now
      if (tr.wr_en) written[tr.wr_addr] = 1'b1; // update history after sample
    end
  endtask
endclass
