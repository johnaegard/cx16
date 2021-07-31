#!/usr/bin/env python3

f = open("TILES.BIN", "wb")

buffer = []

for px_row in range(0,8):
  for px_col in range(7,-1,-1):
    for byte in range(0,8):
      if byte == px_row:
        buffer.append(2**px_col)
      else:
        buffer.append(0)

# blank tile
for zeros in range(0,16):
  buffer.append(0)

f.write(bytearray(buffer))
f.close()