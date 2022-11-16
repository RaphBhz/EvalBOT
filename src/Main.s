	;; RK - Evalbot (Cortex M3 de Texas Instrument)
; programme - Pilotage 2 Moteurs Evalbot par PWM tout en ASM (Evalbot tourne sur lui même)
; This register controls the clock gating logic in normal Run mode
SYSCTL_PERIPH_GPIO EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)


		AREA    |.text|, CODE, READONLY
		ENTRY
		EXPORT	__main
		
		;; The IMPORT command specifies that a symbol is defined in a shared object at runtime.
		IMPORT	MOTEUR_INIT					; initialise les moteurs (configure les pwms + GPIO)
		IMPORT BUMPER1_INIT					; Initialise le Bumper1
		
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
		IMPORT WAIT_BUMPER1					; Attent l'activation du Bumper1
		
; FONCTION PRINCIPALE

__main	

		; Configure les PWM + GPIO
		BL  MOTEUR_INIT	   
		; Configure les Bumpers
		BL  BUMPER1_INIT
		
		; Activer les deux moteurs droit et gauche
		BL	MOTEUR_DROIT_ON
		BL	MOTEUR_GAUCHE_ON

; Boucle de pilotage : l'Evalbot avace et attend une collision
; S'il y a collision, l'Evalbot recule puis
; il tourne de 90 degrés sur la droite
; L'Evalbot répète les tests jusqu'à 4 collisions consécutives
; S'il y a 4 collisions consécutives, l'Evalbot recule et fait clignoter ses Leds

LOOP	
		; Evalbot avance droit devant
		BL MOTEUR_DROIT_AVANT	   
		BL MOTEUR_GAUCHE_AVANT
		
		; Evalbot attent l'activation du Bumper1
		BL WAIT_BUMPER1
		; Evalbot ressort donc le Bumper1 est activé
						
		; Rotation à droite de l'Evalbot pendant une période (2 WAIT)
		BL MOTEUR_GAUCHE_INVERSE  ; MOTEUR_GAUCHE_INVERSE
		
		BL WAIT
		BL WAIT

		B LOOP

		;; Boucle d'attante de 1s
WAIT	LDR r1, =0xAFFFFF 
wait1	SUBS r1, #1
        BNE wait1
		
		;; retour à la suite du lien de branchement
		BX	LR

		NOP
        END