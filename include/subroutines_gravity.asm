; Every frame we apply a vertical_force on the Y position.
ApplyVerticalForce:
 JSR CheckUpCollision
 BEQ SkipNullVertical
 LDA #1
 STA vertical_force
 LDA #0
 STA jump_force_cur
SkipNullVertical:
 CLC
 LDA Sprite1_Y
 ADC vertical_force
 STA Sprite1_Y
 RTS
 
; Once every 10 frame the gravity decrease the vertical_force
ApplyGravity:
 LDA Player_State
 AND #%00000001 ; Check if the player is grounded
 BNE NullVerticalForce
 LDA gravity_delay_cur
 ORA #0
 BNE GravityDelayStep
 LDA GRAVITY_DELAY
 STA gravity_delay_cur
 LDA vertical_force
 CMP GRAVITY_FORCE
 BEQ GravityDone
 INC vertical_force
 JMP GravityDone
GravityDelayStep:
 DEC gravity_delay_cur
 JMP GravityDone
NullVerticalForce:
 LDA #$00
 STA vertical_force
GravityDone:
 RTS