module PC_MUX_2(in1,in2,in3,out);

input in3;
input [31:0] in1,in2;
output logic [31:0] out;


assign out=(in3)?in1:in2+32'd4;

endmodule                 