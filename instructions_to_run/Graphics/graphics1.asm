;;---------------------------
;;--  graphics1.asm
;;--
;;-- LC3 memory-mapped graphics: Vector graphics.
;;-- Memory-mapped means the video display's data memory,
;;-- VRAM, is accessed via Load/Store instructions.
;;-- Vector graphics draws lines or other shapes 
;;-- to create an image.
;;--
;;-- Below, each assembly language statement is
;;-- interpreted in the line comments as its psuedo-C 
;;-- equivalent to aid understanding.
;;-- Of course, this interpretation cannot be absolutely
;;-- correct, but it should help you grasp the intent.
;;--
;;-- Caveat: This program goes into an infinite loop. It
;;-- is intended to be run in the LC3 simulator PennSim;
;;-- execute one instruction at a time using STEP.
;;--
;;-- Constants:
;;-- R4 is the Global Data Pointer (GDP).
;;-- R1 is the number of VRAM cols per row (COLS). 
;;-- R3 is the pixel value for 100% red (RED).
;;--
;;-- Variables:
;;-- R0 is the pointer int VRAM (vram).
;;-- R2 is the pixel color (color).
;;-- R6 is the stack pointer (sp).
;;--
;;-- The "Global Data Table" (GDT) holds all the program's
;;-- initial data.
;;----------------------------
 
.ORIG x0200

;;========== TEXT =========================================

Entry:
    BRnzp Preamble        ;;-- goto Preamble

GDT_address:              ;;-- 
    .FILL GDT             ;;-- const GDT_address ==  & GDT

Preamble:                 ;;====== Preamble =============
    LD  R4, GDT_address   ;;-- const GDP = GDT_address
    LDR R6, R4, #0        ;;-- sp        = GDT[0] == Stack bottom
                          ;;--

Main:                     ;;====== Main =================

                          ;;---------- Initialize Constants:
    LDR R1, R4, #7        ;;-- const COLS  = GDT[7] == x80
    LDR R3, R4, #3        ;;-- const RED   = GDT[3] == RED == x7C00

                          ;;---------- Initialize Variables:
    LDR R0, R4, #6        ;;-- vram  = GDT[6] == & VRAM == xC000
    LDR R2, R4, #4        ;;-- color = GDT[4] == GREEN  == x03E0

                          ;;---------- make color yellow:
    ADD R2, R2, R3        ;;-- color = color + RED

                          ;;---------- Draw diagonal line:
Loop:                     ;;-- Repeat
    STR R2, R0, #0        ;;--    *vram = color   ( MEM[ R0+0 ] <=== R2      )
    ADD R0, R0, R1        ;;--    vram += COLS    ( R0          <=== R0 + R1 )
    ADD R0, R0, #1        ;;--    vram++          ( R0          <=== R1 + 1  )
    BRnzp Loop            ;;-- Forever


;;========== DATA =========================================

GDT:

;;-- identifier      value           table offset   description
;;-------------      ------         -------------  ---------------
    StackBot:   .FILL x3000    ;;--- (offset = 0)  Bottom of Stack
    WHITE:      .FILL x7FFF    ;;--- (offset = 1)  White
    BLACK:      .FILL x0000    ;;--- (offset = 2)  Black
    RED:        .FILL x7C00    ;;--- (offset = 3)  Red
    GREEN:      .FILL x03E0    ;;--- (offset = 4)  Green
    BLUE:       .FILL x001F    ;;--- (offset = 5)  Blue
    VRAM:       .FILL xC000    ;;--- (offset = 6)  start of VRAM
    VRAM_cols:  .FILL x0080    ;;--- (offset = 7)  cols per VRAM row


.END
