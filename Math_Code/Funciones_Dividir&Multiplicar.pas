{MULTIPLICACION Y DIVISION DE NUMEROS}

{$FREQUENCY 8 MHZ }
{$PROCESSOR PIC16F877A}

program Multiplicar_Dividir;

uses PIC16F877A;

var
  resultado : word;

  
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
begin
  if (dato1.high = dato2.high) then
    if (dato1.low = dato2.low) then exit(0) end;  // dato1=dato2
    if (dato1.low > dato2.low) then exit(1) end;  // dato1>dato2
  end;
  if (dato1.high > dato2.high) then exit(1) end;  // dato1>dato2
  exit(2);                                        // dato1<dato2 
end;


//***********************************************************************
//  FUNCION: Words_Restar
//  PicPas v.0.7.2 no resta variables tipo word.
//  Esta funcion rudimentaria pero efectiva lo soluciona.
//***********************************************************************
procedure Words_Restar(dato1,dato2: word) : word;
begin
  repeat
    if ((dato2.high OR dato2.low) = $00) then exit(dato1) end;
    dec(dato1);
    dec(dato2);
  until false;
// Si fuera necesario mejorar velocidad, codificar la funcion resta
// en ensamblador usando la instruccion subwf.
end;


//***********************************************************************
//  FUNCION: Dividir
//  Divide dos datos numericos de tipo byte y word.
//  Devuelve el resultado en variable tipo word de 16 bits.
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
  repeat
    if dividendo < divisor then
      exit(cociente);
    end;
    dividendo := dividendo - divisor;
    inc(cociente);
  until false;
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
//  FUNCION: Resto_Dividir
//  Devuelve el resto de la operacion de dividor dos variables numericas.
//  Devuelve el resultado en variable tipo word de 16 bits.
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
    if(dividendo.high <= divisor.high) then
      if(dividendo.low < divisor.low) then
        exit(dividendo);
      end;
    end;
    auxiliar  := dividendo;
    dividendo := auxiliar - divisor;
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
//  FUNCION: Multiplicar
//  Multiplica dos valores.
//  Devuelve el resultado en variable tipo word de 16 bits.
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
//  FUNCION: DecToBCD2
//  Devuelve el valor de entrada decimal en formato BCD de 2 digitos.
//***********************************************************************
procedure DecToBCD2(decimal : byte) : byte;
var
  bcd : byte;
begin
  if decimal>99 then
    bcd := $EE;  // Indica ERROR en valor decimal de entrada.
  else
    bcd := 0;
    while decimal > 9 do
      bcd     := bcd + 16;
      decimal := decimal - 10; 
    end;
    bcd := bcd + decimal;
  end;
  exit(bcd);
end;

//***********************************************************************
//  FUNCION: DecToBCD4
//  Devuelve el valor de entrada decimal en formato BCD de 4 digitos.
//***********************************************************************
procedure DecToBCD4(decimal : word) : word;
var
  bcd, aux_word : word;
  aux_byte : byte;
begin
  if (Words_Comparar(decimal,9999) = 1) then
    bcd := $EEEE;  // Indica ERROR en valor decimal de entrada.
  else
    aux_word := Dividir(decimal,100);
// NO FUNCIONA:    bcd.high := DecToBCD2(auxiliar.low);
    aux_byte := DecToBCD2(aux_word.low); 
    bcd.high := aux_byte;
    
    aux_word := Resto_Dividir(decimal,100);
// NO FUNCIONA:    bcd.low := DecToBCD2(auxiliar.low);    
    aux_byte := DecToBCD2(aux_word.low);
    bcd.low := aux_byte;
  end;
  exit(bcd);
end;


// FUNCIONES DE PRUEBA........
procedure Print_Resultado;
begin
  resultado := DecToBCD2(resultado.low);
  PORTC := resultado.low;
  delay_ms(2000);
end; 

procedure Prueba_Tiempo_Divisiones(divisiones:word);
begin
  repeat
    resultado := Dividir(43125,1000);
    dec(divisiones);
    if ((divisiones.high OR divisiones.low) = $00) then
      exit;
    end;
  until false;
end;
//............................


//***********************************************************************
// PROGRAMA PRINCIPAL ***************************************************
//***********************************************************************
begin
  ADCON1 := $07;           // Todos los pines configurados como digitales.
  ADCON0 := $00;           // Desactiva conversor A/D.
  SetAsOutput(PORTC);
  SetAsOutput(PORTD);
  PORTC:=0;
  PORTD:=0;
  
  resultado := Dividir(215,10);
  Print_Resultado;
  resultado := Dividir(3223,100);
  Print_Resultado;
  resultado := Dividir(43125,1000);
  Print_Resultado;
  resultado := Dividir(9999,1);
{ 
  PORTD := $01;
  Prueba_Tiempo_Divisiones(word(10));
  PORTD := $0f
}
  resultado := DecToBCD4(resultado);
  PORTC := resultado.low;
  PORTD := resultado.high;
  
// --------------- HASTA AQUI OK, SEGUIR ACABANDO RESTO DE FUNCIONES --------------------------- //
  
//  resultado := Resto_Dividir(100,9);
//  resultado := Resto_Dividir(10000,300);
//  resultado := Resto_Dividir(60000,7);
//  resultado := Multiplicar(100,10);
//  resultado := Multiplicar(40,2);

//  PORTC := Compara_Numeros (2001,2000);
end.

