////////////////////////////////////////////////////////////////////////////////////
//                     VsZeNeR"04
//                     7/Agosto/05
//            Adaptado a compilador SDCC por AguHDz Oct 2017
//            Prueba Otros Compiladores VS PicPas.
//
//   Programa:  Coche Fantastico
//   Version:   0.0
//
//   Dispositivo: PIC 16F648A         Compilador:   SDCC 3.6.0
//   Entorno IDE: Code::Blocks        Simulador:    Proteus 6.8
//
//   Notas: Barrido de led"s simulando la iluminacion del coche fantastico por el
//          puerto A
//
//            RA0 -> 1º Led
//            RA1 -> 2º Led
//            RA2 -> 3º Led
//            RA3 -> 4º Led
//  Fuente: http://www.todopic.com.ar/foros/index.php?topic=4530.msg38857#msg38857
//////////////////////////////////////////////////////////////////////////////////

#include <pic14/pic16f84a.h>

///DECLARACIONES DE FUNCIONES
void derecha(void);               //ilumina led"s derecha a izquierda
void izquierda(void);             //ilumina led"s izquierda a derecha
void delay_ms(int);

///PROGRAMA
void main(void)
{
   TRISA = 0xF0;                 //porta como salida menos RA4(desactivado)
   GIE   = 0;                    //todas las interrupciones desactivadas

   while(1) {                    //bucle...
      derecha();
      izquierda();
   };                            //...infinito
}

// Uncalibrated delay, ~1ms/loop @ 4MHz
void delay_ms(int ms)
{
   unsigned char aux;

   while(ms--)
   {
       aux=50;      // Uncalibrated delay
       while(aux--);
   };
}

void derecha(void)
{
   RA0 = 1;
   delay_ms(300);  // ~300ms @ 4MHz
   RA0 = 0;
   RA1 = 1;
   delay_ms(300);
   RA1 = 0;
   RA2 = 1;
   delay_ms(300);
   RA2 = 0;
   RA3 = 1;
   delay_ms(300);
}

void izquierda(void)
{
   RA3 = 0;
   RA2 = 1;
   delay_ms(300);
   RA2 = 0;
   RA1 = 1;
   delay_ms(300);
   RA1 = 0;
}
