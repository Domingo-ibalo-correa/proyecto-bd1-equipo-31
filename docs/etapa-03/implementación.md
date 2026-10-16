# Etapa 3: Implementación

**Equipo 31 - La Frecuencia**

En este punto pasamos el modelo relacional que armamos en la Etapa 2 a SQL Server y le cargamos datos de prueba para ver que todo camine bien. La idea de este documento es contarles un poco cómo lo estructuramos. Si quieren ver las restricciones a fondo, están en `restricciones-integridad.md`, y las pruebas de que funciona las dejamos en `pruebas-validacion.md`.

---

## 1. El motor y los scripts

Trabajamos con **SQL Server** desde el SSMS (SQL Server Management Studio). La base la llamamos `proyecto_grupo31_secuela` y se levanta directamente con dos scripts que dejamos en la carpeta `sql/`:

*   `sql/ddl/crear_bd.sql`: Crea la base desde cero y levanta las 17 tablas con todas sus claves y restricciones.
*   `sql/dml/datos_prueba.sql`: Carga los datos de prueba. Además, le metimos adentro los `SELECT` de verificación, algunos `UPDATE` y `DELETE` de ejemplo, y las pruebas de restricciones (las dejamos comentadas para que no rompan).

> **Importante:** Hay que correrlos en ese orden estricto (primero el DDL y después el DML) sobre una base limpia. Si necesitan arrancar de nuevo por cualquier cosa, nosotros usábamos este bloque para tirar todo abajo y empezar de cero:
> 
> ```sql
> USE master;
> DROP DATABASE proyecto_grupo31_secuela;
> ```

Hacemos esto porque el DDL crea la base solo si no existe, y si ya está creada de antes te tira error porque las tablas ya existen. Como los `INSERT` del DML usan los `IDENTITY(1,1)` de forma correlativa, siempre conviene partir de una base vacía para que no se desacomoden los IDs.

---

## 2. Cómo pasamos del modelo relacional a las tablas

Básicamente, cada relación del modelo se convirtió en una tabla. Para evitar problemas con las claves foráneas, armamos el script ordenado de modo que primero se creen las tablas "padre" (como `usuario`, `metodo_pago`, `genero`, `vinilo`, `color`, `provincia`) y después las "hijas". Las 17 tablas terminaron agrupándose así:

*   **Ventas:** `Usuario`, `Metodo_pago`, `Compra`, `Detalle_compra`
*   **Catálogo:** `Vinilo`, `vinilo_personalizado`, `genero`, `genero_multiple`, `color`
*   **Abastecimiento:** `Proveedor`, `Ingreso_vinilo`, `detalle_de_ingreso`
*   **Ubicación y contacto del proveedor:** `provincia`, `ciudad`, `direccion`, `numero_proveedor`, `correo_proveedor`

### Sobre los tipos de datos que elegimos

*   Para las **claves primarias** tiramos de `INT IDENTITY(1,1)` para que el motor se encargue de numerarlas solo.
*   Textos comunes como nombres, títulos o correos van con `VARCHAR(50)` o `VARCHAR(100)`.
*   Para los **precios** usamos `DECIMAL(10,2)`. Al principio habíamos probado con `FLOAT`, pero redondeaba mal con los centavos y nos traía dolores de cabeza.
*   Las **fechas** de compra e ingreso van con `DATE` porque la hora exacta no nos importaba para este negocio.
*   Los teléfonos los separamos: el código de área va como `INT` y el número como `BIGINT`.
*   Para cosas como comprobantes (`VARCHAR(20)`) dejamos espacio por si llevan ceros adelante o guiones (tipo `0001-00004501`).
*   Los estados de compra y tipos de vinilo usan `VARCHAR` con restricciones `CHECK` para que no metan cualquier valor.

---

## 3. Ajustes respecto a la Etapa 2

Mientras pasábamos todo a código nos dimos cuenta de que podíamos afinar algunas cositas del modelo anterior:

1. **Direcciones:** En el modelo original la ciudad y la provincia eran texto suelto dentro de `direccion`. Las separamos en tres tablas (`provincia`, `ciudad`, `direccion`) para evitar repetir texto y cumplir con la 3FN (había una dependencia transitiva clara). Le sumamos también piso y depto por si acaso.
2. **Contactos de proveedores:** La vieja tabla `Contacto` era un poco cajón de sastre, así que la dividimos en `numero_proveedor` y `correo_proveedor`. Un proveedor puede tener varios teléfonos y mails independientes entre sí.
3. **Colores:** El color del vinilo personalizado se independizó en su propia tabla `color` para no tener problemas de tipeo ("Rojo", "rojo ", etc.).
4. **Vinilos normales vs personalizados:** No armamos una tabla `vinilo_original`. El tipo se maneja con una columna `Vinilo.tipo_vinilo` (`'Normal'` o `'Personalizado'`), y si es personalizado tira de la tabla `vinilo_personalizado` para guardar la descripción y el color.
5. **Géneros (RN.03):** El vinilo normal tiene un solo género directo en `Vinilo.id_genero`. El personalizado puede tener varios, así que esos van a la tabla `genero_multiple`. En esos casos, el `id_genero` principal queda en `NULL`.
6. **Subtotales:** El `subtotal` del detalle de compra no lo guardamos en la tabla porque se calcula al vuelo con `cantidad * precio_unidad`. Guardarlo era duplicar datos al coete.
7. **Clave de `Detalle_compra`:** Pasó a ser una clave compuesta (`id_compra`, `id_vinilo`), porque un mismo vinilo no se repite suelto en el mismo detalle (la cantidad se maneja con la columna `cantidad`).

---

## 4. ¿Por qué 17 tablas?

Quizás parezcan muchas (el promedio que suelen pedir ronda las 6 a 10), pero sale de normalizar bien el sistema. Las entidades principales son poquitas (usuarios, compras, vinilos, proveedores e ingresos de mercadería). El resto surge de aplicar 3FN y prolijidad: tablas maestras para no repetir texto (géneros, colores, métodos de pago, provincias), tablas para datos multivaluados (teléfonos, correos, géneros múltiples) y las tablas de detalle de compra e ingreso.

---

## 5. Los datos de prueba

Para poblar la base nos armamos un set donde cada tabla tiene entre 8 y 10 registros como mínimo (un poco más en los detalles). Quedó más o menos así:

| Tabla | Registros | Tabla | Registros |
| --- | --- | --- | --- |
| `Usuario` | 10 | `Compra` | 12 |
| `Metodo_pago` | 8 | `Detalle_compra` | 26 |
| `Vinilo` | 18 | `Proveedor` | 10 |
| `genero` | 10 | `Ingreso_vinilo` | 10 |
| `color` | 10 | `detalle_de_ingreso` | 32 |
| `provincia` | 10 | `numero_proveedor` | 12 |
| `ciudad` | 10 | `correo_proveedor` | 12 |
| `direccion` | 10 | `vinilo_personalizado` | 8 |
| | | `genero_multiple` | 16 |

### Criterios que usamos para armar los datos

*   Usamos datos ficticios (los correos terminan en `@example.com`).
*   Los vinilos del 1 al 10 son normales y del 11 al 18 son personalizados. Cada personalizado tiene dos géneros asignados.
*   El `stock_actual` de cada vinilo sale solo de hacer la cuenta de lo que ingresó por proveedor menos lo que se vendió en compras con estado `realizado`.
*   Armamos 12 compras de prueba: 10 realizadas, 1 pendiente y 1 cancelada, fechadas entre agosto y octubre de 2026. Ojo con la pendiente: esa no te descuenta stock hasta que no se confirma, cosa que probamos con los `UPDATE` del final del script (cumpliendo con la RN.05).
*   Dejamos tres vinilos con stock por debajo del mínimo para ver si saltaba bien el aviso.
*   El precio de venta queda grabado en el detalle de cada compra. Por eso, si un vinilo cambia de precio en el tiempo, las compras viejas no se rompen.
*   Hay casos de vinilos que ingresaron por más de un proveedor para validar la RN.02.

---

## 6. Validación

Todo lo que son consultas de control, pruebas de restricciones y los ejemplos de `UPDATE` / `DELETE` los dejamos explicados con sus respectivas capturas en `pruebas-validacion.md`. 

Si quieren chusmear el diagrama de cómo quedó armada la base, lo exportamos como `DiagramaDDL.png`.