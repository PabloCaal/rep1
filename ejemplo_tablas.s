; Archivo:	ejemplo_tablas.s
; Dispositivo:	PIC16F887
; Autor:	Christopher Chiroy
; Compilador:	pic-as (v2.35), MPLABX V6.00
;                
; Programa:	Ejemplo uso de tablas
; Hardware:	Botón en RA0		
;
; Creado:	02 feb, 2022
; Última modificación: 02 feb, 2022

PROCESSOR 16F887

; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

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

// config statements should precede project file includes.
#include <xc.inc>
  
PSECT udata_bank0		;common memory
  CONT:		DS 1		; Contador
  CONT_ASCII:	DS 1		; Valor en ASCII de contador
  
PSECT resVect, class=CODE, abs, delta=2
; ----------- VECTOR RESET ------------
ORG 00h
resVect:
    PAGESEL main
    GOTO main
    
PSECT code, delta=2, abs
; --------- CONFIGURACION -------------
ORG 100h
main:
    BANKSEL ANSEL
    CLRF ANSEL			; I/O digitales
    CLRF ANSELH
    BANKSEL TRISA
    BSF TRISA, 0		; RA0 como entrada
    BANKSEL PORTA
    CLRF CONT			; Reinicio de contador
    CLRF CONT_ASCII		
    
CHECKBOTON:
    BTFSC PORTA, 0		; vemos si botón está presionado
    GOTO CHECKBOTON
    
ANTIREBOTES:
    BTFSS PORTA, 0		; vemos si botón ya no está presionado
    GOTO ANTIREBOTES
    
    MOVF    CONT, W		; Valor de contador a W para buscarlo en la tabla
    CALL    TABLA		; Buscamos caracter de CONT en la tabla ASCII
    MOVWF   CONT_ASCII		; Guardamos caracter de CONT en ASCII
    INCF    CONT		; Incremento de contador
    BTFSC   CONT, 3		; Verificamos que el contador no sea mayor a 7
    CLRF    CONT		; Si es mayor a 7, reiniciamos contador
    GOTO    CHECKBOTON		
    
ORG 200h    
TABLA:
    CLRF    PCLATH		; Limpiamos registro PCLATH
    BSF	    PCLATH, 1		; Posicionamos el PC en dirección 02xxh
    ANDLW   0x07		; No saltar más del tamaño de la tabla
    ADDWF   PCL			; Apuntamos el PC a caracter en ASCII de CONT
    RETLW   '0'			; ASCII char 0
    RETLW   '1'			; ASCII char 1
    RETLW   '2'			; ASCII char 2
    RETLW   '3'			; ASCII char 3
    RETLW   '4'			; ASCII char 4
    RETLW   '5'			; ASCII char 5
    RETLW   '6'			; ASCII char 6
    RETLW   '7'			; ASCII char 7
  
END



