;;---------------------------
;;--  graphics2.asm
;;--
;;-- LC3 memory-mapped graphics: pixel graphics.
;;-- Pixel graphics draws shapes by mapping colors
;;-- to pixels from some source.
;;--
;;-- The "Global Data Table" (GDT) holds the program's
;;-- INITIAL DATA, CONSTANTS, and GLOBAL VARIABLES.
;;--
;;-- Local variables are on the stack.
;;-- Procedure calls access global variables as arguments.
;;-- 
;;-- Nomenclature:
;;-- 
;;-- Constants in CAPS, variables in lower-case, address 
;;-- labels have trailing "_" (would have used "&", but 
;;-- assembler choked). Address label also denotes the 
;;-- address itself.
;;-- 
;;-- "sp" is top-of-stack pointer, "bp" is base-of-frame pointer.
;;-- Seeing the same comment on adjacent lines of code means
;;-- what is decribed by the comments requires multiple 
;;-- instructions.
;;----------------------------
 
.ORIG x0200

;;========== TEXT =========================================

Entry_:
    BRnzp Preamble_       ;;-- goto Preamble

GDT_address_:             ;;-- 
    .FILL GDT_            ;;-- const GDT_address ==  GDT_

Preamble_:                ;;====== Preamble =============
    LD  R4, GDT_address_  ;;-- GDP <=== GDT_
    LDR R6, R4, #0        ;;-- sp  <=== STACKBOT  ( == GDT[0] )
    LDR R5, R4, #0        ;;-- bp  <=== STACKBOT  ( == GDT[0] )

Main_:                    ;;====== Main =================
                          ;;--
                          ;;-- ENTER:
    ADD R6, R6, #-1       ;;--     sp--   (allocate space for local var i;)
                          ;;--            (i is accessed via bp - 1.)
                          ;;--
                          ;;-- initialize char, a pointer to string buffer:
    LDR R0, R4, #-1       ;;--   R0 <=== & msg   ( == GDT[-1] )
    STR R0, R4, #12       ;;--   R0 ===> char    ( == GDT[12]   )
                          ;;--
                          ;;-- initialize charPix pointer:
                          ;;--   IF ( *char == 'A' )
    LDR R0, R4, #12       ;;--     R0 <=== char 
    LDR R1, R0, #0        ;;--     R1 <=== *char   ( == msg[0]  )
    LDR R2, R4, #19       ;;--     R2 <=== 'A'     ( == GDT[19] )
    NOT R2, R2            ;;--     negate( R2 )
    ADD R2, R2, #1        ;;--     negate( R2 )
    ADD R2, R1, R2        ;;--     R2 <=== *char - 'A'
    BRnp ELSE_0           ;;--     (R2 != 0)? goto ELSE
                          ;;--   THEN
    LDR R0, R4, #9        ;;--     R0 <=== CHAR_A  ( == GDT[9]  )
    STR R0, R4, #11       ;;--     R0 ===> charPix ( == GDT[11] )
    BR  ENDIF_0           ;;--   
    ELSE_0:               ;;--    ELSE
    LDR R0, R4, #10       ;;--     R0 <=== CHAR_B  ( == GDT[10] )
    STR R0, R4, #11       ;;--     R0 ===> charPix ( == GDT[11] )
    ENDIF_0:              ;;--    ENDIF
                          ;;--
                          ;;-- initialize vram pointer:
    LDR R0, R4, #6        ;;--   R0 <=== VRAM    ( == GDT[6]  )
    STR R0, R4, #8        ;;--   R0 ===> vram    ( == GDT[8]  )
                          ;;--
                          ;;-- initialize counter i = -CHAR_ROWS:
    LDR R0, R4, #16       ;;--   R0 <=== CHAR_ROWS  ( == GDT[16]     )
    NOT R0, R0            ;;--   negate R0
    ADD R0, R0, #1        ;;--   negate R0
    STR R0, R5, #-1       ;;--   -CHAR_ROWS  ===> i ( R0 ===> Mem[bp-1] )
                          ;;--
    LOOP0:                ;;-- Loop
                          ;;--
                          ;;--   call writeRow( vram, charPix ):
    LEA R7, RET_0         ;;--     R7 <=== RET_0     ( == return address )
    LDR R0, R4, #18       ;;--     R0 <=== writeRow_ ( == GDT[18]        )
    JMP R0                ;;--     PC <=== R0
    RET_0:                ;;--
                          ;;--   advance vram to next row:
    LDR R0, R4, #8        ;;--     R0 <=== vram    ( == GDT[8]  )
    LDR R1, R4, #7        ;;--     R1 <=== COLS    ( == GDT[7]  )
    ADD R0, R0, R1        ;;--     R0 <=== vram + COLS
    STR R0, R4, #8        ;;--     R0 ===> vram
                          ;;--
                          ;;--   advance charPix to next row:
    LDR R0, R4, #11       ;;--     R0 <=== charPix   ( == GDT[11] )
    LDR R1, R4, #17       ;;--     R1 <=== CHAR_COLS ( == GDT[17] )
    ADD R0, R0, R1        ;;--     R0 <=== charPix + CHAR_COLS  
    STR R0, R4, #11       ;;--     R0 ===> charPix
                          ;;--
                          ;;--   increment i:
    LDR R3, R5, #-1       ;;--     R3 <=== i     ( == Mem[bp-1] )
    ADD R3, R3, #1        ;;--     R3++
    STR R3, R5, #-1       ;;--     R3 ===> i
                          ;;--
    BRn LOOP0             ;;-- Until (i == 0)
                          ;;--
                          ;;-- LEAVE:
                          ;;--
    ADD R6, R5, #0        ;;--   restore sp. 

exit_:                    ;;-- We don't know what to do here yet.
    BR exit_              ;;-- Let's just hang in a loop. Commonly, this is
                          ;;-- where we would find our way back to the OS.

                          ;;====== Sub-Routines =================

                          ;;--------------------------------------
writeRow_:                ;;------ writeRow( )
                          ;;------
                          ;;------   Uses globals as arguments:
                          ;;------     ( pixel *vram, pixel *charPix )
                          ;;------   Writes a row of pixels from font
                          ;;------   buffer to VRAM.
                          ;;------   Clobbers R0-R3. Returns via R7.
                          ;;------   R3 is loop index variable.
                          ;;------
    LDR R0, R4, #8        ;;-- R0 <=== vram
    LDR R1, R4, #11       ;;-- R1 <=== charPix
                          ;;-- 
                          ;;-- R3 <=== -CHAR_COLS:
    LDR R3, R4, #17       ;;--    R3 <=== CHAR_COLS   ( == GDT[17])
    NOT R3, R3            ;;--    negate R3
    ADD R3, R3, #1        ;;--    negate R3
                          ;;-- 
    LOOP1:                ;;-- LOOP
                          ;;-- 
    LDR R2, R1, #0        ;;--   R2 <=== *charPix
    STR R2, R0, #0        ;;--   R2 ===> *vram
    ADD R1, R1, #1        ;;--   charPix++
    ADD R0, R0, #1        ;;--   vram++
                          ;;-- 
    ADD R3, R3, #1        ;;--   R3++
    BRn LOOP1             ;;-- Until (R3 == 0)
                          ;;-- 
    JMP R7                ;;-- return()  ( PC <=== R7 )


;;========== DATA =========================================

;;-------------------------------------------------------
;;------------- range of offset is -33 < immed6 < 32 ----
;;-------------------------------------------------------
;;-------------          offset  name               description
;;-------------          ------  --------           -------------
    .FILL msg_      ;;--- ( -1)  const & msg        pointer to msg
GDT_:
    .FILL x3000     ;;--- (  0)  const STACKBOT     Bottom of Stack
    .FILL x7FFF     ;;--- (  1)  const WHITE
    .FILL x0000     ;;--- (  2)  const BLACK
    .FILL x7C00     ;;--- (  3)  const RED
    .FILL x03E0     ;;--- (  4)  const GREEN
    .FILL x001F     ;;--- (  5)  const BLUE
    .FILL xC000     ;;--- (  6)  const VRAM         start of VRAM
    .FILL x0080     ;;--- (  7)  const COLS         columns per VRAM row
    .BLKW 1         ;;--- (  8)  var   vram         pointer into VRAM
    .FILL Char_A_   ;;--- (  9)  const CHAR_A       address of 'A' font buffer
    .FILL Char_B_   ;;--- ( 10)  const CHAR_B       address of 'B' font buffer
    .BLKW 1         ;;--- ( 11)  var charPix        pointer into char pixel buffer
    .BLKW 1         ;;--- ( 12)  var char           pointer to char buffer
    .BLKW 1         ;;--- ( 13)  var vram_row       cursor row in VRAM
    .BLKW 1         ;;--- ( 14)  var vram_col       cursor column in VRAM
    .FILL x0000     ;;--- ( 15)  const 0            value 0
    .FILL x0009     ;;--- ( 16)  const CHAR_ROWS    num rows per char buffer
    .FILL x0007     ;;--- ( 17)  const CHAR_COLS    num cols per char buffer
    .FILL writeRow_ ;;--- ( 18)  const writeRow     function pointer
    .FILL x0041     ;;--- ( 19)  const ASCII_A      ASCII code for 'A'
    .FILL x0042     ;;--- ( 20)  const ASCII_B      ASCII code for 'B'



msg_:
    .FILL x0042     ;;--- msg[0] == 'B'
    .FILL x0041     ;;--- msg[1] == 'A'
    .FILL x0042     ;;--- msg[2] == 'B'
    .FILL x0000     ;;--- msg[3] == '\NUL'

Char_A_:         ;;--- start of 'A' buffer
                 ;;-- Arow0:    . . . . . . .
                 ;;-- Arow1:    . . # # # . .
                 ;;-- Arow2:    . # . . . # .
                 ;;-- Arow3:    . # . . . # .
                 ;;-- Arow4:    . # # # # # .
                 ;;-- Arow5:    . # . . . # .
                 ;;-- Arow6:    . # . . . # .
                 ;;-- Arow7:    . # . . . # .
                 ;;-- Arow8:    . . . . . . .
Arow0:
        .FILL x7FFF         
        .FILL x7FFF         
        .FILL x7FFF         
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7FFF
Arow1:
        .FILL x7FFF 
        .FILL x7FFF 
        .FILL x7c00 
        .FILL x7c00 
        .FILL x7c00 
        .FILL x7FFF
        .FILL x7FFF 
Arow2:
        .FILL x7FFF 
        .FILL x7c00 
        .FILL x7FFF 
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7c00 
        .FILL x7FFF 
Arow3:
        .FILL x7FFF 
        .FILL x7c00 
        .FILL x7FFF 
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7c00 
        .FILL x7FFF 
Arow4:
        .FILL x7FFF 
        .FILL x7c00 
        .FILL x7c00 
        .FILL x7c00 
        .FILL x7c00 
        .FILL x7c00 
        .FILL x7FFF 
Arow5:
        .FILL x7FFF 
        .FILL x7c00 
        .FILL x7FFF 
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7c00 
        .FILL x7FFF 
Arow6:
        .FILL x7FFF 
        .FILL x7c00 
        .FILL x7FFF 
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7c00 
        .FILL x7FFF 
Arow7:
        .FILL x7FFF 
        .FILL x7c00 
        .FILL x7FFF 
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7c00 
        .FILL x7FFF 
Arow8:
        .FILL x7FFF 
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7FFF 

Char_B_:         ;;--- start of 'B' buffer
                 ;;-- Brow0:    . . . . . . .
                 ;;-- Brow1:    . # # # # . .
                 ;;-- Brow2:    . # . . . # .
                 ;;-- Brow3:    . # . . . # .
                 ;;-- Brow4:    . # # # #   .
                 ;;-- Brow5:    . # . . . # .
                 ;;-- Brow6:    . # . . . # .
                 ;;-- Brow7:    . # # # # . .
                 ;;-- Brow8:    . . . . . . .
Brow0:
        .FILL x7FFF         
        .FILL x7FFF         
        .FILL x7FFF         
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7FFF
Brow1:
        .FILL x7FFF 
        .FILL x7c00 
        .FILL x7c00 
        .FILL x7c00 
        .FILL x7c00 
        .FILL x7FFF
        .FILL x7FFF 
Brow2:
        .FILL x7FFF 
        .FILL x7c00 
        .FILL x7FFF 
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7c00 
        .FILL x7FFF 
Brow3:
        .FILL x7FFF 
        .FILL x7c00 
        .FILL x7FFF 
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7c00 
        .FILL x7FFF 
Brow4:
        .FILL x7FFF 
        .FILL x7c00 
        .FILL x7c00 
        .FILL x7c00 
        .FILL x7c00 
        .FILL x7FFF 
        .FILL x7FFF 
Brow5:
        .FILL x7FFF 
        .FILL x7c00 
        .FILL x7FFF 
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7c00 
        .FILL x7FFF 
Brow6:
        .FILL x7FFF 
        .FILL x7c00 
        .FILL x7FFF 
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7c00 
        .FILL x7FFF 
Brow7:
        .FILL x7FFF 
        .FILL x7c00 
        .FILL x7c00 
        .FILL x7c00 
        .FILL x7c00 
        .FILL x7FFF 
        .FILL x7FFF 
Brow8:
        .FILL x7FFF 
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7FFF
        .FILL x7FFF 

.END
