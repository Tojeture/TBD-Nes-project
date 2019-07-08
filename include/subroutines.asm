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
 LDA Vertical_scroll
 ADC #1
 STA Vertical_scroll
 JMP ReadABDone
 
ReadABDone:
 RTS
 
; UP
readupkey:
 LDA JOYPAD1
 AND #1
 BEQ readkeydone
 ; SEC
 ; LDA Sprite1_Y
 ; SBC #2
 ; STA Sprite1_Y
 JMP readkeydone
 
; DOWN
readdownkey:
 LDA JOYPAD1
 AND #1
 BEQ readkeydone
 LDA #$01
 STA vertical_force
 ; LDA Sprite1_Y
 ; ADC #1
 ; STA Sprite1_Y
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
 LDA Sprite1_X
 SBC #1
 STA Sprite1_X
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
 LDA Sprite1_X
 ADC #1
 STA Sprite1_X
 JMP readkeydone
 
nextkeyread:
 LDA JOYPAD1
 AND #1
 BEQ readkeydone
 RTS
 
readkeydone:
 RTS