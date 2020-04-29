`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2019 07:31:39 PM
// Design Name: 
// Module Name: Hazard
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


module Hazard_Unit(IF_write , PC_write , bubble , addrSel , Jump ,jr, Branch , ALUZero ,
    memReadEX , ID_Rs , ID_Rt , EX_Rw , MEM_Rw,
EX_RegWrite , MEM_RegWrite , UseShamt , UseImmed , Clk , Rst ) ;
    output reg IF_write , PC_write, bubble;
     
    output reg [ 1 : 0 ] addrSel ;
    input Jump , Branch , ALUZero , memReadEX , Clk , Rst ;
    input UseShamt , UseImmed ;
    input [ 4 : 0 ] ID_Rs,ID_Rt,EX_Rw, MEM_Rw;    
    input jr;
    
    input EX_RegWrite, MEM_RegWrite;
/*state definition for FSM*/
    parameter NoHazard_state = 3'b000;
    parameter LdHazard_state = 3'b001;
    parameter Jump_state = 3'b010;
   // parameter Branch0_state = 3'b011;
    parameter Branch1_state = 3'b100;
    parameter Jr_state = 3'b011; 
	/*Define a name for each of the states so it is easier to debug and follow*/ 
				 
	
	reg jr_bubble;
	
	/*internal state*/
	reg [2:0] FSM_state,FSM_nxt_state;
	/* internal signals*/
	reg LdHazard;
		
	/*FSM state register*/
	//-----------------SEQUENTIAL LOGIC ------------------//
	always @(negedge Clk or negedge Rst) begin
            if(~Rst) 
                FSM_state <= 0;
            else
                FSM_state <= FSM_nxt_state;
        end

	always @(EX_Rw or memReadEX or UseShamt or UseImmed or ID_Rs or EX_Rw or ID_Rt) begin
		if (EX_Rw !=0 && memReadEX == 1)begin 

			if ((UseShamt==0) && (UseImmed==0) && ((ID_Rs == EX_Rw) || (ID_Rt == EX_Rw))) begin 
				LdHazard <=1;// here currRt changed
			end
			else if(((UseShamt==1) || (UseImmed==1)) && (ID_Rs==EX_Rw)) begin 
			
				LdHazard<=1;
			end
			else begin
				LdHazard<=0;
			end
		end
		else begin
			LdHazard <=0;
		end 
	end
	/*------LOGIC FOR DETERMINING IF STALL FOR JR INSTRUCTION -------*/
	//EX_Rw or MEM_Rw or EX_RegWrite or MEM_RegWrite or ID_Rs or ID_Rt or jr
	always @(*) begin
	   if(jr && MEM_RegWrite==1 && MEM_Rw!=0 && ((ID_Rs==MEM_Rw) || (ID_Rt==MEM_Rw))) begin
               jr_bubble <= 1;
       end
	   else if(jr && EX_RegWrite == 1 && EX_Rw!=0 && ((ID_Rs==EX_Rw) || (ID_Rt==EX_Rw))) begin
	       jr_bubble <= 1;
	   end
	   
	   else begin 
	       jr_bubble <= 0;
	   end
	   
	end
	/*FSM next state and output logic*/
      always @(*) begin //combinational logic
        case(FSM_state)
            NoHazard_state: begin 
                if(Jump== 1'b1) begin //prioritize jump
                    //INCLUDE BUBBLE FOR JR INSTRUCTION AND NOT FORWARDING
                    //uncondition return to no hazard state
                    /* Provide the value of FSM_nxt_state and outputs (PCWrite,IFWrite,Bubble)*/ 
                    FSM_nxt_state = Jump_state; 
                    IF_write = 1'b0; //
                    PC_write = 1'b1;
                    bubble   = 1'b0 ;//changed here
                    addrSel  = 2'b01;
                end
                else if(jr_bubble) begin
                    FSM_nxt_state = NoHazard_state; 
                    IF_write = 1'b0; 
                    PC_write = 1'b0;
                    bubble   = 1'b0;
                    addrSel  = 2'b00;
                    //jr_bubble = 0;
                end
                else if(jr==1'b1) begin //prioritize jump
                    //INCLUDE BUBBLE FOR JR INSTRUCTION AND NOT FORWARDING
                    //uncondition return to no hazard state
                    /* Provide the value of FSM_nxt_state and outputs (PCWrite,IFWrite,Bubble)*/
                   /* if(jr_bubble) begin
                        FSM_nxt_state = NoHazard_state; 
                        IF_write = 1'b0; 
                        PC_write = 1'b0;
                        bubble   = 1'b0;//causing iteration limit
                        addrSel  = 2'b00;
                    end*/
                    
                    
                        FSM_nxt_state = Jr_state; 
                        IF_write = 1'b0; 
                        PC_write = 1'b1;
                        bubble   = 1'b0;
                        addrSel  = 2'b01; 
                    
                    
                end
                else if(Branch== 1'b1 && ALUZero==1'b1 ) begin //3-delay data hazard
                    //uncondition return to no hazard state
                    /* Provide the value of FSM_nxt_state and outputs (PCWrite,IFWrite,Buble)*/ 
                    FSM_nxt_state = Branch1_state; 
                    IF_write = 1'b0; 
                    PC_write = 1'b1;
                    bubble   = 1'b1;//flush pipeline so hence bubble
                    addrSel  = 2'b10;
                end
                else if(LdHazard) begin
                    FSM_nxt_state = NoHazard_state; 
                    IF_write = 1'b0; 
                    PC_write = 1'b0;
                    bubble   = 1'b1;
                    addrSel  = 2'b00;
                
                end
                else begin
                    FSM_nxt_state = NoHazard_state; 
                    IF_write = 1'b1; 
                    PC_write = 1'b1;
                    bubble   = 1'b0;
                    addrSel  = 2'b00;
                end
                /* Complite the "NoHazard_state" state as needed*/
            end
            
            Jump_state : begin
            //uncondition return to no hazard state
            /* Provde the value of FSM_nxt_state and outputs                                 (PCWrite,IFWrite,Buble)*/ 
                FSM_nxt_state = NoHazard_state;
                IF_write = 1'b1; 
                PC_write = 1'b1;
                bubble   = 1'b1;
                addrSel  = 2'b00;    
            end
           /* Branch0_state : begin
                if(ALUZero==1'b1) begin
                    FSM_nxt_state = Branch1_state;
                    IF_write = 1'b0; 
                    PC_write = 1'b1;
                    bubble   = 1'b0;//
                    addrSel  = 2'b10;

                end
                else if(ALUZero==1'b0) begin 
                    FSM_nxt_state = NoHazard_state;
                    IF_write = 1'b1; 
                    PC_write = 1'b1;
                    bubble   = 1'b1;
                    addrSel  = 2'b00;
                end
            end*/
            
            Branch1_state : begin 
                   FSM_nxt_state = NoHazard_state;
                   IF_write = 1'b1; 
                   PC_write = 1'b1;
                   bubble   = 1'b1;
                   addrSel  = 2'b00;

            end
            
            Jr_state : begin
                   FSM_nxt_state = NoHazard_state;
                   IF_write = 1'b1; 
                   PC_write = 1'b1;
                   bubble   = 1'b1;
                   addrSel  = 2'b00;
            
            
            end
           /* LdHazard_state : begin
                 
               FSM_nxt_state = NoHazard_state;
               IF_write = 1'b1; 
               PC_write = 1'b1;
               bubble   = 1'b1;
               addrSel  = 2'b00;
            end*/
            default: begin
                FSM_nxt_state = NoHazard_state;
                PC_write = 1'bx;
                IF_write = 1'bx;
                bubble = 1'bx;
                addrSel = 2'bxx;
            end
        endcase
    end   
endmodule