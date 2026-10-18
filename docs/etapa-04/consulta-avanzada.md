# Consultas avanzadas

Archivo: `sql/consultas/consulta_avanzada.sql`

Tiene dos consultas. Las dos usan varias tablas y una subconsulta, y la primera también usa `HAVING`.

## A) Clientes que gastaron más que el promedio

Sirve para saber quiénes son los mejores clientes y poder fidelizarlos, que es uno de los objetivos de la tienda.

Unimos `Usuario`, `Compra` y `Detalle_compra`, nos quedamos con las compras `realizado` y agrupamos por cliente para sacar cuántas compras hizo, cuántas unidades llevó y cuánto gastó. Con `HAVING` dejamos solo a los que gastaron más que el promedio. Ese promedio sale de una subconsulta que suma lo gastado por cada cliente y después promedia esos totales. Usamos `HAVING` y no `WHERE` porque la condición es sobre un `SUM`, que se calcula después de agrupar.

## B) Vinilos a reponer

Sirve para el aviso de stock bajo (RN.05), pero además de saber cuáles son, saber a qué proveedor pedírselos y a qué precio.

Filtramos los vinilos con `stock_actual < stock_minimo` y unimos `Vinilo`, `detalle_de_ingreso`, `Ingreso_vinilo` y `Proveedor`. Como un vinilo puede venir de más de un proveedor (RN.02), usamos una subconsulta con `MAX(fecha)` para quedarnos solo con el último ingreso de cada uno. También calculamos cuántas unidades faltan para llegar al mínimo.

## Código

```sql
USE proyecto_grupo31_secuela;
GO

-- A) CLIENTES CON GASTO SUPERIOR AL PROMEDIO
-- Para cada cliente se suma lo que gasto en compras realizadas. HAVING deja
-- solo a los que superan el gasto promedio de todos los clientes que compraron.
SELECT u.id_usuario,
       u.nombre_usuario                    AS cliente,
       COUNT(DISTINCT c.id_compra)         AS compras,
       SUM(dc.cantidad)                    AS unidades,
       SUM(dc.cantidad * dc.precio_unidad) AS total_gastado
FROM Usuario u
JOIN Compra c          ON c.id_usuario = u.id_usuario
JOIN Detalle_compra dc ON dc.id_compra = c.id_compra
WHERE c.estado_de_compra = 'realizado'
GROUP BY u.id_usuario, u.nombre_usuario
HAVING SUM(dc.cantidad * dc.precio_unidad) >
       (SELECT AVG(t.total)
        FROM (SELECT SUM(d2.cantidad * d2.precio_unidad) AS total
              FROM Compra c2
              JOIN Detalle_compra d2 ON d2.id_compra = c2.id_compra
              WHERE c2.estado_de_compra = 'realizado'
              GROUP BY c2.id_usuario) AS t)
ORDER BY total_gastado DESC;

-- B) VINILOS A REPONER
-- Vinilos con stock por debajo del minimo, cuanto falta y el proveedor del
-- ultimo ingreso, con el precio de costo que se pago en ese ingreso.
SELECT v.id_vinilo,
       v.artista_Vinilo                    AS artista,
       v.titulo_Vinilo                     AS titulo,
       v.stock_actual,
       v.stock_minimo,
       v.stock_minimo - v.stock_actual     AS faltante,
       p.nombre_Proveedor                  AS ultimo_proveedor,
       i.fecha                             AS fecha_ultimo_ingreso,
       di.precio_unitario                  AS ultimo_costo
FROM Vinilo v
JOIN detalle_de_ingreso di ON di.id_vinilo = v.id_vinilo
JOIN Ingreso_vinilo i      ON i.id_lote    = di.id_lote
JOIN Proveedor p           ON p.id_proveedor = i.id_proveedor
WHERE v.stock_actual < v.stock_minimo
  AND i.fecha = (SELECT MAX(i2.fecha)
                 FROM detalle_de_ingreso di2
                 JOIN Ingreso_vinilo i2 ON i2.id_lote = di2.id_lote
                 WHERE di2.id_vinilo = v.id_vinilo)
ORDER BY faltante DESC;
GO
```

## Resultado

**A)** El gasto promedio por cliente es 117588.89. Superan ese valor:

| id_usuario | cliente | compras | unidades | total_gastado |
| --- | --- | --- | --- | --- |
| 2 | martin.fernandez | 2 | 8 | 309900.00 |
| 1 | lucia.gomez | 2 | 4 | 151700.00 |
| 7 | camila.duarte | 1 | 4 | 137700.00 |

**B)**

| id_vinilo | artista | titulo | stock_actual | stock_minimo | faltante | ultimo_proveedor | fecha_ultimo_ingreso | ultimo_costo |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 3 | Luis Alberto Spinetta | Artaud | 4 | 5 | 1 | Cordoba Vinilos SRL | 2026-08-14 | 24000.00 |
| 5 | Astor Piazzolla | Libertango | 5 | 6 | 1 | Formosa Discos | 2026-08-21 | 23200.00 |
| 4 | Mercedes Sosa | Gracias a la vida | 7 | 8 | 1 | Tucuman Sonidos | 2026-09-04 | 20400.00 |

Son los mismos 3 vinilos con stock bajo que habíamos visto en las pruebas de la Etapa 3.