module Forward_controller(
          //output
          data1, data2,
          //input control
		  ForwardA_flag,ForwardB_flag,
		  Writeback_data_from_pipeline,alu_result_EXMEMout,
		  read_data1_IDEXout,read_data2_IDEXout,Opcode_IDEXout,Alu_data1_select,Alu_data2_select,
		  PC_IDEXout,Immediate32_IDEXout,ALUSrc_IDEXout
       );


output logic [31:0] data1, data2,Alu_data1_select,Alu_data2_select;

input ALUSrc_IDEXout;
input [6:0] Opcode_IDEXout;
input [1:0]ForwardA_flag,ForwardB_flag;
input [31:0]Writeback_data_from_pipeline, alu_result_EXMEMout;
input [31:0]read_data1_IDEXout, read_data2_IDEXout,PC_IDEXout,Immediate32_IDEXout;

always_comb
  begin
    if(ForwardA_flag==2'b01)data1 = alu_result_EXMEMout;//data from EX/MEM ,from last alu out 
    else if(ForwardA_flag==2'b10) data1 = Writeback_data_from_pipeline;//data from MEM/WB ,from data memory or prior alu result
    else  data1 = read_data1_IDEXout;
      
	if(  (Opcode_IDEXout == 7'b0010111)//Utype-AUIPC rd = PC+imm
     ||(Opcode_IDEXout == 7'b1101111)//Jtype-JAL rd=PC+4;PC=PC+imm
     ||(Opcode_IDEXout == 7'b1100111))//Itype-JALR rd=PC+4;PC=rs1+imm   
    Alu_data1_select = PC_IDEXout;
    else if(Opcode_IDEXout == 7'b0110111)Alu_data1_select = 32'b0; //Utype-LUI rd = imm
    else Alu_data1_select = data1;
       
  end

//2-3 MUX forwardB
always_comb
  begin 
    if(ForwardB_flag==2'b01)data2 = alu_result_EXMEMout;//data from EX/MEM ,from last alu out 
    else if(ForwardB_flag==2'b10)data2 = Writeback_data_from_pipeline;//data from MEM/WB ,from data memory or prior alu result
    else data2 = read_data2_IDEXout;
        
     if(   (Opcode_IDEXout == 7'b0010111) //Utype-AUIPC rd = PC+imm
      ||(Opcode_IDEXout == 7'b0110111)) //Utype-LUI rd = imm  
    Alu_data2_select = Immediate32_IDEXout;
    else if(   (Opcode_IDEXout == 7'b1101111)//Jtype-JAL rd=PC+4;PC=PC+imm
            || (Opcode_IDEXout == 7'b1100111))//Itype-JALR rd=PC+4;PC=rs1+imm 
      Alu_data2_select = 32'd4;
    else if(Opcode_IDEXout == 7'b1110011) Alu_data2_select = 32'd0;  //CSR
    else if(ALUSrc_IDEXout) Alu_data2_select = Immediate32_IDEXout;
    else Alu_data2_select = data2;
  end
  
endmodule
