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

; The GPIODATA register is the data register
GPIO_PORTE_BASE		EQU		0x40024000		; GPIO Port E (APB) base: 0x4002.4000 (p416 datasheet de lm3s9B92.pdf)
	
; Broches select
BROCHE0_1			EQU		0x03


		AREA    |.text|, CODE, READONLY
		ENTRY
		
EXPORT BUMPER_INIT
EXPORT BUMPER_VALUE
	

BUMPER_INIT
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION Bumpers
		ldr r8, = GPIO_PORTE_BASE+GPIO_O_DEN	;; Enable Digital Function 
        ldr r0, = BROCHE0_1	
        str r0, [r8]  

		ldr r8, = GPIO_PORTE_BASE+GPIO_I_PUR	;; Pull_up
        ldr r0, = BROCHE0_1		
        str r0, [r8]

		ldr r8, = GPIO_PORTE_BASE + (BROCHE0_1<<2)  ;; @data Register = @base + (mask<<2) ==> Switcher
		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration Bumpers
		
BUMPER_VALUE
		ldr r10,[r8]
		CMP r10,#0x00
		BNE ReadState