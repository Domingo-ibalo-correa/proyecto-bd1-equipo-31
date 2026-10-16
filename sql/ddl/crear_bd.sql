-- AGREGADO: el script se puede correr varias veces (si la base ya existe no la vuelve a crear)
-- y el GO separa la creacion de la base del resto, que es lo que pide SQL Server.
-- AGREGADO: regla general de borrado/modificacion de las FK:
--   NO ACTION = no se puede borrar un registro si otros dependen de el (se usa en todo lo que es historial,
--               por la RN.06: facturas y comprobantes se guardan de forma permanente)
--   CASCADE   = se borra junto con su padre (solo telefonos, correos y personalizacion de un vinilo)
--   ON UPDATE NO ACTION en todas, porque las claves son IDENTITY y no se modifican
IF DB_ID('proyecto_grupo31_secuela') IS NULL
    CREATE DATABASE proyecto_grupo31_secuela;
GO

use proyecto_grupo31_secuela
GO
---------------------tablas padre-------------------------------------
--tabla usuario--
-- lo que nos permite crear un usuario "darle un nombre, contraseña y correo"
-- La restriccion pensada fue hacer UNIQUE el correo del usuario para que sea unico
-- AGREGADO: CHECK para que el correo tenga formato de correo (algo@algo.algo)
CREATE TABLE Usuario(
 id_usuario INT IDENTITY (1,1),
 nombre_usuario VARCHAR (50) NOT NULL,
 correo_usuario VARCHAR (50) NOT NULL,
 contraseña_usuario VARCHAR (20) NOT NULL,
 CONSTRAINT UQ_correo_usuario UNIQUE (correo_usuario),
 CONSTRAINT CHK_correo_usuario CHECK (correo_usuario LIKE '%_@_%._%'),
 CONSTRAINT PK_ID_USUARIO PRIMARY KEY (id_usuario)
);

--tabla metodo_pago--
-- la tabla metodo de pago nos permite saber como pago el cliente si fue por "tranferencia, efectivo, debito, etc"
-- AGREGADO: UNIQUE para que no se cargue dos veces el mismo metodo de pago
CREATE TABLE Metodo_pago(
  id_metodo INT IDENTITY (1,1) NOT NULL,
  nombre_Metodo_pago VARCHAR(50) NOT NULL,
  CONSTRAINT UQ_nombre_metodo_pago UNIQUE (nombre_Metodo_pago),
  CONSTRAINT PK_ID_METODO PRIMARY KEY (id_metodo)
);

--tabla genero--
-- la tabla genero nos permite darle un genero a nuestro vinilo (uno al normal, varios al personalizado)
-- AGREGADO: UNIQUE para que no haya generos repetidos ("Rock" y "Rock" dos veces)
CREATE TABLE genero
(
  id_genero INT IDENTITY (1,1) NOT NULL,
  nombre_genero VARCHAR (50) NOT NULL,
  CONSTRAINT UQ_nombre_genero UNIQUE (nombre_genero),
  CONSTRAINT PK_ID_GENERO PRIMARY KEY (id_genero)
);

--tabla vinilo--
-- la tabla vinilo nos permite crear lo que seria un vinilo darle un artista, un titulo un control de stock en tiempo real
-- por eso lo de stock minimo y actual
-- La restriccion pensada fue primero dar un default al atributo tipo_vinilo que va diferenciar si el cliente quiere un vinilo
-- personalizado o un vinilo normal entonces por defencto ya te toma como un normal y para eso tambien usamos un check para comprobar
-- el stock que no sea menor a 0 ni el minimo ni el actual y para verificar la cadena de "normal" y "personalizado"
-- AGREGADO: id_genero (FK a genero) = el genero del vinilo NORMAL (RN.03: un vinilo comun tiene un unico genero).
-- El vinilo personalizado puede tener varios generos y esos van en la tabla genero_multiple, por eso
-- en Vinilo su id_genero va en NULL. El CHECK CHK_genero_segun_tipo obliga a que se cumpla eso:
-- Normal = con genero / Personalizado = sin genero.
CREATE TABLE Vinilo
(
  id_vinilo INT IDENTITY (1,1) NOT NULL,
  artista_Vinilo VARCHAR(50) NOT NULL,
  stock_minimo INT NOT NULL,
  stock_actual INT NOT NULL,
  titulo_Vinilo VARCHAR(100) NOT NULL,
  tipo_vinilo VARCHAR(20) DEFAULT 'Normal' NOT NULL,
  id_genero INT NULL,
  CONSTRAINT CHK_stock CHECK (stock_actual >= 0 AND stock_minimo >= 0),
  CONSTRAINT CHK_tipo_vinilo CHECK (tipo_vinilo IN ('Normal', 'Personalizado')),
  CONSTRAINT CHK_genero_segun_tipo CHECK ((tipo_vinilo = 'Normal' AND id_genero IS NOT NULL) OR (tipo_vinilo = 'Personalizado' AND id_genero IS NULL)),
  CONSTRAINT PK_ID_VINILO PRIMARY KEY (id_vinilo),
  CONSTRAINT FK_VINILO_GENERO FOREIGN KEY (id_genero) REFERENCES genero(id_genero)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);

--tabla color--
-- la tabla color nos permite darle un color personalizado a nuestro vinilo
-- AGREGADO: UNIQUE para que no haya colores repetidos
CREATE TABLE color
(
  id_color INT IDENTITY (1,1) NOT NULL,
  nombre_color VARCHAR(50) NOT NULL,
  CONSTRAINT UQ_nombre_color UNIQUE (nombre_color),
  CONSTRAINT PK_ID_COLOR PRIMARY KEY (id_color)
);

--tabla provincia--
-- la tabla provincia nos permite guardar los datos de la provincia del proveedor
-- AGREGADO: UNIQUE para que no se cargue dos veces la misma provincia
CREATE TABLE provincia
(
  id_provincia INT IDENTITY (1,1) NOT NULL,
  nombre_provincia VARCHAR(50) NOT NULL,
  CONSTRAINT UQ_nombre_provincia UNIQUE (nombre_provincia),
  CONSTRAINT PK_ID_PROVINCIA PRIMARY KEY (id_provincia)
);

---------------------tablas hijas-------------------------------------
------tabla ciudad -------
-- la tabla ciudad nos permite guardar los datos de la ciudad del proveedor
-- AGREGADO: UNIQUE para que una provincia no tenga dos ciudades con el mismo nombre
CREATE TABLE ciudad
(
  id_ciudad INT IDENTITY (1,1) NOT NULL,
  nombre_ciudad VARCHAR(50) NOT NULL,
  id_provincia INT NOT NULL,
  CONSTRAINT UQ_ciudad_provincia UNIQUE (nombre_ciudad, id_provincia),
  CONSTRAINT PK_CIUDAD PRIMARY KEY (id_ciudad),
  CONSTRAINT FK_CIUDAD_PROVINCIA FOREIGN KEY (id_provincia) REFERENCES provincia(id_provincia)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);
------tabla direccion -------
-- la tabla direccion nos permite guardar los datos de la direccion como altura, calle, piso y departamento del proveedor
-- pensamos que el piso, altura y departamento puedan aceptar  NULL
-- AGREGADO: CHECK para que la altura, si se carga, sea mayor a 0
CREATE TABLE direccion
(
  id_direccion INT IDENTITY (1,1) NOT NULL,
  calle_direccion VARCHAR(50) NOT NULL,
  altura_direccion INT  NULL,
  piso_direccion VARCHAR(20) NULL,
  departamento_direccion VARCHAR(20) NULL,
  id_ciudad INT NOT NULL,
  CONSTRAINT CHK_altura_direccion CHECK (altura_direccion IS NULL OR altura_direccion > 0),
  CONSTRAINT PK_ID_DIRECCION PRIMARY KEY (id_direccion),
  CONSTRAINT FK_ID_DIRECCION FOREIGN KEY (id_ciudad) REFERENCES ciudad(id_ciudad)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);

--tabla compra--
-- la tabla compra nos permite guardar el estado de la compra que fue 'pendiente', 'realizado', 'cancelado', la fecha de la compra
-- y la restriccion que pensamos es que haga un check al estado de la compra
-- AGREGADO: no se puede borrar un usuario ni un metodo de pago que tenga compras (NO ACTION)
CREATE TABLE Compra
(
  id_compra INT IDENTITY (1,1) NOT NULL,
  estado_de_compra VARCHAR(50) NOT NULL,
  fecha_compra DATE NOT NULL,
  id_usuario INT NOT NULL,
  id_metodo INT NOT NULL,
  CONSTRAINT CHK_estado_compra CHECK (estado_de_compra IN ('pendiente', 'realizado', 'cancelado')),
  CONSTRAINT PK_ID_COMPRA PRIMARY KEY (id_compra),
  CONSTRAINT FK_ID_COMPRA_USUARIO FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT FK_ID_COMPRA_METODO FOREIGN KEY (id_metodo) REFERENCES Metodo_pago(id_metodo)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);

--tabla detalle_compra--
-- la tabla detalle_compra nos permite saber la cantidad y el precio de la compra
-- tambien pensamos en la restriccion de hacer CHECK a la cantidad comprar que sea mayor a 0 y que el precio sea mayor o igual a 0
-- ademas cuando se hace un detalle compra usamos en los insert pensamos crear un atributo temporal que haga el subtotal del detalle
-- AGREGADO: precio_unidad pasa de FLOAT a DECIMAL(10,2) porque FLOAT redondea mal con plata
-- AGREGADO: el precio queda guardado en el detalle, asi no cambia aunque despues cambie el precio del vinilo
CREATE TABLE Detalle_compra
(
  precio_unidad DECIMAL(10,2) NOT NULL,
  cantidad INT NOT NULL,
  id_compra INT NOT NULL,
  id_vinilo INT NOT NULL,
  CONSTRAINT CHK_cantidad_compra CHECK (cantidad > 0),
  CONSTRAINT CHK_precio_compra CHECK (precio_unidad >= 0),
  CONSTRAINT PK_ID_DETALLE_COMPRA PRIMARY KEY (id_compra, id_vinilo),
  CONSTRAINT FK_ID_DETALLE_COMPRA_COMPRA FOREIGN KEY (id_compra) REFERENCES Compra(id_compra)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT FK_ID_DETALLE_COMPRA_VINILO FOREIGN KEY (id_vinilo) REFERENCES Vinilo(id_vinilo)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);

------tabla vinolo_personalizado -------
-- la tabla vinolo_personalizado nos permite crear un vinilo personalizado que va a tener la descripcion y su color
-- AGREGADO: los generos del personalizado (puede tener varios, RN.03) ya no van en esta tabla sino en genero_multiple
-- AGREGADO: si se borra el vinilo se borra tambien su personalizacion (CASCADE)
CREATE TABLE vinilo_personalizado
(
  id_vinilo INT NOT NULL,
  descripcion_vinilo_personalizado VARCHAR(100) NULL,
  id_color INT NOT NULL,
  CONSTRAINT PK_VINILO_PERSONALIZADO PRIMARY KEY (id_vinilo),
  CONSTRAINT FK_VINILO_PERSONALIZADO_VINILO FOREIGN KEY (id_vinilo) REFERENCES Vinilo(id_vinilo)
    ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT FK_VINILO_PERSONALIZADO_COLOR FOREIGN KEY (id_color) REFERENCES color(id_color)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);
------tabla genero_multiple -------
-- AGREGADO: un vinilo personalizado puede abarcar varios generos (RN.03) y un genero puede estar en varios
-- vinilos personalizados (relacion N:M), por eso va en una tabla aparte, con clave doble (vinilo + genero).
-- Esta tabla es la misma 'genero_multiple' que figura en el modelo relacional normalizado de la Etapa II.
-- La FK apunta a vinilo_personalizado (no a Vinilo): asi un vinilo NORMAL no puede tener mas de un genero.
-- Si se borra el vinilo personalizado se borran tambien sus generos (CASCADE).
CREATE TABLE genero_multiple
(
  id_vinilo INT NOT NULL,
  id_genero INT NOT NULL,
  CONSTRAINT PK_GENERO_MULTIPLE PRIMARY KEY (id_vinilo, id_genero),
  CONSTRAINT FK_GENERO_MULTIPLE_VINILO_PERSONALIZADO FOREIGN KEY (id_vinilo) REFERENCES vinilo_personalizado(id_vinilo)
    ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT FK_GENERO_MULTIPLE_GENERO FOREIGN KEY (id_genero) REFERENCES genero(id_genero)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);
------tabla proveedor -------
-- la tabla proveedor nos permite guardar el nombre del proveedor y hacer referencia a la direccion del proveedor
-- AGREGADO: UNIQUE para que no se cargue dos veces el mismo proveedor
CREATE TABLE Proveedor
(
  id_proveedor INT IDENTITY (1,1) NOT NULL,
  nombre_Proveedor VARCHAR(50) NOT NULL,
  id_direccion INT NOT NULL,
  CONSTRAINT UQ_nombre_proveedor UNIQUE (nombre_Proveedor),
  CONSTRAINT PK_PROVEEDOR PRIMARY KEY (id_proveedor),
  CONSTRAINT FK_PROVEEDOR_DIRECCION FOREIGN KEY (id_direccion) REFERENCES direccion(id_direccion)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);
------tabla ingreso_vinilo -------
-- la tabla ingreso_vinilo nos da los datos del ingresada de vinilos con su fecha y comprobante
-- AGREGADO: el comprobante es UNIQUE (no se carga dos veces el mismo, RN.06) y pasa a VARCHAR(20)
-- porque los comprobantes reales pueden tener guiones o ceros adelante (ej: 0001-00004521)
CREATE TABLE Ingreso_vinilo
(
  id_lote INT IDENTITY (1,1) NOT NULL,
  fecha DATE NOT NULL,
  comprobante VARCHAR(20) NOT NULL,
  id_proveedor INT NOT NULL,
  CONSTRAINT UQ_comprobante_ingreso UNIQUE (comprobante),
  CONSTRAINT PK_INGRESO_VINILO PRIMARY KEY (id_lote),
  CONSTRAINT FK_INGRESO_VINILO_PROVEEDOR FOREIGN KEY (id_proveedor) REFERENCES Proveedor(id_proveedor)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);
------tabla deatlle_de_ingreso -------
-- la tabla deatlle_de_ingreso nos da los datos de la cantidad y el precio ingresado de los vinilos
-- AGREGADO: CHECK igual que en detalle_compra (cantidad mayor a 0 y precio mayor o igual a 0)
-- y precio_unitario pasa a DECIMAL(10,2)
CREATE TABLE detalle_de_ingreso
(
  precio_unitario DECIMAL(10,2) NOT NULL,
  cantidad INT NOT NULL,
  id_lote INT NOT NULL,
  id_vinilo INT NOT NULL,
  CONSTRAINT CHK_cantidad_ingreso CHECK (cantidad > 0),
  CONSTRAINT CHK_precio_ingreso CHECK (precio_unitario >= 0),
  CONSTRAINT PK_DETALLE_DE_INGRESO PRIMARY KEY (id_lote, id_vinilo),
  CONSTRAINT FK_DETALLE_DE_INGRESO_INGRESO FOREIGN KEY (id_lote) REFERENCES Ingreso_vinilo(id_lote)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT FK_DETALLE_DE_INGRESO_VINILO FOREIGN KEY (id_vinilo) REFERENCES Vinilo(id_vinilo)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);
------tabla numero_proveedor -------
-- la tabla numero_proveedor nos deja almacenar varios numeros para un proveedor y saber su codigo de area
-- AGREGADO: CHECK para que el codigo de area y el numero sean mayores a 0
-- y si se borra el proveedor se borran sus numeros (CASCADE)
CREATE TABLE numero_proveedor
(
  codigo_area INT NOT NULL,
  numero_proveedor BIGINT NOT NULL,
  id_proveedor INT NOT NULL,
  CONSTRAINT CHK_codigo_area CHECK (codigo_area > 0),
  CONSTRAINT CHK_numero_proveedor CHECK (numero_proveedor > 0),
  CONSTRAINT PK_NUMERO_PROVEEDOR PRIMARY KEY (codigo_area, numero_proveedor, id_proveedor),
  CONSTRAINT FK_NUMERO_PROVEEDOR_PROVEEDOR FOREIGN KEY (id_proveedor) REFERENCES Proveedor(id_proveedor)
    ON DELETE CASCADE ON UPDATE NO ACTION
);
------tabla correo_proveedor -------
-- la tabla correo_proveedor nos deja almacenar varios correos para un proveedor
-- AGREGADO: CHECK de formato de correo y si se borra el proveedor se borran sus correos (CASCADE)
CREATE TABLE correo_proveedor
(
  id_proveedor INT NOT NULL,
  correo VARCHAR(50) NOT NULL,
  CONSTRAINT CHK_correo_proveedor CHECK (correo LIKE '%_@_%._%'),
  CONSTRAINT PK_CORREO_PROVEEDOR PRIMARY KEY (correo, id_proveedor),
  CONSTRAINT FK_CORREO_PROVEEDOR_PROVEEDOR FOREIGN KEY (id_proveedor) REFERENCES Proveedor(id_proveedor)
    ON DELETE CASCADE ON UPDATE NO ACTION
);
GO
