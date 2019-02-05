; Sprite hitbox and collision detection
 ; Specify hitbox values by adding 8 pixel to the x and y location
 CLC
 LDA Sprite1_X
 ADC #8
 STA Sprite1_X_prime
 CLC
 LDA Sprite1_Y
 ADC #8
 STA Sprite1_Y_prime
 
 ; detection of floor underneath both bottom hitbox
 ; X and Y_prime give the bottom-left hitbox
 ; Check if this hitbox collide with floor with collide data
 ; Convert this hitbox X and Y into collmap format, 4x30
 LDA Sprite1_Y_prime
 ADC #2
 LSR A
 LSR A
 LSR A ; Divide by 8
 ASL A
 ASL A ; Multiply by 4
 TAY
 LDA Sprite1_X
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
 LDA Sprite1_X
 LSR A
 LSR A
 LSR A ; divide by 8
 AND #7
 TAX
 
 CLC
 LDA CollMap, Y
 AND BitMasks, X
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
 ; detection of wall on both side with side-hitbox