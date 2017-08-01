{
*  (C) AguHDz 31-JUN-2017
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
*  (solo 2 hilos de comunicacion), y una velocidad de 1200 bits por segundo.
*
*  Para modificar la velocidad de transmision o adaptarla a la velocidad del
*  microcontrolador solo seria necesario modificar el tiempo de retardo
*  con las constantes CICLOS_DELAY_1 y CICLOS_DELAY_2 en el procedimiento
*  MEDIOBITDELAY.
*
}

unit UARTSoftLib_8MHz_1200bps;

interface

uses PIC16F84A, Math_Word_Type;

const
  DataBitCount = 8;        // 8 bits de datos, sin paridad ni control de flujo.
  LF           = Chr(10);  // LF/NL	(Line Feed/New Line) - Salto de Linea.
  CR           = Chr(13);  // CR (Carriage Return) - Retorno de Carro.
  HIGH_LEVEL   = 1;        // Nivel alto (uno logico)
  LOW_LEVEL    = 0;        // Nivel bajo (cero logico)

var
  // Es encesario definirlo aquí y en el programa que use esta librería.
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
// Baudrate = 1200 bits per second (BPS)
// Delay = 0.000417 seconds (1e6/Baudrate/2).
// -----------------------------------------------------------------
procedure MedioBitDelay;
const
// -----------------------------------------------------------------
// Clock frequency = 20 MHz    
// Actual delay = 0.000417 seconds = 2085 cycles
// Error = 0 %
//   CICLOS_DELAY_1 = $9F;
//   CICLOS_DELAY_2 = $02;
// -----------------------------------------------------------------
// Clock frequency = 12 MHz    
// Actual delay = 0.000417 seconds = 1251 cycles
// Error = 0 %
//   CICLOS_DELAY_1 = $F8;
//   CICLOS_DELAY_2 = $01;
// -----------------------------------------------------------------
// Clock frequency = 10 MHz    
// Actual delay = 0.0004172 seconds = 1043 cycles
// Error = -0.0479616306954 %
//   CICLOS_DELAY_1 = $CF;
//   CICLOS_DELAY_2 = $01;
// -----------------------------------------------------------------
// Clock frequency = 8 MHz    
// Actual delay = 0.000417 seconds = 834 cycles
// Error = 0 %
   CICLOS_DELAY_1 = $A5;
   CICLOS_DELAY_2 = $01;
// -----------------------------------------------------------------
// Delay Code Generator: http://www.golovchenko.org/cgi-bin/delay 
// -----------------------------------------------------------------
var
  d1, d2 : byte;
begin
  ASM   
	          ;2078 cycles -> 20 MHz
                  ;1243 cycles -> 12 MHz
                  ;1038 cycles -> 10 MHz
                  ; 828 cycles ->  8 MHz
	          movlw	       CICLOS_DELAY_1
	          movwf	       d1
	          movlw	       CICLOS_DELAY_2
	          movwf	       d2
  Delay_0:               
	          decfsz       d1, f
	          goto         $+2
	          decfsz       d2, f
	          goto         Delay_0
                         
	          ;2 cycles    
	          goto         $+1               ; -> Para 8, 12 y 20 MHz
	          ;2 cycles    
	          ;goto         $+1               ; -> Para 12 MHz
                  ;1 cycle
                  ;nop                            ; -> Para 10 y 20 Mhz
	          ;4 cycles (call & return)
  END
end;


// -----------------------------------------------------------------
// Procedure BITDELAY
// Delay = 0.000833 seconds (1e6/Baudrate).
// -----------------------------------------------------------------
procedure BitDelay;
begin
  MedioBitDelay;  // 0.000417 seconds
  MedioBitDelay;  // 0.000417 seconds
                  // 0.000001 seconds cycles call & return.
           // TOTAL: 0.000835 seconds (Error < 0,2%)
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
    dataValue   := dataValue>>1;     // Desplaza a la derecha el dato parcialmente recibido antes de añadir un nuevo bit.
    dataValue.7 := UART_RX;          // Añade bit de datos recibido.
    BitDelay;                        // Tiempo de espera antes de detectar estado del siguiente bit de datos.
    Inc(contador);                   // Incrementa contador de bits de datos.
  until (contador = DataBitCount);   // Acaba cuando se han recibido los 8 bits de datos.
  
  // Comprueba correcta recepcion mediante bit de Stop.
  // Aquí se podría añadir en su caso la deteccion de los bits de paridad.
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
  
  if(decimales>=digitos) then      // Cualquier variable de tipo word esta compuesto como máximo por 5 números (decena millar, millar, centena, decena y unidad)
    UARTSoft_SendChar('0');            // Si hay más de 5 decimales, es necesario escribir el cero inicial y la coma de separación decimal.
    UARTSoft_SendChar(',');  
    parte_decimal := true;         // Estamos escribiendo la parte decimal de número.
    while(decimales>digitos) do    // Escribe todos los ceros decimales necesarios antes de empezar a escribir los valores del número.
      dec(decimales);
      UARTSoft_SendChar('0');
    end;      
  end;
    
  digito := 0;
  contador := digitos;             // Cualquier variable de tipo word esta compuesto como máximo por 5 números (decena millar, millar, centena, decena y unidad)

  div_dec := 1;
  repeat                           // Genera un número 10, 100, 1000 o 10000 en función de la variable de entrada con los digitos a imprimir.
    Dec(digitos);
    div_dec := Multiplicar(div_dec,10);    
  until(digitos=1);
  
  while(contador>0) do             // Inicia LOOP    
    // COMPRUEBA SI ES NECESARIO E IMPRIME SEPARADOR DE PARTE DECIMAL DEL NUMERO.     
    if((decimales = contador) AND NOT parte_decimal) then  // Si estamos en la posición de inicio de la parte decimal escribir la coma separadora. 
      if(NOT fin_ceros_izquierda) then                     // Comprueba si es necesario escribir una cero antes de la coma separadora.
        UARTSoft_SendChar('0');
      end;
      UARTSoft_SendChar(',');
      parte_decimal := true; // A partir de aquí todos los dígitos son parte decimal del número.  
    end;
    
    dec(contador);    // Se coloca aquí en vez de al final de bucle, como es habitual, para optimizar la comparación if(decimales<>contador) de más abajo.
    
    // CALCULA EL DIGITO DEL NUMERO A IMPRIMIR. 
    digito := Dividir(numero,div_dec);  // Obtiene el valor de digito del número a imprimir.
    
    // IMPRIME EL DIGITO SI ES DISTINTO DE CERO.
    if(digito.low > 0) then        // Comprueba si el dígito del número es cero 
      UARTSoft_SendChar(chr(digito.low+$30));  // Si es distinto de cero lo imprime en el display.
      fin_ceros_izquierda := true;         // Si se imprime un primer dígito distinto de cero es que ya no existen ceros no a la izquierda del número.
    // SI EL DIGITO ES CERO, DEPENDIENDO DE LA SITUACION SE IMPRIMIRAN DISTINTOS TIPOS DE CARACTERES O NO SE IMPRIMIRA NINGUNO.
    else
      if(parte_decimal OR fin_ceros_izquierda OR (contador = 0)) then  // Si el dígito de valor cero está en la parte decimal, no es un cero a la izquierda, el  lo imprime.
        UARTSoft_SendChar('0');
      elsif(caracter_derecha <> chr(0)) then  // Si se trata de un cero a la izquierda (en la parte no decimal) y se ha indicado que se desea escribir        
        if(decimales<>contador) then          // algún caracter como el propio cero o un espacio de justificación, lo imprime.
          UARTSoft_SendChar(caracter_derecha)     // La comprobación (decimales<>contador) es necesaria para evitar conflicto con la impresión de valores 0,XX
        end; 
      end;                                    // Si no, no imprime nada.   
    end;
    
    // CALCULO DE VARIABLES NECESARIAS PARA OBTENER EL SIGUIENTE DIGITO A IMPRIMIR.
    numero := Resto_Dividir(numero,div_dec);  // Realiza calculo de resto de división, eliminando el valor de dígito ya impreso.
    div_dec := Dividir(div_dec,word(10));     // Calcula el nuevo divisor para extraer el siguiente dígito del número.
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
