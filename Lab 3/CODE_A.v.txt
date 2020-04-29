// Code your design here
`timescale 1ns / 1ps
//initializing module for Register File
module RegisterFile(BusA, BusB, BusW, RA, RB, RW, RegWr, Clk);
  // declaring inputs and outputs
  output [31:0] BusA, BusB;  //BusA, BusB are read buses and hence declared as outputs.//They carry data from the register and displays the value.
  input [31:0] BusW;		 // BusW will write the data into the register location specified by RW and hence considered as inputs.
  input [4:0] RA, RB;
  input [4:0] RW;
  //reg [4:0] RW;	// RA,RB and RW stores address 
  input RegWr;				//enable command for writing in register.
  input Clk;				//clock

  reg [31:0] registers [31:0]; //32 registers each capable of storing 32 bits
/*
initial begin
registers[0]=0;     //R0 is declared as zero register
end
*/
assign  BusA = (RA==0) ? 32'd0:registers[RA];
assign  BusB = (RB==0) ? 32'd0:registers[RB];

  always @ (posedge Clk) //module is triggered at negative edge
  begin

    if(RegWr) //condition for writing: only when RegWr is high.
    begin
      if (RW != 5'd0)	//assigning R0 equals zero
        registers[RW] =  BusW; // writing the data into memory.
  end
  end
endmodule