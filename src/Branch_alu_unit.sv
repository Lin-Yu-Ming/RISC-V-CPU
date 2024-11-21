`timescale 1ns / 1ps



//localparam op = 4'b1111;

module Branch_alu_unit(Branch_flag,Branch_alu_op,Branch_in,in1,in2 ,opcode );

output logic Branch_flag;

input [31:0]in1,in2;      //32bit
input [2:0]Branch_alu_op; //4bit
input Branch_in;
input [6:0]opcode;

localparam EequalOP = 3'b000; //BEQ ==
localparam NotEequalOP = 3'b001; //BNE !=
localparam SmallerSignOP = 3'b100; //BLT s<s
localparam GreaterEqualSignOP = 3'b101; //BGE s>=s
localparam SmallerUnignOP = 3'b110; //BLTU u<u
localparam GreaterEqualUnsignOP = 3'b111; //BGEU u>=u
logic branch_alu_result;

always_comb
begin
    if(Branch_in)
    begin
        unique case(Branch_alu_op)
            EequalOP: branch_alu_result = (in1 == in2)? 1'b1:1'b0;
            NotEequalOP: branch_alu_result = (in1 != in2)? 1'b1:1'b0;
            SmallerSignOP: branch_alu_result = ($signed(in1) < $signed(in2))? 1'b1:1'b0;
            GreaterEqualSignOP: branch_alu_result = ($signed(in1) >= $signed(in2))? 1'b1:1'b0;
            SmallerUnignOP: branch_alu_result = ($unsigned(in1) < $unsigned(in2))? 1'b1:1'b0;
            GreaterEqualUnsignOP: branch_alu_result = ($unsigned(in1) >= $unsigned(in2))? 1'b1:1'b0;
            default: branch_alu_result = 1'b0;//default
        endcase
    end
    else
        branch_alu_result = 1'b0;
end

assign Branch_flag=(opcode==7'b1101111 || opcode==7'b1100111)?1'b1: branch_alu_result & Branch_in;


endmodule

