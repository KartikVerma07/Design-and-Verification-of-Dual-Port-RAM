// design.sv — Dual-Port (1R/1W) RAM, 1 MB, 8-bit data, 20-bit address
// Policy: read-during-write to the same address returns OLD data on r_data.

module dp_ram_design (
    input               clk,
    input               rst,       // active-high, synchronous
    input  		 bit    wr_en,
    input  		 bit    rd_en,
  	//input  logic [19:0] wr_addr,   // 2^20 locations = 1 MB (byte addressed)
  	input  logic [4:0] wr_addr,
  	//input  logic [19:0] rd_addr,
    input  logic [4:0] rd_addr,
    input  logic  [7:0] w_data,
    output reg  [7:0] r_data
);

    // Parameters kept in case you want to generalize later
    localparam int ADDR_W = 5;
    localparam int DATA_W = 8;
    localparam int DEPTH  = 1 << ADDR_W;
  	bit same_addr;

    // Storage: 1 MB x 8-bit (byte-addressable)
  	reg [DATA_W-1:0] mem [DEPTH-1:0];
  
    // Sequential behavior
    always_ff @(posedge clk) begin
        if (rst) begin
            r_data <= '0;
        end else begin
          same_addr = (wr_en && rd_en && (wr_addr == rd_addr));
            // 1) Read path — captures current contents (OLD data)
          if (rd_en) begin
            $display("%s", "========================================");
                // Show the value that will be captured on r_data this edge (OLD content)
            $display("[%0t] READ  req  : rd_addr=0x%02h r_data(old/prev)=0x%02h%s",
                     $time, rd_addr, mem[rd_addr], same_addr ? $sformatf("  (SAW same-addr: read-before-write)") : ".");
            
            	r_data <= mem[rd_addr];
            
            	// After all NBAs, show the value that r_data settled to this edge
                $strobe("[%0t] READ  post : r_data=0x%02h  (from rd_addr=0x%02h).", $time, r_data, rd_addr);

          end
            // 2) Write path — update becomes visible next cycle
          if (wr_en) begin
                // Show what we’re about to write and, if RAW same-addr, what OLD was
            $display("[%0t] WRITE req  : wr_addr=0x%02h w_data=0x%02h%s",
                     $time, wr_addr, w_data, same_addr ? $sformatf("  (SAW same-addr: READ saw OLD=0x%02h)", mem[wr_addr]): ".");
            
            	mem[wr_addr] <= w_data;
            
            	// After all NBAs, show the memory location updated
            	$strobe("[%0t] WRITE post : mem[0x%02h]=0x%02h.", $time, wr_addr, mem[wr_addr]);
            	if(!rd_en) $strobe("%s", "========================================");
          end
        end
    end
endmodule