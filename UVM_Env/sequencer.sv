class sequencer extends uvm_sequencer#(transaction);
  `uvm_component_utils(sequencer)

  // (Optional) knobs for sequences to read via p_sequencer
  int unsigned default_n_ops = 256;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
endclass

