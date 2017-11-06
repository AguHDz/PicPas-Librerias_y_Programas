'
'  (C) AguHDz 30-OCT-2017
'  Ultima Actualizacion: 05-NOV-2017
'
'  Compilador Proton IDE v.3.6.0.0 (https://sites.google.com/view/rosetta-tech)
'
'  Microcontrolador: PIC16F877A
'
'  RELOJ DIGITAL (TEST COMPARACION COMPILADORES)
'  =============================================
'  Este proyecto es una demostraci�n del uso del compilador Proton IDE con
'  el microcontrolador PIC16F877A para hacer un reloj de tiempo real con
'  el integrado DS1307.
'
'  Se trata de un reloj totalmente funcional con tres botones de ajuste
'  SET, INC y DEC.
'
'  Ajuste:
'
'  1. Pulsar SET durante 1 segundo.
'  2. Aparece el cursor bajo los d�gitos de a�o. Pulsar INC para
'     incremetar el a�o o DEC para decrementarlo. Cada pulsaci�n
'     produce el avance o retroceso de una unidad del digito
'     editado. La pulsaci�n larga permite un avance o retroceso
'     repetitivo haciendo m�s c�modo el ajuste.
'  3. Pulsar SET para pasar a la edici�n del mes y proceder del
'     mismo modo que en el ajuste del a�o pulsando INC o DEC.
'  4. Pulsar SET para ajustar del mismo modo el d�a del mes, hora,
'     y minutos. (los segundos siempre se inIcian a cero despu�s
'     de cada ajuste)
'  5. Tras ajustar minutos y pulsar SET se pasa a la edici�n del
'     d�a de la semana (LUN...DOM). Proceder de igual manera
'     pulsando INC o DEC.
'  6. Pulsar SET para finalizar ajuste. El reloj comienza a funcionar
'     con la nueva hora y d�a.
'
'  NOTAS:
'  - Durante la edici�n, llegado al l�mete inferior o superior del
'    d�gito editado se pasa autom�ticamente al valor inferior o
'    superior. L�mites:
'        - A�o: 00..99
'        - Mes: 01..12
'        - D�a: 01..31 (28, 29 o 30 dependiendo del mes)
'        - Hora: 00..23
'        - Minuto: 00..59
'        - D�a de Semana: LUN..DOM
'  - El l�mite superior del mes de febrero para a�os bisiestos
'    y los meses de 30 y 31 d�as los ajusta el programa de manera
'    autom�tica. En caso de error en la edici�n, corrige el valor
'    de manera autom�tica al l�mite superior v�lido para el mes.
'  - El integrado DS1307 es un reloj de tiempo real que funciona
'    de manera aut�noma, y que sigue funcionando gracias a su bater�a
'    sin necesidad de suministro el�ctrico exterior, por lo que no es
'    necesario ajustar el reloj cada vez que se desconecta la
'    alimentaci�n. Gracias a su bajo consumo, con una bater�a
'    tipo bot�n est�ndar de 48mAh puede seguir funcionando durante
'    m�s de 10 a�os sin necesidad de suministro el�ctrico exterior.
'

Device = 16F877A
Xtal   = 4
Config HS_OSC, WDT_OFF, PWRTE_ON, BODEN_OFF, LVP_OFF, CP_OFF, CPD_OFF, DEBUG_OFF

'************************************************************************************************'
'******************************** D E F I N I C I O N E S ***************************************'
'************************************************************************************************'
'
' __I/O pin & estados_________________________________________________________
Symbol INPUT_PIN           1           ' Pin de entrada.
Symbol OUTPUT_PIN          0           ' Pin de salida.
Symbol HIGH_ST             1           ' Estado digital alto (HIGH)
Symbol LOW_ST              0           ' Estado digital bajo (LOW)
'
' __RTC DS1307________________________________________________________________
Symbol DS1307_CONF         0x90        ' 1 Hz en salida SOUT del DS1307.
Symbol SOUT                PORTA.3     ' Pin que lee la salida SOUT
'
' __Comunicaci�n I2C__________________________________________________________
Symbol SDA                 PORTB.0     ' Pin SDA del bus I2C
Symbol SCL                 PORTB.1     ' Pin SCL del bus I2C
Symbol I2C_SPEED           10          ' Depender� de la velocidad de reloj.
'
' __Pulsadores________________________________________________________________
Symbol P_INC               PORTA.0     ' Pulsador INC
Symbol P_DEC               PORTA.1     ' Pulsador DEC
Symbol P_SET               PORTA.2     ' Pulsador SET
Symbol TIEMPO_ANTIREBOTE   10          ' Milisegundos espera evitar rebote mec�nico de pulsador.
Symbol TIEMPO_REPETICION   500         ' Milisegundos pulsaci�n continua que equivale a otra pulsaci�n.
'
'__Men� de edici�n de fecha y hora____________________________________________
Symbol SET_ANO             1
Symbol SET_MES             2
Symbol SET_DIA             3
Symbol SET_HORA            4
Symbol SET_MINUTO          5
Symbol SET_DIA_SEM         6
Symbol SALIR_SET_TIME      7
'
' __Display LCD_______________________________________________________________
' Bus de datos de 4 bits.
Symbol LCD_DATA_4          PORTB.4     ' Pines de datos
Symbol LCD_DATA_5          PORTB.5
Symbol LCD_DATA_6          PORTB.6
Symbol LCD_DATA_7          PORTB.7
Symbol LCD_RS              PORTB.2     ' Pin RS
Symbol LCD_EN              PORTB.3     ' Pin Enable

' Valores de RS.
Symbol LCD_CmdMode   0    ' Indicador env�o de Comando (instrucci�n de configuraci�n)
Symbol LCD_CharMode  1    ' Indicador env�o de Dato (car�cter)
' ---------------------------------------------------------------------------
' COMANDOS PARA DISPLAY LCD COMPATIBLE CON ESTANDAR HITACHI HD44780
' ---------------------------------------------------------------------------
Symbol LCD_CMD_CLEAR_DISPLAY               0x01

Symbol LCD_CMD_DISPLAY_AND_CURSOR_HOME     0x02

Symbol LCD_CMD_CHARACTER_ENTRY_MODE        0x04
Symbol     LCD_CMD_INCREMENT               0x02
Symbol     LCD_CMD_DECREMENT               0x00
Symbol     LCD_CMD_DISPLAY_SHIFT_ON        0x01
Symbol     LCD_CMD_DISPLAY_SHIFT_OFF       0x00

Symbol LCD_CMD_DISPLAY_ON_OFF_AND_CURSOR   0x08
Symbol     LCD_CMD_DISPLAY_ON              0x04
Symbol     LCD_CMD_DISPLAY_OFF             0x00
Symbol     LCD_CMD_CURSOR_UNDERLINE_ON     0x02
Symbol     LCD_CMD_CURSOR_UNDERLINE_OFF    0x00
Symbol     LCD_CMD_CURSOR_BLINK_ON         0x01
Symbol     LCD_CMD_CURSOR_BLINK_OFF        0x00

Symbol LCD_CMD_DISPLAY_AND_CURSOR_SHIFT    0x10
Symbol     LCD_CMD_DISPLAY_SHIFT           0x08
Symbol     LCD_CMD_CURSOR_MOVE             0x00
Symbol     LCD_CMD_RIGHT                   0x04
Symbol     LCD_CMD_LEFT                    0x00

Symbol LCD_CMD_FUNCTION_SET                0x20
Symbol     LCD_CMD_8BIT_INTERFACE          0x10
Symbol     LCD_CMD_4BIT_INTERFACE          0x00
Symbol     LCD_CMD_2LINES                  0x08
Symbol     LCD_CMD_1LINE                   0x00
Symbol     LCD_CMD_F_FONT_5_10             0x02
Symbol     LCD_CMD_F_FONT_5_8              0x00

Symbol LCD_CMD_SET_DISPLAY_ADDRESS         0x80
Symbol     LCD_CMD_ROW_0                   0x00
Symbol     LCD_CMD_ROW_1                   0x40
Symbol     LCD_CMD_ROW_2                   0x14
Symbol     LCD_CMD_ROW_3                   0x54

Symbol LCD_CMD_SET_CGRAM_ADDRESS           0x40

Symbol LCD_CURSOR_HOME             LCD_CMD_DISPLAY_AND_CURSOR_HOME
Symbol LCD_CLEAR                   LCD_CMD_CLEAR_DISPLAY
Symbol LCD_CURSOR_UNDELINE         LCD_CMD_DISPLAY_ON_OFF_AND_CURSOR + LCD_CMD_DISPLAY_ON + LCD_CMD_CURSOR_UNDERLINE_ON
Symbol LCD_CURSOR_BLINK            LCD_CMD_DISPLAY_ON_OFF_AND_CURSOR + LCD_CMD_DISPLAY_ON + LCD_CMD_CURSOR_BLINK_ON
Symbol LCD_CURSOR_UNDERLINE_BLINK  LCD_CMD_DISPLAY_ON_OFF_AND_CURSOR + LCD_CMD_DISPLAY_ON + LCD_CMD_CURSOR_UNDERLINE_ON + LCD_CMD_CURSOR_BLINK_ON
Symbol LCD_CURSOR_OFF              LCD_CMD_DISPLAY_ON_OFF_AND_CURSOR + LCD_CMD_DISPLAY_ON + LCD_CMD_CURSOR_UNDERLINE_OFF + LCD_CMD_CURSOR_BLINK_OFF
Symbol LCD_ON                      LCD_CMD_DISPLAY_ON_OFF_AND_CURSOR + LCD_CMD_DISPLAY_ON
Symbol LCD_OFF                     LCD_CMD_DISPLAY_ON_OFF_AND_CURSOR + LCD_CMD_DISPLAY_OFF
Symbol LCD_DISPLAY_SHIFT_RIGHT     LCD_CMD_DISPLAY_AND_CURSOR_SHIFT + LCD_CMD_DISPLAY_SHIFT + LCD_CMD_RIGHT
Symbol LCD_DISPLAY_SHIFT_LEFT      LCD_CMD_DISPLAY_AND_CURSOR_SHIFT + LCD_CMD_DISPLAY_SHIFT + LCD_CMD_LEFT
Symbol LCD_DISPLAY_CURSOR_RIGHT    LCD_CMD_DISPLAY_AND_CURSOR_SHIFT + LCD_CMD_CURSOR_MOVE + LCD_CMD_RIGHT
Symbol LCD_DISPLAY_CURSOR_LEFT     LCD_CMD_DISPLAY_AND_CURSOR_SHIFT + LCD_CMD_CURSOR_MOVE + LCD_CMD_LEFT
' ---------------------------------------------------------------------------

'************************************************************************************************'
'************************** V A R I A B L E S   G L O B A L E S  ********************************'
'************************************************************************************************'
'
' __RTC DS1307________________________________________________________________
Dim  DS1307_DiaSemana As Byte    ' D�a de la semana (formato num�rico 1..7)
Dim  DS1307_Dia       As Byte    ' D�a del mes.
Dim  DS1307_Mes       As Byte    ' Mes del a�o.
Dim  DS1307_Ano       As Byte    ' A�o (solo dos d�gitos)
Dim  DS1307_Hora      As Byte    ' Hora del d�a.
Dim  DS1307_Minuto    As Byte    ' Minuto de la hora.
Dim  DS1307_Segundo   As Byte    ' Segundo del minuto.
'
' __Men� edici�n de fecha y hora_____________________________________________
Dim editMenuState     As Byte    ' Posici�n o estado dentro del men� de edici�n.
'
'__Par�metros de subrutinas__________________________________________________
Dim date As Byte
Dim dato As Byte
Dim caracter As Byte
Dim columna As Byte
Dim fila As Byte
Dim numero As Byte
Dim LoopCounter As Byte
Dim ACKBit As Bit
Dim EsBisiesto As Bit
Dim NumeroDecimal As Byte
Dim NumeroBCD As Byte
Dim NumeroDiasDelMes As Byte
Dim limInf As Byte
Dim limSup As Byte
Dim lcdX As Byte
Dim lcdY As Byte
Dim editDato As Byte


'************************************************************************************************'
'************************** P R O G R A M A   P R I N C I P A L  ********************************'
'************************************************************************************************'

GoSub setup

Do
    If P_SET=LOW_ST Then   ' Comprueba si se ha pulsado SET
        editMenuState = SET_ANO
        ' Espera fin pulsaci�n y antirebote mec�nico.
        While P_SET=LOW_ST
          DelayMS TIEMPO_ANTIREBOTE
        Wend
        GoSub timeSet
        GoSub DS1307_timeWrite
    End If

    GoSub DS1307_timeRead    ' Lee la fecha y hora en el DS1307.
    GoSub timeShow           ' Actualiza display LCD con fecha y hora.

    ' Espera 1 segundo usando salida SOUT del DS1307 (1 Hz)
    Do
    Loop While SOUT = 1       ' Espera durante pulso alto.

    Do
    Loop While SOUT = 0       ' Espera durante pulso bajo.

Loop


'************************************************************************************************'
'********************************** S U B R U T I N A S *****************************************'
'************************************************************************************************'

'****************************************************************************
'  Funciones de manejo de display LCD 16x4
'*****************************************************************************
'Sub LCD_send4Bits(In date As Byte)
LCD_send4Bits:
    LCD_DATA_4 = date.4
    LCD_DATA_5 = date.5
    LCD_DATA_6 = date.6
    LCD_DATA_7 = date.7
    LCD_EN     = HIGH_ST
    DelayMS 2 
    LCD_EN     = LOW_ST
    DelayMS 2 
Return
'End Sub

'Sub LCD_send(In date As Byte)
LCD_send:
    GoSub LCD_send4Bits
    date = date << 4
    'LCD_send4Bits(FnLSL(date,4))    ' date<<4
    GoSub LCD_send4Bits
Return
'End Sub

'Sub LCD_command(In date As Byte)
LCD_command:
    LCD_RS = LCD_CmdMode
    'LCD_send(date)
    date = date
    GoSub LCD_send
Return
'End Sub

'Sub LCD_putChar(In date As Byte)
LCD_putChar:
    LCD_RS = LCD_CharMode
    'LCD_send(date)
    GoSub LCD_send
Return
'End Sub

'Sub LCD_gotoXY(In columna As Byte, In fila As Byte)
LCD_gotoXY:
  If fila = 0 Then
    date = LCD_CMD_SET_DISPLAY_ADDRESS + columna + LCD_CMD_ROW_0
  Else
    date = LCD_CMD_SET_DISPLAY_ADDRESS + columna + LCD_CMD_ROW_1
  End If
  GoSub LCD_command
Return
'End Sub

'Sub LCD_init
LCD_init:
    Output LCD_DATA_4   ' Pines iniciados como Salidas.
    Output LCD_DATA_5
    Output LCD_DATA_6
    Output LCD_DATA_7
    Output LCD_RS
    Output LCD_EN

    DelayMS 200      ' Espera para asegurar tensi�n estable tras inicio.
    LCD_RS = LOW_ST
    LCD_EN = LOW_ST

    ' INICIALIZACION POR SOFTWARE DE DISPLAY LCD.
    ' Los tiempos de espera y secuencia de datos son los indicados en todos los
    ' datasheets de los displays compatibles con el est�ndar Hitachi HD44780.
    DelayMS 30     ' Espera >= 15 ms
    ' INICIACION DE DISPLAY MODO 4 BITS DE DATOS.
    date = %00110000
    GoSub LCD_send4Bits
    DelayMS 5     ' Espera >= 4.1 ms
    date = %00110000
    GoSub LCD_send4Bits
    DelayMS 1      ' Espera >= 100 us
    date = %00110000
    GoSub LCD_send4Bits
    date = %00100000
    GoSub LCD_send4Bits
    date = LCD_CMD_FUNCTION_SET + LCD_CMD_4BIT_INTERFACE + LCD_CMD_2LINES + LCD_CMD_F_FONT_5_8
    GoSub LCD_command
    ' FIN DE INICIALIZACION POR SOFTWARE DEL DISPLAY LCD.

    ' CONFIGURACION DE DISPLAY LCD.
    date = LCD_OFF
    GoSub LCD_command
    date = LCD_CMD_CHARACTER_ENTRY_MODE + LCD_CMD_INCREMENT + LCD_CMD_DISPLAY_SHIFT_OFF
    GoSub LCD_command
    date = LCD_ON
    GoSub LCD_command
    date = LCD_CLEAR
    GoSub LCD_command
Return
'End Sub

'****************************************************************************
'  Funciones de comunicaci�n I2C mediante software.
'****************************************************************************
'Sub I2C__Start             ' START function for communicate I2C
I2C__Start:
    SDA = 1
    SCL = 1
    Output SCL             ' Configura pines I2C como Salidas.
    Output SDA
    SDA = 0
    SCL = 0
Return
'End Sub

'Sub I2C__Stop            ' STOP function for communicate I2C
I2C__Stop:
    SDA = 0
    SCL = 1
    SDA = 1
Return
'End Sub

'Function I2C_writeByte(In dato As Byte) As Bit     ' Send data to I2C
'    Dim LoopCounter As Byte
I2C_writeByte:
    For LoopCounter = 0 To 7
        SDA = dato.7
        SCL = 1
        Rol dato
        SCL = 0
    Next

    Input SDA
    SCL = 1
    ACKBit = SDA
    SCL = 0
    Output SDA
    SDA = 0
Return
'End Function

'Function I2C_readByte(In ACKBit As Bit) As Byte   ' Receive data from I2C
'    Dim LoopCounter As Byte
I2C_readByte:
    dato = 0
    Input SDA
    For LoopCounter = 0 To 7
        SCL = 1
        Rol dato          ' dato<<=1
        dato.0 = SDA
        SCL = 0
    Next

    Output SDA
    SDA = ~ACKBit
    SCL = 1
    SCL = 0
Return
'End Function

'****************************************************************************
'  - Funci�n: BCDToDecimal
'  - Descripci�n: Transforma un n�mero en formato BCD a Decimal.
'  - Entrada:
'      > bcdByte: N�mero en formato BCD
'  - Salida: N�mero en formato Decimal.
'*****************************************************************************
' Function BCDToDecimal(In bcdByte As Byte) As Byte
BCDToDecimal:
  NumeroDecimal = 0
  While NumeroBCD > 0x09
    NumeroBCD = NumeroBCD - 0x10
    NumeroDecimal = NumeroDecimal + 10
  Wend
  NumeroDecimal = NumeroDecimal + NumeroBCD    ' Suma el resto <= 0x09.
Return
'End Function

'****************************************************************************
'  - Funci�n: decimalToBCD
'  - Descripci�n: Transforma un n�mero en formato Decimal a BCD.
'  - Entrada:
'      > decimalByte: N�mero en formato Decimal
'  - Salida: N�mero en formato BCD.
'****************************************************************************
'Function decimalToBCD (In decimalByte As Byte) As Byte
decimalToBCD:
  NumeroBCD = 0
  While NumeroDecimal > 9
    NumeroBCD = NumeroBCD + 0x10
    NumeroDecimal  = NumeroDecimal - 10
  Wend
  NumeroBCD = NumeroBCD + NumeroDecimal    ' Suma el resto <= 9.
Return
'End Function

'****************************************************************************
'  - Funci�n: DS1307_timeRead
'  - Descripci�n: Lee fecha y hora del DS1307 a trav�s del bus I2C.
'  - Entrada: Ninguna.
'  - Salida: Ninguna.
'****************************************************************************
'Sub DS1307_timeRead
DS1307_timeRead:
    GoSub I2C__Start           ' Inicia comunicaci�n I2C.
    dato = 0xD0
    GoSub I2C_writeByte  ' Direcci�n I2C del DS1307.
    dato = 0x00
    GoSub I2C_writeByte  ' Primera direcci�n a leer/escribir.
    GoSub I2C__Start           ' Reinicia comunicaci�n I2C.
    dato = 0xD1
    GoSub I2C_writeByte  ' DS1307 en Modo Escritura.
    
    ACKBit = 1                    ' ASK = 1
    
    GoSub I2C_readByte
    NumeroBCD = dato
    GoSub BCDToDecimal   
    DS1307_Segundo = NumeroDecimal

    GoSub I2C_readByte
    NumeroBCD = dato
    GoSub BCDToDecimal 
    DS1307_Minuto = NumeroDecimal

    GoSub I2C_readByte
    NumeroBCD = dato
    GoSub BCDToDecimal     
    DS1307_Hora = NumeroDecimal
    
    GoSub I2C_readByte    
    DS1307_DiaSemana = dato  ' Valor 1...7 (igual en decimal que en BCD)

    GoSub I2C_readByte
    NumeroBCD = dato
    GoSub BCDToDecimal 
    DS1307_Dia = NumeroDecimal
    
    GoSub I2C_readByte
    NumeroBCD = dato
    GoSub BCDToDecimal 
    DS1307_Mes = NumeroDecimal
    
    ACKBit = 1        ' ASK = 0
    GoSub I2C_readByte
    NumeroBCD = dato
    GoSub BCDToDecimal 
    DS1307_Ano = NumeroDecimal
            ' El �ltimo ASK antes del Stop debe ser sea cero (/ASK).
    GoSub I2C__Stop
Return
'End Sub

'****************************************************************************
'  - Funci�n: DS1307_timeWrite
'  - Descripci�n: Escribe fecha y hora en el DS1307 a trav�s del bus I2C.
'  - Entrada: Ninguna.
'  - Salida: Ninguna.
'****************************************************************************
'Sub DS1307_timeWrite
DS1307_timeWrite:
    GoSub I2C__Start           ' Inicia comunicaci�n I2C
    dato = 0xD0
    GoSub I2C_writeByte  ' Direcci�n I2C del DS1307.
    dato = 0x00
    GoSub I2C_writeByte  ' Primera direcci�n a leer/escribir.
    GoSub I2C_writeByte  ' Siempre que se ajusta la fecha y hora los Segundos=0.
    
    NumeroDecimal = DS1307_Minuto
    GoSub decimalToBCD
    dato = NumeroBCD
    GoSub I2C_writeByte
    
    NumeroDecimal = DS1307_Hora
    GoSub decimalToBCD
    dato = NumeroBCD
    GoSub I2C_writeByte
    
    dato = DS1307_DiaSemana      ' Valor 1...7 (igual en decimal que en BCD)
    GoSub I2C_writeByte
    
    NumeroDecimal = DS1307_Dia
    GoSub decimalToBCD
    dato = NumeroBCD
    GoSub I2C_writeByte
    
    NumeroDecimal = DS1307_Mes
    GoSub decimalToBCD
    dato = NumeroBCD
    GoSub I2C_writeByte
    
    NumeroDecimal = DS1307_Ano
    GoSub decimalToBCD
    dato = NumeroBCD
    GoSub I2C_writeByte
    
    GoSub I2C__Stop
Return
'End Sub


'****************************************************************************
'  - Funci�n: LCDPrintDiaSemana
'  - Descripci�n: Muesta en display LCD el d�a de la semana actual en
'    formato texto.
'  - Entrada: Ninguna.
'  - Salida: Ninguna.
'*****************************************************************************
'Sub LCDPrintDiaSemana
LCDPrintDiaSemana:
    Select Case DS1307_DiaSemana
    Case 1
        date = "D"
        GoSub LCD_putChar
        date = "O"
        GoSub LCD_putChar
        date = "M"
        GoSub LCD_putChar
    Case 2
        date = "L"
        GoSub LCD_putChar
        date = "U"
        GoSub LCD_putChar
        date = "N"
        GoSub LCD_putChar
    Case 3
        date = "M"
        GoSub LCD_putChar
        date = "A"
        GoSub LCD_putChar
        date = "R"
        GoSub LCD_putChar
    Case 4
        date = "M"
        GoSub LCD_putChar
        date = "I"
        GoSub LCD_putChar
        date = "E"
        GoSub LCD_putChar
    Case 5
        date = "J"
        GoSub LCD_putChar
        date = "U"
        GoSub LCD_putChar
        date = "E"
        GoSub LCD_putChar
    Case 6
        date = "V"
        GoSub LCD_putChar
        date = "I"
        GoSub LCD_putChar
        date = "E"
        GoSub LCD_putChar
    Case 7
        date = "S"
        GoSub LCD_putChar
        date = "A"
        GoSub LCD_putChar
        date = "B"
        GoSub LCD_putChar
    End Select
Return
'End Sub


'****************************************************************************
'  - Funci�n: bisiesto
'  - Descripci�n: Comprueba si el a�o actual es bisiesto [margen de 2000 a 2099].
'      Para otros m�rgenes de a�os, habr�a que aplicar el algoritmo gen�rico
'      teniendo en cuenta los a�os m�ltiplos de 100 o 400.
'  - NOTAS: Detalle curioso. Para siglos anteriores al XX, habr�a que tener en
'      cuenta que en Espa�a y otros pa�ses catolicos el mes de octubre de 1582
'      s�lo tuvo 20 d�as. Ese mes, el d�a siguiente al jueves 4 fue viernes 15.
'      En el resto del mundo, el cambio fue produciendose en los siguientes
'      siglos (hasta el XX). Por ejemplo, en Inglaterra y colonias fue en 1752
'      (el d�a siguiente al 03/09/1752 fue 14/091782). Este cambio introdujo
'      las reglas actuales para los a�os multiplos de 100 y 400.
'  - Entrada: Ninguna.
'  - Salida:
'      > Devuelve 1 si el a�o es bisiesto, y 0 si no lo es.
'*****************************************************************************
'Function bisiesto As Bit
bisiesto:
' Devuelve 0 si (DS1307_timeAno%4)!=0, y 1 si (DS1307_timeAno%4)==0
  dato = DS1307_Ano
  While dato >= 4
    dato = dato - 4
  Wend

  If dato = 0 Then
    EsBisiesto = 1
  Else
    EsBisiesto = 0
  End If
Return
'End Function

'****************************************************************************
'  - Funci�n: diasDelMes
'  - Descripci�n: Devuelve el n�mero de d�as de cualquier mes del a�o actual.
'  - Entrada: Ninguna.
'  - Salida:
'      > N�mero en d�as del mes.
'****************************************************************************
'Function diasDelMes As Byte
diasDelMes:
    If DS1307_Mes = 2 Then        ' Mes = febrero
        GoSub bisiesto
        If EsBisiesto = 1 Then
            NumeroDiasDelMes = 29
        Else NumeroDiasDelMes = 28
        End If                    ' Bisiesto: 29 d�as / No bisiesto: 28 d�as.
    Else
        If DS1307_Mes=4 Or DS1307_Mes=6 Or DS1307_Mes=9 Or DS1307_Mes=11 Then
            NumeroDiasDelMes = 30         ' Meses de 30 d�as.
        Else NumeroDiasDelMes = 31         ' Meses de 31 d�as.
        End If
    End If
Return
'End Function


'****************************************************************************
'  - Funci�n: LCDPrintNumero
'  - Descripci�n: Imprime en la pantalla LCD un n�mero de 2 d�gitos.
'  - Entrada:
'      > numero: N�mero entre 0 y 99 a imprimir.
'  - Salida: Ninguna.
'****************************************************************************
'Sub LCDPrintNumero(In numeroDecimal As Byte)
LCDPrintNumero:  
    GoSub decimalToBCD
    date = (NumeroBCD >> 4) + 48
    GoSub LCD_putChar
    date = (NumeroBCD & 0x0F) + 48
    GoSub LCD_putChar
Return
'End Sub


'****************************************************************************
'  - Funci�n: timeShow
'  - Descripci�n: Muestra en el display LCD la fecha y hora.
'  - Entrada: Ninguna.
'  - Salida: Ninguna.
'****************************************************************************
'Sub timeShow
timeShow:
    fila = 0
    columna = 1
    GoSub LCD_gotoXY
    NumeroDecimal = DS1307_Dia
    GoSub LCDPrintNumero
    date = "/"
    GoSub LCD_putChar
    NumeroDecimal = DS1307_Mes
    GoSub LCDPrintNumero
    date = "/"
    GoSub LCD_putChar
    NumeroDecimal = DS1307_Ano
    GoSub LCDPrintNumero
    date = " "
    GoSub LCD_putChar
    GoSub LCD_putChar
    GoSub LCD_putChar
    GoSub LCDPrintDiaSemana
    fila = 1
    GoSub LCD_gotoXY
    NumeroDecimal = DS1307_Hora
    GoSub LCDPrintNumero
    date = ":"
    GoSub LCD_putChar
    NumeroDecimal = DS1307_Minuto
    GoSub LCDPrintNumero
    date = ":"
    GoSub LCD_putChar
    NumeroDecimal = DS1307_Segundo
    GoSub LCDPrintNumero
Return
'End Sub


'****************************************************************************
'  - Funci�n: cicloTimeSet
'  - Descripci�n: Subfunci�n de la funci�n timeRead() que edita las variables
'    del d�a y hora del reloj.
'  - Entrada:
'      > limInf   : L�mite Inferior de la variable editada.
'      > limSup   : L�mite Superior de la variable editada.
'      > lcdX     : Posici�n X del display en la que se muestra la variable.
'      > lcdY     : Posici�n Y (fila) del display en la que se muestra la variable.
'      > editDato : Dato editado (es devuelto en esta variable).
'  - Salida: Ninguna.
'****************************************************************************
' Sub cicloTimeSet(In limInf As Byte, In limSup As Byte, In lcdX As Byte, In lcdY As Byte, editDato As Byte)
cicloTimeSet:
    While P_INC=LOW_ST Or P_DEC=LOW_ST  ' Si se pulsa INC o DEC.
        date = LCD_CURSOR_OFF
        GoSub LCD_command
        If P_INC=LOW_ST Then           ' Se ha pulsado INC.
            editDato = editDato + 1
            If editDato>limSup Then
              editDato=limInf  ' Controla que no se supere el l�mite superior.
            End If
        Else                    ' Se ha pulsado DEC.
            editDato = editDato - 1
            If editDato<limInf Or editDato=0xFF Then
               editDato=limSup ' Si limInf==0 (*editDato)-- puede ser 0xFF.
            End If
        End If
        fila = lcdY
        columna = lcdX
        GoSub LCD_gotoXY            ' Coloca el cursor en la posici�n de inicio de impresi�n del dato editado.
        If editMenuState = SET_DIA_SEM Then
          DS1307_DiaSemana = editDato
          GoSub LCDPrintDiaSemana  ' Si se est� editando del d�a de la semana, se imprime el texto.
        Else
          NumeroDecimal = editDato
          GoSub LCDPrintNumero        ' El resto son variables num�ricas de 2 d�gitos.
        End If
        DelayMS TIEMPO_REPETICION       ' Espera el tiempo de autorepetici�n de la tecla pulsada.
    Wend

    If P_SET=LOW_ST Then                ' Si se pulsa SET.
        editMenuState = editMenuState + 1
        While P_SET=LOW_ST
          DelayMS TIEMPO_ANTIREBOTE   ' Espera antirebote mec�nico del pulsador.
        Wend
        If editDato>limSup Then editDato=limSup  ' Evita posible bug al modificar el a�o o el mes, si
        ' no se modifica el d�a y en ese a�o o mes ya no es v�lido.
    End If

    If editMenuState = SET_DIA_SEM Then lcdX = lcdX + 1 ' Si se est� editando el d�a de la semana, se desplaza el cursor
                                               ' una posici�n m�s, ya que el texto ocupa 3 posiciones, en lugar
                                               ' de dos como el resto de variables.
    lcdX = lcdX + 1
    fila = lcdY
    columna = lcdX    
    GoSub LCD_gotoXY  ' Coloca el cursor en la parte izquierda de la variable editada.
    date = LCD_CURSOR_UNDELINE
    GoSub LCD_command       ' Cursor On
Return
'End Sub

'****************************************************************************
'  - Funci�n: timeRead
'  - Descripci�n: Set fecha y hora mediante pulsadores y cursor en display LCD.
'    Programado seg�n la l�gica de una "m�quina de estado". La variable global
'    editMenuState indica la posici�n del cursor dentro del bucle de fijaci�n de fecha y
'    hora.
'  - Entrada: Ninguna.
'  - Salida: Ninguna.
'****************************************************************************
'Sub timeSet
timeSet:
    fila = 1
    columna = 7
    GoSub LCD_gotoXY           ' Goto posici�n de Segundos en display.
    NumeroDecimal = 0
    GoSub LCDPrintNumero         ' 00 en posici�n de Segundos del display.
    date = LCD_CURSOR_UNDELINE
    GoSub LCD_command       ' Cursor On
    While editMenuState<SALIR_SET_TIME
        While editMenuState=SET_ANO
          'cicloTimeSet(0,99,7,0,DS1307_Ano)            ' Set a�o.
          limInf = 0
          limSup = 99
          lcdX = 7
          lcdY = 0
          editDato = DS1307_Ano
          GoSub cicloTimeSet
          DS1307_Ano = editDato
        Wend
        While editMenuState=SET_MES
          'cicloTimeSet(1,12,4,0,DS1307_Mes)            ' Set mes.
          limInf = 1
          limSup = 12
          lcdX = 4
          lcdY = 0
          editDato = DS1307_Mes
          GoSub cicloTimeSet
          DS1307_Mes = editDato
        Wend
        While editMenuState=SET_DIA
          'cicloTimeSet(1,diasDelMes,1,0,DS1307_Dia)    ' Set d�a.
          limInf = 1
          GoSub diasDelMes
          limSup = NumeroDiasDelMes
          lcdX = 1
          lcdY = 0
          editDato = DS1307_Dia
          GoSub cicloTimeSet
          DS1307_Dia = editDato
        Wend
        While editMenuState=SET_HORA
          'cicloTimeSet(0,23,1,1,DS1307_Hora)           ' Set hora.
          limInf = 0
          limSup = 23
          lcdX = 1
          lcdY = 1
          editDato = DS1307_Hora
          GoSub cicloTimeSet
          DS1307_Hora = editDato
        Wend
        While editMenuState=SET_MINUTO
          'cicloTimeSet(0,59,4,1,DS1307_Minuto)         ' Set minutos.
          limInf = 0
          limSup = 59
          lcdX = 4
          lcdY = 1
          editDato = DS1307_Minuto
          GoSub cicloTimeSet
          DS1307_Minuto = editDato
        Wend
        While editMenuState=SET_DIA_SEM
          'cicloTimeSet(1,7,12,0,DS1307_DiaSemana)      ' Set d�a de la semana.
          limInf = 1
          limSup = 7
          lcdX = 12
          lcdY = 0
          editDato = DS1307_DiaSemana
          GoSub cicloTimeSet
          DS1307_DiaSemana = editDato
        Wend
    Wend
    date = LCD_CURSOR_OFF
    GoSub LCD_command
Return
'End Sub


'****************************************************************************
'  - Funci�n: Setup
'  - Descripci�n: Inicializa Microcontrolador y Hardware externo conectado.
'  - Entrada: Ninguna.
'  - Salida: Ninguna.
'****************************************************************************
'Sub setup
setup:
    CMCON  = 0x07          ' Deshabilita comparadores.
    ADCON1 = 0x06          ' Todos los pines configurados como digitales.
    ADCON0 = 0x00          ' Desactiva conversor A/D.
    Symbol GIE = INTCON.7  ' Global Interrupt Enable
    GIE    = 0             ' Todas las interrupciones desactivadas.

    Input P_INC           ' Configura Pulsadores como Entradas.
    Input P_DEC
    Input P_SET
    Input  SOUT

    GoSub I2C__Start            ' Inicia comunicaci�n I2C
    dato = 0xD0
    GoSub I2C_writeByte         ' Direcci�n I2C del DS1307.
    dato = 0x07
    GoSub I2C_writeByte         ' Escribe en la direcci�n 07h.
    dato = DS1307_CONF
    GoSub I2C_writeByte  ' Configura 1 Hz en salida SOUT del DS1307
    GoSub I2C__Stop

    GoSub LCD_init             ' Inicializa display LCD.
    
Return
'End Sub



