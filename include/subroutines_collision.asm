; Sprite hitbox and collision detection
 ; Specify hitbox(pixel) values to be tested if it touches the ground
CheckGround: ; Checkground subroutines
 ; Check the left side
 CLC
 LDA Sprite1_X
 ADC #2
 STA Sprite1_X_prime
 CLC
 LDA Sprite1_Y  ; When rendered the Y position is 1 pixel above the sprite
 ; add 1 pixel to align with top of the sprite, 8 pixel for below the feet and
 ; 1 pixel because rendering position is out of sync by 1 pixel with our array value
 ADC #10 
 STA Sprite1_Y_prime
 JSR CheckPixelCollision
 JSR SetGrounded
 ; Check the right side
 LDA Player_State
 AND #%00000001 ; Check if the player is grounded after the first check
 BNE SkipCheckGround ; if the left side is grounded we don't need double check
 CLC
 LDA Sprite1_X
 ADC #7
 STA Sprite1_X_prime
 CLC
 LDA Sprite1_Y
 ADC #10
 STA Sprite1_Y_prime
 JSR CheckPixelCollision
 JSR SetGrounded
SkipCheckGround:
 RTS
 
CheckPixelCollision:
 ; detection of floor underneath both bottom hitbox
 ; X and Y_prime give the bottom-left hitbox
 ; Check if this hitbox collide with floor with collide data
 ; Convert this hitbox X and Y into collmap format, 4x30
 LDA Sprite1_Y_prime
 LSR A
 LSR A
 LSR A ; Divide by 8
 ASL A
 ASL A ; Multiply by 4
 TAY
 LDA Sprite1_X_prime
 ; Divide by 64 function
 LDX #$00
divide:
 LSR A
 INX
 CPX #$06
 BNE divide
 
 CLC
 STY Temp_Y
 ADC Temp_Y
 TAY
 
 ; Now we get the right collmap info with index in Y register
 ; and we check the x position compared to the collmap data with bitMasks helper
 LDA Sprite1_X_prime
 LSR A
 LSR A
 LSR A ; divide by 8
 AND #7
 TAX
 
 CLC
 LDA CollMap, Y
 AND BitMasks, X
 RTS
 
SetGrounded:
 BNE isGrounded
 LDA Player_State
 AND #%11111110
 STA Player_State
 JMP GroundChkDone
isGrounded:
 LDA Player_State ; Load the Player_State information in X
 ORA #%00000001
 STA Player_State ; Overwrite the modified Player_State
GroundChkDone:
 RTS
 
CheckIfInGround:
 LDA Player_State
 AND #%00000001
 BEQ SkipCheckIfInGround
 
 LDA Sprite1_X
 STA Sprite1_X_prime
 LDA Sprite1_Y
 ADC #9
 STA Sprite1_Y_prime
 JSR CheckPixelCollision
 BEQ SkipCheckIfInGround
 SEC
 LDA Sprite1_Y
 SBC #1 ; Go up one sprite until it is back on ground
 STA Sprite1_Y
 
SkipCheckIfInGround:
 RTS

; TODO : Merge both side in one subroutines
; Wall subroutines
 ; detection of wall on both side with side-hitbox
CheckLeftCollision
 CLC
 LDA Sprite1_X
 ADC #1
 STA Sprite1_X_prime
 CLC
 LDA Sprite1_Y
 ADC #1 ; world position sync
 STA Sprite1_Y_prime
 JSR CheckPixelCollision
 BNE SkipLeftCheck
 CLC
 LDA Sprite1_Y
 ADC #8 ; word position sync + 7 pixel
 STA Sprite1_Y_prime
 JSR CheckPixelCollision
SkipLeftCheck:
 RTS
 
CheckRightCollision
 CLC
 LDA Sprite1_X
 ADC #8
 STA Sprite1_X_prime
 CLC
 LDA Sprite1_Y
 ADC #1
 STA Sprite1_Y_prime
 JSR CheckPixelCollision
 BNE SkipRightCheck
 LDA Sprite1_Y
 ADC #8 ; world position sync + 7 pixel
 STA Sprite1_Y_prime
 JSR CheckPixelCollision
SkipRightCheck:
 RTS