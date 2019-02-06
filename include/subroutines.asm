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
 
 LDA JOYPAD1 ;A
 LDA JOYPAD1 ;B
 LDA JOYPAD1 ;SELECT
 LDA JOYPAD1 ;START
 JSR readupkey
 JSR readdownkey
 JSR readleftkey
 JSR readrightkey
 RTS
 
; UP
readupkey:
 LDA JOYPAD1
 AND #1
 BEQ readkeydone
 SEC
 LDA Sprite1_Y
 SBC #2
 STA Sprite1_Y
 JMP readkeydone
 
; DOWN
readdownkey:
 LDA JOYPAD1
 AND #1
 ; BEQ readkeydone
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