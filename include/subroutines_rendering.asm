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

 
 LDA high_row
 STA var1
 LDA scroll
 JSR RowMultiply
 STA low_row
 
 LDA var1
 STA high_row
 
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
 
 
; TODO : set attributes with scroll