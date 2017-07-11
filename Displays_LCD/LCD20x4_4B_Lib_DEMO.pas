{
*
*  (C) AguHDz 06-JUL-2017
*  Ultima Actualizacion: 10-JUL-2017
*  Prueba para compilador PicPas v.0.7.2
* 
*  Demo de libreria para Manejo de display LCD 20x4 con PIC16F72
*  ================================================================
*  Imprime de manera repatitiva la demostracion en cualquier LCD 20x4
*  compatible con el estandar HITACHI HD44780.
*
}
{$FREQUENCY 8Mhz}

program LCD20x4_4B_Lib_DEMO;

uses PIC16F72, LCDLib_4bits;

const
  PAUSA = 50;

  FLECHA_DERECHA     = 0;         // Custom Character 0
  FLECHA_DERECHA_0   = %00001000;
  FLECHA_DERECHA_1   = %00000100;
  FLECHA_DERECHA_2   = %00000010;
  FLECHA_DERECHA_3   = %00011111;
  FLECHA_DERECHA_4   = %00000010;
  FLECHA_DERECHA_5   = %00000100;
  FLECHA_DERECHA_6   = %00001000;
  FLECHA_DERECHA_7   = %00000000;
  
  FLECHA_IZQUIERDA   = 1;         // Custom Character 1
  FLECHA_IZQUIERDA_0 = %00000010;
  FLECHA_IZQUIERDA_1 = %00000100;
  FLECHA_IZQUIERDA_2 = %00001000;
  FLECHA_IZQUIERDA_3 = %00011111;
  FLECHA_IZQUIERDA_4 = %00001000;
  FLECHA_IZQUIERDA_5 = %00000100;
  FLECHA_IZQUIERDA_6 = %00000010;
  FLECHA_IZQUIERDA_7 = %00000000;
  
  FLECHA_ARRIBA      = 2;         // Custom Character 2
  FLECHA_ARRIBA_0    = %00000100;
  FLECHA_ARRIBA_1    = %00001110;
  FLECHA_ARRIBA_2    = %00010101;
  FLECHA_ARRIBA_3    = %00000100;
  FLECHA_ARRIBA_4    = %00000100;
  FLECHA_ARRIBA_5    = %00000100;
  FLECHA_ARRIBA_6    = %00000100;
  FLECHA_ARRIBA_7    = %00000000;
  
  FLECHA_ABAJO       = 3;         // Custom Character 3
  FLECHA_ABAJO_0     = %00000100;
  FLECHA_ABAJO_1     = %00000100;
  FLECHA_ABAJO_2     = %00000100;
  FLECHA_ABAJO_3     = %00000100;
  FLECHA_ABAJO_4     = %00010101;
  FLECHA_ABAJO_5     = %00001110;
  FLECHA_ABAJO_6     = %00000100;
  FLECHA_ABAJO_7     = %00000000;  

  
var
  Counter, Number : byte;
  
procedure EsperaPausas(Pausas : byte);
begin
  while(Pausas>0) do    
    delay_ms(PAUSA);
    dec(Pausas);
  end;
end; 

procedure LCD_PrintPicPas;
begin
  LCD_WriteChar('P');
  LCD_WriteChar('i');
  LCD_WriteChar('c');
  LCD_WriteChar('P');
  LCD_WriteChar('a');
  LCD_WriteChar('s');
  LCD_WriteChar(' ');
  LCD_WriteChar('0');
  LCD_WriteChar('.');
  LCD_WriteChar('7');
  LCD_WriteChar('.');
  LCD_WriteChar('2'); 
end;

procedure LCD_PrintHolaMundo;
begin
  LCD_WriteChar('H');
  LCD_WriteChar('O');
  LCD_WriteChar('L');
  LCD_WriteChar('A');
  LCD_WriteChar(' ');
  LCD_WriteChar('M');
  LCD_WriteChar('U');
  LCD_WriteChar('N');
  LCD_WriteChar('D');
  LCD_WriteChar('O');  
end; 

procedure LCD_PrintDEMOLCDLib;
begin  
  LCD_WriteChar('D');
  LCD_WriteChar('E');
  LCD_WriteChar('M');
  LCD_WriteChar('O');
  LCD_WriteChar(' ');
  LCD_WriteChar('L');
  LCD_WriteChar('C');
  LCD_WriteChar('D');
  LCD_WriteChar('L');
  LCD_WriteChar('i');
  LCD_WriteChar('b');
end;

procedure LCD_PrintContador;
begin  
  LCD_WriteChar('C');
  LCD_WriteChar('o');
  LCD_WriteChar('n');
  LCD_WriteChar('t');
  LCD_WriteChar('a');
  LCD_WriteChar('d');
  LCD_WriteChar('o');
  LCD_WriteChar('r');
  LCD_WriteChar(':');
  LCD_WriteChar(' ');
end;

procedure LCD_PrintDisplay20x4;
begin  
  LCD_WriteChar('D');
  LCD_WriteChar('i');
  LCD_WriteChar('s');
  LCD_WriteChar('p');
  LCD_WriteChar('l');
  LCD_WriteChar('a');
  LCD_WriteChar('y');
  LCD_WriteChar(' ');
  LCD_WriteChar('2');
  LCD_WriteChar('0');
  LCD_WriteChar('x');  
  LCD_WriteChar('4');
end;

procedure LCD_WriteRepeatChar(repeticiones, pausas : byte; c: char);

begin
  while (repeticiones>0) do
    LCD_WriteChar(c);
    EsperaPausas(pausas);
    dec(repeticiones);
  end;
end;

procedure LCD_DeleteLine(Line : byte);
begin
  LCD_gotoxy(Line,0);
  LCD_WriteRepeatChar(19,0,' ');
end;
  
procedure LCD_BlinkDisplay(Flashes: byte);
begin
  while(Flashes>0) do
    LCD_DisplayOff;
    EsperaPausas(10);
    LCD_DisplayOn;
    EsperaPausas(10);
    dec(Flashes);
  end; 
end; 

//***************************************************************************//
// PROGRAMA PRINCIPAL
//***************************************************************************//
begin
  LCD_Init(20,4);   // LCD 20x4
  
  LCD_CreateChar(FLECHA_DERECHA,
                 FLECHA_DERECHA_0,
                 FLECHA_DERECHA_1,
                 FLECHA_DERECHA_2,
                 FLECHA_DERECHA_3,
                 FLECHA_DERECHA_4,
                 FLECHA_DERECHA_5,
                 FLECHA_DERECHA_6,
                 FLECHA_DERECHA_7);

  LCD_CreateChar(FLECHA_IZQUIERDA,
                 FLECHA_IZQUIERDA_0,
                 FLECHA_IZQUIERDA_1,
                 FLECHA_IZQUIERDA_2,
                 FLECHA_IZQUIERDA_3,
                 FLECHA_IZQUIERDA_4,
                 FLECHA_IZQUIERDA_5,
                 FLECHA_IZQUIERDA_6,
                 FLECHA_IZQUIERDA_7);
                 
  LCD_CreateChar(FLECHA_ARRIBA,
                 FLECHA_ARRIBA_0,
                 FLECHA_ARRIBA_1,
                 FLECHA_ARRIBA_2,
                 FLECHA_ARRIBA_3,
                 FLECHA_ARRIBA_4,
                 FLECHA_ARRIBA_5,
                 FLECHA_ARRIBA_6,
                 FLECHA_ARRIBA_7);
                 
  LCD_CreateChar(FLECHA_ABAJO,
                 FLECHA_ABAJO_0,
                 FLECHA_ABAJO_1,
                 FLECHA_ABAJO_2,
                 FLECHA_ABAJO_3,
                 FLECHA_ABAJO_4,
                 FLECHA_ABAJO_5,
                 FLECHA_ABAJO_6,
                 FLECHA_ABAJO_7);
  
  while true do 
    LCD_PrintHolaMundo;
    EsperaPausas(10);    
    LCD_BlinkDisplay(3);
        
    Number:=0;
    repeat
      Counter:=0;
      repeat
        LCD_gotoxy(Number,Counter);
        LCD_WriteChar('*');
        Inc(Counter);
      until(Counter=20);
      Inc(Number);
    until(Number=4);    
    EsperaPausas(10);
    
    LCD_Clear;
    for Counter:=0 to 19 do
      LCD_GotoXY(0,Counter);
      LCD_WriteChar(Chr(FLECHA_DERECHA));
      EsperaPausas(1);
    end;
    for Counter:=1 to 3 do
      LCD_GotoXY(Counter,19);
      LCD_WriteChar(Chr(FLECHA_ABAJO));
      EsperaPausas(1);
    end;    
    // En PicPas 0.7.2 los bucles FOR todavia no cuentan hacia atras.
    Counter := 18;
    repeat
      LCD_GotoXY(3,Counter);
      LCD_WriteChar(Chr(FLECHA_IZQUIERDA));
      EsperaPausas(1);
      dec(Counter);
    until(Counter = $FF);    
    Counter:=2;
    repeat
      LCD_GotoXY(Counter,0);
      LCD_WriteChar(Chr(FLECHA_ARRIBA));
      EsperaPausas(1);
      dec(Counter);
    until(Counter = 0); 
    for Counter:=1 to 18 do
      LCD_GotoXY(1,Counter);
      LCD_WriteChar(Chr(FLECHA_DERECHA));
      EsperaPausas(1);
    end;
    LCD_GotoXY(2,18);
    LCD_WriteChar(Chr(FLECHA_ABAJO));
    EsperaPausas(1); 
    Counter := 17;
    repeat
      LCD_GotoXY(2,Counter);
      LCD_WriteChar(Chr(FLECHA_IZQUIERDA));
      EsperaPausas(1);
      dec(Counter);
    until(Counter = 0);    
    EsperaPausas(10);    
    
    LCD_Clear;
    LCD_PrintPicPas;
    LCD_gotoxy(1,0);
    LCD_PrintDEMOLCDLib;
    LCD_gotoxy(2,0);
    LCD_PrintDisplay20x4; 
    
    LCD_gotoxy(3,0);
    LCD_PrintContador;
    Number:=2;
    repeat
      LCD_gotoxy(3,10);
      LCD_WriteChar(Chr(Number + 48));
      Counter:=9;
      repeat
        LCD_gotoxy(3,11);
        LCD_WriteChar(Chr(Counter + 48));
        EsperaPausas(2);
        Dec(Counter)
      until(Counter=$FF);
      Dec(Number);
    until(Number=$FF);
    EsperaPausas(20);
    
    LCD_DeleteLine(3);

    for Number:=1 to 5 do    
      for Counter := 0 to 9 do
        LCD_gotoXY(3,9-Counter);
        LCD_WriteChar('<');
        LCD_gotoXY(3,10+Counter);
        LCD_WriteChar('>');
        EsperaPausas(1);
      end;
      
      for Counter := 0 to 9 do
        LCD_gotoXY(3,9-Counter);
        LCD_WriteChar(' ');
        LCD_gotoXY(3,10+Counter);
        LCD_WriteChar(' ');
        EsperaPausas(1);
      end;
      
      for Counter := 0 to 9 do
        LCD_gotoXY(3,Counter);
        LCD_WriteChar('>');
        LCD_gotoXY(3,19-Counter);
        LCD_WriteChar('<');
        EsperaPausas(1);
      end;
    end;   

    delay_ms(1000);
    LCD_Clear;
    delay_ms(1000);
  end;
end.
///***************************************************************************//
