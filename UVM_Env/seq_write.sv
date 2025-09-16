class seq_write extends seq_base;
  `uvm_object_utils(seq_write)

  rand int unsigned n_ops = 32;

  function new(string name="seq_write"); 
    super.new(name); 
  endfunction

  task body();
    if (pseq != null && n_ops == 0) n_ops = pseq.default_n_ops;
    //`uvm_info("SEQ_START", $sformatf("Sequence *seq_write* starting with n_ops=%0d", n_ops), UVM_MEDIUM)
    repeat (n_ops) begin
      transaction it = transaction::type_id::create("it");
      assert(it.randomize() with { wr_en==1; rd_en==0; });
      start_item(it);  // Handshake with sequencer: "I'm ready to send"
      finish_item(it); // Finalize & send item to driver
    end
  endtask
endclass