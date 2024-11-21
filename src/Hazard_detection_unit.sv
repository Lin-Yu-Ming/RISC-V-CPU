`timescale 1ns / 1ps

module Hazard_detection_unit( 
                            //output
                            stall, 
                            //input
                            EXMEM_MemRead, EXMEM_RegisterRd, 
                            IDEX_MemRead, IDEX_RegisterRd, 
                            IFID_RegisterRs1, IFID_RegisterRs2, 
                            Branch,
                            flag,
                            IDEX_Stall);

output logic stall;


input EXMEM_MemRead;
input [4:0]EXMEM_RegisterRd;
input IDEX_MemRead;
input [4:0]IDEX_RegisterRd;
input [4:0]IFID_RegisterRs1;
input [4:0]IFID_RegisterRs2;
input Branch;//from IFIDout
input IDEX_Stall;
input [31:0]flag;
//logic flag1;
//assign flag1=(flag==32'd0)?1'b0:1'b0;

always_comb
begin
    if(flag==32'd0) stall = 1'b0;
    else if( ( (IDEX_MemRead) || (Branch && !IDEX_Stall) )
	  &&( (IDEX_RegisterRd == IFID_RegisterRs1) || (IDEX_RegisterRd == IFID_RegisterRs2) )  ) //stall the pipeline   (alu||branch) && ()
	    begin
	        stall = 1'b1;
      end
    else if( EXMEM_MemRead && Branch
	      &&( (EXMEM_RegisterRd == IFID_RegisterRs1) || (EXMEM_RegisterRd == IFID_RegisterRs2) )  ) //stall the pipeline  -->new for branch
	    begin
	        stall = 1'b1;
      end
    else   //work
      begin
          stall = 1'b0;
      end
end  
endmodule


