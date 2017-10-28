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
    input   [7:0] i_instr_addr,
    input  [15:0] i_instr,
    input         i_ON, i_instr_we, i_control_en, i_clk, i_rst, 
    output  [7:0] o_WREG,
    output        o_loopf);

    // Control Unit
    wire [15:0] w_instr;
    wire [3:0]  w_control;
    wire        w_jump;
    wire        w_call;
    wire        w_rtrn;
    wire        w_ADDRin;
    wire        w_FRin;
    wire        w_ALUin1;
    wire        w_ALUin2;
    wire        w_PCw;
    wire        w_ADDRw;
    wire        w_FRw;
    wire        w_WREGw;
    wire        w_STATUSw;
    wire [1:0]  w_j_mode;
    wire [1:0]  w_WREGin;
    Control_Unit Control_Unit (
        .i_control_input (w_instr[15:12]), 
        .i_clk           (i_clk), 
        .i_en            (i_control_en),
        .i_rst           (i_rst), 
        .o_jump          (w_jump), 
        .o_j_mode        (w_j_mode), 
        .o_call          (w_call), 
        .o_return        (w_rtrn),
        .o_ADDRin        (w_ADDRin), 
        .o_FRin          (w_FRin), 
        .o_WREGin        (w_WREGin), 
        .o_ALUin1        (w_ALUin1), 
        .o_ALUin2        (w_ALUin2), 
        .o_PCw           (w_PCw), 
        .o_ADDRw         (w_ADDRw), 
        .o_FRw           (w_FRw), 
        .o_WREGw         (w_WREGw), 
        .o_STATUSw       (w_STATUSw));

    // Instruction Stack
    wire [7:0] w_PC;
    wire [7:0] w_stack;
    Instruction_Stack #(
        .ADDR_WIDTH(4), 
        .DATA_WIDTH(8)) Instruction_Stack (
            .i_PC    (w_PC), 
            .i_call  (w_call), 
            .i_rtrn  (w_rtrn), 
            .i_rst   (i_rst), 
            .i_clk   (i_clk), 
            .o_stack (w_stack));

    // Program Counter
    wire [7:0] w_PC_next;
    Register #(.WIDTH(8)) PC (
        .i_D   (w_PC_next), 
        .i_clk (i_clk), 
        .i_rst (i_rst), 
        .i_we  (w_PCw), 
        .or_Q  (w_PC));

    // Next Program Counter Logic
    wire       w_jump_flag;
    wire [7:0] w_PC_plus_1 = w_PC + 8'b1;
    wire [7:0] w_PC_jump   = (w_jump_flag==0) ? w_PC_plus_1 :
                           /*(w_jump_flag==1)*/ w_instr[7:0];

    assign w_PC_next = (w_j_mode==0) ? w_PC_plus_1 :
                       (w_j_mode==1) ? w_PC_jump   :                       
                       (w_j_mode==2) ? w_stack     :                       
                     /*(w_j_mode==3)*/ 8'bx; // never happens

    // Instruction Memory
    wire  [7:0] w_instr_addr = i_ON ? w_PC : i_instr_addr;
    RAM #(
        .ADDR_WIDTH( 8), 
        .DATA_WIDTH(16)) Instruction_Memory (
            .i_addr  (w_instr_addr), 
            .i_data  (i_instr), 
            .i_clk   (i_clk), 
            .i_we    (i_instr_we), 
            .or_data (w_instr));

    // Jump Control
    wire [2:0] w_STATUS;
    wire [1:0] w_jump_opcode = w_instr[9:8];
    wire       w_jump_control;
    Jump_Control Jump_Control (
        .i_opcode (w_jump_opcode),
        .i_status (w_STATUS), 
        .o_jump   (w_jump_control));

    assign w_jump_flag = w_jump & w_jump_control;

    // ADDR Register
    wire [7:0] w_WREG;
    wire [7:0] w_ALU_res;
    wire [7:0] w_ADDR_next;
    wire [7:0] w_ADDR;
    Register #(.WIDTH(8)) ADDR (
        .i_D   (w_ADDR_next), 
        .i_clk (i_clk), 
        .i_rst (i_rst), 
        .i_we  (w_ADDRw), 
        .or_Q  (w_ADDR));
    assign w_ADDR_next = (w_ADDRin==0) ? w_WREG :  
                       /*(w_ADDRin==1)*/ w_ALU_res;
    
    // File Registers (Data Memory)
    wire [7:0] w_FR_addr;
    wire [7:0] w_FR;
    RAM #(
        .ADDR_WIDTH(8), 
        .DATA_WIDTH(8)) File_Registers (
            .i_addr  (w_FR_addr), 
            .i_data  (w_WREG), 
            .i_clk   (i_clk), 
            .i_we    (w_FRw), 
            .or_data (w_FR));

    assign w_FR_addr = (w_FRin==0) ? w_instr[7:0] :
                     /*(w_FRin==1)*/ w_ADDR;

    // WREG (Working Register)
    wire [7:0] w_WREG_next;
    Register #(.WIDTH(8))  WREG (
        .i_D   (w_WREG_next), 
        .i_clk (i_clk), 
        .i_rst (i_rst), 
        .i_we  (w_WREGw), 
        .or_Q  (w_WREG));

    assign w_WREG_next = (w_WREGin==0) ? w_ALU_res    :
                         (w_WREGin==1) ? w_instr[7:0] :                       
                         (w_WREGin==2) ? w_FR         :                       
                       /*(w_WREGin==3)*/ w_ADDR;

    // ALU (Arithmetic Logic Unit)
    wire [3:0] w_ALU_opcode = w_instr[11:8];
    wire [7:0] w_ALU_WREG_ADDR;
    wire [7:0] w_ALU_imm_reg;
    wire [2:0] w_ALU_status;
    ALU ALU (
        .i_opcode (w_ALU_opcode),
        .i_oper1  (w_ALU_WREG_ADDR), 
        .i_oper2  (w_ALU_imm_reg), 
        .o_res    (w_ALU_res), 
        .o_status (w_ALU_status));

    assign w_ALU_WREG_ADDR = (w_ALUin1==0) ? w_WREG :
                           /*(w_ALUin1==1)*/ w_ADDR;
    assign w_ALU_imm_reg   = (w_ALUin2==0) ? w_instr[7:0] :
                           /*(w_ALUin2==1)*/ w_FR;

    // STATUS Register
    Register #(.WIDTH(3)) STATUS (
        .i_D   (w_ALU_status), 
        .i_clk (i_clk), 
        .i_rst (i_rst), 
        .i_we  (w_STATUSw), 
        .or_Q  (w_STATUS));

    assign o_WREG  = w_WREG;
    assign o_loopf = ~|w_instr & i_ON;

endmodule
