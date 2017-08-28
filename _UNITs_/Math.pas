{
  (C) AguHDz 18-JUL-2017
  Ultima Actualizacion: 25-AGO-2017

  Compilador PicPas v.0.7.4 (https://github.com/t-edson/PicPas)

  LIBRERIA DE FUNCIONES MATEMATICAS OPTIMIZADAS
  =============================================
  Las funciones mantemáticas de esta librería complementan a las existes
  en el compilador. Algunas no se encuentran implementadas, como las
  operaciones con números de 64 bits. Otras si están ya implementadas,
  o lo estarán en próximas versiones.
  
  Para optimizar los tiempos de cálculo están escritas en ensamblador.
  
  OBJETIVOS
  --------- 
  1.- Suplir la falta de implementación de cierta funciones matemáticas o
      Tipos de datos en PicPas. Y si ya están implementadas, igualar o
      superar los tiempos de cálculo aunque para ello se consuma más
      memoria de programa o de datos.
      
  2.- Servir de base para la implementación de nuevas funciones matemáticas
      que se incluyan en PicPas.
    
  3.- Fines didácticos para conocer como realizan las operaciones matemáticas
      en los sistemas digitales.
  
  4.- Que cada usuario pueda personalizar sus propias operaciones matemáticas
      en PicPas modificando los algoritmos de cálculo matemático para
      adaptarlos a sus propias necesidades de velocidad, espacio de memoria
      usado, contemplar casos especiales, etc.
  
  OPERATIVA DE CALCULO
  --------------------
  Las variables de entrada son MATH_A y MATH_B. El resultado se devuelve en 
  la misma variable de entrada MATH_A que actúa de ACUMULADOR. Para retornar
  el resultado final siguiendo la operativa de PicPas, utilizar las funciones
  Math_XXbits_Return, que devuelve el resultado en el registro W
  para las operaciones de 8 bits, y para números de más bits, se complementa
  con las variables de sistema _H, _U y _E. Los numéricos de 64 bits, por no
  ser un tipo de dato implementado en PicPas, se devuelven como dos variables
  dword con las funciones Math_64bits_Return_LOW y Math_64bits_Return_HIGH.
  
  Los resultados bits y boolean se devuelve en el bit Z, del STATUS. Aunque
  por optimización, en algunos casos, se puede usar el bit C. 
  
  Encadenamiento de operaciones mantemáticas:
  
  // Suma los valores: 88+34+15+17+11+10=175
     MATH_A_L := 88;
     MATH_B_L := 34;
     Math_8bits_Sumar;
     MATH_B_L := 15;
     Math_8bits_Sumar;
     MATH_B_L := 17;
     Math_8bits_Sumar;
     MATH_B_L := 11;
     Math_8bits_Sumar;
     MATH_B_L := 10;
     Math_8bits_Sumar;
     VARIABLE_TIPO_BYTE := Math_8bits_Return;
  // La variable tipo byte de PicPas contendrá el valor de la suma (175)

  TIPO DE DATOS
  -------------
  Alcance de datos numéricos manejados con total precisión en esta librería:   
  ---------------------------------------------------------------------------------   
  | Tipo de dato             | Alcance (valor máximo)          | Tipo dato PicPas |
  ---------------------------------------------------------------------------------
  | unsignet integer  8 bits | 0 to                        255 | byte             |
  | unsignet integer 16 bits | 0 to                     65.535 | word             |
  | unsignet integer 32 bits | 0 to              4.294.967.295 | dword            |
  | unsignet integer 64 bits | 0 to 18.446.744.073.709.551.615 | (unimplemented)  |
  --------------------------------------------------------------------------------- 
  Nota: Los datos de 64 bits se tratan como dos variables dword de PicPas.  

}

unit Math;

interface

var
  // Registro del SFR usandos en librería.
  STATUS      : byte absolute $0003;
  STATUS_Z    : bit  absolute STATUS.2;
  STATUS_C    : bit  absolute STATUS.0;
  // Operandos tipo variable.
  MATH_A_L    : byte absolute $0060;
  MATH_A_H    : byte absolute $0061;
  MATH_A_HL   : byte absolute $0062;
  MATH_A_HH   : byte absolute $0063;
  MATH_B_L    : byte absolute $0064;
  MATH_B_H    : byte absolute $0065;
  MATH_B_HL   : byte absolute $0066;
  MATH_B_HH   : byte absolute $0067;
  MATH_STATUS : byte absolute $0068;
  MATH_CARRY  : bit  absolute MATH_STATUS.0;  // BIT CARRY
  MATH_ERROR  : bit  absolute MATH_STATUS.1;  // BIT ERROR (division por cero, si más errores codificar en MATH_ECODEs)
  MATH_ZERO   : bit  absolute MATH_STATUS.2;  // BIT ZERO
  MATH_ECODE0 : bit  absolute MATH_STATUS.5;  // BITS ERROR CODE (reservados para posible usos futuros)
  MATH_ECODE1 : bit  absolute MATH_STATUS.6;  //   000 : División por cero.
  MATH_ECODE2 : bit  absolute MATH_STATUS.7;  //   001 : Sin asignar.
  // Para usar en funciones de 64 bits. PicPas solo las agrega si se usan esta funciones.
  MATH_A_HHL  : byte absolute $0050;
  MATH_A_HHH  : byte absolute $0051;
  MATH_A_HHHL : byte absolute $0052;
  MATH_A_HHHH : byte absolute $0053;
  MATH_B_HHL  : byte absolute $0054;
  MATH_B_HHH  : byte absolute $0055;
  MATH_B_HHHL : byte absolute $0056;
  MATH_B_HHHH : byte absolute $0057; 
  // Variables axiliares para guardar valores temporales o contadores.
  MATH_TMP_00 : byte absolute $006A;
  MATH_TMP_01 : byte absolute $006B;
  MATH_TMP_02 : byte absolute $006C;
  MATH_TMP_03 : byte absolute $006D;

  
//***********************************************************************
// E S   I G U A L   Q U E
//***********************************************************************
procedure Math_8bits_EsIgual   : boolean;
procedure Math_16bits_EsIgual  : boolean;
procedure Math_32bits_EsIgual  : boolean;
procedure Math_64bits_EsIgual  : boolean;

//***********************************************************************
// E S   M A Y O R   Q U E
//***********************************************************************
procedure Math_8bits_EsMayor   : boolean;
procedure Math_16bits_EsMayor  : boolean;
procedure Math_32bits_EsMayor  : boolean;
procedure Math_64bits_EsMayor  : boolean;

//***********************************************************************
// E S   M E N O R   Q U E
//***********************************************************************
procedure Math_8bits_EsMenor   : boolean;
procedure Math_16bits_EsMenor  : boolean;
procedure Math_32bits_EsMenor  : boolean;
procedure Math_64bits_EsMenor  : boolean;

//***********************************************************************
// E S   C E R O
//***********************************************************************
procedure Math_8bits_EsCero    : boolean;
procedure Math_16bits_EsCero   : boolean;
procedure Math_32bits_EsCero   : boolean;
procedure Math_64bits_EsCero   : boolean;
  
//***********************************************************************
// C O M P A R A R 
//***********************************************************************
procedure Math_8bits_Comparar  : byte;
procedure Math_16bits_Comparar : byte;
procedure Math_32bits_Comparar : byte;
procedure Math_64bits_Comparar : byte;

//***********************************************************************
// S U M A R
//***********************************************************************
procedure Math_8bits_Sumar;
procedure Math_16bits_Sumar;
procedure Math_32bits_Sumar;
procedure Math_64bits_Sumar;

//***********************************************************************
// R E S T A R
//***********************************************************************
procedure Math_8bits_Restar;
procedure Math_16bits_Restar;
procedure Math_32bits_Restar;
procedure Math_64bits_Restar;

//***********************************************************************
// M U L T I P L I C A R
//***********************************************************************
procedure Math_8bits_Multiplicar;
procedure Math_16bits_Multiplicar;
procedure Math_32bits_Multiplicar;
procedure Math_64bits_Multiplicar;

//***********************************************************************
// D I V I D I R
//***********************************************************************
procedure Math_8bits_Dividir;
procedure Math_16bits_Dividir;
procedure Math_32bits_Dividir;
procedure Math_64bits_Dividir;

//***********************************************************************
// M O D U L O 
// Devuelve el resto de la operacion de dividir dos variables numericas.
//***********************************************************************
procedure Math_8bits_Modulo;
procedure Math_16bits_Modulo;
procedure Math_32bits_Modulo;
procedure Math_64bits_Modulo;

//***********************************************************************
// R E S U L T A D O
// Devuelve el resultado en formato compatible con PicPas.
//***********************************************************************
procedure Math_8bits_Return       : byte;
procedure Math_16bits_Return      : word;
procedure Math_32bits_Return      : dword;
procedure Math_64bits_Return_LOW  : dword;
procedure Math_64bits_Return_HIGH : dword;


implementation

//***********************************************************************
// E S   I G U A L   Q U E
//***********************************************************************
procedure Math_8bits_EsIgual  : boolean;
begin
// PENDIENTE
end;
procedure Math_16bits_EsIgual : boolean;
begin
// PENDIENTE
end;
procedure Math_32bits_EsIgual : boolean;
begin
// PENDIENTE
end;
procedure Math_64bits_EsIgual : boolean;
begin
// PENDIENTE
end;

//***********************************************************************
// E S   M A Y O R   Q U E
//***********************************************************************
procedure Math_8bits_EsMayor  : boolean;
begin
// PENDIENTE
end;
procedure Math_16bits_EsMayor : boolean;
begin
// PENDIENTE
end;
procedure Math_32bits_EsMayor : boolean;
begin
// PENDIENTE
end;
procedure Math_64bits_EsMayor : boolean;
begin
// PENDIENTE
end;

//***********************************************************************
// E S   M E N O R   Q U E
//***********************************************************************
procedure  Math_8bits_EsMenor : boolean;
begin
// PENDIENTE
end;
procedure Math_16bits_EsMenor : boolean;
begin
// PENDIENTE
end;
procedure Math_32bits_EsMenor : boolean;
begin
// PENDIENTE
end;
procedure Math_64bits_EsMenor : boolean;
begin
// PENDIENTE
end;

//***********************************************************************
// E S   C E R O
// Devuelve:
//        0 si es igual a cero.
//        1 si el distinto de cero.
//***********************************************************************
procedure Math_8bits_EsCero  : boolean;
begin
// PENDIENTE
end;
procedure Math_16bits_EsCero : boolean;
begin
// PENDIENTE
end;
procedure Math_32bits_EsCero : boolean;
begin
// PENDIENTE
end;
procedure Math_64bits_EsCero : boolean;
begin
// PENDIENTE
end;

//***********************************************************************
// C O M P A R A R 
// Devuelve:
//        0 si son iguales.
//        1 si el MATH_A > MATH_B.
//        2 si el MATH A < MATH B.
//        Por tanto: < 2 si MATH_A >= MATH_B.
//***********************************************************************
procedure Math_8bits_Comparar  : byte;
begin
// PENDIENTE
end;
procedure Math_16bits_Comparar : byte;
begin
// PENDIENTE
end;
procedure Math_32bits_Comparar : byte;
begin
// PENDIENTE
end;
procedure Math_64bits_Comparar : byte;
begin
// PENDIENTE
end;

//***********************************************************************
// S U M A R
//***********************************************************************
procedure Math_8bits_Sumar;
begin
  ASM
  ;MATH_A = MATH_A + MATH_B  
    MOVF    MATH_B_L,W
    ADDWF   MATH_A_L,F
  END
end;

procedure Math_16bits_Sumar;
begin
  ASM
  ;MATH_A = MATH_A + MATH_B 
    MOVF    MATH_B_L,W
    ADDWF   MATH_A_L,F
    MOVF    MATH_B_H,W
    BTFSC   STATUS_C
    ADDLW   1
    ADDWF   MATH_A_H,F    
  END
end;

procedure Math_32bits_Sumar;
begin
  ASM
  ;MATH_A = MATH_A + MATH_B 
    MOVF    MATH_B_L,W
    ADDWF   MATH_A_L,F
    MOVF    MATH_B_H,W
    BTFSC   STATUS_C
    ADDLW   1
    ADDWF   MATH_A_H,F    
    MOVF    MATH_B_HL,W
    BTFSC   STATUS_C
    ADDLW   1    
    ADDWF   MATH_A_HL,F
    MOVF    MATH_B_HH,W
    BTFSC   STATUS_C
    ADDLW   1
    ADDWF   MATH_A_HH,F   
  END
end;

procedure Math_64bits_Sumar : word;
begin
  ASM
  ;MATH_A = MATH_A + MATH_B 
    MOVF    MATH_B_L,W
    ADDWF   MATH_A_L,F
    MOVF    MATH_B_H,W
    BTFSC   STATUS_C
    ADDLW   1
    ADDWF   MATH_A_H,F    
    MOVF    MATH_B_HL,W
    BTFSC   STATUS_C
    ADDLW   1    
    ADDWF   MATH_A_HL,F
    MOVF    MATH_B_HH,W
    BTFSC   STATUS_C
    ADDLW   1
    ADDWF   MATH_A_HH,F   
    MOVF    MATH_B_HHL,W
    BTFSC   STATUS_C
    ADDLW   1
    ADDWF   MATH_A_HHL,F    
    MOVF    MATH_B_HHH,W
    BTFSC   STATUS_C
    ADDLW   1
    ADDWF   MATH_A_HHH,F    
    MOVF    MATH_B_HHHL,W
    BTFSC   STATUS_C
    ADDLW   1    
    ADDWF   MATH_A_HHHL,F
    MOVF    MATH_B_HHHH,W
    BTFSC   STATUS_C
    ADDLW   1
    ADDWF   MATH_A_HHHH,F
  END
end;

//***********************************************************************
// R E S T A R
//***********************************************************************
procedure Math_8bits_Restar;
begin
// PENDIENTE
end;
procedure Math_16bits_Restar;
begin
// PENDIENTE
end;
procedure Math_32bits_Restar;
begin
// PENDIENTE
end;
procedure Math_64bits_Restar;
begin
// PENDIENTE
end;

//***********************************************************************
// MULTIPLICAR
//***********************************************************************
procedure Math_8bits_Multiplicar;
begin
// PENDIENTE
end;
procedure Math_16bits_Multiplicar;
begin
// PENDIENTE
end;
procedure Math_32bits_Multiplicar;
begin
// PENDIENTE
end;
procedure Math_64bits_Multiplicar;
begin
// PENDIENTE
end;

//***********************************************************************
// D I V I D I R
//***********************************************************************
procedure Math_8bits_Dividir;
begin
// PENDIENTE
end;
procedure Math_16bits_Dividir;
begin
// PENDIENTE
end;
procedure Math_32bits_Dividir;
begin
// PENDIENTE
end;
procedure Math_64bits_Dividir;
begin
// PENDIENTE
end;

//***********************************************************************
// M O D U L O 
// Devuelve el resto de la operacion de dividir dos variables numericas.
//***********************************************************************
procedure Math_8bits_Modulo;
begin
// PENDIENTE
end;
procedure Math_16bits_Modulo;
begin
// PENDIENTE
end;
procedure Math_32bits_Modulo;
begin
// PENDIENTE
end;
procedure Math_64bits_Modulo;
begin
// PENDIENTE
end;

//***********************************************************************
// R E S U L T A D O
// Devuelve el resultado en formato compatible con PicPas.
//***********************************************************************
procedure  Math_8bits_Return : byte;
begin
  ASM
    MOVF  MATH_A_L,W
  END
end;
procedure Math_16bits_Return : word;
begin
  ASM
    MOVF  MATH_A_H,W
    MOVWF _H
    MOVF  MATH_A_L,W
  END
end;
procedure Math_32bits_Return : dword;
begin
  ASM
    MOVF  MATH_A_HH,W
    MOVWF _U
    MOVF  MATH_A_HL,W
    MOVWF _E
    MOVF  MATH_A_H,W
    MOVWF _H
    MOVF  MATH_A_L,W
  END
end;
procedure Math_64bits_Return_LOW : dword;
begin
  ASM
    GOTO  Math_32bits_Return
  END
end;
procedure Math_64bits_Return_HIGH : dword;
begin
  ASM
    MOVF  MATH_A_HHHH,W
    MOVWF _U
    MOVF  MATH_A_HHHL,W
    MOVWF _E
    MOVF  MATH_A_HHH,W
    MOVWF _H
    MOVF  MATH_A_HHL,W
  END
end;

//***********************************************************************
end.
