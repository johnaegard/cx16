.include "x16.inc"

.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

   jmp start

; VRAM Addresses
; https://docs.google.com/spreadsheets/d/1n0DPc4DzMAWshT9GZvgzJAs2BIdy6EfK9pPbRWDD-3A/edit?usp=sharing

VRAM_tiles                   = $00000
VRAM_layer0_map              = $00800
VRAM_layer0_map_color_base   = $00801
VRAM_layer1_map_color_base   = $08800

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

default_irq_vector: .addr 0
l0_move: .byte 0
L0_DELAY = 2

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

   ; initialize parallax counter
   lda #L0_DELAY
   sta l0_move

   ; reset scroll
   stz VERA_L0_hscroll_l ; horizontal scroll = 0
   stz VERA_L0_hscroll_h
   stz VERA_L0_vscroll_l ; vertical scroll = 0
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
   jsr ENTROPY_GET
   ; use a and x entropy to choose sparkle coord, place it in word starting at ZP_PTR_1
   stx ZP_PTR_1
   lsr a
   lsr a
   sta ZP_PTR_1 + 1

   ; use y entropy to make d16 color roll
   
   sty ZP_PTR_2


   ; add base tilemap color addr 
   lda ZP_PTR_1
   clc
   adc #<VRAM_layer0_map_color_base
   sta VERA_addr_low
   lda ZP_PTR_1 + 1
   adc #>VRAM_layer0_map_color_base
   sta VERA_addr_high
   stz VERA_addr_bank


   wai
   ; do nothing in main loop, just let ISR do everything
   bra @main_loop
   ; never return, just wait for resetc

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