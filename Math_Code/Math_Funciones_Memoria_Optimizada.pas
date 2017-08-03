{
*  (C) AguHDz 03-AGO-2017
*  Ultima Actualizacion: 03-AGO-2017
*
*  Compilador PicPas v.0.7.2 (https://github.com/t-edson/PicPas)
*
*  FUNCIONES MATEMATICAS NO IMPLEMENTADAS (OPTIMIZADA)
*  ===================================================
*  Para poder avanzar en el uso y prueba de PicPas se hace necesario
*  contar con ciertas operaciones mantem�ticas b�sicas como la multiplicaci�n
*  y la divisi�n, o funciones para comparar u operar con variables tipo word.
*
*  Ya se hicieron dos librer�as con funciones matem�ticas:
*
*  - Math.pas : Funciones gen�ricas que en teor�a deber�an funcionar para
                cualquier tipo de datos de entrada de los manejados por
                Picpas en su versi�n 0.7.2. Sin embargo, en la pr�ctica
                no parece est�r muy bien implementada la sobrecarga de 
                funciones en esta versi�n por lo que su inclusi�n da muchos
                problemas de errores de reconocimiento de tipos de datos.
                
   - Math_Type_Word: Se opta por usar el tipo de dato num�rico m�s grande 
                que maneja la versi�n 0.7.2 de Picpas (el tipo word) y solo
                se incluyen las funciones con este tipo de variables. Funciona
                perfectamente, pero a la hora de queres optinizar las funciones
                usando c�digo ensamblador, aunque funciona en caso particulares
                para cada microcontrolador, al no heredar las constantes definidas
                en el programa que incluye la librer�a, el registro STATUS del SFR
                debe incluirse en la librer�a y ser�a necesario particularizar
                para cada microcontrolador (aunque hasta donde se, este registro
                permanece en la misma posici�n de memoria para toda la familia
                PIC16.
                
   Se implementa esta nueva "librer�a", en realidad una colecci�n de funciones
   matem�ticas m�s optimizadas, pero debido a los problemas pr�cticos actuales
   de Picpas v.0.7.2:
   
   - No optimiza el uso de la memoria cuando se usan variables locales, de
   manera que no librera la memoria ocupada por las variables locales que cada
   vez ocupan m�s espacio, dandose el caso de varibles con los mismos nombres
   en distintas funciones que en lugar de unificarse en una sola posici�n de
   memoria ocupas dos.
   
   - A consecuencia de los anterior, cuando el programa empieza a tener cierto
   tama�o usando distintas librer�as, se llega a llenar le Banco 0 de memoria
   RAM, y Picpas v.0.7.2 da problemas en el uso de variables en otroa bancos.
   Como en otras circunsatancias similares, caso de ser necesario, siempres
   se puede recurrir al c�digo ensamblador para asegura su correcto funcionamiento,
   pero en ese caso, de momento, se hace inviable su uso como librer�as.
   
   La soluci�n adoptada en esta nueva "librer�a" de funciones mantem�tica, es
   crearlas aqu�, probarlas, optimizarlas, y copiar y pegar, seg�n necesidad,
   en el c�digo funente de los programas.
   
   Y para evistar el problema de falta de optimizaci�n de las variables locales
   se crean variables globales (Math_W_Op1, Marh_W_Op2...) que utilizar�n todas las
   funciones, lo que suelo ser normal en programas escritos en ensamblador, ya 
   que para usar la versi�n actual de Picpas en casos pr�cticos, es necesario
   seguir tratando todo el programas "pensando en ensamblador". Es como programar
   en ensamblador teniendo una emorme colecci�n de macros.  
   
   El indicador final del nombre de las funciones indican el tipo de dato
   que manejan:
   
   _bbb: Operador1 : byte, Operador2 : byte , Resultado : byte
   _wbw: Operador1 : word, Operador2 : byte , Resultado : word
   _www: Operador1 : word, Operador2 : word , Resultado : word

   Este m�todo tiene muchas liminataciones por lo que resulta imposible generalizar
   en librer�as. Es m�s una prueba de concepto para consultar o incorporar a
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
  // Esto es lo normal si se programa en ensamblador, y esta colecci�n
  // de fuinciones est� ideada como si se estubiera programando en
  // ensamblador.
  Math_W_Op1, Math_W_Op2, Math_W_Op3 : word;  // Op1 y Op2 para datos de entrada
  Math_B_Op1, Math_B_Op2, Math_B_Op3 : byte;  // En Op3 se suelo enviar el resultado.
                                              // Aunque en determiados casos el resultado
                                              // se deja en Op1.
                                              // Op1 y Op2 se pueden modificar durante
                                              // la ejecuci�n de procedimientos de c�lculo.
                                              
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
//  Esta funcion en ensamblador lo soluciona de la manera m�s efectiva.
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
    // Evita error de divisi�n por cero
    if(Math_W_Op2.low=0) then exit($FFFF) end; // M�ximo resultado posible.
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
