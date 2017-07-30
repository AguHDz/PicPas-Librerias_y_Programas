{
*
*  (C) AguHDz 21-JUL-2017
*  Ultima Actualizacion: 29-JUL-2017
*  Prueba para compilador PicPas v.0.7.2
* 
*  Demo de libreria para imprimir valores numéricos en display LCD
*  ===============================================================
*  Simula la impresión de valores en distintos formatos numéricos.
*
*  LCD_Print_Number(numero : word; decimales: byte; caracter_derecha: char);
*    - numero    : Variables numérica de tipo word a imprimir en display.
*    - decimales : Numero de decimales del valor numerico. (división por 10)
*    - digitos   : Digitos del numero a imprimir (entre 1 y 5)
*    - caracter_derecha : Caracter ASCII para rellenar espacio de ceros a la izquierda del número.
*                         Puede ser cualquier caracter, pero lo normal sería un 0 (cero) para simular
*                         una especie de contador o un espacio para justificar la posición del valor
*                         a imprimir. Si vale 0 (chr(0)) no imprime nada (justificación a la izquierda)
*
*    Ejemplos:
*    
*    LCD_Print_Number(word(12354), 3, 5, chr(0));  -->  12,354
*    LCD_Print_Number(word(354), 0, 5, chr(0));    -->  354
*    LCD_Print_Number(word(354), 7, 5, chr(0));    -->  0,0000354     
*    LCD_Print_Number(word(0), 0, 5, '0');         -->  00000
*    LCD_Print_Number(word(55), 2, 5, chr(0));     -->  0,55
*    
*    
*    LCD_Print_Number(v, 2, 5, chr(0));   Si v=100 -->  1,00
*    LCD_Print_Number(v, 2, 5, chr(0));   Si v=360 -->  3,60
*    LCD_Print_Number(v, 2, 5, chr(0));  Si v=1254 -->  12,54
*    LCD_Print_Number(v, 2, 5, chr(0)); Si v=15254 -->  152,54
*
*    LCD_Print_Number(v, 2, 5, ' ');      Si v=100 -->    1,00
*    LCD_Print_Number(v, 2, 5, ' ');      Si v=360 -->    3,60
*    LCD_Print_Number(v, 2, 5, ' ');     Si v=1254 -->   12,54
*    LCD_Print_Number(v, 2, 5, ' ');    Si v=15254 -->  152,54
*
*    LCD_Print_Number(v, 2, 5, '0');      Si v=100 -->  001,00
*    LCD_Print_Number(v, 2, 5, '0');      Si v=360 -->  003,60
*    LCD_Print_Number(v, 2, 5, '0');     Si v=1254 -->  012,54
*    LCD_Print_Number(v, 2, 5, '0');    Si v=15254 -->  152,54
*
*    Impresión de números largos:
*
*    Numero largo = 128659852
*    Los divimos en dos variables: numero_long_low (4 digitos) y numero_long_high (5 digitos)
*    numero_long_low := 9852;
*    numero_long_high := 12865;
*    LCD_Print_Number(numero_long_high, 2, 5, '0');
*    LCD_Print_Number(numero_long_low, 2, 4, '0'); --> 128659852
*
*    Otro número largo con ceros intermedios:
*    LCD_Print_Number(2865, 0, 5, '0');
*    LCD_Print_Number(852, 0, 4, '0');             --> 028650852
*
*    Numero largo con dos decimales:
*    LCD_Print_Number(2865, 0, 5, '0');
*    LCD_Print_Number(852, 2, 4, '0');             --> 0286508,52
*
*    Numero largo de 17 dígitos con dos decimales:
*    LCD_Print_Number(2865, 0, 5, '0');
*    LCD_Print_Number(25, 0, 4, '0');
*    LCD_Print_Number(1234, 0, 4, '0');
*    LCD_Print_Number(852, 2, 4, '0');             --> 028650025123408,52
*
}

{$FREQUENCY 8Mhz}
{$PROCESSOR PIC16F877A}

program LCD20x4_4B_Lib_DEMO_numeros;

uses PIC16F877A, LCDLib_4bits;  // Con libreria Math (funciones distintos tipos de datos) no funciona.

var
  v : word;

procedure LCD_Print_VOLTAJE;
begin
  LCD_WriteChar('V');
  LCD_WriteChar('O');
  LCD_WriteChar('L');
  LCD_WriteChar('T');
  LCD_WriteChar('A');
  LCD_WriteChar('J');
  LCD_WriteChar('E');
  LCD_WriteChar(':');
  LCD_Print_Number(word(226),0,5,chr(0));
  LCD_WriteChar('v');
end;

procedure LCD_Print_CORRIENTE;
begin
  LCD_WriteChar('C');
  LCD_WriteChar('O');
  LCD_WriteChar('R');
  LCD_WriteChar('R');
  LCD_WriteChar('I');
  LCD_WriteChar('E');
  LCD_WriteChar('N');
  LCD_WriteChar('T');
  LCD_WriteChar('E');
  LCD_WriteChar(':');
  LCD_Print_Number(word(1045),2,5,chr(0));
  LCD_WriteChar('A');
end;

procedure LCD_Print_COS_phi;
begin
  LCD_WriteChar('C');
  LCD_WriteChar('O');
  LCD_WriteChar('S');
  LCD_WriteChar(' ');
  LCD_WriteChar('p');
  LCD_WriteChar('h');
  LCD_WriteChar('i');
  LCD_WriteChar(':');
  LCD_Print_Number(word(96),2,5,chr(0));
end;

procedure LCD_Print_P_ACTIVA;
begin

  LCD_Print_Number(word(8566),0,5,'0');
  LCD_WriteChar('K');
  LCD_WriteChar('V');
  LCD_WriteChar('A');
end;

procedure LCD_Print_P_REACTIVA;
begin
  LCD_Print_Number(word(650),0,5,'0');
  LCD_WriteChar('K');
  LCD_WriteChar('V');
  LCD_WriteChar('A');
  LCD_WriteChar('r');
end;


begin
  LCD_Init(20,4);   // LCD 20x4

  LCD_GotoXY(0,2);
  LCD_Print_VOLTAJE;
  LCD_GotoXY(1,0);
  LCD_Print_CORRIENTE;
  LCD_GotoXY(2,2);
  LCD_Print_COS_phi;
  LCD_GotoXY(3,0);
  LCD_Print_P_ACTIVA;
  LCD_GotoXY(3,11);
  LCD_Print_P_REACTIVA; 
  
  delay_ms(3000); 
  
  LCD_Clear; 
  LCD_Print_Number(word(12354), 3,5, chr(0)); //  -->  12,354
  LCD_GotoXY(1,0); 
  LCD_Print_Number(word(354), 0,5, chr(0));   //  -->  354
  LCD_GotoXY(2,0); 
  LCD_Print_Number(word(354), 7,5, chr(0));   //  -->  0,0000354 
  LCD_GotoXY(3,0);     
  LCD_Print_Number(word(0), 0,5, '0');        //  -->  00000
  LCD_GotoXY(3,16); 
  LCD_Print_Number(word(55), 2,5, chr(0));    //  -->  0,55
 
  delay_ms(3000); 
  
  LCD_Clear;  
  v:=100; 
  LCD_Print_Number(v, 2,5, chr(0)); //   Si v=100 -->  1,00 
  LCD_GotoXY(1,0);
  v:=360;
  LCD_Print_Number(v, 2,5, chr(0)); //   Si v=360 -->  3,60
  LCD_GotoXY(2,0);
  v:=1254;
  LCD_Print_Number(v, 2,5, chr(0)); //  Si v=1254 -->  12,54 
  LCD_GotoXY(3,0); 
  v:=15254;
  LCD_Print_Number(v, 2,5, chr(0)); // Si v=15254 -->  152,54
 
  delay_ms(3000); 

  LCD_Clear;  
  v:=100;
  LCD_Print_Number(v, 2,5, ' ');    //   Si v=100 -->    1,00 
  LCD_GotoXY(1,0); 
  v:=360;
  LCD_Print_Number(v, 2,5, ' ');    //   Si v=360 -->    3,60
  LCD_GotoXY(2,0);
  v:=1254;
  LCD_Print_Number(v, 2,5, ' ');    //  Si v=1254 -->   12,54
  LCD_GotoXY(3,0);  
  v:=15254;
  LCD_Print_Number(v, 2,5, ' ');    // Si v=15254 -->  152,54
 
  delay_ms(3000); 
  
  LCD_Clear;
  v:=100;
  LCD_Print_Number(v, 2,5, '0');    //   Si v=100 -->  001,00
  LCD_GotoXY(1,0);
  v:=360;
  LCD_Print_Number(v, 2,5, '0');    //   Si v=360 -->  003,60
  LCD_GotoXY(2,0);
  v:=1254;
  LCD_Print_Number(v, 2,5, '0');    //  Si v=1254 -->  012,54
  LCD_GotoXY(3,0); 
  v:=15254;
  LCD_Print_Number(v, 2,5, '0');    // Si v=15254 -->  152,54
  
  delay_ms(3000);
 
  LCD_Clear;
  LCD_Print_Number(12865, 0, 5, '0');
  LCD_Print_Number(9852, 0, 4, '0'); //           --> 128659852
  LCD_GotoXY(1,0);
  v:=2865;
  LCD_Print_Number(v, 0, 5, '0');
  v:=852;
  LCD_Print_Number(v, 0, 4, '0'); //              --> 028650852
  LCD_GotoXY(2,0);
  v:=2865;
  LCD_Print_Number(v, 0, 5, '0');
  v:=852;
  LCD_Print_Number(v, 2, 4, '0'); //              --> 0286508,52
  LCD_GotoXY(3,0); 
  v:=2865;
  LCD_Print_Number(v, 0, 5, '0');
  v:=25;
  LCD_Print_Number(v, 0, 4, '0');
  v:=1234;
  LCD_Print_Number(v, 0, 4, '0');
  v:=852;
  LCD_Print_Number(v, 2, 4, '0'); //              --> 028650025123408,52
  
end. 
