.org $8000 ;Indica che il programma inizia dall'indirizzo 8000

reset:
	LDX #$FF    ; Initialize the Stack Pointer
	TXS         ; Transfer X to Stack

flushMem:
	LDA #$07
	STA $01
	LDA #$FF
	STA $00
loopFlush:
	LDA #$00
	STA ($00),Y
	DEC $00
	CMP $00
	BNE loopFlush
	CMP $01
	BCC turnPage
	JMP startPos
turnPage:
	DEC $01
	LDA #$FF
	STA $00
	JMP loopFlush	

startPos:
	LDA #$87
	STA $00		; $0000 cell with currentPos
	LDA #02
	STA $01		; $0001 cell with GPU page
	LDA #$F7
	STA $02		; $0002 cell with starting pos ref

initColors:
	LDX #$10
	LDA #$FF
	STA $04
	LDA #$F0
	STA $06
	
setColors:
	LDA $04
	STA ($06),Y
	INC $06
	DEC $04
	DEX
	BNE setColors
	LDA $04
	DEC $06
	STA ($06),Y
	JSR setPositionColor

joypad:
	LDA $4000
	STA $04
	BNE move
	JMP joypad

move:
        JSR resetcurpos
	LDA $04
	AND #$01
	BNE moveup
	LDA $04
	AND #$02
	BNE movedown
	LDA $04
	AND #$04
	BNE moveleft
	LDA $04
	AND #$08
	BNE moveright

moveup:
	LDX #$10
	JSR decmoveloop
        JSR setPositionColor
	JMP waitloop

movedown:
	LDX #$10
	JSR incmoveloop
        JSR setPositionColor
	JMP waitloop

moveleft:
	LDX #$1
	JSR decmoveloop
	DEC $02
	LDA $02
	CMP #$EF
	BEQ leftBound
        JSR setPositionColor
	JMP waitloop

leftBound:
	LDX #$1
	JSR incmoveloop
	INC $02
        JSR setPositionColor
	JMP waitloop

moveright:
	LDX #$1
	JSR incmoveloop
	INC $02
	LDA $02
	CMP #$00
	BEQ rightBound
        JSR setPositionColor
	JMP waitloop

rightBound:
	LDX #$1
	JSR decmoveloop
	DEC $02
        JSR setPositionColor
	JMP waitloop

decmoveloop:
	DEC $00
	DEX
	BNE decmoveloop
	RTS

incmoveloop:
	INC $00
	DEX
	BNE incmoveloop
	RTS

resetcurpos:
	LDA #$00
	STA ($00),Y
	RTS

setPositionColor:
	LDA ($02),Y
	STA ($00),Y
	RTS	

waitloop:
	LDA $4000
	BNE waitloop
	JMP joypad

interrupt:
RTI

nonmaskable:
RTI

.goto $FFFA
.dw nonmaskable
.dw $8000
.dw interrupt