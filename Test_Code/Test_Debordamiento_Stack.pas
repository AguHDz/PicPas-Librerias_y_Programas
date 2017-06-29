// (C) AguHDz 07-05-2017
// Prueba para compilador PicPas v.0.5.8
// Nivel de anidamiento en llamadas a Procedimientos.
// Llamada repetitiva a procedimientos para encender LEDs hasta que se produzca
// un fallo en el codigo generado o un aviso de error de compilacion.

{$PROCESSOR PIC16F84}
{$FREQUENCY 8Mhz}
program TestDesbordaStack;

const
  PAUSA_ENCENDIDO = 1000;

var
  PORTA   : BYTE absolute $05;
  PORTB   : BYTE absolute $06;
  TRISA   : BYTE absolute $85;
  TRISB   : BYTE absolute $86;

//***************************************************************************//
// Enciende un Led.
//***************************************************************************//
procedure Led_11;
begin
  PORTB := $40;
  delay_ms(PAUSA_ENCENDIDO);
  //Led_12;
end;

//***************************************************************************//
// Enciende un Led.
//***************************************************************************//
procedure Led_10;
begin
  PORTB := $20;
  delay_ms(PAUSA_ENCENDIDO);
  //Led_11;
end;

//***************************************************************************//
// Enciende un Led.
//***************************************************************************//
procedure Led_09;
begin
  PORTB := $10;
  delay_ms(PAUSA_ENCENDIDO);
  //Led_10;
end;

//***************************************************************************//
// Enciende un Led.
//***************************************************************************//
procedure Led_08;
begin
  PORTB := $08;
  delay_ms(PAUSA_ENCENDIDO);
  //Led_09;
end;

//***************************************************************************//
// Enciende un Led.
//***************************************************************************//
procedure Led_07;
begin
  PORTB := $04;
  delay_ms(PAUSA_ENCENDIDO);
  //Led_08;
{
  ==========================================================================
  Nivel de anidamiento maximo = 8 (si se descomenta esta ultima linea, se
  produce un desbordamiento de pila:
  [PIC16 CORE] PC=0x0016. Stack underflow executing RETURN instruction. [U1]
  ========================================================================== 
}
end;

//***************************************************************************//
// Enciende un Led.
//***************************************************************************//
procedure Led_06;
begin
  PORTB := $02;
  delay_ms(PAUSA_ENCENDIDO);
  Led_07;
end;

//***************************************************************************//
// Enciende un Led.
//***************************************************************************//
procedure Led_05;
begin
  PORTA := $00;
  PORTB := $01;
  delay_ms(PAUSA_ENCENDIDO);
  Led_06;
end;

//***************************************************************************//
// Enciende un Led.
//***************************************************************************//
procedure Led_04;
begin
  PORTA := $08;
  delay_ms(PAUSA_ENCENDIDO);
  Led_05;
end;

//***************************************************************************//
// Enciende un Led.
//***************************************************************************//
procedure Led_03;
begin
  PORTA := $04;
  delay_ms(PAUSA_ENCENDIDO);
  Led_04;
end;

//***************************************************************************//
// Enciende un Led.
//***************************************************************************//
procedure Led_02;
begin
  PORTA := $02;
  delay_ms(PAUSA_ENCENDIDO);
  Led_03;
end;

//***************************************************************************//
// Enciende un Led.
//***************************************************************************//
procedure Led_01;
begin
  PORTA := $01;
  delay_ms(PAUSA_ENCENDIDO);
  Led_02;
end;

//***************************************************************************//
// Rutina de inicializacion.
// Configuracion de puertos como salidas.
//***************************************************************************// 
procedure PortInit;
begin
  TRISA := %11110000;
  TRISB := %00000000;
end;

//***************************************************************************//
// PROGRAMA PRINCIPAL
//***************************************************************************//
begin
  PortInit;
  while true do
  begin
    PORTA := $F0;
    PORTB := $00;
    Led_01;
  end;
end.
//***************************************************************************//
