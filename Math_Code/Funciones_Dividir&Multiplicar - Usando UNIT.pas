{
*  (C) AguHDz 18-JUL-2017
*  Ultima Actualizacion: 20-JUL-2017
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
  delay_ms(1000);
end; 

procedure Prueba_Tiempo_Divisiones(divisiones:word);
begin
  while((divisiones.high OR divisiones.low) > $00) do
    resultado := Dividir(43,10);
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

  
// OPERACION                                   RESULTADO
//==============================               =========
  resultado := Words_Restar(100,99);        //   1
  Print_Resultado;
  resultado := Words_Restar(261,250);       //   11
  Print_Resultado;                               
  resultado := Words_Restar_ASM(1111,1000); //   111
  Print_Resultado;                               
  resultado := Words_Restar(4555,3444);     //   1111
  Print_Resultado;                               
                                                 
  resultado := Words_Restar(100,98);        //   2
  Print_Resultado;                               
  resultado := Words_Restar_ASM(272,250);   //   22
  Print_Resultado;                               
  resultado := Words_Restar(1222,1000);     //   222
  Print_Resultado;                               
  resultado := Words_Restar_ASM(5666,3444); //   2222
  Print_Resultado;                               
                                                 
  resultado := Dividir(215,10);             //   21   
  Print_Resultado;                               
  resultado := Dividir(3223,100);           //   32
  Print_Resultado;                               
  resultado := Dividir(43125,1000);         //   43
  Print_Resultado;                               
  resultado := Dividir(20000,2);            //   EEEE  (ERROR: excede conversion BCD)
  Print_Resultado;                               
  resultado := Dividir(9999,1);             //   9999
  Print_Resultado;                               
  resultado := Dividir(1,0);                //   EEEE  (ERROR: division por cero)
  Print_Resultado;                               
                                                 
  resultado := Multiplicar(23,10) + 4;      //   234
  Print_Resultado;                               
  resultado := Multiplicar(234,10) + 5;     //   2345
  Print_Resultado;                               
  resultado := Multiplicar(345,10) + 6;     //   3456
  Print_Resultado;                               
                                                 
  resultado := Multiplicar(2181,3);         //   6543
  Print_Resultado;                               
  resultado := Multiplicar(56,97);          //   5432
  Print_Resultado;                               
  resultado := Multiplicar(108,4);          //   432
  Print_Resultado;                               
                                                 
  resultado := Resto_Dividir(255,25);       //   5
  Print_Resultado;                               
  resultado := Resto_Dividir(60000,33);     //   6
  Print_Resultado;                               
  resultado := Resto_Dividir(10000,356);    //   32
  Print_Resultado;

//  PORTC := Compara_Numeros (2001,2000);

{ 
  PORTD := $01;
  Prueba_Tiempo_Divisiones(word(10000));
  PORTD := $0f;
}

{  
  resultado := DecToBCD4(8888);
  PORTC := resultado.low;
  PORTD := resultado.high;
}
end.

