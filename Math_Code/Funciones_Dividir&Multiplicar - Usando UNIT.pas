{
*  (C) AguHDz 18-JUL-2017
*  Ultima Actualizacion: 18-JUL-2017
*
*  Compilador PicPas v.0.7.2 (https://github.com/t-edson/PicPas)
*
*  PRUEBA DE USO DE LIBRERIAS MATEMATICAS Y DE CONVERSION DECIMA AL BCD
*
}

{$FREQUENCY 8 MHZ }
{$PROCESSOR PIC16F877A}

program Multiplicar_Dividir;

uses PIC16F877A, Math, DecToBCD;

var
  resultado : word;


// FUNCIONES DE PRUEBA........
procedure Print_Resultado;
begin
  resultado := DecToBCD4(resultado);
  PORTC := resultado.low;
  PORTD := resultado.high;
  delay_ms(2000);
end; 

procedure Prueba_Tiempo_Divisiones(divisiones:word);
begin
  while((divisiones.high OR divisiones.low) > $00) do
    resultado := Dividir(43125,100);
    dec(divisiones);
  end;

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

  
  resultado := Dividir(215,10);         // 21   
  Print_Resultado;
  resultado := Dividir(3223,100);       // 32
  Print_Resultado;
  resultado := Dividir(43125,1000);     // 43
  Print_Resultado;
  resultado := Dividir(9999,1);         // 9999   
  Print_Resultado;

{ 
  PORTD := $01;
  Prueba_Tiempo_Divisiones(word(10));
  PORTD := $0f;
}


  resultado := Multiplicar(23,10) + 4;   // 234
  Print_Resultado;
  resultado := Multiplicar(234,10) + 5;  // 2345
  Print_Resultado;
  resultado := Multiplicar(345,10) + 6;  // 3456
  Print_Resultado;
  resultado := Multiplicar(1000,4) + Multiplicar(250,2) + Multiplicar(10,6) + 7;  // 4567
  Print_Resultado;


  
  
  resultado := Resto_Dividir(255,25);     // 5
  Print_Resultado;
  resultado := Resto_Dividir(60000,33);   // 6
  Print_Resultado;
  resultado := Resto_Dividir(10000,356);  // 32
  Print_Resultado;

//  PORTC := Compara_Numeros (2001,2000);

{  
  resultado := DecToBCD4(resultado);
  PORTC := resultado.low;
  PORTD := resultado.high;
}
end.

