{
*  (C) AguHDz 01-AGO-2017
*  Ultima Actualizacion: 01-AGO-2017
*
*  Compilador PicPas v.0.7.2 (https://github.com/t-edson/PicPas)
*
*  PRUEBA DE LIBRERIA UARTSoftLib_8MHz_9600bps
*  ===================================================
*  Se puede usar para depurar código enviando el valor
*  de variables del programa por le puerto serie.
}

{$PROCESSOR PIC16F84A}
{$FREQUENCY 8Mhz}

program TEST_Debug_Serial_comm;

uses PIC16F84A, UARTSoftLib_8MHz_4800bps; 

const
  RETORNO_CARRO   = 0;
  HOLA_MUNDO      = 1;
  COMO_ESTA_USTED = 2;
  BIEN            = 3;
  MAL             = 4;
  GRACIAS         = 5;
  TEST_DEBUG      = 6;
  NUMERO_LED      = 7;
  ON_OFF          = 8;  

var
  // Es necesario definirlo aquí y en la librería.
  // Aunque aquí no debería ser necesario, en la versión 0.7.2 de PicPas
  // si no definen aquí también los pin genera las variables
  // #define UART_RX 0x000,0
  // #define UART_TX 0x000,0
  // que impiden que el programa compilado funcione correctemente.
  UART_RX : bit absolute PORTB_RB7;
  UART_TX : bit absolute PORTB_RB6;
  // -------------------------------------------------------------
  
  prueba           : word;
  caracter_entrada : char;
  pin_led          : char;
  encender         : bit;
  
Procedure Print_String(cadena : byte);
begin
 if(cadena=RETORNO_CARRO) then
    UARTSoft_SendChar(LF);     // Salto de Linea.
    UARTSoft_SendChar(CR);     // Retorno de Carro.
 elsif(cadena=HOLA_MUNDO) then
    UARTSoft_SendChar('H');
    UARTSoft_SendChar('O');
    UARTSoft_SendChar('L');
    UARTSoft_SendChar('A');
    UARTSoft_SendChar(' ');
    UARTSoft_SendChar('M');
    UARTSoft_SendChar('U');
    UARTSoft_SendChar('N');
    UARTSoft_SendChar('D');
    UARTSoft_SendChar('O');
    UARTSoft_SendChar(LF);     // Salto de Linea.
    UARTSoft_SendChar(CR);     // Retorno de Carro.
 elsif(cadena=COMO_ESTA_USTED) then
    UARTSoft_SendChar('C');
    UARTSoft_SendChar('O');
    UARTSoft_SendChar('M');
    UARTSoft_SendChar('O');
    UARTSoft_SendChar(' ');
    UARTSoft_SendChar('E');
    UARTSoft_SendChar('S');
    UARTSoft_SendChar('T');
    UARTSoft_SendChar('A');
    UARTSoft_SendChar(' ');
    UARTSoft_SendChar('U');
    UARTSoft_SendChar('S');
    UARTSoft_SendChar('T');
    UARTSoft_SendChar('E');
    UARTSoft_SendChar('D');
    UARTSoft_SendChar(LF);     // Salto de Linea.
    UARTSoft_SendChar(CR);     // Retorno de Carro.
 elsif(cadena=BIEN) then
    UARTSoft_SendChar('B');
    UARTSoft_SendChar('I');
    UARTSoft_SendChar('E');
    UARTSoft_SendChar('N');
    UARTSoft_SendChar(LF);     // Salto de Linea.
    UARTSoft_SendChar(CR);     // Retorno de Carro.
 elsif(cadena=MAL) then
    UARTSoft_SendChar('M');
    UARTSoft_SendChar('A');
    UARTSoft_SendChar('L');
    UARTSoft_SendChar(LF);     // Salto de Linea.
    UARTSoft_SendChar(CR);     // Retorno de Carro.
 elsif(cadena=GRACIAS) then
    UARTSoft_SendChar('G');
    UARTSoft_SendChar('R');
    UARTSoft_SendChar('A');
    UARTSoft_SendChar('C');
    UARTSoft_SendChar('I');
    UARTSoft_SendChar('A');
    UARTSoft_SendChar('S');
    UARTSoft_SendChar(LF);     // Salto de Linea.
    UARTSoft_SendChar(CR);     // Retorno de Carro.
 elsif(cadena=TEST_DEBUG) then
    UARTSoft_SendChar('T');
    UARTSoft_SendChar('E');
    UARTSoft_SendChar('S');
    UARTSoft_SendChar('T');
    UARTSoft_SendChar(' ');
    UARTSoft_SendChar('D');
    UARTSoft_SendChar('E');
    UARTSoft_SendChar('B');
    UARTSoft_SendChar('U');
    UARTSoft_SendChar('G');
    UARTSoft_SendChar(LF);     // Salto de Linea.
    UARTSoft_SendChar(CR);     // Retorno de Carro.
 elsif(cadena=NUMERO_LED) then
    UARTSoft_SendChar('L');
    UARTSoft_SendChar('E');
    UARTSoft_SendChar('D');
    UARTSoft_SendChar('(');
    UARTSoft_SendChar('0');
    UARTSoft_SendChar('-');
    UARTSoft_SendChar('4');
    UARTSoft_SendChar(')');
    UARTSoft_SendChar(':');
    UARTSoft_SendChar(' ');
 elsif(cadena=ON_OFF) then
    UARTSoft_SendChar('O');
    UARTSoft_SendChar('N');
    UARTSoft_SendChar('(');
    UARTSoft_SendChar('1');
    UARTSoft_SendChar(')');
    UARTSoft_SendChar('/');
    UARTSoft_SendChar('O');
    UARTSoft_SendChar('F');
    UARTSoft_SendChar('F');
    UARTSoft_SendChar('(');
    UARTSoft_SendChar('0');
    UARTSoft_SendChar(')');
    UARTSoft_SendChar(':');
    UARTSoft_SendChar(' ');
  end;
end;

begin

  UARTSoft_Init;             // Inicializa puertos de comunicacion TX y RX. 
   
  Print_String(TEST_DEBUG);
  
  prueba.low:=10;
  repeat
    UARTSoft_SendChar('=');
    dec(prueba.low)
  until(prueba.low=0);  
  Print_String(RETORNO_CARRO);
  
  Print_String(HOLA_MUNDO);
  Print_String(COMO_ESTA_USTED);
  Print_String(BIEN);
  Print_String(MAL);
  Print_String(GRACIAS);
  
  prueba:= 12345;
  UARTSoft_Print_Number_Word(prueba);
  
  prueba:= 45;
  UARTSoft_Print_Number_Word(prueba);
  
  prueba.low:= 90;
  UARTSoft_Print_Number_Byte(prueba.low);
  
  SetAsOutput(PORTA_RA0);  
  SetAsOutput(PORTA_RA1);  
  SetAsOutput(PORTA_RA2);  
  SetAsOutput(PORTA_RA3);
  PORTA_RA0 := 0;
  PORTA_RA1 := 0;
  PORTA_RA2 := 0;
  PORTA_RA3 := 0;
  
  repeat
    // Número de LED?
    Print_String(NUMERO_LED);
    pin_led := UARTSoft_GetChar;
    UARTSoft_SendChar(pin_led);
    Print_String(RETORNO_CARRO);
    // Apagar o Encender?
    Print_String(ON_OFF);
    caracter_entrada := UARTSoft_GetChar;    
    UARTSoft_SendChar(caracter_entrada);    
    Print_String(RETORNO_CARRO);
    // Acción a realizar en función de datos de entrada por consola serie.
    if (caracter_entrada = '1') then
      encender := 1;
    else
      encender := 0;
    end;
    if(pin_led = '0') then  // Apaga o enciende todas las salidas.
      PORTA_RA0 := encender;
      PORTA_RA1 := encender;
      PORTA_RA2 := encender;
      PORTA_RA3 := encender;
    end;      
    if(pin_led = '1') then PORTA_RA0 := encender end;
    if(pin_led = '2') then PORTA_RA1 := encender end;
    if(pin_led = '3') then PORTA_RA2 := encender end;
    if(pin_led = '4') then PORTA_RA3 := encender end;
  until false;
end.
