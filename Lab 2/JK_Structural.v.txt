`timescale 1ns / 1ps

module JK ( out,j,k,clk,reset); //Module initialization 
output out; //Defining outputs
input j, k, clk, reset ; // Defining inputs
wire a,b,q1,q2;
wire Qbar; // Defining internal connections
//gate level modelling

nand #2 N1 (a, clk, j, q2); //providing delay of 2ns for nand gate output
nand #2 N2 (b, clk, k, q1);
nand #2 N3 (q1, a, q2);
nand #2 N4 (q2, b, q1, ~reset); //
assign out=q1; // connecting internal connections to output
assign Qbar=q2;
assign out=~Qbar; 				// Qbar is complement of Q 
endmodule 		// end of module definition