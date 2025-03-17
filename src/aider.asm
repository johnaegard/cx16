; Checkerboard pattern for Commander X16
; Displays a red and white checkerboard pattern using VERA

; VERA register definitions
VERA_ADDR_L     = $9F20
VERA_ADDR_M     = $9F21
VERA_ADDR_H     = $9F22
VERA_DATA       = $9F23
VERA_CTRL       = $9F25
VERA_DC_VIDEO   = $9F29
VERA_DC_HSCALE  = $9F2A
VERA_DC_VSCALE  = $9F2B
VERA_L0_CONFIG  = $9F2D
VERA_L0_MAPBASE = $9F2E
VERA_L0_TILEBASE = $9F2F
VERA_L0_HSCROLL_L = $9F30
VERA_L0_HSCROLL_H = $9F31
VERA_L0_VSCROLL_L = $9F32
VERA_L0_VSCROLL_H = $9F33

; Color definitions
COLOR_BLACK     = $00
COLOR_RED       = $02
COLOR_WHITE     = $0F

; Zero page variables
TEMP1           = $30
TEMP2           = $31

; BASIC header
.org $801
.byte $0C, $08, $0A, $00, $9E, $20, $32, $30, $36, $34, $00, $00, $00  ; BASIC stub: 10 SYS 2064

; Main program
.org $810
    ; Set up VERA for bitmap mode
    lda #0
    sta VERA_CTRL       ; Select VERA DCSEL=0, ADDRSEL=0
    
    ; Enable display - 320x240 with layer 0 enabled
    lda #%01110001      ; Mode 7 (256 color), enable layer 0
    sta VERA_DC_VIDEO
    
    ; Set scaling to 1:1
    lda #64             ; Scale factor 1:1
    sta VERA_DC_HSCALE
    sta VERA_DC_VSCALE
    
    ; Configure Layer 0 for 320x240 bitmap mode
    lda #%00000000      ; Mode 0 (bitmap mode), 1bpp
    sta VERA_L0_CONFIG
    lda #0              ; Map at $00000
    sta VERA_L0_MAPBASE
    lda #0              ; Tiles at $00000
    sta VERA_L0_TILEBASE
    
    ; Reset scroll position
    lda #0
    sta VERA_L0_HSCROLL_L
    sta VERA_L0_HSCROLL_H
    sta VERA_L0_VSCROLL_L
    sta VERA_L0_VSCROLL_H
    
    ; Set up the palette - make color 1 red and color 0 white
    lda #1              ; Start at color register 1
    sta VERA_ADDR_L
    lda #$FA            ; Palette is at $1FA00
    sta VERA_ADDR_M
    lda #$11            ; Auto-increment by 1
    sta VERA_ADDR_H
    
    ; Set color 1 to red
    lda #$00            ; Red (low byte)
    sta VERA_DATA
    lda #$02            ; Red (high byte)
    sta VERA_DATA
    
    ; Clear the screen first (set all to black)
    lda #0
    sta VERA_ADDR_L
    sta VERA_ADDR_M
    lda #$11            ; Auto-increment by 1
    sta VERA_ADDR_H
    
    ldx #0
    ldy #0
clear_screen:
    lda #COLOR_BLACK    ; Black color
    sta VERA_DATA
    inx
    bne clear_screen
    iny
    cpy #$10            ; Clear 4K (320x240 pixels in 1bpp mode = 9600 bytes)
    bne clear_screen
    
    ; Draw the checkerboard pattern
    lda #0              ; Start at the beginning of VRAM
    sta VERA_ADDR_L
    sta VERA_ADDR_M
    lda #$11            ; Auto-increment by 1
    sta VERA_ADDR_H
    
    ; Initialize row counter
    ldy #0              ; Y position counter (rows)
    
row_loop:
    ; For each row, determine if we're in an odd or even block
    tya
    and #$08            ; Check if in an 8-pixel block
    sta TEMP1           ; Store result
    
    ; Process 40 bytes per row (320 pixels in 1bpp mode)
    ldx #40             ; 40 bytes per row
    
byte_loop:
    ; Each byte represents 8 pixels
    ; Determine pattern based on current X position and row
    txa
    and #$01            ; Check if odd or even byte
    eor TEMP1           ; XOR with row result
    beq white_byte
    
    ; Red byte (all 1s for red pixels)
    lda #$FF            ; All bits set = all red pixels
    jmp store_byte
    
white_byte:
    lda #$00            ; All bits clear = all white pixels
    
store_byte:
    sta VERA_DATA       ; Store to VERA
    
    ; Move to next byte
    dex
    bne byte_loop
    
    ; Move to next row
    iny
    cpy #240            ; Check if we've done all rows
    bne row_loop
    
done_drawing:
    
    ; Loop forever when done
infinite_loop:
    jmp infinite_loop
