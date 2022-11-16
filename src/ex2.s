	;; RK - Evalbot (Cortex M3 de Texas Instrument)

		AREA    |.text|, CODE, READONLY

; This register controls the clock gating logic in normal Run mode
SYSCTL_PERIPH_GPIO EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)
	
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

; The GPIODATA register is the data register
GPIO_PORTE_BASE		EQU		0x40024000  ; GPIO Port E base: 0x40024000
GPIO_PORTF_BASE		EQU		0x40025000	; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

; Broches select
PIN0_1				EQU		0x03		; sw3 et sw4 sur pin 0 et 1
BROCHE4_5			EQU		0x30		; led1 & led2 sur broche 4 et 5

; blinking frequency
DUREE   			EQU     0x002FFFFF

	  	ENTRY
		EXPORT	__main
__main	

		; ;; Enable the Port F & D peripheral clock 		(p291 datasheet de lm3s9B96.pdf)
		; ;;									
		ldr r6, = SYSCTL_PERIPH_GPIO  				;; RCGC2
        mov r0, #0x00000028  						;; Enable clock sur GPIO D et F où sont branchés les leds (0x28 == 0b101000)
		; ;;														 									      (GPIO::FEDCBA)
        str r0, [r6]
		
		; ;; "There must be a delay of 3 system clocks before any GPIO reg. access  (p413 datasheet de lm3s9B92.pdf)
		nop	   										;; tres tres important....
		nop	   
		nop	   										;; pas necessaire en simu ou en debbug step by step...
	
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION LED	
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DEN		;; Enable Digital Function 
        ldr r0, = BROCHE4_5		
        str r0, [r6]
		
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DR2R		;; Choix de l'intensité de sortie (2mA)
        ldr r0, = BROCHE4_5			
        str r0, [r6]
		
		mov r2, #0x000       						;; pour eteindre LED
		mov r3, #BROCHE4_5							;; Allume LED1&2 portF broche 4&5 : 00110000
		
		ldr r6, = GPIO_PORTF_BASE + (BROCHE4_5<<2)  ;; @data Register = @base + (mask<<2) ==> LED1
		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration LED
		
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION Bumpers	
		ldr r7, = GPIO_PORTE_BASE+GPIO_O_DEN		;; Enable Digital Function 
        ldr r0, = BROCHE0_1		
        str r0, [r7]
		
		ldr r7, = GPIO_PORTF_BASE+GPIO_O_DR2R		;; Choix de l'intensité de sortie (2mA)
        ldr r0, = BROCHE0_1	
        str r0, [r7]
		     
		
		ldr r7, = GPIO_PORTE_BASE + (BROCHE0_1<<2)  ;; @data Register = @base + (mask<<2) ==> Bumpers
		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration Bumpers