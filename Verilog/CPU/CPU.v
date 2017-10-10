// CPU for FRANK6000 processor
`include "../Instruction_Stack/Instruction_Stack.v"
`include "../Register/Register.v"
`include "../RAM/RAM.v"
`include "../ALU/ALU_macro.v"
`include "../ALU/ALU.v"
`include "../Jump_Control/Jump_Control.v"
`include "../Control_Unit/Control_Unit_macro.v"
`include "../Control_Unit/Control_Unit.v"

module CPU (
    input  [15:0] i_instr,
    input   [7:0] i_instr_addr,
    input         i_ON, i_clk, i_rst, i_we,
    output  [7:0] o_WREG,
    output        o_loopf,
    output  [7:0] o_debug);

    // Control Unit
    wire [3:0] w_control;
    wire       w_jump, w_call, w_rtrn, w_ADDRin, w_FRin, w_ALUin1, w_ALUin2, w_PCw, w_ADDRw, w_FRw, w_WREGw, w_STATUSw;
    wire [1:0] w_j_mode, w_WREGin;
    Control_Unit Control_Unit (.control_input(w_control), .rst(i_rst), .clk(i_clk), .jump(w_jump), .j_mode(w_j_mode), .call(w_call), .return(w_rtrn), .ADDRin(w_ADDRin), .FRin(w_FRin), .WREGin(w_WREGin), .ALUin1(w_ALUin1), .ALUin2(w_ALUin2), .PCw (w_PCw), .ADDRw(w_ADDRw), .FRw(w_FRw), .WREGw(w_WREGw), .STATUSw(w_STATUSw));

    // Instruction Stack
    wire [7:0] w_PC;
    wire [7:0] w_stack;
    Instruction_Stack #(.addr_width(4), .data_width(8)) 
        Instruction_Stack (.i_PC(w_PC), .call(w_call), .rtrn(w_rtrn), .rst(i_rst), .clk(i_clk), .o_Stack(w_stack));

    // Program Counter
    wire [7:0] w_PC_next;
    Register #(.width(8)) 
        PC (.D(w_PC_next), .clk(i_clk), .rst(i_rst), .we(w_PCw), .Q(w_PC));

    // Next Program Counter Logic
    wire [15:0] w_instr_ON;
    wire        w_jump_flag;
    wire  [7:0] w_pi;
    wire  [7:0] w_PC_plus_1 = w_PC + 8'b1;
    wire  [7:0] w_PC_jump   = (w_jump_flag==0) ? w_PC_plus_1 :
                           /*(w_jump_flag==1)*/ w_instr_ON[7:0];
    assign w_PC_next = (w_j_mode==0) ? w_PC_plus_1 :
                       (w_j_mode==1) ? w_PC_jump   :                       
                       (w_j_mode==2) ? w_stack     :                       
                     /*(w_j_mode==3)*/ 8'bx; // never happens

    // Instruction Memory
    wire [15:0] w_instr;
    wire  [7:0] w_instr_addr;
    RAM #(.addr_width(8), .data_width(16))
        Instr_Mem (.addr(w_instr_addr), .din(i_instr), .clk(i_clk), .we(i_we), .dout(w_instr));
    assign w_instr_addr = i_ON ? w_PC : i_instr_addr;
    assign w_instr_ON   = i_ON ? w_instr : 16'b0; 
    assign w_control    = w_instr_ON[15:12];
    assign w_pi         = w_instr_ON[7:0];

    // Jump Control
    wire [2:0] w_STATUS;
    wire [1:0] w_jump_opcode = w_instr_ON[9:8];
    wire w_jump_control;
    Jump_Control Jump_Control (.opcode(w_jump_opcode), .status(w_STATUS), .jump(w_jump_control));
    assign w_jump_flag = w_jump & w_jump_control;

    // ADDR Register
    wire [7:0] w_WREG;
    wire [7:0] w_ALU_res;
    wire [7:0] w_ADDR_next;
    wire [7:0] w_ADDR;
    Register #(.width(8)) 
        ADDR (.D(w_ADDR_next), .clk(i_clk), .rst(i_rst), .we(w_ADDRw), .Q(w_ADDR));
    assign w_ADDR_next = (w_ADDRin==0) ? w_WREG :  
                       /*(w_ADDRin==1)*/ w_ALU_res;
    
    // File Registers (Data Memory)
    wire [7:0] w_FR_addr;
    wire [7:0] w_FR;
    RAM #(.addr_width(8), .data_width(8)) 
        File_Registers (.addr(w_FR_addr), .din(w_WREG), .clk(i_clk), .we(w_FRw), .dout(w_FR));
    assign w_FR_addr = (w_FRin==0) ? w_pi :
                     /*(w_FRin==1)*/ w_ADDR;

    // WREG (Working Register)
    wire [7:0] w_WREG_next;
    Register #(.width(8)) 
        WREG (.D(w_WREG_next), .clk(i_clk), .rst(i_rst), .we(w_WREGw), .Q(w_WREG));
    assign w_WREG_next = (w_WREGin==0) ? w_ALU_res :
                         (w_WREGin==1) ? w_pi      :                       
                         (w_WREGin==2) ? w_FR      :                       
                       /*(w_WREGin==3)*/ w_ADDR;

    // ALU (Arithmetic Logic Unit)
    wire [3:0] w_ALU_opcode = w_instr_ON[11:8];
    wire [7:0] w_ALU_WA;
    wire [7:0] w_ALU_pi;
    wire [2:0] w_ALU_status;
    ALU ALU (.opcode(w_ALU_opcode), .WREG(w_ALU_WA), .p(w_ALU_pi), .res(w_ALU_res), .status(w_ALU_status));
    assign w_ALU_WA = (w_ALUin1==0) ? w_WREG :
                    /*(w_ALUin1==1)*/ w_ADDR;
    assign w_ALU_pi = (w_ALUin2==0) ? w_pi :
                    /*(w_ALUin2==1)*/ w_FR;

    // STATUS Register
    Register #(.width(3)) 
        STATUS (.D(w_ALU_status), .clk(i_clk), .rst(i_rst), .we(w_STATUSw), .Q(w_STATUS));

    assign o_WREG  = w_WREG;
    assign o_loopf = (~|w_instr_ON) & i_ON;
    assign o_debug = w_PC;

endmodule
