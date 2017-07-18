{
*  (C) AguHDz 18-JUL-2017
*  Ultima Actualizacion: 18-JUL-2017
*
*  Compilador PicPas v.0.7.2 (https://github.com/t-edson/PicPas)
*
*  LIBRERIA DE FUNCIONES DE CONVERSION DE NUMEROS DECIMALES A BCD
*
*
}
unit DecToBCD;

interface

uses Math;

implementation

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

end.

