// NUEVA INFORMACION PARA VER SOBRE METODO LECTURA Y ESCRITURA
// http://embeddedlaboratory.blogspot.com.es/2017/05/saving-and-reading-data-from-internal.html

{
*  (C) AguHDz 05-JUN-2017
*  Ultima Actualizacion: 28-JUL-2017
*
*  Compilador PicPas v.0.7.2 (https://github.com/t-edson/PicPas)
*
*  COMUNICACION I2C SOFTWARE
*  =========================
*  Sin probar. En fase de pruebas y codificacion.
*

   velocidades estandas del bus I2C:
      - Normal : 100 kbps
      - Rapido : 400 kbps

   Modos del bus I2C:
      - Reposo: SCL = 1 / SDA = 1
      - Inicio de Transmisión (START): SCL = 1 / SDA = 1->0
      - Fin de Transmisión (STOP): SCL = 1 / SDA = 0->1 
      - Dato válido: SDA = 1 / SCL = 0->1->0
      
   Secuencia de comunicación:

     Bus en Reposo - START - bits de datos (determinado por dispositivo marter bus) - Dato Válido/No Válido (ACK/NoACK) (responde esclavo) - STOP - Bus en Reposo.
        ______________     ___     ___     ___     ___     ___     ___     ___     ___     ___                                              ____________       
  SCL:          sTART |___| 1 |___| 2 |___| 3 |___| 4 |___| 5 |___| 6 |___| 7 |___| 8 |___| 9 |__..........................................|  STOP
        ___________                                                                        ___                                                __________ 
  SDA:             |_____<bit7>__<bit6>___<bit5>__<bit4>__<bit3>__<bit2>__<bit1>__<bit0>__|ACK|__... SIGUIETES BITS Y ACKs .............. ___|

*
*
}

{$FREQUENCY 8 MHZ }
{$PROCESSOR PIC16F84A}
program I2C_Software;

uses
  PIC16F84A;  
  
const
  I2C_MASTER = true;
  I2C_SLAVE  = false;

var
  SDA      : bit absolute PORTA.0;
  SCL      : bit absolute PORTA.1;
  LED      : bit absolute PORTB.0;

//*********************************************************************
//  Delay 10 microsecond.
//  Clock frequency = 8 MHz
//  Delay = 1e-05 seconds = 20 cycles
//  Error = 0 %
//  call delay_10us ->  2 cycles
//  8 x goto $+1    -> 16 cycles
//  return          ->  2 cycles
//                   ----
//  TOTAL           -> 20 cycles = 10 us
//*********************************************************************
procedure delay_I2C;
begin
ASM
  goto $+1  ; 2 cycle (si clock = 8 MHz entonces 2 cycle = 2/8e6*4 = 1 us)
  goto $+1
  goto $+1
;  goto $+1
;  goto $+1
;  goto $+1
;  goto $+1
;  goto $+1
END
end;

Procedure I2C_Init(master_slave : boolean);
begin
  if(master_slave) then
    SetAsOutput(SCL);  // MASTER BUS
    SetAsOutput(SDA);
    SCL := 1;
    SDA := 1;
  else
    SetAsInput(SDA);   // SLAVE
    SetAsInput(SCL);
  end;
end;


//            ____
// SCL:  ____|    |
procedure I2C_Clock;
begin
  delay_I2C;
  SCL := 1;
  delay_I2C;
  SCL := 0;
end; 


// I2C  Reposo | Start
//       ______
// SDA:        |______
//       _______
// SCL:         |____
Procedure I2C_Start;
begin
  delay_I2C;   //x10us delay
  SDA := 0;
  delay_I2C;
  SCL := 0;
end;

// I2C  Stop | Reposo
//            _______
// SDA:  ____|   
//          _________
// SCL:  __|    
Procedure I2C_Stop;
begin
//  SCL := 0;
//  delay_10us;   //x10us delay
  SDA := 0;
  delay_I2C;   //x10us delay
  SCL := 1;
  delay_I2C;   //x10us delay
  SDA := 1
end;


//        _______  _______         ______               ________
// SDA:  / Bit7  \/ Bit6  \_.... _/ Bit0 \____ASK______|          (El ASK o NO_ASK lo envía el SLAVE)
//         ____      ____           ____      ____
// SCL:  _|    |____|    |__....___|    |____|    |_____________
Procedure I2C_Write_Byte(dato : byte) : bit;
var
  ACK      : bit;
  contador : byte;
begin
  for contador:=0 to 7 do 
    if((dato AND $80) = $80) then
      SDA := 1;
    else
      SDA := 0;
    end;
//    SDA := NOT dato.7; //Si se quiere usar así, hay que utilizar el NOT por fallo del compilador.
    I2C_Clock;
    dato := dato<<1;
  end;
  delay_I2C;   //x10us delay
  SCL := 1;
  SetAsInput(SDA);
  ACK := SDA;
  SetAsOutput(SDA);
  delay_I2C;
  SCL := 0;
  SDA := 1;
  exit(ACK);
end;

Procedure I2C_Write_Char(dato : char) : bit;
var
  ACK : bit;
begin
  ACK := I2C_Write_Byte(Ord(dato));
  exit(ACK);
end;

procedure I2C_Read_Byte : byte;
var
  contador : byte;
  dato     : byte;
begin
  SetAsInput(SDA);
  for contador:= 0 to 7 do
    SCL := 0;
    delay_I2C;
    SCL := 1;
    delay_I2C;
    dato.1 := SDA;
    dato := dato << 1;
    delay_I2C;
  end;
  SetAsOutput(SDA);
  exit(dato);
end; 

procedure I2C_Eeprom_Write(address,data : byte);
begin
  LED := 1;
  I2C_Start;
  LED := I2C_Write_Byte(%00000000);     // I2C Address.
  LED := I2C_Write_Byte(address); // byte address.
  LED := I2C_Write_Byte(data);    // data 
  I2C_Stop;
  // para escribir el siguiente dato sería necesario esperar 10 ms.
end;

procedure I2C_ACK;
begin
  SetAsOutput(SDA);
  SDA := 0;
  delay_I2C;
  delay_I2C;
  SetAsInput(SDA);
end;

procedure I2C_NoACK;
begin
  SetAsOutput(SDA);
  SDA := 1;
  delay_I2C;
  delay_I2C;
  SetAsInput(SDA);
end;
  

procedure I2C_Eeprom_Read(address : byte) : byte;
begin
  
end; 

begin
{  I2C_Start;
  delay_10us;
  I2C_Write($AA);
  delay_10us;
  I2C_Stop;
  
  // Solo para que compile funciona alternativa de espera y ver codigo resultante.
  delay_cycles(10);}
  //I2C_eeprom_write(%10101010,%11111111);
  
  SetAsOutput(LED);
  LED := 1;
    
  I2C_Init(I2C_MASTER);
//  LED := I2C_Write_Byte(%01010101);
//repeat
 I2C_Start;
 I2C_Write_Char('H');
 I2C_Write_Char('O');
 I2C_Write_Char('L');
 I2C_Write_Char('A');
 I2C_Write_Char(' ');
 I2C_Write_Char('M');
 I2C_Write_Char('U');
 I2C_Write_Char('N');
 I2C_Write_Char('D');
 I2C_Write_Char('O');
 I2C_Stop;
//until false;
//I2c_Read_Byte;
end.

