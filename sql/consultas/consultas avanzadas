USE proyecto_grupo31_secuela;
GO

-- A) Clientes que tengan gastos superiores al resto
-- Para cada cliente se suma lo que gasto en compras realizadas, having deja solo a los que superan el gasto promedio de todos los clientes que compraron

SELECT u.id_usuario,
       u.nombre_usuario AS cliente,
       COUNT(DISTINCT c.id_compra) AS compras,
       SUM(dc.cantidad) AS unidades,
       SUM(dc.cantidad * dc.precio_unidad) AS total_gastado
FROM Usuario u
JOIN Compra c ON c.id_usuario = u.id_usuario
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

-- B) Vinilos a reponer
-- Vinilos que tengan el stock por debajo del minimo, cuanto falta y el proveedor del ultimo ingreso, con el precio de costo que se pagó en ese ingreso
SELECT v.id_vinilo,
       v.artista_Vinilo AS artista,
       v.titulo_Vinilo AS titulo,
       v.stock_actual,
       v.stock_minimo,
       v.stock_minimo - v.stock_actual AS faltante,
       p.nombre_Proveedor AS ultimo_proveedor,
       i.fecha AS fecha_ultimo_ingreso,
       di.precio_unitario AS ultimo_costo
FROM Vinilo v
JOIN detalle_de_ingreso di ON di.id_vinilo = v.id_vinilo
JOIN Ingreso_vinilo i ON i.id_lote    = di.id_lote
JOIN Proveedor p ON p.id_proveedor = i.id_proveedor
WHERE v.stock_actual < v.stock_minimo
  AND i.fecha = (SELECT MAX(i2.fecha)
                 FROM detalle_de_ingreso di2
                 JOIN Ingreso_vinilo i2 ON i2.id_lote = di2.id_lote
                 WHERE di2.id_vinilo = v.id_vinilo)
ORDER BY faltante DESC;
GO
