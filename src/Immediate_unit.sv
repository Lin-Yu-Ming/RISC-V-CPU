`timescale 1ns / 1ps


module Immediate_unit(out, in);
output reg[31:0]out;
input [31:0]in;

always_comb
begin
    unique case(in[6:0])
      7'b0000011: out = {{20{in[31]}}, in[31:20]}; //Itype:other 
      7'b0000111: out = {{20{in[31]}}, in[31:20]};//FLW
      7'b0100111: out = {{20{in[31]}}, in[31:25], in[11:7]}; //FSW
	7'b0010011: out = {{20{in[31]}}, in[31:20]}; //Itype:other
      7'b1100111: out = {{20{in[31]}}, in[31:20]}; //Itype:JALR
      7'b0100011: out = {{20{in[31]}}, in[31:25], in[11:7]}; //Stype
      7'b1100011: out = {{19{in[31]}}, in[31], in[7], in[30:25], in[11:8], 1'b0}; //Btype
      7'b0010111: out = {in[31:12], 12'd0}; //Utype
	7'b0110111: out = {in[31:12], 12'd0}; //Utype
      7'b1101111: out = {{11{in[31]}}, in[31],in[19:12],in[20],in[30:21],1'b0};//Jtype 
      default: out = 32'd0;
    endcase
    
end

endmodule
