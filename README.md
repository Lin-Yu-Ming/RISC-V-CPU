# RISC-V-CPU


#Spec

Implement the 49 instructions as listed.

General register File size: 32x32-bit

Floating point register File size: 32x32-bit

Instruction memory size: 16Kx32-bit

Data memory size: 16Kx32-bit


#Explain


本次CUP設計主要為5 stage pipeline的架構，如Fig3.所示，分別為IF(Instruction Fetch)、ID(Instruction Decode)、EX(Execution)、MEM(Memory Access)和WB(Write Back)。在IF階段時，PC會決定從哪裡提取下一條要執行的指令，將address傳遞給Instruction Memory，根據提供的 PC 地址，提取一條指令並傳遞IFID  pipeline，且PC輸出透過一個加法器進行 PC+4的動作，來指向下一條指令的地址。在ID階段時，將提取的指令傳遞到Control Unit、 Registers file、Immediate Unit進行解碼，首先指令解碼後，Control Unit會產生8條控制訊號線，分別有ALUSrc、MemtoReg、RegWrite、MemRead、MemWrite、Branch、ALUop、FloatRegWrite，這些訊號線為控制相對應的module進行寫入、讀出或是運算，而Registers裡包含一般暫存器和浮點數暫存器，會透過opcode分辨從Registers讀出的data是從浮點數暫存器讀出或是從一般暫存器讀出，進行下一步運算，而當寫回暫存器的data則是從Control Unit解碼後的RegWrite和FloatRegWrite來分辨是寫入哪個暫存器。在EX階段時，對於存入的指令，會透過Store Memory Control Unit將數據寫入到Data memory，而ALU Control Unit會透過IDEX  pipeline所傳遞的ALUop進行所需運算的分類，從而給出相對應控制訊號給ALU，此時ALU會根據收到的訊號進行像加法、減法、左移、右移….等，本次作業比較特別的是要進行浮點數的加、減法，並且符合IEEE754浮點數運算規則，Fig4.為浮點數運算演算法實現流程圖，首先會先透過exponent決定是否正規化，再來透過比較exponent大小進行右移位的動作，較小的exponent會對齊大的exponent，對齊完後，透過sign bit決定最終的運算，運算完後的值須進行正規化還原，最後再進行四捨五入的判斷得到最終的值。
