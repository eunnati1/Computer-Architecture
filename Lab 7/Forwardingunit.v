`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2019 06:16:53 PM
// Design Name: 
// Module Name: ForwardingUnit
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


module ForwardingUnit ( UseShamt , UseImmed , ID_Rs , ID_Rt , EX_Rw , MEM_Rw,
EX_RegWrite , MEM_RegWrite , AluOpCtrlA , AluOpCtrlB , DataMemForwardCtrl_EX ,
DataMemForwardCtrl_MEM );
//defining inputs
input UseShamt , UseImmed ;
input [ 4 : 0 ] ID_Rs , ID_Rt , EX_Rw , MEM_Rw;
input EX_RegWrite, MEM_RegWrite;
//ID_Rs & ID_Rt are the [25:21] and [20:16] of the instruction line.
// stage 3 logic -->   EX_Rw <= RegDst ? rd : rt  -- this is the execute stage i.e ID/EX pipeline register value
// stage 4 logic -->   MEM_Rw <= EX_Rw;
//EX_RegWrite ?
//MEM_RegWrite ?
//defining outputs
//check destination register from execute and memory stage and compare it with rs and  rt registers from id stage , if the 
//register address matches with any one of these then forwarding accordingly
output reg [ 1 : 0 ] AluOpCtrlA , AluOpCtrlB ;
output reg DataMemForwardCtrl_EX , DataMemForwardCtrl_MEM ;
//UseImmed & MEM_RegWrite & EX_RegWrite for ALUopCtrlB
//UseShamt & MEM_RegWrite & EX_RegWrite for ALUOpCtrlA
//wire [3:0] test ;
//assign test =(UseShamt<<3) + (UseImmed<<2) + (MEM_RegWrite<<1) + (EX_RegWrite);
//main module starts
//--------------combinational logic only------------------
always @ (ID_Rs or ID_Rt or EX_Rw or MEM_Rw or EX_RegWrite or MEM_RegWrite or UseShamt or UseImmed)begin
//CASE OF USESHAMT AND USEIMMED
   if (UseShamt) begin
                  
                    AluOpCtrlA = 0;
                    //AluOpCtr
                  
   end     
   else if( EX_RegWrite == 1 & EX_Rw!=0 & (ID_Rs==EX_Rw)) begin
                    
                        AluOpCtrlA =2;
                    
                   
   end
                  
   else if(MEM_RegWrite==1 & MEM_Rw!=0 & ID_Rs==MEM_Rw) begin
                    
                       AluOpCtrlA =1;
                  
                    
   end
   else begin
        AluOpCtrlA=3;
   end          
    
    //now for ALuopctrlB    
   if(UseImmed) begin
     AluOpCtrlB = 0;
   end     
   
   else if( EX_RegWrite == 1 & EX_Rw!=0 & ID_Rt==EX_Rw) begin
                       
                           AluOpCtrlB =2;
                        
                      
      end
                     
      else if(MEM_RegWrite==1 & MEM_Rw!=0 & ID_Rt==MEM_Rw) begin
                     
                          AluOpCtrlB =1;
                       
                       
      end
      else begin
           AluOpCtrlB=3;
      end
         
/*In the case of an immediate type instruction or a shift instruction that makes use of the shamt
field, we need not forward any data. Thus, the UseShamt and UseImmed signals from the control
unit must be routed into the forwarding unit. In either of those cases, we simply select the
appropriate field from the current instruction.
*/


        
end
//
//PRIORITY ALSO TO BE CHECKED - latest values to be forwarded - to be added later on 

//Datamemory 
always @(ID_Rt or EX_Rw or EX_RegWrite or MEM_Rw or MEM_RegWrite ) begin
    if(ID_Rt == EX_Rw && ID_Rt!=0 && EX_RegWrite==1) begin
        DataMemForwardCtrl_MEM = 1;
        DataMemForwardCtrl_EX = 0;
    end
    else if(ID_Rt !=0 && ID_Rt == MEM_Rw && MEM_RegWrite==1)begin
        DataMemForwardCtrl_MEM = 0; //default
        DataMemForwardCtrl_EX = 1;
    end


    
    else begin
        DataMemForwardCtrl_EX = 0; //default
        DataMemForwardCtrl_MEM = 0;
    end
end



endmodule
