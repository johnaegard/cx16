.include "x16.inc"

.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

   jmp start

TWINKLE_STARS_PER_LOOP = 255

; VRAM Addresses
; https://docs.google.com/spreadsheets/d/1n0DPc4DzMAWshT9GZvgzJAs2BIdy6EfK9pPbRWDD-3A/edit?usp=sharing

VRAM_layer0_map              = $00000
VRAM_layer0_map_color_base   = VRAM_layer0_map + 1
VRAM_layer1_map              = $02000
VRAM_layer1_map_color_base   = VRAM_layer1_map + 1
VRAM_tiles                   = $04000
VRAM_fighter_sprite_base     = $04800

ZP_TWINKLE_COORD_L = ZP_PTR_1
ZP_TWINKLE_COORD_H = ZP_PTR_1 + 1
ZP_TWINKLE_COLOR = ZP_PTR_2
ZP_TWINKLE_COUNT = ZP_PTR_3

;
; VERA CONFIGS
;
; 320x200
VERA_pixel_scale = $40
; enable both layers + sprites
VERA_mode = %01110001
; 64 x 64 tile map, 16 color mode, 1bpp
VERA_tile_config = %01010000
; USE CHANNEL 0 for input
VERA_channel = %11111110

tiles_filename:
.byte "tiles.bin"
end_tiles_filename:
TILES_FILENAME_LENGTH = end_tiles_filename - tiles_filename

tilemap0_filename:
.byte "map0.bin"
end_tilemap0_filename:
TILEMAP0_FILENAME_LENGTH = end_tilemap0_filename - tilemap0_filename

tilemap1_filename:
.byte "map1.bin"
end_tilemap1_filename:
TILEMAP1_FILENAME_LENGTH = end_tilemap1_filename - tilemap1_filename

fighter_filename:
.byte "whtsq.bin"
end_fighter_filename:
FIGHTER_FILENAME_LENGTH = end_fighter_filename - fighter_filename

; starmap motion
l0_move: .byte 0
L0_DELAY = 2
MAP_MAX_COORD = 511

; sprite configs 
BPP4_MASK      = %01111111
FIGHTER_X      = 144
FIGHTER_Y      = 104
SPRITE_Z3      = $0C
SPRITE_VFLIP   = $02
SPRITE_HFLIP   = $01
SPRITE_16x16   = %01010000
SPRITE_COLMASK_Z3_NOFLIP = %11111100

default_irq_vector: .addr 0

start:
   ; channel select
   lda VERA_ctrl
   and #VERA_channel
   sta VERA_ctrl

   ; resolution
   lda #VERA_pixel_scale
   sta VERA_dc_hscale
   sta VERA_dc_vscale

   ; disable display during setup
   stz VERA_dc_video

   ; configure layers
   lda #VERA_tile_config
   sta VERA_L0_config
   sta VERA_L1_config

   ; configure location of map 0 in vram
   lda #(VRAM_layer0_map >> 9)
   sta VERA_L0_mapbase
   
   ; configure location of map 1 in vram
   lda #(VRAM_layer1_map >> 9)
   sta VERA_L1_mapbase

   ; configure location of tiles in vram and set tilesize to 8x8
   lda #((VRAM_tiles >> 9) & %11111100)
   sta VERA_L0_tilebase
   sta VERA_L1_tilebase

   ; load bins to VRAM
   VRAM_LOAD_FILE tiles_filename,    TILES_FILENAME_LENGTH,    VRAM_tiles
   VRAM_LOAD_FILE tilemap0_filename, TILEMAP0_FILENAME_LENGTH, VRAM_layer0_map
   VRAM_LOAD_FILE tilemap1_filename, TILEMAP1_FILENAME_LENGTH, VRAM_layer1_map
   VRAM_LOAD_FILE fighter_filename,  FIGHTER_FILENAME_LENGTH,  VRAM_fighter_sprite_base

   ; initialize parallax counter
   lda #L0_DELAY
   sta l0_move

   ; reset scroll
   stz VERA_L0_hscroll_l 
   stz VERA_L0_hscroll_h
   stz VERA_L0_vscroll_l 
   stz VERA_L0_vscroll_h

   ; light up the sprite
   VERA_SET_ADDR VRAM_sprattr, 1
   ; set sprite frame address
   lda #<(VRAM_fighter_sprite_base >> 5)
   sta VERA_data0
   lda #>(VRAM_fighter_sprite_base >> 5)
   and #BPP4_MASK
   sta VERA_data0

   ; position
   lda #<FIGHTER_X
   sta VERA_data0
   lda #>FIGHTER_X
   sta VERA_data0
   lda #<FIGHTER_Y
   sta VERA_data0
   lda #>FIGHTER_Y
   sta VERA_data0
   lda #(SPRITE_COLMASK_Z3_NOFLIP)
   sta VERA_data0
   lda #(SPRITE_16x16)
   sta VERA_data0

   ; reenable display
   lda #VERA_mode
   sta VERA_dc_video

   ; backup default RAM IRQ vector
   lda IRQVec
   sta default_irq_vector
   lda IRQVec+1
   sta default_irq_vector+1

   ; overwrite RAM IRQ vector with custom handler address
   sei ; disable IRQ while vector is changing
   lda #<custom_irq_handler
   sta IRQVec
   lda #>custom_irq_handler
   sta IRQVec+1
   lda #VSYNC_BIT ; make VERA only generate VSYNC IRQs
   sta VERA_ien
   cli ; enable IRQ now that vector is properly set

@twinkle_reset:
   stz ZP_TWINKLE_COUNT
@twinkle_loop:
   jsr ENTROPY_GET
   ; use (a concat x) entropy for 14-bit sparkle coord covering both tile maps and place it in ZP
   stx ZP_TWINKLE_COORD_L
   lsr
   lsr
   sta ZP_TWINKLE_COORD_H
   lda ZP_TWINKLE_COORD_L      
   and #%11111110            ; zero out the final bit of the twinkle coord to force it even
   sta ZP_TWINKLE_COORD_L

   ; use y entropy to make d16 color roll and put in ZP_PTR_2
   tya
   lsr
   lsr
   lsr
   lsr
   sty ZP_TWINKLE_COLOR
   eor ZP_TWINKLE_COLOR
   and #7
   sta ZP_TWINKLE_COLOR
   
   lda ZP_TWINKLE_COORD_L
   clc
   adc #<VRAM_layer0_map_color_base
   sta VERA_addr_low
   lda ZP_TWINKLE_COORD_H
   adc #>VRAM_layer0_map_color_base
   sta VERA_addr_high
   stz VERA_addr_bank
   
   lda ZP_TWINKLE_COLOR
   sta VERA_data0

   inc ZP_TWINKLE_COUNT
   lda ZP_TWINKLE_COUNT
   cmp #TWINKLE_STARS_PER_LOOP
   beq @done_twinkling_for_now
   bra @twinkle_loop
@done_twinkling_for_now:
   wai
   bra @twinkle_reset

custom_irq_handler:
   lda VERA_isr
   and #VSYNC_BIT
   beq @continue ; non-VSYNC IRQ, no tick update

   ; scroll layer 1
   lda VERA_L1_hscroll_l
   clc
   adc #1
   sta VERA_L1_hscroll_l
   sta VERA_L1_vscroll_l
   lda VERA_L1_hscroll_h
   adc #0
   sta VERA_L1_hscroll_h
   sta VERA_L1_vscroll_h

   ; handle parallax delay
   dec l0_move
   bne @continue ; sky_move non-zero, don't scroll sky

   ; scroll layer 0
   lda VERA_L0_hscroll_l
   clc
   adc #1
   sta VERA_L0_hscroll_l
   sta VERA_L0_vscroll_l
   lda VERA_L0_hscroll_h
   adc #0
   sta VERA_L0_hscroll_h
   sta VERA_L0_vscroll_h

   ; reset parallax counter
   lda #L0_DELAY
   sta l0_move

@continue:
   ; continue to default IRQ handler
   jmp (default_irq_vector)
   ; RTI will happen after jump