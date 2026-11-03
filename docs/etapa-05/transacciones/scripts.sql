USE proyecto_grupo31_secuela;
GO

/*  Prueba 1: venta correcta 
   El cliente 4 compra 2 unidades de Kind of Blue (id 6), que tiene 20 en
   stock. Alcanza, asi que se confirma la venta (COMMIT).                  */
DECLARE @id_usuario INT = 4, @id_metodo INT = 1;
DECLARE @id_vinilo INT = 6, @cantidad INT = 2, @precio DECIMAL(10,2) = 36500;
DECLARE @stock_actual INT, @id_compra INT;

SELECT COUNT(*) AS compras_antes FROM Compra;
SELECT stock_actual AS stock_antes FROM Vinilo WHERE id_vinilo = @id_vinilo;

BEGIN TRANSACTION;

    SELECT @stock_actual = stock_actual
    FROM Vinilo WITH (UPDLOCK, HOLDLOCK)
    WHERE id_vinilo = @id_vinilo;

    INSERT INTO Compra (estado_de_compra, fecha_compra, id_usuario, id_metodo)
    VALUES ('realizado', CAST(GETDATE() AS DATE), @id_usuario, @id_metodo);
    SET @id_compra = SCOPE_IDENTITY();

    INSERT INTO Detalle_compra (precio_unidad, cantidad, id_compra, id_vinilo)
    VALUES (@precio, @cantidad, @id_compra, @id_vinilo);

    -- se controla el stock antes de descontarlo
    IF @stock_actual < @cantidad
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Stock insuficiente: se hizo ROLLBACK.';
    END
    ELSE
    BEGIN
        UPDATE Vinilo SET stock_actual = stock_actual - @cantidad WHERE id_vinilo = @id_vinilo;
        COMMIT TRANSACTION;
        PRINT 'Venta registrada: se hizo COMMIT.';
    END;

SELECT COUNT(*) AS compras_despues FROM Compra;                              -- esperado: una mas que antes
SELECT stock_actual AS stock_despues FROM Vinilo WHERE id_vinilo = 6;        -- esperado: 18
GO

/*  Prueba 2: stock insuficiente 
   Artaud (id 3) tiene 4 unidades y se piden 10. Se hacen los INSERT y el
   UPDATE dentro de la transaccion y despues se controla el stock:
   como no alcanza, el ROLLBACK deshace todo.                              */
DECLARE @id_usuario INT = 4, @id_metodo INT = 1;
DECLARE @id_vinilo INT = 3, @cantidad INT = 10, @precio DECIMAL(10,2) = 34000;
DECLARE @stock_actual INT, @id_compra INT;

SELECT COUNT(*) AS compras_antes FROM Compra;
SELECT COUNT(*) AS renglones_antes FROM Detalle_compra;
SELECT stock_actual AS stock_antes FROM Vinilo WHERE id_vinilo = @id_vinilo;

BEGIN TRANSACTION;

    SELECT @stock_actual = stock_actual
    FROM Vinilo WITH (UPDLOCK, HOLDLOCK)
    WHERE id_vinilo = @id_vinilo;

    INSERT INTO Compra (estado_de_compra, fecha_compra, id_usuario, id_metodo)
    VALUES ('realizado', CAST(GETDATE() AS DATE), @id_usuario, @id_metodo);
    SET @id_compra = SCOPE_IDENTITY();

    INSERT INTO Detalle_compra (precio_unidad, cantidad, id_compra, id_vinilo)
    VALUES (@precio, @cantidad, @id_compra, @id_vinilo);

    -- se controla el stock antes de descontarlo
    IF @stock_actual < @cantidad
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Stock insuficiente: se hizo ROLLBACK.';
    END
    ELSE
    BEGIN
        UPDATE Vinilo SET stock_actual = stock_actual - @cantidad WHERE id_vinilo = @id_vinilo;
        COMMIT TRANSACTION;
        PRINT 'Venta registrada: se hizo COMMIT.';
    END;

-- Tiene que dar lo mismo que antes: no quedo ningun registro parcial
SELECT COUNT(*) AS compras_despues FROM Compra;
SELECT COUNT(*) AS renglones_despues FROM Detalle_compra;
SELECT stock_actual AS stock_despues FROM Vinilo WHERE id_vinilo = 3;        -- esperado: 4
GO
