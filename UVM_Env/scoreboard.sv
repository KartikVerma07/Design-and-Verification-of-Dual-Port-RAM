class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  // TLM sink (monitor → agent → scb)
  uvm_tlm_analysis_fifo#(transaction) fifo;

  // Tiny reference model (OLD-data policy)
  typedef logic [4:0] addr_t;
  typedef logic [7:0] data_t;
  data_t model_mem [addr_t];
  data_t init_value = '0;

  // Queues holding the *expected* value and its address, in order
  data_t exp_q[$];
  addr_t addr_q[$];

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    fifo = new("fifo", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    transaction tr;
    model_mem.delete();
    exp_q.delete(); addr_q.delete();

    forever begin
      // One sample per clock from the monitor (use mon_cb input #1step)
      fifo.get(tr);

      // (A) Compare result for the OLDEST pending read (from last cycle)
      if (exp_q.size() > 0) begin
        data_t exp = exp_q.pop_front();
        addr_t a   = addr_q.pop_front();
        if (!$isunknown(tr.r_data)) begin
          if (tr.r_data !== exp)
            `uvm_error("SCB_READ", $sformatf("rd_addr=0x%0h exp=0x%02h got=0x%02h", a, exp, tr.r_data))
          else
            `uvm_info("SCB_READ", $sformatf("rd_addr=0x%0h data=0x%02h OK", a, tr.r_data), UVM_LOW)
        end
        // if r_data is X/Z this cycle, skip to avoid noise
      end

      // (B) THIS cycle’s read request → compute OLD data & enqueue
      if (tr.rd_en && !$isunknown(tr.rd_addr)) begin
        data_t exp = model_mem.exists(tr.rd_addr) ? model_mem[tr.rd_addr] : init_value;
        exp_q .push_back(exp);         // will be checked NEXT cycle
        addr_q.push_back(tr.rd_addr);  // keep the address only for messages
      end

      // (C) Apply write AFTER (B): enforces OLD-data semantics
      if (tr.wr_en && !$isunknown(tr.wr_addr)) begin
        model_mem[tr.wr_addr] = tr.w_data;
        `uvm_info("SCB_WRITE",
                  $sformatf("dp_mem[%0h] <= 0x%02h", tr.wr_addr, tr.w_data), UVM_LOW)
      end
    end
  endtask
endclass

