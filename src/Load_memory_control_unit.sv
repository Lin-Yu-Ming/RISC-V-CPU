`timescale 1ns / 1ps


module Load_memory_control_unit(read_memory_data_after_HB, is_load, funct3, read_memory_data);
output reg[31:0] read_memory_data_after_HB;
input is_load;
input [2:0]funct3;
input [31:0]read_memory_data;

always_comb
begin
   if(is_load)
    begin
      unique case(funct3)
        3'b000: read_memory_data_after_HB = {{24{read_memory_data[7]}}, read_memory_data[7:0]};//LB funct3=000
        3'b001: read_memory_data_after_HB = {{16{read_memory_data[15]}}, read_memory_data[15:0]};//LH funct3=001
        3'b101: read_memory_data_after_HB = {16'd0, read_memory_data[15:0]};//LHU funct3=101
        3'b100: read_memory_data_after_HB = {24'd0, read_memory_data[7:0]};//LBU funct3=100
        default: read_memory_data_after_HB = read_memory_data;
      endcase
    end
  else
    read_memory_data_after_HB = 32'b0;
end

endmodule
