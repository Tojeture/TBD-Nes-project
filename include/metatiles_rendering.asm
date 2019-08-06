DrawNewMetatiles:
; Determine how many map should be skipped
 LDA worldRowValue
 STA var1
 LSR A
 LSR A
 LSR A
 LSR A
 ASL A
 TAY
 
; Decrease the world row value because we skipped some
 TAX
 LDA var1
WorldRowAdjustLoop:
 SEC
 SBC #$08						; for each 2 adress skipped with MapPointer we decrease the row lookedup by 16 so foreach MapPointer Decrease by 8
 DEX
 BNE WorldRowAdjustLoop
 TAX
 
; Get the right map address from the map list
GetMapAddr:
 LDA Map0,Y
 STA low_map
 LDA Map0+1,Y
 STA high_map
; Loop through the map to get the first address from the metatiles row
 LDY #$00
GetMapRowLoop:
 LDA [low_map],Y
 INY
 CMP $FF
 BNE GetMapRowLoop
 DEX
 BNE GetMapRowLoop
 
 LDA #$00
 STA metatilesPointer
 JSR ReadMapData
 RTS
 
ReadMapData:
 ; Y registry : map adress iterator
 LDA [low_map],Y
 AND #$80  						; 0x80 = #%10000000
 BEQ SkipToDraw
 LDA [low_map],Y
 AND #$0F						; 0x80 = #%00001111
 TAX
 INY
ReadMapDataLoop:
 JSR DrawMetatiles
 DEX
 BNE ReadMapDataLoop
 JMP ReadMapDataDone
SkipToDraw:
 JSR DrawMetatiles
ReadMapDataDone: 
 INY
 LDA [low_map],Y
 CMP #$FF
 BNE ReadMapData
 LDA metatilesPointer
 CMP #$02
 BEQ ReadMapDone
 LDA #$02
 STA metatilesPointer 
ReadMapDone:
 RTS
 
DrawMetatiles:
 TYA
 PHA
 LDA [low_map],Y
 ASL A
 TAY
 LDA MetaTileSeta,Y
 STA low_meta
 LDA MetaTileSeta+1,Y
 STA high_meta
 LDA [low_meta],Y						; Contain the first sprite to puh to data
 PLA
 TAY
 RTS
 



























