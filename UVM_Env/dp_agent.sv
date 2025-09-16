class dp_agent extends uvm_component;
  `uvm_component_utils(dp_agent)

  sequencer  seqr;
  driver     drv;      // keep your existing driver class name
  monitor    mon;      // you renamed monitor class to 'monitor'
  uvm_analysis_port#(transaction) ap;

  function new(string name, uvm_component parent); 
    super.new(name,parent); 
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seqr = sequencer::type_id::create("seqr", this);
    drv  = driver   ::type_id::create("drv" , this);
    mon  = monitor  ::type_id::create("mon" , this);
    ap   = new("ap", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
    mon.ap.connect(ap);
  endfunction
endclass