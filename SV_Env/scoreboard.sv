class scoreboard;
  mailbox #(transaction) mon2scb;

  typedef logic [4:0] addr_t;
  typedef logic [7:0] data_t;
  data_t model_mem [addr_t];   // reference model
  data_t init_value = '0;      // expected value for unwritten addresses

  function new(mailbox #(transaction) mon2scb);
    this.mon2scb = mon2scb;
  endfunction

  task run();
    model_mem.delete();

    forever begin
      transaction tr;
      mon2scb.get(tr);

      // Compute expected read value (OLD-data policy) BEFORE applying write
      if (tr.rd_en && !$isunknown(tr.rd_addr)) begin
        data_t expected = model_mem.exists(tr.rd_addr) ? model_mem[tr.rd_addr] : init_value;

        if (tr.r_data === expected)
          $display("[%0t] SCB READ_OK  : addr=%0h data=0x%02h",
                    $time, tr.rd_addr, tr.r_data);
        else
          $display("[%0t] SCB READ_MIS : addr=%0h exp=0x%02h got=0x%02h",
                    $time, tr.rd_addr, expected, tr.r_data);

        if (!model_mem.exists(tr.rd_addr))
          $display("[%0t] SCB NOTE     : read from UNWRITTEN addr=%0d",
                    $time, tr.rd_addr, init_value);
      end

      // Apply write AFTER read compare → write visible from next cycle
      if (tr.wr_en && !$isunknown(tr.wr_addr)) begin
        model_mem[tr.wr_addr] = tr.w_data;
        $display("[%0t] SCB WRITE    : mem[0x%02h] <= 0x%02h",
                  $time, tr.wr_addr, tr.w_data);
      end
    end
  endtask
endclass
