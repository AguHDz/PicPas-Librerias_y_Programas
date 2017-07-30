{
*
*  (C) AguHDz 21-JUL-2017
*  Ultima Actualizacion: 26-JUL-2017
*  Prueba para compilador PicPas v.0.7.2
* 
*  Demo de libreria para imprimir valores numéricos en display LCD
*  ===============================================================
*  Simula la impresión de valores en distintos formatos numéricos.
*
*  LCD_Print_Number(numero : word; decimales: byte; caracter_derecha: char);
*    - numero    : Variables numérica de tipo word a imprimir en display.
*    - decimales : Numero de decimales del valor numerico. (división por 10)
*    - caracter_derecha : Caracter ASCII para rellenar espacio de ceros a la izquierda del número.
*                         Puede ser cualquier caracter, pero lo normal sería un 0 (cero) para simular
*                         una especie de contador o un espacio para justificar la posición del valor
*                         a imprimir. Si vale 0 (chr(0)) no imprime nada (justificación a la izquierda)
*
*    Ejemplos:
*    
*    LCD_Print_Number(word(12354), 3, chr(0));  -->  12,354
*    LCD_Print_Number(word(354), 0, chr(0));    -->  354
*    LCD_Print_Number(word(354), 7, chr(0));    -->  0,0000354     
*    LCD_Print_Number(word(0), 0, '0');         -->  00000
*    LCD_Print_Number(word(55), 2, chr(0));     -->  0,55
*    
*    
*    LCD_Print_Number(v, 2, chr(0));   Si v=100 -->  1,00
*    LCD_Print_Number(v, 2, chr(0));   Si v=360 -->  3,60
*    LCD_Print_Number(v, 2, chr(0));  Si v=1254 -->  12,54
*    LCD_Print_Number(v, 2, chr(0)); Si v=15254 -->  152,54
*
*    LCD_Print_Number(v, 2, ' ');      Si v=100 -->    1,00
*    LCD_Print_Number(v, 2, ' ');      Si v=360 -->    3,60
*    LCD_Print_Number(v, 2, ' ');     Si v=1254 -->   12,54
*    LCD_Print_Number(v, 2, ' ');    Si v=15254 -->  152,54
*
*    LCD_Print_Number(v, 2, '0');      Si v=100 -->  001,00
*    LCD_Print_Number(v, 2, '0');      Si v=360 -->  003,60
*    LCD_Print_Number(v, 2, '0');     Si v=1254 -->  012,54
*    LCD_Print_Number(v, 2, '0');    Si v=15254 -->  152,54
*
}

{$FREQUENCY 8Mhz}

program LCD20x4_4B_Lib_DEMO_numeros;

uses PIC16F72, LCDLib_4bits, Math_Word_Type ;  // Con libreria Math (funciones distintos tipos de datos) no funciona.

var
  v : word;

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
      if(parte_decimal OR fin_ceros_izquierda OR (contador = 0)) then  // Si el dígito de valor cero está en la parte decimal o no es un cero a la izquierda, lo imprime.
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
  LCD_Print_Number(word(226),0,chr(0));
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
  LCD_Print_Number(word(1045),2,chr(0));
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
  LCD_Print_Number(word(96),2,chr(0));
end;

procedure LCD_Print_P_ACTIVA;
begin

  LCD_Print_Number(word(8566),0,'0');
  LCD_WriteChar('K');
  LCD_WriteChar('V');
  LCD_WriteChar('A');
end;

procedure LCD_Print_P_REACTIVA;
begin
  LCD_Print_Number(word(650),0,'0');
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
  LCD_Print_Number(word(12354), 3, chr(0)); //  -->  12,354
  LCD_GotoXY(1,0); 
  LCD_Print_Number(word(354), 0, chr(0));   //  -->  354
  LCD_GotoXY(2,0); 
  LCD_Print_Number(word(354), 7, chr(0));   //  -->  0,0000354 
  LCD_GotoXY(3,0);     
  LCD_Print_Number(word(0), 0, '0');        //  -->  00000
  LCD_GotoXY(3,16); 
  LCD_Print_Number(word(55), 2, chr(0));    //  -->  0,55
 
  delay_ms(3000); 
  
  LCD_Clear;  
  v:=100; 
  LCD_Print_Number(v, 2, chr(0)); //   Si v=100 -->  1,00 
  LCD_GotoXY(1,0);
  v:=360;
  LCD_Print_Number(v, 2, chr(0)); //   Si v=360 -->  3,60
  LCD_GotoXY(2,0);
  v:=1254;
  LCD_Print_Number(v, 2, chr(0)); //  Si v=1254 -->  12,54 
  LCD_GotoXY(3,0); 
  v:=15254;
  LCD_Print_Number(v, 2, chr(0)); // Si v=15254 -->  152,54
 
  delay_ms(3000); 

  LCD_Clear;  
  v:=100;
  LCD_Print_Number(v, 2, ' ');    //   Si v=100 -->    1,00 
  LCD_GotoXY(1,0); 
  v:=360;
  LCD_Print_Number(v, 2, ' ');    //   Si v=360 -->    3,60
  LCD_GotoXY(2,0);
  v:=1254;
  LCD_Print_Number(v, 2, ' ');    //  Si v=1254 -->   12,54
  LCD_GotoXY(3,0);  
  v:=15254;
  LCD_Print_Number(v, 2, ' ');    // Si v=15254 -->  152,54
 
  delay_ms(3000); 
  
  LCD_Clear;
  v:=100;
  LCD_Print_Number(v, 2, '0');    //   Si v=100 -->  001,00
  LCD_GotoXY(1,0);
  v:=360;
  LCD_Print_Number(v, 2, '0');    //   Si v=360 -->  003,60
  LCD_GotoXY(2,0);
  v:=1254;
  LCD_Print_Number(v, 2, '0');    //  Si v=1254 -->  012,54
  LCD_GotoXY(3,0); 
  v:=15254;
  LCD_Print_Number(v, 2, '0');    // Si v=15254 -->  152,54
end. 
