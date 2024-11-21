`timescale 1ns / 1ps


module EX_MEM_Pipe(
            //output
            MemtoReg_out,RegWrite_out,FloatRegWrite_out,MemRead_out,MemWrite_out,
            ALU_out,
            Rd_out,
            funct3_out,
			Instruction_out,
            //input
            MemtoReg_in,RegWrite_in,FloatRegWrite_in,MemRead_in,MemWrite_in,
            ALU_in,
            Rd_in,
            funct3_in,
			Instruction_in,
            clk,rst,
            );

output logic[31:0]ALU_out;
output logic[4:0]Rd_out;
output logic MemRead_out,MemWrite_out;//M     
output logic MemtoReg_out,RegWrite_out,FloatRegWrite_out;//WB     
output logic [2:0]funct3_out;
output logic [31:0]Instruction_out;

input [31:0]ALU_in;
input [4:0]Rd_in;
input MemRead_in,MemWrite_in;
input MemtoReg_in,RegWrite_in,FloatRegWrite_in;
input [2:0]funct3_in;
input [31:0]Instruction_in;
input clk,rst;

always@(posedge rst , posedge clk)
begin
    if(rst)
    begin//
        ALU_out<=32'd0;
        Rd_out<=5'd0;
        MemRead_out<=1'd0;
        MemWrite_out<=1'd0;
        MemtoReg_out<=1'd0;
        RegWrite_out<=1'd0;
        FloatRegWrite_out<=1'd0;
        funct3_out<=3'd0;
        Instruction_out<=32'd0;
    end
    else
    begin
        ALU_out<=ALU_in;
        Rd_out<=Rd_in;
        MemRead_out<=MemRead_in;
        MemWrite_out<=MemWrite_in;
        MemtoReg_out<=MemtoReg_in;
        RegWrite_out<=RegWrite_in;
        FloatRegWrite_out<=FloatRegWrite_in;
        funct3_out<=funct3_in;
		Instruction_out<=Instruction_in;
    end
end
endmodule
