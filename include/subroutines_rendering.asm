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
SwapNT:
 LDA swapEnabled
 BNE swapDone
 SEC
 LDA scroll
 SBC #$11
 STA scroll
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
 
 JSR DrawNewRow
 
 INC worldRowValueChanged
skipWorldRowValueUpdate:
 RTS
 
skipSeamRenderingCheck:
 LDA #$00
 STA worldRowValueChanged
 RTS
; Draw one row of tile based on address given
DrawNewRow:
 LDA nametable
 JSR LoadHighRow
 STA high_row
 
 LDA scroll
 LSR A
 LSR A
 LSR A
 LSR A							; divide by 16
 TAX
 LDA #$00
RowMultiplyLoop:				; Multiply X value times 64 ( 32 tiles in one row * 2 for each metatiles)
 CPX #$00						; Start by comparing if 0 then break out the loop immediatly
 BEQ exitRowMultiplyLoop
 CLC
 ADC #$40
 BCC skipIncHighRow				; if cycle back to 0 increase high_row address in Y
 INC high_row
skipIncHighRow:
 DEX
 JMP RowMultiplyLoop
exitRowMultiplyLoop:
 STA low_row
 
 LDA $2002
 LDA high_row
 STA PPU_ADDR
 LDA low_row
 STA PPU_ADDR
 
 JSR DrawNewMetatiles
 
 RTS
 
 
; TODO : set attributes with scroll