class seq_mixed extends seq_base;
  `uvm_object_utils(seq_mixed)

  rand int unsigned n_ops      = 32;
  rand int unsigned hazard_pct = 20; // % forcing same-addr same-cycle
  constraint c_hazard { hazard_pct inside {[0:100]}; }

  function new(string name="seq_mixed"); 
    super.new(name); 
  endfunction

  task body();
    if (pseq != null && n_ops == 0) n_ops = pseq.default_n_ops;
    //`uvm_info("SEQ_START", $sformatf("Sequence *seq_mixed* starting with n_ops=%0d", n_ops), UVM_MEDIUM)
    repeat (n_ops) begin
      transaction it = transaction::type_id::create("it");
      assert(it.randomize());

      // Intentionally inject RAW hazard some percentage of the time
      if ($urandom_range(0,99) < hazard_pct) begin
        it.wr_en   = 1;
        it.rd_en   = 1;
        it.rd_addr = it.wr_addr;
      end

      start_item(it); 
      finish_item(it);
    end
  endtask
endclass
