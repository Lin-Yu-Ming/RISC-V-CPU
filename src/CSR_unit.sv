module CSR_unit(instruction_in,Instructions,Cycle,data_in1,data_in2,data_out1,data_out2);
output logic[31:0]data_out1,data_out2;

input[63:0] Instructions,Cycle;
input [31:0] data_in1,data_in2;
input [31:0]instruction_in;

always_comb //1->need branch 0->no need branch
begin
  if(instruction_in[6:0]==7'b1110011) //CSR
    begin
      case({instruction_in[27],instruction_in[21]})
        2'b11:data_out1 = Instructions[63:32];
        2'b01:data_out1 = Instructions[31:0];
        2'b10:data_out1 = Cycle[63:32];
        2'b00:data_out1 = Cycle[31:0]+32'd4;
      endcase
    end
  else //branch
    data_out1 = data_in1;
end
assign data_out2 = data_in2;

endmodule
