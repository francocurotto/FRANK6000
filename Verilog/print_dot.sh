for file in "ALU/ALU.v" "Control_Unit/Control_Unit.v" "CPU/CPU.v" "Instruction_Stack/Instruction_Stack.v" "Jump_Control/Jump_Control.v" "PC_Instr_Mem/PC_Instr_Mem.v" "RAM/RAM.v" "Register/Register.v" 
do
    basename=${file##*/}
    basename=${basename%.*}
    yosys -p "prep; show -stretch -prefix ${file%.*} -format dot $basename" $file
done
