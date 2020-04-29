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
`define JALOPCODE     6'b000011
`define ORIOPCODE       6'b001101
`define ADDIOPCODE  6'b001000
`define ADDIUOPCODE 6'b001001
`define ANDIOPCODE  6'b001100
`define LUIOPCODE       6'b001111
`define SLTIOPCODE  6'b001010
`define SLTIUOPCODE 6'b001011
`define XORIOPCODE  6'b001110

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


module PipelinedControl(UseShamt,RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, Jump,jr,jal, SignExtend, ALUOp, Opcode, funct, bubble);
   input [5:0] Opcode;
   input bubble;
   input [5:0] funct;//new
   output RegDst;
   output ALUSrc;
   output MemToReg;
   output RegWrite;
   output MemRead;
   output MemWrite;
   output Branch;
   output Jump;
   output jr;
   output jal;
    output SignExtend;
   output [3:0] ALUOp;
    output UseShamt; //new
     //Useshamt to be included here  and FUNC   -    remove from ALU control
    reg  ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, Jump, jr,jal,SignExtend;
    reg [1:0] RegDst;
    reg  [3:0] ALUOp;
    reg UseShamt;//new
    always @ (Opcode or funct or bubble) begin
    
    if(bubble) begin
        RegDst<=0;
        ALUSrc<=0;
        MemToReg<=0;
        RegWrite<=0;
        MemRead<=0;
       MemWrite<=0;
       Branch<=0;
       Jump<=0;
       SignExtend<=0;
       ALUOp<=0;
       UseShamt<=0;
       jal <= 1'b1;
       jr<=1'b0;
    end
    
    else begin
    
        case(Opcode)
            `RTYPEOPCODE: begin
                //INCLUDE JR IN HAZARD UNIT --> done 
                RegDst <= 1'b1;
                ALUSrc <=  1'b0;
                MemToReg <= 1'b0;
                RegWrite <=  (funct==6'b001000) ? 1'b0 : 1'b1;
                MemRead <=  1'b0;
                MemWrite <=  1'b0;
                Branch <=  1'b0;
                jr <= (funct==6'b001000) ? 1'b1 : 1'b0; //check this module for jr additinos
                Jump <=  1'b0;
                jal <= 1'b0;
                SignExtend <=  1'b0;
                ALUOp <=  `FUNC;
                UseShamt =((funct == 6'b000000) || (funct == 6'b000010) || (funct == 6'b000011)) ? 1'b1 : 1'b0;
            end
            
            `LWOPCODE: begin
                            RegDst <= 1'b0;
                            ALUSrc <= 1'b1;
                            MemToReg <=  1'b1;
                            RegWrite <= 1'b1;
                            MemRead <=  1'b1;
                            MemWrite <=  1'b0;
                            Branch <=  1'b0;
                            Jump <= 1'b0;
                            jal <= 1'b0;
                            jr <= 1'b0;
                            ALUOp <= `ADD;
                            UseShamt <= 0;
                            SignExtend <= 1'b1;
                            
             end
             
             `SWOPCODE: begin
                             RegDst <= 1'b0;
                             ALUSrc <= 1'b1;
                             MemToReg <= 1'b1;
                             RegWrite <= 1'b0;
                             MemRead <= 1'b0;
                             MemWrite <= 1'b1;
                             Branch <= 1'b0; 
                             Jump <=  1'b0;
                             jal <= 1'b0;
                             jr <= 1'b0;
                             ALUOp <=  `ADD;
                             UseShamt <= 0;
                             SignExtend <=  1'b1;
                            
               end
            
             `BEQOPCODE: begin
                               RegDst <=  1'b0;
                               ALUSrc <=  1'b0;
                               MemToReg <=  1'b0;
                               RegWrite <=  1'b0;
                               MemRead <=  1'b0;
                               MemWrite <=  1'b0;
                               Branch <=  1'b1;  
                               Jump <=  1'b0;
                               jal <= 1'b0;
                               jr <= 1'b0;
                               ALUOp <=  `SUB;
                               UseShamt <= 0;
                               SignExtend <=  1'b1; //changed later
                               
                 end    
                        
             `JOPCODE: begin
                                   RegDst <=  1'b0;
                                   ALUSrc <=  1'b0;
                                   MemToReg <=  1'b0;
                                   RegWrite <=  1'b0;
                                   MemRead <=  1'b0;
                                   MemWrite <=  1'b0;
                                   Branch <=  1'b0;
                                   Jump <=  1'b1;
                                   jal <= 1'b0;
                                   jr <= 1'b0;
                                   SignExtend <=  1'b1;
                                   ALUOp <=  `AND;
                                   UseShamt <= 0;
                     end 
              `JALOPCODE: begin
                                    RegDst <=  2'b10; // make all regdst everywhere 2 bit
                                    ALUSrc <=  1'b0; // regdst = 2 means 31 value to be selected to be added in main flo 
                                    MemToReg <=  1'b0;
                                    RegWrite <=  1'b1;
                                    MemRead <=  1'b0;
                                    MemWrite <=  1'b0;
                                    Branch <=  1'b0;
                                    Jump <=  1'b1;
                                    jal <= 1'b1;//add in the ports list also update jump or jal for address calc
                                    jr <= 1'b0;
                                    SignExtend <=  1'b1;//add mux in main flow for alu ouput selection as PC + 4 in ex stage
                                    ALUOp <=  `AND;//forward PC + 4 to EX stae
                                    UseShamt <= 0;
                      end          
             `ORIOPCODE: begin
                                   RegDst <=  1'b0;
                                   ALUSrc <=  1'b1;
                                   MemToReg <=  1'b0;
                                   RegWrite <=  1'b1;
                                   MemRead <=  1'b0;
                                   MemWrite <=  1'b0;
                                   Branch <=  1'b0;
                                   Jump <=  1'b0;
                                   jal <= 1'b0;
                                   jr <= 1'b0;
                                   SignExtend <=  1'b0;
                                   ALUOp <= `OR;
                                   UseShamt <= 0;
                         end
                              
             `ADDIOPCODE: begin
                                   RegDst <=  1'b0;
                                   ALUSrc <=  1'b1;
                                   MemToReg <=  1'b0;
                                   RegWrite <=  1'b1;
                                   MemRead <=  1'b0;
                                   MemWrite <=  1'b0;
                                   Branch <=  1'b0;
                                   Jump <=  1'b0;
                                   jal <= 1'b0;
                                   jr <= 1'b0;
                                   SignExtend <=  1'b1;
                                   ALUOp <=  `ADD;
                                   UseShamt <= 0;
                         end             
                                     
             `ADDIUOPCODE: begin
                                   RegDst <=  1'b0;
                                   ALUSrc <=  1'b1;
                                   MemToReg <=  1'b0;
                                   RegWrite <=  1'b1;
                                   MemRead <=  1'b0;
                                   MemWrite <=  1'b0;
                                   Branch <=  1'b0;
                                   Jump <=  1'b0;
                                   jal <= 1'b0;
                                   jr <= 1'b0;
                                   SignExtend <=  1'b0; //this should be 1 because both are same operations
                                   ALUOp <= `ADDU;
                                   UseShamt <= 0;
                           end   
                           
             `ANDIOPCODE: begin
                                     RegDst <=  1'b0;
                                     ALUSrc <=  1'b1;
                                     MemToReg <=  1'b0;
                                     RegWrite <=  1'b1;
                                     MemRead <=  1'b0;
                                     MemWrite <=  1'b0;
                                     Branch <=  1'b0;
                                     Jump <=  1'b0;
                                     jal <= 1'b0;
                                     jr <= 1'b0;
                                     SignExtend <=  1'b0;
                                     ALUOp <=  `AND;
                                     UseShamt <= 0;
                             end  
                                         
             `LUIOPCODE: begin
                                   RegDst <=  1'b0;//changed
                                   ALUSrc <=  1'b1;
                                   MemToReg <=  1'b0;
                                   RegWrite <=  1'b1;
                                   MemRead <=  1'b0;
                                   MemWrite <=  1'b0;
                                   Branch <=  1'b0;
                                   Jump <=  1'b0;
                                   jal <= 1'b0;
                                   jr <= 1'b0;
                                   SignExtend <= 1'b0;//changed
                                   ALUOp <=  `LUI;
                                   UseShamt <= 0;
                           end  
                                                       
             `SLTIOPCODE: begin
                                 RegDst <=  1'b0;
                                 ALUSrc <=  1'b1;
                                 MemToReg <=  1'b0;
                                 RegWrite <=  1'b1;
                                 MemRead <=  1'b0;
                                 MemWrite <=  1'b0;
                                 Branch <=  1'b0;
                                 Jump <=  1'b0;
                                 jal <= 1'b0;
                                 jr <= 1'b0;
                                 SignExtend <= 1'b1;
                                 ALUOp <= `SLT;
                                 UseShamt <= 0;
                         end  
             `SLTIUOPCODE: begin
                                   RegDst <= 1'b0;
                                   ALUSrc <=  1'b1;
                                   MemToReg <=  1'b0;
                                   RegWrite <=  1'b1;
                                   MemRead <=  1'b0;
                                   MemWrite <=  1'b0;
                                   Branch <=  1'b0;
                                   Jump <=  1'b0;
                                   jal <= 1'b0;
                                   jr <= 1'b0;
                                   SignExtend <=  1'b1;
                                   ALUOp <=  `SLTU;
                                   UseShamt <= 0;
                           end

             `XORIOPCODE: begin
                                     RegDst <=  1'b0;
                                     ALUSrc <=  1'b1;
                                     MemToReg <=  1'b0;
                                     RegWrite <=  1'b1;
                                     MemRead <=  1'b0;
                                     MemWrite <=  1'b0;
                                     Branch <=  1'b0;
                                     Jump <=  1'b0;
                                     jr <= 1'b0;
                                     jal <= 1'b0;
                                     SignExtend <=  1'b0; //changed 
                                     ALUOp <= `XOR;
                                     UseShamt <= 0;
                             end                                                                                                                                                                                                                                                                                                                                                                                       
    

            default: begin
                RegDst <=  1'bx;
                ALUSrc <=  1'bx;
                MemToReg <=  1'bx;
                RegWrite <=  1'bx;
                MemRead <=  1'bx;
                MemWrite <=  1'bx;
                Branch <=  1'bx;
                Jump <=  1'bx;
                jal <= 1'bx;
                jr <= 1'bx;
                SignExtend <= 1'bx;
                ALUOp <=  4'bxxxx;
                UseShamt <= 1'bx;
                
            end
        endcase
      end
    end
endmodule