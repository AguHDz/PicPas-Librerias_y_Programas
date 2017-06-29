{Prueba Puertos de Entrada y Salida.}
{$PROCESSOR PIC16F84}
{$FREQUENCY 8Mhz}
program LedBlink;

var 
PORTB: BYTE absolute $06;
TRISB: BYTE absolute $86;
PinSalida: boolean absolute PORTB.0;
PinPausa: boolean absolute PORTB.1;
PinEntrada: boolean absolute PORTB.7;

begin
	 TRISB  := %10000000;
	 PinPausa:= false;
   PinSalida := false;

	 while true do
   begin
		 PinSalida := true;
     delay_ms(500);
     PinSalida := false;
     delay_ms(500);
		 while PinEntrada do
	   begin
		   PinPausa := true;
       delay_ms(500);
       PinPausa := false;
       delay_ms(500);
		 end;
   end;
end.
