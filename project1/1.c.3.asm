;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;    neg2pos   ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; sub routine that converts neg to pos
;; assumes input is passed by reg 3,
;; ouput also passed in reg 3
;; R3 <== -R3
;; Compute 2's complement of R3


.ORIG x3027

neg2pos	NOT R4 R4
		ADD R4 R4 x1
		;;BRnzp	ACC
		JMP R6
