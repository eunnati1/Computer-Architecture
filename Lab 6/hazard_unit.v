module HazardUnit (IF_write, PC_write, bubble, addrSel, Jump, Branch, ALUZero,
memReadEX, currRs, currRt, prevRt, UseShamt, UseImmed, Clk, Rst);

output reg IF_write, PC_write, bubble;
output reg [1:0] addrSel;
input Jump, Branch, ALUZero, memReadEX, Clk, Rst;
input UseShamt, UseImmed;
input [4:0] currRs, currRt, prevRt;

parameter NoHazard_state = 3'b000;
parameter Jump_state = 3'b001;
parameter Branch_0_state = 3'b010; //branch execution  
parameter Branch_1_state = 3'b011; //branch not taken

//internal Signals 
reg  LdHazard;

//internal states
reg [2:0] FSM_state, FSM_next_state;

//setting values of LdHazard 
always @(*) begin
if (prevRt !=0 && memReadEX == 1)begin 

if (currRs == prevRt)
LdHazard <=1;

else begin 
if ((UseShamt==0) && (UseImmed==0)) begin 
if (currRt==prevRt)
LdHazard<=1;
else 
LdHazard<=0;
end
else begin
LdHazard <=0;
end 
end 
end 
else begin 
LdHazard<=0;
end 
end 

always @(negedge Clk) begin 
if (Rst==0)
FSM_state <=0;
else
FSM_state <=FSM_next_state;
end 

//Melay implementation of states

always @(*) begin 
case (FSM_state)

NoHazard_state: begin  //jump should be a priority as mentioned in mannual. 
				
				if (Jump==1'b1)begin 
				{IF_write, PC_write, bubble, addrSel} = 5'b01001;//make the addrsel as per jump so that it can take the right pc from pipeline proceesor code. 
				FSM_next_state = Jump_state;//in the jump state make it normal again 
				end 
				
				else if (LdHazard==1'b1)begin//if hazard detected, stop fetching new IF and stop incrementing the PC and writing into pC 
				{IF_write, PC_write, bubble, addrSel} = 5'b00100;
				FSM_next_state = NoHazard_state;
				end
				
				else if (Branch==1'b1)begin 
				{IF_write, PC_write, bubble, addrSel} = 5'b00000;//as per the flow chart, go to branch zero and check for alu zero flag. Later resolve it back to normal 
				FSM_next_state = Branch_0_state;
				end
				
				else begin
				{IF_write, PC_write, bubble, addrSel} = 5'b11000;//normal state 
				FSM_next_state = NoHazard_state;
				end
				
				end
				
Jump_state: begin
			{IF_write, PC_write, bubble, addrSel} = 5'b11100;//stopping execution until jump is resolved completely in nohazard unit
			FSM_next_state = NoHazard_state;
			end
			
Branch_0_state: begin
				if (ALUZero==1'b0)begin //brnach not equal result 
				{IF_write, PC_write, bubble, addrSel} = 5'b11100;
				FSM_next_state = NoHazard_state;
				end 
				else if (ALUZero==1'b1)begin // branch equal result. 
				{IF_write, PC_write, bubble, addrSel} = 5'b01110;//stopping the IF stage incase branch gets detected. Assuming it to be BEQ and not BNEQ
				FSM_next_state = Branch_1_state;
				end
				end
				
Branch_1_state: begin
				{IF_write, PC_write, bubble, addrSel} = 5'b11100;//stopping execution until branch in completely resolved in no hazard unit. 
				FSM_next_state = NoHazard_state;
				end
				
default : 	begin 
			FSM_next_state = NoHazard_state;
			PC_write = 1'bx;
			IF_write = 1'bx;
			bubble = 1'bx;
			addrSel = 2'bxx;
			end 
endcase
end 
endmodule