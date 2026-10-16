# Etapa 3 - Restricciones de integridad

Equipo 31 - La Frecuencia

Este documento lista todas las restricciones que definimos en `sql/ddl/crear_bd.sql` y explica para qué sirve cada una. La idea es que la base rechace por sí sola los datos incorrectos y que no se pierda el historial de compras y de ingresos.

## 1. Claves primarias (17)

Cada tabla tiene una clave primaria. En las tablas con `IDENTITY` el motor genera el número solo.

| Tabla | Clave primaria | Tipo |
| --- | --- | --- |
| `Usuario` | `id_usuario` | IDENTITY |
| `Metodo_pago` | `id_metodo` | IDENTITY |
| `genero` | `id_genero` | IDENTITY |
| `Vinilo` | `id_vinilo` | IDENTITY |
| `color` | `id_color` | IDENTITY |
| `provincia` | `id_provincia` | IDENTITY |
| `ciudad` | `id_ciudad` | IDENTITY |
| `direccion` | `id_direccion` | IDENTITY |
| `Compra` | `id_compra` | IDENTITY |
| `Proveedor` | `id_proveedor` | IDENTITY |
| `Ingreso_vinilo` | `id_lote` | IDENTITY |
| `vinilo_personalizado` | `id_vinilo` | Es también FK a `Vinilo`: cada personalizado es un único vinilo (relación 1 a 1). |
| `Detalle_compra` | `id_compra`, `id_vinilo` | Compuesta: un vinilo aparece una sola vez por compra. |
| `detalle_de_ingreso` | `id_lote`, `id_vinilo` | Compuesta: un vinilo aparece una sola vez por lote. |
| `genero_multiple` | `id_vinilo`, `id_genero` | Compuesta: no se repite un género para el mismo vinilo. |
| `numero_proveedor` | `codigo_area`, `numero_proveedor`, `id_proveedor` | Compuesta: un proveedor puede tener varios teléfonos. |
| `correo_proveedor` | `correo`, `id_proveedor` | Compuesta: un proveedor puede tener varios correos. |

## 2. Claves foráneas y reglas de borrado (17)

Todas las claves foráneas llevan `ON UPDATE NO ACTION`, porque las claves son números generados por la base y nunca se modifican.

Para el borrado usamos dos reglas:

- **NO ACTION** (13 claves): no deja borrar un registro si hay otros que dependen de él. La usamos en todo lo que es historial, porque la RN.06 pide guardar de forma permanente las facturas de venta y los comprobantes de ingreso.
- **CASCADE** (4 claves): al borrar el registro padre se borran también los hijos. La usamos solo cuando el dato hijo no tiene sentido sin su padre.

| Restricción | Tabla.columna | Referencia | ON DELETE | Motivo |
| --- | --- | --- | --- | --- |
| `FK_VINILO_GENERO` | `Vinilo.id_genero` | `genero` | NO ACTION | No se puede borrar un género que tiene vinilos. |
| `FK_CIUDAD_PROVINCIA` | `ciudad.id_provincia` | `provincia` | NO ACTION | No se puede borrar una provincia que tiene ciudades. |
| `FK_ID_DIRECCION` | `direccion.id_ciudad` | `ciudad` | NO ACTION | No se puede borrar una ciudad que tiene direcciones. |
| `FK_ID_COMPRA_USUARIO` | `Compra.id_usuario` | `Usuario` | NO ACTION | No se puede borrar un usuario que tiene compras (RN.06). |
| `FK_ID_COMPRA_METODO` | `Compra.id_metodo` | `Metodo_pago` | NO ACTION | No se puede borrar un método de pago que se usó en compras. |
| `FK_ID_DETALLE_COMPRA_COMPRA` | `Detalle_compra.id_compra` | `Compra` | NO ACTION | Las facturas se conservan completas (RN.06). |
| `FK_ID_DETALLE_COMPRA_VINILO` | `Detalle_compra.id_vinilo` | `Vinilo` | NO ACTION | No se puede borrar un vinilo que ya se vendió. |
| `FK_VINILO_PERSONALIZADO_VINILO` | `vinilo_personalizado.id_vinilo` | `Vinilo` | CASCADE | La personalización no tiene sentido sin el vinilo. |
| `FK_VINILO_PERSONALIZADO_COLOR` | `vinilo_personalizado.id_color` | `color` | NO ACTION | No se puede borrar un color que está en uso. |
| `FK_GENERO_MULTIPLE_VINILO_PERSONALIZADO` | `genero_multiple.id_vinilo` | `vinilo_personalizado` | CASCADE | Los géneros de un personalizado se borran con él. |
| `FK_GENERO_MULTIPLE_GENERO` | `genero_multiple.id_genero` | `genero` | NO ACTION | No se puede borrar un género que está en uso. |
| `FK_PROVEEDOR_DIRECCION` | `Proveedor.id_direccion` | `direccion` | NO ACTION | No se puede borrar una dirección que usa un proveedor. |
| `FK_INGRESO_VINILO_PROVEEDOR` | `Ingreso_vinilo.id_proveedor` | `Proveedor` | NO ACTION | Los comprobantes de ingreso se conservan (RN.06). |
| `FK_DETALLE_DE_INGRESO_INGRESO` | `detalle_de_ingreso.id_lote` | `Ingreso_vinilo` | NO ACTION | Un lote se conserva completo (RN.06). |
| `FK_DETALLE_DE_INGRESO_VINILO` | `detalle_de_ingreso.id_vinilo` | `Vinilo` | NO ACTION | No se puede borrar un vinilo que tiene ingresos. |
| `FK_NUMERO_PROVEEDOR_PROVEEDOR` | `numero_proveedor.id_proveedor` | `Proveedor` | CASCADE | Los teléfonos no sirven sin el proveedor. |
| `FK_CORREO_PROVEEDOR_PROVEEDOR` | `correo_proveedor.id_proveedor` | `Proveedor` | CASCADE | Los correos no sirven sin el proveedor. |

Dos cosas para aclarar sobre el CASCADE:

- `genero_multiple` apunta a `vinilo_personalizado` y no a `Vinilo`. Así la base no permite cargar géneros adicionales para un vinilo normal, que según la RN.03 tiene un único género.
- Si se borra un vinilo personalizado, se borran en cadena su fila en `vinilo_personalizado` y sus géneros en `genero_multiple`. Pero si ese vinilo ya tiene ventas o ingresos, el borrado queda bloqueado por las claves con NO ACTION.

## 3. Restricciones UNIQUE (8)

| Restricción | Tabla | Columna(s) | Qué evita |
| --- | --- | --- | --- |
| `UQ_correo_usuario` | `Usuario` | `correo_usuario` | Dos cuentas con el mismo correo. |
| `UQ_nombre_metodo_pago` | `Metodo_pago` | `nombre_Metodo_pago` | Cargar dos veces el mismo método de pago. |
| `UQ_nombre_genero` | `genero` | `nombre_genero` | Géneros repetidos. |
| `UQ_nombre_color` | `color` | `nombre_color` | Colores repetidos. |
| `UQ_nombre_provincia` | `provincia` | `nombre_provincia` | Provincias repetidas. |
| `UQ_ciudad_provincia` | `ciudad` | `nombre_ciudad`, `id_provincia` | Que una provincia tenga dos ciudades con el mismo nombre. Se permite el mismo nombre en provincias distintas. |
| `UQ_nombre_proveedor` | `Proveedor` | `nombre_Proveedor` | Proveedores repetidos. |
| `UQ_comprobante_ingreso` | `Ingreso_vinilo` | `comprobante` | Cargar dos veces el mismo comprobante de ingreso (RN.06). |

## 4. Restricciones CHECK (13)

| Restricción | Tabla | Condición | Qué controla |
| --- | --- | --- | --- |
| `CHK_correo_usuario` | `Usuario` | `correo_usuario LIKE '%_@_%._%'` | Que el correo tenga formato de correo: algo, arroba, algo, punto y algo. Es una validación básica. |
| `CHK_stock` | `Vinilo` | `stock_actual >= 0 AND stock_minimo >= 0` | Que el stock no sea negativo (RN.05). |
| `CHK_tipo_vinilo` | `Vinilo` | `tipo_vinilo IN ('Normal', 'Personalizado')` | Que el tipo sea uno de los dos valores válidos. |
| `CHK_genero_segun_tipo` | `Vinilo` | `(tipo_vinilo = 'Normal' AND id_genero IS NOT NULL) OR (tipo_vinilo = 'Personalizado' AND id_genero IS NULL)` | Que el vinilo normal tenga su género y que el personalizado no lo tenga acá (sus géneros están en `genero_multiple`). Aplica la RN.03. |
| `CHK_altura_direccion` | `direccion` | `altura_direccion IS NULL OR altura_direccion > 0` | Que la altura, si se carga, sea positiva. Puede quedar vacía. |
| `CHK_estado_compra` | `Compra` | `estado_de_compra IN ('pendiente', 'realizado', 'cancelado')` | Que el estado sea uno de los tres válidos. |
| `CHK_cantidad_compra` | `Detalle_compra` | `cantidad > 0` | Que no se compren cero unidades ni unidades negativas. |
| `CHK_precio_compra` | `Detalle_compra` | `precio_unidad >= 0` | Que el precio no sea negativo. |
| `CHK_cantidad_ingreso` | `detalle_de_ingreso` | `cantidad > 0` | Lo mismo para la mercadería que ingresa. |
| `CHK_precio_ingreso` | `detalle_de_ingreso` | `precio_unitario >= 0` | Que el precio de costo no sea negativo. |
| `CHK_codigo_area` | `numero_proveedor` | `codigo_area > 0` | Que el código de área sea un número positivo. |
| `CHK_numero_proveedor` | `numero_proveedor` | `numero_proveedor > 0` | Que el número de teléfono sea positivo. |
| `CHK_correo_proveedor` | `correo_proveedor` | `correo LIKE '%_@_%._%'` | Mismo control de formato que en `Usuario`. |

## 5. NOT NULL, DEFAULT e IDENTITY

- **NOT NULL:** todas las columnas son obligatorias, salvo cinco que aceptan `NULL` por una razón concreta:
    - `Vinilo.id_genero`: es `NULL` en los vinilos personalizados, porque sus géneros están en `genero_multiple`.
    - `direccion.altura_direccion`, `direccion.piso_direccion` y `direccion.departamento_direccion`: no todas las direcciones tienen altura, piso o departamento.
    - `vinilo_personalizado.descripcion_vinilo_personalizado`: la descripción es opcional.
- **DEFAULT:** `Vinilo.tipo_vinilo` vale `'Normal'` si no se indica otro valor.
- **IDENTITY(1,1):** lo usan las 11 claves primarias simples (las de las tablas `Usuario`, `Metodo_pago`, `genero`, `Vinilo`, `color`, `provincia`, `ciudad`, `direccion`, `Compra`, `Proveedor` e `Ingreso_vinilo`).

## 6. Cómo se relacionan con las reglas de negocio

| Regla | Cómo se aplica en la base |
| --- | --- |
| RN.01 Registro obligatorio | `Compra.id_usuario` es obligatorio y es FK a `Usuario`: no puede existir una compra sin un usuario registrado. El inicio de sesión lo controla la aplicación, no la base. |
| RN.02 Abastecimiento múltiple | Cada lote (`Ingreso_vinilo`) pertenece a un proveedor y su detalle (`detalle_de_ingreso`) indica qué vinilos trajo. Así un vinilo puede venir de varios proveedores y un proveedor puede traer varios vinilos. |
| RN.03 Asignación de géneros | `Vinilo.id_genero` para el normal, `genero_multiple` para el personalizado y `CHK_genero_segun_tipo` para que se cumpla. |
| RN.04 Personalización por compra | `Vinilo.tipo_vinilo` y la tabla `vinilo_personalizado` con su descripción y color. |
| RN.05 Disponibilidad de stock | `CHK_stock` impide el stock negativo. La compra queda `pendiente` hasta confirmarse (ver el punto 7). |
| RN.06 Trazabilidad | Reglas NO ACTION en las FK del historial y `UQ_comprobante_ingreso`. |
| Precio histórico | `Detalle_compra.precio_unidad` guarda el precio al momento de la venta y no cambia aunque cambie el precio del vinilo. |
| Métodos de pago | Tabla `Metodo_pago` con nombre único. |

## 7. Lo que no se resuelve con restricciones

Hay reglas que las restricciones declarativas no pueden garantizar. Las dejamos para la Etapa 5 (procedimientos, transacciones, triggers y seguridad):

- **Descontar el stock al confirmar una compra.** Hoy se hace con un UPDATE manual (está en el script de datos de prueba). Lo correcto es hacerlo en una transacción, de modo que la confirmación de la compra y el descuento de stock se hagan juntos o no se haga ninguno.
- **Reserva temporal de stock durante el pago** (RN.05).
- **Que todo vinilo personalizado tenga al menos un género** en `genero_multiple`. Con restricciones solo se puede controlar que un normal no tenga géneros extra.
- **Que las facturas y los precios guardados no se modifiquen** (RN.06). Se puede reforzar con permisos y con triggers de auditoría.
