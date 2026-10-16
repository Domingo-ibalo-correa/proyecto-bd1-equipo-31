IF DB_ID('proyecto_grupo31_secuela') IS NULL
    CREATE DATABASE proyecto_grupo31_secuela;
GO

use proyecto_grupo31_secuela
GO
---------------------tablas padre-------------------------------------
--tabla usuario--
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
CREATE TABLE Metodo_pago(
  id_metodo INT IDENTITY (1,1) NOT NULL,
  nombre_Metodo_pago VARCHAR(50) NOT NULL,
  CONSTRAINT UQ_nombre_metodo_pago UNIQUE (nombre_Metodo_pago),
  CONSTRAINT PK_ID_METODO PRIMARY KEY (id_metodo)
);

--tabla vinilo--
CREATE TABLE Vinilo
(
  id_vinilo INT IDENTITY (1,1) NOT NULL,
  artista_Vinilo VARCHAR(50) NOT NULL,
  stock_minimo INT NOT NULL,
  stock_actual INT NOT NULL,
  titulo_Vinilo VARCHAR(100) NOT NULL,
  tipo_vinilo VARCHAR(20) DEFAULT 'Normal' NOT NULL,
  CONSTRAINT CHK_stock CHECK (stock_actual >= 0 AND stock_minimo >= 0),
  CONSTRAINT CHK_tipo_vinilo CHECK (tipo_vinilo IN ('Normal', 'Personalizado')),
  CONSTRAINT PK_ID_VINILO PRIMARY KEY (id_vinilo)
);

--tabla genero--
CREATE TABLE genero
(
  id_genero INT IDENTITY (1,1) NOT NULL,
  nombre_genero VARCHAR (50) NOT NULL,
  CONSTRAINT UQ_nombre_genero UNIQUE (nombre_genero),
  CONSTRAINT PK_ID_GENERO PRIMARY KEY (id_genero)
);

--tabla color--
CREATE TABLE color
(
  id_color INT IDENTITY (1,1) NOT NULL,
  nombre_color VARCHAR(50) NOT NULL,
  CONSTRAINT UQ_nombre_color UNIQUE (nombre_color),
  CONSTRAINT PK_ID_COLOR PRIMARY KEY (id_color)
);

--tabla provincia--
CREATE TABLE provincia
(
  id_provincia INT IDENTITY (1,1) NOT NULL,
  nombre_provincia VARCHAR(50) NOT NULL,
  CONSTRAINT UQ_nombre_provincia UNIQUE (nombre_provincia),
  CONSTRAINT PK_ID_PROVINCIA PRIMARY KEY (id_provincia)
);

---------------------tablas hijas-------------------------------------
------tabla ciudad -------
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
CREATE TABLE vinilo_personalizado
(
  id_vinilo INT NOT NULL,
  descripcion_vinilo_personalizado VARCHAR(100) NULL,
  id_genero INT NOT NULL,
  id_color INT NOT NULL,
  CONSTRAINT PK_VINILO_PERSONALIZADO PRIMARY KEY (id_vinilo),
  CONSTRAINT FK_VINILO_PERSONALIZADO_VINILO FOREIGN KEY (id_vinilo) REFERENCES Vinilo(id_vinilo)
    ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT FK_VINILO_PERSONALIZADO_GENERO FOREIGN KEY (id_genero) REFERENCES genero(id_genero)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT FK_VINILO_PERSONALIZADO_COLOR FOREIGN KEY (id_color) REFERENCES color(id_color)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);
------tabla proveedor -------
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