.include "x16.inc"

.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

   jmp start

message: .byte "hello, world!"
end_msg:

NEWLINE = $0D
UPPERCASE = $8E
DOUBLE_WIDE_PIXELS = $40

; VRAM Addresses
VRAM_layer0_map   = $00000
VRAM_layer1_map   = $00200
VRAM_tiles        = $00800

VERA_mode_just_layer0_enabled = %00010001

; 128 x 128 tile map
; 16 color mode
; 1bpp 
VERA_tile_layer0_config = %10100000

start:

   ; set resolution to 320x240
   lda #DOUBLE_WIDE_PIXELS
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

   stz VERA_L0_hscroll_l ; horizontal scroll = 0
   stz VERA_L0_hscroll_h
   stz VERA_L0_vscroll_l ; vertical scroll = 0
   stz VERA_L0_vscroll_h

   ; reenable display
   lda #VERA_mode_just_layer0_enabled
   sta VERA_dc_video
   
   ; force uppercase
   lda #UPPERCASE
   jsr CHROUT
   ; print message
   lda #<message
   sta ZP_PTR_1
   lda #>message
   sta ZP_PTR_1+1
   ldy #0
@loop:
   cpy #(end_msg-message)
   beq @done
   lda (ZP_PTR_1),y
   jsr CHROUT
   iny
   bra @loop
@done:
   ; print newline
   lda #NEWLINE
   jsr CHROUT
   rts


   lda $40
   sta VERA_dc_hscale
   sta VERA_dc_vscale

