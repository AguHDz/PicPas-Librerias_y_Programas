{
*  (C) AguHDz 10-AGO-2017
*  Ultima Actualizacion: 11-AGO-2017
*
*  Compilador PicPas v.0.7.3 (https://github.com/t-edson/PicPas)
*
*  MANEJO DE DATOS NUMERICOS DE 2 BYTES (16 BITS)
*  ==============================================
*  Se intentan optimizar las funciones suma, resta, multiplicación y división
*  para el manejo de números compuestos por 2 bytes (valores de 0 a 65.535)
*
*  Las operaciones de multiplicación son ahora muy eficientes gracias al uso
*  de instrucciones de rotación, reduciendo notablemente su tiempo de ejecución
*  frente a los métodos sencillo de sumas o restas sucesivas.
*
*  Las rutinas matemáticas están completamente codificadas en lenguaje ensamblador,
*  lo que contribuye a aumentar su eficacia.
*
*  Se separan las variables utilizadas en el código ensamblador de cualquier otra
*  que se use en el código Pascal. Por ello, se deben utilizar variables de intercambio
*  de datos (en este ejemplo, se usa la variables tipo word ACUMULADOR, pero 
*  puede ser cualquier otra) que almacenen los datos calculados por las funciones y que
*  permanecen solo temporalmente, hasta que se realice otra operación.
*
*  Las variables de entrada se consideran variables globales de sistema. Siempre el
*  operador 1 de la operación se cargará en SYS_MATH_NUM_A (2 bytes), el operador 2
*  en SYS_MATH_NUM_B (2 bytes) y el resultado se obtendrá en el formato estandar de
*  PicPas para devoluvión de valor tipo word de 2 byte (parte baja en registro W y
*  parte alta en variable de sistema _H. Al ser variables tratadas exclusivamente
*  desde código ensamblador se declaran como globales y absolutas, aunque la
*  posición y orden que ocupen en la memoria es indiferente para su funcionamiento.
*
*  Tambien se utilizan dos variables auxiliares de 1 byte cada una para contadores
*  y almacenamientos temporales dentro de las funciones Multiplicar y Modulo. Si esta
*  funciones se integran en cualquier programa, se pueden sustituir por cualquieras
*  otras variables auxiliares (o usarlar en otras funciones), pero al usarse en
*  código ensamblador, es recomendable que se declaren absolutas.
*
*  El procedimiento Math_16bits_Print_ACUMULADOR_DEC hace un uso intensivo del las
*  operaciones de División y Módulo para imprimir valores de 16 bits en formato decimal.
*
}

{$PROCESSOR PIC16F72}
{$FREQUENCY 8Mhz}
{$MODE PICPAS}

// Para depuración y prueba de programa.
// Usados para comprobar el funcionamiento y evocución de las variables
// del procedimiento Math_16bits_Print_ACUMULADOR_DEC.
// ------------------------------------
//{$DEFINE DEBUG_ON}
//{$DEFINE DEBUG_PAUSA}
// -------------------------------------

program Math_16bits;

uses PIC16F72, LCDLib_4bits;

var
ACUMULADOR      : word;

// ***** VARIABLES GLOBALES USADAS EN FUNCIONES MATEMATICAS DE 16 BITS *******
// Para evitar problemas con la selección de bancos de memoria, es muy recomendable
// declarar en posiciones fijas las variables utilizadas por el código escrito en
// ensamblador.
SYS_MATH_NUM_A_L  : byte absolute $0060;
SYS_MATH_NUM_A_H  : byte absolute $0061;
SYS_MATH_NUM_B_L  : byte absolute $0062;
SYS_MATH_NUM_B_H  : byte absolute $0063;
SYSBYTETEMP_01    : byte absolute $0064;
SYSBYTETEMP_02    : byte absolute $0065;
// ---------------------------------------------------------------------------

// ***** FUNCIONES MATEMATICAS 16 BITS **************************************
// ------------------------------------------------------------------
procedure Math_16bits_SUMAR : word;
// LA SUMA DE VARIABLES TIPO WORD YA SE ENCUENTRA IMPLEMENTADA EN EL COMPILADOR PICPAS.
// Ocupa 10 posiciones de memoria de programa. 
begin
  SetBank(0);
  ASM
  ;[W_H] = SYS_MATH_NUM_A + SYS_MATH_NUM_B
  
 	  movf	  SYS_MATH_NUM_B_H,W
	  addwf	  SYS_MATH_NUM_A_H,W
	  movwf	  _H
	  movf	  SYS_MATH_NUM_B_L,W
    addwf	  SYS_MATH_NUM_A_L,W
	  btfsc	  STATUS_C
	  incf	  _H,f   
  END
end;
// ------------------------------------------------------------------
procedure Math_16bits_RESTAR : word;
// Ocupa 10 posiciones de memoria de programa. 
begin
  SetBank(0);
  ASM
  ;[W_H] = SYS_MATH_NUM_A - SYS_MATH_NUM_B
    
 	  movf	  SYS_MATH_NUM_B_H,W
	  subwf	  SYS_MATH_NUM_A_H,W
	  movwf	  _H
	  movf	  SYS_MATH_NUM_B_L,W
    subwf	  SYS_MATH_NUM_A_L,W
	  btfsc	  STATUS_C
	  incf	  _H,f     
  END
end;
// ------------------------------------------------------------------
procedure Math_16bits_MULTIPLICAR : word;
// Optiminada en ciclos de operacion usando algoritmos de rotación.
// Ocupa 19 posiciones de memoria de programa. 
begin
  SetBank(0);
  ASM
  ;[W_H] = SYS_MATH_NUM_A * SYS_MATH_NUM_B
  
  ;SYS_MATH_NUM_X = 0
	  clrf	  SYSBYTETEMP_01
	  clrf	  _H
  MUL16LOOP:
  ;Si SYS_MATH_NUM_B.0 = 1 entonces [W_H] += SYS_MATH_NUM_A
	  btfss	  SYS_MATH_NUM_B_L,0
	  goto	  ENDIF1
	  movf	  SYS_MATH_NUM_A_L,W
	  addwf	  SYSBYTETEMP_01,F
	  movf	  SYS_MATH_NUM_A_H,W
	  btfsc	  STATUS_C
	  addlw	  1
	  addwf	  _H,F
  ENDIF1:
  ;STATUS.C := 0
	  bcf	  STATUS_C
  ;rotar SYS_MATH_NUM_B derecha
	  rrf	    SYS_MATH_NUM_B_H,F
	  rrf	    SYS_MATH_NUM_B_L,F
  ;STATUS.C := 0
	  bcf	    STATUS_C
  ;rotar SYS_MATH_NUM_A izquierda
	  rlf	    SYS_MATH_NUM_A_L,F
	  rlf	    SYS_MATH_NUM_A_H,F
  
  ;Si SYS_MATH_NUM_B > 0 entonces goto MUL16LOOP
    movf    SYS_MATH_NUM_B_L,w
    iorwf   SYS_MATH_NUM_B_H,w 
    sublw   $00
    btfss   STATUS_Z
    goto    MUL16LOOP     ; SYS_MATH_NUM_B > 0
    
    movf    SYSBYTETEMP_01,w
  END
end; 
// ------------------------------------------------------------------
procedure Math_16bits_MODULO : word;
// Optiminada en ciclos de operación usando algoritmos de rotación.
// Ocupa 39 posiciones de memoria de programa. 
// Se calcula la division entera y el modulo (resto) en esta mismo procedimiento.
// Devuelve el MODULO (resto de división) en el formato estándar para funciones de PicPas
// y el cociente de la division en el operador SYS_MATH_NUM_A que se utiliza para recoger
// el resultado en la función DIVIDIR.
begin
  SetBank(0);
  ASM
  ;[W_H] = SYS_MATH_NUM_A % SYS_MATH_NUM_B
  ;SYS_MATH_NUM_A = SYS_MATH_NUM_A / SYS_MATH_NUM_B
		clrf    SYSBYTETEMP_01
		clrf    _H
	
	;*** Comprueba de divisor = 0 ***
		movf    SYS_MATH_NUM_B_L,w
		iorwf   SYS_MATH_NUM_B_H,w 
		sublw   $00
		btfss   STATUS_Z
		goto    SEGUIR   ; divisor > 0
	;Si divisor = 0 divuelve el número maximo posible ($FFFF=infinito)
  ;Tambien se podría activar flag de ERROR de DIVISION POR CERO.
	;El resto de la división contendrá el valor inicial = 0.
		movlw   $FF
		movwf   SYS_MATH_NUM_A_L
		movwf   SYS_MATH_NUM_A_H
		return
		
  SEGUIR:
		movlw   16             ;Número de 16 bits.
		movwf   SYSBYTETEMP_02
		
  SYSDIV32START:
		rlf		  SYS_MATH_NUM_A_L,F
		rlf		  SYS_MATH_NUM_A_H,F
    
		rlf		  SYSBYTETEMP_01,F
		rlf		  _H,F
    
    ; *** [W_H] = [W_H] - SYS_MATH_NUM_B ***
		movf	  SYS_MATH_NUM_B_L,W
		subwf	  SYSBYTETEMP_01,F
		movf	  SYS_MATH_NUM_B_H,W
		btfss	  STATUS_C
		addlw	  1
		subwf	  _H,F

		bsf		  SYS_MATH_NUM_A_L,0  

		btfsc	  STATUS_C
		goto	  SIGUIENTE
    
		bcf		  SYS_MATH_NUM_A_L,0
    
    ; *** [W_H] = [W_H] + SYS_MATH_NUM_B ***
		movf	  SYS_MATH_NUM_B_L,W
		addwf	  SYSBYTETEMP_01,F
		movf	  SYS_MATH_NUM_B_H,W
		btfsc	  STATUS_C
		addlw	  1
		addwf	  _H,F
    
  SIGUIENTE:
		decfsz	SYSBYTETEMP_02, F
		goto	  SYSDIV32START
    
    movf    SYSBYTETEMP_01,w
  END
end; 
// ------------------------------------------------------------------
procedure Math_16bits_DIVIDIR : word;
// Aunque si se podrían usan directamente los valores de salida en SYS_MATH_NUM_A
// en la llamada a Math_16bits_MODULO, se puede usar esta funcion para estandarizar
// la devolución de resultado al formato PicPas. Haciendo más entendibre el código.
// Pero si se debe optimizar, se puede usar directamente Math_16bits_MODULO.
// Ocupa 5 posiciones de memoria de programa. 
begin
  ASM
    ;Mejora incorporada en version 0.7.3 de PicPas que permite llamar desde bloques ASM
    ;a funciones Pascal. (prueba superada)
    call Math_16bits_MODULO  ;Este procedimiento devuelve el cociente en SYS_MATH_NUM_A
    movf   SYS_MATH_NUM_A_H,w
    movwf  _H
    movf   SYS_MATH_NUM_A_L,w
  END
end;
// ------------------------------------------------------------------
// ***** FIN FUNCIONES MATEMATICAS 16 BITS **********************************

 
 
// ****************************************************
// **** DEMOSTRACION DE USO DE FUNCIONES **************
// ****************************************************
// ------------------------------------------------------------------
procedure Math_16bits_CARGA_A;
begin
  SYS_MATH_NUM_A_L := ACUMULADOR.low;
  SYS_MATH_NUM_A_H := ACUMULADOR.high;
end;


procedure Math_16bits_CARGA_B;
begin
  SYS_MATH_NUM_B_L := ACUMULADOR.low;
  SYS_MATH_NUM_B_H := ACUMULADOR.high;
end;
// ------------------------------------------------------------------
procedure Math_16bits_Print_Digito_ACUMULADOR;
// Imprime en formato HEXADECIMAL un número de 16 bits contenido en la variable ACUMULADOR.
const
  CONV_CHR_NUMERO = $30;  // ASCII '0' ($30) menos $00 = $30
  CONV_CHR_LETRA  = $37;  // ASCII 'A' ($41) menos $10 = $37
begin
  if(SYSBYTETEMP_01>9) then SYSBYTETEMP_01 := SYSBYTETEMP_01 + CONV_CHR_LETRA;
  else SYSBYTETEMP_01 := SYSBYTETEMP_01 + CONV_CHR_NUMERO end;
  LCD_WriteChar(Chr(SYSBYTETEMP_01));
end;
// ------------------------------------------------------------------
procedure Math_16bits_Print_ACUMULADOR;
begin
  SYSBYTETEMP_01 := ACUMULADOR.high >> 4;
  Math_16bits_Print_Digito_ACUMULADOR;
  SYSBYTETEMP_01 := ACUMULADOR.high AND $0F;
  Math_16bits_Print_Digito_ACUMULADOR;
  SYSBYTETEMP_01 := ACUMULADOR.low >> 4;
  Math_16bits_Print_Digito_ACUMULADOR;
  SYSBYTETEMP_01 := ACUMULADOR.low AND $0F;
  Math_16bits_Print_Digito_ACUMULADOR;
end;
// ------------------------------------------------------------------
procedure Math_16bits_Print_ACUMULADOR_DEC;
// Imprime en formato DECIMAL un número de 16 bits contenido en la variable ACUMULADOR.
const
  CONV_CHR_NUMERO = $30;  // ASCII '0' ($30) menos $00 = $30
var
  ACUM_BK  : word;  // Usada para salvar el valor de la variable ACUMULADOR y restaurarla antes de salir de la función.
  VALOR    : word;  // Para operar con el valor de 32 bits a imprimir.
  DIV10    : word;  // Para dividir por multiplos de 10 el valor a imprimir
  digito   : byte;  // Contiene un digito del valor a imprimir.
  contador : byte;  // Contador de bucle.
begin
  ACUM_BK := ACUMULADOR;    // Salvamos el valor la la variable global ACUMULADOR.
  
  VALOR := ACUMULADOR;      // Valor a imprimir.
  DIV10 := 10000;           // Valor inicial de divisor decimal. 

   // ******** Bucle en el que se calculan e imprimen los 5 digitos de la variable word.
   //          Se calcula por divisiones sucesivas de multiplos de 10.
   //          Se utilizan las funciones de cálculo de MODULO y DIVISION para variables de 16 bits.
  contador := 0;
  repeat                       
    // DIGITO = TEMP / DIV10     
    ACUMULADOR := VALOR;
    Math_16bits_CARGA_A;
    {$IFDEF DEBUG_ON}    
      LCD_GotoXY(1,0);  
      LCD_WriteChar('V');
      LCD_WriteChar('A');
      LCD_WriteChar('L');
      LCD_WriteChar('O');
      LCD_WriteChar('R');
      LCD_WriteChar(':');
      Math_16bits_Print_ACUMULADOR;
    {$ENDIF}
    ACUMULADOR := DIV10;
    Math_16bits_CARGA_B;
    {$IFDEF DEBUG_ON}
      LCD_GotoXY(3,0);
      LCD_WriteChar('D');
      LCD_WriteChar('I');
      LCD_WriteChar('V');
      LCD_WriteChar('1');
      LCD_WriteChar('0');
      LCD_WriteChar(':');
      Math_16bits_Print_ACUMULADOR;
      LCD_GotoXY(3,15+contador);
      delay_ms(500);
    {$ENDIF}
    // TEMP = TEMP % DIV10
    VALOR := Math_16bits_MODULO;
    
    digito := SYS_MATH_NUM_A_L AND $0F;
    digito := digito + CONV_CHR_NUMERO;
    LCD_WriteChar(chr(digito));  

    // DIV10 = DIV10 / 10
    ACUMULADOR := DIV10;
    Math_16bits_CARGA_A;
    ACUMULADOR := 10;
    Math_16bits_CARGA_B;
    DIV10 := Math_16bits_DIVIDIR;  
    
    inc(contador);
  until(contador=5);
  // ************************** fin de bucle.
    
  ACUMULADOR := ACUM_BK;       // Se restaura el valor de la variable global ACUMULADOR.
end;
// ------------------------------------------------------------------
procedure prueba_Math_16bits_Print_ACUMULADOR_DEC;
var
  Contador : word;
begin
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
  LCD_GotoXY(0,16);
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_GotoXY(1,0);
  LCD_WriteChar('1');
  LCD_WriteChar('6');
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
  LCD_GotoXY(2,15);
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_WriteChar('-');
  LCD_GotoXY(3,0);
  LCD_WriteChar('1');
  LCD_WriteChar('6');
  LCD_WriteChar(' ');
  LCD_WriteChar('b');
  LCD_WriteChar('i');
  LCD_WriteChar('t');
  LCD_WriteChar('s');
  LCD_WriteChar(':');
  
  Contador := $0000;
  repeat
      ACUMULADOR := Contador;
      LCD_GotoXY(1,16);
      Math_16bits_Print_ACUMULADOR;
      LCD_GotoXY(3,15);
      Math_16bits_Print_ACUMULADOR_DEC;
      {$IFDEF DEBUG_ON}
        Contador := Contador + $0123;
        delay_ms(500);
      {$ELSE}
        Contador := Contador + $000F;
      {$ENDIF}
      {$IFDEF DEBUG_PAUSA}
        delay_ms(1000);
      {$ENDIF}
  until(false);
end;
// ------------------------------------------------------------------


// *******************************************
// *** P R O G R A M A   P R I N C I P A L ***
// *******************************************
begin
  LCD_Init(4,20);
   
// Demostración de uso de operaciones con variables de 16 bits

  LCD_WriteChar('S');
  LCD_WriteChar('u');
  LCD_WriteChar('m');
  LCD_WriteChar('a');
  LCD_WriteChar('r');
  LCD_WriteChar(':');
  LCD_GotoXY(1,15);
  ACUMULADOR := $1234;
  Math_16bits_Print_ACUMULADOR;
  LCD_GotoXY(2,14);
  LCD_WriteChar('+');
  Math_16bits_CARGA_A;
  ACUMULADOR := $5678;
  Math_16bits_Print_ACUMULADOR;
  Math_16bits_CARGA_B;
  ACUMULADOR := Math_16bits_SUMAR;
  LCD_GotoXY(3,14);
  LCD_WriteChar('=');
  Math_16bits_Print_ACUMULADOR;
  
  delay_ms(3000);
  LCD_Clear;
  
  LCD_WriteChar('R');
  LCD_WriteChar('e');
  LCD_WriteChar('s');
  LCD_WriteChar('t');
  LCD_WriteChar('a');
  LCD_WriteChar('r');
  LCD_WriteChar(':');
  LCD_GotoXY(1,15);
  ACUMULADOR := $5432;
  Math_16bits_Print_ACUMULADOR;
  LCD_GotoXY(2,14);
  LCD_WriteChar('-');
  Math_16bits_CARGA_A;
  ACUMULADOR := $1234;
  Math_16bits_Print_ACUMULADOR;
  Math_16bits_CARGA_B;
  ACUMULADOR := Math_16bits_RESTAR;
  LCD_GotoXY(3,14);
  LCD_WriteChar('=');
  Math_16bits_Print_ACUMULADOR;

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
  LCD_GotoXY(1,15);
  ACUMULADOR := $345;
  Math_16bits_Print_ACUMULADOR;
  LCD_GotoXY(2,14);
  LCD_WriteChar('x');
  Math_16bits_CARGA_A;
  ACUMULADOR := $30;
  Math_16bits_Print_ACUMULADOR;
  Math_16bits_CARGA_B;
  ACUMULADOR := Math_16bits_MULTIPLICAR;
  LCD_GotoXY(3,14);
  LCD_WriteChar('=');
  Math_16bits_Print_ACUMULADOR; 
 
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
  LCD_GotoXY(1,15);
  ACUMULADOR := $FFF0;
  Math_16bits_Print_ACUMULADOR;
  LCD_GotoXY(2,14);
  LCD_WriteChar('/');
  Math_16bits_CARGA_A;
  ACUMULADOR := $777;
  Math_16bits_Print_ACUMULADOR;
  Math_16bits_CARGA_B;
  ACUMULADOR := Math_16bits_DIVIDIR;
  LCD_GotoXY(3,14);
  LCD_WriteChar('=');
  Math_16bits_Print_ACUMULADOR;
 
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
  LCD_GotoXY(1,15);
  ACUMULADOR := $2336;
  Math_16bits_Print_ACUMULADOR;
  LCD_GotoXY(2,14);
  LCD_WriteChar('%');
  Math_16bits_CARGA_A;
  ACUMULADOR := $0256;
  Math_16bits_Print_ACUMULADOR;
  Math_16bits_CARGA_B;
  ACUMULADOR := Math_16bits_MODULO;
  LCD_GotoXY(3,14);
  LCD_WriteChar('=');
  Math_16bits_Print_ACUMULADOR;
 
  delay_ms(3000);
  LCD_Clear;  

  prueba_Math_16bits_Print_ACUMULADOR_DEC;
 
end.
