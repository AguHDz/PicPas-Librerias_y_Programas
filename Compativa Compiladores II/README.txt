2� PRUEBA DE COMPILADORES PARA MICROCONTROLADORES PIC DE GAMA MEDIA
==========================================================
[Ultima Edici�n: 06/11/2017: Resultados Definitivos]
Esta 2� comparativa utiliza un "programa patr�n" mucho m�s complejo que el usado en al 1� comparativa, que era demasiado b�sico.
Se trata de un reloj de tiempo real usando el microcontrolador PIC16F877A (y el PIC16F84A cuando el compilador es capaz de generar un ejecutanle de menos de 1K) todas las funciones de reloj las realiza el integrado DS1307 que se comunica mediante protocolo I2C, 3 botones de entrada y un display LCD de salida.
La comunicaci�n I2C es por software por lo que es aplicable a cualquier PIC y se han utilizado instrucciones b�sicas para optimizar el tama�o del c�digo, huyendo de las librer�as est�ndar que puedan acompa�ar a los compiladores y que invalidar�an la prueba. Cuando el compilador dispone de ella, la �nica instrucci�n o librer�a usada ha sido delay_ms() por estar siempre muy optimizada y m�s o menos estandarizada en todos los compiladores.

PUESTO OBTENIDO POR CADA COMPILADOR TRAS PRUEBA:
1�  PICPAS 0.8.0 (https://github.com/t-edson/PicPas - GRATUITO) - 1722 (MEJOR)
2�  XC8 v.1.35 (http://www.microchip.com - DE PAGO - VERSION REGISTRADA) - 1757
3� CCS C v.5.0.74 (http://www.ccsinfo.com/ - DE PAGO) - 1767
4� MIKROPASCAL v.7.1.0 (https://shop.mikroe.com/mikropascal-pic - DE PAGO) - 1967
5� GCBASIC v.0.97.01 (http://gcbasic.sourceforge.net - GRATUITO) - 1968
6� PROTON IDE (v.3.6.0.0 (https://sites.google.Com/view/rosetta-tech - GRATIS PARA PIC MAS USUALES) - 1981
7� PIC MICRO PASCAL v.2.1.4 (http://www.pmpcomp.fr/) - 2045
8� MIKROC V.7.0.0 (https://www.mikroe.com/mikroc - DE PAGO) - 2047
9� XC8 v.1.43 (http://www.microchip.com - VERSION FREE - GRATUITO) - 2542
10� SDCC v.3.6.0 (http://sdcc.sourceforge.net - GRATUITO) - 2977 (PEOR)


TABLAS DE RESULTADOS:

PIC16F877A
=========
PICPAS ->  RAM: 33 bytes   FLASH: 847 words = 880
CCS C ->  RAM: 27 bytes   FLASH: 878 bytes  = 905
GCBASIC ->  RAM: 45 bytes   FLASH: 953 words = 998
MIKROC -> RAM: 37 bytes FLASH: 1000 words = 1037
XC8 (free)->  RAM: 32 bytes   FLASH: 1418 words = 1450
SDCC  ->  RAM: 43 bytes   FLASH: 1842 words = 1885
MIKROPASCAL -> RAM: 35 bytes  FLASH: 962 words = 997
PROTON IDE ->  RAM: 31 bytes  FLASH: 1091 words = 1122
PIC MICRO PASCAL ->  RAM: 33 bytes FLASH: 1151 words = 1184
XC8 (pago)->  RAM: 27  FLASH: 978 words = 1005

PIC16F84A
=========
PICPAS ->  RAM: 33 bytes   FLASH: 809 words = 842
CCS C ->  RAM: 26 bytes   FLASH: 836 bytes = 862
GCBASIC ->  RAM: 45 bytes   FLASH: 925 words = 970
MIKROC ->  RAM: 37 bytes   FLASH: 973 words = 1010
XC8 (free)->  No v�lido. FLASH > 1000 words = 1092 (m�xima RAM + FLASH)
SDCC  ->  No v�lido. FLASH > 1000 words = 1092 (m�xima RAM + FLASH)
MIKROPASCAL ->  RAM: 35 bytes  FLASH: 935 words = 970
PROTON IDE ->  RAM: 31 bytes  FLASH: 828 words = 859
XC8 (pago) ->  RAM: 27  FLASH: 725 words = 752
PIC MICRO PASCAL ->  RAM: 33 bytes FLASH: 828 words = 861

Para obterner el resultado se ha sumado las memoria total RAM y FLASH (la RAM es un bien muy escaso en los PIC por lo que alcanza gran valor en la puntuaci�n) usada por cada compilador en los dos microcontroladores evaluados (PIC16F877A y PIC16F84A). El ganador es el que obtiene un n�mero menor (usa menos recursos = mayor optimizaci�n)

PicPas v.0.8.1 ha resultado ganador, aunque a m�nima distancia de otros compiladores profesionales y mucho m�s completos. Sus competidores en la gama gratuita ser�as GCBASIC y PROTON IDE (aunque este no es gratis para todos los PICs)

Otra conclusi�n importante XC8 en su versi�n gratuita, tal y como anuncia el fabricante, es una mala opci�n para trabajos profesionales. si quieres obtener buenos resultados tendr�s que registrarlo y pagar.

NOTA: Los autores del compilador SDCC para PIC, ya advierten de que se trata de una versi�n preliminar, con el �nico objetivo de que funcione, y de momento, sin haber tenido muy en cuenta la optimizaci�n de c�digo generado.

------
Si alguien se anima a compilarlo con otros compiladores, a�adir�a sus resultados.
Pero debes recordar que se trata de hacer exactamente lo mismo con las correcciones particulares de cada compilador en el c�digo fuente, pero sin tratar de optimizar nada, el c�digo deber ser lo m�s parecido al "programa patr�n" para que se puedan comparar los resultados. No se trata de una prueba de programadores, es una prueba de compiladores.
