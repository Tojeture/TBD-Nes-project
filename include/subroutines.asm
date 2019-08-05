; From bank of interuption lead to this function first before the Start
VBlank_routine:
 ;; Register $4014 for OAM info location
 ; writing to SPR-RAM to load the sprite info with registers $2003 & 4014
 LDA #$00
 STA $2003
 LDA #$03
 STA $4014
 inc VBlankOrNo
 RTI

; Controls

keypressed:
 LDA #$01
 STA JOYPAD1
 LDA #$00
 STA JOYPAD1
 
 JSR ReadAButton
 JSR ReadBButton
 LDA JOYPAD1 ;SELECT
 LDA JOYPAD1 ;START
 JSR readupkey
 JSR readdownkey
 JSR readleftkey
 JSR readrightkey
 RTS
 
; A Button
ReadAButton:
 LDA JOYPAD1
 AND #1
 BEQ ReadAUp
 LDA jump_force_cur
 ORA #0
 BEQ ReadABDone
 DEC jump_force_cur
 LDA #$00
 SBC JUMP_VELOCITY
 STA vertical_force
 JMP ReadABDone
 
; !A Button
ReadAUp:
 LDA Player_State
 AND #%00000001
 BEQ NullJumpForce
 LDA JUMP_FORCE
 JMP SetJumpForce
NullJumpForce:
 LDA #$00
SetJumpForce:
 STA jump_force_cur
 JMP ReadABDone
 
ReadBButton:
 LDA JOYPAD1
 AND #1
 BEQ ReadABDone
 SEC
 DEC scroll
 JMP ReadABDone
 
ReadABDone:
 RTS
 
; UP
readupkey:
 LDA JOYPAD1
 AND #1
 BEQ readkeydone
 SEC
 LDA test_y
 SBC #1
 STA test_y
 JMP readkeydone
 
; DOWN
readdownkey:
 LDA JOYPAD1
 AND #1
 BEQ readkeydone
 ;LDA #$01
 ;STA vertical_force
 CLC
 LDA test_y
 ADC #1
 STA test_y
 JMP readkeydone
 
; LEFT
readleftkey:
 LDA JOYPAD1
 AND #1
 BEQ readkeydone
 LDA Sprite1_S ; Transform to subroutines
 ORA #%01000000
 STA Sprite1_S
 JSR CheckLeftCollision
 BNE readkeydone
 SEC
 LDA test_x;LDA Sprite1_X
 SBC #1
 STA test_x;STA Sprite1_X
 JMP readkeydone
 
; RIGHT
readrightkey:
 LDA JOYPAD1
 AND #1
 BEQ readkeydone
 LDA Sprite1_S
 AND #%10111111
 STA Sprite1_S
 JSR CheckRightCollision
 BNE readkeydone
 CLC
 LDA test_x;LDA Sprite1_X
 ADC #1
 STA test_x;STA Sprite1_X
 JMP readkeydone
 
readkeydone:
 RTS
 
; PPU Routine
LoadHighRow:
 ; A register: 0 or 2
 asl a
 asl a 							; multiply by 4 to get 0 or 8
 clc
 adc #$20 						; add to 20 to get the high address $2000 or $2800
 RTS

RowMultiply:
 ; A register: Vertical value
 ; var1: HighRow value
 LSR A
 LSR A
 LSR A							; divide by 8
 TAX
 LDA #$00
RowMultiplyLoop:				; Multiply X value times 32 ( 32 tiles in one row)
 CPX #$00						; Start by comparing if 0 then break out the loop immediatly
 BEQ exitRowMultiplyLoop
 CLC
 ADC #$20
 BCC skipIncHighRow				; if cycle back to 0 increase high_row address in Y
 INC var1
skipIncHighRow:
 DEX
 JMP RowMultiplyLoop
exitRowMultiplyLoop:
 RTS
 
ADY:
 CLC
 ADC #$01
 DEY
 CPY #$00
 BNE ADY
 RTS