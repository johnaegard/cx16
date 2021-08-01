.include "x16.inc"

.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

   jmp start

; VRAM Addresses
; https://docs.google.com/spreadsheets/d/1n0DPc4DzMAWshT9GZvgzJAs2BIdy6EfK9pPbRWDD-3A/edit?usp=sharing

VRAM_layer0_map              = $00000
VRAM_layer0_map_color_base   = $00001
VRAM_layer1_map              = $02000
VRAM_layer1_map_color_base   = $02001
VRAM_tiles                   = $04000

;
; VERA CONFIGS
;
; 320x200
VERA_pixel_scale = $40
; enable both layers + sprites
VERA_mode = %00110001
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

default_irq_vector: .addr 0
l0_move: .byte 0
L0_DELAY = 2

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

   ; load tile definitions to VRAM
   VRAM_LOAD_FILE tiles_filename, TILES_FILENAME_LENGTH, VRAM_tiles
   VRAM_LOAD_FILE tilemap0_filename, TILEMAP0_FILENAME_LENGTH, VRAM_layer0_map
   VRAM_LOAD_FILE tilemap1_filename, TILEMAP1_FILENAME_LENGTH, VRAM_layer1_map

   ; initialize parallax counter
   lda #L0_DELAY
   sta l0_move

   ; reset scroll
   stz VERA_L0_hscroll_l 
   stz VERA_L0_hscroll_h
   stz VERA_L0_vscroll_l 
   stz VERA_L0_vscroll_h

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

@main_loop:
   ; do nothing in main loop, just let ISR do everything
   wai
   ; never return, just wait for resetc
   bra @main_loop

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