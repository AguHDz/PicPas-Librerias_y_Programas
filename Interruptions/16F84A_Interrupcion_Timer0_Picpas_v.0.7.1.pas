{
*  (C) AguHDz 20-JUN-2017
*  Ultima Actualizacion: 27-JUN-2017
*
*  Compilador PicPas v.0.7.1 (https://github.com/t-edson/PicPas)
*
*  INTERRUPCIONES HARDWARE
*  A partir de la version 0.7.1 de Picpas se implemente un indentificador de procedimiento
*  que atiende a las interrupciones del microcontrolador, pero no hace ninguna copia de
*  registros o accion mas que situar el procedimiento en la posicion $0004 y utilizar la
*  instruccion usando codigo ensamblador RETFIE para salir del mismo.
*
*  El este ejemplo de aplicacion, la interrupcion la produce el desbordamiento
*  del timer TMR0 del microcontrolador. Para ello, configuramos los registros del
*  microcontrolador para producir una interrupcion cada aproximadamente 0,25 segundos,
*  y usando un contador de interrupciones hacemos que los LED_1 y LED_2 cambien de
*  estado cada segundo, independientemente de lo que este haciendo en ese momento
*  el microcontrolador.
*
*  Para comprobar que se conservan los valores de los registros previos a la interrupcion
*  y que por lo tanto no se produce deterioros en el programa principal que ejecuta el
*  microcontrolador, se ha programado un LOOP que apaga y enciende un LED (de color AZUL)
*  cada 300 ms usando la funcion del sistema delay_ms() que en versiones anteriores se
*  situaba precisamente en el area de direcciones de codigo iniciales sobreescribiendo
*  cualquier funcion escrita para atender la interrupcion.
*  
}

{$PROCESSOR PIC16F84A}
{$FREQUENCY 1Mhz}
{$MODE PICPAS}

program Interrupciones;

uses PIC16F84A;

const
  IniTMR0 = 12;   // Valor inicial y de recarga de TRM0. Tiempo desbordamento =
                  // (256-IniTMR0)/(XTAL/4/Divisor Prescaler) =
                  // (256-12)/(1e6/4/256) = 0,249856 segundos.

var
  LED_1          : bit absolute PORTB_RB0;  // LED_1 conectado al pin RB0.
  LED_2          : bit absolute PORTB_RB1;  // LED_2 conectado al pin RB1.
  ContadorInTMR0 : byte;                    // Contador de interrupciones de TMR0.
  LED_AZUL       : bit absolute PORTA_RA0;  // Led azul que parpadeara cada 300ms usando delay_ms().

  
//***********************************************************************
//  PROCEDIMIENTO: _ISR_
//  I.S.R. : Interrupt Service Routine (Rutina de Servicio a la Interrupcion)
//  Cualquier interrupcion producida en el uC 16F84A salta a la
//  direccion $0004, a partir de la que código de programa debe decidir
//  que hacer.
//***********************************************************************
Procedure _ISR_; interrupt;
var
  Reg_W, Reg_STATUS : byte;  // Para guardar valores previos a interrupcion y restablecerlos antes de salir.
begin
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

  // INTERRUPCION TIMER TMR0 --------------------------------------------------------
  if (INTCON_T0IF = 1) then         // Comprueba si la interrupcion la ha producido el desbordamiento del TMR0.
    TMR0             := IniTMR0;    // Valor inicial de TMR0 para nueva cuenta.
    INTCON_T0IF      := 0;          // Restablece el valor del flag de deteccion de interrupcion TMR0.
    Inc(ContadorInTMR0);            // Incrementa contador de interrupciones
    if (ContadorInTMR0 = 4) then    // 4*(256-12)/(1e6/4/256) = 0,999424 segundos.      
      LED_1          := NOT LED_1;  // LED_1 invierte su valor.
      LED_2          := NOT LED_2;  // LED_2 invierte su valor.
      ContadorInTMR0 := 0;          // Se inicializa el contador de interrupciones.
    end;
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
end;


//***********************************************************************
// PROGRAMA PRINCIPAL ***************************************************
//***********************************************************************
begin
  // Configura puertos con entradas o salidas ---------------------------------------
  SetAsOutput(LED_1);         // Puerto como salida para encender/apagar el LED_1.
  SetAsOutput(LED_2);         // Puerto como salida para encender/apagar el LED_2.
  SetAsOutput(LED_AZUL);      // Puerto como salida para encender/apagar el LED_AZUL.
  // --------------------------------------------------------------------------------
  
  // Configuracion de Timer TMR0 ----------------------------------------------------
  OPTION_T0CS := 0;           // Origen de pulsos de incremento de TMR0 es cada ciclo de instruccion (Xtal/4).
  OPTION_T0SE := 0;           // Incrementea contador de TMR0 en los pulsos de bajada.
  OPTION_PSA  := 0;           // El divisor de frecuenta usado es el de TMR0
  OPTION_PS2  := 1;           // Configura divisor (Preescaler) de TMR0 con valor 111 = 1:256.
  OPTION_PS1  := 1;
  OPTION_PS0  := 1;
  // --------------------------------------------------------------------------------

  // Inicializa variables -----------------------------------------------------------
  ContadorInTMR0  := 0;       // Inicializa contador de interrupciones producidad por TMR0.
  LED_1           := 1;       // Inicializa el LED_1 encendido.
  LED_2           := 0;       // Inicializa el LED_2 apagado.
  LED_AZUL        := 1;       // Inicializa el LED_AZUL encendido.
  TMR0            := IniTMR0; // Carga valor de inicio de cuenta en TRM0.
  // --------------------------------------------------------------------------------
  
  // Habilita interrupciones --------------------------------------------------------
  INTCON_GIE      := 1;       // Habilita interruptiones de manera general.
  INTCON_T0IE     := 1;       // Habilita interrupciones por desbordamiento del Timer TMR0.
  // --------------------------------------------------------------------------------

  // LOOP de programa principal -----------------------------------------------------
  repeat  
    // Hacer algo. Por ejemplo, encender otros dos leds llamando a procedimiento para
    // comprobar que se conservan los valores de los registros previos a la interrupcion.
    LED_AZUL := NOT LED_AZUL;
    delay_ms(300);  
  until false;
  // --------------------------------------------------------------------------------
end.
