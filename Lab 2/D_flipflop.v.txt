`timescale 1ns/ 1ps

module d_flip_flop ( out,d ,clk ,reset );

output out ;
reg out ;

input d ;
wire d ;
input clk ;
wire clk ;
input reset ;
wire reset ;

always @ (posedge (clk)) begin
 if (reset)
  out <= 0;
 else
  out <= d ;
end

endmodule