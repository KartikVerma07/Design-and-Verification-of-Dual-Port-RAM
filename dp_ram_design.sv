// Code your design here
// design.sv — Dual-Port (1R/1W) RAM, 1 MB, 8-bit data, 20-bit address
// Policy: read-during-write to the same address returns OLD data on r_data.

module dp_ram (
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

    // Storage: 1 MB x 8-bit (byte-addressable)
  	reg [DATA_W-1:0] mem [DEPTH-1:0];
  
    // Sequential behavior
    always_ff @(posedge clk) begin
        if (rst) begin
            r_data <= '0;
        end else begin
            // 1) Read path — captures current contents (OLD data)
          if (rd_en) begin
                r_data <= mem[rd_addr];
                $display("~present~ mem[rd_addr]: %h",mem[rd_addr]);
                $display("~next~ r_data: %h",r_data);
          end
            // 2) Write path — update becomes visible next cycle
          if (wr_en) begin
                mem[wr_addr] <= w_data;
                $display("~present~ w_data: %h",w_data);
                $display("~next~ mem[wr_addr]: %h",mem[wr_addr]);
          end
          $display("---------------------------------------------");
        end
    end

    // --------------- Optional safety assertions (simulation only) ---------------
`ifdef SIM_ASSERTS
    // Address range checks (fire if X/Z or out of range)
    assert property (@(posedge clk) disable iff (rst)
        !$isunknown(wr_addr) && !$isunknown(rd_addr))
        else $error("dp_ram_1mb: X/Z on address");

    // Data known on write
    assert property (@(posedge clk) disable iff (rst)
        !wr_en or !$isunknown(w_data))
        else $error("dp_ram_1mb: X/Z on w_data when wr_en=1");
`endif

endmodule