// NUEVA INFORMACION PARA VER Y COPIAR METODO LECTURA Y ESCRITURA
// http://embeddedlaboratory.blogspot.com.es/2017/05/saving-and-reading-data-from-internal.html

{
*  (C) AguHDz 05-JUN-2017
*  Ultima Actualizacion: 09-JUN-2017
*
*  Compilador PicPas v.0.6.8 (https://github.com/t-edson/PicPas)
*
*  ESCRITURA DE DATOS EN EEMPROM INTERNA DEL MICROCONTROLADOR
*  Aunque el codigo tal y como esta compila y funciona perfectamente
*  ambos procedimientos, el escrito en ensamblador y el escrito en Pascal,
*  pero se ponen en evidencia ciertos errores a corrregir en futuras versiones
*  de Picpas.
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

procedure espera_10us;
begin
  contador = 1;
  repeat
    dec(contador);
  until contador = 0;
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
  espera_10us;   //x10us delay
  SDA := 0;
  espera_10us;   //x10us delay
  SCL := 0;
end;

Procedure Stop_I2C;
begin
  SCL := 0;
  SDA := 0;
  SCL := 1;
  espera_10us;   //x10us delay
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
        espera_10us;   //x10us delay 
        SCL  := 0;
      end;
   end;
   SCL := 0;
   SDA := 1; //input...
   espera_10us;   //x10us delay 
   ACK := SDA;
   SCL := 0;
end;
 
begin
  Start_I2C;
  espera_10us;
  WriteI2C($AA);
  espera_10us;
  Stop_I2C;
end.

