USE proyecto_grupo31_secuela;
GO

/* 
    Procedimiento
    */
-- Tipo de tabla para mandar varios renglones (vinilo, cantidad, precio) de una vez
IF TYPE_ID('dbo.TipoDetalleVenta') IS NULL
    CREATE TYPE dbo.TipoDetalleVenta AS TABLE
    (
        id_vinilo     INT NOT NULL PRIMARY KEY,
        cantidad      INT NOT NULL,
        precio_unidad DECIMAL(10,2) NOT NULL
    );
GO

/* Registra la venta completa en una sola transaccion:
     1. controla que haya stock de todos los vinilos
     2. crea el encabezado (Compra) en estado 'realizado'
     3. crea los renglones (Detalle_compra) con el precio historico,
        aplicando el descuento del cliente
     4. descuenta el stock
   Si algo falla se deshace todo (ROLLBACK) y se devuelve el error. */
CREATE OR ALTER PROCEDURE dbo.sp_RegistrarVentaCompleta
    @id_usuario INT,
    @id_metodo  INT,
    @detalle    dbo.TipoDetalleVenta READONLY,
    @id_compra  INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM @detalle)
            THROW 50001, 'La venta no tiene renglones.', 1;

        IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id_usuario = @id_usuario)
            THROW 50002, 'El usuario no existe.', 1;

        IF EXISTS (SELECT 1 FROM @detalle d
                   WHERE NOT EXISTS (SELECT 1 FROM Vinilo v WHERE v.id_vinilo = d.id_vinilo))
            THROW 50003, 'Hay un vinilo que no existe.', 1;

        IF EXISTS (SELECT 1 FROM @detalle WHERE cantidad <= 0)
            THROW 50004, 'La cantidad de cada renglon tiene que ser mayor a 0.', 1;

        DECLARE @descuento DECIMAL(5,2) = dbo.fn_CalcularDescuentoCliente(@id_usuario);

        BEGIN TRANSACTION;

            -- se bloquean los vinilos mientras se controla el stock
            IF EXISTS (SELECT 1
                       FROM @detalle d
                       JOIN Vinilo v WITH (UPDLOCK, HOLDLOCK) ON v.id_vinilo = d.id_vinilo
                       WHERE v.stock_actual < d.cantidad)
                THROW 50005, 'Stock insuficiente para completar la venta.', 1;

            INSERT INTO Compra (estado_de_compra, fecha_compra, id_usuario, id_metodo)
            VALUES ('realizado', CAST(GETDATE() AS DATE), @id_usuario, @id_metodo);

            SET @id_compra = SCOPE_IDENTITY();

            INSERT INTO Detalle_compra (precio_unidad, cantidad, id_compra, id_vinilo)
            SELECT ROUND(d.precio_unidad * (1 - @descuento / 100), 2),
                   d.cantidad,
                   @id_compra,
                   d.id_vinilo
            FROM @detalle d;

            UPDATE v
            SET v.stock_actual = v.stock_actual - d.cantidad
            FROM Vinilo v
            JOIN @detalle d ON d.id_vinilo = v.id_vinilo;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

/* Demostracion de procedimiento */

-- Prueba 1: venta correcta de martin.fernandez (id 2, tiene 10 % de descuento)
--           2 unidades de Clics Modernos (id 1) a 31200 y 1 de Dynamo (id 2) a 32600
DECLARE @renglones dbo.TipoDetalleVenta;
DECLARE @nueva_compra INT;

INSERT INTO @renglones (id_vinilo, cantidad, precio_unidad) VALUES (1, 2, 31200), (2, 1, 32600);

EXEC dbo.sp_RegistrarVentaCompleta @id_usuario = 2, @id_metodo = 4,
                                   @detalle = @renglones, @id_compra = @nueva_compra OUTPUT;

SELECT @nueva_compra AS id_compra_creada;

SELECT c.id_compra, c.estado_de_compra, v.titulo_Vinilo, dc.cantidad, dc.precio_unidad,
       dc.cantidad * dc.precio_unidad AS subtotal
FROM Compra c
JOIN Detalle_compra dc ON dc.id_compra = c.id_compra
JOIN Vinilo v          ON v.id_vinilo  = dc.id_vinilo
WHERE c.id_compra = @nueva_compra;

SELECT id_vinilo, titulo_Vinilo, stock_actual FROM Vinilo WHERE id_vinilo IN (1, 2);
GO

-- Prueba 2: venta con stock insuficiente (Artaud, id 3, tiene 4 y se piden 10)
DECLARE @renglones2 dbo.TipoDetalleVenta;
DECLARE @compra2 INT;

INSERT INTO @renglones2 (id_vinilo, cantidad, precio_unidad) VALUES (3, 10, 34000);

BEGIN TRY
    EXEC dbo.sp_RegistrarVentaCompleta @id_usuario = 3, @id_metodo = 1,
                                       @detalle = @renglones2, @id_compra = @compra2 OUTPUT;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS numero_error, ERROR_MESSAGE() AS mensaje;
END CATCH;

-- No tiene que haber quedado nada de la venta fallida
SELECT COUNT(*) AS compras_del_usuario_3 FROM Compra WHERE id_usuario = 3;   -- esperado: 1 (la que ya estaba)
SELECT id_vinilo, stock_actual FROM Vinilo WHERE id_vinilo = 3;              -- esperado: 4
GO
