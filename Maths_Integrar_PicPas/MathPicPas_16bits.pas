{  
*  (C) AguHDz 15-AGO-2017
*  Ultima Actualizacion: 17-AGO-2017
*  
*  Compilador PicPas v.0.7.3 (https://github.com/t-edson/PicPas)
*
*  FUNCIONES MATEMATICAS BASICAS PARA INTEGRAR EN PICPAS - 16 BITS
*  ===============================================================
*  Nomenclatura usada:
*  @0,@1,@2 y @3 para los bytes de los operandos,
*  El registro W y las variables _H, _U, _E para el resultado,
*  los nombres OPVAR_A y OPVAR_B para los operandos,
*  OPCON_A y OPCON_B para las constantes,
*  y SYSTMP00, SYSTMP01,...SYSTMP?? para las variables temporales y contadores dentro de las funciones.
*  
*  
*  En la versión 0.7.3:
*  Para los bytes, bits y boolean, prácticamente, están implementadas todas las operaciones básicas
*  (salvo algunos casos puntuales), incluyendo +, -, =, <>, >, >=, <, <=, AND OR, XOR, NOT, >>, <<. 
*  Para los word, están implementados las operaciones de suma (salvo algunos casos), y comparaciones = , <>, >
*  
*  Los resultados bits y boolean se devuelve en el bit Z, del STATUS. Aunque por optimización,
*  en algunos casos, se puede usar el bit C.
*  
*  Solo considerar que las operaciones de comparación necesarias son: =, >, <. Las otras, no son necesarias,
*  ya que se obtienen por una simple negación lógica, algo que PicPas sabe hacer muy bien. Por lo general,
*  estas operaciones usan los algoritmos de resta.
}

{$PROCESSOR PIC16F877A}
{$FREQUENCY 8Mhz}
{$MODE PICPAS}

program Math_8bits_PicPas;

uses PIC16F877A, LCDLib_4bits_PIC16F877A;

const
// Operandos tipo constante.
OPCON_A = $1234;
OPCON_B = $9876;

var
// Operandos tipo variable.
OPVAR_A  : word;
OPVAR_B  : word;
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


// OPERACIONES CON VARIABLES O CONSTANTES DE 16 BITS **********************
// --- S U M A R -------------------------------------------------------------
procedure Math_16bits_SUMAR : word;
begin
  ASM
  ;[H_W] = [H_W] + [E_U] 
    ADDWF   _U,F
    BTFSC   STATUS,0
    INCF    _H,F
    MOVF    _E,W
    ADDWF   _H,F
    MOVF    _U,W
  END
end;
// ... VARIABLE + VARIABLE ...
procedure Math_16bits_SUMAR_VAR_VAR : word;
begin
  ASM
    MOVF    OPVAR_B.HIGH,W
    MOVWF   _E
    MOVF    OPVAR_B.LOW,W
    MOVWF   _U
    MOVF    OPVAR_A.HIGH,W
    MOVWF   _H
    MOVF    OPVAR_A.LOW,W
    CALL    Math_16bits_SUMAR
  END
end;
// ... VARIABLE + CONSTANTE ...
procedure Math_16bits_SUMAR_VAR_CON : word;
begin
  ASM
    MOVLW   OPCON_B.HIGH
    MOVWF   _E
    MOVLW   OPCON_B.LOW
    MOVWF   _U
    MOVF    OPVAR_A.HIGH,W
    MOVWF   _H
    MOVF    OPVAR_A.LOW,W
    CALL    Math_16bits_SUMAR
  END
end;
// ... CONSTANTE + VARIABLE ...
procedure Math_16bits_SUMAR_CON_VAR : word;
begin
  ASM
    MOVF    OPVAR_B.HIGH,W
    MOVWF   _E
    MOVF    OPVAR_B.LOW,W
    MOVWF   _U
    MOVLW   OPCON_A.HIGH
    MOVWF   _H
    MOVLW   OPCON_A.LOW
    CALL    Math_16bits_SUMAR
  END
end;
// ---------------------------------------------------------------------------

// --- R E S T A R -----------------------------------------------------------
procedure Math_16bits_RESTAR : word;
begin
  ASM
  ;[H_W] = [H_E] - [U_W]
    SUBWF   _E,F
    BTFSS   STATUS,0
    DECF    _H,F
    MOVF    _U,W
    SUBWF   _H,F
    MOVF    _E,W
  END
end;
// ... VARIABLE - VARIABLE ...
procedure Math_16bits_RESTAR_VAR_VAR : word;
begin
  ASM
    MOVF    OPVAR_A.HIGH,W
    MOVWF   _H
    MOVF    OPVAR_A.LOW,W
    MOVWF   _E
    MOVF    OPVAR_B.HIGH,W
    MOVWF   _U
    MOVF    OPVAR_B.LOW,W
    CALL    Math_16bits_RESTAR
  END
end;
// ... VARIABLE - CONSTANTE ...
procedure Math_16bits_RESTAR_VAR_CON : word;
begin
  ASM
    MOVF    OPVAR_A.HIGH,W
    MOVWF   _H
    MOVF    OPVAR_A.LOW,W
    MOVWF   _E
    MOVLW   OPCON_B.HIGH
    MOVWF   _U
    MOVLW   OPCON_B.LOW
    CALL    Math_16bits_RESTAR
  END
end;
// ... CONSTANTE - VARIABLE ...
procedure Math_16bits_RESTAR_CON_VAR : word;
begin
  ASM
    MOVLW   OPCON_A.HIGH
    MOVWF   _H
    MOVLW   OPCON_A.LOW
    MOVWF   _E
    MOVF    OPVAR_B.HIGH,W
    MOVWF   _U
    MOVF    OPVAR_B.LOW,W
    CALL    Math_16bits_RESTAR
  END
end;
// ---------------------------------------------------------------------------


// --- M U L T I P L I C A R -------------------------------------------------
procedure Math_16bits_MULTIPLICAR : word;
begin
  ASM
  ;[H_W] = [H_W] x [E_U]
  ; RES  =  OP_A x OP_B
  ;SYSTMP00 variable temporal. Contiene RES.LOW (resultado.LOW de la multiplicación)
  ;SYSTMP01 variable temporal. Contiene OP_A.LOW  (inicialmente W)
  ;SYSTMP02 variable temporal. Contiene OP_A.HIGH (inicialmente _H)
  ;_H contine durante todo el bucle de multiplicación la parte alta de resultado (RES.HIGH)
    CLRF    SYSTMP00    ;Clear RES.LOW
    MOVWF   SYSTMP01    ;OP_A.LOW  := W
    MOVF    _H,W        ;OP_A.HIGH := _H
    MOVWF   SYSTMP02    
    CLRF    _H          ;Clear RES.HIGH    
  MUL16LOOP:
    BTFSS   _U,0        ;Si (OP_B.0=1) then RES+=OP_A
    GOTO    END_IF_1
   	MOVF    SYSTMP01,W
    ADDWF   SYSTMP00,F
    MOVF    SYSTMP02,W
    BTFSC   STATUS,0
    ADDLW   1
    ADDWF   _H,F
  END_IF_1:
    BCF     STATUS,0    ;STATUS.C := 0
    RRF     _E,F        ;OP_B>>1
    RRF     _U,F
    BCF     STATUS,0    ;STATUS.C := 0
    RLF     SYSTMP01,F  ;OP_A<<1
    RLF     SYSTMP02,F
    MOVF    _E,w        ;Si (OP_B>0) then goto MUL16LOOP
    IORWF   _U,w 
    BTFSS   STATUS,2
    GOTO    MUL16LOOP   ;OP_B>0
    MOVF    SYSTMP00,w  ;Return RES.LOW to W
  END
end;

// ... VARIABLE x VARIABLE ...
procedure Math_16bits_MULTIPLICAR_VAR_VAR : word;
begin
  ASM
    MOVF    OPVAR_B.HIGH,W
    MOVWF   _E
    MOVF    OPVAR_B.LOW,W
    MOVWF   _U
    MOVF    OPVAR_A.HIGH,W
    MOVWF   _H
    MOVF    OPVAR_A.LOW,W
    CALL    Math_16bits_MULTIPLICAR
  END
end;
// ... VARIABLE x CONSTANTE ...
procedure Math_16bits_MULTIPLICAR_VAR_CON : word;
begin
  ASM
    MOVLW   OPCON_B.HIGH
    MOVWF   _E
    MOVLW   OPCON_B.LOW
    MOVWF   _U
    MOVF    OPVAR_A.HIGH,W
    MOVWF   _H
    MOVF    OPVAR_A.LOW,W
    CALL    Math_16bits_MULTIPLICAR
  END
end;
// ... CONSTANTE x VARIABLE ...
procedure Math_16bits_MULTIPLICAR_CON_VAR : word;
begin
  ASM
    MOVF    OPVAR_B.HIGH,W
    MOVWF   _E
    MOVF    OPVAR_B.LOW,W
    MOVWF   _U
    MOVLW   OPCON_A.HIGH
    MOVWF   _H
    MOVLW   OPCON_A.LOW
    CALL    Math_16bits_MULTIPLICAR
  END
end;

procedure Math_16bitsTo32bits_MULTIPLICAR : word;
begin
  ASM
  ;[U_E_H_W] = [H_W] x [U_E]
  ;   RES    =  OP_A x OP_B
  ;SYSTMP00 variable temporal. Contiene RES_L (resultado.LOW de la multiplicación)
  ;SYSTMP01 variable temporal. Contiene OP_A.LOW   (inicialmente W)
  ;SYSTMP02 variable temporal. Contiene OP_A.HIGH  (inicialmente _H)
  ;SYSTMP03 variable temporal. Contiene OP_A.UHIGH (inicialmente 0)
  ;SYSTMP04 variable temporal. Contiene OP_A.EHIGH (inicialmente 0)
  ;SYSTMP05 variable temporal. Contiene OP_B.LOW   (inicialmente _U)
  ;SYSTMP06 variable temporal. Contiene OP_B.HIGH  (inicialmente _E)
  ;_H, _E y _U continen durante todo el bucle de multiplicación los bytes del resultado (RES_H, RES_U y RES_E)
    CLRF    SYSTMP00    ;Clear RES_L
    MOVWF   SYSTMP01    ;OP_A.LOW  := W
    MOVF    _H,W        ;OP_A.HIGH := _H
    MOVWF   SYSTMP02    
    CLRF    _H          ;Clear RES_H
    CLRF    SYSTMP03    ;Clear OP_A.UHIGH
    CLRF    SYSTMP04    ;Clear OP_A.EHIGH
    MOVF    _U,W        ;OP_B.LOW := _U
    MOVWF   SYSTMP05    
    CLRF    _U          ;Clear RES_U
    MOVF    _E,W        ;OP_B.HIGH := _E
    MOVWF   SYSTMP06    
    CLRF    _E          ;Clear RES_E 
  MUL16LOOP:
    BTFSS   SYSTMP05,0  ;Si (OP_B.0=1) then RES+=OP_A
    GOTO    END_IF_1
   	MOVF    SYSTMP01,W
    ADDWF   SYSTMP00,F
    MOVF    SYSTMP02,W
    BTFSC   STATUS,0
    ADDLW   1
    ADDWF   _H,F
    MOVF    SYSTMP03,W
    BTFSC   STATUS,0
    ADDLW   1
    ADDWF   _U,F
    MOVF    SYSTMP04,W
    BTFSC   STATUS,0
    ADDLW   1
    ADDWF   _E,F 
  END_IF_1:
    BCF     STATUS,0    ;STATUS.C := 0
    RRF     SYSTMP06,F  ;OP_B>>1
    RRF     SYSTMP05,F
    BCF     STATUS,0    ;STATUS.C := 0
    RLF     SYSTMP01,F  ;OP_A<<1
    RLF     SYSTMP02,F
    RLF     SYSTMP03,F
    RLF     SYSTMP04,F
    MOVF    SYSTMP05,w  ;Si (OP_B>0) then goto MUL16LOOP
    IORWF   SYSTMP06,w
    BTFSS   STATUS,2
    GOTO    MUL16LOOP   ;OP_B>0  
    MOVF    SYSTMP00,w  ;Return RES.LOW to W
  END
end;
// ... VARIABLE x VARIABLE ... (RESULTADO 32 BITS)
procedure Math_16bitsTo32bits_MULTIPLICAR_VAR_VAR : word;
begin
  ASM
    MOVF    OPVAR_B.HIGH,W
    MOVWF   _E
    MOVF    OPVAR_B.LOW,W
    MOVWF   _U
    MOVF    OPVAR_A.HIGH,W
    MOVWF   _H
    MOVF    OPVAR_A.LOW,W
    CALL    Math_16bitsTo32bits_MULTIPLICAR
  END
end;
// ... VARIABLE x CONSTANTE ... (RESULTADO 16 BITS)
procedure Math_16bitsTo32bits_MULTIPLICAR_VAR_CON : word;
begin
  ASM
    MOVLW   OPCON_B.HIGH
    MOVWF   _E
    MOVLW   OPCON_B.LOW
    MOVWF   _U
    MOVF    OPVAR_A.HIGH,W
    MOVWF   _H
    MOVF    OPVAR_A.LOW,W
    CALL    Math_16bitsTo32bits_MULTIPLICAR
  END
end;
// ... CONSTANTE x VARIABLE ... (RESULTADO 16 BITS)
procedure Math_16bitsTo32bits_MULTIPLICAR_CON_VAR : word;
begin
  ASM
    MOVF    OPVAR_B.HIGH,W
    MOVWF   _E
    MOVF    OPVAR_B.LOW,W
    MOVWF   _U
    MOVLW    OPCON_A.HIGH
    MOVWF   _H
    MOVLW    OPCON_A.LOW
    CALL    Math_16bitsTo32bits_MULTIPLICAR
  END
end;
// ---------------------------------------------------------------------------

// --- M O D U L O -------------------------------------------------
procedure Math_16bits_MODULO : byte;
begin
  ASM

  END
end;
// ... VARIABLE x VARIABLE ...
procedure Math_16bits_MODULO_VAR_VAR : byte;
begin
  ASM

  END
end;
// ... VARIABLE x CONSTANTE ...
procedure Math_16bits_MODULO_VAR_CON : byte;
begin
  ASM

  END
end;

// ... VARIABLE x VARIABLE ...
procedure Math_16bits_MODULO_CON_VAR : byte;
begin
  ASM

  END
end;
// ---------------------------------------------------------------------------

// --- D I V I D I R -------------------------------------------------
procedure Math_16bits_DIVIDIR : byte;
begin
  ASM

  END
end;
// ... VARIABLE x VARIABLE ...
procedure Math_16bits_DIVIDIR_VAR_VAR : byte;
begin
  ASM

  END
end;
// ... VARIABLE x CONSTANTE ...
procedure Math_16bits_DIVIDIR_VAR_CON : byte;
begin
  ASM

  END
end;

// ... VARIABLE x VARIABLE ...
procedure Math_16bits_DIVIDIR_CON_VAR : byte;
begin
  ASM

  END
end;
// ---------------------------------------------------------------------------
procedure LCDPrint_SUM;
begin
  LCD_WriteChar('S');
  LCD_WriteChar('u');
  LCD_WriteChar('m');  
  LCD_WriteChar('a');
end;

procedure LCDPrint_RES;
begin
  LCD_WriteChar('R');
  LCD_WriteChar('e');
  LCD_WriteChar('s');  
  LCD_WriteChar('t');  
  LCD_WriteChar('a');
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

procedure LCDPrint_CON;
begin
  LCD_WriteChar('C');
  LCD_WriteChar('o');
  LCD_WriteChar('n');
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

procedure Print_Numero_32bit(numero_DWORD_HL : word; numero_DWORD_U, numero_DWORD_E : byte);
begin
  Print_Numero_8bit(numero_DWORD_E);
  Print_Numero_8bit(numero_DWORD_U);
  Print_Numero_16bit(numero_DWORD_HL);
end;


begin
  LCD_Init(4,20);
   
// Demostración de uso de operaciones con variables de 16 bits

// ----------------------
  LCDPrint_SUM;
  LCD_WriteChar(' ');
  LCDPrint_VAR;
  LCD_WriteChar('+');
  LCDPrint_VAR;
  LCD_WriteChar(' ');
  LCD_WriteChar('1');  
  LCD_WriteChar('6');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,1);
  OPVAR_A := $9876;
  OPVAR_B := $1234;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,0);
  LCD_WriteChar('+');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,0);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_SUMAR_VAR_VAR);
  
  LCD_GotoXY(1,8);
  OPVAR_A := $1234;
  OPVAR_B := $9876;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,7);
  LCD_WriteChar('+');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,7);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_SUMAR_VAR_VAR);
  
  LCD_GotoXY(1,15);
  OPVAR_A := $2564;
  OPVAR_B := $34A4;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,14);
  LCD_WriteChar('+');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,14);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_SUMAR_VAR_VAR);
// ----------------------
  delay_ms(3000);
  LCD_Clear;
 
  LCDPrint_SUM;
  LCD_WriteChar(' ');
  LCDPrint_VAR;
  LCD_WriteChar('+');
  LCDPrint_CON;
  LCD_WriteChar(' ');
  LCD_WriteChar('1');  
  LCD_WriteChar('6');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,1);
  OPVAR_A := $9876;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,0);
  LCD_WriteChar('+');
  Print_Numero_16bit(OPCON_B);
  LCD_GotoXY(3,0);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_SUMAR_VAR_CON);
  
  LCD_GotoXY(1,8);
  OPVAR_A := $1234;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,7);
  LCD_WriteChar('+');
  Print_Numero_16bit(OPCON_B);
  LCD_GotoXY(3,7);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_SUMAR_VAR_CON);
  
  LCD_GotoXY(1,15);
  OPVAR_A := $2564;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,14);
  LCD_WriteChar('+');
  Print_Numero_16bit(OPCON_B);
  LCD_GotoXY(3,14);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_SUMAR_VAR_CON);
    
// ----------------------
  delay_ms(3000);
  LCD_Clear;
 
  LCDPrint_SUM;
  LCD_WriteChar(' ');
  LCDPrint_CON;
  LCD_WriteChar('+');
  LCDPrint_VAR;
  LCD_WriteChar(' ');
  LCD_WriteChar('1');  
  LCD_WriteChar('6');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,1);
  OPVAR_B := $9876;
  Print_Numero_16bit(OPCON_A);
  LCD_GotoXY(2,0);
  LCD_WriteChar('+');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,0);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_SUMAR_CON_VAR);
  
  LCD_GotoXY(1,8);
  OPVAR_B := $1234;
  Print_Numero_16bit(OPCON_A);
  LCD_GotoXY(2,7);
  LCD_WriteChar('+');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,7);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_SUMAR_CON_VAR);
  
  LCD_GotoXY(1,15);
  OPVAR_B := $2564;
  Print_Numero_16bit(OPCON_A);
  LCD_GotoXY(2,14);
  LCD_WriteChar('+');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,14);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_SUMAR_CON_VAR);

// ----------------------
  delay_ms(3000);
  LCD_Clear;
  
  LCDPrint_RES;
  LCD_WriteChar(' ');
  LCDPrint_VAR;
  LCD_WriteChar('-');
  LCDPrint_VAR;
  LCD_WriteChar(' ');
  LCD_WriteChar('1');  
  LCD_WriteChar('6');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,1);
  OPVAR_A := $9876;
  OPVAR_B := $1234;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,0);
  LCD_WriteChar('-');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,0);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_RESTAR_VAR_VAR);
  
  LCD_GotoXY(1,8);
  OPVAR_A := $1234;
  OPVAR_B := $9876;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,7);
  LCD_WriteChar('-');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,7);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_RESTAR_VAR_VAR);
  
  LCD_GotoXY(1,15);
  OPVAR_A := $2564;
  OPVAR_B := $34A4;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,14);
  LCD_WriteChar('-');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,14);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_RESTAR_VAR_VAR);
// ----------------------
  delay_ms(3000);
  LCD_Clear;
 
  LCDPrint_RES;
  LCD_WriteChar(' ');
  LCDPrint_VAR;
  LCD_WriteChar('-');
  LCDPrint_CON;
  LCD_WriteChar(' ');
  LCD_WriteChar('1');  
  LCD_WriteChar('6');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,1);
  OPVAR_A := $9876;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,0);
  LCD_WriteChar('-');
  Print_Numero_16bit(OPCON_B);
  LCD_GotoXY(3,0);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_RESTAR_VAR_CON);
  
  LCD_GotoXY(1,8);
  OPVAR_A := $1234;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,7);
  LCD_WriteChar('-');
  Print_Numero_16bit(OPCON_B);
  LCD_GotoXY(3,7);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_RESTAR_VAR_CON);
  
  LCD_GotoXY(1,15);
  OPVAR_A := $2564;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,14);
  LCD_WriteChar('-');
  Print_Numero_16bit(OPCON_B);
  LCD_GotoXY(3,14);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_RESTAR_VAR_CON);
  
// ----------------------
  delay_ms(3000);
  LCD_Clear;
 
  LCDPrint_RES;
  LCD_WriteChar(' ');
  LCDPrint_CON;
  LCD_WriteChar('-');
  LCDPrint_VAR;
  LCD_WriteChar(' ');
  LCD_WriteChar('1');  
  LCD_WriteChar('6');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,1);
  OPVAR_B := $9876;
  Print_Numero_16bit(OPCON_A);
  LCD_GotoXY(2,0);
  LCD_WriteChar('-');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,0);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_RESTAR_CON_VAR);
  
  LCD_GotoXY(1,8);
  OPVAR_B := $1234;
  Print_Numero_16bit(OPCON_A);
  LCD_GotoXY(2,7);
  LCD_WriteChar('-');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,7);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_RESTAR_CON_VAR);
  
  LCD_GotoXY(1,15);
  OPVAR_B := $2564;
  Print_Numero_16bit(OPCON_A);
  LCD_GotoXY(2,14);
  LCD_WriteChar('-');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,14);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_RESTAR_CON_VAR); 

// ----------------------
  delay_ms(3000);
  LCD_Clear;
 
  LCDPrint_MUL;
  LCD_WriteChar(' ');
  LCDPrint_VAR;
  LCD_WriteChar('x');
  LCDPrint_VAR;
  LCD_WriteChar(' ');
  LCD_WriteChar('1');
  LCD_WriteChar('6');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,1);
  OPVAR_A := $3421;
  OPVAR_B := $0002;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,0);
  LCD_WriteChar('x');
  OPVAR_B :=$03;
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,0);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_MULTIPLICAR_VAR_VAR);  
  
  LCD_GotoXY(1,8);
  OPVAR_A := $1234;
  OPVAR_B := $22;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,7);
  LCD_WriteChar('x');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,7);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_MULTIPLICAR_VAR_VAR);
  
  LCD_GotoXY(1,15);
  OPVAR_A := $2564;
  OPVAR_B := $A4;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,14);
  LCD_WriteChar('x');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,14);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_MULTIPLICAR_VAR_VAR);  
// ----------------------
  delay_ms(3000);
  LCD_Clear;

  LCDPrint_MUL;
  LCD_WriteChar(' ');
  LCDPrint_VAR;
  LCD_WriteChar('x');
  LCDPrint_CON;
  LCD_WriteChar(' ');
  LCD_WriteChar('1');
  LCD_WriteChar('6');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,1);
  OPVAR_A := $3421;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,0);
  LCD_WriteChar('x');
  Print_Numero_16bit(OPCON_B);
  LCD_GotoXY(3,0);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_MULTIPLICAR_VAR_CON);  
  
  LCD_GotoXY(1,8);
  OPVAR_A := $1234;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,7);
  LCD_WriteChar('x');
  Print_Numero_16bit(OPCON_B);
  LCD_GotoXY(3,7);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_MULTIPLICAR_VAR_CON);
  
  LCD_GotoXY(1,15);
  OPVAR_A := $2564;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,14);
  LCD_WriteChar('x');
  Print_Numero_16bit(OPCON_B);
  LCD_GotoXY(3,14);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_MULTIPLICAR_VAR_CON);
// ----------------------
  delay_ms(3000);
  LCD_Clear;

  LCDPrint_MUL;
  LCD_WriteChar(' ');
  LCDPrint_CON;
  LCD_WriteChar('x');
  LCDPrint_VAR;
  LCD_WriteChar(' ');
  LCD_WriteChar('1');
  LCD_WriteChar('6');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,1);
  OPVAR_B := $3421;
  Print_Numero_16bit(OPCON_A);
  LCD_GotoXY(2,0);
  LCD_WriteChar('x');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,0);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_MULTIPLICAR_CON_VAR);  
  
  LCD_GotoXY(1,8);
  OPVAR_B := $1234;
  Print_Numero_16bit(OPCON_A);
  LCD_GotoXY(2,7);
  LCD_WriteChar('x');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,7);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_MULTIPLICAR_CON_VAR);
  
  LCD_GotoXY(1,15);
  OPVAR_B := $2564;
  Print_Numero_16bit(OPCON_A);
  LCD_GotoXY(2,14);
  LCD_WriteChar('x');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,14);
  LCD_WriteChar('=');
  Print_Numero_16bit(Math_16bits_MULTIPLICAR_CON_VAR);

// ----------------------
  delay_ms(3000);
  LCD_Clear;
 
  LCDPrint_MUL;
  LCD_WriteChar('3');
  LCD_WriteChar('2');
  LCD_WriteChar(' ');
  LCDPrint_VAR;
  LCD_WriteChar('x');
  LCDPrint_VAR;
  LCD_WriteChar(' ');
  LCD_WriteChar('1');
  LCD_WriteChar('6');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,5);
  OPVAR_A := $4321;
  OPVAR_B := $8765;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,4);
  LCD_WriteChar('x');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,0);
  LCD_WriteChar('=');
  Print_Numero_32bit(Math_16bitsTo32bits_MULTIPLICAR_VAR_VAR,_U,_E);
  
  LCD_GotoXY(1,16);
  OPVAR_A := $8889;
  OPVAR_B := $2222;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,15);
  LCD_WriteChar('x');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,11);
  LCD_WriteChar('=');
  Print_Numero_32bit(Math_16bitsTo32bits_MULTIPLICAR_VAR_VAR,_U,_E); 
// ----------------------
  delay_ms(3000);
  LCD_Clear;
 
  LCDPrint_MUL;
  LCD_WriteChar('3');
  LCD_WriteChar('2');
  LCD_WriteChar(' ');
  LCDPrint_VAR;
  LCD_WriteChar('x');
  LCDPrint_CON;
  LCD_WriteChar(' ');
  LCD_WriteChar('1');
  LCD_WriteChar('6');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,5);
  OPVAR_A := $4321;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,4);
  LCD_WriteChar('x');
  Print_Numero_16bit(OPCON_B);
  LCD_GotoXY(3,0);
  LCD_WriteChar('=');
  Print_Numero_32bit(Math_16bitsTo32bits_MULTIPLICAR_VAR_CON,_U,_E);
  
  LCD_GotoXY(1,16);
  OPVAR_A := $8889;
  Print_Numero_16bit(OPVAR_A);
  LCD_GotoXY(2,15);
  LCD_WriteChar('x');
  Print_Numero_16bit(OPCON_B);
  LCD_GotoXY(3,11);
  LCD_WriteChar('=');
  Print_Numero_32bit(Math_16bitsTo32bits_MULTIPLICAR_VAR_CON,_U,_E); 
  
  // ----------------------
  delay_ms(3000);
  LCD_Clear;
 
  LCDPrint_MUL;
  LCD_WriteChar('3');
  LCD_WriteChar('2');
  LCD_WriteChar(' ');
  LCDPrint_CON;
  LCD_WriteChar('x');
  LCDPrint_VAR;
  LCD_WriteChar(' ');
  LCD_WriteChar('1');
  LCD_WriteChar('6');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,5);
  OPVAR_B := $8765;
  Print_Numero_16bit(OPCON_A);
  LCD_GotoXY(2,4);
  LCD_WriteChar('x');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,0);
  LCD_WriteChar('=');
  Print_Numero_32bit(Math_16bitsTo32bits_MULTIPLICAR_CON_VAR,_U,_E);
  
  LCD_GotoXY(1,16);
  OPVAR_B := $2222;
  Print_Numero_16bit(OPCON_A);
  LCD_GotoXY(2,15);
  LCD_WriteChar('x');
  Print_Numero_16bit(OPVAR_B);
  LCD_GotoXY(3,11);
  LCD_WriteChar('=');
  Print_Numero_32bit(Math_16bitsTo32bits_MULTIPLICAR_CON_VAR,_U,_E); 

{  
// ----------------------  
  delay_ms(3000);
  LCD_Clear;
 
  LCDPrint_DIV;
  LCD_WriteChar(' ');
  LCDPrint_VAR;
  LCD_WriteChar('/');
  LCDPrint_VAR;
  LCD_WriteChar(' ');
  LCD_WriteChar('8');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,2);
  OPVAR_A := $CF;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,1);
  LCD_WriteChar('/');
  OPVAR_B :=$0A;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,2);
  Print_Numero_8bit(Math_8bits_DIVIDIR_VAR_VAR);
  
  LCD_GotoXY(1,7);
  OPVAR_A := $AA;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,6);
  LCD_WriteChar('/');
  OPVAR_B :=$55;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,7);
  Print_Numero_8bit(Math_8bits_DIVIDIR_VAR_VAR);
  
  LCD_GotoXY(1,12);
  OPVAR_A := $00;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,11);
  LCD_WriteChar('/');
  OPVAR_B :=$55;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,12);
  Print_Numero_8bit(Math_8bits_DIVIDIR_VAR_VAR);
  
  LCD_GotoXY(1,17);
  OPVAR_A := $33;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,16);
  LCD_WriteChar('/');
  OPVAR_B :=$0;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,17);
  Print_Numero_8bit(Math_8bits_DIVIDIR_VAR_VAR);
// ----------------------  
  delay_ms(3000);
  LCD_Clear;
 
  LCDPrint_DIV;
  LCD_WriteChar(' ');
  LCDPrint_VAR;
  LCD_WriteChar('/');
  LCDPrint_CONST;
  LCD_WriteChar(' ');
  LCD_WriteChar('8');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,2);
  OPVAR_A := $CF;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,1);
  LCD_WriteChar('/');
  Print_Numero_8bit(OPCON_B);
  LCD_GotoXY(3,2);
  Print_Numero_8bit(Math_8bits_DIVIDIR_VAR_CON);
  
  LCD_GotoXY(1,7);
  OPVAR_A := $AA;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,6);
  LCD_WriteChar('/');
  Print_Numero_8bit(OPCON_B);
  LCD_GotoXY(3,7);
  Print_Numero_8bit(Math_8bits_DIVIDIR_VAR_CON);
  
  LCD_GotoXY(1,12);
  OPVAR_A := $00;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,11);
  LCD_WriteChar('/');
  Print_Numero_8bit(OPCON_B);
  LCD_GotoXY(3,12);
  Print_Numero_8bit(Math_8bits_DIVIDIR_VAR_CON);
  
  LCD_GotoXY(1,17);
  OPVAR_A := $33;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,16);
  LCD_WriteChar('/');
  Print_Numero_8bit(OPCON_B);
  LCD_GotoXY(3,17);
  Print_Numero_8bit(Math_8bits_DIVIDIR_VAR_CON);
  
// ----------------------  
  delay_ms(3000);
  LCD_Clear;
 
  LCDPrint_DIV;
  LCD_WriteChar(' ');
  LCDPrint_CONST;
  LCD_WriteChar('/');
  LCDPrint_VAR;
  LCD_WriteChar(' ');
  LCD_WriteChar('8');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,2);
  Print_Numero_8bit(OPCON_A);
  LCD_GotoXY(2,1);
  LCD_WriteChar('/');  
  OPVAR_B := $2;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,2);
  Print_Numero_8bit(Math_8bits_DIVIDIR_CON_VAR);
  
  LCD_GotoXY(1,7);
  Print_Numero_8bit(OPCON_A);
  LCD_GotoXY(2,6);
  LCD_WriteChar('/'); 
  OPVAR_B := $3;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,7);
  Print_Numero_8bit(Math_8bits_DIVIDIR_CON_VAR);
  
  LCD_GotoXY(1,12);
  Print_Numero_8bit(OPCON_A);
  LCD_GotoXY(2,11);
  LCD_WriteChar('/'); 
  OPVAR_B := $04;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,12);
  Print_Numero_8bit(Math_8bits_DIVIDIR_CON_VAR);
  
  LCD_GotoXY(1,17);
  Print_Numero_8bit(OPCON_A);
  LCD_GotoXY(2,16);
  LCD_WriteChar('/'); 
  OPVAR_B := $00;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,17);
  Print_Numero_8bit(Math_8bits_DIVIDIR_CON_VAR);
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
  
  LCD_GotoXY(1,2);
  OPVAR_A := $CF;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,1);
  LCD_WriteChar('%');
  OPVAR_B :=$0A;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,2);
  Print_Numero_8bit(Math_8bits_MODULO_VAR_VAR);
  
  LCD_GotoXY(1,7);
  OPVAR_A := $AA;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,6);
  LCD_WriteChar('%');
  OPVAR_B :=$55;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,7);
  Print_Numero_8bit(Math_8bits_MODULO_VAR_VAR);
  
  LCD_GotoXY(1,12);
  OPVAR_A := $00;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,11);
  LCD_WriteChar('%');
  OPVAR_B :=$55;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,12);
  Print_Numero_8bit(Math_8bits_MODULO_VAR_VAR);
  
  LCD_GotoXY(1,17);
  OPVAR_A := $33;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,16);
  LCD_WriteChar('%');
  OPVAR_B :=$0;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,17);
  Print_Numero_8bit(Math_8bits_MODULO_VAR_VAR);
// ----------------------  
  delay_ms(3000);
  LCD_Clear;

  LCDPrint_MOD;
  LCD_WriteChar(' ');
  LCDPrint_VAR;
  LCD_WriteChar('%');
  LCDPrint_CONST;
  LCD_WriteChar(' ');
  LCD_WriteChar('8');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,2);
  OPVAR_A := $CF;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,1);
  LCD_WriteChar('%');
  Print_Numero_8bit(OPCON_B);
  LCD_GotoXY(3,2);
  Print_Numero_8bit(Math_8bits_MODULO_VAR_CON);
  
  LCD_GotoXY(1,7);
  OPVAR_A := $AA;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,6);
  LCD_WriteChar('%');
  Print_Numero_8bit(OPCON_B);
  LCD_GotoXY(3,7);
  Print_Numero_8bit(Math_8bits_MODULO_VAR_CON);
  
  LCD_GotoXY(1,12);
  OPVAR_A := $00;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,11);
  LCD_WriteChar('%');
  Print_Numero_8bit(OPCON_B);
  LCD_GotoXY(3,12);
  Print_Numero_8bit(Math_8bits_MODULO_VAR_CON);
  
  LCD_GotoXY(1,17);
  OPVAR_A := $33;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,16);
  LCD_WriteChar('%');
  Print_Numero_8bit(OPCON_B);
  LCD_GotoXY(3,17);
  Print_Numero_8bit(Math_8bits_MODULO_VAR_CON);
  
// ----------------------  
  delay_ms(3000);
  LCD_Clear;
 
  LCDPrint_MOD;
  LCD_WriteChar(' ');
  LCDPrint_CONST;
  LCD_WriteChar('%');
  LCDPrint_VAR;
  LCD_WriteChar(' ');
  LCD_WriteChar('8');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,2);
  Print_Numero_8bit(OPCON_A);
  LCD_GotoXY(2,1);
  LCD_WriteChar('%');  
  OPVAR_B := $2;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,2);
  Print_Numero_8bit(Math_8bits_MODULO_CON_VAR);
  
  LCD_GotoXY(1,7);
  Print_Numero_8bit(OPCON_A);
  LCD_GotoXY(2,6);
  LCD_WriteChar('%'); 
  OPVAR_B := $3;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,7);
  Print_Numero_8bit(Math_8bits_MODULO_CON_VAR);
  
  LCD_GotoXY(1,12);
  Print_Numero_8bit(OPCON_A);
  LCD_GotoXY(2,11);
  LCD_WriteChar('%'); 
  OPVAR_B := $04;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,12);
  Print_Numero_8bit(Math_8bits_MODULO_CON_VAR);
  
  LCD_GotoXY(1,17);
  Print_Numero_8bit(OPCON_A);
  LCD_GotoXY(2,16);
  LCD_WriteChar('%'); 
  OPVAR_B := $00;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,17);
  Print_Numero_8bit(Math_8bits_MODULO_CON_VAR);
  
  }
end. 




