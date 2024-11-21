`timescale 1ns / 1ps


module Control_unit(Branch, MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite,FloatRegWrite, OpCode);

output logic Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite,FloatRegWrite;
output logic [1:0]ALUOp;
input [6:0]OpCode;   //7bit op code




parameter opcode_Stype = 7'b0100011;
parameter opcode_Load = 7'b0000011;

always_comb
begin
            ALUSrc=1'b0;
			MemtoReg=1'b0;
			RegWrite=1'b0;
			MemRead=1'b0;
		    MemWrite=1'b0;
			Branch=1'b0;
			ALUOp=2'b00;
			FloatRegWrite=1'b0;
    unique case (OpCode)    
	    7'b0110011://R-type 
		begin
			ALUSrc=1'b0;
			MemtoReg=1'b0;
			RegWrite=1'b1;
			FloatRegWrite=1'b0;
			MemRead=1'b0;
			MemWrite=1'b0;
			Branch=1'b0;
			ALUOp=2'b10;
		end
		7'b0000011://I-type:lw/lb/lh/lhu/lbu
		begin
			ALUSrc=1'b1; //Itype ALUSrc=1,need use immediate
		    MemtoReg=1'b1;
			RegWrite=1'b1;
			FloatRegWrite=1'b0;
			MemRead=1'b1;
			MemWrite=1'b0;
			Branch=1'b0;//Itype branch=0
			ALUOp=2'b01;//01->add
		end
		7'b0010011://I-type:addi/slti/xori... =>these needn't use mem/branch,need write reg
		begin
			ALUSrc=1'b1; //Itype ALUSrc=1
		    MemtoReg=1'b0; //alu to reg->0
			RegWrite=1'b1; //need write reg
			FloatRegWrite=1'b0;
			MemRead=1'b0;  //no use mem
			MemWrite=1'b0; //no use mem
			Branch=1'b0;  //no branch
			ALUOp=2'b00;//00->immediate
		end
		7'b1100111://I-type:JALR   //jalr: rd=PC+4 & PC=imm+rs1
		begin
			ALUSrc=1'b1;  //Itype ALUSrc=1,need imm
		    MemtoReg=1'b0;  //alu to reg->0
			RegWrite=1'b1; //need write reg
			FloatRegWrite=1'b0;
			MemRead=1'b0;   //no read mem
			MemWrite=1'b0; //no write mem
			Branch=1'b1;   //need branch
			ALUOp=2'b01;   //01->add
		end
		7'b0100011://S-type:SW/SB/SH   //SW: M[rs1+imm] =rs2
		begin
			ALUSrc=1'b1;    //need use immediate
		    MemtoReg=1'b0;  //don't care
			RegWrite=1'b0;  //no write reg
			FloatRegWrite=1'b0;
			MemRead=1'b0;   //no read mem
			MemWrite=1'b1;  //write mem
			Branch=1'b0;    // no branch
			ALUOp=2'b01;    //01->add
		end
		7'b1100011://B-type: beq
		begin
			ALUSrc=1'b0;
			MemtoReg=1'b0; //don't care
			RegWrite=1'b0;
			FloatRegWrite=1'b0;
			MemRead=1'b0;
		    MemWrite=1'b0;
		    Branch=1'b1;  //only need branch
			ALUOp=2'b01;  //01->add
		end
		7'b0010111://U-type:AUIPC rd=PC+imm
		begin
			ALUSrc=1'b1;     //need use imm->1
			MemtoReg=1'b0;   //alu to reg->0
			RegWrite=1'b1;   //need write reg
			FloatRegWrite=1'b0;
			MemRead=1'b0;   //no mem
		    MemWrite=1'b0;  //no mem
		    Branch=1'b0;  //no branch
			ALUOp=2'b01;  //01->add
		end
		7'b0110111://U-type:LUI rd=imm
		begin
			ALUSrc=1'b1;     //need use imm->1
			MemtoReg=1'b0;   //alu to reg->0
			RegWrite=1'b1;   //need write reg
			FloatRegWrite=1'b0;
			MemRead=1'b0;   //no mem
		    MemWrite=1'b0;  //no mem
		    Branch=1'b0;  //no branch
			ALUOp=2'b01;  //01->add
		end
		7'b1101111://J-type:JAL  rd=PC+4 && PC=PC+imm
		begin
			ALUSrc=1'b1;     //need use imm->1
			MemtoReg=1'b0;   //alu to reg->0
			RegWrite=1'b1;   //need write reg
			FloatRegWrite=1'b0;
			MemRead=1'b0;   //no mem
		    MemWrite=1'b0;  //no mem
		    Branch=1'b1;  //need branch
			ALUOp=2'b01;  //01->add
	
		end
		7'b0000111:begin //F Type FLW
            ALUSrc=1'b1; //Itype ALUSrc=1,need use immediate
		    MemtoReg=1'b1;
			RegWrite=1'b1;
			FloatRegWrite=1'b1;
			MemRead=1'b1;
			MemWrite=1'b0;
			Branch=1'b0;//Itype branch=0
			ALUOp=2'b11;
        end

        7'b0100111:begin //F Type FSW
            ALUSrc=1'b1;    //need use immediate
		    MemtoReg=1'b0;  //don't care
			RegWrite=1'b0;  //no write reg
			FloatRegWrite=1'b0;
			MemRead=1'b0;   //no read mem
			MemWrite=1'b1;  //write mem
			Branch=1'b0;    // no branch
			ALUOp=2'b11;       
        end

        7'b1010011:begin //F Type FADD and FSUB
            ALUSrc=1'b0;
			MemtoReg=1'b0;
			RegWrite=1'b1;
			FloatRegWrite=1'b1;
			MemRead=1'b0;
			MemWrite=1'b0;
			Branch=1'b0;
			ALUOp=2'b11;
        end
		
		
		7'b1110011://CSR
		begin
			ALUSrc=1'b0;     //no use imm->0
			MemtoReg=1'b0;   //alu to reg->0
			RegWrite=1'b1;   //need write reg
			MemRead=1'b0;   //no mem
		    MemWrite=1'b0;  //no mem
		    Branch=1'b0;  //no branch
			ALUOp=2'b01;   //01->add 
		end
		default://all set 0
		begin
		    ALUSrc=1'b0;
			MemtoReg=1'b0;
			RegWrite=1'b0;
			MemRead=1'b0;
		    MemWrite=1'b0;
			Branch=1'b0;
			ALUOp=2'b00;
			FloatRegWrite=1'b0;
		end
	endcase
end
endmodule
