;;--------------------------------------------------------------
;;-- boot.asm
;;-- 
;;-- This code runs at power-on because it is loaded to 
;;-- x0200 and the PC contains x0200 at power-on.
;;-- 
;;-- A skeleton booter:
;;-- A typical booter reads OS code into memory from disk, 
;;-- then jumps to the OS main(). Our LC3 simulator pretends
;;-- to do the load from disk by having the simulator load 
;;-- the OS code into simulated memory. Thus, all that is
;;-- left for our booter to do is to jump to the OS after
;;-- doing a little initialization for the OS. In the LC3,
;;-- R6 is the Stack Pointer (SP).
;;--------------------------------------------------------------

;;============= .TEXT (boot) ===================================

.ORIG x0200                  ;;-- Load to Boot area.

;;------------ boot() -------------
_boot:
    LD  R6 OS_stack        ;;--   Set SP to OS stack area.
    LD  R7 OS_main         ;;--   R7 <=== OS's main() address.
    JMP R7                 ;;--   jump to OS main().
                           ;;--   Never returns.

    OS_stack: .FILL xC000  ;;--   address OS stack area.
    OS_main: .FILL x8000  ;;--   points to OS main().

.END
