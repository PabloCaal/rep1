; Archivo:	main.s
; Dispositivo:  PIC16F887
; Autor:	Pablo Caal
; Compilador:   pic-as (v2.30), MPLABX V5.40
;
; Programa:	Contador en el puerto A
; Hardware:	LED's en el puerto A
;
; Creado: 26 en, 2022
; Última modificación: 26 en, 2022
    
PROCESSOR 16F887
#include <xc.inc>
    
; CONFIG1
    CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
    CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
    CONFIG  PWRTE = ON            ; Power-up Timer Enable bit (PWRT enabled)
    CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
    CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
    CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
	
    CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
    CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
    CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
    CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
    CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
    CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

PSECT udata_bank0 ; common memory
    cont_small: DS 1 ; 1byte
    cont_big:	DS 1
    
PSECT resVect, class=CODE, abs, delta=2
    
;--------------vector reset----------------
ORG 00h
resetVec:
    PAGESEL main
    goto main
    
PSECT CODE, delta=2, abs
ORG 100h
 
;---------------configuration--------------
 main:
    bsf	    STATUS, 5
    bsf	    STATUS, 6
    clrf    ANSEL
    clrf    ANSELH
    
    bsf	    STATUS, 5
    bcf	    STATUS, 6
    clrf    TRISA
    
    bcf	    STATUS, 5
    bcf	    STATUS, 6
    
;---------------loop principal--------------    
 loop:
    incf    PORTA, 1
    call    delay_big
    goto    loop

;---------------sub rutinas-----------------
delay_big:
; Se desea configurar el delay big a 100 ms
; 100 ms = 100000 us
; Fecuencia del oscilador: 4MHz -> cada instrucción se realiza en 1us (con excepciones)
; t_delay (us) = 1 + 1 + 2 + x(5 + 500)
; 100000 us = 3 + 505x
; x = 198.0118 = 198 aprox.
    
    movlw   198		    ; (1 ciclo) valor inicial del contador
    movwf   cont_big	    ; (1 ciclo)
    call    delay_small	    ; (2 ciclos) rutina delay
    decfsz  cont_big, 1	    ; (1 ciclo) decrementar el contador
    goto    $-2		    ; (2 ciclos) regresar dos líneas
    return		    ; (2 ciclos)

delay_small:
; Se desea configurar el delay small a 500 us
; Fecuencia del oscilador: 4MHz -> cada instrucción se realiza en 1us (con excepciones)
; t_delay (us) = 1 + 1 + 2 + x(3)
; 500 us = 4 + 3x
; x = 165.333 = 165 aprox.
    
    movlw   165		    ; (1 ciclo) valor inicial del contador
    movwf   cont_small	    ; (1 ciclo)
    decfsz  cont_small, 1   ; (1 ciclo) decrementar el contador
    goto    $-1		    ; (2 ciclos) regresar una línea
    return		    ; (2 ciclos)
    
END
