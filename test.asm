; Header
.segment "HEADER"
    .byte   "NES", $1A
    .byte   2
    .byte   1
    .byte   $01, $00

.segment "ZEROPAGE"
    gamestate   .res 1

    playerx     .res 1

.segment "STARTUP" ; Still don't know what this is for

.segment "CODE"
; Game time

vblankwait:
    bit $2002
    bpl vblankwait
    rts

reset:
    sei
    cld
    ldx #$40
    stx $4017
    ldx #$ff
    txs
    inx
    stx $2000
    stx $2001
    stx $4010
    jsr vblankwait

    txa

clearmem:
    sta $0000, x
    sta $0100, x
    sta $0200, x
    sta $0300, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    lda #$fe
    sta $0200, x
    lda #$00
    inx
    bne clearmem

    jsr vblankwait

    lda #$02
    sta $4014
    nop

clearnametables:
    lda $2002
    lda #$20
    sta $2006
    lda #$00
    sta $2006
    ldx #$08
    ldy $00
    lda $00
:
    sta $2007
    dey
    bne :-
    dex
    bne :-

; beginging of the loop

forever:
    jmp forever

vblank:

    lda #%10010000
    sta $2000
    lda #%00011110
    sta $2001
    
    lda #$00
    sta $2005 ;no scrolling (maybe later???)
    sta $2005 ;no scrolling (idk which is which)

; Put rest of game here

.segment "VECTORS"
    .word vblank
    .word reset
    .word 0

.segment "CHARS"
    ; TODO: Make CHR