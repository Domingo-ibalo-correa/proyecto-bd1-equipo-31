# Optimización de consultas con índices

Equipo 31 - La Frecuencia

Script: [scripts.sql](scripts.sql) (se ejecuta por partes, anotando las mediciones de cada una)
Evidencias: carpeta [evidencias/](evidencias)

## 1. Definición y objetivo

Un índice es una estructura que ordena los datos de una o más columnas para encontrarlos más rápido, como el índice de un libro. Sin índice, el motor tiene que leer toda la tabla para buscar un dato (Table Scan). Con índice, va directo a las filas que necesita (Index Seek). El objetivo es reducir el trabajo que hace el motor para responder una consulta.

## 2. Ventajas y aplicaciones

- Aceleran las búsquedas, los filtros por rango, los `JOIN` y los `GROUP BY` sobre las columnas indexadas.
- Reducen las lecturas y el tiempo de respuesta, sobre todo en tablas con muchos registros.
- Tienen un costo: ocupan espacio y hacen un poco más lentos los `INSERT`, `UPDATE` y `DELETE`, porque hay que mantenerlos al día. Por eso se crean solo donde hacen falta.

## 3. Implementación en SQL Server Express

Se usa `CREATE CLUSTERED INDEX` (ordena la tabla misma, solo puede haber uno), `CREATE NONCLUSTERED INDEX` (estructura aparte) y la cláusula `INCLUDE`, para agregar columnas al índice y que la consulta se resuelva sin leer la tabla (índice de cobertura). Las mediciones se hacen con `SET STATISTICS TIME ON` y `SET STATISTICS IO ON`, y se mira el plan de ejecución real con Ctrl+M.

## 4. Caso concreto en La Frecuencia

Con los datos de prueba (12 compras) no se puede ver el efecto de un índice, porque la tabla es demasiado chica. Por eso, siguiendo la guía, armamos una tabla aparte, `Compra_historica`, con 1.000.000 de compras simuladas (fecha, cliente e importe, entre 2022 y 2026). No toca las tablas reales.

La consulta de prueba es la del informe de ventas: las compras del primer trimestre de 2025.

```sql
SELECT id_compra, fecha_compra, importe
FROM Compra_historica
WHERE fecha_compra BETWEEN '2025-01-01' AND '2025-03-31';
```

Se prueba en tres escenarios:

1. Sin índices (la tabla no tiene clave primaria, es un heap).
2. Con un índice agrupado sobre `fecha_compra`.
3. Con un índice no agrupado sobre `fecha_compra` que incluye `importe` (cobertura), con la consulta pidiendo solo esas dos columnas.

Además, el script crea cinco índices sobre las tablas reales que ayudan a las consultas de la Etapa 4 (informe por fechas, compras de un cliente, ventas e ingresos de un vinilo y aviso de stock bajo).

## 5. Demostración y resultados

Los tiempos y lecturas dependen de la computadora, así que acá van los valores medidos en nuestro equipo:

| Escenario | CPU (ms) | Tiempo total (ms) | Lecturas lógicas | Operación principal |
| --- | --- | --- | --- | --- |
| Sin índice | 125 | 642 | | Table Scan |
| Índice agrupado sobre fecha | 47 | 575 | | Clustered Index Seek |
| Índice con cobertura | 47 | 399 | | Index Seek |

Lo que se espera ver es que:

1. Sin índice el motor recorre el millón de filas.
2. Con el índice agrupado las lecturas bajan mucho, porque solo lee las filas del trimestre.
3. Con el índice de cobertura bajan todavía más, porque el índice tiene solo las dos columnas que se piden y es más chico que la tabla.
4. El plan de ejecución pasa de un escaneo completo a una búsqueda (Seek).


## Evidencias

- `evidencias/01-sin-indice.png` y `evidencias/01-plan-de-ejecucion.png`: mensajes y plan de ejecución del escenario 1.
- `evidencias/02-indice-agrupado.png` y `evidencias/02-plan-de-ejecucion.png`: mensajes y plan del escenario 2.
- `evidencias/03-indice-cobertura.png` y `evidencias/03-plan-de-ejecucion.png`: mensajes y plan del escenario 3.
- `evidencias/04-indices-creados.png`: listado de los índices de las tablas reales.
