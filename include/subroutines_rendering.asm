; Clean ppu by writing T registry to V registry with double write
; to PPU_ADDR, updating sroll and setting updated nametable
CleanPPU:
 LDA #$00
 STA PPU_ADDR
 STA PPU_ADDR

 LDA #$00
 STA $2005
 LDA scroll
 STA $2005
 ; Clean PPU
 LDA #%10001000
 ORA nametable
 STA $2000
 LDA #%00011110
 STA $2001
 RTS
ContinuousScroll:
 ; Register scrolling and swap nametable for continous scroll
 LDA scroll
 ;CMP #$FF
 BNE skipSwapNT
SwapNtProcess:
 LDA swapEnabled
 BNE swapDone
 SEC
 LDA scroll
 SBC #$11
 STA scroll
SwapNT:
 LDA nametable
 EOR #$02
 STA nametable
 LDA #$01
 STA swapEnabled
 JMP swapDone
skipSwapNT:
 LDA #$00
 STA swapEnabled
swapDone:
 RTS
 
ScrollingSeamRenderingCheck:
 LDA scroll
 AND #%00000111           			; Keep only bit from 0 to 7
 BNE skipSeamRenderingCheck 		; if it equal zero render new row
 
 LDA worldRowValueChanged
 BNE skipWorldRowValueUpdate
 SEC
 DEC worldRowValue
 ; Swap nametable
 LDA nametable
 EOR #$02
 STA nametable
 JSR DrawNewRow
 LDA nametable
 EOR #$02
 STA nametable
 INC worldRowValueChanged
skipWorldRowValueUpdate:
 RTS
 
skipSeamRenderingCheck:
 LDA #$00
 STA worldRowValueChanged
 RTS
; Draw one row of tile based on address given
DrawNewRow:
 lda nametable 					; should equal to 0 or 2
 EOR #$02
 asl a
 asl a 							; multiply by 4 to get 0 or 8
 clc
 adc #$20 						; add to 20 to get the high address $2000 or $2800
 sta high_row
 
 ; LDA scroll						; get scroll from 0 to 240 ( 240 is max for vertical scrolling)
 ; LSR A
 ; LSR A
 ; LSR A							; divide by 8 to get 0 to 29
 ; TAX
 ; BEQ skipMultiplyLoop
 ; LDA #$00
; RowMultiplyLoop:				; Multiply X value times 32
 ; CLC
 ; ADC #$20
 ; BCC skipIncHighRow				; if cycle back to 0 increase high_row address
 ; INC high_row
; skipIncHighRow:
 ; DEX
 ; BNE RowMultiplyLoop
; skipMultiplyLoop:
 ; STA low_row					; finally store the value in low_row address to be used for rendering
 
 LDA scroll						; get scroll from 0 to 240 ( 240 is max for vertical scrolling)
 LSR A
 LSR A
 LSR A							; divide by 8 to get 0 to 29
 TAX
 LDA #$00
RowMultiplyLoop:				; Multiply X value times 32 ( 32 tiles in one row)
 CPX #$00						; Start by comparing if 0 then break out the loop immediatly
 BEQ exitRowMultiplyLoop
 CLC
 ADC #$20
 BCC skipIncHighRow				; if cycle back to 0 increase high_row address
 INC high_row
skipIncHighRow:
 DEX
 JMP RowMultiplyLoop
exitRowMultiplyLoop:
 STA low_row					; finally store the value in low_row address to be used for rendering
 
 
 LDA worldRowValue				; Get row based on all map combine and calculate how far the source have to go to read a row
 ASL A 
 ASL A 
 ASL A
 ASL A
 ASL A							; Multiplied by 32 for each complete rows of data
 STA low_map
 LDA worldRowValue
 AND #%11111000
 LSR A
 LSR A
 LSR A
 STA high_map
 
 LDA $2002
 LDA high_row
 STA PPU_ADDR
 LDA low_row
 STA PPU_ADDR
 
DrawRow:

 LDA low_map
 CLC
 ADC #LOW(Map0)
 STA low_map
 LDA high_map
 ADC #HIGH(Map0)
 STA high_map
 LDX #$20
 LDY #$00
DrawRowLoop:
 LDA [low_map],y
 STA $2007
 INY
 DEX
 BNE DrawRowLoop
 
 RTS