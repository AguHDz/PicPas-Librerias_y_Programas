{
*  (C) AguHDz 03-AGO-2017
*  Ultima Actualizacion: 03-AGO-2017
*
*  Compilador PicPas v.0.7.2 (https://github.com/t-edson/PicPas)
*
*  < T E S T   C O N   M I C R O C O N T R O L A D O R   P I C 1 6 F 8 7 7 >
*
*  FUNCIONES MATEMATICAS NO IMPLEMENTADAS (OPTIMIZADA) 
*  ===================================================
*  Para poder avanzar en el uso y prueba de PicPas se hace necesario
*  contar con ciertas operaciones mantemáticas básicas como la multiplicación
*  y la división, o funciones para comparar u operar con variables tipo word.
*
*  Ya se hicieron dos librerías con funciones matemáticas:
*
*  - Math.pas : Funciones genéricas que en teoría deberían funcionar para
                cualquier tipo de datos de entrada de los manejados por
                Picpas en su versión 0.7.2. Sin embargo, en la práctica
                no parece estár muy bien implementada la sobrecarga de 
                funciones en esta versión por lo que su inclusión da muchos
                problemas de errores de reconocimiento de tipos de datos.
                
   - Math_Type_Word: Se opta por usar el tipo de dato numérico más grande 
                que maneja la versión 0.7.2 de Picpas (el tipo word) y solo
                se incluyen las funciones con este tipo de variables. Funciona
                perfectamente, pero a la hora de queres optinizar las funciones
                usando código ensamblador, aunque funciona en caso particulares
                para cada microcontrolador, al no heredar las constantes definidas
                en el programa que incluye la librería, el registro STATUS del SFR
                debe incluirse en la librería y sería necesario particularizar
                para cada microcontrolador (aunque hasta donde se, este registro
                permanece en la misma posición de memoria para toda la familia
                PIC16.
                
   Se implementa esta nueva "librería", en realidad una colección de funciones
   matemáticas más optimizadas, pero debido a los problemas prácticos actuales
   de Picpas v.0.7.2:
   
   - No optimiza el uso de la memoria cuando se usan variables locales, de
   manera que no librera la memoria ocupada por las variables locales que cada
   vez ocupan más espacio, dandose el caso de varibles con los mismos nombres
   en distintas funciones que en lugar de unificarse en una sola posición de
   memoria ocupas dos.
   
   - A consecuencia de los anterior, cuando el programa empieza a tener cierto
   tamaño usando distintas librerías, se llega a llenar le Banco 0 de memoria
   RAM, y Picpas v.0.7.2 da problemas en el uso de variables en otroa bancos.
   Como en otras circunsatancias similares, caso de ser necesario, siempres
   se puede recurrir al código ensamblador para asegura su correcto funcionamiento,
   pero en ese caso, de momento, se hace inviable su uso como librerías.
   
   La solución adoptada en esta nueva "librería" de funciones mantemática, es
   crearlas aquí, probarlas, optimizarlas, y copiar y pegar, según necesidad,
   en el código funente de los programas.
   
   Y para evistar el problema de falta de optimización de las variables locales
   se crean variables globales (Math_W_Op1, Marh_W_Op2...) que utilizarán todas las
   funciones, lo que suelo ser normal en programas escritos en ensamblador, ya 
   que para usar la versión actual de Picpas en casos prácticos, es necesario
   seguir tratando todo el programas "pensando en ensamblador". Es como programar
   en ensamblador teniendo una emorme colección de macros.  
   
   El indicador final del nombre de las funciones indican el tipo de dato
   que manejan:
   
   _bbb: Operador1 : byte, Operador2 : byte , Resultado : byte
   _wbw: Operador1 : word, Operador2 : byte , Resultado : word
   _www: Operador1 : word, Operador2 : word , Resultado : word

   Este método tiene muchas liminataciones por lo que resulta imposible generalizar
   en librerías. Es más una prueba de concepto para consultar o incorporar a
   otros programas. 
*
}

{$FREQUENCY 8Mhz}
{$PROCESSOR PIC16F877A}
{$MODE PICPAS}

program Math_Optimizado_TEST_PIC16F877a;

uses PIC16F877A, LCDLib_4bits_PIC16F877A_No_Math_Include;
                 
var
  // ------------------------------------------------------------------
  // Operadores globales usados por las funcines, para evitar el exceso
  // de uso de memoria de Picpas al usar variables locales.
  // Esto es lo normal si se programa en ensamblador, y esta colección
  // de fuinciones está ideada como si se estubiera programando en
  // ensamblador.
  Math_W_Op1, Math_W_Op2, Math_W_Op3 : word;  // Op1 y Op2 para datos de entrada
  Math_B_Op1, Math_B_Op2, Math_B_Op3 : byte;  // En Op3 se suelo enviar el resultado.
                                              // Aunque en determiados casos el resultado
                                              // se deja en Op1.
                                              // Op1 y Op2 se pueden modificar durante
                                              // la ejecución de procedimientos de cálculo.
                                              
  Math_W_St1, Math_W_St2 : word;              // Variables en las que salvaguardar,
  Math_B_St1, Math_B_St2 : byte;              // en caso necesario, el contenido de los 
                                              // Op1 y Op2
  // ------------------------------------------------------------------

// Salvaguarda Operadores.
procedure Math_PUSH;
begin
  Math_W_St1 := Math_W_Op1;
  Math_W_St2 := Math_W_Op2;
  Math_B_St1 := Math_B_Op1;
  Math_B_St2 := Math_B_Op2;   
end;

// Restaura Operadores.
procedure Math_POP;
begin
  Math_W_Op1 := Math_W_St1;
  Math_W_Op2 := Math_W_St2;
  Math_B_Op1 := Math_B_St1;
  Math_B_Op2 := Math_B_St2;   
end; 

//***********************************************************************
// W O R D S _ C O M P A R A R ******************************************
//***********************************************************************
//  FUNCION: Math_Comparar
//  PicPas v.0.7.2 no compara variables tipo word.
//  Esta funcion lo soluciona.
//  Devuelve:
//        0 si sin iguales.
//        1 si el dato1 es mayor que el dato2.
//        2 si el dato2 es mayor que el dato1.
//        Menor que 2 si el dato1 es mayor o igual que el dato 2.
//***********************************************************************
procedure Math_Comparar_wwb : byte;
begin
  if (Math_W_Op1.high > Math_W_Op2.high) then exit(1) end;  // dato1>dato2
  if (Math_W_Op1.high < Math_W_Op2.high) then exit(2) end;  // dato1<dato2
  if (Math_W_Op1.low > Math_W_Op2.low) then exit(1) end;    // dato1>dato2
  if (Math_W_Op1.low < Math_W_Op2.low) then exit(2) end;    // dato1<dato2
  exit(0);                                                  // dato1=dato2 
end;
procedure Math_Comparar_wbb : byte;
begin
  if (Math_W_Op1.high > 0)  then exit(1) end;               // dato1>dato2
  if (Math_W_Op1.low > Math_B_Op2) then exit(1) end;        // dato1>dato2
  if (Math_W_Op1.low < Math_B_Op2) then exit(2) end;        // dato1<dato2
  exit(0);                                                  // dato1=dato2 
end;

//***********************************************************************
// W O R D S _ R E S T A R **********************************************
//***********************************************************************
//  FUNCION: Words_Restar
//  PicPas v.0.7.2 no resta variables tipo word.
//  Esta funcion en ensamblador lo soluciona de la manera más efectiva.
//***********************************************************************
procedure Math_Restar_wbw : word;
// minuendo   = Math_W_Op1
// sustraendo = Math_B_Op2
// resultado  = Math_W_Op1
begin
  ASM 
          movf    Math_B_Op2,w
          subwf   Math_W_Op1.low,f
          btfss   STATUS_C
          decf    Math_W_Op1.high,f
  END
  exit(Math_W_Op1);
end;
procedure Math_Restar_www : word;
// minuendo   = Math_W_Op1
// sustraendo = Math_W_Op2
// resultado  = Math_W_Op1
begin
  ASM
  ;
  ;Resta de dos numeros de 16 bits
  ;
  ;         minuendo.high:minuendo.low - Numero al que se resta (minuendo)
  ;         sustraendo - Numero que se resta (sustraendo)
  ;Salida:  minuendo.high:minuendo.low - Resultado
  ;
  
          movf    Math_W_Op2.low,w
          subwf   Math_W_Op1.low,f
          movf    Math_W_Op2.high,w
          btfss   STATUS_C
          incfsz  Math_W_Op2.high,w
          subwf   Math_W_Op1.high,f    ; minuendo = minuendo - sustraendo
                                       ; El flag CARRY que queda seria valido,
                                       ; pero el Z no.
  ;
  END
  exit(Math_W_Op1);
end;

//***********************************************************************
// D I V I D I R ********************************************************
//***********************************************************************
//  FUNCION: Dividir
//  PicPas v.0.7.2 no divide variables numericas.
//  Divide dos datos numericos de tipo byte y word.
//  Devuelve el resultado en variable tipo word de 16 bits.
//***********************************************************************
procedure Math_Dividir_bbb : byte;
// dividendo = Math_B_Op1
// divisor   = Math_B_Op2
// cociente  = Math_B_Op3
begin
  Math_B_Op3 := 0;
  // comprueba division por cero
  if(Math_B_Op2 = 0) then
    exit($FF); // devuelve el numero mas alto posible (seria infinito)
  end;
  while(Math_B_Op1 >= Math_B_Op2) do
    Math_B_Op1 := Math_B_Op1 - Math_B_Op2;
    inc(Math_B_Op3);
  end;
  exit(Math_B_Op3);
end;
procedure Math_Dividir_wbw : word;
// dividendo = Math_W_Op1
// divisor   = Math_B_Op2
// cociente  = Math_W_Op3
begin
  Math_W_Op3 := 0;
  // comprueba division por cero
  if(Math_B_Op2 = 0) then
    exit($FFFF); // devuelve el numero mas alto posible (seria infinito)
  end;
  while(Math_Comparar_wbb < 2) do  // mientras dividendo >= divisor
    Math_Restar_wbw;
    inc(Math_W_Op3);
  end;
  exit(Math_W_Op3);  
end;
procedure Math_Dividir_www : word;
// dividendo = Math_W_Op1
// divisor   = Math_W_Op2
// cociente  = Math_W_Op3
begin
  if(Math_W_Op2.high=0) then
    // Evita error de división por cero
    if(Math_W_Op2.low=0) then exit($FFFF) end; // Máximo resultado posible.
    // Acelerar resultado en caso particulares.
    if(Math_W_Op2.low=1) then exit(Math_W_Op1) end; // Division por 1.
    if(Math_W_Op2.low=2) then                       // Division por 2.
      Math_W_Op3.low:=Math_W_Op1.low>>1;
      Math_W_Op3.low.7:=Math_W_Op1.high.0;
      Math_W_Op3.high:=Math_W_Op1.high>>1;
      exit(Math_W_Op3);
    end;
  end;
  Math_W_Op3 := 0;
  while(Math_Comparar_wwb < 2) do  // mientras dividendo >= divisor
    Math_Restar_www;
    inc(Math_W_Op3);
  end;
  exit(Math_W_Op3);
end;

//***********************************************************************
// R E S T O _ D I V I D I R ********************************************
//***********************************************************************
//  FUNCION: Resto_Dividir
//  PicPas v.0.7.2 no calcula el resto de un division entre variables.
//  Devuelve el resto de la operacion de dividor dos variables numericas.
//  Devuelve el resultado en variable tipo word de 16 bits.
//***********************************************************************
procedure Math_Resto_bbb : byte;
// dividendo = Math_B_Op1
// divisor   = Math_B_Op2
begin
  // comprueba division por cero
  if Math_B_Op2 = 0 then
    exit(0); // devuelve Cero.
  end;
  while(Math_B_Op1 >= Math_B_Op2) do
    Math_B_Op1 := Math_B_Op1 - Math_B_Op2;
  end;
  exit(Math_B_Op1);   
end;
procedure Math_Resto_wbw : word;
// dividendo = Math_W_Op1
// divisor   = Math_B_Op2
begin
  // comprueba division por cero
  if(Math_B_Op2 = 0) then
    exit(word(0)); // devuelve Cero.
  end;
  while(Math_Comparar_wbb < 2) do  // mientras dividendo >= divisor
    Math_W_Op1 := Math_Restar_wbw;
  end;
  exit(Math_W_Op1);
end;
procedure Math_Resto_www : word;
// dividendo = Math_W_Op1
// divisor   = Math_W_Op2
begin
  // comprueba division por cero
  if((Math_W_Op2.low = 0) AND (Math_W_Op2.high = 0)) then
    exit(word(0)); // devuelve Cero.
  end;
  while(Math_Comparar_wwb < 2) do  // mientras dividendo >= divisor
    Math_W_Op1 := Math_Restar_www;
  end;
  exit(Math_W_Op1);
end;

//***********************************************************************
// M U L T I P L I C A R ************************************************
//***********************************************************************
//  FUNCION: Multiplicar
//  PicPas v.0.7.2 no multiplica variables numericas.
//  Multiplica dos valores.
//  Devuelve el resultado en variable tipo word de 16 bits.
//***********************************************************************
procedure Math_Multiplicar_bbw : word;
// multiplicando  = Math_B_Op1
// multiplicador  = Math_B_Op2
// multiplicacion = Math_W_Op3
begin
  Math_W_Op3 := 0;
  if Math_B_Op2 > 0 then
    repeat 
	    Math_W_Op3 := Math_W_Op3 + Math_B_Op1;
      dec(Math_B_Op2);
    until (Math_B_Op2 = 0);
  end; 
  exit(Math_W_Op3);
end;
procedure Math_Multiplicar_wbw : word;
// multiplicando  = Math_W_Op1
// multiplicador  = Math_B_Op2
// multiplicacion = Math_W_Op3
begin
  Math_W_Op3 := 0;
  if Math_B_Op2 > 0 then
    repeat 
      ASM
        MOVF    Math_W_Op1.low,w
        ADDWF   Math_W_Op3.low,f
        BTFSC   STATUS_C
        INCF    Math_W_Op3.high,f
        MOVF    Math_W_Op1.high,w
        ADDWF   Math_W_Op3.high,f             
      END
      dec(Math_B_Op2);
    until(Math_B_Op2 = 0);
  end; 
  exit(Math_W_Op3);
end;

procedure LCD_Print_COMPARACION;
begin
  LCD_WriteChar('C');
  LCD_WriteChar('O');
  LCD_WriteChar('M');
  LCD_WriteChar('P');
  LCD_WriteChar('A');
  LCD_WriteChar('R');
  LCD_WriteChar('A');
  LCD_WriteChar('C');
  LCD_WriteChar('I');
  LCD_WriteChar('O');
  LCD_WriteChar('N');
end;
procedure LCD_Print_RESTAR;
begin
  LCD_WriteChar('R');
  LCD_WriteChar('E');
  LCD_WriteChar('S');
  LCD_WriteChar('T');
  LCD_WriteChar('A');
  LCD_WriteChar('R');
end;
procedure LCD_Print_DIVIDIR;
begin
  LCD_WriteChar('D');
  LCD_WriteChar('I');
  LCD_WriteChar('V');
  LCD_WriteChar('I');
  LCD_WriteChar('D');
  LCD_WriteChar('I');
  LCD_WriteChar('R');
end;
procedure LCD_Print_RESTO;
begin
  LCD_WriteChar('R');
  LCD_WriteChar('E');
  LCD_WriteChar('S');
  LCD_WriteChar('T');
  LCD_WriteChar('O');
end;
procedure LCD_Print_MULTIPLICAR;
begin
  LCD_WriteChar('M');
  LCD_WriteChar('U');
  LCD_WriteChar('L');
  LCD_WriteChar('T');
  LCD_WriteChar('I');
  LCD_WriteChar('P');
  LCD_WriteChar('I');
  LCD_WriteChar('C');
  LCD_WriteChar('A');
  LCD_WriteChar('R');
end;
procedure LCD_Print_BBB;
begin
  LCD_WriteChar('B');
  LCD_WriteChar('B');
  LCD_WriteChar('B'); 
end;
procedure LCD_Print_WWB;
begin
  LCD_WriteChar('W');
  LCD_WriteChar('W');
  LCD_WriteChar('B'); 
end;
procedure LCD_Print_WBB;
begin
  LCD_WriteChar('W');
  LCD_WriteChar('B');
  LCD_WriteChar('B'); 
end;
procedure LCD_Print_WWW;
begin
  LCD_WriteChar('W');
  LCD_WriteChar('W');
  LCD_WriteChar('W'); 
end;
procedure LCD_Print_WBW;
begin
  LCD_WriteChar('W');
  LCD_WriteChar('B');
  LCD_WriteChar('W'); 
end;
procedure LCD_Print_BBW;
begin
  LCD_WriteChar('B');
  LCD_WriteChar('B');
  LCD_WriteChar('W'); 
end;
procedure LCD_Print_Resultado_Comparacion;
begin
  if(Math_B_Op3=0) then LCD_WriteChar('=');
  elsif (Math_B_Op3=1) then LCD_WriteChar('>');
  elsif (Math_B_Op3=2) then LCD_WriteChar('<');
  end;
end;


// He sacado la función LCD_Print_Number de la librería LCDLib_4bits_PIC16F72
// para usarla utilizando las nuevas funciones matemáticas y no duplicar las funciones
// ocupando toda la memorial del PIC16F72
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
procedure LCD_Print_Number(numero : word; decimales: byte; digitos: byte; caracter_derecha: char);
var
  digito              : word;      // Variable auxiliar que contien el digito a imprimir (decena millar, millar, centena, decena y unidad)
  div_dec             : word;      // Variable auxiliar por la que dividir para obtener cada uno de los digitos.
  contador            : byte;      // Contador de bucle.
  parte_decimal       : boolean;   // flag que indica que se estan escribiendo la parte decimal del numero.
  fin_ceros_izquierda : boolean;   // flag que indica que se han acabado los ceros a la izquierda del numero.
begin
  Math_PUSH;
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
    Math_W_Op1 := div_dec;
    Math_B_Op2 := 10;
    div_dec := Math_Multiplicar_wbw;    
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
    Math_W_Op1 := numero;
    Math_W_Op2 := div_dec;
    digito := Math_Dividir_www;  // Obtiene el valor de digito del número a imprimir.
    
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

    Math_W_Op1 := numero;
    Math_W_Op2 := div_dec;
    numero := Math_Resto_www;  // Realiza calculo de resto de división, eliminando el valor de dígito ya impreso.
    Math_W_Op1 := div_dec;
    Math_B_Op2 := 10;
    div_dec := Math_Dividir_wbw;     // Calcula el nuevo divisor para extraer el siguiente dígito del número.
  end;
  Math_POP;   
end;
//-----------------------------------------------------------------------------

procedure esperar;
begin
  delay_ms(30000);
  LCD_Clear;
end;

// P R O G R A M A   P R I N C I P A L
begin
  LCD_Init(20,4);
  
  LCD_Print_COMPARACION;
  LCD_DisplayCursorRight;
  LCD_Print_WWB;
  
  LCD_GotoXY(0,1); 
  Math_W_Op1 := 54321;
  Math_W_Op2 := 15256;
  Math_B_Op3 := Math_Comparar_wwb; 
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_Print_Resultado_Comparacion; 
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));

  LCD_GotoXY(0,2); 
  Math_W_Op1 := 10562;
  Math_W_Op2 := 61588;
  Math_B_Op3 := Math_Comparar_wwb;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_Print_Resultado_Comparacion; 
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));  

  LCD_GotoXY(0,3); 
  Math_W_Op1 := 3299;
  Math_W_Op2 := 3299;
  Math_B_Op3 := Math_Comparar_wwb;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_Print_Resultado_Comparacion; 
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));  
 
  esperar;
      
  LCD_Print_COMPARACION;
  LCD_DisplayCursorRight;
  LCD_Print_WBB;
  
  LCD_GotoXY(0,1); 
  Math_W_Op1 := 56921;
  Math_B_Op2 := 152;
  Math_B_Op3 := Math_Comparar_wbb;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_Print_Resultado_Comparacion;
  Math_W_Op2 := Math_B_Op2;   
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));

  LCD_GotoXY(0,2); 
  Math_W_Op1 := 100;
  Math_B_Op2 := 88;
  Math_B_Op3 := Math_Comparar_wbb;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_Print_Resultado_Comparacion;
  Math_W_Op2 := Math_B_Op2;   
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));  

  LCD_GotoXY(0,3); 
  Math_W_Op1 := 219;
  Math_B_Op2 := 219;
  Math_B_Op3 := Math_Comparar_wbb;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_Print_Resultado_Comparacion;
  Math_W_Op2.high := 0;
  Math_W_Op2.low  := Math_B_Op2;   
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));  
  
  esperar;
      
  LCD_Print_RESTAR;
  LCD_DisplayCursorRight;
  LCD_Print_WBW;
  
  LCD_GotoXY(0,1); 
  Math_W_Op1 := 10000;
  Math_B_Op2 := 1;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('-');
  Math_W_Op2 := Math_B_Op2;   
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Restar_wbw;   
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  LCD_GotoXY(0,2); 
  Math_W_Op1 := 99;
  Math_B_Op2 := 99;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('-');
  Math_W_Op2 := Math_B_Op2;   
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Restar_wbw;   
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  LCD_GotoXY(0,3); 
  Math_W_Op1 := 65535;
  Math_B_Op2 := 255;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('-');
  Math_W_Op2 := Math_B_Op2;   
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Restar_wbw;   
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));

  esperar;

  LCD_Print_RESTAR;
  LCD_DisplayCursorRight;
  LCD_Print_WWW;
  
  LCD_GotoXY(0,1); 
  Math_W_Op1 := 10000;
  Math_W_Op2 := 9999;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('-'); 
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Restar_www; 
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  LCD_GotoXY(0,2); 
  Math_W_Op1 := 169;
  Math_W_Op2 := 70;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('-'); 
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Restar_www; 
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  LCD_GotoXY(0,3); 
  Math_W_Op1 := 65535;
  Math_W_Op2 := 535;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('-'); 
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Restar_www; 
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));

  esperar;

  LCD_Print_DIVIDIR;
  LCD_DisplayCursorRight;
  LCD_Print_BBB;
  
  LCD_GotoXY(0,1); 
  Math_B_Op1 := 100;
  Math_B_Op2 := 10;
  Math_W_Op1 := Math_B_Op1;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('/');
  Math_W_Op2 := Math_B_Op2;
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_B_Op3 := Math_Dividir_bbb;
  Math_W_Op3 := Math_B_Op3; 
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  LCD_GotoXY(0,2); 
  Math_B_Op1 := 250;
  Math_B_Op2 := 25;
  Math_W_Op1 := Math_B_Op1;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('/');
  Math_W_Op2 := Math_B_Op2;
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_B_Op3 := Math_Dividir_bbb;
  Math_W_Op3 := Math_B_Op3; 
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  LCD_GotoXY(0,3); 
  Math_B_Op1 := 200;
  Math_B_Op2 := 201;
  Math_W_Op1 := Math_B_Op1;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('/');
  Math_W_Op2 := Math_B_Op2;
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_B_Op3 := Math_Dividir_bbb;
  Math_W_Op3 := Math_B_Op3; 
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));

  esperar;

  LCD_Print_DIVIDIR;
  LCD_DisplayCursorRight;
  LCD_Print_WBW;
  
  LCD_GotoXY(0,1); 
  Math_W_Op1 := 1199;
  Math_B_Op2 := 101;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('/');
  Math_W_Op2 := Math_B_Op2;
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Dividir_wbw;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));

  LCD_GotoXY(0,2); 
  Math_W_Op1 := 65535;
  Math_B_Op2 := 255;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('/');
  Math_W_Op2 := Math_B_Op2;
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Dividir_wbw;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));

  LCD_GotoXY(0,3); 
  Math_W_Op1 := 99;
  Math_B_Op2 := 100;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('/');
  Math_W_Op2 := Math_B_Op2;
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Dividir_wbw;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  esperar;

  LCD_Print_DIVIDIR;
  LCD_DisplayCursorRight;
  LCD_Print_WWW;
  
  LCD_GotoXY(0,1); 
  Math_W_Op1 := 56582;
  Math_W_Op2 := 2655;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('/');
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Dividir_www;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
 
  LCD_GotoXY(0,2); 
  Math_W_Op1 := 15;
  Math_W_Op2 := 2000;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('/');
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Dividir_www;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  LCD_GotoXY(0,3); 
  Math_W_Op1 := 65000;
  Math_W_Op2 := 2;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('/');
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Dividir_www;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  esperar;

  LCD_Print_RESTO;
  LCD_DisplayCursorRight;
  LCD_Print_BBB;
  
  LCD_GotoXY(0,1); 
  Math_B_Op1 := 251;
  Math_B_Op2 := 25;
  Math_W_Op1 := Math_B_Op1;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('/');
  Math_W_Op2 := Math_B_Op2;  
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_B_Op3 := Math_Resto_bbb;
  Math_W_Op3 := Math_B_Op3;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  LCD_GotoXY(0,2); 
  Math_B_Op1 := 249;
  Math_B_Op2 := 25;
  Math_W_Op1 := Math_B_Op1;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('/');
  Math_W_Op2 := Math_B_Op2;  
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_B_Op3 := Math_Resto_bbb;
  Math_W_Op3 := Math_B_Op3;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  LCD_GotoXY(0,3); 
  Math_B_Op1 := 160;
  Math_B_Op2 := 8;
  Math_W_Op1 := Math_B_Op1;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('/');
  Math_W_Op2 := Math_B_Op2;  
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_B_Op3 := Math_Resto_bbb;
  Math_W_Op3 := Math_B_Op3;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0)); 
  
  esperar;

  LCD_Print_RESTO;
  LCD_DisplayCursorRight;
  LCD_Print_WBW;
  
  LCD_GotoXY(0,1); 
  Math_W_Op1 := 251;
  Math_B_Op2 := 250;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('%');
  Math_W_Op2 := Math_B_Op2;  
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Resto_wbw;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  LCD_GotoXY(0,2); 
  Math_W_Op1 := 2409;
  Math_B_Op2 := 50;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('%');
  Math_W_Op2 := Math_B_Op2;  
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Resto_wbw;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  LCD_GotoXY(0,3); 
  Math_W_Op1 := 16000;
  Math_B_Op2 := 8;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('%');
  Math_W_Op2 := Math_B_Op2;  
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Resto_wbw;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0)); 
  
  esperar;

  LCD_Print_RESTO;
  LCD_DisplayCursorRight;
  LCD_Print_WWW;
  
  LCD_GotoXY(0,1); 
  Math_W_Op1 := 25001;
  Math_W_Op2 := 250;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('%');  
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Resto_www;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  LCD_GotoXY(0,2); 
  Math_W_Op1 := 6882;
  Math_W_Op2 := 10000;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('%');  
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Resto_www;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  LCD_GotoXY(0,3); 
  Math_W_Op1 := 9999;
  Math_W_Op2 := 9999;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('%');  
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Resto_www;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  esperar;

  LCD_Print_MULTIPLICAR;
  LCD_DisplayCursorRight;
  LCD_Print_BBW;
  
  LCD_GotoXY(0,1); 
  Math_B_Op1 := 251;
  Math_B_Op2 := 250;
  Math_W_Op1 := Math_B_Op1;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('x');
  Math_W_Op2 := Math_B_Op2;  
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Multiplicar_bbw;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  LCD_GotoXY(0,2); 
  Math_B_Op1 := 100;
  Math_B_Op2 := 20;
  Math_W_Op1 := Math_B_Op1;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('x');
  Math_W_Op2 := Math_B_Op2;  
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Multiplicar_bbw;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  LCD_GotoXY(0,3); 
  Math_B_Op1 := 55;
  Math_B_Op2 := 0;
  Math_W_Op1 := Math_B_Op1;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('x');
  Math_W_Op2 := Math_B_Op2;  
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Multiplicar_bbw;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  esperar;

  LCD_Print_MULTIPLICAR;
  LCD_DisplayCursorRight;
  LCD_Print_WBW;
  
  LCD_GotoXY(0,1); 
  Math_W_Op1 := 5985;
  Math_B_Op2 := 10;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('x');
  Math_W_Op2 := Math_B_Op2;  
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Multiplicar_wbw;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  LCD_GotoXY(0,2); 
  Math_W_Op1 := 55;
  Math_B_Op2 := 200;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('x');
  Math_W_Op2 := Math_B_Op2;  
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Multiplicar_wbw;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));
  
  LCD_GotoXY(0,3); 
  Math_W_Op1 := 257;
  Math_B_Op2 := 255;
  LCD_Print_Number(Math_W_Op1,0,5,' ');
  LCD_WriteChar('x');
  Math_W_Op2 := Math_B_Op2;  
  LCD_Print_Number(Math_W_Op2,0,5,chr(0));
  LCD_WriteChar('=');
  Math_W_Op3 := Math_Multiplicar_wbw;
  LCD_Print_Number(Math_W_Op3,0,5,chr(0));

end.
