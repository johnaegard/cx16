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

layer_0_map:
.byte $00,$00,$01,$01,$02,$02,$03,$03
.byte $04,$04,$05,$05,$06,$06,$07,$07
.byte $08,$08,$09,$09,$0A,$0A,$0B,$0B
.byte $0C,$0C,$0D,$0D,$0E,$0E,$0F,$0F
end_layer_0_map:
L0_MAP_SIZE = end_layer_0_map - layer_0_map

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
   
   ; load sprite frames
   lda #1 ; logical number
   ldx #8 ; device number (SD Card / emulator host FS)
   ldy #0 ; secondary address (0 = ignore file header)
   jsr SETLFS
   lda #(TILES_FILENAME_LENGTH)
   ldx #<tiles_filename
   ldy #>tiles_filename
   jsr SETNAM
  ;  lda #(^VRAM_tiles + 2) ; VRAM bank + 2
   lda #(^VRAM_tiles+2) ; VRAM bank + 2
   ldx #<VRAM_tiles
   ldy #>VRAM_tiles
   jsr LOAD

   ;RAM2VRAM tiles, VRAM_tiles, TILES_SIZE

   ;; reset scroll
   stz VERA_L0_hscroll_l ; horizontal scroll = 0
   stz VERA_L0_hscroll_h
   stz VERA_L0_vscroll_l ; vertical scroll = 0
   stz VERA_L0_vscroll_h

   ; load layer 0 map to VRAM
   RAM2VRAM layer_0_map, VRAM_layer0_map, L0_MAP_SIZE

   ; reenable display
   lda #VERA_mode
   sta VERA_dc_video



@done:
   rts