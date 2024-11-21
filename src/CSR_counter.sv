module CSR_counter(CLK,RST,in1,in2,out1,out2);
    
    input CLK,RST,in1,in2;

     output logic [63:0] out1,out2;

    logic last_rst;
    //cycle & instr 
    always@(posedge CLK or posedge RST)
    begin
      if(RST)begin
        out1 <=64'd0;
        last_rst <= 1'b0;
    end
    else begin
        out1 <= out1 + 64'd1;
        last_rst <= 1'b1;
    end
    end
    always@(posedge CLK or posedge RST)
    begin
      if(RST)out2 <=64'd0; 
      else if (~last_rst)out2 <= out2;
      else if(in1)out2 <= out2; 
      else if(in2)out2 <= out2;  
      else out2 <= out2 + 64'd1;  
    end
endmodule