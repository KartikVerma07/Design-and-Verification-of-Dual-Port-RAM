typedef virtual intf.DRV dp_vif_drv_t;

class driver extends uvm_driver#(transaction);
  `uvm_component_utils(driver)

  dp_vif_drv_t vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Get the virtual interface from config_db
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(dp_vif_drv_t)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "No virtual interface set for driver (key='vif').")
  endfunction

  // Drive all lines to idle for one cycle
  task reset_lines();
    vif.drv_cb.wr_en   <= 1'b0;
    vif.drv_cb.rd_en   <= 1'b0;
    vif.drv_cb.wr_addr <= '0;
    vif.drv_cb.rd_addr <= '0;
    vif.drv_cb.w_data  <= '0;
    @(posedge vif.clk);
  endtask

  // Main driving loop: 1 item = 1 active cycle (then deassert)
  task run_phase(uvm_phase phase);
    transaction req;

    // Wait for reset deassertion
    while (vif.rst) @(posedge vif.clk);
    reset_lines();

    forever begin
      // Block until a sequence provides the next item
      seq_item_port.get_next_item(req);

      // Active cycle: drive enables/addr/data
      @(vif.drv_cb);
      vif.drv_cb.wr_en   <= req.wr_en;
      vif.drv_cb.rd_en   <= req.rd_en;
      vif.drv_cb.wr_addr <= req.wr_addr;
      vif.drv_cb.rd_addr <= req.rd_addr;
      vif.drv_cb.w_data  <= req.w_data;

      // Deassert in the following cycle (one-shot operation)
      @(vif.drv_cb);
      vif.drv_cb.wr_en   <= 1'b0;
      vif.drv_cb.rd_en   <= 1'b0;

      // Complete the handshake back to the sequence
      seq_item_port.item_done();
    end
  endtask

endclass