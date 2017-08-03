{
*  (C) AguHDz 18-JUL-2017
*  Ultima Actualizacion: 03-AGO-2017
*
*  Compilador PicPas v.0.7.2 (https://github.com/t-edson/PicPas)
*
*  LIBRERIA DE FUNCIONES MATEMATICAS NO IMPLEMENTADAS
*  (Solo las funciones que tratan con datos tipo word. Estraidas de la
*   librería más general Math.pas debido a que Picpas no siempre admite
*   sobrecarga de datos en los procedimientos importados desde librerías)
*  ==================================================
*  Para poder avanzar en el uso y prueba de PicPas se hace necesario
*  contar con ciertas operaciones mantematicas basicas como la multiplicacion
*  y la division, o funciones para comparar u operar con variables tipo word.
*
*  Actualmente, todos los resultador numericos de esta libreria seran del
*  tipo word (16 bits) o booleanos en caso de resultados binarios.
*  
*  A medida que estas funciones se vayan implementado con funciones u
*  operaciones de sistema en PicPas, se iran eliminando de esta libreria, en la
*  quedaran solo las funciones de uso particular en ciertos programas que
*  nunca se implementaran como funciones de sistema.
*  
*  NOTA: En un principio, los algoritmos de las funciones implementadas
*  en esta libreria para funciones básicas, no se han optimizado para
*  ser muy veloces, simplemente realizan su funcion y ocupan poca memoria,
*  ya que en su momento se eliminaran de aqui y quedaran integradas como 
*  operaciones del sistema en PicPas, donde se es posible que se trate
*  de optimizar la velocidad o la ocupacion de memoria dependiendo
*  de los casos.
*
}
unit Math_Word_Type;

interface

//***********************************************************************
//  FUNCION: Words_Comparar
//  PicPas v.0.7.2 no compara variables tipo word.
//  Esta funcion lo soluciona.
//  Devuelve:
//        0 si sin iguales.
//        1 si el dato1 es mayor que el dato2.
//        2 si el dato2 es mayor que el dato1.
//        Menor que 2 si el dato1 es mayor o igual que el dato 2.
//***********************************************************************
procedure Words_Comparar(dato1,dato2: word) : byte;

//***********************************************************************
//  FUNCION: Words_Restar
//  PicPas v.0.7.2 no resta variables tipo word.
//  Esta funcion en ensamblador lo soluciona de la manera más efectiva.
//***********************************************************************
procedure Words_Restar(minuendo,sustraendo: word) : word;

//***********************************************************************
//  FUNCION: Dividir
//  PicPas v.0.7.2 no divide variables numericas.
//  Divide dos datos numericos de tipo byte y word.
//  Devuelve el resultado en variable tipo word de 16 bits.
//***********************************************************************
procedure Dividir (dividendo, divisor : word) : word;

//***********************************************************************
//  FUNCION: Resto_Dividir
//  PicPas v.0.7.2 no calcula el resto de un division entre variables.
//  Devuelve el resto de la operacion de dividor dos variables numericas.
//  Devuelve el resultado en variable tipo word de 16 bits.
//***********************************************************************
//procedure Resto_Dividir (dividendo, divisor : byte) : word;
procedure Resto_Dividir (dividendo, divisor : word) : word;
//procedure Resto_Dividir (dividendo : word; divisor : byte) : word;

//***********************************************************************
//  FUNCION: Multiplicar
//  PicPas v.0.7.2 no multiplica variables numericas.
//  Multiplica dos valores.
//  Devuelve el resultado en variable tipo word de 16 bits.
//***********************************************************************
procedure Multiplicar (multiplicando : word; multiplicador : byte) : word;


implementation

//***********************************************************************
// W O R D S _ C O M P A R A R ******************************************
//***********************************************************************
procedure Words_Comparar(dato1,dato2: word) : byte;
begin
  if (dato1.high > dato2.high) then exit(1) end;  // dato1>dato2
  if (dato1.high < dato2.high) then exit(2) end;  // dato1<dato2
  if (dato1.low > dato2.low) then exit(1) end;    // dato1>dato2
  if (dato1.low < dato2.low) then exit(2) end;    // dato1<dato2
  exit(0);                                        // dato1=dato2 
end;

//***********************************************************************
// W O R D S _ R E S T A R **********************************************
//***********************************************************************
// Para evitar el uso de la variable absoluta STATUS (aunque algo mas lento)
procedure Words_Restar(minuendo,sustraendo: word) : word;
begin
  if(sustraendo.low > minuendo.low) then inc(sustraendo.high) end;
  minuendo.low := minuendo.low - sustraendo.low;
  minuendo.high := minuendo.high - sustraendo.high;
  exit(minuendo);
end;

//***********************************************************************
// D I V I D I R ********************************************************
//***********************************************************************
procedure Dividir (dividendo, divisor : word) : word;
var
  cociente, auxiliar : word;
begin
  if(divisor.high=0) then
    // Evita error de división por cero
    if(divisor.low=0) then exit($FFFF) end;      // Máximo resultado posible.
    // Acelerar resultado en caso particulares.
    if(divisor.low=1) then exit(dividendo) end;  // Division por 1.
    if(divisor.low=2) then                       // Division por 2.
      cociente.low:=dividendo.low>>1;
      cociente.low.7:=dividendo.high.0;
      cociente.high:=dividendo.high>>1;
      exit(cociente);
    end;
  end;
  cociente := 0;
  while(Words_Comparar(dividendo,divisor) < 2) do  // mientras dividendo >= divisor
    dividendo := Words_Restar(dividendo,divisor);
    inc(cociente);
  end;
  exit(cociente);
end;

//***********************************************************************
// R E S T O _ D I V I D I R ********************************************
//***********************************************************************
procedure Resto_Dividir (dividendo, divisor : word) : word;
var
  auxiliar : word;
begin
  // comprueba division por cero
  if((divisor.low = 0) AND (divisor.high = 0)) then
    exit(word(0)); // devuelve Cero.
  end;
  while(Words_Comparar(dividendo,divisor) < 2) do  // mientras dividendo >= divisor
    dividendo := Words_Restar(dividendo,divisor);
  end;
  exit(dividendo);
end;

//***********************************************************************
// M U L T I P L I C A R ************************************************
//***********************************************************************
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
