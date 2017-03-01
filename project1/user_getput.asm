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

 get	LDI	R1, AA	;Loop if Ready not set     
	BRzp	get     
	LDI	R0, BB	;If set, load char to R0    
	BR	put
 AA	.FILL	xFE00	;Address of KBSR
 BB	.FILL	xFE02	;Address of KBDR


put	LDI	R1, A	;Loop if Ready not set      
 	BRzp	put      
 	STI	R0, B	;If set, send char to DDR
 	BRnzp get ; replace 
 A	.FILL	xFE04	;Address of DSR
 B	.FILL	xFE06	;Address of DDR


.END
