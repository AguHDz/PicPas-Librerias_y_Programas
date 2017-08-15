{
FUNCIONES MATEMÁTICAS PARA INTEGRAR EN PICPAS

Nomenclatura usada:
@0,@1,@2 y @3 para los bytes de los operadores,
El registro W y las variables _H, _E, _U para el resultado,
los nombres OPVAR_A y OPVAR_B para los operadores,
OPCON_A y OPCON_B para las constantes,
y SYSTMP00, SYSTMP01,...SYSTMP?? para las variables temporales y contadores dentro de las funciones.
}

program Math_8bits_PicPas;

uses PIC16F877A, LCDLib_4bits;

const
OPCON = $01; 

var
OPVAR_A : byte;
OPVAR_B : byte;
SYSTMP00, SYSTMP01 : byte;

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
   ;W = OPVAR_A + OPCON  
 	  MOVWF   OPVAR_A
	  ADDLW   OPCON
  END
end;
// ... CONSTANTE + VARIABLE ...
procedure Math_8bits_SUMAR_CON_VAR  : byte;
begin
  ASM
  ;W = OPCON + OPVAR_A  
 	  MOVLW   OPCON
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
  ;W = OPVAR_A - OPCON  
 	  MOVF    OPVAR_A,W
	  SUBLW   OPCON
  END
end;
// ... CONSTANTE - VARIABLE ...
procedure Math_8bits_RESTAR_CON_VAR  : byte;
begin
  ASM
  ;W = OPCON - OPVAR_A  
 	  MOVLW  OPCON
	  SUBWF  OPVAR_A,W
  END
end;
// ---------------------------------------------------------------------------


// --- M U L T I P L I C A R -------------------------------------------------
// ... VARIABLE x VARIABLE ...
procedure Math_8bits_MULTIPLICAR_VAR_VAR  : byte;
begin
  ASM
  ;W = OPVAR_A x OPVAR_B 
  ;SYSTMP00 variable temporal contiene el resultado de la multiplicación. 
  
  ;SYSTMP00 = 0
	  clrf	  SYSTMP00
    
  MUL8_LOOP:
  ;Si OPVAR_B.0 = 1 entonces SYSTMP00 += OPVAR_A
	  btfss	  OPVAR_B,0
	  goto	  END_IF_1
	  movf	  OPVAR_A,W
	  addwf	  SYSTMP00,F

  END_IF_1:
  ;STATUS.C := 0
	  bcf	  STATUS,0
  ;Rotar OPVAR_B derecha
	  rrf	    OPVAR_B,F
  ;STATUS.C := 0
	  bcf	    STATUS,0
  ;Rotar OPVAR_A izquierda
	  rlf	    OPVAR_A,F
    
  ;Si OPVAR_B > 0 entonces goto MUL_LOOP
    MOVF    OPVAR_B,F
    btfss   STATUS,2
    goto    MUL8_LOOP     ;OPVAR_B > 0
    
    movf    SYSTMP00,W   ;Devuelve el resultado en el registro W.
  END
end;
// ... VARIABLE x CONSTANTE ...
procedure Math_8bits_MULTIPLICAR_VAR_CON  : byte;
begin
  ASM
  ;W = OPVAR_A x OPCON
  ;SYSTMP00 variable temporal contiene el resultado de la multiplicación. 
  
    MOVLW   OPCON
    MOVWF   OPVAR_B
    CALL    Math_8bits_MULTIPLICAR_VAR_VAR
  END
end;
// ... CONSTANTE x VARIABLE ... (RESULTADO 8 BITS)
procedure Math_8bits_MULTIPLICAR_CON_VAR  : byte;
begin
  ASM
  ;W = OPCON x OPVAR_B  
    MOVLW   OPCON
    MOVWF   OPVAR_A
    CALL    Math_8bits_MULTIPLICAR_VAR_VAR
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




