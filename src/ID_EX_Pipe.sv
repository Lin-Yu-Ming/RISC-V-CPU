`timescale 1ns / 1ps


module ID_EX_Pipe(
            //output
           	ALUSrc_out,MemtoReg_out,RegWrite_out,FloatRegWrite_out,MemRead_out,MemWrite_out,Branch_out,ALUOp_out, //control out
            PC_out,Read_data1_out,Read_data2_out,Immediate_out,
            Rd_out,funct_code_out,
		    Rs1_out,Rs2_out, //hazard out
		    op_code_out,
		    stall_out,
		    forwardA_out,forwardB_out,
		    //alu_operation_out,
		    Instruction_IDEXout,
		
            //input
            ALUSrc_in,MemtoReg_in,RegWrite_in,FloatRegWrite_in,MemRead_in,MemWrite_in,Branch_in,ALUOp_in,//control in
            PC_in,Read_data1_in,Read_data2_in,Immediate_in,
            Rd_in,funct_code_in,
		    Rs1_in,Rs2_in, //hazard in
		    op_code_in,
		    stall_in,
		    forwardA_in,forwardB_in,
		    //alu_operation_in,
		    instruction_IDEXin,
            clk,rst,
            );
output logic [31:0]PC_out,Read_data1_out,Read_data2_out,Immediate_out;
output logic [4:0]Rd_out;//5bit
output logic [4:0]funct_code_out;
output logic ALUSrc_out;//EX
output logic [1:0] ALUOp_out;//Ex
output logic MemRead_out,MemWrite_out,Branch_out;//M     
output logic MemtoReg_out,RegWrite_out,FloatRegWrite_out;//WB

output logic [4:0]Rs1_out;//hazard
output logic [4:0]Rs2_out;//hazard
output logic [6:0]op_code_out;
output logic stall_out;
output logic [1:0]forwardA_out,forwardB_out;

//output logic [5:0]alu_operation_out;//6bit
output logic [31:0]Instruction_IDEXout;
//output logic [4:0]IDEX_RegisterRd_out;//hazard

input [31:0]PC_in,Read_data1_in,Read_data2_in,Immediate_in;
input [4:0]Rd_in;
input [4:0]funct_code_in;
input ALUSrc_in;
input [1:0]ALUOp_in;
input MemRead_in,MemWrite_in,Branch_in;
input MemtoReg_in,RegWrite_in,FloatRegWrite_in;
input [4:0]Rs1_in;//hazard
input [4:0]Rs2_in;//hazard
input [6:0]op_code_in;
input stall_in;
input [1:0]forwardA_in,forwardB_in;
input [31:0]instruction_IDEXin;

//input [5:0]alu_operation_in;//6bit

input clk,rst;

always@(posedge rst or posedge clk)
begin
    if(rst) 
    begin
	   PC_out<=32'd0;
	   Read_data1_out<=32'd0;
	   Read_data2_out<=32'd0;
	   Immediate_out<=32'd0;
	   Rd_out<=5'd0;
	   funct_code_out<=5'd0;
	   ALUSrc_out<=1'd0;
	   ALUOp_out<=2'd0;
	   MemRead_out<=1'd0;
	   MemWrite_out<=1'd0;
	   Branch_out<=1'd0;	
	   MemtoReg_out<=1'd0;
	   RegWrite_out<=1'd0;
	   FloatRegWrite_out<=1'd0;

	   Rs1_out<=5'd0;//hazard
	   Rs2_out<=5'd0;//hazard
	   op_code_out<=7'd0;
	   stall_out<=1'd0;

	   forwardA_out<=2'd0;
	   forwardB_out<=2'd0;
	   //alu_operation_out<=6'd0;
	   Instruction_IDEXout<=32'd0;
	end
	else 
	begin
	   PC_out<=PC_in;
	   Read_data1_out<=Read_data1_in;
	   Read_data2_out<=Read_data2_in;
	   Immediate_out<=Immediate_in;
	   Rd_out<=Rd_in;
	   funct_code_out<=funct_code_in;
	   ALUSrc_out<=ALUSrc_in;
	   ALUOp_out<=ALUOp_in;
	   MemRead_out<=MemRead_in;
	   MemWrite_out<=MemWrite_in;
	   Branch_out<=Branch_in;
	   MemtoReg_out<=MemtoReg_in;
	   RegWrite_out<=RegWrite_in;
	   FloatRegWrite_out<=FloatRegWrite_in;

	   Rs1_out<=Rs1_in;//hazard
	   Rs2_out<=Rs2_in;//hazard
	   op_code_out<=op_code_in;
	   stall_out<=stall_in;

	   forwardA_out<=forwardA_in;
	   forwardB_out<=forwardB_in;
	   //alu_operation_out<=alu_operation_in;	
	   Instruction_IDEXout<=instruction_IDEXin;
	end
end  
     
endmodule

