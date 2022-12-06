	;; RK - Evalbot (Cortex M3 de Texas Instrument)
   		;; Fichier contenant l'initialisation des LEDs et leur fonctions d'intéraction avec le Main

		AREA    |.text|, CODE, READONLY
 
; This register controls the clock gating logic in normal Run mode
SYSCTL_PERIPH_GPIO EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

; The GPIODATA register is the data register
GPIO_PORTF_BASE		EQU		0x40025000	; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

; The GPIODATA register is the data register
GPIO_PORTD_BASE		EQU		0x40007000		; GPIO Port D (APB) base: 0x4000.7000 (p416 datasheet de lm3s9B92.pdf)

; configure the corresponding pin to be an output
; all GPIO pins are inputs by default
GPIO_O_DIR   		EQU 	0x00000400  ; GPIO Direction (p417 datasheet de lm3s9B92.pdf)

; The GPIODR2R register is the 2-mA drive control register
; By default, all GPIO pins have 2-mA drive.
GPIO_O_DR2R   		EQU 	0x00000500  ; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)

; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN  		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; Pul_up
GPIO_I_PUR   		EQU 	0x00000510  ; GPIO Pull-Up (p432 datasheet de lm3s9B92.pdf)

; Broches select
BROCHE4				EQU		0x10
BROCHE5				EQU		0x20
BROCHE4_5			EQU		0x30		; led1 & led2 sur broche 4 et 5

BROCHE6				EQU 	0x40		; bouton poussoir 1

; blinking frequency
DUREE   			EQU     0x002FFFFF


	  	ENTRY
		EXPORT	LEDS_INIT
		EXPORT  LEDS_ON
		EXPORT  LEDS_OFF
		EXPORT 	LED4_ON
		EXPORT  LED5_ON
			
LEDS_INIT
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION LED
		; ;; Enable the Port F & D peripheral clock 		(p291 datasheet de lm3s9B96.pdf)
		ldr r9, = SYSCTL_PERIPH_GPIO  			;; RCGC2
		ldr	r5, [r9]
        ORR r5, r5, #0x00000028  				;; Enable clock sur GPIO D et F où sont branchés les leds
        str r5, [r9]
		
		; ;; "There must be a delay of 3 system clocks before any GPIO reg. access  (p413 datasheet de lm3s9B92.pdf)
		nop
		nop	   
		nop

        ldr r9, = GPIO_PORTF_BASE+GPIO_O_DIR    ;; 1 Pin du portF en sortie (broche 4 : 00010000)
		ldr r5, [r9]
        orr r5, r5, #BROCHE4_5 	
        str r5, [r9]
		
		ldr r9, = GPIO_PORTF_BASE+GPIO_O_DEN	;; Enable Digital Function 
		ldr r5, [r9]
        orr r5, r5, #BROCHE4_5		
        str r5, [r9]
		
		ldr r9, = GPIO_PORTF_BASE+GPIO_O_DR2R	;; Choix de l'intensité de sortie (2mA)
		ldr r5, [r9]
        orr r5, r5, #BROCHE4_5			
        str r5, [r9]
		
		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration LED 
		
		BX LR
		
LEDS_ON
		ldr r9, = GPIO_PORTF_BASE + (BROCHE4_5<<2)  ;; @data Register = @base + (mask<<2) ==> LED1
        ldr r0, = BROCHE4_5		
		STR r0, [r9]
		BX LR
		
LEDS_OFF
		ldr r9, = GPIO_PORTF_BASE + (BROCHE4_5<<2)  ;; @data Register = @base + (mask<<2) ==> LED1
        mov r0, #0x00
		STR r0, [r9]
		BX LR

LED4_ON
		ldr r9, = GPIO_PORTF_BASE + (BROCHE4_5<<2)  ;; @data Register = @base + (mask<<2) ==> LED1
		ldr r0, = BROCHE4
		STR r0, [r9]
		BX LR

LED5_ON
		ldr r9, = GPIO_PORTF_BASE + (BROCHE4_5<<2)  ;; @data Register = @base + (mask<<2) ==> LED1
		ldr r0, = BROCHE5
		STR r0, [r9]
		BX LR

		NOP
		NOP		
		END 