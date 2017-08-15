{
*  (C) AguHDz 08-AGO-2017
*  Ultima Actualizacion: 10-AGO-2017
*
*  Compilador PicPas v.0.7.2 (https://github.com/t-edson/PicPas)
*
*  MANEJO DE DATOS NUMERICOS DE 4 BYTES (32 BITS)
*  ==============================================
*  Se intentan optimizar las funciones suma, resta, multiplicación y división
*  para el manejo de números largos de 4 bytes (valores de 0 a 4.294.967.295)
*
*  Las operaciones de multiplicación son ahora muy eficientes gracias al uso
*  de instrucciones de rotación, reduciendo notablemente su tiempo de ejecución
*  frente a los métodos sencillo de sumas o restas sucesivas.
*
*  Las rutinas matemáticas están completamente codificadas en lenguaje ensamblador,
*  lo que contribuye a aumentar su eficacia.
*
*  Utilizando estas mismas técnicas se podría trabajar con datos numéricos de
*  tamaños superiores (64 bits o más) con la única limitación de la tamaño de
*  memoria RAM del microcontrolador, pero en principio, no habría ningún problema
*  para operar con una precisión superior a 32 bits (64, 128, 256 bits, etc.)
*
*  Se separan las variables utilizadas en el código ensamblador de cualquier otra
*  que se use en el código Pascal. Por ello, se deben utilizar variables de intercambio
*  de datos (en este ejemplo, se usan las variables ACUMULADOR_L y ACUMULADOR_H, pero 
*  puede ser cualquier otra) que almacenen los datos calculados por las funciones y que
*  permaneces solo temporalmente (hasta que se realice otra operación) en la variable
*  SYS_MATH_NUM_X (32 bits)
*
*  Tanto las variables de entrada como las de la salida se consideran variables
*  globales de sistema. Siempre el operador 1 de la operación se cargará en 
*  SYS_MATH_NUM_A (4 bytes), el operador 2 en SYS_MATH_NUM_B (4 bytes) y el resultado
*  se obtendrá en SYS_MATH_NUM_X (4 bytes). Al ser variables tratadas exclusivamente
*  desde código ensamblador se declaran como globales y absolutas, aunque la
*  posición y orden que ocupen en la memoria es indiferente para su funcionamiento.
*
}

{$PROCESSOR PIC16F72}
{$FREQUENCY 8Mhz}

program Math_32bits;

uses PIC16F72, LCDLib_4bits;

var
ACUMULADOR_L      : word;
ACUMULADOR_H      : word;

// ***** VARIABLES GLOBALES USADAS EN FUNCIONES MATEMATICAS DE 32 BITS *******
// Para evitar problemas con la selección de bancos de memoria, es muy recomendable
// declarar en posiciones fijas las variables utilizadas por el código escrito en
// ensamblador.
SYS_MATH_NUM_A    : byte absolute $0060;
SYS_MATH_NUM_A_H  : byte absolute $0061;
SYS_MATH_NUM_A_U  : byte absolute $0062;
SYS_MATH_NUM_A_E  : byte absolute $0063;
SYS_MATH_NUM_B    : byte absolute $0064;
SYS_MATH_NUM_B_H  : byte absolute $0065;
SYS_MATH_NUM_B_U  : byte absolute $0066;
SYS_MATH_NUM_B_E  : byte absolute $0067;
SYS_MATH_NUM_X    : byte absolute $0068;
SYS_MATH_NUM_X_H  : byte absolute $0069;
SYS_MATH_NUM_X_U  : byte absolute $006A;
SYS_MATH_NUM_X_E  : byte absolute $006B;
SYSBYTETEMP       : byte absolute $006C;
// ---------------------------------------------------------------------------

// ***** FUNCIONES MANTEMATICAS 32 BITS **************************************
procedure Math_32bits_SUMAR;
begin
  SetBank(0);
  ASM
  ;SYS_MATH_NUM_X = SYS_MATH_NUM_A + SYS_MATH_NUM_B
  
	  movf	  SYS_MATH_NUM_B,W
	  addwf	  SYS_MATH_NUM_A,W
	  movwf	  SYS_MATH_NUM_X
	  movf	  SYS_MATH_NUM_B_H,W
	  btfsc	  STATUS_C
	  addlw	  1
	  addwf	  SYS_MATH_NUM_A_H,W
	  movwf	  SYS_MATH_NUM_X_H
	  movf	  SYS_MATH_NUM_B_U,W
	  btfsc	  STATUS_C
	  addlw	  1
	  addwf	  SYS_MATH_NUM_A_U,W
	  movwf	  SYS_MATH_NUM_X_U
	  movf	  SYS_MATH_NUM_B_E,W
	  btfsc	  STATUS_C
	  addlw	  1
	  addwf	  SYS_MATH_NUM_A_E,W
	  movwf	  SYS_MATH_NUM_X_E
  END
end;


procedure Math_32bits_RESTAR;
begin
  SetBank(0);
  ASM
  ;SYS_MATH_NUM_X = SYS_MATH_NUM_A - SYS_MATH_NUM_B
  
    movf    SYS_MATH_NUM_B,W
    subwf   SYS_MATH_NUM_A,W
    movwf   SYS_MATH_NUM_X
    movf    SYS_MATH_NUM_B_H,W
    btfss   STATUS_C
    addlw   1
    subwf   SYS_MATH_NUM_A_H,W
    movwf   SYS_MATH_NUM_X_H
    movf    SYS_MATH_NUM_B_U,W
    btfss   STATUS_C
    addlw   1
    subwf   SYS_MATH_NUM_A_U,W
    movwf   SYS_MATH_NUM_X_U
    movf    SYS_MATH_NUM_B_E,W
    btfss   STATUS_C
    addlw   1
    subwf   SYS_MATH_NUM_A_E,W
    movwf   SYS_MATH_NUM_X_E
  END
end;


procedure Math_32bits_MULTIPLICAR;
// Optiminada en ciclos de operacion usando algoritmos de rotación.
// Ocupa solo 39 bytes.
begin
  SetBank(0);
  ASM
  ;SYS_MATH_NUM_X = SYS_MATH_NUM_A * SYS_MATH_NUM_B
  
  ;SYS_MATH_NUM_X = 0
	  clrf	  SYS_MATH_NUM_X
	  clrf	  SYS_MATH_NUM_X_H
	  clrf	  SYS_MATH_NUM_X_U
	  clrf	  SYS_MATH_NUM_X_E
  MUL32LOOP:
  ;Si SYS_MATH_NUM_B.0 = 1 entonces SYS_MATH_NUM_X += SYS_MATH_NUM_A
	  btfss	  SYS_MATH_NUM_B,0
	  goto	  ENDIF1
	  movf	  SYS_MATH_NUM_A,W
	  addwf	  SYS_MATH_NUM_X,F
	  movf	  SYS_MATH_NUM_A_H,W
	  btfsc	  STATUS_C
	  addlw	  1
	  addwf	  SYS_MATH_NUM_X_H,F
	  movf	  SYS_MATH_NUM_A_U,W
	  btfsc	  STATUS_C
	  addlw	  1
	  addwf	  SYS_MATH_NUM_X_U,F
	  movf	  SYS_MATH_NUM_A_E,W
	  btfsc	  STATUS_C
	  addlw	  1
	  addwf	  SYS_MATH_NUM_X_E,F
  ENDIF1:
  ;STATUS.C := 0
	  bcf	  STATUS_C
  ;rotar SYS_MATH_NUM_B derecha
	  rrf	    SYS_MATH_NUM_B_E,F
	  rrf	    SYS_MATH_NUM_B_U,F
	  rrf	    SYS_MATH_NUM_B_H,F
	  rrf	    SYS_MATH_NUM_B,F
  ;STATUS.C := 0
	  bcf	    STATUS_C
  ;rotar SYS_MATH_NUM_A izquierda
	  rlf	    SYS_MATH_NUM_A,F
	  rlf	    SYS_MATH_NUM_A_H,F
	  rlf	    SYS_MATH_NUM_A_U,F
	  rlf	    SYS_MATH_NUM_A_E,F
  
  ;Si SYS_MATH_NUM_B > 0 entonces goto MUL32LOOP
    movf    SYS_MATH_NUM_B,w
    iorwf   SYS_MATH_NUM_B_H,w 
    iorwf   SYS_MATH_NUM_B_U,w
    iorwf   SYS_MATH_NUM_B_E,w
    btfss   STATUS_Z
    goto    MUL32LOOP     ; SYS_MATH_NUM_B > 0
  
  END
end; 

 
procedure Math_32bits_MODULO;
// Optiminada en ciclos de operacion usando algoritmos de rotación.
// Ocupa solo 63 bytes.
// Se calcula la division entera y el modulo (resto) en esta mismo procedimiento.
// Devuelve el cociente en SYS_MATH_NUM_A
// y el resto de la division en SYS_MATH_NUM_X
begin
  SetBank(0);
  ASM
  ;SYS_MATH_NUM_X = SYS_MATH_NUM_A / SYS_MATH_NUM_B
		clrf    SYS_MATH_NUM_X
		clrf    SYS_MATH_NUM_X_H
		clrf    SYS_MATH_NUM_X_U
		clrf    SYS_MATH_NUM_X_E
	
	;*** Comprueba de divisor = 0 ***
		movf    SYS_MATH_NUM_B,w
		iorwf   SYS_MATH_NUM_B_H,w 
		iorwf   SYS_MATH_NUM_B_U,w
		iorwf   SYS_MATH_NUM_B_E,w
		btfss   STATUS_Z
		goto    SEGUIR   ; divisor > 0
	;Si divisor = 0 divuelve el número maximo posible ($FFFF=infiniro)
	;El resto de la división contendrá el valor inicial = 0.
		movlw   $FF
		movwf   SYS_MATH_NUM_A
		movwf   SYS_MATH_NUM_A_H
		movwf   SYS_MATH_NUM_A_U
		movwf   SYS_MATH_NUM_A_E
		return
		
  SEGUIR:
		movlw   32
		movwf   SYSBYTETEMP
		
  SYSDIV32START:
		rlf		  SYS_MATH_NUM_A,F
		rlf		  SYS_MATH_NUM_A_H,F
		rlf		  SYS_MATH_NUM_A_U,F
		rlf		  SYS_MATH_NUM_A_E,F
    
		rlf		  SYS_MATH_NUM_X,F
		rlf		  SYS_MATH_NUM_X_H,F
		rlf		  SYS_MATH_NUM_X_U,F
		rlf		  SYS_MATH_NUM_X_E,F
    
    ; *** SYS_MATH_NUM_X = SYS_MATH_NUM_X - SYS_MATH_NUM_B ***
		movf	  SYS_MATH_NUM_B,W
		subwf	  SYS_MATH_NUM_X,F
		movf	  SYS_MATH_NUM_B_H,W
		btfss	  STATUS_C
		addlw	  1
		subwf	  SYS_MATH_NUM_X_H,F
		movf	  SYS_MATH_NUM_B_U,W
		btfss	  STATUS_C
		addlw	  1
		subwf	  SYS_MATH_NUM_X_U,F
		movf	  SYS_MATH_NUM_B_E,W
		btfss	  STATUS_C
		addlw	  1
		subwf	  SYS_MATH_NUM_X_E,F

		bsf		  SYS_MATH_NUM_A,0  

		btfsc	  STATUS_C
		goto	  SIGUIENTE
    
		bcf		  SYS_MATH_NUM_A,0
    
    ; *** SYS_MATH_NUM_X = SYS_MATH_NUM_X + SYS_MATH_NUM_B ***
		movf	  SYS_MATH_NUM_B,W
		addwf	  SYS_MATH_NUM_X,F
		movf	  SYS_MATH_NUM_B_H,W
		btfsc	  STATUS_C
		addlw	  1
		addwf	  SYS_MATH_NUM_X_H,F
		movf	  SYS_MATH_NUM_B_U,W
		btfsc	  STATUS_C
		addlw	  1
		addwf	  SYS_MATH_NUM_X_U,F
		movf	  SYS_MATH_NUM_B_E,W
		btfsc	  STATUS_C
		addlw	  1
		addwf	  SYS_MATH_NUM_X_E,F
    
  SIGUIENTE:
		decfsz	SYSBYTETEMP, F
		goto	  SYSDIV32START
  END
end; 


procedure Math_32bits_DIVIDIR;
// Aunque si se podrían usan directamente los valores de salida en SYS_MATH_NUM_A
// en la llamada a Math_32bits_MODULO, se puede usar esta funcion para estandarizar
// los registros de todas las operaciones en SYS_MATH_NUM_X. Haciendo más entendibre
// el código. Pero si se debe optimizar, mejor usar directamente Math_32bits_MODULO.
begin
  Math_32bits_MODULO;  // Es procedimiento devuelve el cociente en SYS_MATH_NUM_A.   
  SYS_MATH_NUM_X   := SYS_MATH_NUM_A;
  SYS_MATH_NUM_X_H := SYS_MATH_NUM_A_H;
  SYS_MATH_NUM_X_E := SYS_MATH_NUM_A_E;
  SYS_MATH_NUM_X_U := SYS_MATH_NUM_A_U; 
end;
// ***** FIN FUNCIONES MANTEMATICAS 32 BITS **********************************


 
 
// ****************************************************
// **** DEMOSTRACION DE USO DE FUNCIONES **************
// ****************************************************

procedure Math_32bits_DEVUELVE_ACUMULADOR;
begin
  ACUMULADOR_L.low  := SYS_MATH_NUM_X;
  ACUMULADOR_L.high := SYS_MATH_NUM_X_H;
  ACUMULADOR_H.low  := SYS_MATH_NUM_X_U;
  ACUMULADOR_H.high := SYS_MATH_NUM_X_E;
end;


procedure Math_32bits_CARGA_A;
begin
  SYS_MATH_NUM_A   := ACUMULADOR_L.low;
  SYS_MATH_NUM_A_H := ACUMULADOR_L.high;
  SYS_MATH_NUM_A_U := ACUMULADOR_H.low;
  SYS_MATH_NUM_A_E := ACUMULADOR_H.high;
end;


procedure Math_32bits_CARGA_B;
begin
  SYS_MATH_NUM_B   := ACUMULADOR_L.low;
  SYS_MATH_NUM_B_H := ACUMULADOR_L.high;
  SYS_MATH_NUM_B_U := ACUMULADOR_H.low;
  SYS_MATH_NUM_B_E := ACUMULADOR_H.high;
end;

procedure Math_32bits_Print_Digito_ACUMULADOR;
const
  CONV_CHR_NUMERO = $30;  // ASCII '0' ($30) menos $00 = $30
  CONV_CHR_LETRA  = $37;  // ASCII 'A' ($41) menos $10 = $37
begin
  if(SYSBYTETEMP>9) then SYSBYTETEMP := SYSBYTETEMP + CONV_CHR_LETRA;
  else SYSBYTETEMP := SYSBYTETEMP + CONV_CHR_NUMERO end;
  LCD_WriteChar(Chr(SYSBYTETEMP));
end;


procedure Math_32bits_Print_ACUMULADOR;
begin
  SYSBYTETEMP := ACUMULADOR_H.high >> 4;
  Math_32bits_Print_Digito_ACUMULADOR;
  SYSBYTETEMP := ACUMULADOR_H.high AND $0F;
  Math_32bits_Print_Digito_ACUMULADOR;
  SYSBYTETEMP := ACUMULADOR_H.low >> 4;
  Math_32bits_Print_Digito_ACUMULADOR;
  SYSBYTETEMP := ACUMULADOR_H.low AND $0F;
  Math_32bits_Print_Digito_ACUMULADOR;
  SYSBYTETEMP := ACUMULADOR_L.high >> 4;
  Math_32bits_Print_Digito_ACUMULADOR;
  SYSBYTETEMP := ACUMULADOR_L.high AND $0F;
  Math_32bits_Print_Digito_ACUMULADOR;
  SYSBYTETEMP := ACUMULADOR_L.low >> 4;
  Math_32bits_Print_Digito_ACUMULADOR;
  SYSBYTETEMP := ACUMULADOR_L.low AND $0F;
  Math_32bits_Print_Digito_ACUMULADOR;
end;


procedure Math_32bits_Print_ACUMULADOR_DEC;
const
  CONV_CHR_NUMERO = $30;  // ASCII '0' ($30) menos $00 = $30
var
  ACUM_BK_L, ACUM_BK_H : word;  // Usada para salvar el valor de la variable ACUMULADOR y restaurarla antes de salir de la función.
  VALOR_L, VALOR_H     : word;  // Para operar con el valor de 32 bits a imprimir.
  DIV10_L, DIV10_H     : word;  // Para dividir por multiplos de 10 el valor a imprimir
  digito               : byte;  // Contiene un digito del valor a imprimir.
  contador             : byte;  // Contador de bucle.
begin
  ACUM_BK_H := ACUMULADOR_H;    // Salvamos el valor la la variable global ACUMULADOR.
  ACUM_BK_L := ACUMULADOR_L;
  
  VALOR_H := ACUMULADOR_H;      // Valor a imprimir
  VALOR_L := ACUMULADOR_L;
  DIV10_H := $3B9A;             // Numero 10000000000 en hexadecimal ($3B9ACA00) 
  DIV10_L := $CA00;

   // ******** Bucle en el que se calculan e imprimen los 10 digitos de la variable.
   //           Se calcula por divisiones sucesivas de multiplos de 10.
   //           Se utilizan las funciones de cálculo de MODULO y DIVISION para variables de 32 bits.
  contador := 0;
  repeat                       
    // DIGITO = TEMP / DIV10     
    ACUMULADOR_H := VALOR_H;
    ACUMULADOR_L := VALOR_L;
    Math_32bits_CARGA_A;
  {$IFDEF DEBUG_ON}
  LCD_GotoXY(0,0);
  Math_32bits_Print_ACUMULADOR;
  {$ENDIF}
      ACUMULADOR_H := DIV10_H;
    ACUMULADOR_L := DIV10_L;
    Math_32bits_CARGA_B;
  {$IFDEF DEBUG_ON}
  LCD_GotoXY(1,0);
  Math_32bits_Print_ACUMULADOR;
  delay_ms(1000);
  {$ENDIF}
    Math_32bits_MODULO;  
    // TEMP = TEMP % DIV10
    VALOR_L.low  := SYS_MATH_NUM_X;
    VALOR_L.high := SYS_MATH_NUM_X_H;
    VALOR_H.low  := SYS_MATH_NUM_X_U;
    VALOR_H.high := SYS_MATH_NUM_X_E;
    
    digito := SYS_MATH_NUM_A AND $0F;
    digito := digito + CONV_CHR_NUMERO;
    LCD_WriteChar(chr(digito));  

    // DIV10 = DIV10 / 10
    ACUMULADOR_H := DIV10_H;
    ACUMULADOR_L := DIV10_L;
    Math_32bits_CARGA_A;
    ACUMULADOR_H := 0;
    ACUMULADOR_L := 10;
    Math_32bits_CARGA_B;
    Math_32bits_DIVIDIR;
    DIV10_L.low  := SYS_MATH_NUM_X;
    DIV10_L.high := SYS_MATH_NUM_X_H;
    DIV10_H.low  := SYS_MATH_NUM_X_U;
    DIV10_H.high := SYS_MATH_NUM_X_E;    
    
    inc(contador);
  until(contador=10);
  // ************************** fin de bucle.
    
  ACUMULADOR_H := ACUM_BK_H;       // Se restaura el valor de la variable global ACUMULADOR.
  ACUMULADOR_L := ACUM_BK_L;
end;

procedure prueba_Math_32bits_Print_ACUMULADOR_DEC;
var
  Contador_L, Contador_H : word;
begin
//  ACUMULADOR_H := $0B9A;
//  ACUMULADOR_L := $CA01; // 194693633

  LCD_GotoXY(0,0);
  LCD_WriteChar('H');
  LCD_WriteChar('e');
  LCD_WriteChar('x');
  LCD_WriteChar('a');
  LCD_WriteChar('d');
  LCD_WriteChar('e');
  LCD_WriteChar('c');
  LCD_WriteChar('i');
  LCD_WriteChar('m');
  LCD_WriteChar('a');
  LCD_WriteChar('l');
  LCD_WriteChar(' ');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_GotoXY(1,0);
  LCD_WriteChar('3');
  LCD_WriteChar('2');
  LCD_WriteChar(' ');
  LCD_WriteChar('b');
  LCD_WriteChar('i');
  LCD_WriteChar('t');
  LCD_WriteChar('s');
  LCD_WriteChar(':');
  LCD_GotoXY(2,0);
  LCD_WriteChar('D');
  LCD_WriteChar('e');
  LCD_WriteChar('c');
  LCD_WriteChar('i');
  LCD_WriteChar('m');
  LCD_WriteChar('a');
  LCD_WriteChar('l');  
  LCD_WriteChar(' '); 
  LCD_WriteChar(' '); 
  LCD_WriteChar(' ');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_GotoXY(3,0);
  LCD_WriteChar('3');
  LCD_WriteChar('2');
  LCD_WriteChar(' ');
  LCD_WriteChar('b');
  LCD_WriteChar('i');
  LCD_WriteChar('t');
  LCD_WriteChar('s');
  LCD_WriteChar(':');
  
  Contador_H := $0000;
  Contador_L := $0000;
  repeat
    repeat
      ACUMULADOR_H := Contador_H;
      ACUMULADOR_L := Contador_L;
      LCD_GotoXY(1,12);
      Math_32bits_Print_ACUMULADOR;
      LCD_GotoXY(3,10);
      Math_32bits_Print_ACUMULADOR_DEC;
      Contador_L := Contador_L + $FFF;
    until(Contador_L.high > $FE);
    Contador_L := $0000;
    Contador_H := Contador_H + 1;
  until(false);
end; 

begin
  LCD_Init(4,20);
  
// Demostración de uso de operaciones con variables de 32 bits

  LCD_WriteChar('S');
  LCD_WriteChar('u');
  LCD_WriteChar('m');
  LCD_WriteChar('a');
  LCD_WriteChar('r');
  LCD_WriteChar(':');
  LCD_GotoXY(1,7);
  ACUMULADOR_H := $0123;
  ACUMULADOR_L := $4567;
  Math_32bits_Print_ACUMULADOR;
  LCD_GotoXY(2,6);
  LCD_WriteChar('+');
  Math_32bits_CARGA_A;
  ACUMULADOR_H := $89AB;
  ACUMULADOR_L := $CDEF;
  Math_32bits_Print_ACUMULADOR;
  Math_32bits_CARGA_B;
  Math_32bits_SUMAR;
  Math_32bits_DEVUELVE_ACUMULADOR;
  LCD_GotoXY(3,6);
  LCD_WriteChar('=');
  Math_32bits_Print_ACUMULADOR;
  
  delay_ms(3000);
  LCD_Clear;
  
  LCD_WriteChar('R');
  LCD_WriteChar('e');
  LCD_WriteChar('s');
  LCD_WriteChar('t');
  LCD_WriteChar('a');
  LCD_WriteChar('r');
  LCD_WriteChar(':');
  LCD_GotoXY(1,7);
  ACUMULADOR_H := $9876;
  ACUMULADOR_L := $5432;
  Math_32bits_Print_ACUMULADOR;
  LCD_GotoXY(2,6);
  LCD_WriteChar('-');
  Math_32bits_CARGA_A;
  ACUMULADOR_H := $10FE;
  ACUMULADOR_L := $DCBA;
  Math_32bits_Print_ACUMULADOR;
  Math_32bits_CARGA_B;
  Math_32bits_RESTAR;
  Math_32bits_DEVUELVE_ACUMULADOR;
  LCD_GotoXY(3,6);
  LCD_WriteChar('=');
  Math_32bits_Print_ACUMULADOR;

  delay_ms(3000);
  LCD_Clear;
 
  LCD_WriteChar('M');
  LCD_WriteChar('u');
  LCD_WriteChar('l');
  LCD_WriteChar('t');
  LCD_WriteChar('i');
  LCD_WriteChar('p');
  LCD_WriteChar('l');
  LCD_WriteChar('i');
  LCD_WriteChar('c');
  LCD_WriteChar('a');
  LCD_WriteChar('r');
  LCD_WriteChar(':');
  LCD_GotoXY(1,7);
  ACUMULADOR_H := $0005;
  ACUMULADOR_L := $5555;
  Math_32bits_Print_ACUMULADOR;
  LCD_GotoXY(2,6);
  LCD_WriteChar('x');
  Math_32bits_CARGA_A;
  ACUMULADOR_H := $0000;
  ACUMULADOR_L := $40;
  Math_32bits_Print_ACUMULADOR;
  Math_32bits_CARGA_B;
  Math_32bits_MULTIPLICAR;
  Math_32bits_DEVUELVE_ACUMULADOR;
  LCD_GotoXY(3,6);
  LCD_WriteChar('=');
  Math_32bits_Print_ACUMULADOR; 
 
  delay_ms(3000);
  LCD_Clear;
  
  LCD_WriteChar('D');
  LCD_WriteChar('i');
  LCD_WriteChar('v');
  LCD_WriteChar('i');
  LCD_WriteChar('d');
  LCD_WriteChar('i');
  LCD_WriteChar('r');
  LCD_WriteChar(':');
  LCD_GotoXY(1,7);
  ACUMULADOR_H := $2658;
  ACUMULADOR_L := $2336;
  Math_32bits_Print_ACUMULADOR;
  LCD_GotoXY(2,6);
  LCD_WriteChar('/');
  Math_32bits_CARGA_A;
  ACUMULADOR_H := $0001;
  ACUMULADOR_L := $0256;
  Math_32bits_Print_ACUMULADOR;
  Math_32bits_CARGA_B;
  Math_32bits_DIVIDIR;
  Math_32bits_DEVUELVE_ACUMULADOR;
  LCD_GotoXY(3,6);
  LCD_WriteChar('=');
  Math_32bits_Print_ACUMULADOR;
 
  delay_ms(3000);
  LCD_Clear;
 
  LCD_WriteChar('R');
  LCD_WriteChar('e');
  LCD_WriteChar('s');
  LCD_WriteChar('t');
  LCD_WriteChar('o');
  LCD_WriteChar(' ');
  LCD_WriteChar('(');
  LCD_WriteChar('M');
  LCD_WriteChar('o');
  LCD_WriteChar('d');
  LCD_WriteChar('u');
  LCD_WriteChar('l');
  LCD_WriteChar('o');
  LCD_WriteChar(')');
  LCD_WriteChar(':');
  LCD_GotoXY(1,7);
  ACUMULADOR_H := $2658;
  ACUMULADOR_L := $2336;
  Math_32bits_Print_ACUMULADOR;
  LCD_GotoXY(2,6);
  LCD_WriteChar('%');
  Math_32bits_CARGA_A;
  ACUMULADOR_H := $0001;
  ACUMULADOR_L := $0256;
  Math_32bits_Print_ACUMULADOR;
  Math_32bits_CARGA_B;
  Math_32bits_MODULO;
  Math_32bits_DEVUELVE_ACUMULADOR;
  LCD_GotoXY(3,6);
  LCD_WriteChar('=');
  Math_32bits_Print_ACUMULADOR; 
 
  delay_ms(3000);
  LCD_Clear;
    
  prueba_Math_32bits_Print_ACUMULADOR_DEC;
 
end.
