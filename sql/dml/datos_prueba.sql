use proyecto_grupo31_secuela
--------------------------------------------------------------------------------
-- INSERTS TABLAS INDEPENDIENTES osea las Padres
--------------------------------------------------------------------------------
-- Usuario
INSERT INTO Usuario (nombre_usuario, correo_usuario, contraseña_usuario) 
VALUES ('domingo', 'domingoibalo8788@gmail.com', 'pensando123');

-- Metodo de Pago 
INSERT INTO Metodo_pago (nombre_Metodo_pago) 
VALUES ('tranferencia')

-- Género
INSERT INTO genero (nombre_genero) 
VALUES ('migajero');

-- Color 
INSERT INTO color (nombre_color) 
VALUES ('morado');

-- Provincia 
INSERT INTO provincia (nombre_provincia) 
VALUES ('Corrientes');

-- Vinilo 
INSERT INTO Vinilo (artista_Vinilo, stock_minimo, stock_actual, titulo_Vinilo) 
VALUES ('mon laferte', 6, 2, 'melancolia');

--------------------------------------------------------------------------------
-- INSERTS TABLAS DEPENDIENTES INTERMEDIAS
--------------------------------------------------------------------------------
-- Ciudad 
INSERT INTO ciudad (nombre_ciudad, id_provincia) 
VALUES ('Corrientes Capital', 1);

-- Dirección 
INSERT INTO direccion (calle_direccion, altura_direccion, id_ciudad) 
VALUES ('la olla', 1234, 1);

-- Proveedor 
INSERT INTO Proveedor (nombre_Proveedor, id_direccion) 
VALUES ('Distribuidora de joyitas', 1);


--------------------------------------------------------------------------------
-- INSERTS TABLAS DEPENDIENTES DE COMPRAS Y PROVEEDORES
--------------------------------------------------------------------------------
-- Teléfonos del Proveedor 
INSERT INTO numero_proveedor (codigo_area, numero_proveedor, id_proveedor) 
VALUES (3400, 3794564869, 1);

-- Correos del Proveedor 
INSERT INTO correo_proveedor (correo, id_proveedor) 
VALUES ('puedoserelproveedor@gmail.com', 1);

-- Ingreso_vinilo
INSERT INTO Ingreso_vinilo (fecha, comprobante, id_proveedor) 
VALUES ('2026-04-10', 987656, 1);

-- Compra
INSERT INTO Compra (estado_de_compra, fecha_compra, id_usuario, id_metodo) 
VALUES ('realizado', '2026-08-25', 1, 1);

--------------------------------------------------------------------------------
-- INSERTS TABLAS DE DETALLES 
--------------------------------------------------------------------------------
-- vinilo_personalizado 
INSERT INTO vinilo_personalizado (id_vinilo, descripcion_vinilo_personalizado, id_genero, id_color) 
VALUES (1, 'musiquitas migajeras', 1, 1);
-- detalle_de_ingreso
INSERT INTO detalle_de_ingreso (precio_unitario, cantidad, id_lote, id_vinilo) 
VALUES (1200.50, 50, 1, 1);


-- Detalle_compra 
INSERT INTO Detalle_compra (precio_unidad, cantidad, id_compra, id_vinilo) 
VALUES (1850.80, 3, 1, 1);
--------------------------------------------------------------------------------
-- SELECTS: VERIFICACIÓN DE DATOS 
--------------------------------------------------------------------------------
-------- Usuarios y Compras ---------
SELECT * FROM Usuario;
SELECT * FROM Metodo_pago;
SELECT * FROM Compra;
SELECT * FROM Detalle_compra;

------- Vinilos y Atributos -----------
SELECT * FROM genero;
SELECT * FROM color;
SELECT * FROM Vinilo;
SELECT * FROM vinilo_personalizado;

-------- Proveedores y Ubicación --------
SELECT * FROM provincia;
SELECT * FROM ciudad;
SELECT * FROM direccion;
SELECT * FROM Proveedor;
SELECT * FROM numero_proveedor;
SELECT * FROM correo_proveedor;
SELECT * FROM Ingreso_vinilo;
SELECT * FROM detalle_de_ingreso;

-----------UPDATES-------------------------
UPDATE Usuario
SET nombre_usuario='juanito'


UPDATE ciudad
SET id_provincia=2

UPDATE direccion
SET id_ciudad=2

UPDATE Proveedor
SET id_direccion=2

UPDATE numero_proveedor
SET id_proveedor=2

UPDATE correo_proveedor
SET id_proveedor=2

UPDATE Ingreso_vinilo
SET id_proveedor=2

UPDATE Compra
SET id_usuario=2
UPDATE Compra
SET id_metodo=2

UPDATE vinilo_personalizado
SET id_genero=2
UPDATE vinilo_personalizado
SET id_color = 2

UPDATE detalle_de_ingreso
SET id_lote=2
UPDATE detalle_de_ingreso
SET id_vinilo=2

UPDATE Detalle_compra
SET id_compra=2
UPDATE Detalle_compra
SET id_vinilo=2