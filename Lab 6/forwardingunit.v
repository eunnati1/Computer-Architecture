module ForwardingUnit(
input UseShamt,
input UseImmed,
input [4:0] ID_Rs,
input [4:0] ID_Rt,
input [4:0] EX_Rw,
input [4:0] MEM_Rw,
input EX_RegWrite,
input MEM_RegWrite,
output reg [1:0] AluOpCtrlA,
output reg [1:0] AluOpCtrlB,
output DataMemForwardCtrl_EX,
output DataMemForwardCtrl_MEM
);

//AluOpCtrlA -> 00 shamt, 01 Register WB, 10 ALu out memory, 11 register a normal 
// AluOpCtrlB -> 00 Sign_exten data, 01 register wb, 10 alu out mem, 11 register b normal. 

always @ (*) begin 
if (UseShamt)
AluOpCtrlA <= 2'b00;

else if (EX_RegWrite && (ID_Rs==EX_Rw) && (EX_Rw!=0) )
AluOpCtrlA <= 2'b10;

else if (MEM_RegWrite && (ID_Rs==MEM_Rw) && (MEM_Rw!=0))
AluOpCtrlA <= 2'b01;

else
AluOpCtrlA <= 2'b11;

end 


always @(*)begin
if (UseImmed)
AluOpCtrlB <= 2'b00;

else if (EX_RegWrite && (ID_Rt==EX_Rw) && (EX_Rw!=0) )
AluOpCtrlB <= 2'b10;

else if ( (MEM_RegWrite) && (ID_Rt == MEM_Rw) && (MEM_Rw!=0) )
AluOpCtrlB <= 2'b01;

else
AluOpCtrlB <= 2'b11;
end

//DataMemForwardCtrl_EX

assign DataMemForwardCtrl_EX = MEM_RegWrite && (MEM_Rw == ID_Rt ) && (MEM_Rw!=0);

//DataMemForwardCtrl_MEM
assign DataMemForwardCtrl_MEM = EX_RegWrite && (EX_Rw == ID_Rt) && (EX_Rw!=0) ;

endmodule 