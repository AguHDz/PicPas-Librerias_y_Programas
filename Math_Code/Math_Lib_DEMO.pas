{
  (C) AguHDz 20-AGO-2017
  Ultima Actualizacion: 25-AGO-2017

  Compilador PicPas v.0.7.4 (https://github.com/t-edson/PicPas)

  DEMOSTRACION Y TESTEO DE LIBRERIA MATH (Operaciones Matemáticas Optimizadas)

}
program Math_Lib_DEMO;

{$PROCESSOR PIC16F877A}
{$FREQUENCY 8Mhz}
{$MODE PICPAS}

// AQUI SE DEFINE LA FUNCION USADA PARA IMPRIMIR LOS NUMEROS EN UN DISPOSITIVO DE SALIDA.
{$DEFINE SALIDA_LCD}
{$DEFINE FUNCION_PRINT_DIGITO=LCD_WriteChar}  // Libreria LCDLib_4bits
//{$DEFINE SALIDA_UARTSOFT}
//{$DEFINE FUNCION_PRINT_DIGITO=UARTSoft_SendChar}  // Libreria UARTSoftLib_8MHz_1200bps

{$DEFINE MS_PAUSA_PAGINAS=3000}  // Milisegundos de Pausa entre páginas de muestra de resultados de test.

uses PIC16F877A, Math, LCDLib_4bits;

var
  contador : word;
  auxiliar : byte;
  W_H_U_E  : dword; 
  
// IMPRESION DE TEXTOS -------------------------------------------------------

procedure LCDPrint_SUMA;
begin
  LCD_WriteChar('S');
  LCD_WriteChar('u');
  LCD_WriteChar('m');  
  LCD_WriteChar('a');
end;

procedure LCDPrint_RESTA;
begin
  LCD_WriteChar('R');
  LCD_WriteChar('e');
  LCD_WriteChar('s');  
  LCD_WriteChar('t');  
  LCD_WriteChar('a');
end; 

procedure LCDPrint_MUL;
begin
  LCD_WriteChar('M');
  LCD_WriteChar('u');
  LCD_WriteChar('l');
end;

procedure LCDPrint_MOD;
begin
  LCD_WriteChar('M');
  LCD_WriteChar('o');
  LCD_WriteChar('d');
end;

procedure LCDPrint_DIV;
begin
  LCD_WriteChar('D');
  LCD_WriteChar('i');
  LCD_WriteChar('v');
end;

procedure LCDPrint_BIT;
begin
  LCD_WriteChar('b');
  LCD_WriteChar('i');
  LCD_WriteChar('t');
end; 

procedure LCDPrint_CALCULANDO;
begin
  LCD_GotoXY(1,0);
  LCD_WriteChar('.');
  LCD_WriteChar('.');
  LCD_WriteChar('.');
  LCD_WriteChar('C');
  LCD_WriteChar('A');
  LCD_WriteChar('L');
  LCD_WriteChar('C');
  LCD_WriteChar('U');
  LCD_WriteChar('L');
  LCD_WriteChar('A');
  LCD_WriteChar('N');
  LCD_WriteChar('D');
  LCD_WriteChar('O');
end;

procedure LCDPrint_CALCULADO;
begin
  LCD_GotoXY(1,0);
  LCD_WriteChar('C');
  LCD_WriteChar('A');
  LCD_WriteChar('L');
  LCD_WriteChar('C');
  LCD_WriteChar('U');
  LCD_WriteChar('L');
  LCD_WriteChar('A');
  LCD_WriteChar('D');
  LCD_WriteChar('O');
  LCD_WriteChar(' ');
  LCD_WriteChar(' ');
  LCD_WriteChar(' ');
  LCD_WriteChar(' ');
  LCD_GotoXY(2,0);
  LCD_WriteChar('R');
  LCD_WriteChar('E');
  LCD_WriteChar('S');
  LCD_WriteChar('U');
  LCD_WriteChar('L');
  LCD_WriteChar('T');
  LCD_WriteChar('A');
  LCD_WriteChar('D');
  LCD_WriteChar('O');
  LCD_WriteChar('=');
end;

procedure LCDPrint_65535;
begin
  LCD_WriteChar('6');
  LCD_WriteChar('5');
  LCD_WriteChar('5');
  LCD_WriteChar('3');
  LCD_WriteChar('6');
end; 

// IMPRESION DE NUMEROS ---------------------------------------------

procedure Print_Digito;
// Imprime en formato HEXADECIMAL un número de 8 bits contenido en la variable auxiliar.
const
  CONV_CHR_NUMERO = $30;  // ASCII '0' ($30) menos $00 = $30
  CONV_CHR_LETRA  = $37;  // ASCII 'A' ($41) menos $10 = $37
begin
  if(auxiliar>9) then auxiliar := auxiliar + CONV_CHR_LETRA;
  else auxiliar := auxiliar + CONV_CHR_NUMERO end;
  //LCD_WriteChar(Chr(numero));
  {$FUNCION_PRINT_DIGITO}(Chr(auxiliar));
end;

procedure Print_Numero_8bit(numero : byte);
begin
  auxiliar := numero >> 4;
  Print_Digito;
  auxiliar := numero AND $0F;
  Print_Digito;
end;

procedure Print_Numero_16bit(dato : char);
begin
  if (dato='A') then
    Print_Numero_8bit(MATH_A_H);
    Print_Numero_8bit(MATH_A_L);
  else
    Print_Numero_8bit(MATH_B_H);
    Print_Numero_8bit(MATH_B_L); 
  end;
end;

procedure Print_Numero_32bit(dato : char);
begin
  if (dato='A') then
    Print_Numero_8bit(MATH_A_HH);
    Print_Numero_8bit(MATH_A_HL);
    Print_Numero_8bit(MATH_A_H);
    Print_Numero_8bit(MATH_A_L);
  else
    Print_Numero_8bit(MATH_B_HH);
    Print_Numero_8bit(MATH_B_HL);
    Print_Numero_8bit(MATH_B_H);
    Print_Numero_8bit(MATH_B_L); 
  end;
end;

procedure Print_Numero_64bit(dato : char);
begin
  if (dato='A') then
    Print_Numero_8bit(MATH_A_HHHH);
    Print_Numero_8bit(MATH_A_HHHL);
    Print_Numero_8bit(MATH_A_HHH);
    Print_Numero_8bit(MATH_A_HHL);
    Print_Numero_8bit(MATH_A_HH);
    Print_Numero_8bit(MATH_A_HL);
    Print_Numero_8bit(MATH_A_H);
    Print_Numero_8bit(MATH_A_L);
  else
    Print_Numero_8bit(MATH_B_HHHH);
    Print_Numero_8bit(MATH_B_HHHL);
    Print_Numero_8bit(MATH_B_HHH);
    Print_Numero_8bit(MATH_B_HHL);
    Print_Numero_8bit(MATH_B_HH);
    Print_Numero_8bit(MATH_B_HL);
    Print_Numero_8bit(MATH_B_H);
    Print_Numero_8bit(MATH_B_L); 
  end;
end;

 
// FUNCIONES DE TEST DE OPERACIONES IMPLEMENTADAS EN LIBRERIA MATH ------------
procedure PasoDePagina;
begin
  delay_ms({$MS_PAUSA_PAGINAS});
  LCD_Clear;
end;

// TEST SUMA 8 BITS -----------------------------------------------------------
procedure Test_SUMA_8bits;
begin
  LCDPrint_SUMA;
  LCD_WriteChar(' ');
  LCD_WriteChar('8');
  LCDPrint_BIT;
  
  MATH_A_L := $55;
  MATH_B_L := $99;
  LCD_GotoXY(1,0);
  Print_Numero_8bit(MATH_A_L);
  LCD_WriteChar('+');
  Print_Numero_8bit(MATH_B_L);
  LCD_WriteChar('=');
  Math_8bits_Sumar;
  Print_Numero_8bit(MATH_A_L);
  
  MATH_A_L := $91;
  MATH_B_L := $09;
  LCD_GotoXY(2,0);
  Print_Numero_8bit(MATH_A_L);
  LCD_WriteChar('+');
  Print_Numero_8bit(MATH_B_L);
  Math_8bits_Sumar;
  MATH_B_L := $09;
  LCD_WriteChar('+');
  Print_Numero_8bit(MATH_B_L);
  LCD_WriteChar('=');
  Math_8bits_Sumar;
  Print_Numero_8bit(MATH_A_L);
  
  MATH_A_L := $88;
  MATH_B_L := $34;
  LCD_GotoXY(3,0);
  Print_Numero_8bit(MATH_A_L);
  LCD_WriteChar('+');
  Print_Numero_8bit(MATH_B_L);
  Math_8bits_Sumar;
  MATH_B_L := $11;
  LCD_WriteChar('+');
  Print_Numero_8bit(MATH_B_L);
  Math_8bits_Sumar;
  MATH_B_L := $11;
  LCD_WriteChar('+');
  Print_Numero_8bit(MATH_B_L);
  Math_8bits_Sumar;
  MATH_B_L := $11;
  LCD_WriteChar('+');
  Print_Numero_8bit(MATH_B_L);
  Math_8bits_Sumar;
  MATH_B_L := $10;
  LCD_WriteChar('+');
  Print_Numero_8bit(MATH_B_L);
  LCD_WriteChar('=');
  Math_8bits_Sumar;
  Print_Numero_8bit(MATH_A_L);
  
  PasoDePagina;
  
  LCD_WriteChar('6');
  LCD_WriteChar('5');
  LCD_WriteChar('5');
  LCD_WriteChar('3');
  LCD_WriteChar('6');
  LCD_WriteChar(' ');
  LCDPrint_SUMA;
  LCD_WriteChar('s');
  LCD_WriteChar(' ');
  LCD_WriteChar('8');
  LCDPrint_BIT;

  LCDPrint_CALCULANDO;  
  contador := $FFFF;
  MATH_A_L := $00;
  repeat
    MATH_B_L := $01;
    Math_8bits_Sumar;
    dec(contador);
  until((contador.low OR contador.high) = 0);  // Más eficiente que usar (contador = word(0))
  
  LCDPrint_CALCULADO;
  LCD_GotoXY(3,18);
  Print_Numero_8bit(MATH_A_L);
end;

// TEST SUMA 16 BITS -----------------------------------------------------------
procedure Test_SUMA_16bits;
begin
  LCDPrint_SUMA;
  LCD_WriteChar(' ');
  LCD_WriteChar('1');
  LCD_WriteChar('6');
  LCDPrint_BIT;
  
  MATH_A_H := $15;
  MATH_A_L := $84;
  MATH_B_H := $12;
  MATH_B_L := $84;
  LCD_GotoXY(1,0);
  Print_Numero_16bit('A');
  LCD_WriteChar('+');
  Print_Numero_16bit('B');
  LCD_WriteChar('=');
  Math_16bits_Sumar;
  Print_Numero_16bit('A');
  
  MATH_A_H := $15;
  MATH_A_L := $84;
  MATH_B_H := $12;
  MATH_B_L := $84;
  LCD_GotoXY(2,0);
  Print_Numero_16bit('A');
  LCD_WriteChar('+');
  Print_Numero_16bit('B');
  Math_16bits_Sumar;  
  MATH_B_H := $12;
  MATH_B_L := $84;
  LCD_WriteChar('+');
  Print_Numero_16bit('B'); 
  LCD_WriteChar('=');
  Math_16bits_Sumar;
  Print_Numero_16bit('A');
  
  MATH_A_H := $0F;
  MATH_A_L := $FC;
  MATH_B_H := $01;
  MATH_B_L := $10;
  LCD_GotoXY(3,0);
  Print_Numero_16bit('A');
  LCD_WriteChar('+');
  Print_Numero_16bit('B');
  Math_16bits_Sumar;  
  MATH_B_H := $12;
  MATH_B_L := $02;
  LCD_WriteChar('+');
  Print_Numero_16bit('B'); 
  LCD_WriteChar('=');
  Math_16bits_Sumar;
  Print_Numero_16bit('A');
  
  PasoDePagina;
  
  LCD_WriteChar('6');
  LCD_WriteChar('5');
  LCD_WriteChar('5');
  LCD_WriteChar('3');
  LCD_WriteChar('6');
  LCD_WriteChar(' ');
  LCDPrint_SUMA;
  LCD_WriteChar('s');
  LCD_WriteChar(' ');
  LCD_WriteChar('1');
  LCD_WriteChar('6');
  LCDPrint_BIT;
  
  LCDPrint_CALCULANDO;
  contador := $FFFF;
  MATH_A_H := $00;
  MATH_A_L := $00;
  repeat
    MATH_B_H := $00;
    MATH_B_L := $01;
    Math_16bits_Sumar;
    dec(contador);
  until((contador.low OR contador.high) = 0);  // Más eficiente que usar (contador = word(0))
  LCDPrint_CALCULADO;
  LCD_GotoXY(3,16);
  Print_Numero_16bit('A');
end;

// TEST SUMA 32 BITS ----------------------------------------------------
procedure Test_SUMA_32bits;
begin
  LCDPrint_SUMA;
  LCD_WriteChar(' ');
  LCD_WriteChar('3');
  LCD_WriteChar('2');
  LCDPrint_BIT;

  MATH_A_HH := $02;
  MATH_A_HL := $DC;
  MATH_A_H  := $F3;
  MATH_A_L  := $A1;
  MATH_B_HH := $11;
  MATH_B_HL := $12;
  MATH_B_H  := $31;
  MATH_B_L  := $15;
  LCD_GotoXY(1,1);
  Print_Numero_32bit('A'); 
  LCD_WriteChar('+');
  Print_Numero_32bit('B');
  Math_32bits_Sumar;
  LCD_WriteChar('+');
  MATH_B_HH := $58;
  MATH_B_HL := $DC;
  MATH_B_H  := $33;
  MATH_B_L  := $01;  
  LCD_GotoXY(2,0);
  LCD_WriteChar('+');
  Print_Numero_32bit('B');
  Math_32bits_Sumar;
  LCD_WriteChar('+');
  MATH_B_HH := $01;
  MATH_B_HL := $E2;
  MATH_B_H  := $C3;
  MATH_B_L  := $11;
  Print_Numero_32bit('B');
  Math_32bits_Sumar;
  LCD_WriteChar('+');
  MATH_B_HH := $00;
  MATH_B_HL := $22;
  MATH_B_H  := $33;
  MATH_B_L  := $44;
  LCD_GotoXY(3,0);
  LCD_WriteChar('+');
  Print_Numero_32bit('B');
  Math_32bits_Sumar;
  LCD_WriteChar('=');
  Print_Numero_32bit('A');
  
  PasoDePagina;
   
  LCD_WriteChar('6');
  LCD_WriteChar('5');
  LCD_WriteChar('5');
  LCD_WriteChar('3');
  LCD_WriteChar('6');
  LCD_WriteChar(' ');
  LCDPrint_SUMA;
  LCD_WriteChar('s');
  LCD_WriteChar(' ');
  LCD_WriteChar('3');
  LCD_WriteChar('2');
  LCDPrint_BIT;
  
  LCDPrint_CALCULANDO;  
  contador := $FFFF;
  MATH_A_HH := $00;
  MATH_A_HL := $00;
  MATH_A_H  := $00;
  MATH_A_L  := $00;
  repeat
    MATH_B_HH := $00;
    MATH_B_HL := $01;
    MATH_B_H  := $00;
    MATH_B_L  := $01;
    Math_32bits_Sumar;
    dec(contador);
  until((contador.low OR contador.high) = 0);  // Más eficiente que usar (contador = word(0))
  LCDPrint_CALCULADO;
  LCD_GotoXY(3,12);
  Print_Numero_32bit('A');
end; 

// TEST SUMA 64 BITS ----------------------------------------------------------- 
procedure Test_SUMA_64bits;
begin
  LCDPrint_SUMA;
  LCD_WriteChar(' ');
  LCD_WriteChar('6');
  LCD_WriteChar('4');
  LCDPrint_BIT;
  
  MATH_A_HHHH := $02;
  MATH_A_HHHL := $D0;
  MATH_A_HHH  := $F3;
  MATH_A_HHL  := $A1;
  MATH_A_HH   := $02;
  MATH_A_HL   := $D0;
  MATH_A_H    := $F3;
  MATH_A_L    := $A1;
  LCD_GotoXY(1,1);
  Print_Numero_64bit('A');
  MATH_B_HHHH := $02;
  MATH_B_HHHL := $D0;
  MATH_B_HHH  := $F3;
  MATH_B_HHL  := $A1;
  MATH_B_HH   := $02;
  MATH_B_HL   := $D0;
  MATH_B_H    := $F3;
  MATH_B_L    := $A1;
  LCD_GotoXY(2,0);  
  LCD_WriteChar('+');
  Print_Numero_64bit('B');
  Math_64bits_Sumar;
  LCD_GotoXY(3,0);  
  LCD_WriteChar('=');
  Print_Numero_64bit('A'); 
  
  PasoDePagina; 

  LCDPrint_65535;
  LCD_WriteChar(' ');
  LCDPrint_SUMA;
  LCD_WriteChar('s');
  LCD_WriteChar(' ');
  LCD_WriteChar('6');
  LCD_WriteChar('4');
  LCDPrint_BIT;
  
  LCDPrint_CALCULANDO;   
  contador := $FFFF;
  MATH_A_HHHH := $00;
  MATH_A_HHHL := $00;
  MATH_A_HHH  := $00;
  MATH_A_HHL  := $00;
  MATH_A_HH   := $00;
  MATH_A_HL   := $00;
  MATH_A_H    := $00;
  MATH_A_L    := $00;
  repeat
    MATH_B_HHHH := $00;
    MATH_B_HHHL := $01;
    MATH_B_HHH  := $00;
    MATH_B_HHL  := $01;
    MATH_B_HH   := $00;
    MATH_B_HL   := $01;
    MATH_B_H    := $00;
    MATH_B_L    := $01;
    Math_64bits_Sumar;
    dec(contador);
  until((contador.low OR contador.high) = 0);  // Más eficiente que usar (contador = word(0))
  LCDPrint_CALCULADO;
  LCD_GotoXY(3,4);
  Print_Numero_64bit('A');
end; 

// Inicializa el dispositico de salida (display LCD, Terminal Serie, etc.)
procedure Init_OUT_Device;
begin
{$IFDEF SALIDA_LCD}
  LCD_Init(4,20);
{$ENDIF}  
end; 

procedure ParaCrear_H_U_E : dword;
begin
  W_H_U_E := $12345678;
  exit(W_H_U_E);
end;
 
//**************************************************************
// P R O G R A M A   P R I N C I P A L
//**************************************************************
begin
  Init_OUT_Device;

  ParaCrear_H_U_E;   

// Demostración de uso de operaciones matemáticas de librería Math

  Test_SUMA_8bits;
  PasoDePagina;  
  Test_SUMA_16bits;
  PasoDePagina;
  Test_SUMA_32bits;
  PasoDePagina;
  Test_SUMA_64bits;

// ---------------------------------------------------------------

end.
