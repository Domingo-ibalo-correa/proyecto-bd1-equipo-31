USE proyecto_grupo31_secuela;
GO

/* Parte 1: tabla de pruebas (sin clave ni indice) */
DROP TABLE IF EXISTS Compra_historica;
GO
CREATE TABLE Compra_historica
(
    id_compra    BIGINT IDENTITY(1,1),
    fecha_compra DATE NOT NULL,
    id_usuario   INT NOT NULL,
    importe      DECIMAL(12,2) NOT NULL
);
GO

/* Parte 2: carga masiva de 1.000.000 de filas 
   Fechas al azar entre 2022 y 2026, 10 clientes e importes hasta 100000*/
SET NOCOUNT ON;
GO

WITH Numeros AS
(
    SELECT TOP (1000000)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO Compra_historica (fecha_compra, id_usuario, importe)
SELECT DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 1825), '2022-01-01'),
       1 + ABS(CHECKSUM(NEWID()) % 10),
       RAND(CHECKSUM(NEWID())) * 100000
FROM Numeros;
GO

SELECT COUNT(*) AS CantidadRegistros FROM Compra_historica;      -- esperado: 1000000
GO

/* Parte 3: consulta sin indices 
   Se limpia la memoria cache para que las mediciones sean comparables
   (DBCC DROPCLEANBUFFERS necesita permisos de administrador).             */
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

CHECKPOINT; DBCC DROPCLEANBUFFERS;
GO
SELECT id_compra, fecha_compra, importe
FROM Compra_historica
WHERE fecha_compra BETWEEN '2025-01-01' AND '2025-03-31';
GO

/* Parte 4: indice agrupado sobre la fecha */
CREATE CLUSTERED INDEX IX_Compra_historica_Fecha
ON Compra_historica (fecha_compra);
GO

CHECKPOINT; DBCC DROPCLEANBUFFERS;
GO
SELECT id_compra, fecha_compra, importe
FROM Compra_historica
WHERE fecha_compra BETWEEN '2025-01-01' AND '2025-03-31';
GO
-- Anotar de nuevo (se espera Clustered Index Seek)

/* Parte 5: se elimina el indice */
DROP INDEX IX_Compra_historica_Fecha ON Compra_historica;
GO

/* Parte 6: indice con cobertura */
CREATE NONCLUSTERED INDEX IX_Compra_historica_Fecha_Cobertura
ON Compra_historica (fecha_compra)
INCLUDE (importe);
GO

CHECKPOINT; DBCC DROPCLEANBUFFERS;
GO
SELECT fecha_compra, importe
FROM Compra_historica
WHERE fecha_compra BETWEEN '2025-01-01' AND '2025-03-31';
GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

/* Parte 7: indices sobre las tablas reales 
   Son los indices que ayudan a las consultas de la Etapa 4. Con las pocas
   filas de los datos de prueba casi no se nota la diferencia pero sirven
   cuando la tienda tenga muchas ventas                                 */
CREATE NONCLUSTERED INDEX IX_Compra_fecha_estado
ON Compra (fecha_compra, estado_de_compra)
INCLUDE (id_usuario, id_metodo);

CREATE NONCLUSTERED INDEX IX_Compra_usuario
ON Compra (id_usuario);

CREATE NONCLUSTERED INDEX IX_Detalle_compra_vinilo
ON Detalle_compra (id_vinilo)
INCLUDE (cantidad, precio_unidad);

CREATE NONCLUSTERED INDEX IX_detalle_ingreso_vinilo
ON detalle_de_ingreso (id_vinilo);

CREATE NONCLUSTERED INDEX IX_Vinilo_stock
ON Vinilo (stock_actual, stock_minimo);
GO

-- Indices creados
SELECT t.name AS tabla, i.name AS indice, i.type_desc AS tipo
FROM sys.indexes i
JOIN sys.tables t ON t.object_id = i.object_id
WHERE i.name LIKE 'IX[_]%'
ORDER BY t.name, i.name;
GO

/* Limpieza (opcional) 
DROP TABLE IF EXISTS Compra_historica;
*/
