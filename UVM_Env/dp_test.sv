class dp_test extends uvm_test;
  `uvm_component_utils(dp_test)
  dp_env 		   env;
  seq_write			 w;
  seq_read           r;
  seq_raw_next_cycle n;
  seq_mixed          m;
  
  function new(string name, uvm_component parent); 
    super.new(name,parent); 
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = dp_env::type_id::create("env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    w = seq_write         ::type_id::create("w");
    r = seq_read          ::type_id::create("r");
    n = seq_raw_next_cycle::type_id::create("n");
    m = seq_mixed         ::type_id::create("m");

    w.start(env.agt.seqr);
    r.start(env.agt.seqr);
    n.start(env.agt.seqr);
    m.start(env.agt.seqr);

    #(20);
    phase.drop_objection(this);
  endtask
endclass