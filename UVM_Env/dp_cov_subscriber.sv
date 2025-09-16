class dp_cov_subscriber extends uvm_subscriber#(transaction);
  `uvm_component_utils(dp_cov_subscriber)

  transaction tr;             //The covergroup will read fields from this object at sample time.
  event       sample_trigger; //A custom event that tells the covergroup exactly when to sample. 

  // An associative array that tracks which addresses have been written at least once
  bit written [bit[4:0]];

  covergroup cg @(sample_trigger);
    option.per_instance = 1;             // <<— enables instance-level reporting
    option.name         = "dp_cov_cg";   

    // Addresses
    cp_wr_addr : coverpoint tr.wr_addr {
      bins low  = {[0:10]};
      bins mid  = {[11:21]};
      bins high = {[22:31]};
    }

    cp_rd_addr : coverpoint tr.rd_addr {
      bins low  = {[0:10]};
      bins mid  = {[11:21]};
      bins high = {[22:31]};
    }

    // Write data (ignore when not a write)
    cp_wdata : coverpoint tr.w_data {
      bins low  = {[8'h00:8'h54]};
      bins mid  = {[8'h55:8'hAA]};
      bins high = {[8'hAB:8'hFF]};
      ignore_bins not_write = {[8'h00:8'hFF]} iff (!tr.wr_en);
	}


    // Operation mix
    cp_op : coverpoint {tr.wr_en, tr.rd_en} {
      bins idle  = {2'b00};
      bins read  = {2'b01};
      bins write = {2'b10};
      bins both  = {2'b11};
    }

    // Same vs different address (only when any op)
    cp_same_addr : coverpoint (tr.wr_addr == tr.rd_addr) iff (tr.wr_en || tr.rd_en) {
      bins same = {1'b1};
      bins diff = {1'b0};
    }

    // RAW hazard (same-cycle R+W to same addr)
    cp_hazard : coverpoint (tr.wr_en && tr.rd_en && (tr.wr_addr == tr.rd_addr)) {
      bins no  = {0};
      bins yes = {1};
    }

    // Read-before-write (read an address never written yet)
    cp_unwritten_read : coverpoint (tr.rd_en && !written.exists(tr.rd_addr)) {
      bins no  = {0};
      bins yes = {1};
    }

    // Useful crosses (kept minimal)
    x_op_same     : cross cp_op, cp_same_addr;
    x_hazard_wd   : cross cp_hazard, cp_wdata;
    x_rdaddr_unwr : cross cp_rd_addr, cp_unwritten_read;

  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cg = new();
  endfunction

  // Sample, then update 'written' history after sampling
  virtual function void write(transaction t);
    tr = t;
    -> sample_trigger;
    if (t.wr_en) written[t.wr_addr] = 1'b1;
  endfunction

endclass