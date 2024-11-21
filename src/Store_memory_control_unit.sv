`timescale 1ns / 1ps
module Store_memory_control_unit(write_data_hb_out,Write_enble_bit, 
              is_store, funct3,bit_address, data_in,Write_enble);
output logic[31:0] write_data_hb_out;
output logic Write_enble;
output logic[31:0] Write_enble_bit;
logic [31:0]write_en;
input is_store;
input [2:0]funct3;
input [1:0]bit_address;
input [31:0]data_in;

always_comb
begin
  begin
    unique case({funct3[1:0], bit_address})
      4'b00_00://SB 
        begin
          write_data_hb_out = {24'b0,data_in[7:0]};
          write_en = 32'hffffff00;
        end
      4'b00_01://SB
        begin
          write_data_hb_out = {16'b0,data_in[7:0],8'b0};
          write_en = 32'hffff00ff;
        end
      4'b00_10://SB
        begin
          write_data_hb_out = {8'b0,data_in[7:0],16'b0};
          write_en = 32'hff00ffff;
        end
      4'b00_11://SB
        begin
          write_data_hb_out = {data_in[7:0],24'b0};
          write_en = 32'h00ffffff;
        end
      4'b01_00://SH
        begin
          write_data_hb_out = {16'b0,data_in[15:0]};
           write_en = 32'hffff0000;
        end  
      4'b01_10://SH
        begin
          write_data_hb_out = {data_in[15:0],16'b0};
          write_en = 32'h0000ffff;
        end 
      default://SW(010)
        begin
          write_data_hb_out = data_in;
          write_en = 32'h00000000;
        end
    endcase
  end
end

assign Write_enble_bit = (is_store)? write_en:32'b1111;
assign Write_enble=(is_store)?1'b0:1'b1;


endmodule
