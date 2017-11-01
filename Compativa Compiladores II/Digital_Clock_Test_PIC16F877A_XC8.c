/*
*  (C) AguHDz 20-OCT-2017
*  Ultima Actualizacion: 01-NOV-2017
*
*  Compilador XC8 v.1.43 (http://www.microchip.com)
*
*  Microcontrolador: PIC16F877A
*
*  RELOJ DIGITAL (TEST COMPARACION COMPILADORES)
*  =============================================
*  Este proyecto es una demostraci�n del uso del compilador XC8 con
*  el microcontrolador PIC16F877A para hacer un reloj de tiempo real con
*  el integrado DS1307.
*
*  Se trata de un reloj totalmente funcional con tres botones de ajuste
*  SET, INC y DEC.
*
*  Ajuste:
*
*  1. Pulsar SET durante 1 segundo.
*  2. Aparece el cursor bajo los d�gitos de a�o. Pulsar INC para
*     incremetar el a�o o DEC para decrementarlo. Cada pulsaci�n
*     produce el avance o retroceso de una unidad del digito
*     editado. La pulsaci�n larga permite un avance o retroceso
*     repetitivo haciendo m�s c�modo el ajuste.
*  3. Pulsar SET para pasar a la edici�n del mes y proceder del
*     mismo modo que en el ajuste del a�o pulsando INC o DEC.
*  4. Pulsar SET para ajustar del mismo modo el d�a del mes, hora,
*     y minutos. (los segundos siempre se inIcian a cero despu�s
*     de cada ajuste)
*  5. Tras ajustar minutos y pulsar SET se pasa a la edici�n del
*     d�a de la semana (LUN...DOM). Proceder de igual manera
*     pulsando INC o DEC.
*  6. Pulsar SET para finalizar ajuste. El reloj comienza a funcionar
*     con la nueva hora y d�a.
*
*  NOTAS:
*  - Durante la edici�n, llegado al l�mete inferior o superior del
*    d�gito editado se pasa autom�ticamente al valor inferior o
*    superior. L�mites:
*        - A�o: 00..99
*        - Mes: 01..12
*        - D�a: 01..31 (28, 29 o 30 dependiendo del mes)
*        - Hora: 00..23
*        - Minuto: 00..59
*        - D�a de Semana: LUN..DOM
*  - El l�mite superior del mes de febrero para a�os bisiestos
*    y los meses de 30 y 31 d�as los ajusta el programa de manera
*    autom�tica. En caso de error en la edici�n, corrige el valor
*    de manera autom�tica al l�mite superior v�lido para el mes.
*  - El integrado DS1307 es un reloj de tiempo real que funciona
*    de manera aut�noma, y que sigue funcionando gracias a su bater�a
*    sin necesidad de suministro el�ctrico exterior, por lo que no es
*    necesario ajustar el reloj cada vez que se desconecta la
*    alimentaci�n. Gracias a su bajo consumo, con una bater�a
*    tipo bot�n est�ndar de 48mAh puede seguir funcionando durante
*    m�s de 10 a�os sin necesidad de suministro el�ctrico exterior.
*/

// CONFIG
#pragma config FOSC = HS        // Oscillator Selection bits (HS oscillator)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled)
#pragma config PWRTE = ON       // Power-up Timer Enable bit (PWRT enabled)
#pragma config BOREN = ON       // Brown-out Reset Enable bit (BOR enabled)
#pragma config LVP = ON         // Low-Voltage (Single-Supply) In-Circuit Serial Programming Enable bit (RB3/PGM pin has PGM function; low-voltage programming enabled)
#pragma config CPD = OFF        // Data EEPROM Memory Code Protection bit (Data EEPROM code protection off)
#pragma config WRT = OFF        // Flash Program Memory Write Enable bits (Write protection off; all program memory may be written to by EECON control)
#pragma config CP = OFF         // Flash Program Memory Code Protection bit (Code protection off)
// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.

#include <xc.h>
#include <stdint.h>                // Define variables del modo est�ndar uint8_t, int16_t...
#include <stdbool.h>               // Define el tipo de dato a bit (bool o boolean)

/************************************************************************************************/
/******************************** D E F I N I C I O N E S ***************************************/
/************************************************************************************************/
//
// __I/O pin & estados_________________________________________________________
#define INPUT_PIN           1           // Pin de entrada.
#define OUTPUT_PIN          0           // Pin de salida.
#define HIGH_ST             1           // Estado digital alto (HIGH)
#define LOW_ST              0           // Estado digital bajo (LOW)
//
// __delay_ms()________________________________________________________________
#define _XTAL_FREQ          4000000L    // 4 MHz
//
// __RTC DS1307________________________________________________________________
#define DS1307_CONF         0x90        // 1 Hz en salida SOUT del DS1307.
#define SOUT                RA3         // Pin que lee la salida SOUT
#define SOUT_DIR            TRISA3
//
// __Comunicaci�n I2C__________________________________________________________
#define SDA                 RB0         // Pin SDA del bus I2C
#define SCL                 RB1         // Pin SCL del bus I2C
#define SDA_DIR             TRISB0
#define SCL_DIR             TRISB1
#define SDA_HIGH            SDA = 1     // SDA nivel alto. (HIGH)
#define SDA_LOW             SDA = 0     // SDA nivel bajo. (LOW)
#define SDA_INPUT           SDA_DIR = 1 // SDA como entrada.
#define SDA_OUTPUT          SDA_DIR = 0 // SDA como salida.
#define SCL_OUTPUT          SCL_DIR = 0 // SCL como salida.
#define SCL_HIGH            SCL = 1     // SCL nivel alto.
#define SCL_LOW             SCL = 0     // SCL nivel bajo.
//
// __Pulsadores________________________________________________________________
#define P_INC               RA0    // Pulsador INC
#define P_DEC               RA1    // Pulsador DEC
#define P_SET               RA2    // Pulsador SET
#define P_INC_DIR           TRISA0
#define P_DEC_DIR           TRISA1
#define P_SET_DIR           TRISA2
#define TIEMPO_ANTIREBOTE   10     // Milisegundos espera evitar rebote mec�nico de pulsador.
#define TIEMPO_REPETICION   500    // Milisegundos pulsaci�n continua que equivale a otra pulsaci�n.
//
//__Men� de edici�n de fecha y hora____________________________________________
#define SET_ANO             1
#define SET_MES             2
#define SET_DIA             3
#define SET_HORA            4
#define SET_MINUTO          5
#define SET_DIA_SEM         6
#define SALIR_SET_TIME      7
//
// __Display LCD_______________________________________________________________
// Bus de datos de 4 bits.
#define LCD_DATA_4          RB4         // Pines de datos
#define LCD_DATA_5          RB5
#define LCD_DATA_6          RB6
#define LCD_DATA_7          RB7
#define LCD_RS              RB2         // Pin RS
#define LCD_EN              RB3         // Pin Enable
#define LCD_DATA_4_DIR      TRISB4
#define LCD_DATA_5_DIR      TRISB5
#define LCD_DATA_6_DIR      TRISB6
#define LCD_DATA_7_DIR      TRISB7
#define LCD_RS_DIR          TRISB2
#define LCD_EN_DIR          TRISB3
// Valores de RS.
#define LCD_CmdMode   0    // Indicador env�o de Comando (instrucci�n de configuraci�n)
#define LCD_CharMode  1    // Indicador env�o de Dato (car�cter)
// ---------------------------------------------------------------------------
// COMANDOS PARA DISPLAY LCD COMPATIBLE CON ESTANDAR HITACHI HD44780
// ---------------------------------------------------------------------------
#define LCD_CMD_CLEAR_DISPLAY               0x01

#define LCD_CMD_DISPLAY_AND_CURSOR_HOME     0x02

#define LCD_CMD_CHARACTER_ENTRY_MODE        0x04
#define     LCD_CMD_INCREMENT               0x02
#define     LCD_CMD_DECREMENT               0x00
#define     LCD_CMD_DISPLAY_SHIFT_ON        0x01
#define     LCD_CMD_DISPLAY_SHIFT_OFF       0x00

#define LCD_CMD_DISPLAY_ON_OFF_AND_CURSOR   0x08
#define     LCD_CMD_DISPLAY_ON              0x04
#define     LCD_CMD_DISPLAY_OFF             0x00
#define     LCD_CMD_CURSOR_UNDERLINE_ON     0x02
#define     LCD_CMD_CURSOR_UNDERLINE_OFF    0x00
#define     LCD_CMD_CURSOR_BLINK_ON         0x01
#define     LCD_CMD_CURSOR_BLINK_OFF        0x00

#define LCD_CMD_DISPLAY_AND_CURSOR_SHIFT    0x10
#define     LCD_CMD_DISPLAY_SHIFT           0x08
#define     LCD_CMD_CURSOR_MOVE             0x00
#define     LCD_CMD_RIGHT                   0x04
#define     LCD_CMD_LEFT                    0x00

#define LCD_CMD_FUNCTION_SET                0x20
#define     LCD_CMD_8BIT_INTERFACE          0x10
#define     LCD_CMD_4BIT_INTERFACE          0x00
#define     LCD_CMD_2LINES                  0x08
#define     LCD_CMD_1LINE                   0x00
#define     LCD_CMD_F_FONT_5_10             0x02
#define     LCD_CMD_F_FONT_5_8              0x00

#define LCD_CMD_SET_DISPLAY_ADDRESS         0x80
#define     LCD_CMD_ROW_0                   0x00
#define     LCD_CMD_ROW_1                   0x40
#define     LCD_CMD_ROW_2                   0x14
#define     LCD_CMD_ROW_3                   0x54

#define LCD_CMD_SET_CGRAM_ADDRESS           0x40

#define LCD_CURSOR_HOME \
    LCD_CMD_DISPLAY_AND_CURSOR_HOME

#define LCD_CLEAR \
    LCD_CMD_CLEAR_DISPLAY

#define LCD_CURSOR_UNDELINE \
    LCD_CMD_DISPLAY_ON_OFF_AND_CURSOR + LCD_CMD_DISPLAY_ON + \
    LCD_CMD_CURSOR_UNDERLINE_ON

#define LCD_CURSOR_BLINK \
    LCD_CMD_DISPLAY_ON_OFF_AND_CURSOR + LCD_CMD_DISPLAY_ON + \
    LCD_CMD_CURSOR_BLINK_ON

#define LCD_CURSOR_UNDERLINE_BLINK \
    LCD_CMD_DISPLAY_ON_OFF_AND_CURSOR + LCD_CMD_DISPLAY_ON + \
    LCD_CMD_CURSOR_UNDERLINE_ON + LCD_CMD_CURSOR_BLINK_ON

#define LCD_CURSOR_OFF \
    LCD_CMD_DISPLAY_ON_OFF_AND_CURSOR + LCD_CMD_DISPLAY_ON + \
    LCD_CMD_CURSOR_UNDERLINE_OFF + LCD_CMD_CURSOR_BLINK_OFF

#define LCD_ON \
    LCD_CMD_DISPLAY_ON_OFF_AND_CURSOR + LCD_CMD_DISPLAY_ON

#define LCD_OFF \
    LCD_CMD_DISPLAY_ON_OFF_AND_CURSOR + LCD_CMD_DISPLAY_OFF

#define LCD_DISPLAY_SHIFT_RIGHT \
    LCD_CMD_DISPLAY_AND_CURSOR_SHIFT + LCD_CMD_DISPLAY_SHIFT + LCD_CMD_RIGHT

#define LCD_DISPLAY_SHIFT_LEFT \
  LCD_CMD_DISPLAY_AND_CURSOR_SHIFT + LCD_CMD_DISPLAY_SHIFT + LCD_CMD_LEFT

#define LCD_DISPLAY_CURSOR_RIGHT \
    LCD_CMD_DISPLAY_AND_CURSOR_SHIFT + LCD_CMD_CURSOR_MOVE + LCD_CMD_RIGHT

#define LCD_DISPLAY_CURSOR_LEFT \
    LCD_CMD_DISPLAY_AND_CURSOR_SHIFT + LCD_CMD_CURSOR_MOVE + LCD_CMD_LEFT
// ---------------------------------------------------------------------------


/************************************************************************************************/
/************************** V A R I A B L E S   G L O B A L E S  ********************************/
/************************************************************************************************/

// RTC DS1307
uint8_t  DS1307_DiaSemana;      // D�a de la semana (formato num�rico 1..7)
uint8_t  DS1307_Dia;            // D�a del mes.
uint8_t  DS1307_Mes;            // Mes del a�o.
uint8_t  DS1307_Ano;            // A�o (solo dos d�gitos)
uint8_t  DS1307_Hora;           // Hora del d�a.
uint8_t  DS1307_Minuto;         // Minuto de la hora.
uint8_t  DS1307_Segundo;        // Segundo del minuto.

// Men� edici�n de fecha y hora.
uint8_t editMenuState;          // Posici�n o estado dentro del men� de edici�n.


/************************************************************************************************/
/********************************** F U N C I O N E S *******************************************/
/************************************************************************************************/

/****************************************************************************
  Funciones de manejo de display LCD 16x4
*****************************************************************************/
void LCD_send4Bits(uint8_t date)
{
    LCD_DATA_4 = (date & 0x10) == 0x10;
    LCD_DATA_5 = (date & 0x20) == 0x20;
    LCD_DATA_6 = (date & 0x40) == 0x40;
    LCD_DATA_7 = (date & 0x80) == 0x80;
    LCD_EN     = HIGH_ST;
    __delay_ms(2);
    LCD_EN     = LOW_ST;
    __delay_ms(2);
}

void LCD_send(uint8_t date)
{
    LCD_send4Bits(date);
    LCD_send4Bits(date<<4);
}

void LCD_command(uint8_t comm)
{
    LCD_RS = LCD_CmdMode;
    LCD_send(comm);
}

void LCD_putChar(uint8_t date)
{
    LCD_RS = LCD_CharMode;
    LCD_send(date);
}

void LCD_gotoXY(uint8_t columna, uint8_t fila)
{
  if(fila == 0)
    LCD_command(LCD_CMD_SET_DISPLAY_ADDRESS + columna + LCD_CMD_ROW_0);
  else
    LCD_command(LCD_CMD_SET_DISPLAY_ADDRESS + columna + LCD_CMD_ROW_1);
}

void LCD_init(void)
{
    LCD_DATA_4_DIR = OUTPUT_PIN;   // Pines iniciados como Salidas.
    LCD_DATA_5_DIR = OUTPUT_PIN;
    LCD_DATA_6_DIR = OUTPUT_PIN;
    LCD_DATA_7_DIR = OUTPUT_PIN;
    LCD_RS_DIR     = OUTPUT_PIN;
    LCD_EN_DIR     = OUTPUT_PIN;

    __delay_ms(200);   // Espera para asegurar tensi�n estable tras inicio.
    LCD_RS = LOW_ST;
    LCD_EN = LOW_ST;

    // INICIALIZACION POR SOFTWARE DE DISPLAY LCD.
    // Los tiempos de espera y secuencia de datos son los indicados en todos los
    // datasheets de los displays compatibles con el est�ndar Hitachi HD44780.
    __delay_ms(30);    // Espera >= 15 ms
    // INICIACION DE DISPLAY MODO 4 BITS DE DATOS.
    LCD_send4Bits(0b00110000);
    __delay_ms(5);    // Espera >= 4.1 ms
    LCD_send4Bits(0b00110000);
    __delay_ms(1);    // Espera >= 100 us
    LCD_send4Bits(0b00110000);
    LCD_send4Bits(0b00100000);
    LCD_command(LCD_CMD_FUNCTION_SET + LCD_CMD_4BIT_INTERFACE + LCD_CMD_2LINES + LCD_CMD_F_FONT_5_8);
    // FIN DE INICIALIZACION POR SOFTWARE DEL DISPLAY LCD.

    // CONFIGURACION DE DISPLAY LCD.
    LCD_command(LCD_OFF);
    LCD_command(LCD_CMD_CHARACTER_ENTRY_MODE + LCD_CMD_INCREMENT + LCD_CMD_DISPLAY_SHIFT_OFF);
    LCD_command(LCD_ON);
    LCD_command(LCD_CLEAR);
}

/****************************************************************************
  Funciones de comunicaci�n I2C mediante software.
*****************************************************************************/
void I2C_start(void)     // START function for communicate I2C
{
    SDA_HIGH;
    SCL_HIGH;
    SCL_OUTPUT;          // Configura pines I2C como Salidas.
    SDA_OUTPUT;
    SDA_LOW;
    SCL_LOW;
}

void I2C_stop(void)     // STOP function for communicate I2C
{
    SDA_LOW;
    SCL_HIGH;
    SDA_HIGH;
}

bool I2C_writeByte(uint8_t dato)     // Send data to I2C
{
    uint8_t LoopCounter;
    bool ACKbit;

    for(LoopCounter=0; LoopCounter<8; LoopCounter++)
    {
        SDA = (dato & 0x80) == 0x80;    // SDA = bit de m�s peso del valor dato.
        SCL_HIGH;
        dato<<=1;
        SCL_LOW;
    }

    SDA_INPUT;
    SCL_HIGH;
    ACKbit = SDA;
    SCL_LOW;
    SDA_OUTPUT;
    return ACKbit;
}
uint8_t I2C_readByte(bool ACKByte)   // Receive data from I2C
{
    uint8_t LoopCounter;
    uint8_t dato=0; 

    SDA_INPUT;
    for(LoopCounter=0; LoopCounter<8; LoopCounter++)
    {
        SCL_HIGH;
        dato<<=1;
        if(SDA) dato|=1;
        SCL_LOW;
    }

    SDA_OUTPUT;
    SDA = !ACKByte;
    SCL_HIGH;
    SCL_LOW;
    return dato;
}

/****************************************************************************
  - Funci�n: BCDToDecimal
  - Descripci�n: Transforma un n�mero en formato BCD a Decimal.
  - Entrada:
      > bcdByte: N�mero en formato BCD
  - Salida: N�mero en formato Decimal.
*****************************************************************************/
uint8_t BCDToDecimal(uint8_t bcdByte)
{
    uint8_t decimal = 0;

    while(bcdByte > 0x09)
    {
        bcdByte -= 0x10;
        decimal += 10;
    }
    decimal += bcdByte;     // Suma el resto <= $09.
    return decimal;         // Devuelve valor en formato decimal.
}

/****************************************************************************
  - Funci�n: decimalToBCD
  - Descripci�n: Transforma un n�mero en formato Decimal a BCD.
  - Entrada:
      > decimalByte: N�mero en formato Decimal
  - Salida: N�mero en formato BCD.
*****************************************************************************/
uint8_t decimalToBCD (uint8_t decimalByte)
{
    uint8_t BCDByte = 0;

    while(decimalByte > 9)
    {
        BCDByte     += 0x10;
        decimalByte -= 10;
    }
    BCDByte += decimalByte;    // Suma el resto <= 9.
    return BCDByte;            // Devuelve valor en formato BCD.
}

/****************************************************************************
  - Funci�n: DS1307_timeRead
  - Descripci�n: Lee fecha y hora del DS1307 a trav�s del bus I2C.
  - Entrada: Ninguna.
  - Salida: Ninguna.
*****************************************************************************/
void DS1307_timeRead(void)
{
    I2C_start();          // Inicia comunicaci�n I2C.
    I2C_writeByte(0xD0);  // Direcci�n I2C del DS1307.
    I2C_writeByte(0x00);  // Primera direcci�n a leer/escribir.
    I2C_start();          // Reinicia comunicaci�n I2C.
    I2C_writeByte(0xD1);  // DS1307 en Modo Escritura.
    DS1307_Segundo   = BCDToDecimal(I2C_readByte(true)); // ASK = 1
    DS1307_Minuto    = BCDToDecimal(I2C_readByte(true));
    DS1307_Hora      = BCDToDecimal(I2C_readByte(true));
    DS1307_DiaSemana = I2C_readByte(true);  // Valor 1...7 (igual en decimal que en BCD)
    DS1307_Dia       = BCDToDecimal(I2C_readByte(true));
    DS1307_Mes       = BCDToDecimal(I2C_readByte(true));
    DS1307_Ano       = BCDToDecimal(I2C_readByte(false)); // ASK = 0
            // El �ltimo ASK antes del Stop debe ser sea cero (/ASK).
    I2C_stop();
}

/****************************************************************************
  - Funci�n: DS1307_timeWrite
  - Descripci�n: Escribe fecha y hora en el DS1307 a trav�s del bus I2C.
  - Entrada: Ninguna.
  - Salida: Ninguna.
*****************************************************************************/
void DS1307_timeWrite(void)
{
    I2C_start();          // Inicia comunicaci�n I2C
    I2C_writeByte(0xD0);  // Direcci�n I2C del DS1307.
    I2C_writeByte(0x00);  // Primera direcci�n a leer/escribir.
    I2C_writeByte(0);     // Siempre que se ajusta la fecha y hora los Segundos=0.
    I2C_writeByte(decimalToBCD(DS1307_Minuto));
    I2C_writeByte(decimalToBCD(DS1307_Hora));
    I2C_writeByte(DS1307_DiaSemana);  // Valor 1...7 (igual en decimal que en BCD)
    I2C_writeByte(decimalToBCD(DS1307_Dia));
    I2C_writeByte(decimalToBCD(DS1307_Mes));
    I2C_writeByte(decimalToBCD(DS1307_Ano));
    I2C_stop();
}

/****************************************************************************
  - Funci�n: LCDPrintDiaSemana
  - Descripci�n: Muesta en display LCD el d�a de la semana actual en
    formato texto.
  - Variables Entrada:
      > dia: D�a de la semana en formato num�rico (0:Domingo... 6:S�bado)
  - Variables Salida: Ninguna.
*****************************************************************************/
void LCDPrintDiaSemana(void)
{
    switch (DS1307_DiaSemana)
    {
    case 1:
        LCD_putChar('D');
        LCD_putChar('O');
        LCD_putChar('M');
        break;
    case 2:
        LCD_putChar('L');
        LCD_putChar('U');
        LCD_putChar('N');
        break;
    case 3:
        LCD_putChar('M');
        LCD_putChar('A');
        LCD_putChar('R');
        break;
    case 4:
        LCD_putChar('M');
        LCD_putChar('I');
        LCD_putChar('E');
        break;
    case 5:
        LCD_putChar('J');
        LCD_putChar('U');
        LCD_putChar('E');
        break;
    case 6:
        LCD_putChar('V');
        LCD_putChar('I');
        LCD_putChar('E');
        break;
    case 7:
        LCD_putChar('S');
        LCD_putChar('A');
        LCD_putChar('B');
        break;
    }
}

/****************************************************************************
  - Funci�n: bisiesto
  - Descripci�n: Comprueba si el a�o actual es bisiesto [margen de 2000 a 2099].
      Para otros m�rgenes de a�os, habr�a que aplicar el algoritmo gen�rico
      teniendo en cuenta los a�os m�ltiplos de 100 o 400.
  - NOTAS: Detalle curioso. Para siglos anteriores al XX, habr�a que tener en
      cuenta que en Espa�a y otros pa�ses catolicos el mes de octubre de 1582
      s�lo tuvo 20 d�as. Ese mes, el d�a siguiente al jueves 4 fue viernes 15.
      En el resto del mundo, el cambio fue produciendose en los siguientes
      siglos (hasta el XX). Por ejemplo, en Inglaterra y colonias fue en 1752
      (el d�a siguiente al 03/09/1752 fue 14/091782). Este cambio introdujo
      las reglas actuales para los a�os multiplos de 100 y 400.
  - Entrada: Ninguna.
  - Salida:
      > Devuelve 1 si el a�o es bisiesto, y 0 si no lo es.
*****************************************************************************/
bool bisiesto(void)
{
    // Devuelve 0 si (DS1307_timeAno%4)!=0, y 1 si (DS1307_timeAno%4)==0
    uint8_t dato = DS1307_Ano;

    while(dato >= 4)
    {
        dato -= 4;
    }
    if(dato == 0)
        return true;
    else
        return false;
    //return !(DS1307_Ano%4);
}

/****************************************************************************
  - Funci�n: diasDelMes
  - Descripci�n: Devuelve el n�mero de d�as de cualquier mes del a�o actual.
  - Entrada: Ninguna.
  - Salida:
      > N�mero en d�as del mes.
*****************************************************************************/
uint8_t diasDelMes(void)
{
    if(DS1307_Mes==2)             // Mes = febrero
    {
        if(bisiesto())
            return 29;
        else
            return 28;           // Bisiesto: 29 d�as / No bisiesto: 28 d�as.
    }
    else
    {
        if((DS1307_Mes==4) || (DS1307_Mes==6) || (DS1307_Mes==9) || (DS1307_Mes==11))
            return 30;            // Meses de 30 d�as.
        else
            return 31;            // Meses de 31 d�as.
    }
}

/****************************************************************************
  - Funci�n: LCDPrintNumero
  - Descripci�n: Imprime en la pantalla LCD un n�mero de 2 d�gitos.
  - Entrada:
      > numero: N�mero entre 0 y 99 a imprimir.
  - Salida: Ninguna.
*****************************************************************************/
void LCDPrintNumero(uint8_t numero)
{
    LCD_putChar((numero/10)+48);   // Imprime d�gito decena.
    LCD_putChar((numero%10)+48);   // Imprime d�gito unidad.
}

/****************************************************************************
  - Funci�n: timeShow
  - Descripci�n: Muestra en el display LCD la fecha y hora.
  - Entrada: Ninguna.
  - Salida: Ninguna.
*****************************************************************************/
void timeShow(void)
{
    LCD_gotoXY(1,0);
    LCDPrintNumero(DS1307_Dia);
    LCD_putChar('/');
    LCDPrintNumero(DS1307_Mes);
    LCD_putChar('/');
    LCDPrintNumero(DS1307_Ano);
    LCD_putChar(' ');
    LCD_putChar(' ');
    LCD_putChar(' ');
    LCDPrintDiaSemana();
    LCD_gotoXY(1,1);
    LCDPrintNumero(DS1307_Hora);
    LCD_putChar(':');
    LCDPrintNumero(DS1307_Minuto);
    LCD_putChar(':');
    LCDPrintNumero(DS1307_Segundo);
}

/****************************************************************************
  - Funci�n: cicloTimeSet
  - Descripci�n: Subfunci�n de la funci�n timeRead() que edita las variables
    del d�a y hora del reloj.
  - Entrada:
      > limInf : L�mite Inferior de la variable editada.
      > limSup : L�mite Superior de la variable editada.
      > lcdX   : Posici�n X del display en la que se muestra la variable.
      > lcdY   : Posici�n Y (fila) del display en la que se muestra la variable.
      > dato   : Dato editado.
  - Salida: El valor editado.
*****************************************************************************/
uint8_t cicloTimeSet(uint8_t limInf, uint8_t limSup, uint8_t lcdX, uint8_t lcdY, uint8_t editDato)
{
    while((P_INC && P_DEC)==LOW_ST)  // Si se pulsa INC o DEC.
    {
        LCD_command(LCD_CURSOR_OFF);
        if(P_INC==LOW_ST)            // Se ha pulsado INC.
        {
            editDato++;
            if(editDato>limSup) editDato=limInf;  // Controla que no se supere el l�mite superior.
        }
        else                    // Se ha pulsado DEC.
        {
            editDato--;
            if((editDato<limInf)||(editDato==0xFF)) editDato=limSup; // Si limInf==0 (*Dato)-- puede ser 0xFF.

        }
        LCD_gotoXY(lcdX, lcdY);          // Coloca el cursor en la posici�n de inicio de impresi�n del dato editado.
        if(editMenuState==SET_DIA_SEM)   // Si se est� editando del d�a de la semana, se imprime el texto.
        {
            DS1307_DiaSemana = editDato;
            LCDPrintDiaSemana();
        }
        else LCDPrintNumero(editDato);   // El resto son variables num�ricas de 2 d�gitos.
        __delay_ms(TIEMPO_REPETICION);   // Espera el tiempo de autorepetici�n de la tecla pulsada.
    }

    if(P_SET==LOW_ST)                // Si se pulsa SET.
    {
        editMenuState++;
        while(P_SET==LOW_ST) __delay_ms(TIEMPO_ANTIREBOTE);  // Espera antirebote mec�nico del pulsador.
        if(editDato>limSup) editDato=limSup;  // Evita posible bug al modificar el a�o o el mes, si
                                              // no se modifica el d�a y en ese a�o o mes ya no es v�lido.
    }

    if(editMenuState==SET_DIA_SEM) lcdX++;  // Si se est� editando el d�a de la semana, se desplaza el cursor
                                            // una posici�n m�s, ya que el texto ocupa 3 posiciones, en lugar
                                            // de dos como el resto de variables.
    LCD_gotoXY(++lcdX, lcdY);          // Coloca el cursor en la parte izquierda de la variable editada.
    LCD_command(LCD_CURSOR_UNDELINE);  // Cursor On
    return editDato;
}

/****************************************************************************
  - Funci�n: timeRead
  - Descripci�n: Set fecha y hora mediante pulsadores y cursor en display LCD.
    Programado seg�n la l�gica de una "m�quina de estado". La variable global
    editMenuState indica la posici�n del cursor dentro del bucle de fijaci�n de fecha y
    hora.
  - Entrada: Ninguna.
  - Salida: Ninguna.
*****************************************************************************/
void timeSet(void)
{
    LCD_gotoXY(7,1);           // Goto posici�n de Segundos en display.
    LCDPrintNumero(0);         // 00 en posici�n de Segundos del display.
    LCD_command(LCD_CURSOR_UNDELINE);       // Cursor On
    while(editMenuState<SALIR_SET_TIME)
    {
        while(editMenuState==SET_ANO)
            DS1307_Ano = cicloTimeSet(0,99,7,0,DS1307_Ano);               // Set a�o.
        while(editMenuState==SET_MES)
            DS1307_Mes = cicloTimeSet(1,12,4,0,DS1307_Mes);               // Set mes.
        while(editMenuState==SET_DIA)
            DS1307_Dia= cicloTimeSet(1,diasDelMes(),1,0,DS1307_Dia);      // Set d�a.
        while(editMenuState==SET_HORA)
            DS1307_Hora = cicloTimeSet(0,23,1,1,DS1307_Hora);             // Set hora.
        while(editMenuState==SET_MINUTO)
            DS1307_Minuto = cicloTimeSet(0,59,4,1,DS1307_Minuto);         // Set minutos.
        while(editMenuState==SET_DIA_SEM)
            DS1307_DiaSemana = cicloTimeSet(1,7,12,0,DS1307_DiaSemana);   // Set d�a de la semana.
    }
    LCD_command(LCD_CURSOR_OFF);            // Cursor Off
}

/****************************************************************************
  - Funci�n: Setup
  - Descripci�n: Inicializa Microcontrolador y Hardware externo conectado.
  - Entrada: Ninguna.
  - Salida: Ninguna.
*****************************************************************************/
void setup(void)
{
    CMCON  = 0x07;          // Deshabilita comparadores.
    ADCON1 = 0x06;          // Todos los pines configurados como digitales.
    ADCON0 = 0x00;          // Desactiva conversor A/D.
    GIE    = false;         // Todas las interrupciones desactivadas.

    P_INC_DIR = INPUT_PIN;  // Configura Pulsadores como Entradas.
    P_DEC_DIR = INPUT_PIN;
    P_SET_DIR = INPUT_PIN;
    SOUT_DIR  = INPUT_PIN;

    I2C_start();                 // Inicia comunicaci�n I2C
    I2C_writeByte(0xD0);         // Direcci�n I2C del DS1307.
    I2C_writeByte(0x07);         // Escribe en la direcci�n 07h.
    I2C_writeByte(DS1307_CONF);  // Configura 1 Hz en salida SOUT del DS1307
    I2C_stop();
    
    LCD_init();                  // Inicializa display LCD.
}

/****************************************************************************
  - Funci�n: main
  - Descripci�n: Programa Principal.
  - Entrada: Ninguna.
  - Salida: Ninguna.
*****************************************************************************/
void main(void)
{
    setup();

    while(true)
    {
        if(P_SET==LOW_ST)   // Comprueba si se ha pulsado SET
        {
            editMenuState = SET_ANO;
            // Espera fin pulsaci�n y antirebote mec�nico.
            while(P_SET==LOW_ST) __delay_ms(TIEMPO_ANTIREBOTE);
            timeSet();            // Ajuste de reloj.
            DS1307_timeWrite();   // Env�a datos editados.
        }

        DS1307_timeRead();  // Lee la fecha y hora en el DS1307.
        timeShow();         // Actualiza display LCD con fecha y hora.

        // Espera 1 segundo usando salida SOUT del DS1307 (1 Hz)
        while(SOUT);        // Espera durante pulso alto.
        while(!SOUT);       // Espera durante pulso bajo.
    }
}
