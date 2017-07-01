{ DELAY CYCLES TESTS}

{$FREQUENCY 8 MHZ }
{$PROCESSOR PIC16F84A}
program DELAY_CYCLES;

uses
  PIC16F84A;  
 
var
  contador : byte;

procedure delay_cycles(cycles : byte);
begin                   // 2 cycles (call procedure)
  repeat
    dec(cycles);       // 1 cycle
  until cycles = 0;    // 5 cycles (goto repeat or return)
  ASM
    NOP
  END
  
{    
Da lugar al siguiente código:
__delay_cycles:              --> 2 cycles. (call)
    $0001 decf cycles,f      --> 1 cycle.
    $0002 movlw 0x00         --> 1 cycle.
    $0003 subwf cycles,w     --> 1 cycle.
    $0004 btfss 0x003, 2     --> 1 or 2 cycles.
    $0005 goto 0x001         --> 2 cycles.
    $0006 nop                --> 1 cycle.
    $0007 return             --> 2 cycles.
end;

- Contador de Ciclos:
  2 de llamada a procedimiento (call).
  6 por cada ves que se repita el bucle repeat..until.
  6 en la ultima vuelta del bucle repeat..until.
  2 de retorno del procedimiento (return)
  
  TOTAL: 2 + 6*cycles + 2 = 
         4 + 12*cycles
         
- Contador de Ciclos (sin $0006 nop):
  2 de llamada a procedimiento (call).
  6 por cada ves que se repita el bucle repeat..until.
  5 en la ultima vuelta del bucle repeat..until.
  2 de retorno del procedimiento (return)
  
  TOTAL: 2 + 6*(cycles-1) + 5*cycles + 2 = 
         4 + 11*cycles - 6 =
         (11 * cycles) - 2
}

  while cycles > 0 do
    dec(cycles);
  end;
{
Da lugar al siguiente código:
__delay_cycles:
    $0001 movf cycles,w
    $0002 sublw 0x00
    $0003 btfsc 0x003, 0
    $0004 goto 0x007
    $0005 decf cycles,f
    $0006 goto 0x001
    $0007 return 
    
- Contador de Ciclos:
  2 de llamada a procedimiento (call).
  7 por cada ves que se repita el bucle repeat..until.
  5 en la ultima vuelta del bucle repeat..until.
  2 de retorno del procedimiento (return) 

TOTAL: 4 + 7*(cycles-1) + 5*cycles 
}
  
  for contador:=0 to cycles do
  end; 
  
  repeat
    if cycles = 0 then
      exit    
    else
      dec(cycles)
    end;
  until cycles = 0;

end;

//*********************************************************************
//  Delay 10 microsecond.
//  Clock frequency = 8 MHz
//  Delay = 1e-05 seconds = 20 cycles
//  Error = 0 %
//  call delay_10us ->  2 cycles
//  16 x nop        -> 16 cycles
//  return          ->  2 cycles
//                    ----
//  TOTAL           -> 20 cycles = 10 us
//*********************************************************************
procedure delay_10cycles;
begin
  ASM
    ;6 cycles
    goto	$+1
    goto	$+1
    goto	$+1
    
    ;4 cycles (including call)
  END
end;

begin
  // Solo para que compile funciona alternativa de espera y ver codigo resultante.
  delay_cycles(10);
  delay_10cycles;
end.

