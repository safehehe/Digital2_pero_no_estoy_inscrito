# Pantalla

## Encendido pantalla 16x16 con LEDs WS2812B
Segun el [datasheet](/docs/WS2812B-LED-datasheet.pdf) los LEDs WS2812B permiten 24 bits
para el color que estan ordenados como GRB y se indica que el bit más significactivo debe
ser enviado primero.

La codificación utilizada por el fabricante diferencia `1` de `0` a partir de el ciclo util
de un pulso con frecuencida de 800kHz, se utiliza un ciclo util de 32% (0.4us on, 0.85us off)
para identificar el `cero` y un ciclo util de 68%(0.85us on, 0.4 off) para identificar el `uno`. Además se cuenta con una señal de reset que corresponde a mantener el voltaje bajo por más de 50us y es utilizada para indicar al LED que sera ingresada nueva información.

Cuando se conectan en cascada se envia una trama de 24 bits que es almacenada por
el primer LED, luego una segunda trama que es _reconstruida_ por el primer LED y 
envida en serie al siguiente LED, el cual la almacena, el proceso se repite para
las siguientes tramas, por que la trama i-esima es enviada al LED i-esimo.

Luego de llenar todos los pixeles se debe enviar una señal de reset, que indique a
los pixeles que seran llenados de nuevo.
### Implementación
#### Generador de pulsos con ancho de pulso dinamico
Se utiliza un generador de pulsos a 800kHz que permite ajustar el ancho de pulso
con una entrada binaria según el bit que se desea enviar. Tiene señal de inicio, reset, 
enviar señal de reset y señales que indican cuando se termina el nivel alto de el pulso.
#### Lectura de memoria y selección de bit a enviar
Se lee la memoria utilizando lineas de dirección y habilidator de lectura, la 
información ya se encuentra en orden por lo que se utiliza el bit menos significativo
de un registro de corrimiento para indicar al generador de pulso el bit que se desea
enviar.
#### Ciclo de actualización de pantalla
Cuando se envie información por primera vez, luego de un reset global, se lee
la información de el primer pixel, se envia y cuando se termine el nivel positivo 
de el bit 24 se lee el siguiente pixel y se envia, esto continua hasta enviar la 
información que corresponde a los 256 pixeles de la pantalla, luego se envia una señal
de reset a los pixeles y se repite el ciclo empezando por el primer pixel.


## Respaldo en memoria y selección de color
Se usa una memoria volatil que guarda la información que sera enviada a la pantalla
por lo que tiene 256 palabras de 24 bits y el color se organiza BRG[23:0] de forma que
el bit más significativo se encuentra en la primera posición.
### Implementación
Para la interfaz de ecritura se utizan lineas de dirección y lineas de color 
además de habilitador de escritura; para la lectura se utilizan lineas de dirección 
y color ademas de habilitador de escritura. Se requiere un comportamiento read-first.
