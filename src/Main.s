	;; RK - Evalbot (Cortex M3 de Texas Instrument)
; programme - Pilotage 2 Moteurs Evalbot par PWM tout en ASM (Evalbot tourne sur lui m�me)
; This register controls the clock gating logic in normal Run mode

		AREA    |.text|, CODE, READONLY
		ENTRY
		EXPORT	__main
		
		;; The IMPORT command specifies that a symbol is defined in a shared object at runtime.
		IMPORT	MOTEUR_INIT					; initialise les moteurs (configure les pwms + GPIO)
		IMPORT  BUMPERS_INIT				; Initialise les Bumpers
		IMPORT  LEDS_INIT
		
		; Fonctions Moteur Droit
		IMPORT	MOTEUR_DROIT_ON				; activer le moteur droit
		IMPORT  MOTEUR_DROIT_OFF			; d�activer le moteur droit
		IMPORT  MOTEUR_DROIT_AVANT			; moteur droit tourne vers l'avant
		IMPORT  MOTEUR_DROIT_ARRIERE		; moteur droit tourne vers l'arri�re
		IMPORT  MOTEUR_DROIT_INVERSE		; inverse le sens de rotation du moteur droit
		
		; Fonctions Moteur Gauche
		IMPORT	MOTEUR_GAUCHE_ON			; activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_OFF			; d�activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_AVANT			; moteur gauche tourne vers l'avant
		IMPORT  MOTEUR_GAUCHE_ARRIERE		; moteur gauche tourne vers l'arri�re
		IMPORT  MOTEUR_GAUCHE_INVERSE		; inverse le sens de rotation du moteur gauche
			
		; Fonctions Bumper1
		IMPORT  READ_BUMPERS				; Lis la valeur d'activation des Bumpers
			
		; Fonctions LEDS
		IMPORT  LEDS_ON						; Active les LEDs
		IMPORT  LEDS_OFF					; D�sactive les LEDs
		
; FONCTION PRINCIPALE

__main	

		; Configure les PWM + GPIO
		BL  MOTEUR_INIT
		BL  BUMPERS_INIT
		BL  LEDS_INIT
		
		; Activer les deux moteurs droit et gauche
		BL	MOTEUR_DROIT_ON
		BL	MOTEUR_GAUCHE_ON
		BL  LEDS_ON

; Boucle de pilotage : l'Evalbot avace et attend une collision
; S'il y a collision, l'Evalbot recule puis
; il tourne de 90 degr�s sur la droite
; L'Evalbot r�p�te les tests jusqu'� 4 collisions cons�cutives
; S'il y a 4 collisions cons�cutives, l'Evalbot recule et fait clignoter ses Leds

LOOP	
		; Evalbot avance droit devant
		BL MOTEUR_DROIT_AVANT
		BL MOTEUR_GAUCHE_AVANT
		
		; Lecture de la valeur d'activation des Bumpers et �criture dans r2
		BL READ_BUMPERS
		
		; Si aucun Bumper n'est activ� (r2 = 3), on continue � boucler
		CMP r2, #3
		BGE LOOP
		
		; L'Evalbot est coinc�, il recule
		BL MOTEUR_GAUCHE_INVERSE
		BL MOTEUR_DROIT_INVERSE
		BL WAIT
		
		; Ajoute 1 au nombre de collisions, si on a encha�n� 4 collisions, on allume les LEDs
		ORR r3, r3, #0x01
		CMP r3, #4
		BEQ STUCK
		
		; Rotation � droite de l'Evalbot pendant 2 p�riodes
		BL MOTEUR_DROIT_INVERSE
		BL WAIT
		BL WAIT
		
		B LOOP

		;; Boucle d'attente
WAIT	LDR r4, =0xAFFFFF 
wait1	SUBS r4, #1
        BNE wait1
		BX	LR
		
STUCK	

		NOP
        END