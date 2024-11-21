`timescale 1ns / 1ps
module ALU(ALU_result, ALU_operation, in1_select, in2_select);
          
output logic [31:0]ALU_result;
input [31:0]in1_select,in2_select; //32bit
input [5:0]ALU_operation; //6bit


localparam ANDop = 6'b00_0000;
localparam ORop = 6'b00_0001;
localparam ADDop = 6'b00_0010;
localparam SUBop = 6'b00_0110;
localparam XORop = 6'b00_0111 ;
localparam AlgoShiftRightUnsignedop = 6'b00_1001;
localparam AlgoShiftRightSignedop = 6'b00_1010;
localparam LogicShiftLeftop = 6'b00_1011;
localparam LogicShiftRightUnsignedop = 6'b00_1100;
localparam LogicShiftRightSignedop = 6'b00_1101;

localparam MULop = 6'b01_0000;
localparam MULHop = 6'b01_0001;
localparam MULHSUop = 6'b01_0010;
localparam MULHUop = 6'b01_0011;

localparam FADDop = 6'b11_0000;//fadd
localparam FSUBop = 6'b11_0001;//fsub

logic [31:0]ALU_result_basic;
always_comb
begin
    if(!ALU_operation[4]&&!ALU_operation[5])//00
      begin
        unique case(ALU_operation)
            ANDop: ALU_result_basic = in1_select & in2_select;//and
            ORop : ALU_result_basic = in1_select | in2_select;//or
            ADDop: ALU_result_basic = in1_select + in2_select;//add
            SUBop: ALU_result_basic = in1_select - in2_select;//substract
            XORop: ALU_result_basic = in1_select ^ in2_select;
            AlgoShiftRightUnsignedop: ALU_result_basic = ($unsigned(in1_select) < $unsigned(in2_select))? 32'd1:32'd0;//sltu
            AlgoShiftRightSignedop: ALU_result_basic = ($signed(in1_select) < $signed(in2_select))? 32'd1:32'd0;//slt
            LogicShiftLeftop: ALU_result_basic = in1_select << in2_select[4:0];
            LogicShiftRightUnsignedop: ALU_result_basic = in1_select >> in2_select[4:0];
            LogicShiftRightSignedop: ALU_result_basic = $signed(in1_select) >>> in2_select[4:0];

            default: ALU_result_basic = 32'd0;//default
        endcase
      end
    else
      ALU_result_basic = 32'h0000_0000;
end


logic [31:0]ALU_result_mul;
logic [65:0]mul_result_sign;
logic [32:0]Mul1,Mul2;

always_comb
begin
    if(ALU_operation[4]&&!ALU_operation[5])//01
      begin
		unique case (ALU_operation)
		    MULop:begin
                Mul1 = {1'b0,in1_select};
                Mul2 = {1'b0,in2_select};
            end
		    MULHop:begin
		        Mul1 = {in1_select[31],in1_select};
		        Mul2 = {in2_select[31],in2_select};
		    end
		    MULHSUop:begin
                Mul1 = {in1_select[31],in1_select};
                Mul2 = {1'b0,in2_select};//sign * unsign
            end
		    MULHUop:begin
                Mul1 = {1'b0,in1_select};
                Mul2 = {1'b0,in2_select};
            end
		    default:begin
		        Mul1 = 33'd0;
		        Mul2 = 33'd0;
		    end
		endcase
      
        mul_result_sign = {{33{Mul1[32]}},$signed(Mul1)} * {{33{Mul2[32]}},$signed(Mul2)};
      
		unique case(ALU_operation)
		    MULop:ALU_result_mul = mul_result_sign[31:0];
			MULHop:ALU_result_mul = mul_result_sign[63:32];
			MULHSUop:ALU_result_mul = mul_result_sign[63:32];
			MULHUop:ALU_result_mul = mul_result_sign[63:32];
			default:ALU_result_mul = 32'd0;
		endcase
      end
    else
    begin
      Mul1 = 33'd0;
      Mul2 = 33'd0;
	    mul_result_sign = 66'd0;
      ALU_result_mul = 32'd0;
    end
end

logic sign1,sign2,final_sign;
logic [7:0] exponet1,exponet2,diff,tmp_exponet,final_exponet;
logic signed [7:0]exponet_add,left_shift;
logic [22:0] fraction1,fraction2, final_fraction;
logic [23:0] nor_fraction1,nor_fraction2;
logic [29:0] extend_nor_fraction1,extend_nor_fraction2;
logic [30:0] tmp_extend_nor_fraction;
logic [31:0]ALU_result_float;

always_comb begin  //11 {sign,exponet[7:0],fraction[22:0]}
  if (ALU_operation[4]&&ALU_operation[5]) begin
    exponet_add=8'd0;
    left_shift=8'd0;
	final_sign=1'b0;
	sign1=1'b0;
	sign2=1'b0;
	exponet1=8'd0;
	exponet2=8'd0;
	diff=8'd0;
	tmp_exponet=8'd0;
	final_exponet=8'd0;
	fraction1=23'd0;
	fraction2=23'd0;
	final_fraction=23'd0;
	nor_fraction1=24'd0;
	nor_fraction2=24'd0;
	extend_nor_fraction1=30'd0;
	extend_nor_fraction2=30'd0;
	tmp_extend_nor_fraction=31'd0;
	ALU_result_float=32'd0;
	
    sign1=in1_select[31];
    sign2=in2_select[31]; 
    exponet1=in1_select[30:23];
    exponet2=in2_select[30:23]; 
    fraction1=in1_select[22:0];
    fraction2=in2_select[22:0];
    diff=(exponet1>exponet2)?exponet1-exponet2:exponet2-exponet1;
    nor_fraction1=(exponet1!=8'd0)?{1'b1,fraction1}:{1'b0,fraction1};
    nor_fraction2=(exponet2!=8'd0)?{1'b1,fraction2}:{1'b0,fraction2};
    if(exponet1>exponet2)begin
        extend_nor_fraction2={nor_fraction2,6'd0}>>diff; //{nor_fraction[23:0],23'b0}
        extend_nor_fraction1={nor_fraction1,6'd0};
    end
    else begin
        extend_nor_fraction1={nor_fraction1,6'd0}>>diff;
        extend_nor_fraction2={nor_fraction2,6'd0};
    end
    case (ALU_operation)
      FADDop:begin
          if(sign1==sign2)begin//11,00
              tmp_extend_nor_fraction=extend_nor_fraction1+extend_nor_fraction2;
              final_sign=sign1;
              tmp_exponet=exponet1;
          end
          else  begin //01,10        
              if (extend_nor_fraction1>extend_nor_fraction2)begin
                  tmp_extend_nor_fraction={1'b0,(extend_nor_fraction1-extend_nor_fraction2)};
                  tmp_exponet=exponet1;
                  final_sign=sign1;  
              end
              else begin   
                  tmp_extend_nor_fraction={1'b0,(extend_nor_fraction2-extend_nor_fraction1)};
                  tmp_exponet=exponet2;
                  final_sign=sign2;  
              end 
          end
      end

      FSUBop:begin
          if(!sign1&&!sign2)begin//00
              if (extend_nor_fraction1>extend_nor_fraction2)begin
                  tmp_extend_nor_fraction={1'b0,(extend_nor_fraction1-extend_nor_fraction2)};
                  tmp_exponet=exponet1;
                  final_sign=sign1;  
              end
              else begin   
                  tmp_extend_nor_fraction={1'b0,(extend_nor_fraction2-extend_nor_fraction1)};
                  tmp_exponet=exponet2;
                  final_sign=sign2;  
              end 
          end
          else if (sign1&&sign2)begin //11
               if (extend_nor_fraction1>extend_nor_fraction2)begin
                  tmp_extend_nor_fraction={1'b0,(extend_nor_fraction1-extend_nor_fraction2)};
                  tmp_exponet=exponet1;
                  final_sign=sign1;  
              end
              else begin   //extend_nor_fraction1<extend_nor_fraction2
                  tmp_extend_nor_fraction={1'b0,(extend_nor_fraction2-extend_nor_fraction1)};
                  tmp_exponet=exponet2;
                  final_sign=1'b0;  
              end 
          end
          else if (!sign1&&sign2) begin //01        
              if (extend_nor_fraction1>extend_nor_fraction2)begin
                  tmp_extend_nor_fraction=extend_nor_fraction1+extend_nor_fraction2;
                  tmp_exponet=exponet1;
                  final_sign=sign1;  
              end
              else begin //extend_nor_fraction1<extend_nor_fraction2  
                  tmp_extend_nor_fraction=extend_nor_fraction2+extend_nor_fraction1;
                  tmp_exponet=exponet2;
                  final_sign=sign1;  
              end 
          end

          else  begin //10        
              if (extend_nor_fraction1>extend_nor_fraction2)begin
                  tmp_extend_nor_fraction=extend_nor_fraction1+extend_nor_fraction2;
                  tmp_exponet=exponet1;
                  final_sign=sign1;  
              end
              else begin //extend_nor_fraction1<extend_nor_fraction2  
                  tmp_extend_nor_fraction=extend_nor_fraction2+extend_nor_fraction1;
                  tmp_exponet=exponet2;
                  final_sign=sign1;  
              end 
          end


      end
      
      default:ALU_result_float = 32'd0; 
    endcase
    if (tmp_extend_nor_fraction[30]&&tmp_extend_nor_fraction[29]) begin  //1,1     
            exponet_add=8'd1;                                                           
            left_shift=8'd1;                                                            
    end
    else if (tmp_extend_nor_fraction[30]&&!tmp_extend_nor_fraction[29])begin //1,0
        exponet_add=8'd1;
        left_shift=8'd1;
    end
    else if (!tmp_extend_nor_fraction[30]&&tmp_extend_nor_fraction[29]) begin//0,1
        exponet_add=8'd0;
        left_shift=8'd0;
    end
    else begin
        if (tmp_extend_nor_fraction[28]) begin
            exponet_add=8'b1111_1111;
            left_shift=8'd1;
        end
        else if (tmp_extend_nor_fraction[27]) begin
            exponet_add=8'b1111_1110;
            left_shift=8'd2;
        end
        else  begin
            exponet_add=8'b1111_1101;
            left_shift=8'd3;
        end  
    end 

      
    tmp_extend_nor_fraction=(tmp_extend_nor_fraction[30]&&tmp_extend_nor_fraction[29]||
                        tmp_extend_nor_fraction[30]&&!tmp_extend_nor_fraction[29])?tmp_extend_nor_fraction>>left_shift:
                                                                                  tmp_extend_nor_fraction<<left_shift;           ;

    if (tmp_extend_nor_fraction[5]&&(|tmp_extend_nor_fraction[4:0])) begin
        final_fraction=tmp_extend_nor_fraction[28:6]+23'b1; 
    end
    else if (tmp_extend_nor_fraction[5]&&!(|tmp_extend_nor_fraction[4:0]))begin
        if (tmp_extend_nor_fraction[6]) final_fraction=tmp_extend_nor_fraction[28:6]+23'b1;
        else final_fraction=tmp_extend_nor_fraction[28:6];  
    end 
    else final_fraction=tmp_extend_nor_fraction[28:6];

    final_exponet=tmp_exponet+exponet_add;
    ALU_result_float={final_sign,final_exponet,final_fraction};

  end
  else begin
      ALU_result_float = 32'd0;
      sign1=1'd0;
      sign2=1'd0;
      final_sign=1'd0;
      exponet1=8'd0;
      exponet2=8'd0;
      diff=8'd0;
      left_shift=8'd0;
      tmp_exponet=8'd0;
      final_exponet=8'd0;
      exponet_add=8'd0;
      
      fraction1=23'd0;
      fraction2=23'd0;
      nor_fraction1=24'd0;
      nor_fraction2=24'd0;
      final_fraction=23'd0;
      extend_nor_fraction1=30'd0;
      extend_nor_fraction2=30'd0;
      tmp_extend_nor_fraction=31'd0;
  end
      
end

assign ALU_result =(ALU_operation[4]&&ALU_operation[5]) ? ALU_result_float:(ALU_operation[4]&&!ALU_operation[5])?
       ALU_result_mul : ALU_result_basic;

endmodule

