{
*  (C) AguHDz 06-JUL-2017
*  Ultima Actualizacion: 29-JUL-2017
*
*  Compilador PicPas v.0.7.2 (https://github.com/t-edson/PicPas)
*
*  LIBRERIA MANEJO DE DISPLAY LCD (BUS DATOS: 4 BITS)
*  ==================================================
*  Para LCD compatibles con el estandar HITACHI HD44780
*  Usando el modo Bus de Datos de 4 bits.
*  
   INSTRUCCIONES DE USO DE LIBRERIA:
    
    1. Incluir libreria LCD_4B_lib.
    2. Si es necesario, modificar nombre el nombre del microcontrolador
       (uses PIC16F84A) y los pines por defecto usados en esta libreria para
       definir la conexion entre el PIC y el Display LCD:
       
       LCD_DATA_4: Pin del puerto I/O del PIC que se conecta al pin D4 del bus
                   de datos del Display LCD.
       LCD_DATA_5: Pin del puerto I/O del PIC que se conecta al pin D5 del bus
                   de datos del Display LCD.
       LCD_DATA_6: Pin del puerto I/O del PIC que se conecta al pin D6 del bus
                   de datos del Display LCD.
       LCD_DATA_7: Pin del puerto I/O del PIC que se conecta al pin D7 del bus
                   de datos del Display LCD.
       LCD_RS    : Pin de puerto I/O del PIC que se conecta al pin RS (REGISTER
                   SELECT) del Display.
       LCD_EN    : Pin de puerto I/O del PIC que se conecta al pin E (ENABLE)
                   del Display.

       NOTA: Las funciones de esta libreria estan programadas de tal manera que
       es indiferente el puerto al que pertenezca cada uno de estos pines de
       control del Display. Se puede utilizar cualquier pin de cualquier puerto
       para cada pin de control.

   
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
    D4 (LCD pin 11) a PIC: LCD_DATA_4
    D5 (LCD pin 12) a PIC: LCD_DATA_5
    D6 (LCD pin 13) a PIC: LCD_DATA_6
    D7 (LCD pin 14) a PIC: LCD_DATA_7    
}

unit LCDLib_4bits;

interface

uses PIC16F877A, LCDLib_Const, Math_Word_Type; //en la versión 0.7.2 no funciona la importacion de funciones con sobrecarga de datos.

const
  LCD_CmdMode  = 0;    // valores de pin RS
  LCD_CharMode = 1;
 
var
  LCD_DATA_4   : bit absolute PORTB.4;  // BIT D0 BUS de datos 4 bits.
  LCD_DATA_5   : bit absolute PORTB.5;  // BIT D1 BUS de datos 4 bits.
  LCD_DATA_6   : bit absolute PORTB.6;  // BIT D2 BUS de datos 4 bits.
  LCD_DATA_7   : bit absolute PORTB.7;  // BIT D3 BUS de datos 4 bits.    
  LCD_RS       : bit absolute PORTB.2;  // SELECT REGISTER.
  LCD_EN       : bit absolute PORTB.3;  // ENABLE STARTS DATA READ/WRITE.
  LCD_FILAS    : byte;                  // Lineas del LCD.
  LCD_COLUMNAS : byte;                  // Caracteres por linea del LCD.
  LCD_Counter  : byte;

//-----------------------------------------------------------------------------
// Envia los 4 bits superiores al puerto de datos de 4 bits en Display.
procedure LCD_Send_4bits(dat: byte);
//-----------------------------------------------------------------------------
// Envia un datos en Display.
procedure LCD_Send(dat: byte);
//-----------------------------------------------------------------------------
// El dato enviado es un Comando.
procedure LCD_Command(comm: byte);
//-----------------------------------------------------------------------------
// El dato enviado es un caracter a mostrar en el display LCD.
procedure LCD_WriteChar(register c: char);
{//-----------------------------------------------------------------------------
// Imprime un numero enviado en formato word;
procedure Words_Comparar(dato1,dato2: word) : byte;
procedure Words_Restar(minuendo,sustraendo: word) : word;
procedure Resto_Dividir (dividendo, divisor : word) : word;
procedure Dividir (dividendo, divisor : word) : word;
procedure LCD_Print_Number(numero : word);}
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

procedure LCD_Print_Number(numero : word; decimales: byte; digitos: byte; caracter_derecha: char);
//-----------------------------------------------------------------------------
// Impresión de números:
// numero           : Variables numérica de tipo word a imprimir en display.
// decimales        : Numero de decimales del valor numerico. (división por 10)
// digitos          : Digitos del numero a imprimir (entre 1 y 5)
// caracter_derecha : Caracter ASCII para rellenar espacio de ceros a la izquierda del número.
//                    Puede ser cualquier caracter, pero lo normal sería un 0 (cero) para simular
//                    una especie de contador o un espacio para justificar la posición del valor
//                    a imprimir. Si vale 0 (chr(0)) no imprime nada (justificación a la izquierda)
//
//    Ejemplos:
//    
//    LCD_Print_Number(word(12354), 3, 5, chr(0));  -->  12,354
//    LCD_Print_Number(word(354), 0, 5, chr(0));    -->  354
//    LCD_Print_Number(word(354), 7, 5, chr(0));    -->  0,0000354     
//    LCD_Print_Number(word(0), 0, 5, '0');         -->  00000
//    LCD_Print_Number(word(55), 2, 5, chr(0));     -->  0,55
//-----------------------------------------------------------------------------

// =======================================================================
// N O T A   I M P O R T A N T E :
// SOBRE LOS TIEMPOS DE ESPERA TRAS CADA INSTRUCCION ENVIADA, RECORDAR
// QUE: La funcion LCD_Command ya INCLUYE 2 ms de espera. (Ver LCD_Send)
// =======================================================================

implementation

//-----------------------------------------------------------------------------
procedure LCD_Send_4bits(dat: byte);
begin
  LCD_DATA_4 := dat.4;
  LCD_DATA_5 := dat.5;
  LCD_DATA_6 := dat.6;
  LCD_DATA_7 := dat.7;
  LCD_EN   := 1;
  delay_ms(2);     // Pulso de 2 ms de anchura.
  LCD_EN   := 0;
end;
//-----------------------------------------------------------------------------
procedure LCD_Send(dat : byte);
begin
  LCD_Send_4bits(dat);
  LCD_Send_4bits(dat<<4);
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
  SetAsOutput(LCD_DATA_4);
  SetAsOutput(LCD_DATA_5);
  SetAsOutput(LCD_DATA_6);
  SetAsOutput(LCD_DATA_7);
  SetAsOutPut(LCD_RS);
  SetAsOutPut(LCD_EN);
  
  //----------------------------
  // Reservado para futuros usos.
  LCD_FILAS    := filas;
  LCD_COLUMNAS := columnas;
  //----------------------------
 
  delay_ms(300); // Espera para asegurar tension estable tras arranque.
  
  LCD_RS := 0;
  LCD_EN := 0;

  // =======================================================================
  // SOBRE LOS TIEMPOS DE ESPERA TRAS CADA INSTRUCCION ENVIADA, RECORDAR
  // QUE: La funcion LCD_Command ya INCLUYE 2 ms de espera. (Ver LCD_Send)
  // =======================================================================
 
  // INICIACION DE DISPLAY MODO 4 BITS DE DATOS
  // Los tiempos de espera son los indicados en todos los
  // datasheets de los displays compatibles con el estandar Hitachi HD44780.
  LCD_Send_4bits(%00110000);
  delay_ms(5);  // Espera > 4.1 ms
  LCD_Send_4bits(%00110000);
  delay_ms(1);  // Espera > 100 us
  LCD_Send_4bits(%00110000);
  delay_ms(1);  // No sería necesario, pero se espera 1 ms por estabilizar.
  LCD_Send_4bits(%00100000);
 
  // Parametros mas comunes de configuracion y uso de displays LCD.
  // Se pueden modificar segun necesidad.
  LCD_Command(LCD_FUNCTION_SET + LCD_4BIT_INTERFACE + LCD_2LINES + LCD_F_FONT_5_8);
  LCD_Command(LCD_DISPLAY_ON_OFF_AND_CURSOR + LCD_DISPLAY_OFF);
  LCD_Command(LCD_CLEAR_DISPLAY);
  LCD_Command(LCD_CHARACTER_ENTRY_MODE + LCD_INCREMENT + LCD_DISPLAY_SHIFT_OFF);
  LCD_Command(LCD_DISPLAY_ON_OFF_AND_CURSOR + LCD_DISPLAY_ON);
  LCD_Command(LCD_DISPLAY_AND_CURSOR_HOME);
end;
//-----------------------------------------------------------------------------
procedure LCD_Print_Number(numero : word; decimales: byte; digitos: byte; caracter_derecha: char);
var
  digito              : word;      // Variable auxiliar que contien el digito a imprimir (decena millar, millar, centena, decena y unidad)
  div_dec             : word;      // Variable auxiliar por la que dividir para obtener cada uno de los digitos.
  contador            : byte;      // Contador de bucle.
  parte_decimal       : boolean;   // flag que indica que se estan escribiendo la parte decimal del numero.
  fin_ceros_izquierda : boolean;   // flag que indica que se han acabado los ceros a la izquierda del numero.
begin
  fin_ceros_izquierda := false;    // Escribir ceros a la izquierda del numero (valores ceros a la izquierda)
  parte_decimal       := false;    // No estamos escribiendo la parte decimal del numero.
  
  if(decimales>=digitos) then      // Cualquier variable de tipo word esta compuesto como máximo por 5 números (decena millar, millar, centena, decena y unidad)
    LCD_WriteChar('0');            // Si hay más de 5 decimales, es necesario escribir el cero inicial y la coma de separación decimal.
    LCD_WriteChar(',');  
    parte_decimal := true;         // Estamos escribiendo la parte decimal de número.
    while(decimales>digitos) do    // Escribe todos los ceros decimales necesarios antes de empezar a escribir los valores del número.
      dec(decimales);
      LCD_WriteChar('0');
    end;      
  end;
    
  digito := 0;
  contador := digitos;             // Cualquier variable de tipo word esta compuesto como máximo por 5 números (decena millar, millar, centena, decena y unidad)

  div_dec := 1;
  repeat                           // Genera un número 10, 100, 1000 o 10000 en función de la variable de entrada con los digitos a imprimir.
    Dec(digitos);
    div_dec := Multiplicar(div_dec,10);    
  until(digitos=1);
  
  while(contador>0) do             // Inicia LOOP    
    // COMPRUEBA SI ES NECESARIO E IMPRIME SEPARADOR DE PARTE DECIMAL DEL NUMERO.     
    if((decimales = contador) AND NOT parte_decimal) then  // Si estamos en la posición de inicio de la parte decimal escribir la coma separadora. 
      if(NOT fin_ceros_izquierda) then                     // Comprueba si es necesario escribir una cero antes de la coma separadora.
        LCD_WriteChar('0');
      end;
      LCD_WriteChar(',');
      parte_decimal := true; // A partir de aquí todos los dígitos son parte decimal del número.  
    end;
    
    dec(contador);    // Se coloca aquí en vez de al final de bucle, como es habitual, para optimizar la comparación if(decimales<>contador) de más abajo.
    
    // CALCULA EL DIGITO DEL NUMERO A IMPRIMIR. 
    digito := Dividir(numero,div_dec);  // Obtiene el valor de digito del número a imprimir.
    
    // IMPRIME EL DIGITO SI ES DISTINTO DE CERO.
    if(digito.low > 0) then        // Comprueba si el dígito del número es cero 
      LCD_WriteChar(chr(digito.low+$30));  // Si es distinto de cero lo imprime en el display.
      fin_ceros_izquierda := true;         // Si se imprime un primer dígito distinto de cero es que ya no existen ceros no a la izquierda del número.
    // SI EL DIGITO ES CERO, DEPENDIENDO DE LA SITUACION SE IMPRIMIRAN DISTINTOS TIPOS DE CARACTERES O NO SE IMPRIMIRA NINGUNO.
    else
      if(parte_decimal OR fin_ceros_izquierda OR (contador = 0)) then  // Si el dígito de valor cero está en la parte decimal, no es un cero a la izquierda, el  lo imprime.
        LCD_WriteChar('0');
      elsif(caracter_derecha <> chr(0)) then  // Si se trata de un cero a la izquierda (en la parte no decimal) y se ha indicado que se desea escribir        
        if(decimales<>contador) then          // algún caracter como el propio cero o un espacio de justificación, lo imprime.
          LCD_WriteChar(caracter_derecha)     // La comprobación (decimales<>contador) es necesaria para evitar conflicto con la impresión de valores 0,XX
        end; 
      end;                                    // Si no, no imprime nada.   
    end;
    
    // CALCULO DE VARIABLES NECESARIAS PARA OBTENER EL SIGUIENTE DIGITO A IMPRIMIR.
    numero := Resto_Dividir(numero,div_dec);  // Realiza calculo de resto de división, eliminando el valor de dígito ya impreso.
    div_dec := Dividir(div_dec,word(10));     // Calcula el nuevo divisor para extraer el siguiente dígito del número.
  end;    
end;
{
PRIMERA VERSION DE LA FUNCION. MEJORADA AÑADIENDO LA OPCION DE IMPRIMIR UN NUMERO DE DIGITOS DETERMINADO
PARA PODER COMBINARLO E IMPRIMIR NUMEROS CON MENOS DE 5 DIGITOS.
procedure LCD_Print_Number(numero : word; decimales: byte; caracter_derecha: char);
var
  digito              : word;      // Variable auxiliar que contien el digito a imprimir (decena millar, millar, centena, decena y unidad)
  div_dec             : word;      // Variable auxiliar por la que dividir para obtener cada uno de los digitos.
  contador            : byte;      // Contador de bucle.
  parte_decimal       : boolean;   // flag que indica que se estan escribiendo la parte decimal del numero.
  fin_ceros_izquierda : boolean;   // flag que indica que se han acabado los ceros a la izquierda del numero.
begin
  fin_ceros_izquierda := false;    // Escribir ceros a la izquierda del numero (valores ceros a la izquierda)
  parte_decimal       := false;    // No estamos escribiendo la parte decimal del numero.
  
  if(decimales>=5) then            // Cualquier variable de tipo word esta compuesto como máximo por 5 números (decena millar, millar, centena, decena y unidad)
    LCD_WriteChar('0');            // Si hay más de 5 decimales, es necesario escribir el cero inicial y la coma de separación decimal.
    LCD_WriteChar(',');  
    parte_decimal := true;         // Estamos escribiendo la parte decimal de número.
    while(decimales>5) do          // Escribe todos los ceros decimales necesarios antes de empezar a escribir los valores del número.
      dec(decimales);
      LCD_WriteChar('0');
    end;      
  end;
  
  digito := 0;
  contador := 5;                   // Cualquier variable de tipo word esta compuesto como máximo por 5 números (decena millar, millar, centena, decena y unidad)
  div_dec := 10000;                // Primer valor del divisor para obtener las decenas de millar.
  while(contador>0) do             // Inicia LOOP
    
    // COMPRUEBA SI ES NECESARIO E IMPRIME SEPARADOR DE PARTE DECIMAL DEL NUMERO.     
    if((decimales = contador) AND NOT parte_decimal) then  // Si estamos en la posición de inicio de la parte decimal escribir la coma separadora. 
      if(NOT fin_ceros_izquierda) then                     // Comprueba si es necesario escribir una cero antes de la coma separadora.
        LCD_WriteChar('0');
      end;
      LCD_WriteChar(',');
      parte_decimal := true; // A partir de aquí todos los dígitos son parte decimal del número.  
    end;
    
    dec(contador);    // Se coloca aquí en vez de al final de bucle, como es habitual, para optimizar la comparación if(decimales<>contador) de más abajo.
    
    // CALCULA EL DIGITO DEL NUMERO A IMPRIMIR. 
    digito := Dividir(numero,div_dec);  // Obtiene el valor de digito del número a imprimir.
    
    // IMPRIME EL DIGITO SI ES DISTINTO DE CERO.
    if(digito.low > 0) then        // Comprueba si el dígito del número es cero 
      LCD_WriteChar(chr(digito.low+$30));  // Si es distinto de cero lo imprime en el display.
      fin_ceros_izquierda := true;         // Si se imprime un primer dígito distinto de cero es que ya no existen ceros no a la izquierda del número.
    // SI EL DIGITO ES CERO, DEPENDIENDO DE LA SITUACION SE IMPRIMIRAN DISTINTOS TIPOS DE CARACTERES O NO SE IMPRIMIRA NINGUNO.
    else
      if(parte_decimal OR fin_ceros_izquierda OR (contador = 0)) then  // Si el dígito de valor cero está en la parte decimal, no es un cero a la izquierda, el  lo imprime.
        LCD_WriteChar('0');
      elsif(caracter_derecha <> chr(0)) then  // Si se trata de un cero a la izquierda (en la parte no decimal) y se ha indicado que se desea escribir        
        if(decimales<>contador) then          // algún caracter como el propio cero o un espacio de justificación, lo imprime.
          LCD_WriteChar(caracter_derecha)     // La comprobación (decimales<>contador) es necesaria para evitar conflicto con la impresión de valores 0,XX
        end; 
      end;                                    // Si no, no imprime nada.   
    end;
    
    // CALCULO DE VARIABLES NECESARIAS PARA OBTENER EL SIGUIENTE DIGITO A IMPRIMIR.
    numero := Resto_Dividir(numero,div_dec);  // Realiza calculo de resto de división, eliminando el valor de dígito ya impreso.
    div_dec := Dividir(div_dec,word(10));     // Calcula el nuevo divisor para extraer el siguiente dígito del número.
  end; 
 
end;
}
//-----------------------------------------------------------------------------
end.
