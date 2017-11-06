2ª PRUEBA DE COMPILADORES PARA MICROCONTROLADORES PIC DE GAMA MEDIA
==========================================================
[Ultima Edición: 06/11/2017: Resultados Definitivos]
Esta 2ª comparativa utiliza un "programa patrón" mucho más complejo que el usado en al 1ª comparativa, que era demasiado básico.
Se trata de un reloj de tiempo real usando el microcontrolador PIC16F877A (y el PIC16F84A cuando el compilador es capaz de generar un ejecutanle de menos de 1K) todas las funciones de reloj las realiza el integrado DS1307 que se comunica mediante protocolo I2C, 3 botones de entrada y un display LCD de salida.
La comunicación I2C es por software por lo que es aplicable a cualquier PIC y se han utilizado instrucciones básicas para optimizar el tamaño del código, huyendo de las librerías estándar que puedan acompañar a los compiladores y que invalidarían la prueba. Cuando el compilador dispone de ella, la única instrucción o librería usada ha sido delay_ms() por estar siempre muy optimizada y más o menos estandarizada en todos los compiladores.

PUESTO OBTENIDO POR CADA COMPILADOR TRAS PRUEBA:
1ª  PICPAS 0.8.0 (https://github.com/t-edson/PicPas - GRATUITO) - 1722 (MEJOR)
2º  XC8 v.1.35 (http://www.microchip.com - DE PAGO - VERSION REGISTRADA) - 1757
3º CCS C v.5.0.74 (http://www.ccsinfo.com/ - DE PAGO) - 1767
4º MIKROPASCAL v.7.1.0 (https://shop.mikroe.com/mikropascal-pic - DE PAGO) - 1967
5º GCBASIC v.0.97.01 (http://gcbasic.sourceforge.net - GRATUITO) - 1968
6º PROTON IDE (v.3.6.0.0 (https://sites.google.Com/view/rosetta-tech - GRATIS PARA PIC MAS USUALES) - 1981
7º PIC MICRO PASCAL v.2.1.4 (http://www.pmpcomp.fr/) - 2045
8º MIKROC V.7.0.0 (https://www.mikroe.com/mikroc - DE PAGO) - 2047
9º XC8 v.1.43 (http://www.microchip.com - VERSION FREE - GRATUITO) - 2542
10º SDCC v.3.6.0 (http://sdcc.sourceforge.net - GRATUITO) - 2977 (PEOR)


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
XC8 (free)->  No válido. FLASH > 1000 words = 1092 (máxima RAM + FLASH)
SDCC  ->  No válido. FLASH > 1000 words = 1092 (máxima RAM + FLASH)
MIKROPASCAL ->  RAM: 35 bytes  FLASH: 935 words = 970
PROTON IDE ->  RAM: 31 bytes  FLASH: 828 words = 859
XC8 (pago) ->  RAM: 27  FLASH: 725 words = 752
PIC MICRO PASCAL ->  RAM: 33 bytes FLASH: 828 words = 861

Para obterner el resultado se ha sumado las memoria total RAM y FLASH (la RAM es un bien muy escaso en los PIC por lo que alcanza gran valor en la puntuación) usada por cada compilador en los dos microcontroladores evaluados (PIC16F877A y PIC16F84A). El ganador es el que obtiene un número menor (usa menos recursos = mayor optimización)

PicPas v.0.8.1 ha resultado ganador, aunque a mínima distancia de otros compiladores profesionales y mucho más completos. Sus competidores en la gama gratuita serías GCBASIC y PROTON IDE (aunque este no es gratis para todos los PICs)

Otra conclusión importante XC8 en su versión gratuita, tal y como anuncia el fabricante, es una mala opción para trabajos profesionales. si quieres obtener buenos resultados tendrás que registrarlo y pagar.

NOTA: Los autores del compilador SDCC para PIC, ya advierten de que se trata de una versión preliminar, con el único objetivo de que funcione, y de momento, sin haber tenido muy en cuenta la optimización de código generado.

Mas información y comentarios en : https://www.facebook.com/groups/electronicaymicrocontroladores/permalink/1812269192135162/
------
Si alguien se anima a compilarlo con otros compiladores, añadiría sus resultados.
Pero debes recordar que se trata de hacer exactamente lo mismo con las correcciones particulares de cada compilador en el código fuente, pero sin tratar de optimizar nada, el código deber ser lo más parecido al "programa patrón" para que se puedan comparar los resultados. No se trata de una prueba de programadores, es una prueba de compiladores.
