; NES header
 .inesprg 1 ; one (1) bank of program code
 .ineschr 1 ; one (1) bank of picture data
 .inesmap 0 ; we use mapper 0
 .inesmir 0 ; Mirror setting always 1.

; Address Constant
PPU_ADDR = $2006
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
 ; RENDERING
 swapEnabled: .db 0
 worldRowValue: .db 0
 worldRowValueChanged: .db 0
 nametable: .db 0
 columnNumber: .db 0
 low_ppu_addr: .db 0
 high_ppu_addr: .db 0
 low_map: .db 0
 high_map: .db 0
 low_row: .db 0
 high_row: .db 0
 Temp_X: .db 0
 Temp_Y: .db 0
 ; COLLISION
 Player_State: .db 0
 vertical_force: .db 0
 jump_force_cur: .db 0
 gravity_delay_cur: .db 0
 gravity_force_cur: .db 0
 jump_velocity_cur: .db 0
 ; HITBOX
 Sprite1_X_prime: .db 0
 Sprite1_Y_prime: .db 0
 ; SCROLL
 scroll: .db 0
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
 ; Value Constant
 DEATH_ZONE: .db $E6
 INITIAL_POSITION_X: .db $40
 INITIAL_POSITION_Y: .db $B6
 JUMP_FORCE: .db $14
 JUMP_VELOCITY: .db $01
 GRAVITY_FORCE: .db $03
 GRAVITY_DELAY: .db $08
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
 
 ; INIT MAP
 LDA #$00
 STA nametable
 LDA #$EF
 STA scroll
 LDA #$5D
 STA worldRowValue
 
InitNametablesRendering:
 JSR DrawNewRow
 SEC
 LDA scroll
 SBC #$08
 STA scroll
 
 DEC worldRowValue
 LDA worldRowValue
 CMP #$3F
 BNE InitNametablesRendering
 ; Draw one more rows outside the screen in the buffering seam
 LDA #$02
 STA nametable
 LDA #$EF
 STA scroll
 DEC worldRowValue
 DEC worldRowValue					;Decrease another because 23A0 to 23C0 is not drawn, instead it is used for something else
 JSR DrawNewRow
 LDA #$00
 STA nametable
 
 
 ; INIT VARIABLES
 ; Physics
 LDA JUMP_FORCE
 STA jump_force_cur
 LDA GRAVITY_DELAY
 STA gravity_delay_cur
 ; define Y position on init,sprite1,sprite2
 LDA INITIAL_POSITION_Y
 STA Sprite1_Y
 STA Sprite2_Y
 ; define X position
 LDA INITIAL_POSITION_X
 STA Sprite1_X
 ADC #$08
 STA Sprite2_X
 ; define other sprite related variables
 LDA #$00
 STA Sprite1_T
 STA Sprite2_T
 STA Sprite1_S
 LDA #%00000001 ; set the second palette for the second player
 STA Sprite2_S
 
; MAIN LOOP
update:
 LDA #$00
 LDX #$00
 LDY #$00
 
 JSR CheckGround
 ; Check if character is in the grounded
 JSR CheckIfInGround
 ; Apply gravity
 JSR ApplyGravity
 ; Control input
 JSR keypressed
 ; ApplyVerticalForce
 JSR ApplyVerticalForce
 
 LDA Sprite1_Y
 CMP DEATH_ZONE
 BNE SkipResetPosition
 LDA INITIAL_POSITION_X
 STA Sprite1_X
 LDA INITIAL_POSITION_Y
 STA Sprite1_Y
SkipResetPosition:
 
WaitForVBlank:
 LDA VBlankOrNo
 CMP #1
 BNE WaitForVBlank
 DEC VBlankOrNo
 
 JSR ScrollingSeamRenderingCheck
 ; LDA Horizontal_scroll
 ; AND #%00000111
 ; BNE skipDrawSeam
 
;skipDrawSeam:

 JSR ContinuousScroll
 
 JSR CleanPPU
 
 jmp update ; infinite loop
 
 .include "include/subroutines_gravity.asm"
 .include "include/subroutines_collision.asm"
 .include "include/subroutines_rendering.asm"
 .include "include/subroutines.asm"

;; RESOURCES ;;
palette:
 .incbin "palette.pal"
; Map and attributes need to be the next 255 bytes
Map0:
 .incbin "map02.nam"
 .incbin "map01.nam"
 .incbin "map00.nam"
 
 
;Attributes:
 ;.incbin "map_attr.atr"

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
 .db $CF, $FF, $FF, $FF
 .db $C0, $00, $00, $0F
 .db $C0, $00, $00, $0F
 .db $C0, $00, $00, $0F 
 .db $FF, $FF, $FF, $CF
 .db $FC, $00, $23, $CF
 .db $FC, $00, $23, $CF
 .db $FC, $00, $20, $0F ; 8th line
 .db $FC, $00, $22, $3F
 .db $FC, $7F, $22, $23
 .db $C0, $0C, $22, $23
 .db $C0, $0C, $22, $23
 .db $C0, $0C, $F2, $23 
 .db $C0, $0C, $23, $E3
 .db $C0, $0F, $20, $03
 .db $C3, $FC, $20, $03 ; 16th
 .db $C0, $0C, $FF, $F3
 .db $C0, $0C, $30, $43
 .db $C0, $0F, $30, $43
 .db $FC, $0C, $33, $C7
 .db $C0, $0C, $F0, $03
 .db $C0, $0C, $00, $03
 .db $C0, $0C, $00, $03
 .db $C0, $0C, $00, $03 ; 24th
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