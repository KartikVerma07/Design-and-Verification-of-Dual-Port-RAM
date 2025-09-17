class transaction;
  
  //rand logic [19:0]wr_addr;
  randc logic [4:0]wr_addr;
  rand logic [7:0] w_data;
  	   //logic [19:0]rd_addr;
  rand logic [4:0]rd_addr;
  	   logic [7:0] r_data;
  rand       bit   wr_en;
  rand       bit   rd_en;
  
  constraint addr_limit {wr_addr <= 5'h1f;
                         rd_addr <= 5'h1f;}

  function void display(string name="");
  $display("---- %s ---- @ %0t", name, $time);
    $display("wr_en=%0b rd_en=%0b | wr_addr=0x%02h rd_addr=0x%02h  | w_data=0x%02h r_data=0x%02h", wr_en, rd_en, wr_addr, rd_addr, w_data, r_data);
  endfunction
 
endclass