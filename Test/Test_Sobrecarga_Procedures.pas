{
*  (C) AguHDz 22-05-2017
*  Ultima Actualizacion: 22-05-2017
*
*  Prueba para compilador PicPas v.0.6.4
*  Prueba de concepto sobre carga de procedimientos.
}

program Test_Sobrecarga_Procedures;

procedure delay_us(microsegundos: word);
begin
  // cuerpo de procedimiento.
end;

procedure delay_us(microsegundos: byte);
begin
  // cuerpo de procedimiento.
end;

begin                          
  delay_us(100);
  delay_us(1000);
end.
