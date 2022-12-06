;; RK - Evalbot (Cortex M3 de Texas Instrument)
	;; Fichier contenant l'initialisation des Bumpers et leur fonctions d'intéraction avec le Main
	
;; Pour l'activation de la clock    0x400FE000
SYSCTL_RCGC2		EQU		0x400FE108		;SYSCTL_RCGC2: offset 0x108 (p291 datasheet de lm3s9b92.pdf)

; The GPIODATA register is the data register
GPIO_PORTE_BASE		EQU		0x40024000		; GPIO Port E (APB) base: 0x4002.4000 (p416 datasheet de lm3s9B92.pdf)


; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_I_DEN  		EQU 	0x0000051C  	; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; Pull_up
GPIO_I_PUR   		EQU 	0x00000510  	; GPIO Pull-Up (p432 datasheet de lm3s9B92.pdf)

; Broches select
BROCHE0_1			EQU		0x03			; Broche 0	+ Broche 1
BROCHE0				EQU		0x01
BROCHE1				EQU		0x02
	
	
		AREA    |.text|, CODE, READONLY
 


	  	ENTRY
		
		;; The EXPORT command specifies that a symbol can be accessed by other shared objects or executables.
		EXPORT BUMPERS_INIT
		EXPORT READ_BUMPERS
		
BUMPERS_INIT
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION Bumpers
		ldr r7, = SYSCTL_RCGC2
		ldr	r2, [r7] 		
        ORR	r2, r2, #0x00000010  ;; Enable port E GPIO  (38)
        str r2, [r7]
		
		;: "There must be a delay of 3 system clocks before any GPIO reg. access  (p413 datasheet de lm3s9B92.pdf)   
		NOP
		NOP
		NOP
		
		LDR r8, =GPIO_PORTE_BASE + GPIO_I_DEN	   ;; Enable Digital Function
		LDR r2, [r8]
        ORR r2, r2, #BROCHE0_1	
        STR r2, [r8]  

		LDR r8, =GPIO_PORTE_BASE + GPIO_I_PUR      ;; Pull up
		LDR r2, [r8]
        ORR r2, r2, #BROCHE0_1	
        STR r2, [r8]
		
		;vvvvvvvvvvvvvvvvvvvvvvvvvvvvFin configuration Bumpers
		BX LR
		
READ_BUMPERS
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^Lecture du contenu de la valeur d'activation du Bumper 1
		LDR r8, =GPIO_PORTE_BASE + (BROCHE0_1<<2)  ;; @data Register = @base + (mask<<2) ==> Valeur Bumper

		LDR r2, [r8]
		
		BX LR
		;vvvvvvvvvvvvvvvvvvvvvvvvvvvvFin Lecture Bumper 1

		NOP
		NOP
		END