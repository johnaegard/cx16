#!/usr/bin/env python3
contents = [0,0]
contents = contents + ([0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef] * 128)
contents = contents + ([0xff] * 128)
f = open("WHTSQ.BIN", "wb")
f.write(bytearray(contents))
f.close()