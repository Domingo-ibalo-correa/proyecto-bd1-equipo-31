USE proyecto_grupo31_secuela;
GO

-- a) Ventas por género
-- El genero de un vinilo normal esta en Vinilo.id_genero y el de un personalizado en genero_multiple (RN.03), se juntan los dos con union all
-- Un personalizado con 2 generos suma en cada uno de ellos
;WITH vinilo_genero AS (
    SELECT id_vinilo, id_genero FROM Vinilo WHERE id_genero IS NOT NULL
    UNION ALL
    SELECT id_vinilo, id_genero FROM genero_multiple
)
SELECT g.nombre_genero AS genero,
       COUNT(DISTINCT c.id_compra) AS cantidad_compras,
       SUM(dc.cantidad) AS unidades_vendidas,
       SUM(dc.cantidad * dc.precio_unidad) AS importe_total
FROM Compra c
JOIN Detalle_compra dc ON dc.id_compra = c.id_compra
JOIN vinilo_genero vg ON vg.id_vinilo = dc.id_vinilo
JOIN genero g ON g.id_genero  = vg.id_genero
WHERE c.estado_de_compra = 'realizado'
  AND c.fecha_compra BETWEEN '2026-08-01' AND '2026-10-31'
GROUP BY g.nombre_genero
ORDER BY importe_total DESC;

-- b) Ventas por metodo de pago en el mismo rango de fechas
SELECT m.nombre_Metodo_pago AS metodo_de_pago,
       COUNT(DISTINCT c.id_compra) AS cantidad_compras,
       SUM(dc.cantidad) AS unidades_vendidas,
       SUM(dc.cantidad * dc.precio_unidad) AS importe_total
FROM Compra c
JOIN Metodo_pago m ON m.id_metodo  = c.id_metodo
JOIN Detalle_compra dc ON dc.id_compra = c.id_compra
WHERE c.estado_de_compra = 'realizado'
  AND c.fecha_compra BETWEEN '2026-08-01' AND '2026-10-31'
GROUP BY m.nombre_Metodo_pago
ORDER BY importe_total DESC;
GO
