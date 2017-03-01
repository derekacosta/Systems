;;--------------------------------------------------------------
;;-- user.asm
;;--
;;-- A skeleton user-mode program that calls putc() (i.e.,
;;-- TRAP x07). Obviously missing a loop to display the entire
;;-- string. Also, missing is an exit to return to OS (e.g.,
;;-- TRAP x25).
;;--------------------------------------------------------------

;;============= .TEXT (user) ===================================

.ORIG x1000     ;;-- loads to first page of user memory.

    trap x23 ;;-- call _lil_win.

.END
