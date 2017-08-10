// (C) AguHDz 13-05-2017
// Ultima Actualizacion: 10-08-2017
// Prueba para compilador PicPas v.0.7.3
//
// WatchDog Timer en microcontrolador PIC 16F84A.
// Enciende y apaga led conectado a pin RB0 usando el timer WatchDog para
// reiniciar el microcontrolador en cada ciclo de encendido y apagado.
// Demostracion del uso de instrucciones en ensamblador dentro de codigo PicPas.

{*
  Fuses de microcontrolador:
  - Oscilator Selection: HS (Alta velocidad con Cristal Externo)
  - Wathtdog Timer: Enable (Si no lo estuviera este programa no funciona)
  - Power-up Timer: Disable.
  - Code Protecction: OFF.

  Resultado FUSES de esta configuracion; $3FFE
  En el PIC 16F84A se graba en la posicion de memoria $2007
  Es el :02400E00FE3F73 en la penultima linea del fichero HEX generado.
 *}

{$PROCESSOR PIC16F84A}

{$FREQUENCY 8Mhz}

// A partir de la versión 0.7.3 PicPas admite la inclusión de
// texto externo y e incluir en el fichero HEX los FUSES
// o Palabra de Configuración del Microcontrolador.
{$INCLUDE .\INCLUDE\FUSES_16F84A.inc}
{$CONFIG _CP_OFF, _PWRT_OFF, _HS_OSC, _WDT_ON }

program WatchDog_Timer;

uses PIC16F84A;

begin
  // Asigna preescala al WDT (PSA=1) con valor 1:64 (PS2:PS0=110).
  OPTION := %00001110;
  // Tiempo de RESET por Watchdog = 4*1/8e6*256*128*64 = 1,048576 segundos.
  // Mas info sobre Timer PIC en:
  //  https://es.slideshare.net/lmzurita/gua-rpida-tmr0-e-interrupciones

  // Inicio de codigo ensamblador insertado en programa
  asm
    CLRWDT    ; clear WatchDog Timer
  end
  // Fin de codigo ensamblador

  TRISB := $00;        // Configura PORTB como output.
  PORTB := $01;        // Enciende led.
  Delay_ms(500);       // Espera 0.5 segundos.
  PORTB := $00;        // Apaga led.

  repeat until false;  // Bucle infinito a la espera de que el el WatchDog reinicie el PIC.
end.
