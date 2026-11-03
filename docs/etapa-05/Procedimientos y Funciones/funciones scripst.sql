USE proyecto_grupo31_secuela;
GO

-- 1) Total de una compra (suma de cantidad * precio de cada renglon)
CREATE OR ALTER FUNCTION dbo.fn_TotalCompra (@id_compra INT)
RETURNS DECIMAL(12,2)
AS
BEGIN
    RETURN ISNULL((SELECT SUM(dc.cantidad * dc.precio_unidad)
                   FROM Detalle_compra dc
                   WHERE dc.id_compra = @id_compra), 0);
END;
GO

-- 2) Porcentaje de descuento de un cliente segun lo que compro hasta hoy
--    (solo cuentan las compras 'realizado')
--      300000 o mas  -> 10 %
--      150000 o mas  ->  5 %
--      menos         ->  0 %
CREATE OR ALTER FUNCTION dbo.fn_CalcularDescuentoCliente (@id_usuario INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @acumulado DECIMAL(12,2);

    SELECT @acumulado = ISNULL(SUM(dc.cantidad * dc.precio_unidad), 0)
    FROM Compra c
    JOIN Detalle_compra dc ON dc.id_compra = c.id_compra
    WHERE c.id_usuario = @id_usuario
      AND c.estado_de_compra = 'realizado';

    RETURN CASE WHEN @acumulado >= 300000 THEN 10
                WHEN @acumulado >= 150000 THEN 5
                ELSE 0 END;
END;
GO

-- 3) Vinilos que hay que reponer
CREATE OR ALTER FUNCTION dbo.fn_VinilosAReponer ()
RETURNS TABLE
AS
RETURN
(
    SELECT v.id_vinilo,
           v.artista_Vinilo,
           v.titulo_Vinilo,
           v.stock_actual,
           v.stock_minimo,
           v.stock_minimo - v.stock_actual AS faltante
    FROM Vinilo v
    WHERE v.stock_actual < v.stock_minimo
);
GO

/* Demostración de funciones */

-- Total de la compra 1, esperado: 71100.00
SELECT dbo.fn_TotalCompra(1) AS total_compra_1;

-- Descuento de cada cliente
SELECT id_usuario,
       nombre_usuario,
       dbo.fn_CalcularDescuentoCliente(id_usuario) AS descuento_porcentaje
FROM Usuario
ORDER BY id_usuario;

-- Vinilos a reponer, esperado: Artaud, Gracias a la vida y Libertango
SELECT * FROM dbo.fn_VinilosAReponer() ORDER BY faltante DESC, id_vinilo;
GO
