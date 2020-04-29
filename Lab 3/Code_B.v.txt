`timescale 1ns / 1ps

module data_memory (
input [31:0] addr,          // Memory Address
input [31:0] write_data,    // Memory Address Contents
input  memwrite, memread,
input clk,                  // All synchronous elements, including memories, should have a clock signal
output reg [31:0] read_data      // Output of Memory Address Contents
);

reg [7:0] MEMO[128:0];  // 63 registers of 32 bit each
/*
integer i;
//storing dummy vakues in data memory
initial begin
  read_data <= 0;
  for (i = 0; i < 256; i = i + 1) begin
    MEMO[i] = i;
  end
end
*/
// Data is written into the memory during negative edge
always @(negedge clk) begin
  if (memwrite == 1'b1) begin //when write signal is 1 and read signal is 0
   //MEMO[addr] = write_data;
   {MEMO[addr],MEMO[addr+1],MEMO[addr+2],MEMO[addr+3]}=write_data;//changed
   // read_data <=MEMO[addr-4];
    
  end
  end
  //data is read from the memory during the positive edge
  always @(posedge clk) begin
  if (memread == 1'b1) begin //when read signal is 1 and write signal is 0
   // read_data <= MEMO[addr];
  read_data[31:0]={MEMO[addr],MEMO[addr+1],MEMO[addr+2],MEMO[addr+3]};
  end
end

endmodule