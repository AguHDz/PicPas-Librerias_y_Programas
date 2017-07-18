{
*  (C) AguHDz 18-JUL-2017
*  Ultima Actualizacion: 18-JUL-2017
*
*  Compilador PicPas v.0.7.2 (https://github.com/t-edson/PicPas)
*
*  LIBRERIA DE FUNCIONES MATEMATICAS NO IMPLEMENTADAS
*  ==================================================
*  Para poder avanzar en el uso y prueba de PicPas se hace necesario
*  contar con ciertas operaciones mantematicas basicas como la multiplicacion
*  y la division, o funciones para comparar u operar con variables tipo word.
*
*  En principio, todos los resultador numericos de esta libreria seran del
*  tipo word (16 bits) o booleanos en caso de resultados binarios.
*  
*  A medida que estas funciones se vayan implementado con funciones u
*  operacionesde sistema en PicPas, se iran eliminando de esta libreria, en la
*  quedaran solo las funciones de uso particular en ciertos programas que
*  nunca se implementaran como funciones de sistema.
*  
*  NOTA: En un principio, los algoritmos de las funciones implementadas
*  en esta libreria para funciones muy básicas, no están optimizados para
*  ser muy veloces, simplemente para realizar su funcion y ocupara poca memoria,
*  ya que en su momento se eliminara de aqui y quedaran integradas como 
*  operaciones del sistema en PicPas, donde se se trataria de optimizar la
*  velocidad o la ocupacion de memoria dependiendo de los casos.
*
}
unit Math;

interface

var
  STATUS_C : bit  absolute $0003.0;   // Deberia ser un dato heredado del programa
                                      // que haga uso de la libreria. En PicPas v.0.7.2
                                      // todavia no esta implementado.
                                      // De cualquier modo la posicion STATUS en el SFR
                                      // de los distintos PIC suelo ser la $0003
                                      // Si no se define, toma la direccion en el SFR
                                      // del microcontroaldor por defecto (PIC16F84A)

//***********************************************************************
//  FUNCION: Words_Comparar
//  PicPas v.0.7.2 no compara variables tipo word.
//  Esta funcion lo soluciona.
//  Devuelve:
//        0 si sin iguales.
//        1 si el dato1 es mayor que el dato2.
//        2 si el dato2 es mayor que el dato1.
//***********************************************************************
procedure Words_Comparar(dato1,dato2: word) : byte;

//***********************************************************************
//  FUNCION: Words_Restar
//  PicPas v.0.7.2 no resta variables tipo word.
//  Esta funcion en ensamblador lo soluciona de la manera más efectiva.
//***********************************************************************
procedure Words_Restar(minuendo: byte; register sustraendo: byte) : word;
procedure Words_Restar(minuendo: word; register sustraendo: byte) : word;
procedure Words_Restar(minuendo,sustraendo: word) : word;

//***********************************************************************
//  FUNCION: Dividir
//  Divide dos datos numericos de tipo byte y word.
//  Devuelve el resultado en variable tipo word de 16 bits.
//***********************************************************************
procedure Dividir (dividendo, divisor : byte) : word;
procedure Dividir (dividendo, divisor : word) : word;
procedure Dividir (dividendo : word; divisor : byte) : word;

//***********************************************************************
//  FUNCION: Resto_Dividir
//  Devuelve el resto de la operacion de dividor dos variables numericas.
//  Devuelve el resultado en variable tipo word de 16 bits.
//***********************************************************************
procedure Resto_Dividir (dividendo, divisor : byte) : word;
procedure Resto_Dividir (dividendo, divisor : word) : word;
procedure Resto_Dividir (dividendo : word; divisor : byte) : word;

//***********************************************************************
//  FUNCION: Multiplicar
//  Multiplica dos valores.
//  Devuelve el resultado en variable tipo word de 16 bits.
//***********************************************************************
procedure Multiplicar (multiplicando, multiplicador : byte) : word;
procedure Multiplicar (multiplicando : word; multiplicador : byte) : word;


implementation


//***********************************************************************
procedure Words_Comparar(dato1,dato2: word) : byte;
begin
  if (dato1.high = dato2.high) then
    if (dato1.low = dato2.low) then exit(0) end;  // dato1=dato2
    if (dato1.low > dato2.low) then exit(1) end;  // dato1>dato2
  end;
  if (dato1.high > dato2.high) then exit(1) end;  // dato1>dato2
  exit(2);                                        // dato1<dato2 
end;
//***********************************************************************
procedure Words_Restar(minuendo: byte; register sustraendo: byte) : word;
begin
  ASM
    subwf   minuendo,w
    clrf    _H
  END
end;

procedure Words_Restar(minuendo: word; register sustraendo: byte) : word;
begin
  ASM
    subwf   minuendo.low,f
    btfss   STATUS_C
    decf    minuendo.high,f
  END
  exit(minuendo);
end;

procedure Words_Restar(minuendo,sustraendo: word) : word;
begin
  ASM
  ;
  ;Resta de dos numeros de 16 bits
  ;
  ;         minuendo.high:minuendo.low - Numero al que se resta (minuendo)
  ;         sustraendo - Numero que se resta (sustraendo)
  ;Salida:  minuendo.high:minuendo.low - Resultado
  ;
  
          movf    sustraendo.low,w
          subwf   minuendo.low,f
          movf    sustraendo.high,w
          btfss   STATUS_C
          incfsz  sustraendo.high,w
          subwf   minuendo.high,f    ; minuendo = minuendo - sustraendo
                                       ; El flag CARRY que queda seria valido,
                                       ; pero el Z no.
  ;
  END
  exit(minuendo);
end;
//***********************************************************************
procedure Dividir (dividendo, divisor : byte) : word;
var
  cociente : word;
begin
  cociente := 0;
  // comprueba division por cero
  if divisor = 0 then
    exit($FFFF); // devuelve el numero mas alto posible (seria infinito)
  end;
//  repeat
//    if dividendo < divisor then
//      exit(cociente);
//    end;
//    dividendo := dividendo - divisor;
//    inc(cociente);
//  until false;
  while(dividendo >= divisor) do
    dividendo := dividendo - divisor;
    inc(cociente);
  end;
  exit(cociente);
end;

procedure Dividir (dividendo, divisor : word) : word;
var
  cociente, auxiliar : word;
begin
  cociente := 0;
  // comprueba division por cero
  if((divisor.low OR divisor.high) = $00) then
    exit($FFFF); // devuelve el numero mas alto posible (seria infinito)
  end;
  repeat
    if(Words_Comparar(divisor,dividendo) = 1) then  // Si dividor > dividendo.
      exit(cociente);
    end;
    dividendo := Words_Restar(dividendo,divisor);
    inc(cociente);
  until false;
end;

procedure Dividir (dividendo : word; divisor : byte) : word;
var
  cociente, d_word : word;
begin
  // comprueba division por cero
  if(divisor = 0) then
    exit($FFFF); // devuelve el numero mas alto posible (seria infinito)
  end;
  d_word.high := 0;  // Variable auxiliar para poder usar la variables divisor como tipo word.
  d_word.low  := divisor;
  cociente    := 0;
  repeat
    if(Words_Comparar(d_word,dividendo) = 1) then  // Si dividor > dividendo.
      exit(cociente);
    end;
    dividendo := Words_Restar(dividendo, d_word);
    inc(cociente);
  until false;
end;
//***********************************************************************
procedure Resto_Dividir (dividendo, divisor : byte) : word;
var
  resto : word;
begin
  resto := 0;
  // comprueba division por cero
  if divisor = 0 then
    exit(resto); // devuelve Cero.
  end;
  repeat
    if dividendo < divisor then
      resto.high := 0;
      resto.low  := dividendo;
      exit(resto);
    end;
    dividendo := dividendo - divisor;
  until false;
end;

procedure Resto_Dividir (dividendo, divisor : word) : word;
var
  auxiliar : word;
begin
  // comprueba division por cero
  if((divisor.low = 0) AND (divisor.high = 0)) then
    exit(word(0)); // devuelve Cero.
  end;
  repeat
    if(Words_Comparar(divisor,dividendo) = 1) then  // Si dividor > dividendo.
      exit(dividendo);
    end;
    dividendo := Words_Restar(dividendo, divisor);
  until false;
end;

procedure Resto_Dividir (dividendo : word; divisor : byte) : word;
var
  auxiliar, d_word : word;
begin
  // comprueba division por cero
  if(divisor = 0) then
    exit(word(0)); // devuelve Cero.
  end;
  d_word.high := 0;  // Variable auxiliar para poder usar la variables divisor como tipo word.
  d_word.low  := divisor;
  repeat
    if(Words_Comparar(d_word,dividendo) = 1) then  // Si dividor > dividendo.
      exit(dividendo);
    end;
    dividendo := Words_Restar(dividendo, d_word);
  until false;
end;
//***********************************************************************
procedure Multiplicar (multiplicando, multiplicador : byte) : word;
var
  multiplicacion : word;
begin
  multiplicacion := 0;
  if multiplicador <> 0 then
    repeat 
	    multiplicacion := multiplicacion + multiplicando;
      dec(multiplicador);
    until (multiplicador = 0);
  end; 
  exit(multiplicacion);
end;

procedure Multiplicar (multiplicando : word; multiplicador : byte) : word;
var
  multiplicacion, auxiliar : word;
begin
  multiplicacion := 0;
  if multiplicador <> 0 then
    repeat 
      auxiliar := multiplicacion;
	    multiplicacion := auxiliar + multiplicando;
      dec(multiplicador);
    until(multiplicador = 0);
  end; 
  exit(multiplicacion);
end;
//***********************************************************************
end.
