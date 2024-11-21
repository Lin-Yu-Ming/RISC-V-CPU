`timescale 1ns / 1ps



module Branch_forward_unit(
                    //output
					Branch_alu_data1,Branch_alu_data2, 

					//input MUX 
					read_data1,	
					read_data2,
					ALU_result_EXMEMout,	
					WB_data,
					
                    //input
                    IFID_RegisterRs1,
                    IFID_RegisterRs2,
                    EXMEM_RegWrite,
                    EXMEM_RegisterRd,
                    MEMWB_RegWrite,
                    MEMWB_RegisterRd,
					Branch_in);




reg [1:0]forwardA;
reg [1:0]forwardB;

output reg [31:0]Branch_alu_data1,Branch_alu_data2;

input [31:0]read_data1;
input [31:0]read_data2;
input [31:0]ALU_result_EXMEMout;	
input [31:0]WB_data;



input [4:0]IFID_RegisterRs1;
input [4:0]IFID_RegisterRs2;
input EXMEM_RegWrite;
input [4:0]EXMEM_RegisterRd;
input MEMWB_RegWrite;
input [4:0]MEMWB_RegisterRd;
input Branch_in;


always_comb
begin
	  if (Branch_in&&(EXMEM_RegWrite==1'b1)&& (EXMEM_RegisterRd!=5'd0)
	     &&(EXMEM_RegisterRd==IFID_RegisterRs1))Branch_alu_data1=ALU_result_EXMEMout;//MEM   
	  else if(Branch_in&&(MEMWB_RegWrite==1'b1)&&(MEMWB_RegisterRd!=5'd0)
         &&(MEMWB_RegisterRd==IFID_RegisterRs1))Branch_alu_data1=WB_data;
	  else Branch_alu_data1=read_data1;   
end 


always_comb
begin	    
	  //control forwardB
	  if (Branch_in&&(EXMEM_RegWrite==1'b1)&&(EXMEM_RegisterRd!=5'd0) 
        &&(EXMEM_RegisterRd==IFID_RegisterRs2))Branch_alu_data2 = ALU_result_EXMEMout;
	  else if(Branch_in&&(MEMWB_RegWrite==1'b1)&&(MEMWB_RegisterRd!=5'd0)
        && (MEMWB_RegisterRd==IFID_RegisterRs2))Branch_alu_data2=WB_data;
	  else Branch_alu_data2 = read_data2;
	    
end  

endmodule
