{
*  (C) AguHDz 28-JUN-2017
*  Ultima Actualizacion: 30-JUL-2017
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

uses PIC16F84A;

const
  HOLA_MUNDO      = 1;
  COMO_ESTA_USTED = 2;
  BIEN            = 3;
  MAL             = 4;
  GRACIAS         = 5;
 
Procedure Cadena_Data_Base(register posicion : byte) : char;
begin
  ASM
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
    RETLW 15    ; Cadena 2 
    RETLW 'C'
    RETLW 'O'
    RETLW 'M'
    RETLW 'O'
    RETLW ' '
    RETLW 'E'
    RETLW 'S'
    RETLW 'T'
    RETLW 'A'
    RETLW ' '
    RETLW 'U'
    RETLW 'S'
    RETLW 'T'
    RETLW 'E'
    RETLW 'D'
    ;------------------------- 
    RETLW  4    ; Cadena 3  
    RETLW 'B'
    RETLW 'I'
    RETLW 'E'
    RETLW 'N'
    ;------------------------- 
    RETLW  3    ; Cadena 4   
    RETLW 'M'
    RETLW 'A'
    RETLW 'L'
    ;------------------------- 
    RETLW  7    ; Cadena 5  
    RETLW 'G'
    RETLW 'R'
    RETLW 'A'
    RETLW 'C'
    RETLW 'I'
    RETLW 'A'
    RETLW 'S'
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
  while cadena < counter do
    valor   := Ord(Cadena_Data_Base(puntero));
    puntero := puntero + valor;
    inc(counter)
  end;
  valor   := Ord(Cadena_Data_Base(puntero));
  exit(valor);
end; 

Procedure String_Get_Char(cadena, caracter : byte) : char;
var
  puntero : byte;
  counter : byte;
begin
  puntero := 0;
  counter := 1;
  while cadena < counter do
    puntero := puntero + String_Length(counter);
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
    // a la pantalla LCD, o en general, al dispositivo de salida requerido.
  until contador < String_Length(cadena);
end;

begin
  String_Print(HOLA_MUNDO);
  String_Print(COMO_ESTA_USTED);  
  String_Print(BIEN);
  String_Print(MAL);
  String_Print(GRACIAS);
end. 
