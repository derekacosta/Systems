.ORIG x3000
; multiply 
; RO <- R1 * R2

start 	AND R0, R0, #0 ; initialize R0 to zero
LOOP	ADD R0, R0, R1 ; add R1 to the running sum
		ADD R2, R2, #-1; subtract 1 from R2
 		BRzp LOOP ; if positive, keep looping
 		HALT ; if we get here, we're done

