; So, essentially, we add a flag for the vblank.
; Personally, I wouldn't, but the machine wouldn't shut up about it.

.segment "HEADER"
    .byte   "NES", $1A
    .byte   2
    .byte   1
    .byte   $01, $00

.segment "ZEROPAGE"
    ; Game variables
    gamestate:      .res 1
    playerx:        .res 1
    
    ; Meta variables
    buttons1:       .res 1
    vblankflag:     .res 1
    
    ; Consts
    PLAYERY         = $80

        ; for the sake of sanity
    BUTTON_LEFT     = %00000010
    BUTTON_RIGHT    = %00000001
    BUTTON_START    = %00010000

.segment "STARTUP" ; Still don't know what this is for

.segment "CODE"

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

loadpalettes:
    lda $2002
    lda #$3F
    sta $2006
    lda #$00
    sta $2006

    ldx #$00
@loop:
    lda palettes, x
    sta $2007
    inx
    cpx #$20
    bne @loop

; INIT VARS HERE
    lda #$80
    sta playerx
    lda #$01
    sta gamestate ; I'll add stuff later

; Maybe?
    jsr vblankwait
    lda #$01
    sta vblankflag

; gaem

gameloop:
    lda vblankflag
    cmp #$01
    bne gameloop

    ; actual game
    ; ...after resetting the flag
    lda #$00
    sta vblankflag

    lda #%10010000
    sta $2000
    lda #%00011110
    sta $2001
    
    lda #$00
    sta $2005 ;no scrolling
    sta $2005 ;no scrolling (idk which is which)

    jsr readcontroller1

    jsr checkgamestate
    jsr updatesprites
    
    lda #$00
    sta $2003
    lda #$02
    sta $4014
jmp gameloop


; -------- SUBROUTINES ---------
checkgamestate:
    lda gamestate
    cmp #$00
    beq titlescreen ; later
    cmp #$01
    beq ingame ; ya
    
    joever:
        rts

titlescreen: ; I'll fill this out later
    
    jmp joever

ingame:

    moveplayerleft:
        lda buttons1
        and #BUTTON_LEFT
        beq @done

        lda playerx
        sec
        sbc #$01
        sta playerx
    @done:

    moveplayerright:
        lda buttons1
        and #BUTTON_RIGHT
        beq @done

        lda playerx
        clc
        adc #$01
        sta playerx

    @done:
        jmp joever

readcontroller1:
    lda #$01
    sta $4016
    lda #$00
    sta $4016
    ldx #$08

    @loop:
        lda $4016
        lsr A
        rol buttons1
        dex
        bne @loop
        rts

updatesprites:
    lda #PLAYERY
    sta $0200
    lda #$01
    sta $0201
    lda #$00
    sta $0202
    lda playerx
    sta $0203

    rts

vblank:
    lda #$01
    sta vblankflag
    rti

irq:        ; ?????
    rti 

; DATA AND STUFF
palettes: ;for now, yoink smb's palettes
    .byte $22,$29,$1a,$0F,   $22,$36,$17,$0F,   $22,$30,$21,$0F,   $22,$27,$17,$0F  ; background palette data
    .byte $22,$16,$27,$18,   $22,$1A,$30,$27,   $22,$16,$30,$27,   $22,$0F,$36,$17  ; sprite palette data

sprites:
    ; 
    .byte

.segment "VECTORS"
    .word vblank
    .word reset
    .word irq

.segment "CHARS"
    .incbin "shitchr.chr"