#! env python3

# open file
f = open("TILES.BIN", "wb")

buffer = []

for px_row in range(0,8):
  for px_col in range(7,-1,-1):
    for byte in range(0,8):
      if byte == px_row:
        buffer.append(2**px_col)
      else:
        buffer.append(0)

# fill out the tile list with 192 extra blank tiles.
# this is inefficient from a RAM standpoint but
# makes the random starfield a bit easier to code.

for blank in range(0,192):
  for zeros in range(0,8):
    buffer.append(0)

f.write(bytearray(buffer))
f.close()