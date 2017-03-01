

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; main procedure ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; loads data from file and computes sum of the magnitude 
;; (abs value) of all values in file.
;; Store result in R4

.ORIG x3000


;; clear regs 0 - 4 for usage
	AND R0 R0 x0 		;R0 <- loaded value
	AND R1 R1 x0		;R1 <- accumulator
	AND R2 R2 x0		;R2 <- address of filestart
	AND R3 R3 x0		;R3 <- file size
	AND R4 R4 x0		;R4 : used to pass arg
	AND R5 R5 x0		
	AND R6 R6 x0		

BRnzp PREINIT

	;; compute addition
	;; sequentially add file contents, if number is neg
	;; branch to neg2pos to convert to pos representation

COND		ADD	R3 R3 #-1		; decrement counter
		BRn	END				; computation complete
START		
		LDR	R0 R2	 #0	; RO <- M[R2] 
		ADD	R2 R2 #1	; increment to next data item
		ADD	R4 R0 #0	; R4 used as shared memory to
					; pass args (may not be necessary)
		JMP	R6	   ; if neg convert2pos before add

ACC		ADD	R0 R4 #0	; R4 used as shared memory to
					; pass args (may not be necessary)
		ADD	R1 R1 R0	; Accumulate positive value
		BRnzp COND

END		JMP R7

JUMP 		JMP 	R5

		initPtr .FILL INIT 

PREINIT 
	AND R5 R5 #0
	LD R5 initPtr
	JMP R5

;;
;; Leave space for future code
	.BLKW #300   ;<------------------- LOOK HERE 
	

;; Preamble 	
;; need pointer to filestart to load data, given ISA

FileStartPtr 	.FILL FileStart
MEANMAGPtr	.FILL MEANMAG
FileSizePtr	.FILL FileSize
neg2posPtr	.FILL neg2pos
returnPtr	.FILL ACC
CONDPtr		.FILL COND
FINPtr 		.FILL FINISH
TestPtr		.FILL TESTCONDITION

FileSize	.FILL #10		;num data in file


INIT		LD 	R5 CONDPtr
		LD 	R6 TestPtr
		LD	R2 FileStartPtr	; load starting address
		LD	R3 FileSize	; load filesize as counter
		LD 	R7 FINPtr
		JMP 	R5



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;    neg2pos   ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; sub routine that converts neg to pos
;; assumes input is passed by reg 3, 
;; ouput also passed in reg 3
;; R3 <== -R3	
;; Compute 2's complement of R3

neg2pos	NOT R4 R4	
		ADD R4 R4 x1
		;;BRnzp	ACC
		AND R5 R5 #0
		LD R5 returnPtr
		JMP R5

TESTCONDITION 	BRn neg2pos
		AND R5 R5 #0
		LD R5 returnPtr
		JMP R5

FINISH 		LD	R2 MEANMAGPtr	; load address for mean
		STR	R1 R2 #0		; M[R1] <- R2
		HALT					; the end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;  Data File ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

