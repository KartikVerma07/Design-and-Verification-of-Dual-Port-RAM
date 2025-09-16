class dp_env extends uvm_env;
  `uvm_component_utils(dp_env)

  dp_agent          agt;
  scoreboard        scb;
  dp_cov_subscriber cov;

  function new(string name, uvm_component parent); 
    super.new(name,parent); 
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = dp_agent   ::type_id::create("agt", this);
    scb = scoreboard ::type_id::create("scb", this);
    cov = dp_cov_subscriber ::type_id::create("cov", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    // Producer (agent AP) → Scoreboard FIFO's analysis_export 
    agt.ap.connect(scb.fifo.analysis_export);

    // Producer → Coverage subscriber (keeps the same)
    agt.ap.connect(cov.analysis_export);
  endfunction
endclass