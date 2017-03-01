;;-----------------------------------------------------------
;;-- OS.asm
;;-- 
;;-- A skeleton OS with one service, putc().
;;-- OS starts in main() and begins its intialization phase.
;;-- That phase calls each OS service's initialization routine.
;;-- The init_putc() routine sets putc()'s TRAP vector.
;;-- The OS, having completed its initialization phase, then
;;-- jumps to the user program.
;;--
;;-- putc() displays one character.
;;-- putc() gets its argument character via register R0.
;;-- putc() uses polling to see if the display is ready.
;;-- putc() is assigned the TVT slot x0007 (i.e., TRAP x07).
;;-------------------------------------------------------------

;;============== .TEXT (kernel) ===============================
.ORIG x5000                  ;;-- Load at start of OS space.

;------- OS main() ----------------
_main:
    JSR _init_putc           ;;--   initialization phase.
    LD  R7 USER_start        ;;--   prepare to jump to user.
    JMP R7                   ;;--   jump to USER space at x1000.
                             ;;--
    USER_start: .FILL x2000  ;;--   pointer to USER space.

;;------ init_putc() --------------
_init_putc:
    LD  R1 putc_TVT          ;;--   R1 <=== TVT slot address.
    LD  R0 putc_ptr          ;;--   R0 <=== putc()'s address.
    STR R0 R1 #0             ;;--   write VT: R0 ===> MEM[R1].
    jmp R7                   ;;--   return to OS main().
                             ;;--
    putc_TVT:   .FILL x0007  ;;--   points to putc()'s TVT slot.
    putc_ptr:   .FILL _putc  ;;--   points to putc().

;;------ _putc( R0 ) ------------------
_putc:
    ST R1 saved_R1          ;;--   save caller's R1 register.
    poll:                   ;;--   Do
    LDI R1 DSR_ptr          ;;--     read the DSR, R1 <=== DSR;
    BRzp poll               ;;--   until ready, DSR[15] == 1.
    STI R0 DDR_ptr          ;;--   display char, DDR <=== R0.
    LD R1 saved_R1          ;;--   restore caller's R1.
    JMP R7                  ;;--   return to caller.
                            ;;--
    DDR_ptr:  .FILL xFE06   ;;--   points to DDR.
    DSR_ptr:  .FILL xFE04   ;;--   points to DSR.
    saved_R1: .FILL x0000   ;;--   space for caller's R1.

.END
