{
*  (C) AguHDz 29-JUL-2017
*  Ultima Actualizacion: 29-JUL-2017
*
*  Compilador PicPas v.0.7.2 (https://github.com/t-edson/PicPas)
*
*  CONTADOR DE PULSOS EXTERNOS
*  ===============================================================
*  Ejemplo de uso de nueva función LCD_Print_Number de la librería
*  LCDlib_4bits para imprimir numeros enteros de tipo word.
*
*  Configura el Timer 1 como contador de pulsos externos.
*  Imprime en display LCD el numero de pulsos contados. 
*
}

{$FREQUENCY 8Mhz}
{$PROCESSOR PIC16F877A}

program Counter_External_Pulse;

uses PIC16F877A, LCDLib_4bits;

var
  pulsos_TMR1, overflows_TMR1 : word;     // Contadores de Pulsos externos y de desbordamientos del Timer 1.
  OverFlow_Pin : bit absolute PORTC_RC1;  // Pin de salida por el que comunica el desbordamiento del Timer 1.

//***********************************************************************
//  PROCEDIMIENTO: _ISR_
//  I.S.R. : Interrupt Service Routine (Rutina de Servicio a la Interrupcion)
//  Cualquier interrupcion producida en el uC 16F877A salta a la
//  direccion $0004, a partir de la que código de programa debe decidir
//  que hacer.
//***********************************************************************
Procedure _ISR_; interrupt;
var
  Reg_W, Reg_STATUS : byte;  // Para guardar valores previos a interrupcion y restablecerlos antes de salir.
begin
  INTCON_GIE  := 0;     // Desbabilitación General de Interrupciones.
  ASM
  ;------------------------------------------------------------------------------------
  ; Inicio de instrucciones que se ejecutan cuando se produce una interrupcion.
  ;------------------------------------------------------------------------------------
    MOVWF Reg_W        ; Guarda en registro W en Reg_W.
    SWAPF STATUS,w     ; Invierte los nibbles del registro de estado (STATUS) y lo guarda en W.
                       ; Se usa SWAPF en lugar de MOVF porque no afecta al flag Z del registro STATUS.
                       ; Es la tecnica recomendada por Microchip para salvaguardar los valores previos 
                       ; a la interrupcion.
    MOVWF Reg_STATUS   ; Guarda el contenido de W en Reg_STATUS.
  ;------------------------------------------------------------------------------------
  END
  // INTERRUPCION TIMER TMR1 --------------------------------------------------------
    if(PIR1_TMR1IF = 1) then                    // Comprueba se se ha producido el desbordamiento del Timer 1.
      PIR1_TMR1IF := 0;                         // Restaura valor de flag de desbordamiento. 
      Inc(overflows_TMR1);                      // Incrementa la parte alta del contador de 4 bytes.
      OverFlow_Pin := 1;                        // Pulso de salida para indicar del desbordamiento del Timer 1.
      OverFlow_Pin := 0;
    end;
  // --------------------------------------------------------------------------------
  ASM
  ;------------------------------------------------------------------------------------
  ; Fin de interrupcion y reposicion de los valores previos de W y STATUS.
  ;------------------------------------------------------------------------------------
    SWAPF Reg_STATUS,w ; Invertimos los nibbles para dejar en su posicion correcta el registro STATUS.
    MOVWF STATUS       ; Restauramos el valor de STATUS previo a la interrupcion.
    SWAPF Reg_W,f      ; Invertimos los nibbles de Reg_W y lo guardamos en la misma posicion de memoria.
    SWAPF Reg_W,w      ; Volvemos a invertor los nibbles de Reg_W y lo guardamos en el registro W, con
                       ; lo que queda con el valor que tenia antes de la interrupcion.
                       ; Se usa SWAPF en lugar de MOVF porque no afecta al flag Z del registro STATUS.
                       ; Es la tecnica recomendada por Microchip para salvaguardar los valores previos 
                       ; a la interrupcion.
  ;------------------------------------------------------------------------------------
  END
  INTCON_GIE  := 1;     // Desbabilitación General de Interrupciones.
end;


//***********************************************************************
// P R O G R A M A    P R I N C I P A L 
//***********************************************************************
begin
  ADCON1 := $07;       // Todos los pines configurados como digitales.
  ADCON0 := $00;       // Desactiva conversor A/D.
  
  SetAsOutput(OverFlow_Pin); // Configura Pin indicador de Overflow (desbordamiento de Timer 1)
  OverFlow_Pin  := 0;        // Inicializa a cero. Cuando se produce desboldamiento, lo indicará con un pulso.

  // Configuración del Timer 1:
  T1CON_T1CKPS1 := 0;  // Preescaler de Timer 1 = 1:1
  T1CON_T1CKPS0 := 0;  // Preescaler de Timer 1 = 1:1
  T1CON_T1OSCEN := 0;  // No se utiliza un oscilador externo independiente para el Timer 1. (en este caso es indiferente)
  T1CON_T1SYNC  := 1;  // Timer 1 funciona de forma sincronizada con oscilador interno del PIC.
  T1CON_TMR1CS  := 1;  // Timer 1 utilizado con contador. (se incrementa con flanco de subida en pin RC0/T1CKI)
  T1CON_TMR1ON  := 1;  // Timer 1 Habilitado.
                       // Más información en: http://microcontroladores-mrelberni.com/timer1-pic/
  
  LCD_Init(20,4);      // Inicializa LCD
  
  TMR1L  := 0;         // Inicializa Timer 1 a cero.
  TMR1H  := 0;
  PIR1_TMR1IF := 0;    // flag de desbordamiento de Timer 1 se ponde a cero.
  
  LCD_GotoXY(0,3);     // Mueve cursor de display.
  LCD_WriteChar('P');  // Imprime texto en display.
  LCD_WriteChar('u');
  LCD_WriteChar('l');
  LCD_WriteChar('s');
  LCD_WriteChar('o');
  LCD_WriteChar('s');
  LCD_WriteChar(':');
  
  LCD_GotoXY(1,0);
  LCD_WriteChar('O');
  LCD_WriteChar('v');
  LCD_WriteChar('e');
  LCD_WriteChar('r');
  LCD_WriteChar('F');
  LCD_WriteChar('l');
  LCD_WriteChar('o');
  LCD_WriteChar('w');
  LCD_WriteChar('s');
  LCD_WriteChar(':');
  
  overflows_TMR1 := 0;  // Inicializa e imprime contador de desbordamientos del Timer 1.
  LCD_GotoXY(1,11);
  LCD_Print_Number(overflows_TMR1, 0, 5, '0');
  
  PIE1_TMR1IE := 1;     // Habilita Interruptción por desbordamiento de Timer 1. 
  INTCON_PEIE := 1;     // Habilita Interrupciones por periféricos.
  INTCON_GIE  := 1;     // Habilitación General de Interrupciones.
  
  repeat                                        // Bucle infinito.  
    LCD_GotoXY(0,11);                           // Mueve cursor de display.
    pulsos_TMR1.low  := TMR1L;                  // Guarda valor de Timer 1 en variable pulsos_TMR1
    pulsos_TMR1.high := TMR1H;
    LCD_Print_Number(pulsos_TMR1, 0, 5, '0');      // Imprime el número de pulsos externos contado por el Timer 1.
    LCD_GotoXY(1,11);
    LCD_Print_Number(overflows_TMR1, 0, 5, '0');   // Imprime el numero de overflows (desbordamientos) del Timer 1.}
  until false;                                  // Se repite el bucle. 
end. 

