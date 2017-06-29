{Prueba Puertos de llamada a procedures.}
{PicPas - 0.5.7}
{$PROCESSOR PIC16F84}
{$FREQUENCY 8Mhz}
program LedBlink;

var 
PORTB: BYTE absolute $06;
TRISB: BYTE absolute $86;
LedRojo: boolean absolute PORTB.0;
LedAzul: boolean absolute PORTB.1;
Pulsador: boolean absolute PORTB.7;
aux: byte;  // Variable auxiliar para pasar parametros a procedures.
{en la version 0.5.7 todavia no funciona el envio de datos a procedures}

procedure prueba (variable : byte);
begin
  //if (variable = 1) then aux:=1; // Esto todavia no funciona en PicPas 0.5.7.
end;

procedure LedOn;
begin
  if (aux = 1) then LedRojo:=true
  else LedAzul:=true;
end;

procedure LedOff;
begin
  if (aux = 1) then LedRojo:=false
  else LedAzul:=false;
end;

procedure DetectaEntrada;
begin
  aux:=1;
  LedOff;
  inc(aux);
  while Pulsador do
  begin
    LedOff;
    delay_ms(200);
    LedOn;
    delay_ms(200);	 
  end;
end;

begin
  TRISB  := %10000000;
  LedRojo := false;
  LedAzul := false;

  while true do
  begin
    aux := 1;
    LedOff;
    inc(aux);
    LedON;
    delay_ms(500);
    DetectaEntrada;
    aux := 1;
    LedOn;
    inc(aux);
    LedOff;
    delay_ms(500);
    DetectaEntrada;
  end;
end.
