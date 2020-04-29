timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/04/2019 08:48:03 AM
// Design Name: 
// Module Name: D Flipflop
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


module D_FF(q,d,clk,reset);
    output q;
    input d, clk, reset;
    reg q;
    // lots of construction here....
    always @(posedge reset or negedge clk)
    if (reset)
    q = 1'b0;
    else
    q=d;
endmodule