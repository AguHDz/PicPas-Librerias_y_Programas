{  
*  (C) AguHDz 15-AGO-2017
*  Ultima Actualizacion: 18-AGO-2017
*  
*  Compilador PicPas v.0.7.3 (https://github.com/t-edson/PicPas)
*
*  FUNCIONES MATEMATICAS BASICAS PARA INTEGRAR EN PICPAS - DIVISION Y MODULO (RESIDUO O RESTO DE DIVISION) - 8 BITS
*  ================================================================================================================
*  Nomenclatura usada:
*  El registro W y las variables _H, _U, _E para el resultado,
*  los nombres OPVAR_A y OPVAR_B para los operandos,
*  OPCON_A y OPCON_B para las constantes,
*  y SYSTMP00, SYSTMP01,...SYSTMP?? para las variables temporales y contadores dentro de las funciones.
}

{$PROCESSOR PIC16F877A}
{$FREQUENCY 8Mhz}
{$MODE PICPAS}

program Math_8bitsTo16bits_DIVIDIR_y_MODULO;

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

// --- D I V I S I O N  &  M O D U L O -------------------------------------------------
// ... 8 BITS ...
procedure Math_8bits_DIV_MOD;
begin
  ASM
  ;[W] = [W] / [_H]
  ;COCIENTE = OP_A / OP_B  ---- MODULO (RESTO O RESIDUO) = OP_A % OP_B 
  ;_U Contiene al OP_A. Y al final del LOOP de división el COCIENTE de la división.
  ;_E Contiene el resto (MODULO) de la división.
  ;SYSTMP00 variable temporal. Contador de bucle de división.
    CLRF    _E          ;Resto (modulo) de la división.
    MOVF    _H,F
    BTFSS   STATUS,2    ;Si Zero
    GOTO    SEGUIR      ;Divisor > 0
   ;Si divisor = 0 divuelve el número maximo posible ($FF=infinito o indeterminado)
   ;Tambien se podría activar flag de ERROR de DIVISION POR CERO.
   ;El resto de la división contendrá el valor inicial = 0.
    MOVLW   $FF
    MOVWF   _U
    RETURN
  SEGUIR:
    MOVWF   _U          ;OP_A := W
    MOVLW   8           ;Número de 8 bits.
    MOVWF   SYSTMP00
  DIV_LOOP:
    RLF     _U,F        ;OP_A >> 1
    RLF     _E,F        ;MODULO >> 1
    MOVF    _H,W        ;MODULO -= OP_B
    SUBWF   _E,F
    BSF     _U,0        ;OP_A.0 := 1
    BTFSC   STATUS,0    ;Si Carry
    GOTO    SIGUIENTE
    BCF     _U,0        ;OP_A.0 := 0
    MOVF    _H,W        ;MODULO += OP_B
    ADDWF   _E,F
  SIGUIENTE:
    DECFSZ  SYSTMP00,F
    GOTO    DIV_LOOP
  END
end;

// ... MODULO VARIABLE x VARIABLE ...
procedure Math_8bits_MODULO_VAR_VAR : byte;
begin
  ASM
    MOVF    OPVAR_B,W
    MOVWF   _H
    MOVF    OPVAR_A,W   ;Pasando el operando A en el registro W se ahorra 1 instrucción en cada división
                        ;Aunque 1 instrucción más en subrutina, si hay más de una suma Math_8bits_DIV_MOD,
                        ;se gana 1 posición de memoria de programa por cada operación adicional. 
    CALL    Math_8bits_DIV_MOD
    MOVF    _E,W        ;Devuelve el resultado en el registro W.
  END
end;

// ... DIVISION VARIABLE x VARIABLE ...
procedure Math_8bits_DIVISION_VAR_VAR : byte;
begin
  ASM
    MOVF    OPVAR_B,W
    MOVWF   _H
    MOVF    OPVAR_A,W   ;Pasando el operando A en el registro W se ahorra 1 instrucción en cada división
                        ;Aunque 1 instrucción más en subrutina, si hay más de una suma Math_8bits_DIV_MOD,
                        ;se gana 1 posición de memoria de programa por cada operación adicional. 
    CALL    Math_8bits_DIV_MOD
    MOVF    _U,W        ;Devuelve el resultado en el registro W.
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
  LCDPrint_DIV;
  LCD_WriteChar(' ');
  LCDPrint_VAR;
  LCD_WriteChar('/');
  LCDPrint_VAR;
  LCD_WriteChar(' ');
  LCD_WriteChar('8');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,1);
  OPVAR_A := $2F;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,0);
  LCD_WriteChar('/');
  OPVAR_B :=$AA;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,0);
  LCD_WriteChar('=');
  Print_Numero_8bit(Math_8bits_DIVISION_VAR_VAR);
  
  LCD_GotoXY(1,6);
  OPVAR_A := $0F;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,5);
  LCD_WriteChar('/');
  OPVAR_B :=$0A;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,5);
  LCD_WriteChar('=');
  Print_Numero_8bit(Math_8bits_DIVISION_VAR_VAR);
  
  LCD_GotoXY(1,11);
  OPVAR_A := $F5;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,10);
  LCD_WriteChar('/');
  OPVAR_B :=$20;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,10);
  LCD_WriteChar('=');
  Print_Numero_8bit(Math_8bits_DIVISION_VAR_VAR);
  
  LCD_GotoXY(1,16);
  OPVAR_A := $55;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,15);
  LCD_WriteChar('/');
  OPVAR_B :=$00;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,15);
  LCD_WriteChar('=');
  Print_Numero_8bit(Math_8bits_DIVISION_VAR_VAR);
// ----------------------
  delay_ms(3000);
  LCD_Clear;
  
  LCDPrint_MOD;
  LCD_WriteChar(' ');
  LCDPrint_VAR;
  LCD_WriteChar('%');
  LCDPrint_VAR;
  LCD_WriteChar(' ');
  LCD_WriteChar('8');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,1);
  OPVAR_A := $2F;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,0);
  LCD_WriteChar('%');
  OPVAR_B :=$AA;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,0);
  LCD_WriteChar('=');
  Print_Numero_8bit(Math_8bits_MODULO_VAR_VAR);
  
  LCD_GotoXY(1,6);
  OPVAR_A := $0F;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,5);
  LCD_WriteChar('%');
  OPVAR_B :=$0A;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,5);
  LCD_WriteChar('=');
  Print_Numero_8bit(Math_8bits_MODULO_VAR_VAR);
  
  LCD_GotoXY(1,11);
  OPVAR_A := $F5;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,10);
  LCD_WriteChar('%');
  OPVAR_B :=$20;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,10);
  LCD_WriteChar('=');
  Print_Numero_8bit(Math_8bits_MODULO_VAR_VAR);
  
  LCD_GotoXY(1,16);
  OPVAR_A := $55;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,15);
  LCD_WriteChar('%');
  OPVAR_B :=$00;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,15);
  LCD_WriteChar('=');
  Print_Numero_8bit(Math_8bits_MODULO_VAR_VAR);

end. 




