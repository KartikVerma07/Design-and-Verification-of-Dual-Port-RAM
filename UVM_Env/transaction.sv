class transaction extends uvm_sequence_item;;
  
  rand bit         wr_en, rd_en;
  rand logic [4:0] wr_addr, rd_addr;
  rand logic [7:0] w_data;
       logic [7:0] r_data;

  constraint c_addr_range {
    wr_addr inside {[5'h00:5'h1F]};
    rd_addr inside {[5'h00:5'h1F]};
  }

  `uvm_object_utils_begin(transaction)
    `uvm_field_int(wr_en,   UVM_ALL_ON)
    `uvm_field_int(rd_en,   UVM_ALL_ON)
    `uvm_field_int(wr_addr, UVM_ALL_ON)
    `uvm_field_int(rd_addr, UVM_ALL_ON)
    `uvm_field_int(w_data,  UVM_ALL_ON)
    `uvm_field_int(r_data,  UVM_NOPRINT)
  `uvm_object_utils_end

  function new(string name="transaction"); 
    super.new(name); 
  endfunction
  
  endclass