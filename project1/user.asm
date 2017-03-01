;;--------------------------------------------------------------
;;-- user.asm
;;--
;;-- A skeleton user-mode program that calls putc() (i.e., 
;;-- TRAP x07). Obviously missing a loop to display the entire
;;-- string. Also, missing is an exit to return to OS (e.g.,
;;-- TRAP x25).
;;--------------------------------------------------------------

;;============= .TEXT (user) ===================================

.ORIG x2000     ;;-- loads to first page of user memory.

        AND R3 R3 #0 ;;initialize
        LD R3 msgPtr ;;loads contents of msgPtr to R3
        LDR R0 R3 #0 ;;loads it with register for direct access

LOOP 	TRAP x07    ;;-- call putc( R0 ).
	ADD R3 R3 #1 ;;increment
	LDR R0 R3 #0 ;;loads R0 with updated value 
	;;LD R0 msg   ;;-- load 1st char as argument for putc().
	BRp LOOP
    
	TRAP x25

    msg:  .STRINGZ "hello world"
    msgPtr .FILL msg    

.END
