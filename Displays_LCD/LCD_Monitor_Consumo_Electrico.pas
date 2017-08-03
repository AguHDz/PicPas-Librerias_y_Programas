{
*
*  (C) AguHDz 02-AGO-2017
*  Ultima Actualizacion: 02-AGO-2017
*
*  Prueba para compilador PicPas v.0.7.2
* 
*  Monitor de Consumo Eléctrico en display LCD 20x4
*  ================================================
*  Monitoriza en un display LCD de 20x4 los valores de tensión (voltios),
*  corriente (Amperios), potencia (kilowatios) y energía consimida (kilowatios-hora)

   VALORES MAXIMOS DE MEDIDA:
   - Voltaje   : 500 Voltios.
   - Corriente : 120 Amperios.
   - Potencia  :  60 kW.
   - Energía   : 655 kWh.
   
   Ideado para uso doméstico y suministro monofásico en baja tensión.

   EN FASE DE DESARROLLO.
}

{$FREQUENCY 8Mhz}
{$PROCESSOR PIC16F877A}

program LCD_Monitor_Consumo_Electrico;

uses PIC16F877A, LCDLib_4bits, Math_Word_Type;  // Con libreria Math (funciones distintos tipos de datos) no funciona.

var
  voltaje, corriente, potencia, energia : word;

procedure LCD_Print_POTENCIA;
begin
  LCD_WriteChar('P');
  LCD_WriteChar('O');
  LCD_WriteChar('T');
  LCD_WriteChar('E');
  LCD_WriteChar('N');
  LCD_WriteChar('I');
  LCD_WriteChar('A');
  LCD_WriteChar(':');
  LCD_WriteChar(' '); 
  LCD_WriteChar(' ');  
  LCD_Print_Number(potencia,3,5,' ');
  LCD_WriteChar('k');
  LCD_WriteChar('W');
end;

procedure LCD_Print_ENERGIA;
begin
  LCD_WriteChar('E');
  LCD_WriteChar('N');
  LCD_WriteChar('E');
  LCD_WriteChar('R');
  LCD_WriteChar('G');
  LCD_WriteChar('I');
  LCD_WriteChar('A');
  LCD_WriteChar(':');
  LCD_WriteChar(' ');
  LCD_Print_Number(energia,2,5,' ');
  LCD_WriteChar('k');
  LCD_WriteChar('W');
  LCD_WriteChar('h');
end;

procedure LCD_Print_VOLTAJE;
begin
  LCD_WriteChar('V');
  LCD_WriteChar('O');
  LCD_WriteChar('L');
  LCD_WriteChar('T');
  LCD_WriteChar('A');
  LCD_WriteChar('J');
  LCD_WriteChar('E');
  LCD_WriteChar(':');
  LCD_WriteChar(' ');
  LCD_Print_Number(voltaje,2,5,' ');
  LCD_WriteChar('v');
end;

procedure LCD_Print_CORRIENTE;
begin
  LCD_WriteChar('C');
  LCD_WriteChar('O');
  LCD_WriteChar('R');
  LCD_WriteChar('R');
  LCD_WriteChar('I');
  LCD_WriteChar('E');
  LCD_WriteChar('N');
  LCD_WriteChar('T');
  LCD_WriteChar('E');
  LCD_WriteChar(':');
  LCD_WriteChar(' ');
  LCD_Print_Number(corriente,2,5,' ');
  LCD_WriteChar('A');
end;


// Si se utiliza función PETA debido a que PicPas no controla
// el uso de memoria en los bancos superiores al 00, y este ya 
// llena con las variables usadas hasta ahora.
// Calcula de manera precisa la potencia intantanea en kW con 3
// decimales, pero usando solo variables word (las de más dígitos
// que actualmente tiene implementada PicPas v.0.7.2)
procedure Calcula_Potencia;
var
  operador1, operador2, operador3, operador4, v_aux: word;
  contador : byte;
begin
  v_aux     := voltaje;
  potencia  := 0;
  operador3 := 10000;
  operador4 := 1;
  contador  := 0;
  repeat   
    operador1 := Dividir(v_aux,operador3);
    operador2 := Multiplicar(corriente, operador1.low);
    operador2 := Dividir(operador2,operador4);
    potencia  := potencia + operador2;       
    v_aux     := Resto_Dividir(v_aux,operador3);    
    operador3 := Dividir(operador3,word(10));
    operador4 := Multiplicar(operador4,10);
    inc(contador);
  until (contador = 5);
end;

// P R O G R A M A   P R I N C I P A L
begin
  LCD_Init(20,4);   // LCD 20x4
  
  repeat
    voltaje   := 22359;  // Se leería desde sensor de voltaje.
    corriente := 1935;   // Se leería desde sensor de corriente.
    Calcula_Potencia;    // Calcula la potencia instantanea en función del voltaje y corriente.
    energia   := 13658;  // Pendiente. Se necesita una base de tiempos
                         // que nos la puede dar el Timer 1, incrementado
                         // el contador de energía usando interrupcionesdestructor
                         // este timer.
  
    LCD_GotoXY(0,2);
    LCD_Print_VOLTAJE;
    LCD_GotoXY(1,0);
    LCD_Print_CORRIENTE; 
    LCD_GotoXY(2,2);   
    LCD_Print_POTENCIA;
    LCD_GotoXY(3,2);
    LCD_Print_ENERGIA;
    
    delay_ms(1000);
   // corriente := corriente + 111;
  until(false);
    
end. 
