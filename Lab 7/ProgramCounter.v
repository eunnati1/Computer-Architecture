`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2019 06:38:53 PM
// Design Name: 
// Module Name: PC
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PC( 
 PC_write,
 clk,
 reset,
 last_address,
 startPC ,
 address );
   input PC_write; 
   input clk,reset;
   input [31:0] last_address;
   input [31:0] startPC;
   output reg [31:0]address;
   
   always @(negedge clk or negedge reset)begin
           
           if (~reset) begin // because it low enable signal
           address[31:0] <= startPC;
           end
           else if(PC_write)   begin
           address[31:0] <= last_address;
           end
        end
endmodule