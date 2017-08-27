////////////////////////////////////////////////////////////////////////////////////
//                     VsZeNeR"04  (Algoritmo optimizado)
//                     7/Agosto/05
//
//   Programa:   Coche Fantastico
//   Version:   0.0
//
//   Dispositivo: PIC 16F648A         Compilador:    CCS vs3.227
//   Entorno IDE: MPLAB IDE v7.20      Simulador:    Proteus 6.7sp3
//
//   Notas: Barrido de led"s simulando la iluminacion del coche fantastico por el
//         puerto A
//
//            RA0 -> 1º Led
//            RA1 -> 2º Led
//            RA2 -> 3º Led
//            RA3 -> 4º Led
//  Fuente: http://www.todopic.com.ar/foros/index.php?topic=4530.msg38857#msg38857
//////////////////////////////////////////////////////////////////////////////////

program Coche_Optimizado;
{$PROCESSOR PIC16F84}
{$FREQUENCY 4Mhz}

uses PIC16F84A;

begin
   TRISA      := $F0;          //porta como salida menos RA4(desactivado)
   INTCON_GIE := 0;            //todas las interrupciones desactivadas
   PORTA      := $01;

   while true do               //bucle...
     repeat                    //iluminacion hacia izquierda
        PORTA := PORTA<<1;
        delay_ms(300);
     until (PORTA.3=1);
     repeat                    //iluminacion hacia derecha
        PORTA := PORTA>>1;
        delay_ms(300);
     until (PORTA.0=1);     
   end;                        //...infinito
end.
