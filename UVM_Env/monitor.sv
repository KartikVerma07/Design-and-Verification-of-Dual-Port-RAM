// Virtual interface comes from intf.sv
typedef virtual intf.MON dp_vif_mon_t;

class monitor extends uvm_component;
  `uvm_component_utils(monitor)

  dp_vif_mon_t vif;
  uvm_analysis_port#(transaction) ap;

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(dp_vif_mon_t)::get(this,"","vif",vif))
      `uvm_fatal(get_type_name(),"No vif set for monitor");
    ap = new("ap", this);
  endfunction

  task run_phase(uvm_phase phase);
    transaction it;
    // Wait for reset deassertion
    while (vif.rst) @(posedge vif.clk);

    forever begin
      @(vif.mon_cb);
      it = transaction::type_id::create("it", , get_full_name());
      it.wr_en   = vif.mon_cb.wr_en;
      it.rd_en   = vif.mon_cb.rd_en;
      it.wr_addr = vif.mon_cb.wr_addr;
      it.rd_addr = vif.mon_cb.rd_addr;
      it.w_data  = vif.mon_cb.w_data;
      it.r_data  = vif.mon_cb.r_data;
      ap.write(it);
    end
  endtask
endclass
