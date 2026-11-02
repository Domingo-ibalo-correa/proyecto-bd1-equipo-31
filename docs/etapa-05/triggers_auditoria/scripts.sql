USE proyecto_grupo31_secuela;
GO

IF OBJECT_ID('dbo.auditoria_vinilo') IS NULL
CREATE TABLE auditoria_vinilo
(
    id_auditoria          INT IDENTITY (1,1) NOT NULL,
    fecha_hora            DATETIME2 NOT NULL CONSTRAINT DF_auditoria_vinilo_fecha DEFAULT SYSDATETIME(),
    usuario               SYSNAME NOT NULL CONSTRAINT DF_auditoria_vinilo_usuario DEFAULT SUSER_SNAME(),
    operacion             VARCHAR(10) NOT NULL,
    id_vinilo             INT NOT NULL,
    titulo_Vinilo         VARCHAR(100) NOT NULL,
    stock_anterior        INT NULL,
    stock_nuevo           INT NULL,
    stock_minimo_anterior INT NULL,
    stock_minimo_nuevo    INT NULL,
    CONSTRAINT PK_AUDITORIA_VINILO PRIMARY KEY (id_auditoria)
);
GO

IF OBJECT_ID('dbo.auditoria_precio') IS NULL
CREATE TABLE auditoria_precio
(
    id_auditoria    INT IDENTITY (1,1) NOT NULL,
    fecha_hora      DATETIME2 NOT NULL CONSTRAINT DF_auditoria_precio_fecha DEFAULT SYSDATETIME(),
    usuario         SYSNAME NOT NULL CONSTRAINT DF_auditoria_precio_usuario DEFAULT SUSER_SNAME(),
    id_compra       INT NOT NULL,
    id_vinilo       INT NOT NULL,
    precio_anterior DECIMAL(10,2) NOT NULL,
    precio_nuevo    DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_AUDITORIA_PRECIO PRIMARY KEY (id_auditoria)
);
GO

-- Trigger 1: INSERT, UPDATE y DELETE sobre Vinilo
-- En un UPDATE solo se registra si cambio el stock actual o el minimo
CREATE OR ALTER TRIGGER trg_auditoria_vinilo
ON Vinilo
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- alta
    INSERT INTO auditoria_vinilo (operacion, id_vinilo, titulo_Vinilo, stock_nuevo, stock_minimo_nuevo)
    SELECT 'INSERT', i.id_vinilo, i.titulo_Vinilo, i.stock_actual, i.stock_minimo
    FROM inserted i
    WHERE NOT EXISTS (SELECT 1 FROM deleted);

    -- modificacion de stock
    INSERT INTO auditoria_vinilo (operacion, id_vinilo, titulo_Vinilo,
                                  stock_anterior, stock_nuevo, stock_minimo_anterior, stock_minimo_nuevo)
    SELECT 'UPDATE', i.id_vinilo, i.titulo_Vinilo,
           d.stock_actual, i.stock_actual, d.stock_minimo, i.stock_minimo
    FROM inserted i
    JOIN deleted d ON d.id_vinilo = i.id_vinilo
    WHERE i.stock_actual <> d.stock_actual
       OR i.stock_minimo <> d.stock_minimo;

    -- baja
    INSERT INTO auditoria_vinilo (operacion, id_vinilo, titulo_Vinilo, stock_anterior, stock_minimo_anterior)
    SELECT 'DELETE', d.id_vinilo, d.titulo_Vinilo, d.stock_actual, d.stock_minimo
    FROM deleted d
    WHERE NOT EXISTS (SELECT 1 FROM inserted);
END;
GO

-- Trigger 2: cambio de precio en un renglon de compra
CREATE OR ALTER TRIGGER trg_auditoria_precio
ON Detalle_compra
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(precio_unidad)
        INSERT INTO auditoria_precio (id_compra, id_vinilo, precio_anterior, precio_nuevo)
        SELECT i.id_compra, i.id_vinilo, d.precio_unidad, i.precio_unidad
        FROM inserted i
        JOIN deleted d ON d.id_compra = i.id_compra
                      AND d.id_vinilo = i.id_vinilo
        WHERE i.precio_unidad <> d.precio_unidad;
END;
GO

/* DEMOSTRACION */

-- Prueba 1: se modifica el stock minimo de Exodus (id 8) de 4 a 6
UPDATE Vinilo SET stock_minimo = 6 WHERE id_vinilo = 8;

-- Prueba 2: se corrige el stock de Kind of Blue (id 6) por un conteo fisico
UPDATE Vinilo SET stock_actual = stock_actual - 1 WHERE id_vinilo = 6;

-- Prueba 3: se modifica el precio de un renglon (compra 1, vinilo 7: Pink Floyd)
UPDATE Detalle_compra SET precio_unidad = 41000 WHERE id_compra = 1 AND id_vinilo = 7;

-- Prueba 4: un UPDATE que no cambia el stock NO tiene que auditarse
UPDATE Vinilo SET artista_Vinilo = artista_Vinilo WHERE id_vinilo = 9;

SELECT * FROM auditoria_vinilo ORDER BY id_auditoria;
SELECT * FROM auditoria_precio ORDER BY id_auditoria;

-- Se deja todo como estaba (esto tambien queda auditado, a proposito)
UPDATE Vinilo SET stock_minimo = 4 WHERE id_vinilo = 8;
UPDATE Vinilo SET stock_actual = stock_actual + 1 WHERE id_vinilo = 6;
UPDATE Detalle_compra SET precio_unidad = 39900 WHERE id_compra = 1 AND id_vinilo = 7;

SELECT COUNT(*) AS filas_auditoria_vinilo FROM auditoria_vinilo;
SELECT COUNT(*) AS filas_auditoria_precio FROM auditoria_precio;
GO
