use proyecto_grupo31_secuela
GO

--------------------------------------------------------------------------------
-- INSERTS TABLAS INDEPENDIENTES osea las Padres
--------------------------------------------------------------------------------
-- Usuarios
INSERT INTO Usuario (nombre_usuario, correo_usuario, contraseña_usuario) VALUES
  ('lucia.gomez', 'lucia.gomez@example.com', 'clave_lg26'),
  ('martin.fernandez', 'martin.fernandez@example.com', 'clave_mf26'),
  ('sofia.ramires', 'sofia.ramirez@example.com', 'clave_sr26'),
  ('joaquin.benitez', 'joaquin.benitez@example.com', 'clave_jb26'),
  ('valentina.acosta', 'valentina.acosta@example.com', 'clave_va26'),
  ('mateo.romero', 'mateo.romero@example.com', 'clave_mr26'),
  ('camila.duarte', 'camila.duarte@example.com', 'clave_cd26'),
  ('nicolas.ortiz', 'nicolas.ortiz@example.com', 'clave_no26'),
  ('agustina.molina', 'agustina.molina@example.com', 'clave_am26'),
  ('tomas.villalba', 'tomas.villalba@example.com', 'clave_tv26');

-- Metodos de Pago
INSERT INTO Metodo_pago (nombre_Metodo_pago) VALUES
  ('Efectivo'),
  ('Transferencia bancaria'),
  ('Tarjeta de debito'),
  ('Tarjeta de credito'),
  ('Mercado Pago'),
  ('Uala'),
  ('MODO'),
  ('Cuenta DNI');

-- Generos
INSERT INTO genero (nombre_genero) VALUES
  ('Rock nacional'),
  ('Rock internacional'),
  ('Jazz'),
  ('Blues'),
  ('Folklore'),
  ('Tango'),
  ('Pop'),
  ('Reggae'),
  ('Funk y Soul'),
  ('Musica clasica');

-- Colores
INSERT INTO color (nombre_color) VALUES
  ('Negro'),
  ('Rojo'),
  ('Azul'),
  ('Verde'),
  ('Transparente'),
  ('Blanco'),
  ('Amarillo'),
  ('Violeta'),
  ('Naranja'),
  ('Rosa');

-- Provincias
INSERT INTO provincia (nombre_provincia) VALUES
  ('Corrientes'),
  ('Chaco'),
  ('Misiones'),
  ('Entre Rios'),
  ('Santa Fe'),
  ('Buenos Aires'),
  ('Cordoba'),
  ('Formosa'),
  ('Tucuman'),
  ('Mendoza');

-- Vinilo (18: los 10 primeros son normales y del 11 al 18 son personalizados)
-- stock_actual = lo que ingreso por proveedores menos lo vendido en compras 'realizado'.
-- Una compra 'pendiente' (RN.05) no descuenta stock hasta que se confirma 

-- Quedan con stock por debajo del minimo: Spinetta, Mercedes Sosa y Piazzolla (para probar el aviso de stock bajo).
INSERT INTO Vinilo (artista_Vinilo, stock_minimo, stock_actual, titulo_Vinilo, tipo_vinilo) VALUES
  ('Charly Garcia', 5, 32, 'Clics Modernos', 'Normal'),
  ('Soda Stereo', 5, 26, 'Dynamo', 'Normal'),
  ('Luis Alberto Spinetta', 5, 4, 'Artaud', 'Normal'),
  ('Mercedes Sosa', 8, 7, 'Gracias a la vida', 'Normal'),
  ('Astor Piazzolla', 6, 5, 'Libertango', 'Normal'),
  ('Miles Davis', 5, 20, 'Kind of Blue', 'Normal'),
  ('Pink Floyd', 6, 32, 'The Dark Side of the Moon', 'Normal'),
  ('Bob Marley and The Wailers', 4, 17, 'Exodus', 'Normal'),
  ('Fito Paez', 5, 26, 'El amor despues del amor', 'Normal'),
  ('Andres Calamaro', 4, 19, 'Alta suciedad', 'Normal'),
  ('Gustavo Cerati', 2, 2, 'Bocanada (edicion personalizada)', 'Personalizado'),
  ('Soda Stereo', 2, 2, 'Dynamo (edicion personalizada)', 'Personalizado'),
  ('Mercedes Sosa', 2, 2, 'Gracias a la vida (edicion personalizada)', 'Personalizado'),
  ('Pink Floyd', 2, 2, 'The Dark Side of the Moon (edicion personalizada)', 'Personalizado'),
  ('Miles Davis', 2, 2, 'Kind of Blue (edicion personalizada)', 'Personalizado'),
  ('Bob Marley and The Wailers', 2, 2, 'Exodus (edicion personalizada)', 'Personalizado'),
  ('Astor Piazzolla', 2, 3, 'Libertango (edicion personalizada)', 'Personalizado'),
  ('Fito Paez', 2, 3, 'El amor despues del amor (edicion personalizada)', 'Personalizado');

--------------------------------------------------------------------------------
-- INSERTS TABLAS DEPENDIENTES INTERMEDIAS
--------------------------------------------------------------------------------
-- Ciudades
INSERT INTO ciudad (nombre_ciudad, id_provincia) VALUES
  ('Corrientes Capital', 1),
  ('Resistencia', 2),
  ('Posadas', 3),
  ('Parana', 4),
  ('Rosario', 5),
  ('Mar del Plata', 6),
  ('Cordoba Capital', 7),
  ('Formosa Capital', 8),
  ('San Miguel de Tucuman', 9),
  ('Mendoza Capital', 10);

-- Direcciones - piso, departamento y altura pueden ser NULL
INSERT INTO direccion (calle_direccion, altura_direccion, piso_direccion, departamento_direccion, id_ciudad) VALUES
  ('Junin', 1120, NULL, NULL, 1),
  ('Av. 9 de Julio', 1500, NULL, NULL, 2),
  ('Av. Mitre', 2350, '1', 'B', 3),
  ('San Martin', 845, NULL, NULL, 4),
  ('Cordoba', 1780, '3', 'A', 5),
  ('Av. Colon', 3120, NULL, NULL, 6),
  ('Obispo Trejo', 560, '2', 'C', 7),
  ('Belgrano', 740, NULL, NULL, 8),
  ('Munecas', 430, NULL, NULL, 9),
  ('Ruta Nacional 40 km 3', NULL, NULL, NULL, 10);

-- Proveedores - el proveedor N usa la direccion N
INSERT INTO Proveedor (nombre_Proveedor, id_direccion) VALUES
  ('Discos del Litoral', 1),
  ('Vinilos del Chaco', 2),
  ('Distribuidora Sonido Misionero', 3),
  ('Casa del Disco Parana', 4),
  ('Rosario Records Distribuidora', 5),
  ('Atlantico Musica Mayorista', 6),
  ('Cordoba Vinilos SRL', 7),
  ('Formosa Discos', 8),
  ('Tucuman Sonidos', 9),
  ('Distribuidora Cuyo Musica', 10);

--------------------------------------------------------------------------------
-- INSERTS TABLAS DEPENDIENTES DE COMPRAS Y PROVEEDORES
--------------------------------------------------------------------------------
-- Ingreso_vinilo - 10 lotes osea uno por proveedor
INSERT INTO Ingreso_vinilo (fecha, comprobante, id_proveedor) VALUES
  ('2026-06-05', '0001-00004501', 1),
  ('2026-06-19', '0001-00004502', 2),
  ('2026-07-03', '0002-00001870', 3),
  ('2026-07-17', '0001-00007310', 4),
  ('2026-07-31', '0003-00000455', 5),
  ('2026-08-07', '0001-00002288', 6),
  ('2026-08-14', '0004-00003901', 7),
  ('2026-08-21', '0001-00005512', 8),
  ('2026-09-04', '0002-00006120', 9),
  ('2026-09-18', '0001-00009047', 10);

-- Compra - 12, 10 realizadas, 1 pendiente y 1 cancelada
INSERT INTO Compra (estado_de_compra, fecha_compra, id_usuario, id_metodo) VALUES
  ('realizado', '2026-08-12', 1, 2),
  ('realizado', '2026-08-19', 2, 4),
  ('realizado', '2026-08-27', 3, 3),
  ('realizado', '2026-09-02', 4, 5),
  ('realizado', '2026-09-05', 5, 1),
  ('realizado', '2026-09-09', 1, 2),
  ('realizado', '2026-09-14', 6, 6),
  ('realizado', '2026-09-21', 7, 4),
  ('realizado', '2026-09-28', 8, 5),
  ('realizado', '2026-10-03', 2, 7),
  ('pendiente', '2026-10-12', 9, 8),
  ('cancelado', '2026-10-08', 10, 4);

-- Telefonos del Proveedor - 12 algunos proveedores tienen dos telefonos
INSERT INTO numero_proveedor (codigo_area, numero_proveedor, id_proveedor) VALUES
  (379, 4456120, 1),
  (379, 4456121, 1),
  (362, 4421305, 2),
  (376, 4437710, 3),
  (343, 4228450, 4),
  (341, 4471230, 5),
  (341, 4471231, 5),
  (223, 4950660, 6),
  (351, 4234870, 7),
  (370, 4425190, 8),
  (381, 4311940, 9),
  (261, 4298350, 10);

-- Correos del Proveedor
INSERT INTO correo_proveedor (correo, id_proveedor) VALUES
  ('ventas@discosdellitoral.example.com', 1),
  ('compras@discosdellitoral.example.com', 1),
  ('ventas@vinilosdelchaco.example.com', 2),
  ('ventas@sonidomisionero.example.com', 3),
  ('contacto@casadeldiscoparana.example.com', 4),
  ('ventas@rosariorecords.example.com', 5),
  ('mayoristas@rosariorecords.example.com', 5),
  ('ventas@atlanticomusica.example.com', 6),
  ('ventas@cordobavinilos.example.com', 7),
  ('ventas@formosadiscos.example.com', 8),
  ('ventas@tucumansonidos.example.com', 9),
  ('ventas@cuyomusica.example.com', 10);

--------------------------------------------------------------------------------
-- INSERTS TABLAS DE DETALLES
--------------------------------------------------------------------------------
-- vinilo_personalizado (8)
INSERT INTO vinilo_personalizado (id_vinilo, descripcion_vinilo_personalizado, id_genero, id_color) VALUES
  (11, 'Tapa con foto familiar y dedicatoria', 1, 2),
  (12, 'Etiqueta central con el nombre del cliente', 1, 3),
  (13, 'Dedicatoria grabada en la contratapa', 5, 1),
  (14, 'Sobre interno con letras impresas', 2, 6),
  (15, 'Edicion de regalo con estuche', 3, 3),
  (16, 'Tapa con ilustracion a pedido', 8, 4),
  (17, 'Dedicatoria y fecha de aniversario', 6, 8),
  (18, 'Vinilo color rosa con etiqueta grabada', 1, 10);

-- detalle_de_ingreso (32 renglones). Algunos vinilos entran por mas de un proveedor (RN.02)
-- precio_unitario = lo que paga la tienda al proveedor
INSERT INTO detalle_de_ingreso (precio_unitario, cantidad, id_lote, id_vinilo) VALUES
  (21500, 20, 1, 1),
  (20800, 15, 1, 2),
  (23400, 4, 1, 3),
  (19800, 5, 2, 4),
  (22600, 4, 2, 5),
  (24900, 15, 2, 6),
  (27500, 20, 3, 7),
  (21900, 12, 3, 8),
  (20400, 15, 3, 9),
  (20100, 12, 4, 10),
  (22100, 10, 4, 1),
  (21400, 8, 4, 2),
  (33000, 3, 5, 11),
  (32500, 3, 5, 12),
  (31500, 3, 5, 13),
  (35500, 3, 5, 14),
  (34000, 3, 6, 15),
  (32800, 3, 6, 16),
  (33500, 3, 6, 17),
  (32000, 3, 6, 18),
  (24000, 2, 7, 3),
  (25500, 8, 7, 6),
  (28100, 10, 7, 7),
  (21000, 8, 8, 9),
  (23200, 2, 8, 5),
  (22500, 6, 8, 8),
  (20400, 3, 9, 4),
  (20700, 8, 9, 10),
  (22000, 5, 9, 2),
  (22700, 5, 10, 1),
  (28700, 6, 10, 7),
  (21600, 5, 10, 9);

-- Detalle_compra (26 renglones)
-- precio_unidad = precio de venta AL MOMENTO de la compra: queda guardado y no cambia aunque cambie el precio.
-- Por eso un mismo vinilo (ej: Pink Floyd) figura mas caro en las compras de octubre que en las de agosto y septiembre.
INSERT INTO Detalle_compra (precio_unidad, cantidad, id_compra, id_vinilo) VALUES
  (31200, 1, 1, 1),
  (39900, 1, 1, 7),
  (33900, 1, 2, 3),
  (36100, 2, 2, 6),
  (29600, 1, 2, 9),
  (28700, 1, 3, 4),
  (30200, 2, 4, 2),
  (29100, 1, 4, 10),
  (39900, 1, 5, 7),
  (31800, 1, 5, 8),
  (47800, 1, 6, 11),
  (32800, 1, 6, 5),
  (47100, 1, 7, 12),
  (51500, 1, 7, 14),
  (31200, 2, 8, 1),
  (29600, 1, 8, 9),
  (45700, 1, 8, 13),
  (49300, 1, 9, 15),
  (36100, 1, 9, 6),
  (43100, 2, 10, 7),
  (51400, 1, 10, 16),
  (36600, 1, 10, 3),
  (32600, 1, 11, 2),
  (52500, 1, 11, 17),
  (34300, 2, 12, 8),
  (50100, 1, 12, 18);

--------------------------------------------------------------------------------
-- SELECTS: VERIFICACION DE DATOS
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

-------- Proveedores y Ubicacion --------
SELECT * FROM provincia;
SELECT * FROM ciudad;
SELECT * FROM direccion;
SELECT * FROM Proveedor;
SELECT * FROM numero_proveedor;
SELECT * FROM correo_proveedor;
SELECT * FROM Ingreso_vinilo;
SELECT * FROM detalle_de_ingreso;

-------- Cantidad de registros por tabla (tienen que ser 8 o mas) --------
SELECT 'Usuario' AS tabla, COUNT(*) AS registros FROM Usuario
UNION ALL SELECT 'Metodo_pago', COUNT(*) FROM Metodo_pago
UNION ALL SELECT 'Vinilo', COUNT(*) FROM Vinilo
UNION ALL SELECT 'genero', COUNT(*) FROM genero
UNION ALL SELECT 'color', COUNT(*) FROM color
UNION ALL SELECT 'provincia', COUNT(*) FROM provincia
UNION ALL SELECT 'ciudad', COUNT(*) FROM ciudad
UNION ALL SELECT 'direccion', COUNT(*) FROM direccion
UNION ALL SELECT 'Compra', COUNT(*) FROM Compra
UNION ALL SELECT 'Detalle_compra', COUNT(*) FROM Detalle_compra
UNION ALL SELECT 'vinilo_personalizado', COUNT(*) FROM vinilo_personalizado
UNION ALL SELECT 'Proveedor', COUNT(*) FROM Proveedor
UNION ALL SELECT 'Ingreso_vinilo', COUNT(*) FROM Ingreso_vinilo
UNION ALL SELECT 'detalle_de_ingreso', COUNT(*) FROM detalle_de_ingreso
UNION ALL SELECT 'numero_proveedor', COUNT(*) FROM numero_proveedor
UNION ALL SELECT 'correo_proveedor', COUNT(*) FROM correo_proveedor;

-----------UPDATES-------------------------
-- Cada UPDATE lleva su WHERE, sin WHERE se modifican todas las filas de la tabla
-- Cada uno modifica exactamente 1 registro.

-- se corrige un error de tipeo en el nombre de usuario
UPDATE Usuario
SET nombre_usuario = 'sofia.ramirez'
WHERE id_usuario = 3;

-- se corrige la altura de la direccion del proveedor 1
UPDATE direccion
SET altura_direccion = 1125
WHERE id_direccion = 1;

-- Pink Floyd es de lo que mas se vende: se sube el stock minimo
UPDATE Vinilo
SET stock_minimo = 8
WHERE id_vinilo = 7;

-- se cambia el nombre de un metodo de pago
UPDATE Metodo_pago
SET nombre_Metodo_pago = 'Mercado Pago QR'
WHERE id_metodo = 5;

-- el cliente cambio el color de su vinilo personalizado
UPDATE vinilo_personalizado
SET id_color = 5
WHERE id_vinilo = 12;

-- se confirma el pago de la compra 11 (estaba 'pendiente') y recien ahi se descuenta el stock (RN.05)
UPDATE Compra
SET estado_de_compra = 'realizado'
WHERE id_compra = 11;

UPDATE Vinilo
SET stock_actual = stock_actual - 1
WHERE id_vinilo = 2;

UPDATE Vinilo
SET stock_actual = stock_actual - 1
WHERE id_vinilo = 17;

-----------DELETES-------------------------
-- Cada DELETE lleva su WHERE. Se borran solo registros de prueba que nadie usa.

-- 1) registros sueltos, sin ningun dato que dependa de ellos
INSERT INTO provincia (nombre_provincia) VALUES ('Santa Cruz');
INSERT INTO color (nombre_color) VALUES ('Dorado');

DELETE FROM provincia
WHERE nombre_provincia = 'Santa Cruz';

DELETE FROM color
WHERE nombre_color = 'Dorado';

-- 2) se borra un telefono de un proveedor
DELETE FROM numero_proveedor
WHERE codigo_area = 379 AND numero_proveedor = 4456121 AND id_proveedor = 1;

-- 3) prueba del ON DELETE CASCADE: al borrar el proveedor se borran solos sus telefonos y correos
INSERT INTO direccion (calle_direccion, altura_direccion, id_ciudad) VALUES ('Calle de prueba', 100, 1);
INSERT INTO Proveedor (nombre_Proveedor, id_direccion) VALUES ('Proveedor de prueba', 11);
INSERT INTO numero_proveedor (codigo_area, numero_proveedor, id_proveedor) VALUES (379, 4000000, 11);
INSERT INTO correo_proveedor (correo, id_proveedor) VALUES ('prueba@example.com', 11);

DELETE FROM Proveedor
WHERE id_proveedor = 11;

DELETE FROM direccion
WHERE id_direccion = 11;

-- Estos dos tienen que fallar (se dejan comentados): son las pruebas de las reglas de borrado
-- DELETE FROM Usuario WHERE id_usuario = 1;  -- error: el usuario tiene compras (ON DELETE NO ACTION, RN.06)
-- DELETE FROM Vinilo WHERE id_vinilo = 1;    -- error: el vinilo tiene ventas e ingresos asociados

-------- Pruebas de las restricciones: cada INSERT de abajo tiene que dar ERROR (ir descomentando de a uno) --------
-- INSERT INTO Usuario (nombre_usuario, correo_usuario, contraseña_usuario) VALUES ('otro', 'lucia.gomez@example.com', 'clave1234');   -- UNIQUE: correo repetido
-- INSERT INTO Usuario (nombre_usuario, correo_usuario, contraseña_usuario) VALUES ('otro', 'correo-sin-arroba', 'clave1234');          -- CHECK: formato de correo
-- INSERT INTO Vinilo (artista_Vinilo, stock_minimo, stock_actual, titulo_Vinilo) VALUES ('X', 1, -5, 'Y');                             -- CHECK: stock negativo
-- INSERT INTO Vinilo (artista_Vinilo, stock_minimo, stock_actual, titulo_Vinilo, tipo_vinilo) VALUES ('X', 1, 1, 'Y', 'Raro');         -- CHECK: tipo invalido
-- INSERT INTO Compra (estado_de_compra, fecha_compra, id_usuario, id_metodo) VALUES ('enviado', '2026-10-15', 1, 1);                   -- CHECK: estado invalido
-- INSERT INTO Detalle_compra (precio_unidad, cantidad, id_compra, id_vinilo) VALUES (1000, 0, 12, 1);                                  -- CHECK: cantidad 0
-- INSERT INTO Compra (estado_de_compra, fecha_compra, id_usuario, id_metodo) VALUES ('pendiente', '2026-10-15', 99, 1);               -- FK: usuario inexistente