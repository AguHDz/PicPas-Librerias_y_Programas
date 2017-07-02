{
*  (C) AguHDz 01-07-2017
*  Ultima Actualizacion: 02-07-2017
*
*  Compilador PicPas v.0.7.1 (https://github.com/t-edson/PicPas)
*
*  FUNCIONES DE ESPERA UN DETERMINADO NUMERO DE CICLOS MAQUINA
*  ===========================================================
*  Mediante bucles, instrucciones NOP y saltos GOTO $+1 se espera un determinado
*  numero de ciclos maquina (1 ciclo máquina = 4 ciclos de reloj) a que algun
*  proceso controlado por el microcontrolador finalice antes de seguir con la 
*  ejecucion del programa.
*
}

{$PROCESSOR PIC16F84A}
{$FREQUENCY 8 MHZ}
{$MODE PICPAS}

program DELAY_CYCLES;

uses
  PIC16F84A;  
 

// ----------------------------------------------------------------------------
// Procedure DELAY_4CYCLES
// Entrada cyclesx100 = 100 x ciclos maquina (4 ciclos reloj) de espera
// Total ciclos
//   Call -------------------------> 2
//   Return -----------------------> 2
// 
//  TOTAL Ciclos = 2 + 2 = 4
//  Ocupa 1 byte de Memoria de Programa.
// ----------------------------------------------------------------------------
procedure delay_4cycles;
begin
end;


// ----------------------------------------------------------------------------
// Procedure DELAY_X10CYCLES
// Entrada cyclesx10 = 10 x ciclos maquina (4 ciclos reloj) de espera
// Total ciclos
//   Call -------------------------> 2
//   Decrementa cyclesx10  --------> 3
//   Si cyclesx10 > 0 while -------> 2 + 3 + 2 = 7
//   Tras funcion while -----------> 1 + 2 = 3
//   Return -----------------------> 2
// 
//  TOTAL Ciclos = 2 + (3+2+3+2)*(cyclesx10-1) + (3+1+2) + 2
//  Ocupa 9 bytes de Memoria de Programa y 1 byte de RAM.
// ----------------------------------------------------------------------------
procedure delay_x10cycles(cyclesx10:byte);
begin
  while (dec(cyclesx10) > 0) do
    //----< 3 cycles >---------------------------
    ASM
      goto $+1
      nop
    END
    //-------------------------------------------
  end;
end;


// ----------------------------------------------------------------------------
// Procedure DELAY_X100CYCLES
// Entrada cyclesx100 = 100 x ciclos maquina (4 ciclos reloj) de espera
// Total ciclos
//   Call -------------------------> 2
//   Decrementa cyclesx100 --------> 3
//   Si cyclesx100 > 0 while ------> 2 + 95 = 97
//   Tras funcion while -----------> 1 + 2 + 90 = 93
//   Return -----------------------> 2
// 
//  TOTAL Ciclos = 2 + (3+2+95)*(cyclesx100-1) + (3+1+2+90) + 2
//  Ocupa 17 bytes de Memoria de Programa y 2 bytes de RAM.
// ----------------------------------------------------------------------------
procedure delay_x100cycles(cyclesx100:byte);
var
  d1 : byte;
begin
  while (dec(cyclesx100) > 0) do
    //----< 95 cycles >--------------------------
    ASM
               ;94 cycles
               movlw      $1F
               movwf	    d1
      Delay_0:
               decfsz	    d1, f
               goto	      Delay_0
               
               ;1 cycle
               nop
    END
    //-------------------------------------------
  end;
  //----< 90 cycles >----------------------------
  ASM
             ;88 cycles
             movlw      $1D
             movwf	    d1
    Delay_0:
             decfsz	    d1, f
             goto	      Delay_0
             
             ;2 cycles
             goto	$+1
  END
  //---------------------------------------------
end;


// ----------------------------------------------------------------------------
// Procedure DELAY_X1000CYCLES
// Entrada cyclesx100 = 1000 x ciclos maquina (4 ciclos reloj) de espera
// Total ciclos
//   Call -------------------------> 2
//   Decrementa cyclesx1000 -------> 3
//   Si cyclesx100 > 0 while ------> 2 + 995 = 997
//   Tras funcion while -----------> 1 + 2 + 990 = 993
//   Return -----------------------> 2
// 
//  TOTAL Ciclos = 2 + (3+2+995)*(cyclesx1000-1) + (3+1+2+990) + 2
//  Ocupa 25 bytes de Memoria de Programa y 3 bytes de RAM.
// ----------------------------------------------------------------------------
procedure delay_x1000cycles(cyclesx1000:byte);
var
  d1, d2 : byte;
begin
  while (dec(cyclesx1000) > 0) do
    //----< 995 cycles >--------------------------
    ASM
               ;993 cycles
               movlw      $C6
               movwf	    d1
               movlw      $01
               movwf	    d2
      Delay_0:
               decfsz	    d1, f
               goto	      $+2
               decfsz     d2, f
               goto	      Delay_0
               
               ;2 cycle
               goto       $+1
    END
    //-------------------------------------------
  end;  
  //----< 990 cycles >---------------------------
  ASM
             ;988 cycles
             movlw      $C5
             movwf	    d1
             movlw      $01
             movwf	    d2
    Delay_0:
             decfsz	    d1, f
             goto	      $+2
             decfsz     d2, f
             goto	      Delay_0
             
             ;2 cycle
             goto       $+1
  END
  //---------------------------------------------
end;


// Pendiente de revision ******************************************************
procedure delay_cycles(x : word);
begin
  repeat
    x := x - word(1);
  until ((x.low = 0) AND (x.high = 0));
end;
// ****************************************************************************


begin
  delay_4cycles;
  delay_x10cycles(100);
  delay_x100cycles(100);
  delay_x1000cycles(100);
  delay_cycles(1000);
end.

