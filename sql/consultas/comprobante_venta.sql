USE proyecto_grupo31_secuela;
GO

DECLARE @id_compra INT = 1;   -- probar tambien con 2, 4, 11, y otros números

-- 1) encabezado del comprobante: quien compró, cuando lo hizo, como pagó y en que estado está

SELECT c.id_compra AS nro_comprobante,
       c.fecha_compra AS fecha,
       u.nombre_usuario AS cliente,
       u.correo_usuario AS correo,
       m.nombre_Metodo_pago AS metodo_de_pago,
       c.estado_de_compra AS estado
FROM Compra c
JOIN Usuario u ON u.id_usuario = c.id_usuario
JOIN Metodo_pago m ON m.id_metodo  = c.id_metodo
WHERE c.id_compra = @id_compra;

-- 2) detalle: un renglon por vinilo, con el precio que se cobró ese día

SELECT v.titulo_Vinilo AS titulo,
       v.artista_Vinilo AS artista,
       v.tipo_vinilo AS tipo,
       dc.cantidad,
       dc.precio_unidad AS precio_unitario,
       dc.cantidad * dc.precio_unidad AS subtotal
FROM Detalle_compra dc
JOIN Vinilo v ON v.id_vinilo = dc.id_vinilo
WHERE dc.id_compra = @id_compra
ORDER BY v.titulo_Vinilo;

-- 3) el total  de la compra
SELECT SUM(dc.cantidad) AS unidades,
       SUM(dc.cantidad * dc.precio_unidad) AS total_a_pagar
FROM Detalle_compra dc
WHERE dc.id_compra = @id_compra;
GO
