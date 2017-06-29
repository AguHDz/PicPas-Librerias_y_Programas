{
*  (C) AguHDz 15-05-2017
*  Ultima Actualizacion: 23-05-2017 (Se añade directiva $MODE PASCAL para hacerlo
*  compatible con versiones posteriores a la 0.6.4 de PicPas.
*  
*  Prueba para compilador PicPas v.0.6.2
*  4 Displays led 7 segmentos con microcontrolador PIC 16F84A.
*
*  Utiliza la tecnica de retencion de imagen a alta frecuencia para encender
*  de manera secuencial los 4 displays a tal velocidad que para el ojo humano
*  todos permencen encendidos permanentemente.
*
*  Mensajes en display:
*  1.- Saluda con un "HOLA" y parpadea 3 veces.
*  2.- Inicio de secuencia mostrando "----".
*  3.- Cuenta 10 segundos en Display y parpadea 5 veces indicando fin de cuenta.
*  4.- Despedida con un "bye" y parpadea 2 veces.
*  5.- Secuencia de transicion de derecha a izquierda entre "bye" y mensaje final "End".
*  6.- Apaga Displays, pausa y vuelve a realizar toda la secuencia anterior.
}

{$MODE PASCAL}  // ACTIVA MODO COMPATIBILIDAD CON LENGUAJE PASCAL SIN MEJORAS.
{$PROCESSOR PIC16F84}
{$FREQUENCY 8Mhz}
program CuatroDisplays7Led;
 
uses PIC16F84A;

const
  // Tiempo en milisegundos que permanece encendido cada uno de los 4 displays.
  PAUSA_DISPLAY = 10;
  // Si es muy alto, se aprecia parpadeo en los displays.
  // Si es muy bajo o cero, no deja tiempo para encender los leds del display.

var
  Counter : byte;
  Display1, Display2, Display3, Display4 : byte;


//*******************************************************************************
// Refresco de Displays y mientra espera en pausas de la secuencia del programa.
//*******************************************************************************
procedure WriteDisplay(CounterTime : byte);
// El equivalente en milisegundos al valor CounterTime sera
// aproximadamente = (CounterTime * 4 * PAUSA_DISPLAY)
begin
  repeat
  begin
    // DISPLAY 1
    PORTB := 0;               // Apaga display (anterior).
    PORTA := $01;             // Seleeciona el display 1.
    PORTB := Display1;        // Enciende los leds correspondientes.
    delay_ms(PAUSA_DISPLAY);  // Tiempo que permanece encendido el display.
    // DISPLAY 2
    PORTB := 0;
    PORTA := $02;
    PORTB := Display2;
    delay_ms(PAUSA_DISPLAY);
    // DISPLAY 3
    PORTB := 0;
    PORTA := $04;
    PORTB := Display3;
    delay_ms(PAUSA_DISPLAY);
    // DISPLAY 4
    PORTB := 0;
    PORTA := $08;
    PORTB := Display4;
    delay_ms(PAUSA_DISPLAY);
    // Decremente el contador de tiempo
    dec(CounterTime);
  end;
  until CounterTime = 0;    // Comprueba si se ha transcurrido el tiempo programado.
end;

//***********************************************************************
// Escribe un caracter o numero (dato) en uno de los displays (digito)
//***********************************************************************
procedure SendToDisplayLed(dato : byte; digito : byte);
var
  Display : byte;
begin
{  // CASE..OF todavia no funciona en PicPas 0.6.2
  case numero of
  0 : Display := $3F;
  1 : Display := $06;
  2 : Display := $5B;
   ...
   else Display := $00;
  end; }
  Display := $00; // Apaga Display (o caracter Espacio).
//NUMEROS
  if dato = 0 then Display := $3F
  else if dato = 1 then Display := $06
  else if dato = 2 then Display := $5B
  else if dato = 3 then Display := $4F
  else if dato = 4 then Display := $66
  else if dato = 5 then Display := $6D
  else if dato = 6 then Display := $7D
  else if dato = 7 then Display := $07
  else if dato = 8 then Display := $7F
  else if dato = 9 then Display := $6F
//LETRAS
  else if dato = ord('A') then Display := $77
  else if dato = ord('b') then Display := $7C
  else if dato = ord('d') then Display := $5E
  else if dato = ord('e') then Display := $7B
  else if dato = ord('E') then Display := $79
  else if dato = ord('H') then Display := $76
  else if dato = ord('L') then Display := $38
  else if dato = ord('n') then Display := $54
  else if dato = ord('O') then Display := $3F
  else if dato = ord('y') then Display := $6E
  else if dato = ord('-') then Display := $40;
//if dato = ord(' ') then Display := $00;  // Apaga Display o Espacio.

//DISPLAY
  if digito = 1 then Display1 := Display
  else if digito = 2 then Display2 := Display
  else if digito = 3 then Display3 := Display
  else if digito = 4 then Display4 := Display;
end;

//***********************************************************************
// Escribe los 4 Displays.
//***********************************************************************
procedure DisplayPrint(D4:char;D3:char;D2:char;D1:char);
begin
  SendToDisplayLed(ord(D1),1);
  SendToDisplayLed(ord(D2),2);
  SendToDisplayLed(ord(D3),3);
  SendToDisplayLed(ord(D4),4);
end;

//***********************************************************************
// Escribe los 4 Displays con efecto parpadeo.
//***********************************************************************
procedure DisplayPrintBrink(D4:char;D3:char;D2:char;D1:char;Blinks:byte);
begin
  repeat
  begin
	DisplayPrint(' ',' ',' ',' ');
    WriteDisplay(10);
    DisplayPrint(D4,D3,D2,D1);
    WriteDisplay(10);
    dec(Blinks);
  end;
  until Blinks = 0;
end;

//***********************************************************************
// PROGRAMA PRINCIPAL ***************************************************
//***********************************************************************
begin

  TRISA := $F0;  // Configura Pines 1..4 de PORT4 como salidas.
  TRISB := $00;  // Configura PORTB como salidas.

  while true do  // Inicio de bucle infinito.
  begin
    // Mensaje HOLA en Display
    DisplayPrint('H','O','L','A');
    WriteDisplay(60);
    // Parpadea mensaje HOLA
    DisplayPrintBrink('H','O','L','A',3);

    DisplayPrint('-','-','-','-');
    WriteDisplay(40);

    // Pone a cero todos los digitos del Display.
    DisplayPrint(chr(0),chr(0),chr(0),chr(0));
    WriteDisplay(20);

    // Contador de 10 segundos.
    // Muestra en display numeros del 9 al 0.
    Counter := 10;
    repeat
    begin
      dec(Counter);
      SendToDisplayLed(Counter,1);
      WriteDisplay(25); // Aproximadamente 1000ms = 25*4*PAUSA_DISPLAY.
    end;
    until Counter = 0;

    // El numero cero parpadea 5 veces, indicando fin de cuenta.
    DisplayPrintBrink(chr(0),chr(0),chr(0),chr(0),5);

    // Mensaje de despedida "bye" con efecto transicion a "End".
    DisplayPrint('b','y','e',' ');
    WriteDisplay(100);
    DisplayPrintBrink('b','y','e',' ',2);
    WriteDisplay(20);
    DisplayPrint('y','e',' ','E');
    WriteDisplay(20);
    DisplayPrint('e',' ','E','n');
    WriteDisplay(20);
    DisplayPrint(' ','E','n','d');
    WriteDisplay(20);
    DisplayPrint('E','n','d',' ');
    WriteDisplay(100);
    DisplayPrint(' ',' ',' ',' ');
    WriteDisplay(100);
  end;  // Retorno de bucle infinito.
end.
