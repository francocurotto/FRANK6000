#!/usr/bin/env python
import sys, time
from serial import *

try:
    filename = sys.argv[1]
except:
    filename = "Tests/01_move.hex"

print "Transmitting " + filename + "..."
inputFile = open(filename, 'r')

ser = Serial(port='/dev/ttyUSB1',
             baudrate = 115200, 
             bytesize = EIGHTBITS, 
             parity   = PARITY_NONE, 
             stopbits = STOPBITS_ONE)
             #rtscts=True, dsrdtr=True)

for line in inputFile:
    ser.write(bytearray.fromhex(line[2:4]+line[0:2]))
    time.sleep(0.1)


