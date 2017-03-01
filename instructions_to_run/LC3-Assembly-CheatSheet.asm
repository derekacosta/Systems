;;;=========== LC3 Assembly Cheat Sheet ==================================
;;; Assembly language as defined by lc3as and lc3pre.
;;; This documents LC3 assembly language in as-an-example form. This file
;;; is assembly source code with comments: it can be assembled.
;;; It covers all elements of LC3 assembly language, including lc3pre,
;;; our pre-processor's language extenstions. 
;;; To make the semantics clear, addresses of assembled code are shown
;;; in the per-line comments. Labels are case insensitive.
;;; THIS IS A COMMENT, from first " ;" to end of line is deleted/ignored.
;;; Blank space and lines are also ignored. 
;;; The code below is in sections:
;;; -- Offsets and Labels (Also see "Symbol Table") 
;;; -- Jumps, Calls, Interrupts
;;; -- Load/Store, Push/Pop, and Operate
;;; -- Constants
;;; -- Symbol Table
;;;=================================================================

;;;=====( Offsets and Labels )======================================
.orig x0200   ;---- Assembler directive: code's load location at runtime,
              ;----  if there is a loader that reads the .obj header.
nop           ;----[x0200] br 0, 9-bit off = 0.
br #15        ;----[x0201] PC <== PC+off == PC+15 == x0211
br done       ;----[x0202] PC <== PC+(done - PC) == x0207
br andDone    ;----[x0203] off = (andDone - PC), PC <== x0207
ld r5, xF     ;----[x0204] R5 <== Mem[ PC+15 ], 9-bit off.
ld r5, data   ;----[x0205] R5 <== Mem[ PC + (data-PC) ]
br #-1        ;----[x0206] PC <== (x0207 - 1) == x0206.

done:         ;---- Assembly Label: address of next code or data line.
andDone       ;---- Assembly Label: address of next code or data line.
halt          ;----[x0207] = trap x25

data: .fill x00ff    ;----[x0208] Assembler directive: insert x00ff into this word.
buff: .blkw #4       ;----[x0209] Assembler directive: insert x0000 into 4 words.
msg:  .stringz "12"  ;----[x020C] = .fill x0031 .fill x0032 .fill x0000
                     ;----       which is ascii '1' '2' NUL, left zero-extended.

;;;=====( Jumps, Calls, Interrupts )====================================
foo:
             ;---- reg write sets PSR.CC
BR  foo      ;---- PC <== PC + (foo-PC) == foo
BRn foo      ;---- PC <== foo if PSR.CC.n == 1 
BRz foo      ;---- PC <== foo if PSR.CC.z == 1
BRp foo      ;---- PC <== foo if PSR.CC.p == 1
BRnp foo     ;---- PC <== foo if (PSR.CC.p == 1 OR PSR.CC.n = 1)
ret          ;---- jmp r7
lea r5, foo  ;---- R5 <== PC+(foo-PC); (9-bit off)
jmp r5       ;---- PC <== R5
jsr foo      ;---- PC <== PC+offset (11-bit offset), R7 <== PC (in parallel).
jsrr r5      ;---- PC <== R5, R7 <== PC (in parallel)
trap x10     ;---- PC <== Mem[ x0010 ], R7 <== PC (in parallel)

jsr__(foo)     ;---- push( r7 ), jsr foo, pop( r7 )
jsrr__(r4)     ;---- push( r7 ), jsrr r4, pop( r7 )
trap__(x13)    ;---- push( r7 ), trap x13, pop( r7 )
intsOff__      ;---- trap(x0) :  PSR.Prio <== 7
intsOn__       ;---- trap(x1) :  PSR.Prio <== 0

msg2:   .stringz "Some ascii chars"
buf:    .fill x0000
getc__         ;---- trap(x20):  R0 <== KBDR, get char
st r0, buf
putc__         ;---- trap(x21):  DDR <== R0, display char
out__          ;---- trap(x21):  putc
lea r0, msg
puts__         ;---- trap(x22):  display_string( r0 )
halt__         ;---- trap(x25):  MCR <== STOP_CLOCK

rti            ;----  pop(PC,   PSR), swap sp
;<INTERRUPT>   ;---- push(PC-1, PSR), swap sp, PSR.mode=0, PC<==MEM[vec]
;<EXCEPTION>   ;---- push(PC-1, PSR), swap sp, PSR.mode=0, PC<==MEM[vec] 
               ;---- keyboard interrupt vec = x0180
               ;---- non-keyboard interrupt vec = x0181
               ;---- privilege exception vec = x0100
               ;---- illegal opcode exception vec = x0101

;;;=====( Load/Store, Push/Pop, and Operate )==============================
ptr: .fill x1234
ld r5, data      ;---- R5 <== Mem[ data ] (9-bit off).
ldr r5, r4, #5   ;---- R5 <== Mem[ R4+5 ] (6-bit off).
ldi r5, ptr      ;---- R5 <== Mem[ Mem[ ptr ] ] (6-bit off)
                 ;---- st, str, sti: similarly
                   ;---- sp == r6 
push__(r5)         ;---- dec( sp ), MEM[ sp ] <== r5
pop__(r5)          ;---- r5 <== MEM[ sp ], inc( sp )

not r1, r2       ;---- R1 <== bit-wise negation of R2
and r1, r2, r3   ;---- bit-wise AND, reg-reg-reg addressing
add r1, r2, #13  ;---- reg-reg-immed addressing, 5-bit immed. in decimal.
add r1, r2, x13  ;---- reg-reg-immed addressing, immed. in hexadecimal.
add r1, r2, 13   ;---- constant defaults to decimal.
                 ;---- all constants are left sign-extended.
zero__(r2)         ;---- r2 <== 0
mov__(r3, r5)      ;---- r3 <== r5
inc__(r7)          ;---- add r7, r7, 1
dec__(r7)          ;---- add r7, r7, -1
sub__(r1, r2, r3)  ;---- r1 <== (r2 - r3)
or__(r1, r2, r3)   ;---- r1 <== (r2 OR r3)

;;;=====( Constants )===================================

bar: .fill bits__0101__1100__1011__1111__ ;---- .fill x5CBF
     .fill 15                             ;---- 15 in decimal
     .fill x000F                          ;---- ditto
     .fill #15                            ;---- ditto
and r5, r5, bits__bit1__1101__            ;---- and, r5, x1D
     .fill x000A   ;---- x0A, ascii CR, "carriage return" end-of-line char
     .fill x000D   ;---- x0D, ascii LF, "line feed" end-of-line char
     .fill x0020   ;---- x20, ascii SP, space " " char
     .fill x0030   ;---- x30, ascii '0'
     .fill x0041   ;---- x41, ascii 'A'
     .fill x0061   ;---- x61, ascii 'a'

.END          ;---- Assembler directive: end of source code.
;;;=====( Symbol Table )===================================
;---------------------------------------
;-- Everything below ".END" is ignored by the assembler.
;--    lc3as LC3-assemblyCheatSheet.asm 
;-- produces two files: 
;--    LC3-assemblyCheatSheet.obj
;--    LC3-assemblyCheatSheet.sym 
;-- The latter has been included below.
;-- NB--Addresses are x0200+offset: ".ORIG x0200"
;-- set the starting location counter, LC, to x0200. To
;-- get a symbol table of pure offsets, use ".ORIG x0000".
;---------------------------------------
// Symbol table
// Scope level 0:
//	Symbol Name       Page Address
//	----------------  ------------
//	nop               0200
//	done              0206
//	andDone           0206
//	data              0207
//	buff              0208
//	msg               020C
//	foo               020F
//	msg2              0233
//	buf               0244
//	ptr               0261
//	bar               027E
