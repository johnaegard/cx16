#!/usr/bin/env python3

import random

MAP_TRUE_WIDTH = 64
MAP_TRUE_HEIGHT = 64
NUM_NONBLANK_TILES = 64
NUM_COLORS = 16
BLANK_TILE_RATE_L0 = 0.93
BLANK_TILE_INDEX = 64
BLANK_TILE_RATE_L1 = 0.95

def tile_coord(col,row):
  return 2 * (row * MAP_TRUE_WIDTH + col)

def color_coord(col,row):
  return 2 * (row * MAP_TRUE_WIDTH + col) +1 

def random_tile(blank_tile_rate): 
  if random.random() < blank_tile_rate:
    return BLANK_TILE_INDEX
  else:
    return random.randrange(0,NUM_NONBLANK_TILES)

def make_map(blank_tile_rate):
  buffer = [255] * (MAP_TRUE_HEIGHT * MAP_TRUE_WIDTH * 2)
  for col in range(0,MAP_TRUE_WIDTH):
    for row in range(0,MAP_TRUE_HEIGHT):
      buffer[tile_coord(col,row)] = random_tile(blank_tile_rate) 
      buffer[color_coord(col,row)] = random.randrange(1,NUM_COLORS)
  return buffer

l0_buffer = make_map(BLANK_TILE_RATE_L0)
f = open("MAP0.BIN", "wb")
f.write(bytearray([0,0]))
f.write(bytearray(l0_buffer))
f.close()

l1_buffer = make_map(BLANK_TILE_RATE_L1)
f = open("MAP1.BIN", "wb")
f.write(bytearray([0,0]))
f.write(bytearray(l1_buffer))
f.close()