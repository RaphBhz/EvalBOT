	;; RK - Evalbot (Cortex M3 de Texas Instrument)
; programme - Pilotage 2 Moteurs Evalbot par PWM tout en ASM (Evalbot tourne sur lui même)
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
		IMPORT  MOTEUR_DROIT_OFF			; déactiver le moteur droit
		IMPORT  MOTEUR_DROIT_AVANT			; moteur droit tourne vers l'avant
		IMPORT  MOTEUR_DROIT_ARRIERE		; moteur droit tourne vers l'arrière
		IMPORT  MOTEUR_DROIT_INVERSE		; inverse le sens de rotation du moteur droit
		
		; Fonctions Moteur Gauche
		IMPORT	MOTEUR_GAUCHE_ON			; activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_OFF			; déactiver le moteur gauche
		IMPORT  MOTEUR_GAUCHE_AVANT			; moteur gauche tourne vers l'avant
		IMPORT  MOTEUR_GAUCHE_ARRIERE		; moteur gauche tourne vers l'arrière
		IMPORT  MOTEUR_GAUCHE_INVERSE		; inverse le sens de rotation du moteur gauche
			
		; Fonctions Bumper1
		IMPORT  READ_BUMPERS				; Lis la valeur d'activation des Bumpers
			
		; Fonctions LEDS
		IMPORT  LEDS_ON						; Active les LEDs
		IMPORT  LEDS_OFF					; Désactive les LEDs
		
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
; il tourne de 90 degrés sur la droite
; L'Evalbot répète les tests jusqu'à 4 collisions consécutives
; S'il y a 4 collisions consécutives, l'Evalbot recule et fait clignoter ses Leds

LOOP	
		; Evalbot avance droit devant
		BL MOTEUR_DROIT_AVANT
		BL MOTEUR_GAUCHE_AVANT
		
		; Lecture de la valeur d'activation des Bumpers et écriture dans r2
		BL READ_BUMPERS
		
		; Si aucun Bumper n'est activé (r2 = 3), on continue à boucler
		CMP r2, #3
		BGE LOOP
		
		; L'Evalbot est coincé, il recule
		BL MOTEUR_GAUCHE_INVERSE
		BL MOTEUR_DROIT_INVERSE
		BL WAIT
		
		; Ajoute 1 au nombre de collisions, si on a enchaîné 4 collisions, on allume les LEDs
		ORR r3, r3, #0x01
		CMP r3, #4
		BEQ STUCK
		
		; Rotation à droite de l'Evalbot pendant 2 périodes
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