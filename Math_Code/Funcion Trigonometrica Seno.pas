{FUNCION TRIGONOMETRICA SENO.}

{$FREQUENCY 8 MHZ }
{$PROCESSOR PIC16F84A}

program Funcion_Seno;

uses PIC16F84A;

var
  contador : byte;
//***********************************************************************
//  FUNCION: SIN90
//  Devuelve en formato BCD los dos primeros decimales de la operacion
//  trigonometrica seno para angulos entre 0 y 90 grados.
//***********************************************************************
procedure sin90 (register angulo : byte) : byte;
begin
  ASM
    ADDWF PCL,F
    RETLW	$00
    RETLW $02
    RETLW $03
    RETLW $05
    RETLW $07
    RETLW $09
    RETLW $10
    RETLW $12
    RETLW $14
    RETLW $16
    RETLW $17
    RETLW $19
    RETLW $21
    RETLW $22
    RETLW $24
    RETLW $26
    RETLW $28
    RETLW $29
    RETLW $31
    RETLW $33
    RETLW $34
    RETLW $36
    RETLW $37
    RETLW $39
    RETLW $41
    RETLW $42
    RETLW $44
    RETLW $45
    RETLW $47
    RETLW $48
    RETLW $50
    RETLW $52
    RETLW $53
    RETLW $54
    RETLW $56
    RETLW $57
    RETLW $59
    RETLW $60
    RETLW $62
    RETLW $63
    RETLW $64
    RETLW $66
    RETLW $67
    RETLW $68
    RETLW $69
    RETLW $71
    RETLW $72
    RETLW $73
    RETLW $74
    RETLW $75
    RETLW $77
    RETLW $78
    RETLW $79
    RETLW $80
    RETLW $81
    RETLW $82
    RETLW $83
    RETLW $84
    RETLW $85
    RETLW $86
    RETLW $87
    RETLW $87
    RETLW $88
    RETLW $89
    RETLW $90
    RETLW $91
    RETLW $91
    RETLW $92
    RETLW $93
    RETLW $93
    RETLW $94
    RETLW $95
    RETLW $95
    RETLW $96
    RETLW $96
    RETLW $97
    RETLW $97
    RETLW $97
    RETLW $98
    RETLW $98
    RETLW $98
    RETLW $99
    RETLW $99
    RETLW $99
    RETLW $99
    RETLW $A0
    RETLW $A0
    RETLW $A0
    RETLW $A0
    RETLW $A0
    RETLW $A0
  END
end;

//***********************************************************************
//  FUNCION: DecToBCD2
//  Devuelve el valor de entrada decimal en formato BCD de 2 digitos.
//***********************************************************************
procedure DecToBCD2(decimal : byte) : byte;
var
  bcd : byte;
begin
  if decimal>99 then
    exit($EE);  // ERROR en valor decimal de entrada.
  end;
  bcd := 0;
  while decimal > 9 do
    bcd     := bcd + 16;
    decimal := decimal - 10; 
  end;
  bcd := bcd + decimal;
  exit(bcd);
end;

//***********************************************************************
// PROGRAMA PRINCIPAL ***************************************************
//***********************************************************************
begin
  SetAsOutput(PORTB);
  for contador:=0 to 90 do
    SetAsInput(PORTA);            // Apaga display conectado al puerta A.
    // Muestra el Angulo.
    PORTB := DecToBCD2(contador);
    delay_ms(1000);               // Pausa tras mostrar Angulo en grados.
    // Muestra el SENO del Angulo.
    PORTB := sin90(contador);
    SetAsOutput(PORTA);           // Enciende display conectado al puerto A.
    if PORTB = $A0 then
      PORTA := $01;
      PORTB := $00;
    else
      PORTA := $00;
    end;
    delay_ms(1000);               // Pausa tras mostrar el resultado SEN(Angulo)
  end;
end.
