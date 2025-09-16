class seq_base extends uvm_sequence#(transaction);
  `uvm_object_utils(seq_base)

  sequencer pseq;

  function new(string name="seq_base"); 
    super.new(name); 
  endfunction

  virtual task pre_start();
    super.pre_start();
    if (!$cast(pseq, m_sequencer))
      `uvm_warning(get_type_name(),
        "Could not cast m_sequencer to sequencer; using local defaults")
  endtask
endclass
