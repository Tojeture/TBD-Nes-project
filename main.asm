; NES header
 .inesprg 1 ; one (1) bank of program code
 .ineschr 1 ; one (1) bank of picture data
 .inesmap 0 ; we use mapper 0
 .inesmir 1 ; Mirror setting always 1.

; Constant
JOYPAD1 = $4016
JOYPAD2 = $4017

; Bank of interuption
 .bank 1
 .org $FFFA
 .dw VBlank_routine
 .dw Start
 .dw 0

; Bank of programming code
 .bank 0
; Set variable before changing to programming code
 .org $0000
 VBlankOrNo: .db 0
 L_byte: .db 0
 H_byte: .db 0
 Temp_X: .db 0
 Temp_Y: .db 0
 Death_Zone: .db 0
 INITIAL_POSITION_X: .db 0
 INITIAL_POSITION_Y: .db 0
 ; Collision
 Player_State: .db 0
 ; Hitbox
 Sprite1_X_prime: .db 0
 Sprite1_Y_prime: .db 0
 ; Scroll
 Vertical_scroll: .db 0
 Horizontal_scroll: .db 0
 .org $0300
 ;; OAM informations for sprite rendering
 ; Render info
 ; Sprite 1
 Sprite1_Y: .db $00 ;0300 Y position
 Sprite1_T: .db $00 ;0301 tiles number
 Sprite1_S: .db $00 ;0302 (flip,color)
 Sprite1_X: .db $00 ;0303 X position
 ; Sprite 2
 Sprite2_Y: .db $00 ;0304 Y position
 Sprite2_T: .db $00 ;0305 tiles number
 Sprite2_S: .db $00 ;0306 (flip,color)
 Sprite2_X: .db $00 ;0307 X position
 
 
 .org $8000

; Config ppu with one byte stored in the 2 ppu control register at $2000 & $2001 ( Start right after org $8000 for cpu programming)
Start:
 ;; NES CONFIG
 LDA #%10001000
 STA $2000
 LDA #%00011110
 STA $2001
 LDX #$00 ; clear X
 
; PALETTE
 LDA $2002
 LDA #$3F
 STA $2006
 LDA #$00
 STA $2006
  
loadpal:
 LDA palette, X
 STA $2007
 INX
 CPX #32
 BNE loadpal

; MAP
 LDA $2002
 LDA #$20
 STA $2006
 LDA #$00
 STA $2006
 
 LDA #LOW(Map)
 STA L_byte
 LDA #HIGH(Map)
 STA H_byte
 
 LDY #$00
 LDX #$00
Loadnames:
 LDA [L_byte], Y
 STA $2007
 INY
 CPY #$00
 BNE Loadnames
 INC H_byte
 INX
 CPX #$04
 BNE Loadnames

 ;; INIT VARIABLES
 LDA #$E6
 STA Death_Zone
 ; define Y position on init,sprite1,sprite2
 LDA #$26
 STA INITIAL_POSITION_Y
 STA Sprite1_Y
 STA Sprite2_Y
 ; define X position
 LDA #$40
 STA INITIAL_POSITION_X
 STA Sprite1_X
 LDA #$60
 STA Sprite2_X
 ; define other sprite related variables
 LDA #$00
 STA Sprite1_T
 STA Sprite2_T
 STA Sprite1_S
 LDA #%00000001 ; set the second palette for the second player
 STA Sprite2_S
 ; Screen scrolling
 STA Vertical_scroll
 STA Horizontal_scroll
 
; MAIN LOOP
update:
 LDA #$00
 LDX #$00
 LDY #$00
 
 JSR CheckGround
 ; check if character is in the grounded
 JSR CheckIfInGround
 
 ;JMP skipgravity ; TODO remove test of gravity
 LDA Player_State
 AND #%00000001 ; Check if the player is grounded
 BNE skipgravity
 ; first check if the Y value + acceleration is still colliding if so remove 1
 CLC
 LDA Sprite1_Y
 ADC #3
 STA Sprite1_Y
skipgravity:

 LDA Sprite1_Y
 CMP Death_Zone
 BNE skipresetposition
 LDA INITIAL_POSITION_X
 STA Sprite1_X
 LDA INITIAL_POSITION_Y
 STA Sprite1_Y
skipresetposition:

 JSR keypressed
 
WaitForVBlank:
 LDA VBlankOrNo
 CMP #1
 BNE WaitForVBlank
 DEC VBlankOrNo
 
 ; Register $2005 for scrolling
 LDA Horizontal_scroll
 STA $2005
 LDA Vertical_scroll
 STA $2005
 jmp update ; infinite loop

 .include "include/subroutines_collision.asm"
 .include "include/subroutines.asm"

;; RESOURCES ;;
palette:
 .incbin "palette.pal"
Map:
 .incbin "map.nam"
Attributes:
 .incbin "map_attr.atr"
Text: .db "Hello",0
BitMasks:
   .db %10000000
   .db %01000000
   .db %00100000
   .db %00010000
   .db %00001000
   .db %00000100
   .db %00000010
   .db %00000001
CollMap:
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03 ; 8th line
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03 ; 16th
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03
 .db $C0, $00, $00, $03 ; 24th
 .db $C3, $FF, $FF, $C3
 .db $C3, $FF, $FF, $C3
 .db $C3, $FF, $FF, $C3
 .db $C3, $FF, $FF, $C3
 .db $C3, $FF, $FF, $C3
 .db $C3, $FF, $FF, $C3 ; 30th ;; 11000011 11111111 11111111 11000011

; Bank of picture for the ppu
 .bank 2
 .org $0000
 .incbin "background.bkg"
 .incbin "sprite.spr"