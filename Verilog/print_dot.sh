for file in "ALU/ALU.v" "Bin_2_7Seg/Bin_2_7Seg.v" "Control_Unit/Control_Unit.v" "CPU/CPU.v" "Debounce_Switch/Debounce_Switch.v" "FRANK6000/FRANK6000.v" "Instr_RX/Instr_RX.v" "Instruction_Stack/Instruction_Stack.v" "Jump_Control/Jump_Control.v" "RAM/RAM.v" "Register/Register.v" 
do
    basename=${file##*/}
    basename=${basename%.*}
    yosys -p "prep; show -stretch -prefix ${file%.*} -format dot $basename" $file
done
