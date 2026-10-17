# Informe de ventas

Archivo: `sql/consultas/informe_ventas.sql`

## Para qué sirve

El dueño quiere saber qué géneros se venden más en un período y con qué métodos de pago pagan los clientes, para decidir qué pedirles a los proveedores y qué medios de pago conviene promocionar.

## Cómo lo resolvimos

Son dos consultas con `GROUP BY`. En las dos filtramos por rango de fechas con `BETWEEN` (variables `@desde` y `@hasta`) y solo contamos las compras `realizado`. Calculamos la cantidad de compras (`COUNT(DISTINCT id_compra)`), las unidades (`SUM(cantidad)`) y el importe (`SUM(cantidad * precio_unidad)`), ordenado de mayor a menor importe.

- La **A** agrupa por género. Como el género del vinilo normal está en `Vinilo.id_genero` y el del personalizado en `genero_multiple`, primero armamos una tabla con `WITH` que junta las dos cosas con `UNION ALL`, y después la unimos con las ventas.
- La **B** agrupa por método de pago.

Algo a tener en cuenta: un vinilo personalizado con dos géneros se cuenta en los dos. Por eso si se suman los importes de la consulta A da más que lo realmente vendido. La B sí da el total real.

## Código

```sql
USE proyecto_grupo31_secuela;
GO

DECLARE @desde DATE = '2026-08-01';
DECLARE @hasta DATE = '2026-10-31';

-- A) Ventas por GENERO.
-- El genero de un vinilo normal esta en Vinilo.id_genero y el de un
-- personalizado en genero_multiple (RN.03). Se juntan los dos con UNION ALL.
-- Un personalizado con 2 generos suma en cada uno de ellos.
;WITH vinilo_genero AS (
    SELECT id_vinilo, id_genero FROM Vinilo WHERE id_genero IS NOT NULL
    UNION ALL
    SELECT id_vinilo, id_genero FROM genero_multiple
)
SELECT g.nombre_genero                      AS genero,
       COUNT(DISTINCT c.id_compra)          AS cantidad_compras,
       SUM(dc.cantidad)                     AS unidades_vendidas,
       SUM(dc.cantidad * dc.precio_unidad)  AS importe_total
FROM Compra c
JOIN Detalle_compra dc ON dc.id_compra = c.id_compra
JOIN vinilo_genero vg  ON vg.id_vinilo = dc.id_vinilo
JOIN genero g          ON g.id_genero  = vg.id_genero
WHERE c.estado_de_compra = 'realizado'
  AND c.fecha_compra BETWEEN @desde AND @hasta
GROUP BY g.nombre_genero
ORDER BY importe_total DESC;

-- B) Ventas por METODO DE PAGO en el mismo rango de fechas
SELECT m.nombre_Metodo_pago                 AS metodo_de_pago,
       COUNT(DISTINCT c.id_compra)          AS cantidad_compras,
       SUM(dc.cantidad)                     AS unidades_vendidas,
       SUM(dc.cantidad * dc.precio_unidad)  AS importe_total
FROM Compra c
JOIN Metodo_pago m     ON m.id_metodo  = c.id_metodo
JOIN Detalle_compra dc ON dc.id_compra = c.id_compra
WHERE c.estado_de_compra = 'realizado'
  AND c.fecha_compra BETWEEN @desde AND @hasta
GROUP BY m.nombre_Metodo_pago
ORDER BY importe_total DESC;
GO
```

## Resultado

Con el rango del 2026-08-01 al 2026-10-31.

Consulta A, por género:

| genero | cantidad_compras | unidades_vendidas | importe_total |
| --- | --- | --- | --- |
| Rock nacional | 8 | 11 | 381100.00 |
| Rock internacional | 4 | 5 | 217500.00 |
| Jazz | 2 | 4 | 157600.00 |
| Pop | 4 | 4 | 154100.00 |
| Tango | 3 | 3 | 131000.00 |
| Reggae | 2 | 2 | 83200.00 |
| Folklore | 2 | 2 | 74400.00 |
| Musica clasica | 1 | 1 | 52500.00 |
| Funk y Soul | 1 | 1 | 51400.00 |
| Blues | 1 | 1 | 49300.00 |

Consulta B, por método de pago:

| metodo_de_pago | cantidad_compras | unidades_vendidas | importe_total |
| --- | --- | --- | --- |
| Tarjeta de credito | 2 | 8 | 273400.00 |
| Mercado Pago QR | 2 | 5 | 174900.00 |
| MODO | 1 | 4 | 174200.00 |
| Transferencia bancaria | 2 | 4 | 151700.00 |
| Uala | 1 | 2 | 98600.00 |
| Cuenta DNI | 1 | 2 | 85100.00 |
| Efectivo | 1 | 2 | 71700.00 |
| Tarjeta de debito | 1 | 1 | 28700.00 |

Para controlar, la suma de la B da 1058300.00 en 11 compras, que es todo lo vendido. La compra 12 está cancelada y no entra.

Si se cambia el rango a octubre (`2026-10-01` a `2026-10-31`) el informe solo muestra las compras de ese mes, así comprobamos que el filtro de fechas anda.