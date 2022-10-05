    .inesprg 1
    .ineschr 1
    .inesmap 0
    .inesmir 1

;;;;;;;;;;;;;;;;;;;;;;;

    .rsset $0000    ;Pointers in zero page
buttons .rs 1
facing .rs 1
fire .rs 1
fireTimer .rs 1
fireDir .rs 1

;;;;;;;;;;;;;;;;;;;;;;;;;;

SKY = $24 ;sky tile
SKYATT = %00000000

;;;;;;;;;;;;;;;;

    .bank 0
    .org $C000

wait4ppu:
    BIT $2002
    BPL wait4ppu
    RTS

RESET:
    SEI      ;disable IRQ
    CLD      ;kil decimal mode
    LDX #$40
    STX $4017   ;kil APU frame IRQ
    LDA #$FF
    TXS         ;alive stack
    INX
    STX $2000
    STX $2001
    STX $4010

    JSR wait4ppu

clrmem:
    LDA #$00
    STA $0000, x
    STA $0100, x
    STA $0300, x
    STA $0400, x
    STA $0500, x
    STA $0600, x
    STA $0700, x
    LDA #$FE
    STA $0200, x     ;sprites gone
    INX
    BNE clrmem

    JSR wait4ppu

LoadPalletes:
    LDA $2002
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006
    LDX #$00
LoadPalletesLoop:
    LDA palletes, x
    STA $2007
    INX
    CPX #$20
    BNE LoadPalletesLoop

LoadSprites:
    LDX #$00
LoadSpritesLoop:
    LDA sprites, x
    STA $0200, x
    INX
    CPX #$28
    BNE LoadSpritesLoop

LoadBackground:
    LDA $2002
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006
    LDX #$00
LoadBackgroundLoop:
    LDX #$00 ;;row
    LDY #$00 ;;tile

Out:

In:
    LDA #SKY
    STA $2007
    INX
    CPX #$20
    BNE In
;One row done

    INY
    CPY #$1E
    BNE Out

;;;;;BG loop done

LoadAttributes:
    LDA $2002
    LDA #$23
    STA $2006
    LDA #$C0
    STA $2006
    LDA #$00
LoadAttributesLoop:
    LDA #SKYATT
    STA $2007
    INX
    CPX #$40
    BNE LoadAttributesLoop





    LDA #$00
    STA facing
    STA fire
    STA fireTimer
    STA fireDir

    LDA #%10010000
    STA $2000

    LDA %00011110
    STA $2001




Forever:
    JMP Forever

NMI:
    LDA #$00
    STA $2003
    LDA #$02
    STA $4014

    LDA #%10010000
    STA $2000
    LDA #%00011110
    STA $2001
    LDA #$00
    STA $2005
    STA $2005

    JSR ReadController
    LDA #%00000001
    AND buttons
    BEQ NoR
    JSR Right

NoR:

    JSR ReadController
    LDA #%00000010
    AND buttons
    BEQ NoL
    JSR Left

NoL:

    JSR ReadController
    LDA #%00000100
    AND buttons
    BEQ NoD
    JSR Down

NoD:

    JSR ReadController
    LDA #%00001000
    AND buttons
    BEQ NoU
    JSR Up

NoU:

    JSR ReadController
    LDA #%01000000
    AND buttons
    BEQ NoB
    JSR Fire

NoB:

    JSR MoveFire

    RTI
    


Left:

    LDA #$03
    STA facing

    LDA $0203
    SEC
    SBC #$02
    STA $0203
    LDA $0207
    SEC
    SBC #$02
    STA $0207
    LDA $020B
    SEC
    SBC #$02
    STA $020B
    LDA $020F
    SEC
    SBC #$02
    STA $020F

    RTS

Right:

    LDA #$01
    STA facing

    LDA $0203
    CLC
    ADC #$02
    STA $0203
    LDA $0207
    CLC
    ADC #$02
    STA $0207
    LDA $020B
    CLC
    ADC #$02
    STA $020B
    LDA $020F
    CLC
    ADC #$02
    STA $020F

    RTS

Up:

    LDA #$00
    STA facing

    LDA $0200
    SEC
    SBC #$02
    STA $0200
    LDA $0204
    SEC
    SBC #$02
    STA $0204
    LDA $0208
    SEC
    SBC #$02
    STA $0208
    LDA $020C
    SEC
    SBC #$02
    STA $020C

    RTS

Down:

    LDA #$02
    STA facing

    LDA $0200
    CLC
    ADC #$02
    STA $0200
    LDA $0204
    CLC
    ADC #$02
    STA $0204
    LDA $0208
    CLC
    ADC #$02
    STA $0208
    LDA $020C
    CLC
    ADC #$02
    STA $020C

    RTS

Fire:

    LDA #$64
    STA $0211
    LDA #$01
    STA $0212

    LDX #%00000001
    CPX fire
    BEQ DoneFire

    LDA #%00000001
    STA fire
    LDA #$01
    STA $0212

    LDA #$00
    STA fireTimer

    LDA facing
    STA fireDir

    LDA $020C
    STA $0210
    LDA $020F
    STA $0213

DoneFire:
    RTS

MoveFire:
    LDA fire
    AND #%00000001
    BEQ DoneMoveFire

    LDX fireDir
    CPX #$00
    BEQ FUp

    LDX fireDir
    CPX #$01
    BEQ FRight

    LDX fireDir
    CPX #$02
    BEQ FDown

    LDX fireDir
    CPX #$03
    BEQ FLeft

FLeft:
    LDA $0213
    SEC
    SBC #$06
    STA $0213
    JMP FTime

FRight:
    LDA $0213
    CLC
    ADC #$06
    STA $0213
    JMP FTime

FUp:
    LDA $0210
    SEC
    SBC #$06
    STA $0210
    JMP FTime

FDown:
    LDA $0210
    CLC
    ADC #$06
    STA $0210
    JMP FTime

FTime:
    LDX fireTimer
    INX
    STX fireTimer


    LDX #$10
    CPX fireTimer
    BEQ KillFire
    JMP DoneMoveFire

KillFire:
    LDA #$00
    STA fire
    LDA #$00
    STA $0210
    STA $0211
    STA $0212
    STA $0213

DoneMoveFire:
    RTS

ReadController:
    LDA #$01
    STA $4016
    LDA #$00
    STA $4016
    LDX #$08
ReadControllerLoop:
    LDA $4016
    LSR A
    ROL buttons
    DEX
    BNE ReadControllerLoop
    RTS
    




;;;;;;;;;;;;;;;;;;;;;

    .bank 1
    .org $E000

palletes:
    .db $22,$29,$1A,$0F,  $22,$36,$17,$0F,  $22,$30,$21,$0F,  $22,$27,$17,$0F ;bg pallete
    .db $22,$2D,$07,$19,  $22,$3D,$2D,$03,  $22,$23,$29,$2C,  $22,$23,$29,$2C ;sprite pallete

sprites:
    .db $80, $32, $00, $80  ;mario
    .db $80, $33, $00, $88  ;-
    .db $88, $34, $00, $80  ;-
    .db $88, $35, $00, $88  ;-


    .org $FFFA
    .dw NMI
    .dw RESET
    .dw 0


    .bank 2
    .org $0000
    .incbin "mario.chr"