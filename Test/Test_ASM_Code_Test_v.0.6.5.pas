{
*  (C) AguHDz 27-05-2017
*  Ultima Actualizacion: 27-05-2017
*
*  Prueba para compilador PicPas v.0.6.5 (https://github.com/t-edson/PicPas)
*  Uso de variables del programas PASCAL y etiquetas en dentro de código ASM.
*
*  A partir de la version 0.6.5 PicPas permite utilizar variables definidas
*  en el codigo fuente escrito en PASCAL dentro de las secciones del programa
*  escritas en Ensamblador. Tambien permite el uso de etiquetas dentro del
*  codigo ASM.
}

{$FREQUENCY 8 MHZ }
program TestVariablesyEtiquetasEnASM;
uses PIC16F84A;

//***********************************************************************
// PROCEDIMIENTO: SETSALIDA
// Configura el puerto RB como salida y escribe un valor.
// Prueba de traspaso de variables a codigo escrito en ASM.
//***********************************************************************
procedure SetSalida(valor: byte);
begin
ASM 
  MOVWF valor      ; Mueve el continido de la posicion de memoria valor al registro W
  BSF   STATUS,5   ; Banco 1.
  CLRF  PORTB      ; Todo el Puerto RB como Salida
  BCF   STATUS,5   ; Banco 0.
  MOVWF PORTB      ; Puerto RB = valor;
END
end;

//***********************************************************************
// PROCEDIMIENTO: SETSALIDA_USANDO_REGISTER
// Configura el puerto RB como salida y escribe un valor.
// Prueba de traspaso de variables registro a codigo escrito en ASM.
// Evita ocupar una posicion de la memoria y es mas rapido.
// PicPas usa el registro W del PIC para traspaso de valores REGISTER.
//***********************************************************************
procedure SetSalida_usando_Register(register valor: byte);
begin
ASM 
  ; Ahora no es necesaria la instruccion MOVWF valor.
  BSF   STATUS,5  ; Banco 1.
  CLRF  PORTB     ; Todo el Puerto RB como Salida
  BCF   STATUS,5  ; Banco 0.
  MOVWF PORTB     ; Puerto RB = valor;
END
end;

//***********************************************************************
// PROCEDIMIENTO: DELAY_1S
// Espera 1 segundo (con velocidad de reloj = 8 MHz)
// Prueba de uso de etiquetas dentro de codigo escrito en ASM.
//***********************************************************************
procedure delay_1s;
var
  delay1,delay2,delay3 : byte;
begin
ASM
; F_Osc = 8 MHz -> ciclos espera 1 segundo = 1/(4*1/8e6) = 2000000 de ciclos maquina.
; 1999996 ciclos + 4 ciclos (call y return) = 2000000
  MOVLW  $11
  MOVWF	 delay1
  MOVLW	 $5D
  MOVWF	 delay2
  MOVLW	 $05
  MOVWF	 delay3
Delay_1s_Loop:  ; CUIDADO: Las etiquetas no permiten espacios de tabulacion a la izquierda.
  DECFSZ delay1, f
  GOTO   $+2
  DECFSZ delay2, f
  GOTO	 $+2
  DECFSZ delay3, f
  GOTO   Delay_1s_Loop
END
end;

//***********************************************************************
// PROGRAMA PRINCIPAL ***************************************************
//***********************************************************************
begin
  while true do                         
    SetSalida($FF);
    delay_1s;
    SetSalida_usando_Register($00);
    delay_1s;
  end;
end.
