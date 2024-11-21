`timescale 1ns / 1ps



module Registers(Read_data1, Read_data2, RegWrite,FloatRegWrite ,Read_reg1, Read_reg2, 
                 Write_reg, Write_data, clk, rst,Read_data1_after_forward,Read_data2_after_forward,Opcode);

output logic [31:0]Read_data1, Read_data2,Read_data1_after_forward,Read_data2_after_forward;
input RegWrite,FloatRegWrite;
input [4:0]Read_reg1, Read_reg2, Write_reg;
input [31:0]Write_data;
input clk, rst;
input [6:0]Opcode;

logic [31:0]regs[31:0];
logic [31:0]floatregisters[31:0];

//Read register data


//Write data in register
always @(posedge clk, posedge rst)
begin
    if(rst) for(int index=0;index<32;index++)regs[index]<=32'b0;//all register reset to 0 
    else if(RegWrite && Write_reg != 5'b0_0000&&!FloatRegWrite ) regs[Write_reg]<=Write_data;
    else regs[Write_reg]<=regs[Write_reg];    
end

always @(posedge clk, posedge rst)
begin
    if(rst) for(int index=0;index<32;index++)floatregisters[index]<=32'b0;//all register reset to 0 
    else if(FloatRegWrite&&RegWrite) floatregisters[Write_reg]<=Write_data;   
    else  floatregisters[Write_reg]<=floatregisters[Write_reg];       
end

assign Read_data1 = (Opcode==7'b1010011)?floatregisters[Read_reg1]:regs[Read_reg1];
assign Read_data2 = (Opcode==7'b1010011||Opcode==7'b0100111)?floatregisters[Read_reg2]:regs[Read_reg2];
assign Read_data1_after_forward=(RegWrite&&Write_reg==Read_reg1||FloatRegWrite&&Write_reg==Read_reg1)?Write_data:Read_data1;
assign Read_data2_after_forward=(RegWrite&&Write_reg==Read_reg2||FloatRegWrite&&Write_reg==Read_reg2)?Write_data:Read_data2;
endmodule
