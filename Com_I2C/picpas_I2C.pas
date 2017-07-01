// NUEVA INFORMACION PARA VER SOBRE METODO LECTURA Y ESCRITURA
// http://embeddedlaboratory.blogspot.com.es/2017/05/saving-and-reading-data-from-internal.html

{
*  (C) AguHDz 05-JUN-2017
*  Ultima Actualizacion: 09-JUN-2017
*
*  Compilador PicPas v.0.6.8 (https://github.com/t-edson/PicPas)
*
*  COMUNICACION I2C
*  ================
*  Sin probar. En fase de pruebas y codificacion.
*
}

{$FREQUENCY 8 MHZ }
{$PROCESSOR PIC16F84A}
program I2C;

uses
  PIC16F84A;  
 
var
  SDA      : bit absolute PORTA.0;
  SCL      : bit absolute PORTA.1;
  LED      : bit absolute PORTB.0;
  ACK      : bit;
  contador : byte;

procedure delay_cycles(cycles : byte);
begin                   // 2 cycles (call procedure)
  repeat
    dec(cycles);       // 1 cycle
  until cycles = 0;    // 5 cycles (goto repeat or return)
  
  while cycles > 0 do
    dec(cycles);
  end;
  
  for contador:=0 to cycles do
  end; 

{
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

ENTRADA  CYCLES
   1       9 
   2       
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
         
  VALOR    con NOP     sin NOP
             4               
}
end;

//*********************************************************************
//  Delay 10 microsecond.
//  Clock frequency = 8 MHz
//  Delay = 1e-05 seconds = 20 cycles
//  Error = 0 %
//  call delay_10us ->  2 cycles
//  16 x nop       -> 16 cycles
//  return         ->  2 cycles
//                   ----
//  TOTAL          -> 20 cycles = 10 us
//*********************************************************************
procedure delay_10us;
begin
ASM
  NOP  ; 1 cycle (si clock = 8 MHz entonces 1 cycle = 1/8e6*4 = 0.5 us)
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
  NOP
END
end;

Procedure Start_I2C;
begin
  SCL := 1;
  SDA := 1;
  delay_10us;   //x10us delay
  SDA := 0;
  delay_10us;   //x10us delay
  SCL := 0;
end;

Procedure Stop_I2C;
begin
  SCL := 0;
  SDA := 0;
  SCL := 1;
  delay_10us;   //x10us delay
  SDA := 1;
end;

Procedure WriteI2C(dato : byte);
begin
  for contador:=0 to 8 do 
    SCL := 0;
    if(dato AND $80)=0 then
      SDA := 0;
      else
        SDA  := 1;
        SCL  := 1;
        dato := dato<<1;
        delay_10us;   //x10us delay 
        SCL  := 0;
      end;
   end;
   SCL := 0;
   SDA := 1; //input...
   delay_10us;   //x10us delay 
   ACK := SDA;
   SCL := 0;
end;
 
begin
  Start_I2C;
  delay_10us;
  WriteI2C($AA);
  delay_10us;
  Stop_I2C;
  
  // Solo para que compile funciona alternativa de espera y ver codigo resultante.
  delay_cycles(10);
end.

