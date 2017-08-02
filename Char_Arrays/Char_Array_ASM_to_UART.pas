{
*  (C) AguHDz 28-JUN-2017
*  Ultima Actualizacion: 01-AGO-2017
*
*  Compilador PicPas v.0.7.2 (https://github.com/t-edson/PicPas)
*
*  FUNCIONES PARA MANEJO DE STRINGS CONSTANTES (Cadenas de Caracteres)
*
*  Las cadenas se alojan en la memoria de programa en el formato estándar
*  del lenguaje Pascal: 1 byte de longitud de cadena + caracteres de la cadena.
*  El tamaño máximo de cada cadena es de 255 bytes, pero podemos tener tantas
*  cadenas como memoria de programa dispongamos.
}

{$FREQUENCY 8 MHZ }
{$PROCESSOR PIC16F84A}

program cadenas_String;

uses PIC16F84A, UARTSoftLib_8MHz_4800bps;

var
  // Es encesario definirlo aquí y en el programa que use esta librería.
  UART_RX : bit absolute PORTB_RB7;
  UART_TX : bit absolute PORTB_RB6;
  // --------------------------------------------

const
  HOLA_MUNDO         = 1;
  COMO_ESTAN_USTEDES = 2;
  MUY_BIEN           = 3;
  MAL                = 4;
  GRACIAS            = 5;
  RETORNO_DE_CARRO   = 6;

// El programa no utiliza interruptciones, pero definiendo esta función como
// de interrupción me aseguro de que la parte alta del contador de programa
// es 00 y puedo escribir cadenas hasta ocupar 252 bytes ($0100 - $0004 = 252)
// Si el programa utilizara interrupciones, no sería complicado compabilizar la
// tabla de datos con el código de a ejecutar en las interruptciones.
Procedure Cadena_Data_Base(register posicion : byte) : char; interrupt;
begin
  ASM
  ; Direccion $0004
    ADDWF PCL,F
    ;-------------------------  
    RETLW 10    ; Cadena 1
    RETLW 'H'
    RETLW 'O'
    RETLW 'L'
    RETLW 'A'
    RETLW ' '
    RETLW 'M'
    RETLW 'U'
    RETLW 'N'
    RETLW 'D'
    RETLW 'O'
    ;-------------------------  
    RETLW 19   ; Cadena 2  
    RETLW 'C'
    RETLW 'o'
    RETLW 'm'
    RETLW 'o'
    RETLW ' '
    RETLW 'e'
    RETLW 's'
    RETLW 't'
    RETLW 'a'
    RETLW 'n'
    RETLW ' '
    RETLW 'u'
    RETLW 's'
    RETLW 't'
    RETLW 'e'
    RETLW 'd'
    RETLW 'e'
    RETLW 's'
    RETLW '?'
    ;------------------------- 
    RETLW  8    ; Cadena 3
    RETLW 'M'
    RETLW 'u'
    RETLW 'y'
    RETLW ' '
    RETLW 'b'
    RETLW 'i'
    RETLW 'e'
    RETLW 'n'
    ;------------------------- 
    RETLW  3    ; Cadena 4   
    RETLW 'M'
    RETLW 'a'
    RETLW 'l'
    ;------------------------- 
    RETLW  7    ; Cadena 5  
    RETLW 'G'
    RETLW 'r'
    RETLW 'a'
    RETLW 'c'
    RETLW 'i'
    RETLW 'a'
    RETLW 's'
    ;------------------------- 
    RETLW  2    ; Cadena 6  
    RETLW  10
    RETLW  13    
  END
end;

Procedure String_Length(cadena : byte) : byte;
var
  puntero : byte;
  counter : byte;
  valor   : byte;
begin
  puntero := 0;
  counter := 1;
  while(counter<=cadena) do
    valor   := Ord(Cadena_Data_Base(puntero));
    puntero := puntero + valor + 1;
    inc(counter);
  end;
  exit(valor);
end; 

Procedure String_Get_Char(cadena, caracter : byte) : char;
var
  puntero : byte;
  counter : byte;
begin
  puntero := 0;
  counter := 1;
  while(counter<cadena) do
    puntero := puntero + String_Length(counter) + 1;
    inc(counter)
  end;
  puntero := puntero + caracter;
  exit(Cadena_Data_Base(puntero));
end;

Procedure String_Print(cadena : byte);
var
  contador : byte;
  caracter : char;
begin
  contador := 1;
  repeat 
    caracter := String_Get_Char(cadena,contador);
    inc(contador);
    // Llamar aquí a la función que debe enviar el caracter al puerto serie,
    // a la pantalla LCD, o en general, al dispositivo de salida deseado.
    UARTSoft_SendChar(caracter);
  until(contador > String_Length(cadena));
end;

begin
  UARTSoft_Init;
  
  String_Print(HOLA_MUNDO);
  String_Print(RETORNO_DE_CARRO);
  String_Print(COMO_ESTAN_USTEDES);
  String_Print(RETORNO_DE_CARRO);
  String_Print(MUY_BIEN);
  String_Print(RETORNO_DE_CARRO);
  String_Print(GRACIAS);
end. 
