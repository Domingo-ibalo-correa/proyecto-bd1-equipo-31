# Comprobante de venta

Archivo: `sql/consultas/comprobante_venta.sql`

## Para qué sirve

Cuando alguien compra, la tienda tiene que poder mostrarle qué llevó, cuánto pagó por cada vinilo y cuál fue el total. La consulta arma ese comprobante para la compra que se elija con la variable `@id_compra`.

## Cómo lo resolvimos

Hicimos tres consultas seguidas sobre la misma compra:

1. El encabezado, uniendo `Compra` con `Usuario` (para el nombre del cliente) y con `Metodo_pago`.
2. El detalle, uniendo `Detalle_compra` con `Vinilo`. El subtotal de cada renglón es `cantidad * precio_unidad`.
3. El total, con `SUM` de las unidades y de los subtotales.

El precio lo tomamos de `Detalle_compra` y no de `Vinilo`, porque ahí queda guardado el precio del día de la venta. El subtotal no lo guardamos en ninguna tabla, se calcula cada vez.

## Código

```sql
USE proyecto_grupo31_secuela;
GO

DECLARE @id_compra INT = 1;   -- probar tambien con 2, 4, 11, etc.

-- 1) ENCABEZADO: quien compro, cuando, como pago y en que estado esta
SELECT c.id_compra        AS nro_comprobante,
       c.fecha_compra     AS fecha,
       u.nombre_usuario   AS cliente,
       u.correo_usuario   AS correo,
       m.nombre_Metodo_pago AS metodo_de_pago,
       c.estado_de_compra AS estado
FROM Compra c
JOIN Usuario u     ON u.id_usuario = c.id_usuario
JOIN Metodo_pago m ON m.id_metodo  = c.id_metodo
WHERE c.id_compra = @id_compra;

-- 2) DETALLE: un renglon por vinilo, con el precio que se cobro ese dia
SELECT v.titulo_Vinilo                AS titulo,
       v.artista_Vinilo               AS artista,
       v.tipo_vinilo                  AS tipo,
       dc.cantidad,
       dc.precio_unidad               AS precio_unitario,
       dc.cantidad * dc.precio_unidad AS subtotal
FROM Detalle_compra dc
JOIN Vinilo v ON v.id_vinilo = dc.id_vinilo
WHERE dc.id_compra = @id_compra
ORDER BY v.titulo_Vinilo;

-- 3) TOTAL de la compra
SELECT SUM(dc.cantidad)                    AS unidades,
       SUM(dc.cantidad * dc.precio_unidad) AS total_a_pagar
FROM Detalle_compra dc
WHERE dc.id_compra = @id_compra;
GO
```

## Resultado

Con `@id_compra = 1`:

| nro_comprobante | fecha | cliente | correo | metodo_de_pago | estado |
| --- | --- | --- | --- | --- | --- |
| 1 | 2026-08-12 | lucia.gomez | lucia.gomez@example.com | Transferencia bancaria | realizado |

| titulo | artista | tipo | cantidad | precio_unitario | subtotal |
| --- | --- | --- | --- | --- | --- |
| Clics Modernos | Charly Garcia | Normal | 1 | 31200.00 | 31200.00 |
| The Dark Side of the Moon | Pink Floyd | Normal | 1 | 39900.00 | 39900.00 |

| unidades | total_a_pagar |
| --- | --- |
| 2 | 71100.00 |

Probamos también con la compra 4, que tiene un vinilo con cantidad 2 (Dynamo, 2 x 30200 = 60400). Ahí el total da 89500.00 con 3 unidades.

La compra 11 tiene un vinilo personalizado y sale igual, con la columna `tipo` en `Personalizado` (total 85100.00).

Un detalle para notar es que Dynamo figura a 30200 en la compra 4 (septiembre) y a 32600 en la compra 11 (octubre). Cada comprobante mantiene el precio de su fecha.