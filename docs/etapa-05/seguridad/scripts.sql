USE master;
GO

-- Inicios de sesion (logins)
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usuario_admin')
    CREATE LOGIN usuario_admin   WITH PASSWORD = 'Admin123*';
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usuario_lector')
    CREATE LOGIN usuario_lector  WITH PASSWORD = 'Lector123*';
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usuario_con_rol')
    CREATE LOGIN usuario_con_rol WITH PASSWORD = 'Rol123*';
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usuario_sin_rol')
    CREATE LOGIN usuario_sin_rol WITH PASSWORD = 'Rol456*';
GO

USE proyecto_grupo31_secuela;
GO

-- Usuarios de la base asociados a cada login
IF DATABASE_PRINCIPAL_ID('usuario_admin')   IS NULL CREATE USER usuario_admin   FOR LOGIN usuario_admin;
IF DATABASE_PRINCIPAL_ID('usuario_lector')  IS NULL CREATE USER usuario_lector  FOR LOGIN usuario_lector;
IF DATABASE_PRINCIPAL_ID('usuario_con_rol') IS NULL CREATE USER usuario_con_rol FOR LOGIN usuario_con_rol;
IF DATABASE_PRINCIPAL_ID('usuario_sin_rol') IS NULL CREATE USER usuario_sin_rol FOR LOGIN usuario_sin_rol;
GO

/*  Parte 1: permisos a nivel de usuario  */

-- usuario_admin, administrador de la base
ALTER ROLE db_owner ADD MEMBER usuario_admin;

-- usuario_lector, solo puede leer las compras
GRANT SELECT ON dbo.Compra TO usuario_lector;

-- pero se le permite registrar ventas con el procedimiento
GRANT EXECUTE ON dbo.sp_RegistrarVentaCompleta TO usuario_lector;
GRANT EXECUTE ON TYPE::dbo.TipoDetalleVenta    TO usuario_lector;
GO

/*  Parte 2: permisos a nivel de rol  */

IF DATABASE_PRINCIPAL_ID('rol_consulta_vinilos') IS NULL CREATE ROLE rol_consulta_vinilos;
GRANT SELECT ON dbo.Vinilo TO rol_consulta_vinilos;
ALTER ROLE rol_consulta_vinilos ADD MEMBER usuario_con_rol;
-- usuario_sin_rol NO se agrega a ningun rol
GO

/*  Pruebas  */
-- Todo en un solo lote para poder juntar los resultados en una tabla

IF OBJECT_ID('tempdb..#resultados') IS NOT NULL DROP TABLE #resultados;
CREATE TABLE #resultados
(
    n          INT IDENTITY(1,1),
    prueba     VARCHAR(60),
    usuario    VARCHAR(30),
    esperado   VARCHAR(20),
    obtenido   VARCHAR(20),
    nro_error  INT NULL
);

DECLARE @res VARCHAR(20), @err INT, @x INT, @nueva_compra INT;

-- tabla con los renglones de la venta que va a registrar usuario_lector
DECLARE @renglones dbo.TipoDetalleVenta;
INSERT INTO @renglones (id_vinilo, cantidad, precio_unidad) VALUES (9, 1, 30000);

-- Prueba 1: SELECT sobre Vinilo con usuario_con_rol
SET @res = NULL; SET @err = NULL;
EXECUTE AS USER = 'usuario_con_rol';
BEGIN TRY
    SELECT TOP 1 @x = id_vinilo FROM Vinilo;
    SET @res = 'Correcto';
END TRY
BEGIN CATCH
    SET @res = 'Acceso denegado'; SET @err = ERROR_NUMBER();
END CATCH;
REVERT;
INSERT INTO #resultados (prueba, usuario, esperado, obtenido, nro_error)
VALUES ('SELECT sobre Vinilo', 'usuario_con_rol', 'Correcto', @res, @err);

-- Prueba 2: SELECT sobre Vinilo con usuario_sin_rol
SET @res = NULL; SET @err = NULL;
EXECUTE AS USER = 'usuario_sin_rol';
BEGIN TRY
    SELECT TOP 1 @x = id_vinilo FROM Vinilo;
    SET @res = 'Correcto';
END TRY
BEGIN CATCH
    SET @res = 'Acceso denegado'; SET @err = ERROR_NUMBER();
END CATCH;
REVERT;
INSERT INTO #resultados (prueba, usuario, esperado, obtenido, nro_error)
VALUES ('SELECT sobre Vinilo', 'usuario_sin_rol', 'Acceso denegado', @res, @err);

-- Prueba 3: INSERT directo sobre Compra con usuario_admin
SET @res = NULL; SET @err = NULL; SET @nueva_compra = NULL;
EXECUTE AS USER = 'usuario_admin';
BEGIN TRY
    INSERT INTO Compra (estado_de_compra, fecha_compra, id_usuario, id_metodo)
    VALUES ('pendiente', CAST(GETDATE() AS DATE), 1, 1);
    SET @nueva_compra = SCOPE_IDENTITY();
    SET @res = 'Correcto';
END TRY
BEGIN CATCH
    SET @res = 'Acceso denegado'; SET @err = ERROR_NUMBER();
END CATCH;
REVERT;
INSERT INTO #resultados (prueba, usuario, esperado, obtenido, nro_error)
VALUES ('INSERT directo sobre Compra', 'usuario_admin', 'Correcto', @res, @err);

-- se borra la compra de prueba para no dejar una compra sin renglones
IF @nueva_compra IS NOT NULL DELETE FROM Compra WHERE id_compra = @nueva_compra;

-- Prueba 4: INSERT directo sobre Compra con usuario_lector
SET @res = NULL; SET @err = NULL;
EXECUTE AS USER = 'usuario_lector';
BEGIN TRY
    INSERT INTO Compra (estado_de_compra, fecha_compra, id_usuario, id_metodo)
    VALUES ('pendiente', CAST(GETDATE() AS DATE), 1, 1);
    SET @res = 'Correcto';
END TRY
BEGIN CATCH
    SET @res = 'Acceso denegado'; SET @err = ERROR_NUMBER();
END CATCH;
REVERT;
INSERT INTO #resultados (prueba, usuario, esperado, obtenido, nro_error)
VALUES ('INSERT directo sobre Compra', 'usuario_lector', 'Acceso denegado', @res, @err);

-- Prueba 5: registrar una venta con el procedimiento, con usuario_lector
SET @res = NULL; SET @err = NULL; SET @nueva_compra = NULL;
EXECUTE AS USER = 'usuario_lector';
BEGIN TRY
    EXEC dbo.sp_RegistrarVentaCompleta @id_usuario = 5, @id_metodo = 3,
                                       @detalle = @renglones, @id_compra = @nueva_compra OUTPUT;
    SET @res = 'Correcto';
END TRY
BEGIN CATCH
    SET @res = 'Acceso denegado'; SET @err = ERROR_NUMBER();
END CATCH;
REVERT;
INSERT INTO #resultados (prueba, usuario, esperado, obtenido, nro_error)
VALUES ('EXEC sp_RegistrarVentaCompleta', 'usuario_lector', 'Correcto', @res, @err);

-- Resumen de las 5 pruebas
SELECT n, prueba, usuario, esperado, obtenido, nro_error FROM #resultados ORDER BY n;

-- La venta de la prueba 5 quedo registrada (compra, renglon y stock):
SELECT c.id_compra, c.estado_de_compra, dc.id_vinilo, dc.cantidad, dc.precio_unidad
FROM Compra c JOIN Detalle_compra dc ON dc.id_compra = c.id_compra
WHERE c.id_compra = @nueva_compra;
GO

/* Opcional para borrar los usuarios de prueba
USE proyecto_grupo31_secuela;
DROP USER usuario_admin;  DROP USER usuario_lector;
DROP USER usuario_con_rol; DROP USER usuario_sin_rol;
DROP ROLE rol_consulta_vinilos;
USE master;
DROP LOGIN usuario_admin;  DROP LOGIN usuario_lector;
DROP LOGIN usuario_con_rol; DROP LOGIN usuario_sin_rol;
---------------------------------------------------------------------- */
