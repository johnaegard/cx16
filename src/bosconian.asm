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

start:

   ; set resolution to 320x240
   lda #DOUBLE_WIDE_PIXELS
   sta VERA_dc_hscale
   sta VERA_dc_vscale

   ; activate layer 0, set for 8x8 1-bit tiles.
   ; deactivate layer 1

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

