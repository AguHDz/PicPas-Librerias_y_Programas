{
*  (C) AguHDz 28-05-2017
*  Ultima Actualizacion: 28-05-2017
*
*  Compilador PicPas v.0.6.5 (https://github.com/t-edson/PicPas)
*  Giro de motor paso a paso de 4 polos con botones de START, STOP y
   giros a DERECHA e IZQUIERDA (horario y antihorario).
*
*  Pulsadores:
*    - DERECHA: Memoriza que el giro del motor sea en sentito horario.
*    - IZQUIERDA: Memiriza que el giro del motor sea en sentido antihorario.
*    - START: Inicia el giro del Motor.
*    - STOP: Detiene el giro del Motor.
*
*  Se puede cambiar el sentido del giro sin necesidad de pulsar previamente STOP.
*  Se puede programar el sentodo de giro antes de pulsar START.
*
*  A partir de la version 0.6.5 PicPas implementa la sentencia FOR de la que
*  hace uso el procedimiento Girar de este programa. Tambien se hace uso de
*  los comandos internos SetAsInput y SetAsOutput para configurar los puertos
*  o pines individualmente (equivalente a configurarlos directamente escribido
*  los registros TRISA y TRISB)
}

{$FREQUENCY 8 MHZ }
program Motor_Paso_a_Paso;

uses PIC16F84A;

const
  GIRO_DERECHA   = true;           // Giro a la derecha (sentido horario)
  GIRO_IZQUIERDA = false;          // Giro a la izquierda (sentido antihorario)
  PAUSA_GIRO     = 100;            // Pausa entre giros de 90 grados del motor.

var
  Start     : bit absolute PORTA.0; // Pulsador START
  Stop      : bit absolute PORTA.1; // Pulsador STOP
  Derecha   : bit absolute PORTA.2; // Pulsador DERECHA
  Izquierda : bit absolute PORTA.3; // Pulsador IZQUIERDA
  Motor     : byte absolute PORTB;  // Motor Paso a Paso (RB0 a RB4)
  ST_Start  : boolean;              // Memoriza pulsacion de boton START.
  ST_Stop   : boolean;              // Memoriza pulsacion de boton STOP.
  ST_Giro   : boolean;              // Memoriza el sentido de giro del Motor.

//***********************************************************************
// PROCEDURE CompruebaPulsadores
// Ademas de comprobar y memorizar la pulsacion de los botones de control
// proporciona pausa en cambio de posicion del eje del motor (velocidad)
//***********************************************************************
procedure CompruebaPulsadores;
begin
  if Start=1 then               // Si se pulsa el boton START el motor gira.
    ST_Start := true;
    ST_Stop  := false;
  elsif Stop=1 then             // Si se pulsa el boton STOP el motor de detiene.
    ST_Start := false;
    ST_Stop  := true;
    Motor    := $00;
  end;

  if Derecha=1 then             // Si se pulsa el boton DERECHA el motor gira en sentido horario.
    Motor := $00;               // Detiene el motor temporalmente antes de cambiar sentido de giro.
    ST_Giro := GIRO_DERECHA;    // Memoriza giro a la derecha.
  elsif Izquierda=1 then        // Si se pulsa el boton IZQUIERDA el motor gira en sentido horario.
    Motor := $00;               // Detiene el motor temporalmente antes de cambiar sentido de giro.
    ST_Giro := GIRO_IZQUIERDA;  // Memoriza giro a la izquierda.
  end;

  if ST_Start then              // Si el motor esta girando produce pausa	
    delay_ms(PAUSA_GIRO);       // para dar tiempo al movimiento fisico del eje
  end;                          // del motor. Cambiando el valor de PAUSA_GIRO se
end;                            // puede ajustar la velocidad del motor.

//***********************************************************************
// PROCEDURE Girar
// Gira el motor Paso a Paso en el sentido que se le haya indicado.
//***********************************************************************
procedure Girar;
var contador : byte;
begin
  for contador:=1 to 4 do          // Motor PaP de 4 posiciones
    CompruebaPulsadores;           // Comprueba si se ha presionado algun pulsador.
    if contador=1 then             // Si inicio de secuencia de giro. 
      if ST_Giro then Motor:=$08;  // Inicia giro a la derecha (horario)
      else Motor:=$01;             // Inicia giro a la izquierda (antihorario)
      end;
    else
      if ST_Giro then Motor:=Motor>>1; // Continua giro a la derecha.
      else Motor:=Motor<<1;            // Continua giro a la izquierda.
      end;
    end;    
  end;
end;

//***********************************************************************
// PROCEDURE Parar
// Detiene el giro del motor Paso a Paso.
//***********************************************************************
procedure Parar;
begin
  Motor := $00;              // Detiene el Motor.
  CompruebaPulsadores;       // Comprueba la pulsacion de botones.
end;
 
//***********************************************************************
// PROGRAMA PRINCIPAL ***************************************************
//***********************************************************************
begin
  // ------------- SETUP
  SetAsInput(Start);         // Configura el Pin Start como entrada.
  SetAsInput(Stop);          // Configura el Pin Stop como entrada.
  SetAsInput(Derecha);       // Configura el Pin Derecha como entrada.
  SetAsInput(Izquierda);     // Configura el Pin Izquierda como entrada.
  SetAsOutput(Motor);        // Configura el Puerto Motor como salida.

  ST_Giro  := GIRO_DERECHA;  // Sentido de giro tras reinicio de uC.
  ST_Start := false;         // Tras reinico de uC el motor estara parado
  ST_Stop  := true;          // a la espera de que se pulse START
  Motor := $00;              // Motor parado.
  // ------------ END SETUP
  
  // ------------ LOOP
  while true do
    if (ST_Start and not ST_Stop) then Girar;    // El Motor gira.
    elsif (not ST_Start and ST_Stop) then Parar; // El Motor de detiene.
    end;
  end;
  // ------------ END LOOP
end.
