class seq_raw_next_cycle extends seq_base;
  `uvm_object_utils(seq_raw_next_cycle)

  function new(string name="seq_raw_next_cycle"); 
    super.new(name); 
  endfunction

  task body();
    transaction w,r;
    //`uvm_info("SEQ_START", "Sequence *seq_raw_next_cycle* starting", UVM_MEDIUM);
    // Write
    w = transaction::type_id::create("w");
    w.wr_en   = 1;
    w.rd_en   = 0;
    w.wr_addr = $urandom_range(0,31);
    w.w_data  = $urandom_range(0,255);
    start_item(w); 
    finish_item(w);
    // Next cycle read same address
    r = transaction::type_id::create("r");
    r.wr_en   = 0;
    r.rd_en   = 1;
    r.rd_addr = w.wr_addr;
    start_item(r); 
    finish_item(r);
  endtask
endclass
