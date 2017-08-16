{
FUNCIONES MATEMÁTICAS PARA INTEGRAR EN PICPAS

Nomenclatura usada:
@0,@1,@2 y @3 para los bytes de los operandos,
El registro W y las variables _H, _E, _U para el resultado,
los nombres OPVAR_A y OPVAR_B para los operandos,
OPCON_A y OPCON_B para las constantes,
y SYSTMP00, SYSTMP01,...SYSTMP?? para las variables temporales y contadores dentro de las funciones.

Esta primera implementación solo incluye la posibilidad de insertar el código ensamblado INLINE.
En futuras versiones se podrá considerar la posibilidad de realizar llamadas a funciones de cálculo
optimizando el tamaño del código generado.
}

program Math_8bits_PicPas;

uses PIC16F877A, LCDLib_4bits;

const
OPCON_A = $01;
OPCON_B = $02; 

var
OPVAR_A : byte;
OPVAR_B : byte;
SYSTMP00, SYSTMP01 : byte;  // Variables axiliares para guardar valores temporales o contadores.

// Para pruebas del código generado
RESULTADO_W,RESULTADO_H,RESULTADO_E,RESULTADO_U : byte;

// OPERACIONES CON VARIABLES O CONSTANTES DE 8 BITS **********************
// --- S U M A R -------------------------------------------------------------
// ... VARIABLE + VARIABLE ...
procedure Math_8bits_SUMAR_VAR_VAR  : byte;
begin
  ASM
  ;W = OPVAR_A + OPVAR_B  
 	  MOVF  OPVAR_A,W
	  ADDWF OPVAR_B,W
  END
end;
// ... VARIABLE + CONSTANTE ...
procedure Math_8bits_SUMAR_VAR_CON  : byte;
begin
  ASM
   ;W = OPVAR_A + OPCON_B 
 	  MOVWF   OPVAR_A
	  ADDLW   OPCON_B
  END
end;
// ... CONSTANTE + VARIABLE ...
procedure Math_8bits_SUMAR_CON_VAR  : byte;
begin
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
  ASM
  ;W = OPVAR_A - OPVAR_B  
 	  MOVF    OPVAR_A,W
	  SUBWF   OPVAR_B,W
  END
end;
// ... VARIABLE - CONSTANTE ...
procedure Math_8bits_RESTAR_VAR_CON  : byte;
begin
  ASM
  ;W = OPVAR_A - OPCON_B
 	  MOVF    OPVAR_A,W
	  SUBLW   OPCON_B
  END
end;
// ... CONSTANTE - VARIABLE ...
procedure Math_8bits_RESTAR_CON_VAR  : byte;
begin
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
  ASM
  ;W = OPVAR_A x OPVAR_B 
  ;SYSTMP00 variable temporal. Contiene el resultado de la multiplicación. 
	  clrf	  SYSTMP00
  MUL8_LOOP:
	  btfss	  OPVAR_B,0   ;Si OPVAR_B.0 = 1 entonces SYSTMP00 += OPVAR_A
	  goto	  END_IF_1
	  movf	  OPVAR_A,W
	  addwf	  SYSTMP00,F
  END_IF_1:
	  bcf	    STATUS,0    ;STATUS.C := 0
	  rrf	    OPVAR_B,F
    bcf	    STATUS,0    ;STATUS.C := 0
	  rlf	    OPVAR_A,F  
    MOVF    OPVAR_B,F   ;Si OPVAR_B > 0 entonces goto MUL_LOOP
    btfss   STATUS,2
    goto    MUL8_LOOP    
    movf    SYSTMP00,W  ;Devuelve el resultado en el registro W.
  END
end;
// ... VARIABLE x CONSTANTE ...
procedure Math_8bits_MULTIPLICAR_VAR_CON  : byte;
begin
  ASM
  ;W = OPVAR_A x OPCON_B
  ;SYSTMP00 variable temporal. Contiene el resultado de la multiplicación.
  ;SYSTMP01 variable temporal. Contiene el operando constante OPCON_B.    
	  clrf	  SYSTMP00
    MOVLW   OPCON_B
    MOVWF   SYSTMP01
  MUL8_LOOP:
	  btfss	  SYSTMP01,0  ;Si OPCON_B.0 = 1 entonces SYSTMP00 += OPVAR_A
	  goto	  END_IF_1
	  movf	  OPVAR_A,W
	  addwf	  SYSTMP00,F
  END_IF_1:
	  bcf	    STATUS,0    ;STATUS.C := 0
	  rrf	    SYSTMP01,F
    bcf	    STATUS,0    ;STATUS.C := 0
	  rlf	    OPVAR_A,F  
    MOVF    SYSTMP01,F  ;Si OPCON_B > 0 entonces goto MUL_LOOP
    btfss   STATUS,2
    goto    MUL8_LOOP    
    movf    SYSTMP00,W  ;Devuelve el resultado en el registro W.
  END
end;
// ... CONSTANTE x VARIABLE ... (RESULTADO 8 BITS)
procedure Math_8bits_MULTIPLICAR_CON_VAR  : byte;
begin
  ASM
  ;W = OPCON_A x OPVAR_B  
  ;SYSTMP00 variable temporal. Contiene el resultado de la multiplicación. 
  ;SYSTMP01 variable temporal. Contiene el operando constante OPCON_A.
	  clrf	  SYSTMP00
    MOVLW   OPCON_A
    MOVWF   SYSTMP01
  MUL8_LOOP:
	  btfss	  OPVAR_B,0   ;Si OPVAR_B.0 = 1 entonces SYSTMP00 += OPVAR_A
	  goto	  END_IF_1
	  movf	  SYSTMP01,W
	  addwf	  SYSTMP00,F
  END_IF_1:
	  bcf	    STATUS,0    ;STATUS.C := 0
	  rrf	    OPVAR_B,F
    bcf	    STATUS,0    ;STATUS.C := 0
	  rlf	    SYSTMP01,F  
    MOVF    OPVAR_B,F   ;Si OPVAR_B > 0 entonces goto MUL_LOOP
    btfss   STATUS,2
    goto    MUL8_LOOP    
    movf    SYSTMP00,W  ;Devuelve el resultado en el registro W.
  END
end;
// ... CONSTANTE x VARIABLE ... (RESULTADO 16 BITS)
procedure Math_8bitsTo16bits_MULTIPLICAR_CON_VAR  : word;
begin
// PENDIENTE
end;
// ---------------------------------------------------------------------------


begin
// PENDIENTE  
end. 




