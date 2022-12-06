	;; RK - Evalbot (Cortex M3 de Texas Instrument)
; programme - Pilotage 2 Moteurs Evalbot par PWM tout en ASM (Evalbot tourne sur lui même)
; This register controls the clock gating logic in normal Run mode

		AREA    |.text|, CODE, READONLY
		ENTRY
		EXPORT	__main

; Durée des boucles d'attente
DUREE			EQU			0x002FFFFF
DUREE_VIRAGE	EQU			0x01210000
	
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
		IMPORT  MOTEUR_MAX_SPEED			; définit la vitesse du moteur à sa valeur maximale
		IMPORT  MOTEUR_NORMAL_SPEED			; définit la vitesse du moteur à sa valeur par défaut
		IMPORT  MOTEUR_MIN_SPEED			; définit la vitesse du moteur à sa valeur minimale

		
		; Fonctions Moteur Gauche
		IMPORT	MOTEUR_GAUCHE_ON			; activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_OFF			; déactiver le moteur gauche
		IMPORT  MOTEUR_GAUCHE_AVANT			; moteur gauche tourne vers l'avant
		IMPORT  MOTEUR_GAUCHE_ARRIERE		; moteur gauche tourne vers l'arrière
		IMPORT  MOTEUR_GAUCHE_INVERSE		; inverse le sens de rotation du moteur gauche
			
		; Fonctions Bumper1
		IMPORT  READ_BUMPERS				; Lit la valeur d'activation des Bumpers
			
		; Fonctions LEDS
		IMPORT  LEDS_ON						; Active les LEDs
		IMPORT  LED4_ON						; Active la LED Broche 4
		IMPORT  LED5_ON						; Active la LED Broche 5
		IMPORT  LEDS_OFF					; Désactive les LEDs
			
		; Fonctions SWITCH
		IMPORT  SWITCH_INIT					; Initialise le switch
		IMPORT  READ_SWITCH1				; Lit la valeur d'activation du Switch 1
		IMPORT  READ_SWITCH2				; Lit la valeur d'activation du Switch 2
		
; FONCTION PRINCIPALE

__main	

		; Configure les PWM + GPIO
		BL  MOTEUR_INIT
		BL  BUMPERS_INIT
		BL  LEDS_INIT
		BL  SWITCH_INIT
		
		
; Attends l'activation du Switch 2 pour commencer le programme		
STANDBY
		BL READ_SWITCH2
		CMP r5, #0
		BNE STANDBY
		
		; Activer les deux moteurs droit et gauche
		BL	MOTEUR_DROIT_ON
		BL	MOTEUR_GAUCHE_ON

		; On définit le nombre de coliisions avant warning à 4 (4 côtés)
		LDR r3, =0x04
		

		
		
; Boucle de pilotage : l'Evalbot avace et attend une collision
; S'il y a collision, l'Evalbot recule puis
; il tourne de 90 degrés sur la droite
; L'Evalbot répète les tests jusqu'à 4 collisions consécutives
; S'il y a 4 collisions consécutives, l'Evalbot recule et fait clignoter ses Leds

LOOP	
		BL MOTEUR_MIN_SPEED

		; Evalbot avance droit devant
		BL MOTEUR_DROIT_AVANT
		BL MOTEUR_GAUCHE_AVANT
		
		; Lecture de la valeur d'activation des Bumpers et écriture dans r2
		BL READ_BUMPERS
		
		; Si aucun Bumper n'est activé (r2 = 3), on continue à boucler
		CMP r2, #3
		BGE LOOP
		
		; L'Evalbot est coincé, il recule
		BL MOTEUR_NORMAL_SPEED
		BL MOTEUR_GAUCHE_INVERSE
		BL MOTEUR_DROIT_INVERSE
		LDR r4, =DUREE_VIRAGE
		BL WAIT
		
		; On vérifie si on a atteint le nombre maximal de collisions
		; Ajoute 1 au nombre de collisions, si on a enchaîné 4 collisions, on allume les LEDs
		SUBS r3, #1
		BEQ STUCK
		
		; Rotation à droite de l'Evalbot pendant 2 périodes, la LED du côté de la rotation s'allume pendant le virage
		BL LED5_ON
		BL MOTEUR_DROIT_INVERSE
		LDR r4, =DUREE_VIRAGE
		BL WAIT
		BL LEDS_OFF

		B LOOP

;; Boucle d'attente, on définit r4 a une valeur précise avant l'appel
WAIT	
		SUBS r4, #1
        BNE WAIT
		BX	LR
		
;; L'évalBOT est coincé, il s'arrêtte
STUCK
		BL MOTEUR_DROIT_OFF
		BL MOTEUR_GAUCHE_OFF

;; L'évalBOT fait clignoter ses LEDs
WARNING 
		BL LEDS_ON
		
		BL READ_SWITCH1
		CMP r5, #0
		BEQ FORCE
		
		LDR r4, =DUREE
		BL WAIT
		
		BL LEDS_OFF

		BL READ_SWITCH1
		CMP r5, #0
		BEQ FORCE

		LDR r4, =DUREE
		BL WAIT
		
		B WARNING
		
; L'évalBOT tente de forcer le mur devant lui
FORCE
		BL LEDS_OFF
		BL MOTEUR_DROIT_ON
		BL MOTEUR_GAUCHE_ON
		BL MOTEUR_MAX_SPEED
		BL MOTEUR_DROIT_AVANT
		BL MOTEUR_GAUCHE_AVANT
		
		LDR r4, =0xFFFF 
		BL WAIT
		
		BL MOTEUR_NORMAL_SPEED
		BL MOTEUR_DROIT_OFF
		BL MOTEUR_GAUCHE_OFF
		BL STANDBY
		
		
		NOP
        END