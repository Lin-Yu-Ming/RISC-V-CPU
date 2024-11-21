`timescale 1ns / 1ps
//---------IF Stage------------
`include "./PC.sv"
`include "./PC_MUX_2.sv"
`include "./CSR_counter.sv"
`include "./Instruction_Address.sv"

//---------ID Stage------------
`include "./Registers.sv"
`include "./Control_unit.sv"
`include "./Immediate_unit.sv"
`include "./Hazard_detection_unit.sv"
`include "./Branch_alu_unit.sv"
`include "./Branch_forward_unit.sv"
`include "./CSR_unit.sv"

//---------EX Stage------------
`include "./ALU_control_unit.sv"
`include "./ALU.sv"
`include "./Forwarding_unit.sv"
`include "./Forward_controller.sv"
`include "./Store_memory_control_unit.sv"

//---------MEM Stage------------
`include "./Load_memory_control_unit.sv"
//---------WB Stage------------


//---------Pipeline------------
`include "./IF_ID_Pipe.sv"
`include "./ID_EX_Pipe.sv"
`include "./EX_MEM_Pipe.sv"
`include "./MEM_WB_Pipe.sv"

module CPU (clk, rst,
  //IM
  InstructionAddress,
  instruction,
  //DM
  Write_enble,
  Write_enble_bit,
  Data_address,
  DataMemory_in,
  DataMemory_out
  );

output logic[31:0] DataMemory_in;
output logic [13:0]InstructionAddress;
output logic Write_enble;
output logic [13:0] Data_address;
output logic [31:0] Write_enble_bit;

input clk,rst;
input logic [31:0]instruction;
input logic[31:0] DataMemory_out;

//---------IF Stage------------
logic PC_Src;
logic [31:0]currentPC,nextPC,PC_target_address,Add4_out;
logic [63:0]cycle,instr;

//---------IFID Pipeline------------
logic IF_flush;
logic [31:0]PC_IFIDout,instruction_IFIDout;
logic [63:0]cycle_IFIDout,instr_IFIDout;

//---------ID Stage------------
logic Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite,FloatRegWrite;
logic [1:0] ALUOp;
logic [31:0] immediate32;
logic [31:0] read_data1,read_data2;
logic Branch_after_stall_controller, MemRead_after_stall_controller, MemtoReg_after_stall_controller, MemWrite_after_stall_controller, ALUSrc_after_stall_controller, RegWrite_after_stall_controller,FloatReg_after_stall_controller;//hazard detection unit
logic [1:0] ALUOp_after_stall_controller;//hazard detection unit
logic stall;//hazard detection unit
logic [4:0]rd;
logic [4:0]funct_code;
logic branch_flag;
logic [1:0] branch_forwardA,branch_forwardB;
logic [31:0] branch_alu_data1,branch_alu_data2;
logic [4:0] read_reg1,read_reg2;
logic [31:0]read_data1_reg_out,read_data2_reg_out;
logic [31:0]read_data1_after_forward,read_data2_after_forward;
logic [5:0] alu_operation;//6bit

//---------IDEX Pipeline------------
logic Branch_IDEXout, MemRead_IDEXout, MemtoReg_IDEXout, MemWrite_IDEXout, ALUSrc_IDEXout, RegWrite_IDEXout,FloatRegWrite_IDEXout;//control
logic [1:0] ALUOp_IDEXout; //control
logic [31:0] PC_IDEXout;
logic [31:0] read_data1_IDEXout,read_data2_IDEXout;
logic [31:0] immediate32_IDEXout;
logic [4:0]rd_IDEXout;
logic [4:0]funct_code_IDEXout;
logic [4:0]rs1_IDEXout,rs2_IDEXout;//hazard
logic [6:0]opcode_IDEXout;
logic stall_IDEXout;
logic [5:0] alu_operation_IDEXout;
logic [31:0]instruction_IDEXout;
logic [1:0]forwardA_flag,forwardB_flag;
logic [1:0]forwardA_IDEX_out,forwardB_IDEX_out;

//---------EX Stage------------
logic [31:0] PC_add_immediate;
logic [31:0] alu_result, alu_result_basic;
logic [31:0] alu_data1_forward,alu_data2_forward,alu_data2_forward_EXMEM;
logic [31:0] alu_data1_select,alu_data2_select;
logic [31:0]UJtype_data;
logic UJtype_data_control;

//---------EXMEM Pipeline------------
logic Branch_EXMEMout, MemtoReg_EXMEMout, MemWrite_EXMEMout, RegWrite_EXMEMout,FloatRegWrite_EXMEMout;
logic [31:0] PC_add_immediate_EXMEMout;
logic [31:0] alu_result_EXMEMout;
logic [4:0]rd_EXMEMout;
logic [2:0] funct3_EXMEMout;

logic [31:0]instruction_EXMEMout;

//---------MEM Stage------------
logic [31:0] read_memory_data;
logic [31:0]read_memory_data_after_HB;

//---------MEMWB Pipeline------------
logic RegWrite_MEMWBout,FloatRegWrite_MEMWBout;
logic [4:0]rd_MEMWBout;

logic [31:0]data_after_HB_MEMWBout,alu_result_MEMWBout;

//---------WB Stage------------
logic MemtoReg_MEMWBout;
logic [31:0]WB_data;




//---------IF Stage------------
PC pc(.Current_PC(currentPC), .Next_PC(nextPC), .clk(clk), .rst(rst) , .PC_write(!stall));
PC_MUX_2 pc_mux_2(.in1(PC_target_address),.in2(currentPC),.in3(PC_Src),.out(nextPC));
Instruction_Address instruction_address(.in1(nextPC[15:2]),.in2(currentPC[15:2]),.in3(!stall),.out(InstructionAddress));
CSR_counter csr_counter(.CLK(clk),.RST(rst),.in1(stall),.in2(IF_flush),.out1(cycle),.out2(instr));

//---------IFID Pipeline------------
IF_ID_Pipe if_id_pipe(//output
            .PC_out(PC_IFIDout), .Instruction_out(instruction_IFIDout),
            .cycle_out(cycle_IFIDout), .instr_out(instr_IFIDout),
            //input
            .PC_in(currentPC), .Instruction_in(instruction),
            .cycle_in(cycle), .instr_in(instr),
            .IFID_write(!stall),//hazard detection out
            .IF_flush(IF_flush),//branch flush
            .clk(clk), .rst(rst));


//---------ID Stage------------
assign funct_code = {instruction_IFIDout[30],instruction_IFIDout[25],instruction_IFIDout[14:12]};//5bit
assign rd = instruction_IFIDout[11:7];//5bit
assign read_reg1 = instruction_IFIDout[19:15];
assign read_reg2 = instruction_IFIDout[24:20];

CSR_unit csr_unit(.instruction_in(instruction_IFIDout),.Instructions(instr_IFIDout),.Cycle(cycle_IFIDout),
                  .data_in1(read_data1_after_forward),.data_in2(read_data2_after_forward),.data_out1(read_data1),
				  .data_out2(read_data2));

Control_unit control_uint(.Branch(Branch), .MemRead(MemRead), .MemtoReg(MemtoReg), .ALUOp(ALUOp), .MemWrite(MemWrite), .ALUSrc(ALUSrc), .RegWrite(RegWrite),.FloatRegWrite(FloatRegWrite), 
                .OpCode(instruction_IFIDout[6:0]));
//after_stall_controller
assign Branch_after_stall_controller = (stall)? 1'b0:Branch;
assign MemRead_after_stall_controller = (stall)? 1'b0:MemRead;
assign MemtoReg_after_stall_controller = (stall)? 1'b0:MemtoReg;
assign MemWrite_after_stall_controller = (stall)? 1'b0:MemWrite;
assign ALUSrc_after_stall_controller = (stall)? 1'b0:ALUSrc;
assign RegWrite_after_stall_controller = (stall)? 1'b0:RegWrite;
assign FloatReg_after_stall_controller =(stall)?1'b0:FloatRegWrite;
assign ALUOp_after_stall_controller = (stall)? 2'b11:ALUOp;

Registers registers(
                //output
                .Read_data1(read_data1_reg_out),.Read_data2(read_data2_reg_out),.Read_data1_after_forward(read_data1_after_forward),
                .Read_data2_after_forward(read_data2_after_forward),				
                //input
                .Read_reg1(read_reg1), .Read_reg2(read_reg2), //rs1,rs2
                .RegWrite(RegWrite_MEMWBout),.FloatRegWrite(FloatRegWrite_MEMWBout),
                .Write_reg(rd_MEMWBout), .Write_data(WB_data),.Opcode(instruction_IFIDout[6:0]),
                .clk(clk), .rst(rst));

Immediate_unit immediate_unit(.out(immediate32), .in(instruction_IFIDout));

Hazard_detection_unit Hazard_Detection_Unit( 
                          //output
                          .stall(stall),
                          //input 
                          .EXMEM_MemRead(MemRead_EXMEMout), .EXMEM_RegisterRd(rd_EXMEMout), 
                          .IDEX_MemRead(MemRead_IDEXout),.IDEX_RegisterRd(rd_IDEXout),
                          .IFID_RegisterRs1(instruction_IFIDout[19:15]), .IFID_RegisterRs2(instruction_IFIDout[24:20]),
                          .Branch(Branch),
                          .IDEX_Stall(stall_IDEXout),.flag(currentPC));


Branch_forward_unit branch_forward_unit(
          //output
          .Branch_alu_data1(branch_alu_data1),.Branch_alu_data2(branch_alu_data2), 
           //input 
          .read_data1(read_data1),	
          .read_data2(read_data2),
          .ALU_result_EXMEMout(alu_result_EXMEMout),	        
          .WB_data(WB_data),
          .IFID_RegisterRs1(read_reg1),
          .IFID_RegisterRs2(read_reg2),
          .EXMEM_RegWrite(RegWrite_EXMEMout),
          .EXMEM_RegisterRd(rd_EXMEMout),
          .MEMWB_RegWrite(RegWrite_MEMWBout),
          .MEMWB_RegisterRd(rd_MEMWBout),
          .Branch_in(Branch_after_stall_controller));

Branch_alu_unit branch_alu_unit(.Branch_flag(branch_flag),
                     .Branch_alu_op(instruction_IFIDout[14:12]),.Branch_in(Branch_after_stall_controller),
                     .in1(branch_alu_data1), .in2(branch_alu_data2),
                     .opcode(instruction_IFIDout[6:0]));


assign PC_Src = branch_flag;
assign IF_flush = branch_flag;
assign PC_target_address=(instruction_IFIDout[6:0]==7'b1100111)?branch_alu_data1+immediate32:PC_IFIDout+immediate32;



//---------IDEX Pipeline------------
ID_EX_Pipe id_ex_pipe(
            //output
           	.ALUSrc_out(ALUSrc_IDEXout),.MemtoReg_out (MemtoReg_IDEXout),.RegWrite_out(RegWrite_IDEXout),.FloatRegWrite_out(FloatRegWrite_IDEXout),.MemRead_out(MemRead_IDEXout),.MemWrite_out(MemWrite_IDEXout),
			.Branch_out(Branch_IDEXout),.ALUOp_out(ALUOp_IDEXout), //control_out
            .PC_out(PC_IDEXout),
            .Read_data1_out(read_data1_IDEXout),.Read_data2_out(read_data2_IDEXout),
            .Immediate_out(immediate32_IDEXout),
            .Rd_out(rd_IDEXout),
			.funct_code_out(funct_code_IDEXout),
			.Rs1_out(rs1_IDEXout),.Rs2_out(rs2_IDEXout), //hazard out
            .op_code_out(opcode_IDEXout),
            .stall_out(stall_IDEXout),
            .forwardA_out(forwardA_IDEX_out), .forwardB_out(forwardB_IDEX_out),
            .Instruction_IDEXout(instruction_IDEXout),
			
            //input
            .ALUSrc_in(ALUSrc_after_stall_controller),.MemtoReg_in(MemtoReg_after_stall_controller),.RegWrite_in(RegWrite_after_stall_controller),.FloatRegWrite_in(FloatReg_after_stall_controller),.MemRead_in(MemRead_after_stall_controller),.MemWrite_in(MemWrite_after_stall_controller),
			.Branch_in(Branch_after_stall_controller),.ALUOp_in(ALUOp_after_stall_controller), 
            .PC_in(PC_IFIDout),
            .Read_data1_in(read_data1), .Read_data2_in(read_data2),
            .Immediate_in(immediate32),
            .Rd_in(rd), 
			.funct_code_in(funct_code),
			.Rs1_in(read_reg1), .Rs2_in(read_reg2), //hazard out
            .op_code_in(instruction_IFIDout[6:0]),
            .stall_in(stall),
            .forwardA_in(forwardA_flag), .forwardB_in(forwardB_flag),
			.instruction_IDEXin(instruction_IFIDout),
			
            .clk(clk),.rst(rst)
            );
			
//---------EX Stage------------
Forwarding_unit forwarding_unit(
          //output
          .ForwardA_flag(forwardA_flag),
          .ForwardB_flag(forwardB_flag),
          //input control
          .IFID_Rs1(read_reg1),
          .IFID_Rs2(read_reg2),
          .IDEX_RegWrite(RegWrite_IDEXout),
          .IDEX_RegisterRd(rd_IDEXout),
          .EXMEM_RegWrite(RegWrite_EXMEMout),
          .EXMEM_RegisterRd(rd_EXMEMout),
		  //input signal	
		  .instruction_in(instruction_IFIDout),
		  .instruction_IDEXout(instruction_IDEXout),
		  .instruction_EXMEMout(instruction_EXMEMout)
					);


Forward_controller forward_controller (.ForwardA_flag(forwardA_IDEX_out),.ForwardB_flag(forwardB_IDEX_out),.Writeback_data_from_pipeline(WB_data),
                                       .alu_result_EXMEMout(alu_result_EXMEMout),.read_data1_IDEXout(read_data1_IDEXout),.read_data2_IDEXout(read_data2_IDEXout),
									   .data1(alu_data1_forward),.data2(alu_data2_forward),.Opcode_IDEXout(opcode_IDEXout),.PC_IDEXout(PC_IDEXout),
									   .Immediate32_IDEXout(immediate32_IDEXout),.Alu_data1_select(alu_data1_select),.Alu_data2_select(alu_data2_select),.ALUSrc_IDEXout(ALUSrc_IDEXout));



ALU_control_unit alu_control_unit(.ALU_operation(alu_operation), .ALUOp(ALUOp_IDEXout), .FunctCode(funct_code_IDEXout),.instruction(instruction_IDEXout));

ALU alu(//output
        .ALU_result(alu_result),
        //input
        .ALU_operation(alu_operation),.in1_select(alu_data1_select),.in2_select(alu_data2_select));
        
//SW/SB/SH
assign Data_address  = alu_result[15:2];

Store_memory_control_unit store_memory_control_unit(.write_data_hb_out(DataMemory_in),.Write_enble_bit(Write_enble_bit),.Write_enble(Write_enble),
        .is_store(MemWrite_IDEXout), .funct3(funct_code_IDEXout[2:0]), .bit_address(alu_result[1:0]), .data_in(alu_data2_forward));
		
//---------EXMEM Pipeline------------
EX_MEM_Pipe ex_mem_pipe(
            //output
            .MemtoReg_out(MemtoReg_EXMEMout),.RegWrite_out(RegWrite_EXMEMout),.FloatRegWrite_out(FloatRegWrite_EXMEMout),.MemRead_out(MemRead_EXMEMout),.MemWrite_out( MemWrite_EXMEMout),
            .ALU_out(alu_result_EXMEMout),
            .Rd_out(rd_EXMEMout),
            .funct3_out(funct3_EXMEMout),
			.Instruction_out(instruction_EXMEMout),
            //input
            .MemtoReg_in( MemtoReg_IDEXout),.RegWrite_in(RegWrite_IDEXout),.FloatRegWrite_in(FloatRegWrite_IDEXout),.MemRead_in( MemRead_IDEXout),.MemWrite_in(MemWrite_IDEXout),
            .ALU_in(alu_result),
            .Rd_in(rd_IDEXout),
            .funct3_in(funct_code_IDEXout[2:0]),
			.Instruction_in(instruction_IDEXout),
            .clk(clk),.rst(rst)
            );

//---------MEM Stage------------
Load_memory_control_unit load_memory_control_unit(.read_memory_data_after_HB(read_memory_data_after_HB), .is_load(MemRead_EXMEMout), 
                .funct3(funct3_EXMEMout), .read_memory_data(DataMemory_out));


//---------MEMWB Pipeline------------
MEM_WB_Pipe mem_wb_pipe(
            //output
            .RegWrite_out(RegWrite_MEMWBout),.FloatRegWrite_out(FloatRegWrite_MEMWBout),
            .Rd_out(rd_MEMWBout),
            .MemtoReg_out(MemtoReg_MEMWBout),.data_after_HB_out(data_after_HB_MEMWBout), .alu_result_out(alu_result_MEMWBout),
            
            //input
            .RegWrite_in(RegWrite_EXMEMout),.FloatRegWrite_in(FloatRegWrite_EXMEMout),
            .Rd_in(rd_EXMEMout),
            .MemtoReg_in(MemtoReg_EXMEMout),.data_after_HB_in(read_memory_data_after_HB),.alu_result_in(alu_result_EXMEMout),
            .rst(rst), .clk(clk)
            );

//---------WB Stage------------
assign WB_data =  (MemtoReg_MEMWBout)? data_after_HB_MEMWBout:alu_result_MEMWBout;

endmodule



