{
*  (C) AguHDz 01-AGO-2017
*  Ultima Actualizacion: 01-AGO-2017
*
*  Compilador PicPas v.0.7.2 (https://github.com/t-edson/PicPas)
*
*  COMUNICACION SERIE RS232 (UART) MEDIANTE SOFTWARE
*  =================================================
*  Envio y recepcion de caracteres ASCII mediante puerto serie RS232 creando una
*  UART mediante software. Cualquier pin de los puertos I/O del microcontrolador
*  es valido para configurarse como linea de Transmision (TX) o Recepcion (RX) de
*  datos.
*
*  Por defecto se utiliza el protocolo RS-232 en su configuracion mas
*  comun: 8 bits de datos, 1 bit de Stop, sin paridad ni control de flujo
*  (solo 2 hilos de comunicacion), y una velocidad de 4800 bits por segundo.
*
*  Para modificar la velocidad de transmision o adaptarla a la velocidad del
*  microcontrolador solo seria necesario modificar el tiempo de retardo
*  con las constantes CICLOS_DELAY_1 y CICLOS_DELAY_2 en el procedimiento
*  MEDIOBITDELAY.
*
}

unit UARTSoftLib_8MHz_4800bps;

interface

uses PIC16F84A, Math_Word_Type;

const
  DataBitCount = 8;        // 8 bits de datos, sin paridad ni control de flujo.
  LF           = Chr(10);  // LF/NL	(Line Feed/New Line) - Salto de Linea.
  CR           = Chr(13);  // CR (Carriage Return) - Retorno de Carro.
  HIGH_LEVEL   = 1;        // Nivel alto (uno logico)
  LOW_LEVEL    = 0;        // Nivel bajo (cero logico)

var
  // Es encesario definirlo aqu� y en el programa que use esta librer�a.
  UART_RX : bit absolute PORTB_RB7;
  UART_TX : bit absolute PORTB_RB6;
  // --------------------------------------------

procedure MedioBitDelay;
procedure BitDelay;
procedure UARTSoft_Init;
procedure UARTSoft_SendChar(register dato : char);
procedure UARTSoft_GetChar : char;
procedure UARTSoft_Print_Number(numero : word; decimales: byte; digitos: byte; caracter_derecha: char);
procedure UARTSoft_Print_Number_Word(numero : word);
procedure UARTSoft_Print_Number_Byte(numero : byte);

implementation
  
// -----------------------------------------------------------------
// Procedure MEDIOBITDELAY
// Baudrate = 9600 bits per second (BPS)
// Delay = 0.00010417 seconds (1/Baudrate/2).
// -----------------------------------------------------------------
procedure MedioBitDelay;
const
// -----------------------------------------------------------------
// Clock frequency = 20 MHz    
// Actual delay = 0.00010417 seconds = 517 cycles
// CICLOS_DELAY_1 = $AC;
// -----------------------------------------------------------------
// Clock frequency = 16 MHz    
// Actual delay = 0.00010417 seconds = 412 cycles
//   CICLOS_DELAY_1 = $89;
// -----------------------------------------------------------------
// Clock frequency = 12 MHz    
// Actual delay = 0.00010417 seconds = 307 cycles
//   CICLOS_DELAY_1 = $66;
// -----------------------------------------------------------------
// Clock frequency = 10 MHz    
// Actual delay = 0.00010417 seconds = 256 cycles
//   CICLOS_DELAY_1 = $55;
// -----------------------------------------------------------------
// Clock frequency = 8 MHz    
// Actual delay = 0.00010417 seconds = 208 cycles
   CICLOS_DELAY_1 = $43;
// -----------------------------------------------------------------
// Clock frequency = 4 MHz    
// Actual delay = 0.00010417 seconds = 104 cycles
//   CICLOS_DELAY_1 = $21;  // (NO RECOMENDABLE)
// -----------------------------------------------------------------
// Delay Code Generator: http://www.golovchenko.org/cgi-bin/delay 
// -----------------------------------------------------------------
var
  d1 : byte;
begin
  ASM   
	          ; 517 cycles -> 20 MHz
            ; 412 cycles -> 16 MHz
            ; 307 cycles -> 12 MHz
            ; 256 cycles -> 10 MHz
            ; 208 cycles ->  8 MHz
            ; 104 cyckes ->  4 MHz (NO RECOMENDABLE)
	          movlw	       CICLOS_DELAY_1
	          movwf	       d1
  Delay_0:               
	          decfsz       d1, f
	          goto         Delay_0
            
            goto $+1                          ; 8 y 12 MHz
            ;nop                               ; 16 MHz

	          ;4 cycles (call & return)
  END
end;

// -----------------------------------------------------------------
// Procedure BITDELAY
// Delay = 0.00005208333 seconds (1/Baudrate).
// -----------------------------------------------------------------
procedure BitDelay;
begin
  MedioBitDelay;  // 0.00010417 seconds
  MedioBitDelay;  // 0.00010417 seconds
end;

// -----------------------------------------------------------------
// Procedure UARTSOFT_INIT
// Inicializa los pines de comunicacion serie.
// -----------------------------------------------------------------
procedure UARTSoft_Init;
begin
  SetAsOutput(UART_TX);    // Salida.
  SetAsInput(UART_RX);     // Entrada.
  UART_Tx := HIGH_LEVEL;   // Pone a 1 la linea TX.
end;

// -----------------------------------------------------------------
// Procedure UARTSOFT_SENTCHAR
// Envia un caracter enviado por el puerto serie (UART).
// -----------------------------------------------------------------
procedure UARTSoft_SendChar(register dato : char);
var
  contador, dataValue : byte;
begin
  dataValue := Ord(dato);            // Conversion de caracter de entrada a variable tipo byte.
  contador  := 0;                    // Inicializa contador de bits de datos.
  UART_TX   := LOW_LEVEL;            // Comienza la transmision.
  BitDelay;                          // Tiempo en nivel logico bajo de la linea de transmision (TX).
  
  repeat                             // Envia los 8 bits de datos.
    UART_TX   := dataValue.0;        // La linea de transmision toma el estado del bit de datos correspondiente.
    BitDelay;                        // Espera con estado de bit de datos en el linea de transmision (TX).
    dataValue := dataValue>>1;       // Desplaza a la derecha el byte de datos para en siguiente vuelta enviar el bit.
    Inc(contador);                   // Incrementa contador de bits de datos.
  until (contador = DataBitCount);   // Acaba cuando se han transmitido los 8 bits de datos.
  
  UART_TX  := HIGH_LEVEL;            // Envia el bit de Stop.
  BitDelay;                          // Espera con estado de bits de Stop en linea de transmision (TX).
end;


// -----------------------------------------------------------------
// Procedure UARTSOFT_GETCHAR
// Espera y lee un caracter enviado por el puerto serie (UART).
// -----------------------------------------------------------------
procedure UARTSoft_GetChar : char;
var
  contador, dataValue : byte;
begin
  contador  := 0;                    // Inicializa contador de bits de datos.
  dataValue := 0;                    // Inicializa a cero la variable que va a contener el byte recibido.
  repeat until(UART_RX = LOW_LEVEL); // Espera hasta deteccion de inicio la transmision.
  BitDelay;                          // Espera el tiempo del bit de inicio de transmision.
  MedioBitDelay;                     // Espera 1/2 tiempo de transmision para hacer la lectura en un punto central del pulso.

  repeat                             // Recibe los 8 bits de datos.
    dataValue   := dataValue>>1;     // Desplaza a la derecha el dato parcialmente recibido antes de a�adir un nuevo bit.
    dataValue.7 := UART_RX;          // A�ade bit de datos recibido.
    BitDelay;                        // Tiempo de espera antes de detectar estado del siguiente bit de datos.
    Inc(contador);                   // Incrementa contador de bits de datos.
  until (contador = DataBitCount);   // Acaba cuando se han recibido los 8 bits de datos.
  
  // Comprueba correcta recepcion mediante bit de Stop.
  // Aqu� se podr�a a�adir en su caso la deteccion de los bits de paridad.
  if (UART_RX = HIGH_LEVEL) then     // Bit de Stop debe ser un uno logico.
    MedioBitDelay;                   // Espera final para completar el tiempo de la trama de bits completa.
    exit(Chr(DataValue));            // Devuelve el dato leido.
  else                               // Ha ocurrido algun error !
    MedioBitDelay;                   // Espera final para completar el tiempo de la trama de bits completa.
    exit(Chr(0));                    // Si detecta error devuelve el valor cero.
  end;
end; 

//-----------------------------------------------------------------------------
procedure UARTSoft_Print_Number(numero : word; decimales: byte; digitos: byte; caracter_derecha: char);
var
  digito              : word;      // Variable auxiliar que contien el digito a imprimir (decena millar, millar, centena, decena y unidad)
  div_dec             : word;      // Variable auxiliar por la que dividir para obtener cada uno de los digitos.
  contador            : byte;      // Contador de bucle.
  parte_decimal       : boolean;   // flag que indica que se estan escribiendo la parte decimal del numero.
  fin_ceros_izquierda : boolean;   // flag que indica que se han acabado los ceros a la izquierda del numero.
begin
  fin_ceros_izquierda := false;    // Escribir ceros a la izquierda del numero (valores ceros a la izquierda)
  parte_decimal       := false;    // No estamos escribiendo la parte decimal del numero.
  
  if(decimales>=digitos) then      // Cualquier variable de tipo word esta compuesto como m�ximo por 5 n�meros (decena millar, millar, centena, decena y unidad)
    UARTSoft_SendChar('0');            // Si hay m�s de 5 decimales, es necesario escribir el cero inicial y la coma de separaci�n decimal.
    UARTSoft_SendChar(',');  
    parte_decimal := true;         // Estamos escribiendo la parte decimal de n�mero.
    while(decimales>digitos) do    // Escribe todos los ceros decimales necesarios antes de empezar a escribir los valores del n�mero.
      dec(decimales);
      UARTSoft_SendChar('0');
    end;      
  end;
    
  digito := 0;
  contador := digitos;             // Cualquier variable de tipo word esta compuesto como m�ximo por 5 n�meros (decena millar, millar, centena, decena y unidad)

  div_dec := 1;
  repeat                           // Genera un n�mero 10, 100, 1000 o 10000 en funci�n de la variable de entrada con los digitos a imprimir.
    Dec(digitos);
    div_dec := Multiplicar(div_dec,10);    
  until(digitos=1);
  
  while(contador>0) do             // Inicia LOOP    
    // COMPRUEBA SI ES NECESARIO E IMPRIME SEPARADOR DE PARTE DECIMAL DEL NUMERO.     
    if((decimales = contador) AND NOT parte_decimal) then  // Si estamos en la posici�n de inicio de la parte decimal escribir la coma separadora. 
      if(NOT fin_ceros_izquierda) then                     // Comprueba si es necesario escribir una cero antes de la coma separadora.
        UARTSoft_SendChar('0');
      end;
      UARTSoft_SendChar(',');
      parte_decimal := true; // A partir de aqu� todos los d�gitos son parte decimal del n�mero.  
    end;
    
    dec(contador);    // Se coloca aqu� en vez de al final de bucle, como es habitual, para optimizar la comparaci�n if(decimales<>contador) de m�s abajo.
    
    // CALCULA EL DIGITO DEL NUMERO A IMPRIMIR. 
    digito := Dividir(numero,div_dec);  // Obtiene el valor de digito del n�mero a imprimir.
    
    // IMPRIME EL DIGITO SI ES DISTINTO DE CERO.
    if(digito.low > 0) then        // Comprueba si el d�gito del n�mero es cero 
      UARTSoft_SendChar(chr(digito.low+$30));  // Si es distinto de cero lo imprime en el display.
      fin_ceros_izquierda := true;         // Si se imprime un primer d�gito distinto de cero es que ya no existen ceros no a la izquierda del n�mero.
    // SI EL DIGITO ES CERO, DEPENDIENDO DE LA SITUACION SE IMPRIMIRAN DISTINTOS TIPOS DE CARACTERES O NO SE IMPRIMIRA NINGUNO.
    else
      if(parte_decimal OR fin_ceros_izquierda OR (contador = 0)) then  // Si el d�gito de valor cero est� en la parte decimal, no es un cero a la izquierda, el  lo imprime.
        UARTSoft_SendChar('0');
      elsif(caracter_derecha <> chr(0)) then  // Si se trata de un cero a la izquierda (en la parte no decimal) y se ha indicado que se desea escribir        
        if(decimales<>contador) then          // alg�n caracter como el propio cero o un espacio de justificaci�n, lo imprime.
          UARTSoft_SendChar(caracter_derecha)     // La comprobaci�n (decimales<>contador) es necesaria para evitar conflicto con la impresi�n de valores 0,XX
        end; 
      end;                                    // Si no, no imprime nada.   
    end;
    
    // CALCULO DE VARIABLES NECESARIAS PARA OBTENER EL SIGUIENTE DIGITO A IMPRIMIR.
    numero := Resto_Dividir(numero,div_dec);  // Realiza calculo de resto de divisi�n, eliminando el valor de d�gito ya impreso.
    div_dec := Dividir(div_dec,word(10));     // Calcula el nuevo divisor para extraer el siguiente d�gito del n�mero.
  end;    
end;

//-----------------------------------------------------------------------------
procedure UARTSoft_Print_Number_Word(numero : word);
begin
  UARTSoft_Print_Number(numero, 0, 5, Chr(0));  
  UARTSoft_SendChar(LF);     // Salto de Linea.
  UARTSoft_SendChar(CR);     // Retorno de Carro.
end; 

//-----------------------------------------------------------------------------
procedure UARTSoft_Print_Number_Byte(numero : byte);
var
  aux : word;
begin
  aux.low  := numero;
  aux.high := 0;
  UARTSoft_Print_Number(aux, 0, 5, Chr(0));  
  UARTSoft_SendChar(LF);     // Salto de Linea.
  UARTSoft_SendChar(CR);     // Retorno de Carro.
end;
//-----------------------------------------------------------------------------
 
end.
