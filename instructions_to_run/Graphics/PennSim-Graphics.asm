.ORIG x0200
    LD R4, PTR
    BRnzp MAIN
PTR:
    .FILL DATA
MAIN:
    LDR R0, R4, #0   ;-- red
    LDR R3, R4, #4   ;-- VRAM
    STR R0, R3, #0   ;-- (123, 127)
    STR R0, R3, #-1  ;-- (123, 126)
    STR R0, R3, #-2  ;-- (123, 125)
    STR R0, R3, #-3  ;-- (123, 124) 
    STR R0, R3, #-4  ;-- (123, 123) 
    STR R0, R3, #-5  ;-- (123, 122) 
DATA:
    .FILL x7C00   ;-- 0RRR RR00 0000 0000
    .FILL x03E0   ;-- 0000 00GG GGG0 0000
    .FILL x001F   ;-- 0000 0000 000B BBBB
    .FILL xC000   ;-- Start of VRAM
    .FILL xFDFF   ;-- end of VRAM
.END
