`timescale 1ns / 1ps


`define SLL 	4'b0011
`define SRL 	4'b0100

`define SRA		4'b1101

//divide the main flow into stages logic using always blocks as in the hint video
module PipelinedProc (
CLK,
Reset_L,
startPC,
dMemOut);
    
input CLK,Reset_L;
input [31:0] startPC;
output [31:0] dMemOut;

wire [31:0] data;
wire [31:0] Address; //changed to register
wire [31:0] updated_PC_Address;

//SCC1 wires 
wire [1:0] RegDst;
//wire ALUSrc;
wire MemToReg;
wire RegWrite;
wire MemRead;
wire MemWrite;
wire Branch;
wire Jump;
wire SignExtend;
wire [3:0]AluOp;

//register RF1 wires 
wire [31:0] BusA, BusB;
wire [31:0] BusW;
wire [4:0] RA, RB, RW;
wire RegWr;
wire Clk;
wire[4:0] write_register_select;
wire [31:0] write_register_data;


//ALU CONTROL
wire [3:0] AluCtrl;


//MUX before ALU 
wire [31:0] operandB_ALU;
wire[31:0] sign_extension_data;

//ALU 
wire [31:0] ALU_Output;
wire Zero;


//DATA MEMORY 
wire [31:0] Data_memory_out;

//shiftleft for branch;
wire [31:0] shift_left_2_branch;

//branch address
wire [31:0] branch_address;

//pc update
wire [31:0] PC_update;

//and of branch and zero 

wire [31:0] branch_and ;

//input to branch mux;

wire [31:0] branch_mux;

//shift left 2 bits 25 to 0
wire [27:0] shift_for_jump;

//final jump 
wire [31:0] final_jump;

//wire [31:0] final_output;

wire [31:0] final_bus_B;
wire [31:0] final_bus_A;
wire shift; // this is to account for the shamt part of R type instructions for SLL SRL SRA
// new variabeles

wire [1:0] addrSel;
wire PC_write;
wire IF_write;
reg [31:0] data2;
wire [5:0] Opcode;
wire [4:0] rs, rt, rd, shamt;
wire [5:0] funct;
wire [15:0] imm16;
wire bubble;
wire UseShamt;
wire UseImmed;
wire [4:0] rw;
wire rsUsed;
wire rtUsed;



wire [1:0] AluOpCtrlA;
wire [1:0] AluOpCtrlB;
wire DataMemForwardCtrl_EX;
wire DataMemForwardCtrl_MEM;


wire [31:0] shifted;

wire jr;
wire jal;
// stage 3 logic variables
reg [5:0] funct3;
reg [31:0] final_bus_A3;
reg [31:0] final_bus_B3;
reg [31:0] BusA3;
reg [31:0] BusB3;
reg [31:0] sign_extension_data3;
reg [4:0] rw3;
reg [1:0] RegDst3;
reg MemToReg3;
reg RegWrite3;
reg MemRead3;
reg MemWrite3;
reg Branch3;
reg [3:0] AluOp3;
reg [1:0] AluOpCtrlA3;
reg [1:0] AluOpCtrlB3;
reg DataMemForwardCtrl_EX3;
reg DataMemForwardCtrl_MEM3;
reg [31:0] muxA;
reg [31:0] muxB;
wire [31:0] muxC;
reg [4:0] shamt3;
reg [31:0] shift_left_2_branch3;

reg jal3 ;
reg [31:0] Address3;
wire [31:0] datamemory_address;

reg [31:0] branch_address3;
//STAGE 4 logic variables

wire [31:0] muxD;  
reg  Zero4;
reg [31:0] branch_address4; 
reg  [31:0] ALU_Output4;
reg [31:0] BusB4;
reg [4:0] rw4;
reg MemToReg4;
reg RegWrite4;
reg MemRead4;
reg MemWrite4;
reg Branch4;//no use
reg [31:0] muxC4;
reg DataMemForwardCtrl_MEM4;

reg [31:0] datamemory_address4;

//STAGE 5  LOGIC  VARIABLES
reg [31:0] Data_memory_out5;
reg [31:0] ALU_Output5;
reg [4:0] rw5;
reg MemToReg5;
reg RegWrite5;



/*-----------------------------------------Stage 1 Logic-----------------------------------------*/
	
	//-----------------------------------------PC RESET OR NORMAL -----------------------------------
    assign  updated_PC_Address = (addrSel==2'b00)? PC_update : (addrSel==2'b01)? final_jump : ((addrSel==2'b10)) ? branch_address3 : PC_update; //change to 4 back
    PC pc1( PC_write,CLK,Reset_L,updated_PC_Address,startPC,Address);
	
	 
	//------------------------------------PC + 4 -----------------------------------------
     assign  PC_update =  Address + 32'd4 ;  //give delay so ttat this executes later than PC function
	//-----------------------------------INSTRUCTION FETCH ---------------------------------------
        InstructionMemory im1(data, Address);
        
        
        
	/*  ---------------------------STAGE 2 LOGIC STARTS FOR IF/ID  ----------------------------------*/
	always @ (negedge CLK or negedge Reset_L) begin
            if(~Reset_L)
                data2 = 32'b0; 
            else if(IF_write) begin
                data2 = data;
                
            end
    end
	 
	assign {Opcode, rs, rt, rd, shamt, funct} = data2; 
	
	assign imm16 = data2[15:0];
	 
	PipelinedControl controller(UseShamt,RegDst, UseImmed, MemToReg, RegWrite, MemRead, MemWrite, Branch, Jump, jr, jal, SignExtend, AluOp, Opcode, funct, bubble);
	assign #1 rw = (RegDst==2'b10) ? 5'd31 : (RegDst==2'b01) ? rd : rt;  
	//assign #2 rsUsed = (Opcode != 6'b001111/*LUI*/) & ~UseShamt;
    //assign #1 rtUsed = (Opcode == 6'b0) || Branch || (Opcode == 6'b101011/*SW*/);
    
    Hazard_Unit hazard( IF_write , PC_write , bubble , addrSel , Jump ,jr, Branch3 , Zero ,
        MemRead3 , rs, rt, RegWrite3 ? rw3 : 5'b0 , rw4,
    RegWrite3 , RegWrite4 , UseShamt , UseImmed , CLK , Reset_L ) ; //ensure Zero here is equal to Zero of ALU result module
        //changed to Zero here
        //rtUsed ? rt : 5'b0
        //rw changed to rw3 here
        //rtUsed ? rt : 5'b0

    //----------------------------------INSTRUCTION DECODE ------------------------------------------
    RegisterFile rf1 (.BusA(BusA), .BusB(BusB), .BusW(write_register_data), .RA(rs), .RB(rt), .RW(RegWrite5 ? rw5 : 5'b0), .RegWr(RegWrite5), .Clk(CLK)); 
    //define RegWrite5 , write_register_data(already defined under) from stage 5 logic , rw5 from stage 5 logic 
    
    
     assign sign_extension_data[31:0] = SignExtend ? {{16{imm16[15]}},imm16} : {{16{1'b0}},imm16}  ;
    assign shift_for_jump = data2[25:0] << 2;
        assign final_jump = (jr==1'b1) ? BusA :{Address[31:28],shift_for_jump};//jr mux included here
       
        
     //  assign #2 operandB_ALU = ALUSrc ? sign_extension_data :BusB;
        //assign #2 final_bus_A = UseShamt ? BusB : BusA;   
 //   assign #2 final_bus_B = UseShamt ? {27'b0, shamt} : operandB_ALU;//shamt ot Data2[10:6] ?? check
    //assign final_bus_A = {27'b0, shamt};
    assign final_bus_B = (AluOpCtrlB == 2'b00) ? sign_extension_data : BusB;
    ForwardingUnit fu1( UseShamt , UseImmed , rs , rt , rw3 , rw4,
RegWrite3 , RegWrite4 , AluOpCtrlA , AluOpCtrlB , DataMemForwardCtrl_EX ,
DataMemForwardCtrl_MEM );   //rsUsed to be converted into rs ?? same for rt? 

//assign shifted = sign_extension_data << 2;
assign shift_left_2_branch[31:0] = Branch ? (sign_extension_data[29:0] << 2) : 32'd0;
assign  branch_address[31:0] =  Branch ? ( shift_left_2_branch + Address) : 32'd0;	
	
	/*----------------------------------------STAGE 3 LOGIC------------------------------------------*/
    always @ (negedge CLK or negedge Reset_L) begin
            if(~Reset_L) begin
                branch_address3 <= 0;
                jal3 <= 0;
                Address3<=0;
                shamt3 <= 0;
                final_bus_B3 <= 0;
                BusA3 <= 0;
                BusB3 <= 0;
                funct3 <= 0;
                rw3 <= 0;
                RegDst3 <= 0;
                MemToReg3 <= 0;
                RegWrite3 <= 0;
                MemRead3 <= 0;
                MemWrite3 <= 0;
                Branch3 <= 0;
                AluOp3 <= 0;
                AluOpCtrlA3<=0;
                AluOpCtrlB3<=0;
                DataMemForwardCtrl_EX3<=0;
                DataMemForwardCtrl_MEM3<=0;
            end
            else if(bubble) begin
                branch_address3 <= 0;
                jal3 <= 0;
                Address3<=0;
                shamt3 <= 0;
                final_bus_B3 <= 0;
                BusA3 <=0;
                BusB3 <= 0;
                funct3 <= 0;
                rw3 <= 0;
                RegDst3 <= 0;
                MemToReg3 <= 0;
                RegWrite3 <= 0;
                MemRead3 <= 0;
                MemWrite3 <= 0;
                Branch3 <= 0;
                AluOp3 <= 0;
                AluOpCtrlA3<=0;
                AluOpCtrlB3<=0;
                DataMemForwardCtrl_EX3<=0;
                DataMemForwardCtrl_MEM3<=0;
            end
            else begin
                branch_address3 <= branch_address;
                jal3 <= jal;
                Address3<= Address;
                shamt3 <= shamt;
                final_bus_B3 <= final_bus_B;
                BusA3 <= BusA;
                BusB3 <= BusB;
                funct3 <= funct;
                rw3 <= rw;
                RegDst3 <= RegDst;
                MemToReg3 <= MemToReg;
                RegWrite3 <= RegWrite;
                MemRead3 <= MemRead;
                MemWrite3 <= MemWrite;
                Branch3 <= Branch;
                AluOp3 <= AluOp;
                AluOpCtrlA3<=AluOpCtrlA;
                AluOpCtrlB3<=AluOpCtrlB;
                DataMemForwardCtrl_EX3<=DataMemForwardCtrl_EX;
                DataMemForwardCtrl_MEM3<=DataMemForwardCtrl_MEM;
            end
        end
        //define all the aboive variables
    
        
    //assign funct3 = sign_extension_data3[5:0];//define funct3
    ALUControl ac1(AluCtrl, AluOp3, funct3);
   
    
    always @(*) begin
        case(AluOpCtrlA3)
            2'b00 : muxA = {27'b0, shamt3}; // shamt value
            2'b01 : muxA = write_register_data;
            2'b10 : muxA = ALU_Output4;
            2'b11 : muxA = BusA3;//change to BusA?
            default : muxA = 0;  //
        endcase 
    end
    always @(*) begin
        case(AluOpCtrlB3)
            2'b00 : muxB = final_bus_B3;  //signextended immediate value
            2'b01 : muxB = write_register_data;
            2'b10 : muxB = ALU_Output4;
            2'b11 : muxB = final_bus_B3;
            default: muxB = 0;//what should be the default value?
        endcase
    end
    ALU alu1(ALU_Output, Zero, muxA, muxB, AluCtrl);       
    
    assign muxC = DataMemForwardCtrl_EX3 ? write_register_data : BusB3;      

    assign datamemory_address = jal3 ? Address3 : ALU_Output;
	     //define jal3 and datamemory_address
    
    
    
    

/*------------------------------------STAGE  4  LOGIC  -----------------------------------------------  */
always @ (negedge CLK or negedge Reset_L) begin
		if(~Reset_L) begin
		    datamemory_address4 <= 0;
			Zero4 <= 0;
			//branch_address4 <= 0;
			ALU_Output4 <= 0;
			BusB4 <= 0;
			rw4 <= 0;
			MemToReg4 <= 0;
			RegWrite4 <= 0;
			MemRead4 <= 0;
			MemWrite4 <= 0;
			Branch4 <= 0;
			muxC4 <= 0; 
			DataMemForwardCtrl_MEM4 <= 0;
		end
		else begin
		    datamemory_address4 <= datamemory_address;
			Zero4 <= Zero;
            //branch_address4 <= branch_address;
            ALU_Output4 <= ALU_Output;
            BusB4 <= BusB3;
            rw4 <= rw3;
            MemToReg4 <= MemToReg3;
            RegWrite4 <= RegWrite3;
            MemRead4 <= MemRead3;
            MemWrite4 <= MemWrite3;
            Branch4 <= Branch3;
            muxC4 <= muxC; 
            DataMemForwardCtrl_MEM4 <= DataMemForwardCtrl_MEM3;
		end
	end

assign muxD = DataMemForwardCtrl_MEM4 ? write_register_data : muxC4;
//-------------------------------   MEMORY   ACCESS -----------------------------------------------
DataMemory DM1 (Data_memory_out, datamemory_address4, muxD, MemRead4, MemWrite4, CLK);




/*----------------------------------STAGE  5   LOGIC  ---------------------------------------*/
always @ (negedge CLK or negedge Reset_L) begin
		if(~Reset_L) begin
			Data_memory_out5 <= 0;
			ALU_Output5 <= 0;
			rw5 <= 0;
			MemToReg5 <= 0;
			RegWrite5 <= 0;
		end
		else begin
			Data_memory_out5 <= Data_memory_out;
            ALU_Output5 <= datamemory_address4;
            rw5 <= rw4;
            MemToReg5 <= MemToReg4;
            RegWrite5 <= RegWrite4;
		end
	end

//-----------------------------mux for selecting data to be written into Register FILE-----------
assign #1 write_register_data = MemToReg5 ? Data_memory_out: ALU_Output5;










//-------------------------- FINAL OUTPUT OF SINGLE CYCLE PROCESSOR----------------------
assign dMemOut = Data_memory_out;



endmodule