{Cadenas de Caracteres}

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

Procedure Cadena_Get_Longitud(cadena : byte) : byte;
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

Procedure Cadena_Get_Caracter(cadena, caracter : byte) : char;
var
  puntero : byte;
  counter : byte;
begin
  puntero := 0;
  counter := 1;
  while cadena < counter do
    puntero := puntero + Cadena_Get_Longitud(counter);
    inc(counter)
  end;
  puntero := puntero + caracter;
  exit(Cadena_Data_Base(puntero));
end;

Procedure Cadena_Print(cadena : byte);
var
  contador : byte;
//  longitud : byte;
  caracter : char;
begin
  contador := 1;
  repeat 
    caracter := Cadena_Get_Caracter(cadena,contador);
    inc(contador);
  until contador < Cadena_Get_Longitud(cadena);
{  
  longitud := Cadena_Get_Longitud(cadena);
  for contador:=1 to longitud do
    caracter := Cadena_Get_Caracter(cadena,contador);
  end;
  }
end;

begin
  Cadena_Print(HOLA_MUNDO);
  Cadena_Print(COMO_ESTA_USTED);  
  Cadena_Print(BIEN);
  Cadena_Print(MAL);
  Cadena_Print(GRACIAS);
end. 
