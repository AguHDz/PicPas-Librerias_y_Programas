{
*  (C) AguHDz 27-JUN-2017
*  Ultima Actualizacion: 01-AGO-2017
*
*  Compilador PicPas v.0.7.1 (https://github.com/t-edson/PicPas)
*
*  COMUNICACION SERIE RS232 (UART) MEDIANTE SOFTWARE USANDO LIBRERIA
*  =================================================================
*  Envio y recepcion de caracteres ASCII mediante puerto serie RS232
*
*
}

{$PROCESSOR PIC16F84A}
{$FREQUENCY 16Mhz}

program TEST_Debug_Serial_comm;

uses PIC16F84A, UARTSoftLib_16MHz_9600bps; 

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
  
  prueba : word;
  
begin

  UARTSoft_Init;             // Inicializa puertos de comunicacion TX y RX.  
  UARTSoft_SendChar('T');    // Mensaje HOLA MUNDO
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
  
  prueba:= 12345;
  UARTSoft_Print_Number(prueba, 8, 5, '0');  
  UARTSoft_SendChar(LF);     // Salto de Linea.
  UARTSoft_SendChar(CR);     // Retorno de Carro.
  
  prueba:= 345;
  UARTSoft_Print_Number(prueba, 0, 5, ' ');  
  UARTSoft_SendChar(LF);     // Salto de Linea.
  UARTSoft_SendChar(CR);     // Retorno de Carro.

  repeat
    UARTSoft_SendChar(UARTSoft_GetChar);  // Escribe en el terminal cada caracter recibido (ECHO)
  until false;
end.
