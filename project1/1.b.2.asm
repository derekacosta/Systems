.ORIG x3000

	;; Positive Integer Division
	;; R4 <- R1 / R2

Start	AND     R3, R3, 0   ; clear R3
	AND 	R4, R4, 0   ; clear R4, as temp

	NOT     R3, R2      ; R3 <-- R2
	ADD     R3, R3 #1   ; add one to get two's compliment

Repeat	ADD     R4, R4, #1  ; Add 1 to R4 repeatedly
	ADD     R1, R1, R3  ; Subtract R2 from R1
	BRn     Done
	BRzp    Repeat

Done	ADD     R4, R4, #-1 	; answer

	HALT ; if we get here, we're done
