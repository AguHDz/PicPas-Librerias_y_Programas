// (C) AguHDz 14-05-2017
// Ultima Actualizacion: 14-05-2017
// Prueba para compilador PicPas v.0.6.1
// Display led 7 segmentos con microcontrolador PIC 16F84A.
// Cuenta de 10 segundos en Display y parpadea 3 veces indicando fin de cuenta.

{$MODE PASCAL}  // ACTIVA MODO COMPATIBILIDAD CON LENGUAJE PASCAL SIN MEJORAS.
{$PROCESSOR PIC16F84}
{$FREQUENCY 8Mhz}

program Simple7LedDisplay;
 
uses PIC16F84A;

var
  Counter : byte;

procedure SendToDisplayLed(dato : byte);
begin
{
  // CASE todavia no funciona en PicPas 0.6.1
  case numero of
  0 : PORTB := $3F;
  1 : PORTB := $06;
  2 : PORTB := $5B;
   ...
   else PORTB := $00;
  end;
}
  if dato = 0 then PORTB := $3F;
  if dato = 1 then PORTB := $06;
  if dato = 2 then PORTB := $5B;
  if dato = 3 then PORTB := $4F;
  if dato = 4 then PORTB := $66;
  if dato = 5 then PORTB := $6D;
  if dato = 6 then PORTB := $7D;
  if dato = 7 then PORTB := $07;
  if dato = 8 then PORTB := $7F;
  if dato = 9 then PORTB := $6F;
  if dato = ord('H') then PORTB := $76;
  if dato = ord('h') then PORTB := $74;
  if dato = ord('L') then PORTB := $38;
  if dato = ord('A') then PORTB := $77;  
  if dato = ord(' ') then PORTB := $00;  // Apaga Display o Espacio.
end;

begin

  TRISB := $00;        // Configura PORTB como output.

  while true do
  begin

		// Contador de 10 segundos.
		// Muestra en display numeros del 9 al 0.
    Counter := 10;
    repeat
    begin
      dec(Counter);
			SendToDisplayLed(Counter);
      delay_ms(1000);
    end;
    until Counter = 0;

    // El numero cero parpadea 3 veces, indicando fin de cuenta.
    Counter := 3;
    repeat
    begin
      dec(Counter);
			SendToDisplayLed(ord(' ')); // Apaga display.
      delay_ms(300);
			SendToDisplayLed(0);
      delay_ms(300);
    end;
    until Counter = 0;

		// Apaga el display 1 segundo antes de iniciar nuevamente la cuenta.
		SendToDisplayLed(ord(' '));
    delay_ms(1000);

  end;
end.
