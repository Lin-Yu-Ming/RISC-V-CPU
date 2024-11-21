module Instruction_Address(in1,in2,in3,out);

input in3;
input [13:0] in1,in2;
output logic [13:0] out;


assign out=(in3)?in1:in2;

endmodule      