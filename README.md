# RISC-V-CPU


# Spec

Implement the 49 instructions as listed.

General register File size: 32x32-bit

Floating point register File size: 32x32-bit

Instruction memory size: 16Kx32-bit

Data memory size: 16Kx32-bit


# Explain


本次CUP設計主要為5 stage pipeline的架構，如圖所示，分別為IF(Instruction Fetch)、ID(Instruction Decode)、EX(Execution)、MEM(Memory Access)和WB(Write Back)。在IF階段時，PC會決定從哪裡提取下一條要執行的指令，將address傳遞給Instruction Memory，根據提供的 PC 地址，提取一條指令並傳遞IFID  pipeline，且PC輸出透過一個加法器進行 PC+4的動作，來指向下一條指令的地址。在ID階段時，將提取的指令傳遞到Control Unit、 Registers file、Immediate Unit進行解碼，首先指令解碼後，Control Unit會產生8條控制訊號線，分別有ALUSrc、MemtoReg、RegWrite、MemRead、MemWrite、Branch、ALUop、FloatRegWrite，這些訊號線為控制相對應的module進行寫入、讀出或是運算，而Registers裡包含一般暫存器和浮點數暫存器，會透過opcode分辨從Registers讀出的data是從浮點數暫存器讀出或是從一般暫存器讀出，進行下一步運算，而當寫回暫存器的data則是從Control Unit解碼後的RegWrite和FloatRegWrite來分辨是寫入哪個暫存器。在EX階段時，對於存入的指令，會透過Store Memory Control Unit將數據寫入到Data memory，而ALU Control Unit會透過IDEX  pipeline所傳遞的ALUop進行所需運算的分類，從而給出相對應控制訊號給ALU，此時ALU會根據收到的訊號進行像加法、減法、左移、右移….等，本次作業比較特別的是要進行浮點數的加、減法，並且符合IEEE754浮點數運算規則，Fig4.為浮點數運算演算法實現流程圖，首先會先透過exponent決定是否正規化，再來透過比較exponent大小進行右移位的動作，較小的exponent會對齊大的exponent，對齊完後，透過sign bit決定最終的運算，運算完後的值須進行正規化還原，最後再進行四捨五入的判斷得到最終的值。在MEM階段時，Load Memory Control Unit為讀取memory的controller，如果指令是Load指令，這個stage會讀取Data Memory位址的data。
        在WB階段時， ALU 的計算結果或從Data memory中讀取的數據會透過多工器的控制，將數據寫回Register file中，供後續指令使用。
         本次設計可以有效解決Data hazard、Control hazard、Structure hazard的問題。
         在Data hazard處理的部分中，指令之間的相互依賴關係會導致Data hazard的問題，為了有效地處理這些問題，在設計中使用Forwarding Control和stall機制來解決此問題。利用Forwarding Control  unit 去判斷當前指令的來源暫存器rs1和 rs2 是否是前一指令的目標寄存器 rd。如果是，Forwarding Control  unit會發出控制信號，通知Forwarding controller選擇正確的數據路徑，將前面的計算結果直接傳遞給後續指令，這樣可以避免等待WB階段寫回資料的延遲，但是並非所有Data hazard都可以通過Forwarding來解決，像load-use的指令無法通過Forwarding解決，此時會透過Hazard Detection Unit 給出stall訊號暫停一個週期，好讓指令的數據完成讀取。
        在Control hazard的部分透過Hazard Detection Unit、Branch alu unit和Branch forwarding unit進行判斷，在執行跳轉指令時，會先透過Branch alu unit 計算目標地址並判斷分支條件是否成立，根據運算結果，如果確定需要跳轉，處理器會發出相應的跳轉控制信號，此時Hazard Detection Unit會根據此訊號向PC_mux發出控制信號，這個控制信號決定PC是否需要更新，並選擇新的跳轉目標地址，在確定跳轉後，會清空這些指令，可以避免由於錯誤的分支預測或跳轉而導致的無效指令執行，並保證整體的正確性。當所有必要的清空操作完成後，新的跳轉目標地址就會被加載到PC中，處理器開始從新的位置繼續執行正確的指令。

