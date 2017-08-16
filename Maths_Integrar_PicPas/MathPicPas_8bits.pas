{  
*  (C) AguHDz 15-AGO-2017
*  Ultima Actualizacion: 16-AGO-2017
*  
*  Compilador PicPas v.0.7.3 (https://github.com/t-edson/PicPas)
*
*  FUNCIONES MATEMATICAS BASICAS PARA INTEGRAR EN PICPAS - 8 BITS
*  ==============================================================
*  Nomenclatura usada:
*  @0,@1,@2 y @3 para los bytes de los operandos,
*  El registro W y las variables _H, _E, _U para el resultado,
*  los nombres OPVAR_A y OPVAR_B para los operandos,
*  OPCON_A y OPCON_B para las constantes,
*  y SYSTMP00, SYSTMP01,...SYSTMP?? para las variables temporales y contadores dentro de las funciones.
*  
*  Esta primera implementación solo incluye la posibilidad de insertar el código ensamblado INLINE.
*  En futuras versiones se podrá considerar la posibilidad de realizar llamadas a funciones de cálculo
*  optimizando el tamaño del código generado.
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
OPCON_A_L = $8F;
OPCON_A_H = $00;
OPCON_A_E = $00;
OPCON_A_U = $00;
OPCON_A   = OPCON_A_L;
OPCON_B_L = $33;
OPCON_B_H = $00;
OPCON_B_E = $00;
OPCON_B_U = $00;
OPCON_B   = OPCON_B_L;

var
// Operandos tipo variable.
OPVAR_A_L : byte absolute $0050;
OPVAR_A_H : byte absolute $0051;
OPVAR_A_E : byte absolute $0052;
OPVAR_A_U : byte absolute $0053;
OPVAR_B_L : byte absolute $0054;
OPVAR_B_H : byte absolute $0055;
OPVAR_B_E : byte absolute $0056;
OPVAR_B_U : byte absolute $0057;
OPVAR_A   : byte absolute OPVAR_A_L;
OPVAR_B   : byte absolute OPVAR_B_L;
// Variables axiliares para guardar valores temporales o contadores.
SYSTMP00  : byte absolute $0060;
SYSTMP01  : byte absolute $0061;
SYSTMP02  : byte absolute $0062;
SYSTMP03  : byte absolute $0062;

// Para pruebas del código generado
//RESULTADO_W,RESULTADO_H,RESULTADO_E,RESULTADO_U : byte;

// OPERACIONES CON VARIABLES O CONSTANTES DE 8 BITS **********************
// --- S U M A R -------------------------------------------------------------
// ... VARIABLE + VARIABLE ...
procedure Math_8bits_SUMAR_VAR_VAR  : byte;
begin
  SetBank(0);
  ASM
  ;W = OPVAR_A + OPVAR_B  
    MOVF  OPVAR_A,W
    ADDWF OPVAR_B,W
  END
end;
// ... VARIABLE + CONSTANTE ...
procedure Math_8bits_SUMAR_VAR_CON  : byte;
begin
  SetBank(0);
  ASM
   ;W = OPVAR_A + OPCON_B 
    MOVWF   OPVAR_A
    ADDLW   OPCON_B
  END
end;
// ... CONSTANTE + VARIABLE ...
procedure Math_8bits_SUMAR_CON_VAR  : byte;
begin
  SetBank(0);
  ASM
  ;W = OPCON + OPVAR_A  
    MOVLW   OPCON_B
    ADDWF   OPVAR_A,W
  END
end;
// ---------------------------------------------------------------------------

// --- R E S T A R -----------------------------------------------------------
// ... VARIABLE - VARIABLE ...
procedure Math_8bits_RESTAR_VAR_VAR  : byte;
begin
  SetBank(0);
  ASM
  ;W = OPVAR_A - OPVAR_B  
    MOVF    OPVAR_A,W
    SUBWF   OPVAR_B,W
  END
end;
// ... VARIABLE - CONSTANTE ...
procedure Math_8bits_RESTAR_VAR_CON  : byte;
begin
  SetBank(0);
  ASM
  ;W = OPVAR_A - OPCON_B
    MOVF    OPVAR_A,W
    SUBLW   OPCON_B
  END
end;
// ... CONSTANTE - VARIABLE ...
procedure Math_8bits_RESTAR_CON_VAR  : byte;
begin
  SetBank(0);
  ASM
  ;W = OPCON_A - OPVAR_B  
    MOVLW  OPCON_A
    SUBWF  OPVAR_B,W
  END
end;
// ---------------------------------------------------------------------------


// --- M U L T I P L I C A R -------------------------------------------------
// ... VARIABLE x VARIABLE ...
procedure Math_8bits_MULTIPLICAR_VAR_VAR  : byte;
begin
  SetBank(0);
  ASM
  ;W = OPVAR_A x OPVAR_B 
  ;SYSTMP00 variable temporal. Contiene el resultado de la multiplicación. 
    CLRF    SYSTMP00
  MUL8_LOOP:
    BTFSS   OPVAR_B,0   ;Si OPVAR_B.0 = 1 entonces SYSTMP00 += OPVAR_A
    GOTO    END_IF_1
    MOVF    OPVAR_A,W
    ADDWF   SYSTMP00,F
  END_IF_1:
    BCF     STATUS,0    ;STATUS.C := 0
    RRF     OPVAR_B,F
    BCF     STATUS,0    ;STATUS.C := 0
    RLF     OPVAR_A,F  
    MOVF    OPVAR_B,F   ;Si OPVAR_B > 0 entonces goto MUL_LOOP
    BTFSS   STATUS,2
    GOTO    MUL8_LOOP    
    MOVF    SYSTMP00,W  ;Devuelve el resultado en el registro W.
  END
end;
// ... VARIABLE x CONSTANTE ...
procedure Math_8bits_MULTIPLICAR_VAR_CON  : byte;
begin
  SetBank(0);
{
// CODIFICACION ALTERNATIVA LLAMANDO A LA FUNCION Math_8bits_MULTIPLICAR_VAR_VAR
ASM
    MOVLW   OPCON_B
    MOVWF   OPVAR_B
    CALL    Math_8bits_MULTIPLICAR_VAR_VAR
END
}
  ASM
  ;W = OPVAR_A x OPCON_B
  ;SYSTMP00 variable temporal. Contiene el resultado de la multiplicación.
  ;SYSTMP01 variable temporal. Contiene el operando constante OPCON_B.    
    CLRF    SYSTMP00
    MOVLW   OPCON_B
    MOVWF   SYSTMP01
  MUL8_LOOP:
    BTFSS   SYSTMP01,0  ;Si OPCON_B.0 = 1 entonces SYSTMP00 += OPVAR_A
    GOTO    END_IF_1
    MOVF    OPVAR_A,W
    ADDWF   SYSTMP00,F
  END_IF_1:
    BCF     STATUS,0    ;STATUS.C := 0
    RRF     SYSTMP01,F
    BCF     STATUS,0    ;STATUS.C := 0
    RLF     OPVAR_A,F  
    MOVF    SYSTMP01,F  ;Si OPCON_B > 0 entonces goto MUL_LOOP
    BTFSS   STATUS,2
    GOTO    MUL8_LOOP    
    MOVF    SYSTMP00,W  ;Devuelve el resultado en el registro W.
  END
end;
// ... CONSTANTE x VARIABLE ... (RESULTADO 8 BITS)
procedure Math_8bits_MULTIPLICAR_CON_VAR : byte;
begin
  SetBank(0);
{
// CODIFICACION ALTERNATIVA LLAMANDO A LA FUNCION Math_8bits_MULTIPLICAR_VAR_VAR
ASM
    MOVLW   OPCON_A
    MOVWF   OPVAR_A
    CALL    Math_8bits_MULTIPLICAR_VAR_VAR
END
}
  ASM
  ;W = OPCON_A x OPVAR_B  
  ;SYSTMP00 variable temporal. Contiene el resultado de la multiplicación. 
  ;SYSTMP01 variable temporal. Contiene el operando constante OPCON_A.
    CLRF    SYSTMP00
    MOVLW   OPCON_A
    MOVWF   SYSTMP01
  MUL8_LOOP:
    BTFSS   OPVAR_B,0   ;Si OPVAR_B.0 = 1 entonces SYSTMP00 += OPVAR_A
    GOTO    END_IF_1
    MOVF    SYSTMP01,W
    ADDWF   SYSTMP00,F
  END_IF_1:
    BCF	    STATUS,0    ;STATUS.C := 0
    RRF	    OPVAR_B,F
    BCF	    STATUS,0    ;STATUS.C := 0
    RLF	    SYSTMP01,F  
    MOVF    OPVAR_B,F   ;Si OPVAR_B > 0 entonces goto MUL_LOOP
    BTFSS   STATUS,2
    GOTO    MUL8_LOOP    
    MOVF    SYSTMP00,W  ;Devuelve el resultado en el registro W.
  END
end;
// ... VARIABLE x VARIABLE ... (RESULTADO 16 BITS)
procedure Math_8bitsTo16bits_MULTIPLICAR_VAR_VAR : word;
begin
  SetBank(0);
  ASM
  ;[W_H] = OPVAR_A / OPVAR_B 
  ;SYSTMP00 variable temporal. Contiene el resultado de la multiplicación. 
  ;SYSTMP01 variable temporal. Contiene la parte alta del operando A (inicialmente cero).
  ;SYSTMP02 variable temporal. Contiene la parte alta del operando B (inicialmente cero).
    CLRF    SYSTMP00
    CLRF    _H
    CLRF    SYSTMP01    ;OPVAR_A_H
    CLRF    SYSTMP02    ;OPVAR_B_H
    
  MUL16_LOOP:
    BTFSS   OPVAR_B,0   ;Si OPVAR_B.0 = 1 entonces SYSTMP00 += OPVAR_A
    GOTO    END_IF_1
    MOVF    OPVAR_A,W
    ADDWF   SYSTMP00,F
    MOVF    SYSTMP01,W
    BTFSC   STATUS,0    ;Si no Carry
    ADDLW   1
    ADDWF   _H,F
  END_IF_1:
    BCF     STATUS,0    ;STATUS.C := 0
    RRF     SYSTMP02,F
    RRF     OPVAR_B,F
    BCF     STATUS,0    ;STATUS.C := 0
    RLF     OPVAR_A,F 
    RLF     SYSTMP01,F 
    MOVF    OPVAR_B,W   ;Si OPVAR_B > 0 entonces goto MUL_LOOP
    IORWF   SYSTMP02,W
    BTFSS   STATUS,2    ;Si Zero
    GOTO    MUL16_LOOP   
    MOVF    SYSTMP00,W  ;Devuelve el resultado en el registro W.
  END
end;
// ... VARIABLE x CONSTANTE ... (RESULTADO 16 BITS)
procedure Math_8bitsTo16bits_MULTIPLICAR_VAR_CON : word;
begin
  SetBank(0);
{
// CODIFICACION ALTERNATIVA LLAMANDO A LA FUNCION Math_8bitsTo16bits_MULTIPLICAR_VAR_VAR
ASM
    MOVLW   OPCON_B
    MOVWF   OPVAR_B
    CALL    Math_8bitsTo16bits_MULTIPLICAR_VAR_VAR
END
}
  ASM
  ;[W_H] = OPVAR_A / OPCON_B 
  ;SYSTMP00 variable temporal. Contiene el resultado de la multiplicación.
  ;SYSTMP01 variable temporal. Contiene la parte baja del operando B (inicialmente IPCON_B).
  ;SYSTMP02 variable temporal. Contiene la parte alta del operando A (inicialmente cero).
  ;SYSTMP03 variable temporal. Contiene la parte alta del operando B (inicialmente cero).
    MOVLW   OPCON_B
    MOVWF   SYSTMP01

    CLRF    SYSTMP00
    CLRF    _H
    CLRF    SYSTMP02    ;OPVAR_A_H
    CLRF    SYSTMP03    ;OPVAR_B_H
        
  MUL16_LOOP:
    BTFSS   SYSTMP01,0   ;Si SYSTMP01.0 = 1 entonces SYSTMP00 += OPVAR_A
    GOTO    END_IF_1
    MOVF    OPVAR_A,W
    ADDWF   SYSTMP00,F
    MOVF    SYSTMP02,W
    BTFSC   STATUS,0    ;Si no Carry
    ADDLW   1
    ADDWF   _H,F
  END_IF_1:
    BCF     STATUS,0    ;STATUS.C := 0
    RRF     SYSTMP03,F
    RRF     SYSTMP01,F
    BCF     STATUS,0    ;STATUS.C := 0
    RLF     OPVAR_A,F 
    RLF     SYSTMP02,F 
    MOVF    SYSTMP01,W   ;Si SYSTMP01 > 0 entonces goto MUL_LOOP
    IORWF   SYSTMP03,W
    BTFSS   STATUS,2    ;Si Zero
    GOTO    MUL16_LOOP   
    MOVF    SYSTMP00,W  ;Devuelve el resultado en el registro W.
  END
end;
// ... CONSTANTE x VARIABLE ... (RESULTADO 16 BITS)
procedure Math_8bitsTo16bits_MULTIPLICAR_CON_VAR : word;
begin
  SetBank(0);
{
// CODIFICACION ALTERNATIVA LLAMANDO A LA FUNCION Math_8bitsTo16bits_MULTIPLICAR_VAR_VAR
ASM
    MOVLW   OPCON_A
    MOVWF   OPVAR_A
    CALL    Math_8bitsTo16bits_MULTIPLICAR_VAR_VAR
END
}
  ASM
  ;[W_H] = OPCON_A / OPVAR_B 
  ;SYSTMP00 variable temporal. Contiene el resultado de la multiplicación. 
  ;SYSTMP01 variable temporal. Contiene la parte baja del operando B (inicialmente IPCON_A).
  ;SYSTMP02 variable temporal. Contiene la parte alta del operando A (inicialmente cero).
  ;SYSTMP03 variable temporal. Contiene la parte alta del operando B (inicialmente cero).
    MOVLW   OPCON_A
    MOVWF   SYSTMP01

    CLRF    SYSTMP00
    CLRF    _H
    CLRF    SYSTMP02    ;OPVAR_A_H
    CLRF    SYSTMP03    ;OPVAR_B_H
        
  MUL16_LOOP:
    BTFSS   OPVAR_B,0   ;Si OPVAR_B.0 = 1 entonces SYSTMP00 += SYSTMP01
    GOTO    END_IF_1
    MOVF    SYSTMP01,W
    ADDWF   SYSTMP00,F
    MOVF    SYSTMP02,W
    BTFSC   STATUS,0    ;Si no Carry
    ADDLW   1
    ADDWF   _H,F
  END_IF_1:
    BCF     STATUS,0    ;STATUS.C := 0
    RRF     SYSTMP03,F
    RRF     OPVAR_B,F
    BCF     STATUS,0    ;STATUS.C := 0
    RLF     SYSTMP01,F 
    RLF     SYSTMP02,F 
    MOVF    OPVAR_B,W   ;Si OPVAR_B > 0 entonces goto MUL_LOOP
    IORWF   SYSTMP03,W
    BTFSS   STATUS,2    ;Si Zero
    GOTO    MUL16_LOOP   
    MOVF    SYSTMP00,W  ;Devuelve el resultado en el registro W.
  END
end;
// ---------------------------------------------------------------------------

// --- M O D U L O -------------------------------------------------
// ... VARIABLE x VARIABLE ...
procedure Math_8bits_MODULO_VAR_VAR : byte;
begin
  SetBank(0);
  ASM
  ;W = OPVAR_A x OPVAR_B 
  ;SYSTMP00 variable temporal. Contiene el resto (modulo) de la división. 
  ;SYSTMP01 variable temporal. Contador de bucle de división.
    CLRF    SYSTMP00    ;Resto (modulo) de la división.
    MOVF    OPVAR_B,F
    BTFSS   STATUS,2    ;Si Zero
    GOTO    SEGUIR      ;Divisor > 0
  ;Si divisor = 0 divuelve el número maximo posible ($FF=infinito)
  ;Tambien se podría activar flag de ERROR de DIVISION POR CERO.
  ;El resto de la división contendrá el valor inicial = 0.
    MOVLW   $FF
    RETURN
  SEGUIR:
    MOVLW   8           ;Número de 8 bits.
    MOVWF   SYSTMP01
  DIV_START:
    RLF     OPVAR_A,F
    RLF     SYSTMP00,F
    MOVF    OPVAR_B,W
    SUBWF   SYSTMP00,F
    BSF     OPVAR_A,0
    BTFSC   STATUS,0    ;Carry := 1
    GOTO    SIGUIENTE
    BCF     OPVAR_A,0
    MOVF    OPVAR_B,W 
    ADDWF   SYSTMP00,F
  SIGUIENTE:
    DECFSZ  SYSTMP01,F
    GOTO    DIV_START
    MOVF    SYSTMP00,W   ;Devuelve el resultado en el registro W.
  END
end;
// ... VARIABLE x CONSTANTE ...
procedure Math_8bits_MODULO_VAR_CON : byte;
begin
  SetBank(0);
  ASM
  ;W = OPVAR_A x OPCON_B 
  ;SYSTMP00 variable temporal. Contiene el resto (modulo) de la división.
  ;SYSTMP01 variable temporal. Contador de bucle de división.
    CLRF    SYSTMP00    ;Resto (modulo) de la división.
    MOVLW   OPCON_B
    SUBLW   $00
    BTFSS   STATUS,2    ;Si Zero
    GOTO    SEGUIR      ;Divisor > 0
  ;Si divisor = 0 divuelve el número maximo posible ($FF=infinito)
  ;Tambien se podría activar flag de ERROR de DIVISION POR CERO.
  ;El resto de la división contendrá el valor inicial = 0.
    MOVLW   $FF
    RETURN
  SEGUIR:
    MOVLW   8           ;Número de 8 bits.
    MOVWF   SYSTMP01
  DIV_START:
    RLF     OPVAR_A,F
    RLF     SYSTMP00,F
    MOVLW   OPCON_B
    SUBWF   SYSTMP00,F
    BSF     OPVAR_A,0
    BTFSC   STATUS,0    ;Carry := 1
    GOTO    SIGUIENTE
    BCF     OPVAR_A,0
    MOVLW   OPCON_B 
    ADDWF   SYSTMP00,F
  SIGUIENTE:
    DECFSZ  SYSTMP01,F
    GOTO    DIV_START
    MOVF    SYSTMP00,W   ;Devuelve el resultado en el registro W.
  END
end;

// ... VARIABLE x VARIABLE ...
procedure Math_8bits_MODULO_CON_VAR : byte;
begin
  SetBank(0);
  ASM
  ;W = OPCON_A x OPVAR_B 
  ;SYSTMP00 variable temporal. Contiene el resto (modulo) de la división.
  ;SYSTMP01 variable temporal. Contador de bucle de división.
  ;SYSTMP02 variable temporal. Contiene el operador A.
    CLRF    SYSTMP00    ;Resto (modulo) de la división.
    MOVF    OPVAR_B,F
    BTFSS   STATUS,2    ;Si Zero
    GOTO    SEGUIR      ;Divisor > 0
  ;Si divisor = 0 divuelve el número maximo posible ($FF=infinito)
  ;Tambien se podría activar flag de ERROR de DIVISION POR CERO.
  ;El resto de la división contendrá el valor inicial = 0.
    MOVLW   $FF
    RETURN
  SEGUIR:
    MOVLW   8           ;Número de 8 bits.
    MOVWF   SYSTMP01
    MOVLW   OPCON_A
    MOVWF   SYSTMP02
  DIV_START:
    RLF     SYSTMP02,F
    RLF     SYSTMP00,F
    MOVF    OPVAR_B,W
    SUBWF   SYSTMP00,F
    BSF     SYSTMP02,0
    BTFSC   STATUS,0    ;Carry := 1
    GOTO    SIGUIENTE
    BCF     SYSTMP02,0
    MOVF    OPVAR_B,W 
    ADDWF   SYSTMP00,F
  SIGUIENTE:
    DECFSZ  SYSTMP01,F
    GOTO    DIV_START
    MOVF    SYSTMP00,W   ;Devuelve el resultado en el registro W.
  END
end;
// ---------------------------------------------------------------------------

// --- D I V I D I R -------------------------------------------------
// ... VARIABLE x VARIABLE ...
procedure Math_8bits_DIVIDIR_VAR_VAR : byte;
begin
  SetBank(0);
  ASM
  ;W = OPVAR_A x OPVAR_B 
  ;SYSTMP00 variable temporal. Contiene el resto (modulo) de la división.. 
  ;SYSTMP01 variable temporal. Contador de bucle de división.
    CLRF    SYSTMP00    ;Resto (modulo) de la división.
    MOVF    OPVAR_B,F
    BTFSS   STATUS,2    ;Si Zero
    GOTO    SEGUIR      ;Divisor > 0
  ;Si divisor = 0 divuelve el número maximo posible ($FF=infinito)
  ;Tambien se podría activar flag de ERROR de DIVISION POR CERO.
  ;El resto de la división contendrá el valor inicial = 0.
    MOVLW   $FF
    RETURN
  SEGUIR:
    MOVLW   8           ;Número de 8 bits.
    MOVWF   SYSTMP01
  DIV_START:
    RLF     OPVAR_A,F
    RLF     SYSTMP00,F
    MOVF    OPVAR_B,W
    SUBWF   SYSTMP00,F
    BSF     OPVAR_A,0
    BTFSC   STATUS,0    ;Carry := 1
    GOTO    SIGUIENTE
    BCF     OPVAR_A,0
    MOVF    OPVAR_B,W 
    ADDWF   SYSTMP00,F
  SIGUIENTE:
    DECFSZ  SYSTMP01,F
    GOTO    DIV_START
    MOVF    OPVAR_A,W   ;Devuelve el resultado en el registro W.
  END
end;
// ... VARIABLE x CONSTANTE ...
procedure Math_8bits_DIVIDIR_VAR_CON : byte;
begin
  SetBank(0);
  ASM
  ;W = OPVAR_A x OPCON_B 
  ;SYSTMP00 variable temporal. Contiene el resto (modulo) de la división. 
  ;SYSTMP01 variable temporal. Contador de bucle de división.
    CLRF    SYSTMP00    ;Resto (modulo) de la división.
    MOVLW   OPCON_B
    SUBLW   $00
    BTFSS   STATUS,2    ;Si Zero
    GOTO    SEGUIR      ;Divisor > 0
  ;Si divisor = 0 divuelve el número maximo posible ($FF=infinito)
  ;Tambien se podría activar flag de ERROR de DIVISION POR CERO.
  ;El resto de la división contendrá el valor inicial = 0.
    MOVLW   $FF
    RETURN
  SEGUIR:
    MOVLW   8           ;Número de 8 bits.
    MOVWF   SYSTMP01
  DIV_START:
    RLF     OPVAR_A,F
    RLF     SYSTMP00,F
    MOVLW   OPCON_B
    SUBWF   SYSTMP00,F
    BSF     OPVAR_A,0
    BTFSC   STATUS,0    ;Carry := 1
    GOTO    SIGUIENTE
    BCF     OPVAR_A,0
    MOVLW   OPCON_B 
    ADDWF   SYSTMP00,F
  SIGUIENTE:
    DECFSZ  SYSTMP01,F
    GOTO    DIV_START
    MOVF    OPVAR_A,W   ;Devuelve el resultado en el registro W.
  END
end;

// ... VARIABLE x VARIABLE ...
procedure Math_8bits_DIVIDIR_CON_VAR : byte;
begin
  SetBank(0);
  ASM
  ;W = OPCON_A x OPVAR_B 
  ;SYSTMP00 variable temporal. Contiene el resto (modulo) de la división.
  ;SYSTMP01 variable temporal. Contador de bucle de división.
  ;SYSTMP02 variable temporal. Contiene el operador A.
    CLRF    SYSTMP00    ;Resto (modulo) de la división.
    MOVF    OPVAR_B,F
    BTFSS   STATUS,2    ;Si Zero
    GOTO    SEGUIR      ;Divisor > 0
  ;Si divisor = 0 divuelve el número maximo posible ($FF=infinito)
  ;Tambien se podría activar flag de ERROR de DIVISION POR CERO.
  ;El resto de la división contendrá el valor inicial = 0.
    MOVLW   $FF
    RETURN
  SEGUIR:
    MOVLW   8           ;Número de 8 bits.
    MOVWF   SYSTMP01
    MOVLW   OPCON_A
    MOVWF   SYSTMP02
  DIV_START:
    RLF     SYSTMP02,F
    RLF     SYSTMP00,F
    MOVF    OPVAR_B,W
    SUBWF   SYSTMP00,F
    BSF     SYSTMP02,0
    BTFSC   STATUS,0    ;Carry := 1
    GOTO    SIGUIENTE
    BCF     SYSTMP02,0
    MOVF    OPVAR_B,W 
    ADDWF   SYSTMP00,F
  SIGUIENTE:
    DECFSZ  SYSTMP01,F
    GOTO    DIV_START
    MOVF    SYSTMP02,W   ;Devuelve el resultado en el registro W.
  END
end;
// ---------------------------------------------------------------------------
procedure LCDPrint_SUMAR;
begin
  LCD_WriteChar('S');
  LCD_WriteChar('u');
  LCD_WriteChar('m');
  LCD_WriteChar('a');
  LCD_WriteChar('r');
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
   
// Demostración de uso de operaciones con variables de 16 bits

// ----------------------
  LCDPrint_MUL;
  LCD_WriteChar(' ');
  LCDPrint_VAR;
  LCD_WriteChar('x');
  LCDPrint_VAR;
  LCD_WriteChar(' ');
  LCD_WriteChar('8');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,1);
  OPVAR_A := $0F;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,0);
  LCD_WriteChar('x');
  OPVAR_B :=$0A;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,0);
  LCD_WriteChar('=');
  Print_Numero_8bit(Math_8bits_MULTIPLICAR_VAR_VAR);
  
  LCD_GotoXY(1,6);
  OPVAR_A := $0A;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,5);
  LCD_WriteChar('x');
  OPVAR_B :=$0F;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,5);
  LCD_WriteChar('=');
  Print_Numero_8bit(Math_8bits_MULTIPLICAR_VAR_VAR);
  
  LCD_GotoXY(1,11);
  OPVAR_A := $55;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,10);
  LCD_WriteChar('x');
  OPVAR_B :=$02;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,10);
  LCD_WriteChar('=');
  Print_Numero_8bit(Math_8bits_MULTIPLICAR_VAR_VAR);
  
  LCD_GotoXY(1,16);
  OPVAR_A := $33;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,15);
  LCD_WriteChar('x');
  OPVAR_B :=$0;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,15);
  LCD_WriteChar('=');
  Print_Numero_8bit(Math_8bits_MULTIPLICAR_VAR_VAR);
// ----------------------  
  delay_ms(3000);
  LCD_Clear;
  
  LCDPrint_MUL;
  LCD_WriteChar(' ');
  LCDPrint_VAR;
  LCD_WriteChar('x');
  LCDPrint_CONST;
  LCD_WriteChar(' ');
  LCD_WriteChar('8');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,1);
  OPVAR_A :=$0A;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,0);
  LCD_WriteChar('x');
  Print_Numero_8bit(OPCON_B);
  LCD_GotoXY(3,0);
  LCD_WriteChar('=');
  Print_Numero_8bit(Math_8bits_MULTIPLICAR_VAR_CON);
  
  LCD_GotoXY(1,6);
  OPVAR_A :=$0F;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,5);
  LCD_WriteChar('x');
  Print_Numero_8bit(OPCON_B);
  LCD_GotoXY(3,5);
  LCD_WriteChar('=');
  Print_Numero_8bit(Math_8bits_MULTIPLICAR_VAR_CON);
  
  LCD_GotoXY(1,11);
  OPVAR_A :=$FF;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,10);
  LCD_WriteChar('x');
  Print_Numero_8bit(OPCON_B);
  LCD_GotoXY(3,10);
  LCD_WriteChar('=');
  Print_Numero_8bit(Math_8bits_MULTIPLICAR_VAR_CON);
  
  LCD_GotoXY(1,16);
  OPVAR_A :=$02;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,15);
  LCD_WriteChar('x');
  Print_Numero_8bit(OPCON_B);
  LCD_GotoXY(3,15);
  LCD_WriteChar('=');
  Print_Numero_8bit(Math_8bits_MULTIPLICAR_VAR_CON);
// ----------------------  
  delay_ms(3000);
  LCD_Clear;
  
  LCDPrint_MUL;
  LCD_WriteChar(' ');
  LCDPrint_CONST;
  LCD_WriteChar('x');
  LCDPrint_VAR;
  LCD_WriteChar(' ');
  LCD_WriteChar('8');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,1);
  Print_Numero_8bit(OPCON_A);
  LCD_GotoXY(2,0);
  LCD_WriteChar('x');
  OPVAR_B :=$0A;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,0);
  LCD_WriteChar('=');
  Print_Numero_8bit(Math_8bits_MULTIPLICAR_CON_VAR);
  
  LCD_GotoXY(1,6);
  Print_Numero_8bit(OPCON_A);
  LCD_GotoXY(2,5);
  LCD_WriteChar('x');
  OPVAR_B :=$0F;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,5);
  LCD_WriteChar('=');
  Print_Numero_8bit(Math_8bits_MULTIPLICAR_CON_VAR);
  
  LCD_GotoXY(1,11);
  Print_Numero_8bit(OPCON_A);
  LCD_GotoXY(2,10);
  LCD_WriteChar('x');
  OPVAR_B :=$FF;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,10);
  LCD_WriteChar('=');
  Print_Numero_8bit(Math_8bits_MULTIPLICAR_CON_VAR);
  
  LCD_GotoXY(1,16);
  Print_Numero_8bit(OPCON_A);
  LCD_GotoXY(2,15);
  LCD_WriteChar('x');  
  OPVAR_B :=$02;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,15);
  LCD_WriteChar('=');
  Print_Numero_8bit(Math_8bits_MULTIPLICAR_CON_VAR);
// ----------------------  
  delay_ms(3000);
  LCD_Clear;
  
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
  
  LCD_GotoXY(1,2);
  OPVAR_A := $1F;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,1);
  LCD_WriteChar('x');
  OPVAR_B :=$0A;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,0);
  Print_Numero_16bit(Math_8bitsTo16bits_MULTIPLICAR_VAR_VAR);
  
  LCD_GotoXY(1,7);
  OPVAR_A := $0A;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,6);
  LCD_WriteChar('x');
  OPVAR_B :=$1F;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,5);
  Print_Numero_16bit(Math_8bitsTo16bits_MULTIPLICAR_VAR_VAR);
  
  LCD_GotoXY(1,12);
  OPVAR_A := $55;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,11);
  LCD_WriteChar('x');
  OPVAR_B :=$AA;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,10);
  Print_Numero_16bit(Math_8bitsTo16bits_MULTIPLICAR_VAR_VAR);
  
  LCD_GotoXY(1,17);
  OPVAR_A := $33;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,16);
  LCD_WriteChar('x');
  OPVAR_B :=$0;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,15);
  Print_Numero_16bit(Math_8bitsTo16bits_MULTIPLICAR_VAR_VAR);
// ----------------------  
  delay_ms(3000);
  LCD_Clear;
 
  LCDPrint_MUL;
  LCD_WriteChar('1');
  LCD_WriteChar('6');
  LCD_WriteChar(' ');
  LCDPrint_VAR;
  LCD_WriteChar('x');
  LCDPrint_CONST;
  LCD_WriteChar(' ');
  LCD_WriteChar('8');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,2);
  OPVAR_A := $EF;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,1);
  LCD_WriteChar('x');
  Print_Numero_8bit(OPCON_B);
  LCD_GotoXY(3,0);
  Print_Numero_16bit(Math_8bitsTo16bits_MULTIPLICAR_VAR_CON);
  
  LCD_GotoXY(1,7);
  OPVAR_A := $0A;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,6);
  LCD_WriteChar('x');
  Print_Numero_8bit(OPCON_B);
  LCD_GotoXY(3,5);
  Print_Numero_16bit(Math_8bitsTo16bits_MULTIPLICAR_VAR_CON);
  
  LCD_GotoXY(1,12);
  OPVAR_A := $55;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,11);
  LCD_WriteChar('x');
  Print_Numero_8bit(OPCON_B);
  LCD_GotoXY(3,10);
  Print_Numero_16bit(Math_8bitsTo16bits_MULTIPLICAR_VAR_CON);
  
  LCD_GotoXY(1,17);
  OPVAR_A := $33;
  Print_Numero_8bit(OPVAR_A);
  LCD_GotoXY(2,16);
  LCD_WriteChar('x');
  Print_Numero_8bit(OPCON_B);
  LCD_GotoXY(3,15);
  Print_Numero_16bit(Math_8bitsTo16bits_MULTIPLICAR_VAR_CON);
// ----------------------  
  delay_ms(3000);
  LCD_Clear;  

  LCDPrint_MUL;
  LCD_WriteChar('1');
  LCD_WriteChar('6');
  LCD_WriteChar(' ');
  LCDPrint_CONST;
  LCD_WriteChar('x');
  LCDPrint_VAR;
  LCD_WriteChar(' ');
  LCD_WriteChar('8');
  LCDPrint_BIT;
  
  LCD_GotoXY(1,2);
  Print_Numero_8bit(OPCON_A);
  LCD_GotoXY(2,1);
  LCD_WriteChar('x');
  OPVAR_B := $EF;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,0);
  Print_Numero_16bit(Math_8bitsTo16bits_MULTIPLICAR_CON_VAR);
  
  LCD_GotoXY(1,7);
  Print_Numero_8bit(OPCON_A);
  LCD_GotoXY(2,6);
  LCD_WriteChar('x');
  OPVAR_B := $0A;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,5);
  Print_Numero_16bit(Math_8bitsTo16bits_MULTIPLICAR_CON_VAR);
  
  LCD_GotoXY(1,12);
  Print_Numero_8bit(OPCON_A);
  LCD_GotoXY(2,11);
  LCD_WriteChar('x');
  OPVAR_B := $55;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,10);
  Print_Numero_16bit(Math_8bitsTo16bits_MULTIPLICAR_CON_VAR);
  
  LCD_GotoXY(1,17);
  Print_Numero_8bit(OPCON_A);
  LCD_GotoXY(2,16);
  LCD_WriteChar('x');
  OPVAR_B := $33;
  Print_Numero_8bit(OPVAR_B);
  LCD_GotoXY(3,15);
  Print_Numero_16bit(Math_8bitsTo16bits_MULTIPLICAR_CON_VAR);
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
end. 




