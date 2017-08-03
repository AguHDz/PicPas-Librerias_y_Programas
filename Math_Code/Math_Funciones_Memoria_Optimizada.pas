{
*  (C) AguHDz 03-AGO-2017
*  Ultima Actualizacion: 03-AGO-2017
*
*  Compilador PicPas v.0.7.2 (https://github.com/t-edson/PicPas)
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
program Math_Optimizado;

uses PIC16F84A;  // SOLO PARA PROBAR, ESTA "LIBRERIA" NO ESTA IDEADA PARA
                 // INCLUIR, SOLO PARA COPIAR Y PEGAR SUS FUNCIONES EN 
                 // LOS PROGRAMAS
                 
                 
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


// P R O G R A M A   P R I N C I P A L
begin

// Codigo fuente de programa principal

end.
