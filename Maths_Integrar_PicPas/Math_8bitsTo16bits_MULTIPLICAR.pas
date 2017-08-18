{  
*  (C) AguHDz 15-AGO-2017
*  Ultima Actualizacion: 16-AGO-2017
*  
*  Compilador PicPas v.0.7.3 (https://github.com/t-edson/PicPas)
*
*  FUNCIONES MATEMATICAS BASICAS PARA INTEGRAR EN PICPAS - MULTIPLICACION VARIABLES 8 BITS CON RESULTADO 16 BITS
*  =============================================================================================================
*  Nomenclatura usada:
*  El registro W y las variables _H, _U, _E para el resultado,
*  los nombres OPVAR_A y OPVAR_B para los operandos,
*  OPCON_A y OPCON_B para las constantes,
*  y SYSTMP00, SYSTMP01,...SYSTMP?? para las variables temporales y contadores dentro de las funciones.
}

{$PROCESSOR PIC16F877A}
{$FREQUENCY 8Mhz}
{$MODE PICPAS}

program Math_8bitsTo16bits_MULTIPLICAR;

uses PIC16F877A, LCDLib_4bits_PIC16F877A;

var
// Operandos tipo variable.
OPVAR_A  : byte;
OPVAR_B  : byte;
// VARIABLE AXILIAR QUE ESTARA DEFINIDA POR DEFECTO EN PROXIMA VERSION DE PICPAS
_U       : byte;  // UltraHIGH / UHIGH / UH / HIGH.LOW  / HL
_E       : byte;  // ExtraHIGH / EHIGH / EH / HIGH.HIGH / HH
// Variables axiliares para guardar valores temporales o contadores.
SYSTMP00 : byte;
SYSTMP01 : byte;
SYSTMP02 : byte;
SYSTMP03 : byte;
SYSTMP04 : byte;
SYSTMP05 : byte;
SYSTMP06 : byte;

// --- M U L T I P L I C A R -------------------------------------------------
// ... 8 BITS X 8 BITS (RESULTADO 16 BITS)
procedure Math_8bitsTo16bits_MULTIPLICAR : word;
begin
  ASM
  ;[H_W] =  [W] x [_U]
  ; RES  = OP_A x OP_B
  ;SYSTMP00 variable temporal. Contiene RES.LOW (resultado.LOW de la multiplicación)
  ;_H Contine durante todo el bucle de multiplicación la parte alta de resultado (RES.HIGH)
  ;_E Contiene OP_A.LOW (inicialmente W)
  ;SYSTMP01 variable temporal. Contiene OP_A.HIGH (inicialmente 0)
    CLRF    SYSTMP00    ;Clear RES.LOW
    CLRF    _H          ;Clear RES.HIGH
    CLRF    SYSTMP01    ;Clear OP_A.HIGH
    MOVWF   _E          ;OP_A.LOW := W 
  MUL_LOOP:
    BTFSS   _U,0        ;Si (OP_B.0=1) then RES+=OP_A
    GOTO    END_IF_1
   	MOVF    _E,W
    ADDWF   SYSTMP00,F
    MOVF    SYSTMP01,W
    BTFSC   STATUS,0
    ADDLW   1
    ADDWF   _H,F
  END_IF_1:
    BCF     STATUS,0    ;STATUS.C := 0
    RRF     _U,F        ;OP_B>>1
    BCF     STATUS,0    ;STATUS.C := 0
    RLF     _E,F        ;OP_A<<1
    RLF     SYSTMP01,F
    MOVF    _U,F        ;Si (OP_B>0) then goto MUL_LOOP
    BTFSS   STATUS,2    ;Flag Zero
    GOTO    MUL_LOOP    ;OP_B>0
    MOVF    SYSTMP00,W  ;Return RES.LOW to W
  END
end;

// ... VARIABLE x VARIABLE ...
procedure Math_8bitsTo16bits_MULTIPLICAR_VAR_VAR : word;
begin
  ASM
    MOVF    OPVAR_B,W
    MOVWF   _U
    MOVF    OPVAR_A,W    ;Pasando el operando A en el registro W se ahorra 1 instrucción en cada suma
                         ;Aunque 1 instrucción más en subrutina, si hay más de una suma 8bitsTo16bits,
                         ;se gana 1 posición de memoria de programa por cada suma adicional. 
    CALL    Math_8bitsTo16bits_MULTIPLICAR
  END
end;


procedure LCDPrint_MUL;
begin
  LCD_WriteChar('M');
  LCD_WriteChar('u');
  LCD_WriteChar('l');
end;

procedure LCDPrint_MOD;
begin
  LCD_WriteChar('M');
  LCD_WriteChar('o');
  LCD_WriteChar('d');
end;

procedure LCDPrint_DIV;
begin
  LCD_WriteChar('D');
  LCD_WriteChar('i');
  LCD_WriteChar('v');
end;

procedure LCDPrint_VAR;
begin
  LCD_WriteChar('V');
  LCD_WriteChar('a');
  LCD_WriteChar('r');
end;

procedure LCDPrint_CONST;
begin
  LCD_WriteChar('C');
  LCD_WriteChar('o');
  LCD_WriteChar('n');
  LCD_WriteChar('s');
  LCD_WriteChar('t');
end;

procedure LCDPrint_BIT;
begin
  LCD_WriteChar('b');
  LCD_WriteChar('i');
  LCD_WriteChar('t');
end; 

// ------------------------------------------------------------------
procedure Print_Digito(numero : byte);
// Imprime en formato HEXADECIMAL un número de 16 bits contenido en la variable ACUMULADOR.
const
  CONV_CHR_NUMERO = $30;  // ASCII '0' ($30) menos $00 = $30
  CONV_CHR_LETRA  = $37;  // ASCII 'A' ($41) menos $10 = $37
begin
  if(numero>9) then numero := numero + CONV_CHR_LETRA;
  else numero := numero + CONV_CHR_NUMERO end;
  LCD_WriteChar(Chr(numero));
end;
// ------------------------------------------------------------------
procedure Print_Numero_8bit(numero : byte);
var
  auxiliar : byte;
begin
  auxiliar := numero >> 4;
  Print_Digito(auxiliar);
  auxiliar := numero AND $0F;
  Print_Digito(auxiliar);
end;
// ------------------------------------------------------------------
procedure Print_Numero_16bit(numero : word);
begin
  Print_Numero_8bit(numero.high);
  Print_Numero_8bit(numero.low);
end;

begin
  LCD_Init(4,20);
   
// Demostración de uso de operaciones con variables de 8 bits

// ----------------------
  LCDPrint_MUL;
  LCD_WriteChar('1');
  LCD_WriteChar('6');
  LCD_WriteChar(' ');
  LCDPrint_VAR;
  LCD_WriteChar('x');
  LCDPrint_VAR;
  LCD_WriteChar(' ');
  LCD_WriteChar('8');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,3);
  OPVAR_A := $2F;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,2);
  LCD_WriteChar('x');
  OPVAR_B :=$AA;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,0);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_8bitsTo16bits_MULTIPLICAR_VAR_VAR);
  
  LCD_GotoXY(1,10);
  OPVAR_A := $0F;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,9);
  LCD_WriteChar('x');
  OPVAR_B :=$0A;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,7);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_8bitsTo16bits_MULTIPLICAR_VAR_VAR);
  
  LCD_GotoXY(1,17);
  OPVAR_A := $55;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,16);
  LCD_WriteChar('x');
  OPVAR_B :=$20;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,14);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_8bitsTo16bits_MULTIPLICAR_VAR_VAR);
// ----------------------
  delay_ms(3000);
    
  LCD_GotoXY(1,3);
  OPVAR_A := $2F;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,2);
  LCD_WriteChar('x');
  OPVAR_B :=$00;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,0);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_8bitsTo16bits_MULTIPLICAR_VAR_VAR);
  
  LCD_GotoXY(1,10);
  OPVAR_A := $FF;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,9);
  LCD_WriteChar('x');
  OPVAR_B :=$FF;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,7);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_8bitsTo16bits_MULTIPLICAR_VAR_VAR);
  
  LCD_GotoXY(1,17);
  OPVAR_A := $FF;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,16);
  LCD_WriteChar('x');
  OPVAR_B :=$01;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,14);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_8bitsTo16bits_MULTIPLICAR_VAR_VAR);

end. 




