{
*  (C) AguHDz 06-JUL-2017
*  Ultima Actualizacion: 09-JUL-2017
*
*  Compilador PicPas v.0.7.2 (https://github.com/t-edson/PicPas)
*
*  LIBRERIA MANEJO DE DISPLAY LCD (BUS DATOS: 8 BITS)
*  ==================================================
*  Para LCD compatibles con el estandar HITACHI HD44780
*  Usando el modo Bus de Datos de 8 bits.
*  
   INSTRUCCIONES DE USO DE LIBRERIA:
    
    1. Incluir libreria LCD_8B_lib.
    2. Si es necesario, modificar nombre el nombre del microcontrolador
       (uses PIC16F84A) y los pines por defecto usados en esta libreria para
       definir la conexion entre el PIC y el Display LCD:
       
       LCD_DATA: Puerto I/O de 8 bits del PIC que se conecta al bus de datos
                 del Display LCD.
       LCD_RS  : Pin de puerto I/O del PIC que se conecta al pin RS (REGISTER
                 SELECT) del Display.
       LCD_EN  : Pin de puerto I/O del PIC que se conecta al pin E (ENABLE) del
                 Display.
   
   INSTRUCCIONES DE CONEXIONADO ELECTRICO:
   
     ---- Alimentacion y Contraste ----
    Vss  (LCD pin 1) a negativo alimentacion
    Vdd  (LCD pin 2) a + 5V, (si no queremos controlar el apagado el LCD)
    Contraste (LCD pin 3) a tierra a traves de una resistencia fija (p.e. 2K2,
    menos valor = mayor contraste) o de un potenciometro ajustable de 5K.
    
    ---- Control ----
    RS (LCD pin 4) a PIC: LCD_RS
    RW (LCD pin 5) a tierra (= LCD pin 1)
    E  (LCD pin 6) a PIC: LCD_EN
 
    ---- Data ----
    D0 (LCD pin  7) a PIC: LCD_DATA.0
    D1 (LCD pin  8) a PIC: LCD_DATA.1
    D2 (LCD pin  9) a PIC: LCD_DATA.2
    D3 (LCD pin 10) a PIC: LCD_DATA.3
    D4 (LCD pin 11) a PIC: LCD_DATA.4
    D5 (LCD pin 12) a PIC: LCD_DATA.5
    D6 (LCD pin 13) a PIC: LCD_DATA.6
    D7 (LCD pin 14) a PIC: LCD_DATA.7    
}

unit LCDLib_8bits;

interface

uses PIC16F84A, LCDLib_Const;

const
  LCD_CmdMode  = 0;    // valores de pin RS
  LCD_CharMode = 1;
 
var
  LCD_DATA     : byte absolute PORTB;    // 8 BIT DATA BUS.
  LCD_RS       : bit  absolute PORTA.0;  // SELECT REGISTER.
  LCD_EN       : bit  absolute PORTA.1;  // ENABLE STARTS DATA READ/WRITE.
  LCD_FILAS    : byte;                   // Lineas del LCD.
  LCD_COLUMNAS : byte;                   // Caracteres por linea del LCD.
  LCD_Counter  : byte;

  
//-----------------------------------------------------------------------------
// Envia un datos en Display.
procedure LCD_Send(register dat: byte);
//-----------------------------------------------------------------------------
// El dato enviado es un Comando.
procedure LCD_Command(register comm: byte);
//-----------------------------------------------------------------------------
//El dato enviado es un caracter a mostrar en el display LCD.
procedure LCD_WriteChar(register c: char);
//-----------------------------------------------------------------------------
// Mueve el cursor del display a la fila y columan indicada.
// Esquina superior izquierda (0,0)
// En display 16x2: Esquina inferior derecha (1,15)
procedure LCD_GotoXY(fila,columna: byte);
//-----------------------------------------------------------------------------
// Mueve el cursor a la posicion (0,0). Esquina superior izquierda.
procedure LCD_CursorHome;
//-----------------------------------------------------------------------------
// Borrar todos los caracteres de la pantalla y manda el cursor a la posicion
// esquina superior izquierda (0,0)
procedure LCD_Clear;
//-----------------------------------------------------------------------------
// Muestra barra baja en la posicion del cursor.
procedure LCD_CursorUnderline;
//-----------------------------------------------------------------------------
// Parpadeo en la posicion del cursor.
procedure LCD_CursorBlink;
//-----------------------------------------------------------------------------
// Barra baja y parpadeo en posicion del cursor.
procedure LCD_CursorUnderlineBlink;
//-----------------------------------------------------------------------------
// Elimina cualquier efecto indicador de la posicion del cursor.
procedure LCD_CursorOff;
//-----------------------------------------------------------------------------
// Apaga el display ocultando su contenido.
procedure LCD_DisplayOff;
//-----------------------------------------------------------------------------
// Muestra contenido de display.
// Elimina cualquier indicador de posiciion de cursor en display, por lo que
// si se estaban usando estos indicadores, es necesario reactivarlos.
procedure LCD_DisplayOn;
//-----------------------------------------------------------------------------
// Manejo simultaneo de los tres parametros de configuracion del cursor.
// OnOff     : Muestra/Oculta los caracteres en el display.
// Underline : Muestra/Oculta barra inferior indicando posicion del cursor.
// Blink     : Muestra/Oculta parpadeo indicando posicion del cursor.
procedure LCD_Cursor(OnOff, Underline, Blink :boolean);
//-----------------------------------------------------------------------------
// Mueve el contenido mostrado en el display una posicion a la derecha.
procedure LCD_DisplayShiftRight;
//-----------------------------------------------------------------------------
// Mueve el contenido mostrado en el display una posicion a la izquierda.
procedure LCD_DisplayShiftLeft;
//-----------------------------------------------------------------------------
// Mueve el cursor una posicion a la derecha.
procedure LCD_DisplayCursorRight;
//-----------------------------------------------------------------------------
// Mueve el cursor una posicion a la izquierda.
procedure LCD_DisplayCursorLeft;
//-----------------------------------------------------------------------------
// Crear un nuevo Custom Character. (Caracter Personalizado)
procedure LCD_CreateChar(charnum, chardata0, chardata1, chardata2, chardata3,
                         chardata4, chardata5, chardata6, chardata7 : byte);
//-----------------------------------------------------------------------------
// Rutina de inicializacion del display LCD.
// Resetea el LCD y lo inicializa en modo 8 bit mode, 2 columnas y cursor off.
procedure LCD_Init(columnas, filas : byte);
//-----------------------------------------------------------------------------

// =======================================================================
// N O T A   I M P O R T A N T E :
// SOBRE LOS TIEMPOS DE ESPERA TRAS CADA INSTRUCCION ENVIADA, RECORDAR
// QUE: La funcion LCD_Command ya INCLUYE 2 ms de espera. (Ver LCD_Send)
// =======================================================================

implementation

//-----------------------------------------------------------------------------
procedure LCD_Send(register dat: byte);
begin
  LCD_DATA := dat;
  LCD_EN   := 1;
  delay_ms(2);     // Pulso de 2 ms de anchura.
  LCD_EN   := 0;
  delay_ms(2);     // Espera 2 ms. Tiempo suficiente para que se interprete y
                   // ejecute cualquier instruccion enviada al Display LCD.
end;
//-----------------------------------------------------------------------------
procedure LCD_Command(register Comm: byte);
begin
  LCD_RS   := LCD_CmdMode;
  LCD_Send(Comm);
end;
//-----------------------------------------------------------------------------
procedure LCD_WriteChar(register c: char);
begin
  LCD_RS   := LCD_CharMode;
  LCD_Send(ord(c));
end;
//-----------------------------------------------------------------------------
procedure LCD_GotoXY(fila,columna: byte);
begin
  if    (fila = 0) then
    LCD_Command(LCD_SET_DISPLAY_ADDRESS + columna + LCD_ROW_0);
  elsif (fila = 1) then
    LCD_Command(LCD_SET_DISPLAY_ADDRESS + columna + LCD_ROW_1);
  elsif (fila = 2) then
    LCD_Command(LCD_SET_DISPLAY_ADDRESS + columna + LCD_ROW_2);
  elsif (fila = 3) then
    LCD_Command(LCD_SET_DISPLAY_ADDRESS + columna + LCD_ROW_3);  
  end;
end;
//-----------------------------------------------------------------------------
procedure LCD_CursorHome;
begin
  LCD_Command(LCD_DISPLAY_AND_CURSOR_HOME);
end;
//-----------------------------------------------------------------------------
procedure LCD_Clear;
begin
  LCD_Command(LCD_CLEAR_DISPLAY);
end;
//-----------------------------------------------------------------------------
procedure LCD_CursorUnderline;
begin
  LCD_Command(LCD_DISPLAY_ON_OFF_AND_CURSOR + LCD_DISPLAY_ON + LCD_CURSOR_UNDERLINE_ON);
end;
//-----------------------------------------------------------------------------
procedure LCD_CursorBlink;
begin
  LCD_Command(LCD_DISPLAY_ON_OFF_AND_CURSOR + LCD_DISPLAY_ON + LCD_CURSOR_BLINK_ON);
end;
//-----------------------------------------------------------------------------
procedure LCD_CursorUnderlineBlink;
begin
  LCD_Command(LCD_DISPLAY_ON_OFF_AND_CURSOR + LCD_DISPLAY_ON + LCD_CURSOR_UNDERLINE_ON + LCD_CURSOR_BLINK_ON);  
end;
//-----------------------------------------------------------------------------
procedure LCD_CursorOff;
begin
  LCD_Command(LCD_DISPLAY_ON_OFF_AND_CURSOR + LCD_DISPLAY_ON + LCD_CURSOR_UNDERLINE_OFF + LCD_CURSOR_BLINK_OFF);
end;
//-----------------------------------------------------------------------------
procedure LCD_DisplayOn;
begin
  LCD_Command(LCD_DISPLAY_ON_OFF_AND_CURSOR + LCD_DISPLAY_ON);
end;
//-----------------------------------------------------------------------------
procedure LCD_DisplayOff;
begin
  LCD_Command(LCD_DISPLAY_ON_OFF_AND_CURSOR + LCD_DISPLAY_OFF);
end;
//-----------------------------------------------------------------------------
procedure LCD_Cursor(OnOff, Underline, Blink : boolean);
var
  command : byte;
begin
  command := LCD_DISPLAY_ON_OFF_AND_CURSOR;
  if OnOff then command := command + LCD_DISPLAY_ON; end;
  if Underline then command := command + LCD_CURSOR_UNDERLINE_ON; end;
  if Blink then command := command + LCD_CURSOR_BLINK_ON; end;
  LCD_Command(command);
end;
//-----------------------------------------------------------------------------
procedure LCD_DisplayShiftRight;
begin
  LCD_Command(LCD_DISPLAY_AND_CURSOR_SHIFT + LCD_DISPLAY_SHIFT + LCD_RIGHT); 
end;
//-----------------------------------------------------------------------------
procedure LCD_DisplayShiftLeft;
begin
  LCD_Command(LCD_DISPLAY_AND_CURSOR_SHIFT + LCD_DISPLAY_SHIFT + LCD_LEFT);
end;
//-----------------------------------------------------------------------------
procedure LCD_DisplayCursorRight;
begin
  LCD_Command(LCD_DISPLAY_AND_CURSOR_SHIFT + LCD_CURSOR_MOVE + LCD_RIGHT);
end;
//-----------------------------------------------------------------------------
procedure LCD_DisplayCursorLeft;
begin
  LCD_Command(LCD_DISPLAY_AND_CURSOR_SHIFT + LCD_CURSOR_MOVE + LCD_LEFT);
end;
//-----------------------------------------------------------------------------
procedure LCD_CreateChar(charnum,
                         chardata0,
                         chardata1,
                         chardata2,
                         chardata3,
                         chardata4,
                         chardata5,
                         chardata6,
                         chardata7 : byte);
begin
  charnum := charnum AND $07;  // Previene errores sin charnum > 7;
  charnum := charnum << 3;
  LCD_Command(LCD_SET_CGRAM_ADDRESS + charnum);
  LCD_WriteChar(Chr(chardata0));
  LCD_WriteChar(Chr(chardata1));
  LCD_WriteChar(Chr(chardata2));
  LCD_WriteChar(Chr(chardata3));
  LCD_WriteChar(Chr(chardata4));
  LCD_WriteChar(Chr(chardata5));
  LCD_WriteChar(Chr(chardata6));
  LCD_WriteChar(Chr(chardata7));
  LCD_Clear;    // Necesario para finalizar la creacion de Custom Character.
end;
//-----------------------------------------------------------------------------
procedure LCD_Init(columnas, filas : byte);
begin
  SetAsOutput(LCD_DATA);
  SetAsOutPut(LCD_RS);
  SetAsOutPut(LCD_EN);
  
  //----------------------------
  // Reservado para futuros usos.
  LCD_FILAS    := filas;
  LCD_COLUMNAS := columnas;
  //----------------------------

  delay_ms(300); // Espera para asegurar tension estable tras arranque. 
  
  LCD_RS   := 0;
  LCD_EN   := 0;

  // =======================================================================
  // SOBRE LOS TIEMPOS DE ESPERA TRAS CADA INSTRUCCION ENVIADA, RECORDAR
  // QUE: La funcion LCD_Command ya INCLUYE 2 ms de espera. (Ver LCD_Send)
  // =======================================================================
 
  // INICIACION DE DISPLAY MODO 8 BITS DE DATOS
  // Los tiempos de espera son los indicados en todos los
  // datasheets de los displays compatibles con el estandar Hitachi HD44780.
  LCD_Command(LCD_FUNCTION_SET + LCD_8BIT_INTERFACE);
  delay_ms(5);  // Espera > 4.1 ms
  LCD_Command(LCD_FUNCTION_SET + LCD_8BIT_INTERFACE);
  delay_ms(1);  // Espera > 100 Us
  LCD_Command(LCD_FUNCTION_SET + LCD_8BIT_INTERFACE);
  
 
  // Parametros mas comunes de configuracion y uso de displays LCD.
  // Se pueden modificar segun necesidad.
  LCD_Command(LCD_FUNCTION_SET + LCD_8BIT_INTERFACE + LCD_2LINES + LCD_F_FONT_5_8);
  LCD_Command(LCD_DISPLAY_ON_OFF_AND_CURSOR + LCD_DISPLAY_OFF);
  LCD_Command(LCD_CLEAR_DISPLAY);
  LCD_Command(LCD_CHARACTER_ENTRY_MODE + LCD_INCREMENT + LCD_DISPLAY_SHIFT_OFF);
  LCD_Command(LCD_DISPLAY_ON_OFF_AND_CURSOR + LCD_DISPLAY_ON);
  LCD_Command(LCD_DISPLAY_AND_CURSOR_HOME);
end;
//-----------------------------------------------------------------------------

end.
