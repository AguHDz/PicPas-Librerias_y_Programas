{
*  (C) AguHDz 22-05-2017
*  Ultima Actualizacion: 22-05-2017
*
*  Prueba para compilador PicPas v.0.6.4
*  Prueba de concepto para generar retrasos de microsegundos en PIC 16F84A.
*
*  Este tipo de retrasos de menos de 1 milisegundo son necesarios cuando se 
*  trabajo por ejemplo con protocolos de comunicacion serie muy rapidos con
*  el I2C o SPI. 
*  
*  PicPas en su version 0.6.4 todavia no admite reservar espacios de memoria
*  para variables usadas en partes de programa escritas en ensamblador,
*  tampoco admite etiquetas, por lo que se complica codificar ciclos de espera.
*  Y aunque es posible codificarlos utilizando posiciones de memoria altas y 
*  usando para los saltos direcciones numericas muy faciles de encontrar en
*  el codigo ensamblador de la ventana de la izquierda, he llegado a la conclusion
*  de que para pequeños retardos de us es preferible utilizar instrucciones NOP
*  y contar con los 4 ciclos que supone la llamada y retorno a un procedimiento.
*
*  Así, para una frecuencia de reloj de 8 MHz, basta con intercalar este codigo:
*  ASM
*    NOP
*    NOP
*  END
*  para detener 1 us la ejecucion del programa:
*  
*  Para otras frecuencias de reloj : 1 ciclo = 1 / Frecuencia * 4
*  Si Frecuencia = 8 MHz, 1 ciclo = 1 / 8e6 * 4 = 0.5 us
*
*  Si el compilador permitiera acceder a la variable interna de velocidad de
*  reloj y en la definicion de constantes del programa se permitiera realizar
*  operaciones matematicas mas complejas, todas estas operaciones se podrían
*  automatizar o creando algun tipo de libreria.
}

{$MODE PASCAL}  // ACTIVA MODO COMPATIBILIDAD CON LENGUAJE PASCAL SIN MEJORAS.
{$FREQUENCY 8 MHZ }  // FRECUENCIA DE RELOJ DE MICROCONTROLADOR.
{$PROCESSOR PIC16F84A} // SELECCIONA MICROCONTROLADOR.

program Delay_us_sample;

var
  PORTB : BYTE absolute $06;
  TRISB : BYTE absolute $86;
  pin: bit absolute PORTB.4;

//*********************************************************************
//  Delay 10 microsecond.
//  Clock frequency = 8 MHz
//  Delay = 2e-06 seconds = 4 cycles
//  Error = 0 %
//  call delay_2us -> 2 cycles
//  return         -> 2 cycles
//                   ---
//  TOTAL          -> 4 cycles = 2 us
//*********************************************************************
procedure delay_2us;
begin
  // call & return = 2 us si Clock es 8 MHz
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

//***********************************************************************
// PROGRAMA PRINCIPAL ***************************************************
//***********************************************************************
begin                          
  TRISB := 0;   //all outputs
  while true do begin
    delay_10us;
    delay_10us;
    delay_10us;
    delay_10us;
    delay_10us;
    delay_10us;
    delay_10us;
    delay_10us;
    delay_10us;
    delay_10us; // 10us x 10 = 100us
    pin := not pin;
  end;
end.
