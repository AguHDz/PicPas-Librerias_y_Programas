{$FREQUENCY 8 MHZ }
//{$PROCESSOR PIC16F84A}  // con esta directiva no compila el codigo ASM.
program DireIndirASM;
uses
  PIC16F84A;  // Es necesario anadir a la libreria origial el registro INDF
              // INDF     :byte absolute $00;
{
   Prueba direccionamiento indirecto en codigo ASM.
   Graba el valor $55 en todas las posiciones de memoria
   RAM desde la $20 a la $30 ($30 es la primera direccion
   consecutiba a partir de la $20 en que su bit 4 es un 1.
}
begin
ASM
  MOVLW $20    ; Direccion %00100000 
  MOVWF FSR
next:
  MOVLW $55
  MOVWF INDF
  INCF FSR,F
  BTFSS FSR,4  ; Comprueba si se ha llegado a la direccion %00110000 ($30)
  GOTO next
END
end.
