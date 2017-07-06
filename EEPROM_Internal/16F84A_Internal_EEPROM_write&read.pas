{
*  (C) AguHDz 15-JUN-2017
*  Ultima Actualizacion: 15-JUN-2017
*
*  Compilador PicPas v.0.6.9 (https://github.com/t-edson/PicPas)
*
*  ESCRITURA Y LECTURA DE DATOS EN MEMORIA EEPROM INTERNA DEL MICROCONTROLADOR PIC.
*  Ejemplo de uso de funciones en Picpas.
*  Tambien se usan nombres de variables y constantes definidas en nueva
*  UNIT 16F84A.pas. Ahora mas coherente en el uso de los nombre de bytes y 
*  bits de la zona SFR de memoria y sus registros.
}

{$FREQUENCY 8 MHZ }
//{$PROCESSOR PIC16F84A}  // Ya incluido en UNIT PIC16F84A.
program EEPROMInterna;

uses
  PIC16F84A;  
 
var
  Led_Error : bit absolute PORTB.0;
  Led_Ok    : bit absolute PORTB.1;
  contador  : byte;

//***********************************************************************
//  PROCEDIMIENTO: WriteIEEPROM
//  Graba un byte en la memoria EEPROM interna de microcontrolador PIC.
//***********************************************************************
procedure WriteIEEPROM(direccion , valor: byte);
var
  flag_INT    : bit;             // Para guardar el estado del flag general de habilitacion de interrupciones.
begin
  EEADR       := direccion;
  EEDATA      := valor;
  flag_INT    := INTCON_GIE;     // Guarda el flag general de habilizacion de interruptiones.
  INTCON_GIE  := 0;              // Deshabilita interrupciones.
  EECON1_WREN := 1;
  EECON2      := $55;
  EECON2      := $AA;
  EECON1_WR   := 1;
  EECON1_WREN := 0;
  repeat until (EECON1_WR = 0); // Espera escritura de EEPROM.
  INTCON_GIE  := flag_INT;      // Restaura el valor previo del flag general de interrupciones.
end;

//***********************************************************************
//  FUNCION: ReadIEEPROM
//  Devuelve el byte leido en un determinada direccion de la  memoria
//  EEPROM interna de microcontrolador PIC.
//***********************************************************************
procedure ReadIEEPROM(direccion : byte): byte;
begin
  EEADR       := direccion;
  EECON1_RD   := 1;
  repeat until (EECON1_RD = 0); // Espera lectura de EEPROM.
  exit(EEDATA);
end;

begin
  SetAsOutput(Led_Error);
  SetAsOutput(Led_Ok);
//----< TEST LECTURA/ESCRITURA DE EEPROM INTERNA DEL PIC >
  for contador:=$00 to $10 do  
    WriteIEEPROM(contador,contador);
    if contador = ReadIEEPROM(contador) then
      // COINCIDENCIA DE VALORES ESCRITOS Y LEIDOS.
      Led_Error := 0;
      Led_Ok    := 1;
    else
      // NO COINCIDENCIA = ERROR DE LECTURA O ESCRITURA.
      Led_Error := 1;
      Led_Ok    := 0;
      exit;  // DETENER PROGRAMA.
    end; 
  end;
//-----< FIN DE TEST LECTURA/ESCRITURA DE EEPROM INTERNA DEL PIC >
end.
