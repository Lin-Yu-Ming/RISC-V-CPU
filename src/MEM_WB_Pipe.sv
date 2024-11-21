`timescale 1ns / 1ps




module MEM_WB_Pipe(
            //output
            RegWrite_out,FloatRegWrite_out,
            Rd_out,
			MemtoReg_out,data_after_HB_out, alu_result_out,
            //input
            RegWrite_in,FloatRegWrite_in,
            Rd_in,
			MemtoReg_in,data_after_HB_in,alu_result_in,
            rst,clk,
            );

output logic RegWrite_out,FloatRegWrite_out;//WB     
output logic [4:0]Rd_out;
output logic [31:0]data_after_HB_out, alu_result_out;
output logic MemtoReg_out;

input RegWrite_in,FloatRegWrite_in;
input [4:0]Rd_in;
input MemtoReg_in;
input [31:0]data_after_HB_in,alu_result_in;

input clk,rst;    

always@(posedge rst,posedge clk)
begin
    if(rst)begin
        Rd_out <= 5'd0;
        RegWrite_out <= 1'd0;
        FloatRegWrite_out<=1'd0;
		data_after_HB_out<= 32'd0;
		alu_result_out<= 32'd0;
		MemtoReg_out<=1'd0;
    end
    else begin
        Rd_out<=Rd_in;
        RegWrite_out<=RegWrite_in; 
        FloatRegWrite_out<=FloatRegWrite_in;
		data_after_HB_out<= data_after_HB_in;
		alu_result_out<= alu_result_in;
		MemtoReg_out<=MemtoReg_in;
    end
end
endmodule



