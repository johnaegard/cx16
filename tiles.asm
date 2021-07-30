.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

   jmp start

; Zero Page
ZP_PTR            = $30

; RAM Interrupt Vectors
IRQVec            = $0314

; VERA
VERA_addr_low     = $9F20
VERA_addr_high    = $9F21
VERA_addr_bank    = $9F22
VERA_data0        = $9F23
VERA_ctrl         = $9F25
VERA_ien          = $9F26
VERA_isr          = $9F27
VSYNC_BIT         = $01
VERA_dc_video     = $9F29
VERA_dc_hscale    = $9F2A
VERA_dc_vscale    = $9F2B
DISPLAY_SCALE     = 32 ; 4X zoom
VERA_L0_config    = $9F2D
VERA_L0_mapbase   = $9F2E
VERA_L0_tilebase  = $9F2F
VERA_L0_hscroll_l = $9F30
VERA_L0_hscroll_h = $9F31
VERA_L0_vscroll_l = $9F32
VERA_L0_vscroll_h = $9F33
VERA_L1_config    = $9F34
VERA_L1_mapbase   = $9F35
VERA_L1_tilebase  = $9F36
VERA_L1_hscroll_l = $9F37
VERA_L1_hscroll_h = $9F38
VERA_L1_vscroll_l = $9F39
VERA_L1_vscroll_h = $9F3A

; VRAM Addresses
VRAM_layer0_map   = $00000
VRAM_layer1_map   = $00200
VRAM_tiles        = $00800

; globals:
sky: ; 32 x 32 (only populating first 8 rows)
.byte $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00
.byte $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00
.byte $01,$00, $01,$00, $01,$00, $02,$00, $03,$00, $04,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $02,$00, $03,$00, $04,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $02,$00, $03,$00, $04,$00, $01,$00, $01,$00
.byte $01,$00, $01,$00, $01,$00, $04,$0c, $05,$08, $04,$08, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $04,$0c, $05,$08, $04,$08, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $04,$0c, $05,$08, $04,$08, $01,$00, $01,$00
.byte $04,$04, $04,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $02,$00, $03,$00, $04,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $02,$00, $03,$00, $04,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00
.byte $04,$0c, $04,$08, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $04,$0c, $05,$08, $04,$08, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $04,$0c, $05,$08, $04,$08, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00
.byte $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00
.byte $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00, $01,$00

ground: ; 32 x 32 (only populating first 15 rows)
.byte $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00
.byte $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00
.byte $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00
.byte $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00
.byte $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00
.byte $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00
.byte $08,$00, $08,$04, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $08,$00, $08,$04, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $08,$00, $08,$04, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $00,$00, $08,$00, $08,$04, $00,$00, $00,$00, $00,$00
.byte $09,$00, $09,$04, $07,$00, $07,$00, $07,$00, $07,$00, $07,$00, $07,$00, $07,$00, $09,$00, $09,$04, $07,$00, $07,$00, $07,$00, $07,$00, $07,$00, $07,$00, $07,$00, $09,$00, $09,$04, $07,$00, $07,$00, $07,$00, $07,$00, $07,$00, $07,$00, $07,$00, $09,$00, $09,$04, $07,$00, $07,$00, $07,$00
.byte $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00
.byte $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00
.byte $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00
.byte $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00
.byte $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00
.byte $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00
.byte $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00, $06,$00

end_maps:
MAPS_SIZE = end_maps-sky

tiles:
      ; Tile 0
.byte $00,$00,$00,$00
.byte $00,$00,$00,$00
.byte $00,$00,$00,$00
.byte $00,$00,$00,$00
.byte $00,$00,$00,$00
.byte $00,$00,$00,$00
.byte $00,$00,$00,$00
.byte $00,$00,$00,$00

      ; Tile 1
.byte $33,$33,$33,$33
.byte $33,$33,$33,$33
.byte $33,$33,$33,$33
.byte $33,$33,$33,$33
.byte $33,$33,$33,$33
.byte $33,$33,$33,$33
.byte $33,$33,$33,$33
.byte $33,$33,$33,$33

      ; Tile 2
.byte $33,$33,$33,$33
.byte $33,$33,$33,$33
.byte $33,$33,$33,$33
.byte $33,$33,$33,$3f
.byte $33,$33,$3f,$f1
.byte $33,$3f,$f1,$11
.byte $33,$f1,$11,$11
.byte $3f,$11,$11,$1f

      ; Tile 3
.byte $33,$33,$33,$33
.byte $33,$33,$33,$33
.byte $33,$33,$33,$33
.byte $ff,$f3,$33,$33
.byte $11,$1f,$f3,$33
.byte $11,$11,$1f,$ff
.byte $1f,$11,$11,$11
.byte $f1,$11,$11,$11

      ; Tile 4
.byte $33,$33,$33,$33
.byte $33,$33,$33,$33
.byte $33,$33,$33,$33
.byte $33,$33,$33,$33
.byte $33,$33,$33,$33
.byte $ff,$ff,$f3,$33
.byte $11,$11,$1f,$33
.byte $11,$11,$11,$f3

      ; Tile 5
.byte $33,$33,$33,$33
.byte $33,$33,$33,$33
.byte $33,$33,$33,$33
.byte $33,$33,$33,$33
.byte $33,$33,$33,$33
.byte $ff,$ff,$ff,$ff
.byte $11,$11,$11,$11
.byte $11,$11,$11,$f1

      ; Tile 6
.byte $55,$55,$d5,$55
.byte $55,$55,$d5,$55
.byte $5d,$55,$5d,$55
.byte $5d,$55,$5d,$55
.byte $d5,$55,$55,$55
.byte $d5,$55,$55,$55
.byte $5d,$55,$5d,$55
.byte $5d,$55,$5d,$55

      ; Tile 7
.byte $00,$00,$00,$00
.byte $00,$00,$00,$00
.byte $00,$00,$00,$00
.byte $00,$00,$00,$00
.byte $00,$00,$00,$00
.byte $0d,$00,$d0,$0d
.byte $55,$55,$55,$55
.byte $55,$55,$55,$55

      ; Tile 8
.byte $00,$00,$00,$00
.byte $00,$00,$00,$00
.byte $00,$00,$00,$00
.byte $00,$00,$00,$55
.byte $00,$00,$55,$55
.byte $00,$00,$55,$55
.byte $00,$05,$55,$55
.byte $00,$05,$55,$55

      ; Tile 9
.byte $00,$05,$55,$55
.byte $00,$00,$55,$55
.byte $00,$00,$05,$95
.byte $00,$00,$00,$09
.byte $00,$00,$00,$09
.byte $0d,$00,$d0,$09
.byte $55,$55,$55,$99
.byte $55,$55,$59,$95

end_tiles:
TILES_SIZE = end_tiles-tiles

.macro RAM2VRAM ram_addr, vram_addr, num_bytes
   .scope
      ; set data port 0 to start writing to VRAM address
      stz VERA_ctrl
      lda #($10 | ^vram_addr) ; stride = 1
      sta VERA_addr_bank
      lda #>vram_addr
      sta VERA_addr_high
      lda #<vram_addr
      sta VERA_addr_low
       ; ZP pointer = start of video data in CPU RAM
      lda #<ram_addr
      sta ZP_PTR
      lda #>ram_addr
      sta ZP_PTR+1
      ; use index pointers to compare with number of bytes to copy
      ldx #0
      ldy #0
   vram_loop:
      lda (ZP_PTR),y
      sta VERA_data0
      iny
      cpx #>num_bytes ; last page yet?
      beq check_end
      cpy #0
      bne vram_loop ; not on last page, Y non-zero
      inx ; next page
      inc ZP_PTR+1
      bra vram_loop
   check_end:
      cpy #<num_bytes ; last byte of last page?
      bne vram_loop ; last page, before last byte
   .endscope
.endmacro


default_irq_vector: .addr 0

sky_move: .byte 0
SKY_DELAY = 2

start:
   stz VERA_dc_video ; disable display

   ; scale display to 4x zoom (160x120)
   lda #DISPLAY_SCALE
   sta VERA_dc_hscale
   sta VERA_dc_vscale

   ; configure layer 0: sky
   lda #$02 ; 32x32 4bpp tiles
   sta VERA_L0_config
   lda #(VRAM_layer0_map >> 9)
   sta VERA_L0_mapbase
   lda #(VRAM_tiles >> 9) ; 8x8 tiles
   sta VERA_L0_tilebase
   stz VERA_L0_hscroll_l ; horizontal scroll = 0
   stz VERA_L0_hscroll_h
   stz VERA_L0_vscroll_l ; vertical scroll = 0
   stz VERA_L0_vscroll_h

   ; configure layer 1: ground
   lda #$02 ; 32x32 4bpp tiles
   sta VERA_L1_config
   lda #(VRAM_layer1_map >> 9)
   sta VERA_L1_mapbase
   lda #(VRAM_tiles >> 9) ; 8x8 tiles
   sta VERA_L1_tilebase
   stz VERA_L1_hscroll_l ; horizontal scroll = 0
   stz VERA_L1_hscroll_h
   stz VERA_L1_vscroll_l ; vertical scroll = 0
   stz VERA_L1_vscroll_h

   ; copy tile maps to VRAM
   RAM2VRAM sky, VRAM_layer0_map, MAPS_SIZE
   ; copy tiles to VRAM
   RAM2VRAM tiles, VRAM_tiles, TILES_SIZE

   ; enable display, both layers
   lda #$31
   sta VERA_dc_video

   ; initialize parallax counter
   lda #SKY_DELAY
   sta sky_move

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
   wai
   ; do nothing in main loop, just let ISR do everything
   bra @main_loop
   ; never return, just wait for reset


custom_irq_handler:
   lda VERA_isr
   and #VSYNC_BIT
   beq @continue ; non-VSYNC IRQ, no tick update

   ; scroll ground (layer 1) to the left one pixel
   lda VERA_L1_hscroll_l
   clc
   adc #1
   sta VERA_L1_hscroll_l
   lda VERA_L1_hscroll_h
   adc #0
   sta VERA_L1_hscroll_h

   ; handle parallax delay
   dec sky_move
   bne @continue ; sky_move non-zero, don't scroll sky

   ; scroll sky (layer 0) to the left one pixel
   lda VERA_L0_hscroll_l
   clc
   adc #1
   sta VERA_L0_hscroll_l
   lda VERA_L0_hscroll_h
   adc #0
   sta VERA_L0_hscroll_h

   ; reset parallax counter
   lda #SKY_DELAY
   sta sky_move

@continue:
   ; continue to default IRQ handler
   jmp (default_irq_vector)
   ; RTI will happen after jump
