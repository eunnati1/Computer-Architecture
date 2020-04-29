`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:23:34 03/10/2009 
// Design Name: 
// Module Name:    SingleCycleControl 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`define RTYPEOPCODE 6'b000000
`define LWOPCODE        6'b100011
`define SWOPCODE        6'b101011
`define BEQOPCODE       6'b000100
`define JOPCODE     6'b000010
`define ORIOPCODE       6'b001101
`define ADDIOPCODE  6'b001000
`define ADDIUOPCODE 6'b001001
`define ANDIOPCODE  6'b001100
`define LUIOPCODE       6'b001111
`define SLTIOPCODE  6'b001010
`define SLTIUOPCODE 6'b001011
`define XORIOPCODE  6'b001110
`define SLLFunc 6'b000000
`define SRLFunc 6'b000010
`define SRAFunc 6'b000011

`define AND     4'b0000
`define OR      4'b0001
`define ADD     4'b0010
`define SLL     4'b0011
`define SRL     4'b0100
`define SUB     4'b0110
`define SLT     4'b0111
`define ADDU    4'b1000
`define SUBU    4'b1001
`define XOR     4'b1010
`define SLTU    4'b1011
`define NOR     4'b1100
`define SRA     4'b1101
`define LUI     4'b1110
`define FUNC    4'b1111

module PipeLineCycleControl(

output reg RegDst,
output reg ALUSrc1, //if 0 means source is register file, else shamt functionality to be used. 
output reg ALUSrc2, //if 0 means take from register file, else use the immedieate value 
output reg MemToReg, //to select data memory output or alu output 
output reg RegWrite,// to write data or to not write data in register file 
output reg MemRead, // to read from data memory 
output reg MemWrite,// to write in to the data memory 
output reg Branch,// indicates a branch is to be taken or not 
output reg  Jump,//indicates a jump to be taken or not. 
output reg SignExtend, //whether to extend the sign or not 
output reg [3:0] ALUOp,//input to the alu controller 
input wire [5:0] Opcode,//input opcode from instruction 
input wire [5:0] Func);//input functional bits from instruction. 
   
    always @ (Opcode or Func) begin
        case(Opcode)
            `RTYPEOPCODE: begin
					if ((Func == `SLLFunc)| (Func == `SRLFunc)| (Func == `SRAFunc))begin 
					RegDst <= 1;
					ALUSrc1 <= 1;//in case of any SRL , SRA or SLL use source 1 as shamt and not register. 
					ALUSrc2 <= 0;
					MemToReg <= 0;//rest all the functionalities remain same as the R type of prev lab
					RegWrite <= 1;
					MemRead <= 0;
					MemWrite <= 0;
					Branch <= 0;
					Jump <= 0;
					SignExtend <= 1'b0;
					ALUOp <= `FUNC;
					end 
					else begin 
					RegDst <= 1;
					ALUSrc1 <= 0;
					ALUSrc2 <= 0;
					MemToReg <= 0;
					RegWrite <= 1;
					MemRead <= 0;
					MemWrite <= 0;
					Branch <= 0;
					Jump <= 0;
					SignExtend <= 1'b0;
					ALUOp <= `FUNC;
					end 
            end
            
            `LWOPCODE: begin
                            RegDst <= 1'b0;
                            ALUSrc1 <= 1'b0;
							ALUSrc2 <= 1'b1;// in this case we need to use the immedieate address.
                            MemToReg <=  1'b1;
                            RegWrite <= 1'b1;
                            MemRead <=  1'b1;
                            MemWrite <=  1'b0;
                            Branch <=  1'b0;
                            Jump <= 1'b0;
                            ALUOp <= `ADD;
                            
                            SignExtend <= 1'b1;
                            
             end
             
             `SWOPCODE: begin
                             RegDst <= 1'b0;
							 ALUSrc1 <= 1'b0; //we do not need to shift src1
                             ALUSrc2 <= 1'b1;//however source b should be a immedieate value 
                             MemToReg <= 1'b1;
                             RegWrite <= 1'b0;
                             MemRead <= 1'b0;
                             MemWrite <= 1'b1;
                             Branch <= 1'b0; 
                             Jump <=  1'b0;
                             ALUOp <=  `ADD;
                             
                             SignExtend <=  1'b1;
                            
               end
            
             `BEQOPCODE: begin
                               RegDst <=  1'b0;
                               ALUSrc1 <=  1'b0;// in branch we do not need shamt 
							   ALUSrc2 <=  1'b0;// also the comparision between two registers are specified in register files.
                               MemToReg <=  1'b0;
                               RegWrite <=  1'b0;
                               MemRead <=  1'b0;
                               MemWrite <=  1'b0;
                               Branch <=  1'b1;  
                               Jump <=  1'b0;
                               ALUOp <=  `SUB;
                               
                               SignExtend <=  1'b1; //changed later
                               
                 end    
                        
             `JOPCODE: begin
                                   RegDst <=  1'b0;
                                   ALUSrc1 <=  1'b0;
								   ALUSrc2 <=  1'b0;
                                   MemToReg <=  1'b0;
                                   RegWrite <=  1'b0;
                                   MemRead <=  1'b0;
                                   MemWrite <=  1'b0;
                                   Branch <=  1'b0;
                                   Jump <=  1'b1;
                                   SignExtend <=  1'b1;
                                   ALUOp <=  `AND;
                     end 
                        
             `ORIOPCODE: begin
                                   RegDst <=  1'b0;
                                   ALUSrc1 <=  1'b0;//shamt =no
								   ALUSrc2 <=  1'b1; //immedieate =yes
                                   MemToReg <=  1'b0;
                                   RegWrite <=  1'b1;
                                   MemRead <=  1'b0;
                                   MemWrite <=  1'b0;
                                   Branch <=  1'b0;
                                   Jump <=  1'b0;
                                   SignExtend <=  1'b0;
                                   ALUOp <= `OR;
                         end
                              
             `ADDIOPCODE: begin
                                   RegDst <=  1'b0;
                                   ALUSrc1 <=  1'b0;// shamt = no 
								   ALUSrc2 <=  1'b1;//imm = yes 
                                   MemToReg <=  1'b0;
                                   RegWrite <=  1'b1;
                                   MemRead <=  1'b0;
                                   MemWrite <=  1'b0;
                                   Branch <=  1'b0;
                                   Jump <=  1'b0;
                                   SignExtend <=  1'b1;
                                   ALUOp <=  `ADD;
                         end             
                                     
             `ADDIUOPCODE: begin
                                   RegDst <=  1'b0;
                                   ALUSrc1 <=  1'b0;
								   ALUSrc2 <=  1'b1;
                                   MemToReg <=  1'b0;
                                   RegWrite <=  1'b1;
                                   MemRead <=  1'b0;
                                   MemWrite <=  1'b0;
                                   Branch <=  1'b0;
                                   Jump <=  1'b0;
                                   SignExtend <=  1'b0; //changed later
                                   ALUOp <= `ADDU;
                           end   
                           
             `ANDIOPCODE: begin
                                     RegDst <=  1'b0;
                                     ALUSrc1 <=  1'b0; //shamt no
									 ALUSrc2 <=  1'b1; //imm yes 
                                     MemToReg <=  1'b0;
                                     RegWrite <=  1'b1;
                                     MemRead <=  1'b0;
                                     MemWrite <=  1'b0;
                                     Branch <=  1'b0;
                                     Jump <=  1'b0;
                                     SignExtend <=  1'b0;
                                     ALUOp <=  `AND;
                             end  
                                         
             `LUIOPCODE: begin
                                   RegDst <=  1'b0;
                                   ALUSrc1 <=  1'b0;// shamt no 
								   ALUSrc2 <=  1'b1; //imme yes 
                                   MemToReg <=  1'b0;
                                   RegWrite <=  1'b1;
                                   MemRead <=  1'b0;
                                   MemWrite <=  1'b0;
                                   Branch <=  1'b0;
                                   Jump <=  1'b0;
                                   SignExtend <= 1'b0;//changed
                                   ALUOp <=  `LUI;
                           end  
                                                       
             `SLTIOPCODE: begin
                                 RegDst <=  1'b0;
                                 ALUSrc1 <=  1'b0; //shamt no  
								 ALUSrc2 <=  1'b1; //imm yes 
                                 MemToReg <=  1'b0;
                                 RegWrite <=  1'b1;
                                 MemRead <=  1'b0;
                                 MemWrite <=  1'b0;
                                 Branch <=  1'b0;
                                 Jump <=  1'b0;
                                 SignExtend <= 1'b1;
                                 ALUOp <= `SLT;
                         end  
             `SLTIUOPCODE: begin
                                   RegDst <= 1'b0;
                                   ALUSrc1 <=  1'b0; //shamt no 
								   ALUSrc2 <=  1'b1;// imm yes 
                                   MemToReg <=  1'b0;
                                   RegWrite <=  1'b1;
                                   MemRead <=  1'b0;
                                   MemWrite <=  1'b0;
                                   Branch <=  1'b0;
                                   Jump <=  1'b0;
                                   SignExtend <=  1'b1;
                                   ALUOp <=  `SLTU;
                           end

             `XORIOPCODE: begin
                                     RegDst <=  1'b0;
                                     ALUSrc1 <=  1'b0; //shamt no 
									 ALUSrc2 <=  1'b1; // imm yes 
                                     MemToReg <=  1'b0;
                                     RegWrite <=  1'b1;
                                     MemRead <=  1'b0;
                                     MemWrite <=  1'b0;
                                     Branch <=  1'b0;
                                     Jump <=  1'b0;
                                     SignExtend <=  1'b0; //changed 
                                     ALUOp <= `XOR;
                             end                                                                                                                                                                                                                                                                                                                                                                                       
    

            default: begin
                RegDst <=  1'bx;
                ALUSrc1 <=  1'bx;
                ALUSrc2 <=  1'bx;
                MemToReg <=  1'bx;
                RegWrite <=  1'bx;
                MemRead <=  1'bx;
                MemWrite <=  1'bx;
                Branch <=  1'bx;
                Jump <=  1'bx;
                SignExtend <= 1'bx;
                ALUOp <=  4'bxxxx;
            end
        endcase
    end
endmodule