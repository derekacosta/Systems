

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; main procedure ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; loads data from file and computes sum of the magnitude
;; (abs value) of all values in file.
;; Store result in R4

.ORIG x3000




;; Preamble
;; need pointer to filestart to load data, given ISA

FileStartPtr 	.FILL FileStart
MEANMAGPtr	.FILL MEANMAG
FileSizePtr	.FILL FileSize
neg2posPtr .FILL x3027
returnPtr	.FILL ACC

;; clear regs 0 - 4 for usage
	AND R0 R0 x0 		;R0 <- loaded value
	AND R1 R1 x0		;R1 <- accumulator
	AND R2 R2 x0		;R2 <- address of filestart
	AND R3 R3 x0		;R3 <- file size
	AND R4 R4 x0		;R4 : used to pass arg

	;; compute addition
	;; sequentially add file contents, if number is neg
	;; branch to neg2pos to convert to pos representation

		LD 	R6 returnPtr
		LD 	R5 neg2posPtr
		LD	R2 FileStartPtr	; load starting address
		LD	R3 FileSizePtr	; load filesize as counter
COND		ADD	R3 R3 #-1		; decrement counter
		BRn	END				; computation complete
START
		LDR	R0 R2	 #0	; RO <- M[R2]
		ADD	R2 R2 #1	; increment to next data item
		ADD	R4 R0 #0	; R4 used as shared memory to
					; pass args (may not be necessary)
		BRn	JUMP	   ; if neg convert2pos before add

ACC		ADD	R0 R4 #0	; R4 used as shared memory to
					; pass args (may not be necessary)
		ADD	R1 R1 R0	; Accumulate positive value
		BRnzp COND

END		LD	R2 MEANMAGPtr	; load address for mean
		STR	R1 R2 #0		; M[R1] <- R2
		HALT					; the end

JUMP
			JMP R5
;;
;; Leave space for future code
;;	.BLKW #300   ;<------------------- LOOK HERE


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;    neg2pos   ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; sub routine that converts neg to pos
;; assumes input is passed by reg 3,
;; ouput also passed in reg 3
;; R3 <== -R3
;; Compute 2's complement of R3


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;  Data File ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



FileSize	.FILL #10		;num data in file
FileStart	.FILL x0001	;first data item
		.FILL x0002
		.FILL x0003
		.FILL x0004
		.FILL x0050
		.FILL xFFCC
		.FILL xFFFF
		.FILL x0080
		.FILL x0000
		.FILL xFFFF	;last data item


MEANMAG	.BLKW		1	; store mean magnitude here
