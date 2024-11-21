`timescale 1ns / 1ps


module ALU_control_unit(ALU_operation, ALUOp, FunctCode,instruction);


localparam ANDop = 6'b00_0000;
localparam ORop = 6'b00_0001;
localparam ADDop = 6'b00_0010;
localparam SUBop = 6'b00_0110;
localparam XORop = 6'b00_0111 ;
localparam AlgoShiftRightUnsignedop = 6'b00_1001;
localparam AlgoShiftRightSignedop = 6'b00_1010;
localparam LogicShiftLeftop = 6'b00_1011;
localparam LogicShiftRightUnsignedop = 6'b00_1100;
localparam LogicShiftRightSignedop = 6'b00_1101;

localparam MULop = 6'b01_0000;
localparam MULHop = 6'b01_0001;
localparam MULHSUop = 6'b01_0010;
localparam MULHUop = 6'b01_0011;

localparam FADDop = 6'b11_0000;//fadd
localparam FSUBop = 6'b11_0001;//fsub

output logic [5:0]ALU_operation;
input [31:0] instruction;
input [1:0]ALUOp;
input [4:0]FunctCode;      //instr[30,25,14-12](func7[5]+func7[0]+func3[2:0])



always_comb
  begin                                       
	unique casex ({ALUOp,FunctCode})
	//Rtype ->10 Rtype ids
	 (7'b10_00_000):ALU_operation=ADDop; //add
	 (7'b10_10_000):ALU_operation=SUBop;  //sub
	 (7'b10_00_001):ALU_operation=LogicShiftLeftop; //sll
	 (7'b10_00_010):ALU_operation=AlgoShiftRightSignedop; //slt
	 (7'b10_00_011):ALU_operation=AlgoShiftRightUnsignedop;  //sltu
	 (7'b10_00_100):ALU_operation= XORop; //xor
	 (7'b10_10_101):ALU_operation= LogicShiftRightUnsignedop; //srl unsigned	 
	 (7'b10_00_101):ALU_operation= LogicShiftRightSignedop; //sra signed	 	
	 (7'b10_00_110):ALU_operation= ORop;//or	 
	 (7'b10_00_111):ALU_operation= ANDop;//and
	(7'b10_01_000):ALU_operation= MULop; //mul
	(7'b10_01_001):ALU_operation= MULHop; //mulh	
	(7'b10_01_010):ALU_operation= MULHSUop; //mulhsu	
	(7'b10_01_011):ALU_operation= MULHUop;//mulhu
			
	
	
	//Itype
	 (7'b00_XX_000):ALU_operation=ADDop;  //addi
	 (7'b00_XX_010):ALU_operation=AlgoShiftRightSignedop;  //slti
	 (7'b00_XX_011):ALU_operation=AlgoShiftRightUnsignedop;  //sltu
	 (7'b00_XX_100):ALU_operation= XORop; //xori
	 (7'b00_XX_110):ALU_operation= ORop;  //ori	
	 (7'b00_XX_111):ALU_operation= ANDop;  //andi
	 (7'b00_0X_001):ALU_operation= LogicShiftLeftop; //slli
	 (7'b00_0X_101):ALU_operation= LogicShiftRightUnsignedop; //srli unsigned	 
	 (7'b00_1X_101):ALU_operation= LogicShiftRightSignedop;//srai signed
		 	
	// Btype/Utype/Jtype/jalr/load/store/CSR
	 (7'b01_XX_XXX): ALU_operation=ADDop; 
	
	 (7'b11_xx_010):ALU_operation=ADDop; //FLW/FSW
        
    (7'b11_xx_111):begin
       case (instruction[31:27])
           5'b00000:ALU_operation=FADDop; //FADD
           5'b00001:ALU_operation=FSUBop; //FSUB
           default:ALU_operation=6'b11_1111; 
       endcase
    end
		
	    
	default:   //Error(undefined)
		ALU_operation=6'b11_1111; 
		
	endcase
  end
endmodule
