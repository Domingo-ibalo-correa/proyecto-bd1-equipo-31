# Triggers de auditoría

Equipo 31 - La Frecuencia

Script: [scripts.sql](scripts.sql) (se ejecuta completo, después de `crear_bd.sql` y `datos_prueba.sql`)
Evidencias: carpeta [evidencias/](evidencias)

## 1. Definición y objetivo

Un trigger es un código que se ejecuta solo cuando ocurre un `INSERT`, `UPDATE` o `DELETE` sobre una tabla. Dentro del trigger se puede consultar lo que había antes (tabla `deleted`) y lo que hay después (tabla `inserted`). Un trigger de auditoría guarda ese cambio en otra tabla para tener trazabilidad: quién hizo qué, cuándo y con qué valores.

## 2. Ventajas y aplicaciones

- Se registra el cambio automáticamente, sin depender de que cada programa se acuerde de hacerlo.
- Permite saber quién cambió un stock o un precio, cuándo y cuál era el valor anterior.
- Ayuda a cumplir la RN.06 de trazabilidad.

## 3. Implementación en SQL Server Express

Se crean las tablas de auditoría y los triggers `AFTER INSERT, UPDATE, DELETE`. El usuario se toma con `SUSER_SNAME()` y la fecha con `SYSDATETIME()`, ambos como valor por defecto de la tabla de auditoría.

## 4. Caso concreto en La Frecuencia

Hicimos dos auditorías:

1. `auditoria_vinilo`, con el trigger `trg_auditoria_vinilo` sobre `Vinilo`. Registra cuando se da de alta o de baja un vinilo, y cuando cambia su stock actual o su stock mínimo, con el valor anterior y el nuevo. Un `UPDATE` que no toca esas columnas no se registra.
2. `auditoria_precio`, con el trigger `trg_auditoria_precio` sobre `Detalle_compra`. Registra si alguien cambia el precio de un renglón de una venta. Por la RN.06 ese precio histórico no debería cambiar nunca, así que si pasa, queda constancia.

Como nuestra tabla `Vinilo` no tiene una columna de precio (el precio se guarda en cada venta), el ejemplo del precio que pide la guía lo hicimos sobre `Detalle_compra`.

## 5. Demostración y resultados

El script hace cuatro cambios y después consulta las tablas de auditoría:

1. El stock mínimo de Exodus (id 8) pasa de 4 a 6.
2. Se baja en 1 el stock de Kind of Blue (id 6), como una corrección por conteo físico.
3. Se cambia el precio del renglón de Pink Floyd (id 7) en la compra 1, de 39900 a 41000.
4. Un `UPDATE` que no cambia el stock. No tiene que auditarse.

`auditoria_vinilo` queda con 2 filas:

| operacion | id_vinilo | stock_anterior | stock_nuevo | stock_minimo_anterior | stock_minimo_nuevo |
| --- | --- | --- | --- | --- | --- |
| UPDATE | 8 | 17 | 17 | 4 | 6 |
| UPDATE | 6 | 18 | 17 | 5 | 5 |

El stock de Kind of Blue figura de 18 a 17 porque antes se hizo la prueba de transacciones, que lo bajó de 20 a 18. Si esa prueba no se hizo, sería de 20 a 19.

`auditoria_precio` queda con 1 fila: compra 1, vinilo 7, precio anterior 39900.00 y precio nuevo 41000.00.

La prueba 4 no genera ninguna fila. Cada fila trae además la fecha, la hora y el usuario que hizo el cambio.

Al final se deja todo como estaba con tres `UPDATE` de vuelta, y esos cambios también quedan auditados a propósito. Por eso al terminar hay 4 filas en `auditoria_vinilo` y 2 en `auditoria_precio`.

Los triggers se crean después de cargar `datos_prueba.sql`, así que la carga de datos no se audita. Si se ejecuta el script dos veces, las tablas de auditoría acumulan las filas de las dos corridas.

## Evidencias

- `evidencias/01-auditoria-vinilo.png`: contenido de `auditoria_vinilo`.
- `evidencias/02-auditoria-precio.png`: contenido de `auditoria_precio`.
