{ DELAY CYCLES TESTS}

{$FREQUENCY 8 MHZ }
{$PROCESSOR PIC16F84A}
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
// ----------------------------------------------------------------------------
procedure delay_x10cycles(cyclesx10:byte);
begin
  while (dec(cyclesx10) > 0) do
    // ---< 3 cycles
    ASM
      NOP
      NOP
      NOP
    END
    // end 3 cycles >---
  end;
end;


// ----------------------------------------------------------------------------
// Procedure DELAY_X100CYCLES
// Entrada cyclesx100 = 100 x ciclos maquina (4 ciclos reloj) de espera
// Total ciclos
//   Call -------------------------> 2
//   Decrementa cyclesx100 --------> 3
//   Si cyclesx100 > 0 while ------> 2 + 95 = 97
//   Tras funcion while -----------> 1 + 2 + 90 = 97
//   Return -----------------------> 2
// 
//  TOTAL Ciclos = 2 + (3+2+95)*(cyclesx100-1) + (3+1+2+90) + 2
// ----------------------------------------------------------------------------
procedure delay_x100cycles(cyclesx100:byte);
var
  d1 : byte;
begin
  while (dec(cyclesx100) > 0) do
    // ---< 95 cycles
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
    //  end 95 cycles >---
  end;
  
  // ---< 90 cycles
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
  //  end 90 cycles >---
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
  // Solo para que compile funciona alternativa de espera y ver codigo resultante.

  delay_4cycles;
  delay_x10cycles(10);
  delay_x100cycles(100);
  delay_cycles(1000);
end.
