interface intf(input logic clk, rst);
  
  //logic [19:0]wr_addr;
  //logic [19:0]rd_addr;
  logic [4:0]wr_addr;
  logic [4:0]rd_addr;
  logic [7:0] w_data;
  logic [7:0] r_data;
  	 bit	  wr_en;
  	 bit	  rd_en;
  
endinterface