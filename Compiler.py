#!/usr/bin/env python
import sys, os, string, traceback

def main():
    # list of command lines
    commandLines = []
    
    # handle input file to compile    
    fSrc, fLgs, fHex = handleInput()
    
    # header
    fLgs.write("v2.0 raw\n")
    
    # 1st loop get assignments and labels
    for lineNum, line in enumerate(fSrc):
        # add new line if not present
        if line[-1] is not "\n":
            line = line + "\n"
        try:
            processLine(line, lineNum+1, commandLines)
        except:
            print "Error at trying to process line " + str(lineNum) + ":\n" + line
            print traceback.format_exc()
            os.remove(fLgs.name)
            os.remove(fHex.name)
            exit()
            
    
    # 2do loop compile command lines
    for [command, lineNum] in commandLines:
        try:
            hexCommand = compileCommand(command)
        except:
            print "Error at trying to compile line " + str(lineNum) + ":\n" + command
            print traceback.format_exc()
            os.remove(fLgs.name)
            os.remove(fHex.name)
            exit()
        fLgs.write(hexCommand)
        fHex.write(hexCommand)
    
    print "Compilation Successful!"
            
    # close files
    fSrc.close()
    fLgs.close()
    fHex.close()
    
def handleInput():
    try:
        srcPath = sys.argv[1]
        fileList = os.path.splitext(srcPath)
        lgsPath = fileList[0] + ".lgs"
        hexPath = fileList[0] + ".hex"
    except:
        print "Usage: ./Compiler.py input-path"
        exit()
    
    print "Compiling " + srcPath + "..."
    fSrc = open(srcPath, "r")
    fLgs = open(lgsPath, "w")
    fHex = open(hexPath, "w")
    
    return fSrc, fLgs, fHex
    
def processLine(line, lineNum, commandLines):
    # remove comments
    lineWithoutComments = line[:string.find(line, "#")]
    # strip whitespaces
    strippedLine = lineWithoutComments.strip()
    # all upercase
    upperLine = strippedLine.upper()
    
    # condition line type
    # empty line
    if upperLine == "":
        return
    # command, assign or label line
    else:
        wordList = upperLine.split()
        command = wordList[0]
        if command == "ASSGN":
            processAssign(wordList)
        elif command == "LABEL":
            processLabel(wordList, lineCounter)
        else:
            processCommand(upperLine, lineNum, commandLines)

# assigments
def processAssign(wordList):
    if not isCommandDefined(wordList[1]):
        assignments[wordList[1]] = wordList[2]
    else:
        print "Command aready defined, either is a keyword or you already defined that label/asssignment"
        exit()
    
# labels
def processLabel(wordList, lineCounter):
    if not isCommandDefined(wordList[1]):
        labels[wordList[1]] = str(lineCounter)
    else:
        print "Command aready defined, either is a keyword or you already defined that label/asssignment"
        exit()
        
# process command
def processCommand(line, lineNum, commandLines):
    global lineCounter
    lineCounter += 1
    if lineCounter > MAX_INSTRUCTIONS:
        print "Maximum number of intructions ("+str(MAX_INSTRUCTIONS)+")  exceeded"
        exit()
    commandLines.append([line, lineNum])
        
# check if command is already defined
def isCommandDefined(command):
    return command in R0_commands or command in R1_commands or \
    command in R2_commands or command in B_commands or \
    command in J_commands or command in assignments or \
    command in labels 
        
# compile command
def compileCommand(commandLine):
    wordList = commandLine.split()
    binaryLine = ""
    command = wordList[0]
    
    if command in R0_commands:
        binaryLine = compileR0command(wordList)
    elif command in R1_commands:
        binaryLine = compileR1command(wordList)
    elif command in R2_commands:
        binaryLine = compileR2command(wordList)
    elif command in B_commands:
        binaryLine = compileBcommand(wordList)
    elif command in J_commands:
        binaryLine = compileJcommand(wordList)
    else:
        print "Command not recognized:\n" + commandLine
        exit()
        
    binaryLine = binaryLine.replace(" ", "")    
    compiledLine = "{0:04x}".format(int(binaryLine, 2)) + "\n"
        
    return compiledLine

# compile R0-command
def compileR0command(wordList):
    global stackCounter
    if wordList[0] == "RETRN":
        stackCounter -= 1
    return R0_commands[wordList[0]].replace(" ", "")
    
# compile R1-command
def compileR1command(wordList):
    param = parseParam(wordList[1], assignments, VAR_CONST_LIMITS)
    opcode = R1_commands[wordList[0]]
    return opcode + param
    
# compile R2-command
def compileR2command(wordList):
    src = SRC_dict[wordList[1]]
    param = parseParam(wordList[2], assignments, VAR_CONST_LIMITS)
    opcodeList = R2_commands[wordList[0]]
    return opcodeList[0] + src + opcodeList[1] + param
    
# compile B-command
def compileBcommand(wordList):
    param = parseParam(wordList[1], assignments, BITS_LIMITS)
    opcode = B_commands[wordList[0]]
    return opcode + param
    
# compile J-command
def compileJcommand(wordList):
    global stackCounter
    if wordList[0] == "CALLS":
        stackCounter += 1
        if stackCounter > MAX_STACK:
            print "Stack overflow"
            end()
    param = parseParam(wordList[1], labels, [0, MAX_INSTRUCTIONS-1])
    opcodeList = J_commands[wordList[0]]
    return opcodeList + param

# parse parameters
def parseParam(param, numDict, limits):
    try:
        if param in numDict:
            decParam = int(numDict[param], 0)
        else:
            decParam = int(param, 0)
    except:
        print "Couldn't understand varaible or constant " + param
        exit() 
    if decParam < limits[0] or decParam > limits[1]:
        print "Parameter out of bound. Use a paramenter between " + str(limits)
        exit()
    return "{0:08b}".format(decParam)

# global parameters
lineCounter = 0
stackCounter = 0
MAX_INSTRUCTIONS = 256
VAR_CONST_LIMITS = [0, 255]
BITS_LIMITS = [0, 7]
MAX_STACK = 16

assignments = {}
labels = {}    
    
R0_commands = {
    "CPYWA" : "100 0 0000 0000 0000",
    "CPYAW" : "110 1 0000 0000 0000",
    "CPYWR" : "100 1 0000 0000 0000",
    "CPYRW" : "110 0 0000 0000 0000",
    "ZEROW" : "010 0 0000 0000 0000",
    "BNOTW" : "010 0 0001 0000 0000",
    "NEGTW" : "010 0 0010 0000 0000",
    "INCRW" : "010 0 0011 0000 0000",
    "DECRW" : "010 0 0100 0000 0000",
    "ZEROA" : "011 0 0000 0000 0000",
    "INCRA" : "011 0 0011 0000 0000",
    "DECRA" : "011 0 0100 0000 0000",
    "RETRN" : "001 1 0000 0000 0000",
    "NOOPR" : "011 1 0000 0000 0000",
    "LOOPF" : "000 0 0000 0000 0000"}
    
R1_commands = {
    "CPYWP" : "101 1 0000"}
    
R2_commands = {
    "CPYPW" : ["111", "0000"],
    "ANDWP" : ["010", "0101"],
    "IORWP" : ["010", "0110"],
    "XORWP" : ["010", "0111"],
    "ADDWP" : ["010", "1000"],
    "SUBWP" : ["010", "1001"],
    "CMPWP" : ["010", "1010"]}
    
B_commands = {
    "SHFLW" : "010 0 1011",
    "SHFRW" : "010 0 1100"}
    
J_commands = {
    "GOTOI" : "000 1 0000",
    "GTIFZ" : "000 1 0001",
    "GTIFN" : "000 1 0010",
    "GTIFC" : "000 1 0011",
    "CALLS" : "001 0 0000"}
    
SRC_dict = {
    "IMM" : "0",
    "FLR" : "1"}

if __name__ == "__main__":
    main()
