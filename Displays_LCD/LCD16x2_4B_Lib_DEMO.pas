{
*
*  (C) AguHDz 06-JUL-2017
*  Ultima Actualizacion: 09-JUL-2017
*  Prueba para compilador PicPas v.0.7.2
* 
*  Demo de libreria para Manejo de display LCD 16x2 con PIC16F84A
*  ================================================================
*  Imprime de manera repatitiva la demostracion en cualquier LCD 16x2
*  compatible con el estandar HITACHI HD44780.
*
}

{$FREQUENCY 8Mhz}

program LCD16x2_4B_Lib_DEMO;

uses PIC16F84A, LCDLib_4bits;

const
  PAUSA = 50;
  
  SMILE_ALEGRE     = 0;         // Custom Character 0
  SMILE_ALEGRE_0   = %00000000;
  SMILE_ALEGRE_1   = %00001010;
  SMILE_ALEGRE_2   = %00000000;
  SMILE_ALEGRE_3   = %00000000;
  SMILE_ALEGRE_4   = %00010001;
  SMILE_ALEGRE_5   = %00001110;
  SMILE_ALEGRE_6   = %00000000;
  SMILE_ALEGRE_7   = %00000000;
  
  SMILE_TRISTE     = 1;         // Custom Character 1
  SMILE_TRISTE_0   = %00000000;
  SMILE_TRISTE_1   = %00001010;
  SMILE_TRISTE_2   = %00000000;
  SMILE_TRISTE_3   = %00000000;
  SMILE_TRISTE_4   = %00000000;
  SMILE_TRISTE_5   = %00001110;
  SMILE_TRISTE_6   = %00010001;
  SMILE_TRISTE_7   = %00000000;  

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
  LCD_Init(16,2);   // LCD 16x2
  
  LCD_CreateChar(SMILE_ALEGRE,         // Custom Character SMILE_ALEGRE
                 SMILE_ALEGRE_0,
                 SMILE_ALEGRE_1,
                 SMILE_ALEGRE_2,
                 SMILE_ALEGRE_3,
                 SMILE_ALEGRE_4,
                 SMILE_ALEGRE_5,
                 SMILE_ALEGRE_6,
                 SMILE_ALEGRE_7);

  LCD_CreateChar(SMILE_TRISTE,         // Custom Character SMILE_TRISTE
                 SMILE_TRISTE_0,
                 SMILE_TRISTE_1,
                 SMILE_TRISTE_2,
                 SMILE_TRISTE_3,
                 SMILE_TRISTE_4,
                 SMILE_TRISTE_5,
                 SMILE_TRISTE_6,
                 SMILE_TRISTE_7);
  
  while true do    
    LCD_gotoXY(1,0);
    LCD_PrintDEMOLCDLib;    
    EsperaPausas(20);
      
    LCD_CursorHome;
    LCD_Cursor(true, true, false);
    LCD_WriteChar('H');
    LCD_WriteChar('O');
    LCD_WriteChar('L');
    LCD_WriteChar('A');
    EsperaPausas(20); 
    LCD_CursorBlink;
    EsperaPausas(40);
    LCD_CursorUnderlineBlink;
    LCD_WriteChar(' ');
    EsperaPausas(3);
    LCD_WriteChar('M');
    EsperaPausas(3);
    LCD_WriteChar('U');
    EsperaPausas(3);
    LCD_WriteChar('N');
    EsperaPausas(3);
    LCD_WriteChar('D');
    EsperaPausas(3);
    LCD_WriteChar('O');    
    EsperaPausas(5);
    
    for Counter:=0 to 5 do
      LCD_DisplayCursorRight;
      EsperaPausas(10);
    end;
    
    for Counter:=0 to 5 do   
      EsperaPausas(10);
      LCD_DisplayCursorLeft;
    end;    
    
    LCD_CursorUnderline;
    for Counter:=0 to 2 do   
      EsperaPausas(5);
      LCD_WriteChar('.');
    end;
    EsperaPausas(10);
    
    LCD_BlinkDisplay(3);
    EsperaPausas(3);
    
    LCD_CursorOff;
    
    LCD_WriteChar(chr(SMILE_ALEGRE));
    LCD_DisplayCursorLeft;
    EsperaPausas(20);
    LCD_WriteChar(chr(SMILE_TRISTE));
    EsperaPausas(3);
    
    for Counter:=0 to 15 do
      LCD_DisplayShiftRight;
      EsperaPausas(1);
    end;
    
    for Counter:=0 to 15 do
      LCD_DisplayShiftLeft;
      EsperaPausas(1);
    end;

    LCD_DisplayCursorRight;
    LCD_DisplayCursorRight;
    LCD_PrintPicPas;
       
    for Counter:=0 to 13 do
      LCD_DisplayShiftLeft;
      EsperaPausas(1);
    end;
    
    EsperaPausas(6);
    LCD_BlinkDisplay(3);
    
    LCD_Clear;
    LCD_gotoXY(0,2);
    LCD_PrintPicPas;
    EsperaPausas(6);

    for Number:=1 to 5 do    
      for Counter := 0 to 7 do
        LCD_gotoXY(1,7-Counter);
        LCD_WriteChar('<');
        LCD_gotoXY(1,8+Counter);
        LCD_WriteChar('>');
        EsperaPausas(3);
      end;
      
      for Counter := 0 to 7 do
        LCD_gotoXY(1,7-Counter);
        LCD_WriteChar(' ');
        LCD_gotoXY(1,8+Counter);
        LCD_WriteChar(' ');
        EsperaPausas(3);
      end;
      
      for Counter := 0 to 7 do
        LCD_gotoXY(1,Counter);
        LCD_WriteChar('>');
        LCD_gotoXY(1,15-Counter);
        LCD_WriteChar('<');
        EsperaPausas(3);
      end;
    end;   

    delay_ms(1000);
    LCD_Clear;
    delay_ms(1000);
  end;
end.
///***************************************************************************//
