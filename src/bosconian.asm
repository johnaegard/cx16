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
; just layer 0 enabled
VERA_mode = %00010001
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

   ; configure location of map in vram
   lda #(VRAM_layer0_map >> 9)
   sta VERA_L0_mapbase
   
   ; configure location of tiles in vram and set to 8x8
   lda #(VRAM_tiles >> 9) 
   sta VERA_L0_tilebase

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

   ;; reset scroll
   stz VERA_L0_hscroll_l ; horizontal scroll = 0
   stz VERA_L0_hscroll_h
   stz VERA_L0_vscroll_l ; vertical scroll = 0
   stz VERA_L0_vscroll_h

   ; reenable display
   lda #VERA_mode
   sta VERA_dc_video



@done:
   rts