`timescale 1ns / 1ps


module Forwarding_unit(
          //output

          ForwardA_flag,
          ForwardB_flag,
          //input control
          IFID_Rs1,
          IFID_Rs2,
          IDEX_RegWrite,
          IDEX_RegisterRd,
          EXMEM_RegWrite,
          EXMEM_RegisterRd,

		  instruction_in,
		  instruction_IDEXout,
		  instruction_EXMEMout,
					);


output logic [1:0]ForwardA_flag;
output logic [1:0]ForwardB_flag;
 
input [4:0]IFID_Rs1;
input [4:0]IFID_Rs2;
input IDEX_RegWrite;
input [4:0]IDEX_RegisterRd;
input EXMEM_RegWrite;
input [4:0]EXMEM_RegisterRd;
input [31:0]instruction_in;
input [31:0]instruction_IDEXout;
input [31:0]instruction_EXMEMout;



always_comb
begin 
	  if(instruction_in[6:0]==7'b0100111 || instruction_in[6:0]==7'b0000111 )begin
		  if( (IDEX_RegWrite == 1'b1) && (instruction_IDEXout[6:0]!=7'b1010011  )
		  && (IDEX_RegisterRd != 5'b00000) 
		  && (IDEX_RegisterRd == IFID_Rs1) )  //EX hazard
		  ForwardA_flag = 2'b01;           //data from EX/MEM ,from last alu out

		  else if( (EXMEM_RegWrite == 1'b1)&& (instruction_EXMEMout[6:0]!=7'b1010011)
		  && (EXMEM_RegisterRd != 5'b00000)
		  && (EXMEM_RegisterRd == IFID_Rs1) )  //MEM hazard
		  ForwardA_flag = 2'b10;  //data from MEM/WB ,from data memory or prior alu result
		  else
		  ForwardA_flag = 2'b00;
		end
	  else begin
		  if( (IDEX_RegWrite == 1'b1) 
		  && (IDEX_RegisterRd != 5'b00000) 
		  && (IDEX_RegisterRd == IFID_Rs1) )  //EX hazard
		  ForwardA_flag = 2'b01;           //data from EX/MEM ,from last alu out

		  else if( (EXMEM_RegWrite == 1'b1)
		  && (EXMEM_RegisterRd != 5'b00000)
		  && (EXMEM_RegisterRd == IFID_Rs1) )  //MEM hazard
		  ForwardA_flag = 2'b10;  //data from MEM/WB ,from data memory or prior alu result
		  else
		  ForwardA_flag = 2'b00;
		end
end

always_comb
begin 
	  if(instruction_in[6:0]==7'b1010011 ||instruction_in[6:0]==7'b0100111 || instruction_in[6:0]==7'b0000111 )begin
			if( (IDEX_RegWrite == 1'b1) && (instruction_IDEXout[6:0]==7'b0000111 || instruction_IDEXout[6:0]==7'b0100111 || (instruction_IDEXout[6:0]==7'b1010011) )
			&& (IDEX_RegisterRd != 5'b00000) 
			&& (IDEX_RegisterRd == IFID_Rs2) )  //EX hazard
			ForwardB_flag = 2'b01;          //data from EX/MEM ,from last alu out
			else if( (EXMEM_RegWrite == 1'b1) && (instruction_EXMEMout[6:0]==7'b0000111 || instruction_EXMEMout[6:0]==7'b0100111 ||instruction_EXMEMout[6:0]==7'b1010011)
			&& (EXMEM_RegisterRd != 5'b000000) 
			&& (EXMEM_RegisterRd == IFID_Rs2) )  //MEM hazard
			ForwardB_flag = 2'b10;  //data from MEM/WB ,from data memory or prior alu result
			else
			ForwardB_flag = 2'b00;
		end
	  else begin
			if( (IDEX_RegWrite == 1'b1)
			&& (IDEX_RegisterRd != 5'b00000) 
			&& (IDEX_RegisterRd == IFID_Rs2) )  //EX hazard
			ForwardB_flag = 2'b01;          //data from EX/MEM ,from last alu out
			else if( (EXMEM_RegWrite == 1'b1)  
			&& (EXMEM_RegisterRd != 5'b000000)
			&& (EXMEM_RegisterRd == IFID_Rs2) )  //MEM hazard
			ForwardB_flag = 2'b10;  //data from MEM/WB ,from data memory or prior alu result
			else
			ForwardB_flag = 2'b00;
		end
end 
endmodule
