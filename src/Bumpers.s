;; RK - Evalbot (Cortex M3 de Texas Instrument)
	;; Fichier contenant l'initialisation des Bumpers et leur fonctions d'intéraction avec le Main

; The GPIODATA register is the data register
GPIO_PORTF_BASE		EQU		0x40025000	; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

; The GPIODATA register is the data register
GPIO_PORTD_BASE		EQU		0x40007000		; GPIO Port D (APB) base: 0x4000.7000 (p416 datasheet de lm3s9B92.pdf)

; The GPIODATA register is the data register
GPIO_PORTE_BASE		EQU		0x40024000		; GPIO Port E (APB) base: 0x4002.4000 (p416 datasheet de lm3s9B92.pdf)



; configure the corresponding pin to be an output
; all GPIO pins are inputs by default
GPIO_O_DIR   		EQU 	0x00000400  ; GPIO Direction (p417 datasheet de lm3s9B92.pdf)

; The GPIODR2R register is the 2-mA drive control register
; By default, all GPIO pins have 2-mA drive.
GPIO_O_DR2R   		EQU 	0x00000500  ; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)

; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN  		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; Pull_up
GPIO_I_PUR   		EQU 	0x00000510  ; GPIO Pull-Up (p432 datasheet de lm3s9B92.pdf)

; Broches select
BROCHE0_1			EQU		0x03
	
	
		AREA    |.text|, CODE, READONLY
 


	  	ENTRY
		
		;; The EXPORT command specifies that a symbol can be accessed by other shared objects or executables.
		EXPORT BUMPER1_INIT
		EXPORT WAIT_BUMPER1
		
BUMPER1_INIT
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION Bumper 1
		ldr r6, = GPIO_PORTF_BASE  			
        mov r0, #0x00000038  				
		; ;;														 									
        str r0, [r6]
				; ;; "There must be a delay of 3 system clocks before any GPIO reg. access  (p413 datasheet de lm3s9B92.pdf)   
								;; pas necessaire en simu ou en debbug step by step...		
		
		LDR r8, = GPIO_PORTE_BASE+GPIO_O_DEN	;; Enable Digital Function 
        LDR r0, = BROCHE0_1	
        STR r0, [r8]  

		LDR r8, = GPIO_PORTE_BASE+GPIO_I_PUR	;; Pull_up
        LDR r0, = BROCHE0_1		
        STR r0, [r8]

		LDR r8, = GPIO_PORTE_BASE + (BROCHE0_1<<2)  ;; @data Register = @base + (mask<<2) ==> Switcher
		
		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration Switcher 
		BX LR

WAIT_BUMPER1
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^Attente de l'activation du Bumper1
		
		LDR r10,[r8]
		CMP r10,#0x00
		BNE WAIT_BUMPER1
		BX LR
		
		;vvvvvvvvvvvvvvvvvvvvvvvvvFin de l'attente : le bumper1 a été activé
		
		NOP		
		END 