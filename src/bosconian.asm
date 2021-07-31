.include "x16.inc"

.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

   jmp start

; VRAM Addresses
; https://docs.google.com/spreadsheets/d/1n0DPc4DzMAWshT9GZvgzJAs2BIdy6EfK9pPbRWDD-3A/edit?usp=sharing

VRAM_tiles        = $00000
VRAM_layer0_map   = $00800
VRAM_layer1_map   = $08800

;
; VERA CONFIGS
;
; 320x200
VERA_pixel_scale = $40
; enable both layers + sprites
VERA_mode = %00110001
; 128 x 128 tile map, 16 color mode, 1bpp
VERA_tile_layer0_config = %10100000 

tiles_filename:
.byte "tiles.bin"
end_tiles_filename:
TILES_FILENAME_LENGTH = end_tiles_filename - tiles_filename

tilemap0_filename:
.byte "tilemap0.bin"
end_tilemap0_filename:
TILEMAP0_FILENAME_LENGTH = end_tilemap0_filename - tilemap0_filename

tilemap1_filename:
.byte "tilemap1.bin"
end_tilemap1_filename:
TILEMAP1_FILENAME_LENGTH = end_tilemap1_filename - tilemap1_filename

; TILEMAP CONFIGS
X_FLIP = 640
Y_FLIP = 480
PER_FRAME_DELAY = 65536 / 4

; TILEMAP VARS
tilemap_l0_x:
.word 0
tilemap_l0_y:
.word 0
tilemap_l0_speed:
.word 1

tilemap_l1_x:
.word 0
tilemap_l1_y:
.word 0
tilemap_l1_speed:
.word 2

start:

   ; resolution
   lda #VERA_pixel_scale
   sta VERA_dc_hscale
   sta VERA_dc_vscale

   ; disable display during setup
   stz VERA_dc_video

   ; configure layer 0
   lda #VERA_tile_layer0_config
   sta VERA_L0_config

   ; configure location of map 0 in vram
   lda #(VRAM_layer0_map >> 9)
   sta VERA_L0_mapbase
   
   ; configure location of map 1 in vram
   lda #(VRAM_layer1_map >> 9)
   sta VERA_L1_mapbase

   ; configure location of tiles in vram and set to 8x8
   lda #(VRAM_tiles >> 9) 
   sta VERA_L0_tilebase
   sta VERA_L1_tilebase

   ; load tile definitions to VRAM
   lda #1 ; logical number
   ldx #8 ; device number (SD Card / emulator host FS)
   ldy #0 ; secondary address (0 = ignore file header)
   jsr SETLFS
   lda #(TILES_FILENAME_LENGTH)
   ldx #<tiles_filename
   ldy #>tiles_filename
   jsr SETNAM
   lda #(^VRAM_tiles+2) ; VRAM bank + 2
   ldx #<VRAM_tiles
   ldy #>VRAM_tiles
   jsr LOAD

   ; load tilemap for layer 0 into VRAM .... this should be a macro
   lda #1 ; logical number
   ldx #8 ; device number (SD Card / emulator host FS)
   ldy #0 ; secondary address (0 = ignore file header)
   jsr SETLFS
   lda #(TILEMAP0_FILENAME_LENGTH)
   ldx #<tilemap0_filename
   ldy #>tilemap0_filename
   jsr SETNAM
   lda #(^VRAM_layer0_map+2) ; VRAM bank + 2
   ldx #<VRAM_layer0_map
   ldy #>VRAM_layer0_map
   jsr LOAD

   ; load tilemap for layer 1 into VRAM .... this should be a macro
   lda #1 ; logical number
   ldx #8 ; device number (SD Card / emulator host FS)
   ldy #0 ; secondary address (0 = ignore file header)
   jsr SETLFS
   lda #(TILEMAP1_FILENAME_LENGTH)
   ldx #<tilemap1_filename
   ldy #>tilemap1_filename
   jsr SETNAM
   lda #(^VRAM_layer1_map+2) ; VRAM bank + 2
   ldx #<VRAM_layer1_map
   ldy #>VRAM_layer1_map
   jsr LOAD

   ; reset scroll
   stz VERA_L0_hscroll_l ; horizontal scroll = 0
   stz VERA_L0_hscroll_h
   stz VERA_L0_vscroll_l ; vertical scroll = 0
   stz VERA_L0_vscroll_h

   ; reenable display
   lda #VERA_mode
   sta VERA_dc_video

scroll:
   lda tilemap_l0_x
   clc
   adc tilemap_l0_speed
   sta tilemap_l0_x

   lda tilemap_l0_x+1
   adc tilemap_l0_speed +1
   sta tilemap_l0_x+1

   sta VERA_L0_hscroll_h
   lda tilemap_l0_x
   sta VERA_L0_hscroll_l

   lda tilemap_l1_x
   clc
   adc tilemap_l1_speed
   sta tilemap_l1_x

   lda tilemap_l1_x+1
   adc tilemap_l1_speed +1
   sta tilemap_l1_x+1

   sta VERA_L1_hscroll_h
   lda tilemap_l1_x
   sta VERA_L1_hscroll_l

   ldy #>PER_FRAME_DELAY
   delay_outer:
      ldx #<PER_FRAME_DELAY
      delay_inner:
         dex
         bne delay_inner
      dey
      bne delay_outer

   jmp scroll

@done:
   rts