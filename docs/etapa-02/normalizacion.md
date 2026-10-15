3. Procesos de Normalización



**Primera Forma Normal** (1FN): Cada tabla debe tener una PK, no deben existir grupos repetidos y todos
los atributos deben ser atómicos.



1. En la tabla Compra existen las columnas transferencia y tarjeta que son un grupo repetitivo, con
esta estructura si en un futuro se añade un nuevo método habría que modificar la tabla. Se creó
la tabla Metodo\_pago y Compra incorpora cod\_metodo como clave foránea.
2. La tabla Genero\_multiple no tiene una clave primaria, solo tiene cod\_vinilo que es una FK y
además para almacenar múltiples géneros por vinilo se necesita saber cuál es el género
entonces se añadió la columna género, la clave primaria debe estar compuesta por cod\_vinilo y
género, para evitar que se registre el mismo género dos veces para un mismo vinilo.
3. La tabla Contacto no tiene clave primaria, sin la clave primaria no se puede identificar un
registro especifico de contacto, se agregó una clave primaria cod\_contacto que sería la PK y se
mantiene cod\_proveedor como FK.
4. En la tabla Detalle\_compra están día, mes y año como columnas separadas, son valores
atomicos pero al momento de hacer consultas a la base de datos es mejor unificarlas en una
sola columna, entonces se añadió fecha\_compra que es de tipo DATE o DATETIME y se juntan
las tres columnas en una.



**Segunda Forma Normal** (2FN): Para cumplir la 2fn la base de datos debe cumplir la 1fn y ningún atributo
no clave debe depender de solo una parte de una clave primaria compuesta.



1. La columna comprobante pasa de detalle\_de\_ingreso a Ingreso\_vinilo, la clave de
detalle\_ingreso es cod\_lote y cod\_vinilo, el número de comprobante identifica al documento
del lote completo, o sea que depende solo de cod\_lote que es solo una parte de la clave y se
convierte en una dependencia parcial, y también el mismo comprobante se repetiría en cada
línea del lote.
2. precio\_unitario y cantidad pasan de Ingreso\_vinilo a detalle\_de\_ingreso, estos dos valores
dependen del par (lote, vinilo) y no solo del lote, en un mismo lote cada vinilo puede entrar con
distinta cantidad y distinto precio, con la estructura actual un lote solo puede tener un único
precio y una única cantidad, aunque contenga varios vinilos.



**Tercera Forma Normal** (3FN): Ningún atributo no clave tiene que depender de otro atributo no clave,
ósea no tiene que haber dependencias transitivas.



1. fecha\_compra pasa de Detalle\_compra a Compra. La clave primaria de Detalle\_compra es
cod\_det\_compra y las dependencias serían cod\_det\_compra -> cod\_compra, y cod\_compra ->
fecha\_compra, por transitividad la fecha depende de la línea de detalle a través de cod\_compra
que no es clave primaria. Sin el cambio se repetiría la misma fecha en cada línea y podría haber
fechas distintas en la misma compra.



2\. Se crea la tabla Genero y el género pasa a referenciarse por código. El género estaba como texto
   libre en vinilo\_original y en genero\_multiple, eso permite que el mismo género se cargue escrito
   de formas distintas (“rock”, “Rock”, “Rock nacional”, etc) y si lo queremos renombrar habría que
   actualizar todas las filas, al convertirlo en tabla la dependencia queda explicita: cod\_vinilo ->
   cod\_genero -> nombre\_genero. Vinilo\_original y genero\_multiple pasan a usar cod\_genero
   como FK.

