#!/usr/bin/env python3

import random

MAP_TRUE_WIDTH = 128
MAP_TRUE_HEIGHT = 128
MAP_WIDTH = 120
MAP_HEIGHT = 90
NUM_TILES = 65
NUM_COLORS = 16

def in_northwest(col,row):
  return col < 40 and row < 30

def in_north(col,row):
  return col >= 40 and col < 80 and row < 30

def in_west(col,row):
  return col < 40 and row >= 30 and row < 60

def in_center(col,row):
  return col >= 40 and col < 80 and row >= 30 and row < 60

def tile_coord(col,row):
  return 2 * (row * MAP_TRUE_WIDTH + col)

def color_coord(col,row):
  return 2 * (row * MAP_TRUE_WIDTH + col) +1 

buffer = [255] * (MAP_TRUE_HEIGHT * MAP_TRUE_WIDTH * 2)

for col in range(0,MAP_WIDTH):
  for row in range(0,MAP_HEIGHT):
    tile_index = random.randrange(0,NUM_TILES)
    color = random.randrange(0,NUM_COLORS)
    if in_northwest(col,row):
      buffer[tile_coord(col,row)] = tile_index         # NORTHWEST TILE
      buffer[color_coord(col,row)] = color             # NORTHWEST COLOR

      buffer[tile_coord(col+80,row)] = tile_index      # NORTHEAST TILE
      buffer[color_coord(col+80,row)] = color          # NORTHEAST COLOR

      buffer[tile_coord(col,row+60)] = tile_index      # SOUTHWEST TILE
      buffer[color_coord(col,row+60)] = color          # SOUTHWEST COLOR

      buffer[tile_coord(col+80,row+60)] = tile_index   # SOUTHEAST TILE
      buffer[color_coord(col+80,row+60)] = color       # SOUTHEAST COLOR

    elif in_north(col,row):
      buffer[tile_coord(col,row)] = tile_index         # NORTH TILE
      buffer[color_coord(col,row)] = color             # NORTH COLOR

      buffer[tile_coord(col,row+60)] = tile_index      # SOUTH TILE
      buffer[color_coord(col,row+60)] = color          # SOUTH COLOR

    elif in_west(col,row):
      buffer[tile_coord(col,row)] = tile_index         # WEST TILE
      buffer[color_coord(col,row)] = color             # WEST COLOR

      buffer[tile_coord(col+80,row)] = tile_index      # EAST TILE
      buffer[color_coord(col+80,row)] = color          # EAST COLOR

    elif in_center(col,row):
      buffer[tile_coord(col,row)] = tile_index         # CENTER TILE
      buffer[color_coord(col,row)] = color             # CENTER COLOR

    else:
      continue

f = open("TILEMAP0.BIN", "wb")
f.write(bytearray(buffer))
f.close()