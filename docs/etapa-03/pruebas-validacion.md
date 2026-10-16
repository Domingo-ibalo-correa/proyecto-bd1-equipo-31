# Etapa 3 - Pruebas de validación

Equipo 31 - La Frecuencia

Para comprobar que la base quedó bien armada hicimos cuatro tipos de pruebas: revisar los datos cargados, controlar que sean coherentes, intentar cargar datos incorrectos (que la base tiene que rechazar) y probar UPDATE y DELETE que sí tienen que funcionar.

Todas las sentencias están en `sql/dml/datos_prueba.sql`. Las pruebas que tienen que dar error están al final del script, comentadas: se descomentan de a una (en SSMS, seleccionar y usar Ctrl+K, Ctrl+U) y se ejecutan. Las capturas están en la carpeta `casos-de-prueba/`.

Antes de empezar se corre `crear_bd.sql` y después `datos_prueba.sql` sobre una base vacía.

## 1. Registros cargados

Después de los INSERT contamos los registros de cada tabla con la consulta que está en el script:

```sql
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
UNION ALL SELECT 'genero_multiple', COUNT(*) FROM genero_multiple
UNION ALL SELECT 'Proveedor', COUNT(*) FROM Proveedor
UNION ALL SELECT 'Ingreso_vinilo', COUNT(*) FROM Ingreso_vinilo
UNION ALL SELECT 'detalle_de_ingreso', COUNT(*) FROM detalle_de_ingreso
UNION ALL SELECT 'numero_proveedor', COUNT(*) FROM numero_proveedor
UNION ALL SELECT 'correo_proveedor', COUNT(*) FROM correo_proveedor;
```

Resultado esperado: 10 usuarios, 8 métodos de pago, 18 vinilos, 10 géneros, 10 colores, 10 provincias, 10 ciudades, 10 direcciones, 12 compras, 26 renglones de compra, 8 vinilos personalizados, 16 filas en `genero_multiple`, 10 proveedores, 10 ingresos, 32 renglones de ingreso, 12 teléfonos y 12 correos. Todas las tablas tienen 8 registros o más.

Captura: `casos-de-prueba/01-registros-por-tabla.png`

## 2. Coherencia de los datos

Además de que haya datos, controlamos que sean coherentes entre sí.

### 2.1 El stock coincide con ingresos menos ventas

El `stock_actual` de cada vinilo tiene que ser igual a lo que ingresó menos lo vendido en compras `realizado`. Esta consulta muestra los vinilos donde no coincide:

```sql
;WITH stock AS (
    SELECT v.id_vinilo, v.titulo_Vinilo, v.stock_actual,
           ISNULL((SELECT SUM(d.cantidad)
                   FROM detalle_de_ingreso d
                   WHERE d.id_vinilo = v.id_vinilo), 0)
         - ISNULL((SELECT SUM(dc.cantidad)
                   FROM Detalle_compra dc
                   JOIN Compra c ON c.id_compra = dc.id_compra
                   WHERE dc.id_vinilo = v.id_vinilo
                     AND c.estado_de_compra = 'realizado'), 0) AS stock_calculado
    FROM Vinilo v
)
SELECT * FROM stock WHERE stock_actual <> stock_calculado;
```

Resultado esperado: 0 filas. Si se quita la última línea del WHERE se ven los 18 vinilos con las dos columnas iguales. Hay que correrla con el script recién cargado (antes de los UPDATE de confirmación de la compra 11) o después de ellos, y en los dos casos tiene que dar 0 filas, porque la compra pendiente no descuenta stock hasta que se confirma y el UPDATE confirma la compra y descuenta el stock a la vez.

### 2.2 Vinilos con stock por debajo del mínimo

```sql
SELECT id_vinilo, artista_Vinilo, titulo_Vinilo, stock_actual, stock_minimo
FROM Vinilo
WHERE stock_actual < stock_minimo;
```

Resultado esperado: 3 filas.

| id_vinilo | artista_Vinilo | titulo_Vinilo | stock_actual | stock_minimo |
| --- | --- | --- | --- | --- |
| 3 | Luis Alberto Spinetta | Artaud | 4 | 5 |
| 4 | Mercedes Sosa | Gracias a la vida | 7 | 8 |
| 5 | Astor Piazzolla | Libertango | 5 | 6 |

### 2.3 El precio queda guardado en cada compra

Pink Floyd (vinilo 7) se vendió en tres fechas, y el precio de octubre es distinto al de agosto y septiembre:

```sql
SELECT c.fecha_compra, dc.precio_unidad
FROM Detalle_compra dc
JOIN Compra c ON c.id_compra = dc.id_compra
WHERE dc.id_vinilo = 7
ORDER BY c.fecha_compra;
```

Resultado esperado: 3 filas, con precios 39900.00 (2026-08-12), 39900.00 (2026-09-05) y 43100.00 (2026-10-03). Muestra que el precio de una venta anterior no cambió cuando el vinilo pasó a venderse más caro.

### 2.4 Géneros de los vinilos

Todos los vinilos normales tienen un género:

```sql
SELECT COUNT(*) AS normales_sin_genero
FROM Vinilo
WHERE tipo_vinilo = 'Normal' AND id_genero IS NULL;
```

Resultado esperado: 0.

Y cada vinilo personalizado tiene sus géneros en `genero_multiple`:

```sql
SELECT v.id_vinilo, v.titulo_Vinilo, COUNT(gm.id_genero) AS cantidad_generos
FROM Vinilo v
LEFT JOIN genero_multiple gm ON gm.id_vinilo = v.id_vinilo
WHERE v.tipo_vinilo = 'Personalizado'
GROUP BY v.id_vinilo, v.titulo_Vinilo;
```

Resultado esperado: 8 filas (los vinilos 11 a 18). Cada uno tiene 2 géneros, salvo el vinilo 14, que queda con 1 después del DELETE del punto 4.2 (antes de ese DELETE también tiene 2).

Captura de las pruebas de este punto: `casos-de-prueba/02-coherencia-de-datos.png`

## 3. Pruebas de restricciones (tienen que dar error)

En cada prueba la base tiene que rechazar la sentencia y mostrar un error. El texto exacto del mensaje depende del idioma del servidor. Lo que tiene que aparecer es el número de error (547 para CHECK y claves foráneas, 2627 para UNIQUE y claves primarias) y el nombre de la restricción.

Estas pruebas se dejan para el final porque un INSERT que falla igual consume un número del IDENTITY, y los datos de prueba usan esos números.

### 3.1 Datos incorrectos al cargar

**1. Correo repetido** (UNIQUE)

```sql
INSERT INTO Usuario (nombre_usuario, correo_usuario, contraseña_usuario) VALUES ('otro', 'lucia.gomez@example.com', 'clave1234');
```

Error esperado: Msg 2627, `UQ_correo_usuario`.

**2. Correo con formato inválido** (CHECK)

```sql
INSERT INTO Usuario (nombre_usuario, correo_usuario, contraseña_usuario) VALUES ('otro', 'correo-sin-arroba', 'clave1234');
```

Error esperado: Msg 547, `CHK_correo_usuario`.

**3. Stock negativo** (CHECK)

```sql
INSERT INTO Vinilo (artista_Vinilo, stock_minimo, stock_actual, titulo_Vinilo, id_genero) VALUES ('X', 1, -5, 'Y', 1);
```

Error esperado: Msg 547, `CHK_stock`.

**4. Tipo de vinilo inválido** (CHECK)

```sql
INSERT INTO Vinilo (artista_Vinilo, stock_minimo, stock_actual, titulo_Vinilo, tipo_vinilo, id_genero) VALUES ('X', 1, 1, 'Y', 'Raro', 1);
```

Error esperado: Msg 547, `CHK_tipo_vinilo` (también incumple `CHK_genero_segun_tipo`; el motor informa una de las dos).

**5. Vinilo con un género que no existe** (FK)

```sql
INSERT INTO Vinilo (artista_Vinilo, stock_minimo, stock_actual, titulo_Vinilo, id_genero) VALUES ('X', 1, 1, 'Y', 99);
```

Error esperado: Msg 547, `FK_VINILO_GENERO`.

**6. Vinilo normal sin género** (CHECK)

```sql
INSERT INTO Vinilo (artista_Vinilo, stock_minimo, stock_actual, titulo_Vinilo) VALUES ('X', 1, 1, 'Y');
```

Error esperado: Msg 547, `CHK_genero_segun_tipo`.

**7. Vinilo personalizado con género en `Vinilo`** (CHECK)

```sql
INSERT INTO Vinilo (artista_Vinilo, stock_minimo, stock_actual, titulo_Vinilo, tipo_vinilo, id_genero) VALUES ('X', 1, 1, 'Y', 'Personalizado', 1);
```

Error esperado: Msg 547, `CHK_genero_segun_tipo`.

**8. Géneros extra para un vinilo normal** (FK)

```sql
INSERT INTO genero_multiple (id_vinilo, id_genero) VALUES (1, 2);
```

Error esperado: Msg 547, `FK_GENERO_MULTIPLE_VINILO_PERSONALIZADO`.

**9. Género repetido para el mismo vinilo** (PRIMARY KEY)

```sql
INSERT INTO genero_multiple (id_vinilo, id_genero) VALUES (11, 1);
```

Error esperado: Msg 2627, `PK_GENERO_MULTIPLE`.

**10. Estado de compra inválido** (CHECK)

```sql
INSERT INTO Compra (estado_de_compra, fecha_compra, id_usuario, id_metodo) VALUES ('enviado', '2026-10-15', 1, 1);
```

Error esperado: Msg 547, `CHK_estado_compra`.

**11. Cantidad igual a 0** (CHECK)

```sql
INSERT INTO Detalle_compra (precio_unidad, cantidad, id_compra, id_vinilo) VALUES (1000, 0, 12, 1);
```

Error esperado: Msg 547, `CHK_cantidad_compra`.

**12. Compra de un usuario que no existe** (FK)

```sql
INSERT INTO Compra (estado_de_compra, fecha_compra, id_usuario, id_metodo) VALUES ('pendiente', '2026-10-15', 99, 1);
```

Error esperado: Msg 547, `FK_ID_COMPRA_USUARIO`.

Captura: `casos-de-prueba/03-errores-de-carga.png` (se pueden ejecutar las doce juntas y sacar una sola captura de la pestaña de mensajes).

### 3.2 Borrados que la base no permite

Estas sentencias tienen que fallar por las reglas NO ACTION. Muestran que no se puede perder el historial de compras ni de ingresos.

**13. Borrar un usuario que tiene compras** (FK (NO ACTION))

```sql
DELETE FROM Usuario WHERE id_usuario = 1;
```

Error esperado: Msg 547, `FK_ID_COMPRA_USUARIO`.

**14. Borrar un vinilo que tiene ventas e ingresos** (FK (NO ACTION))

```sql
DELETE FROM Vinilo WHERE id_vinilo = 1;
```

Error esperado: Msg 547, una de las FK que apuntan a `Vinilo` (por ejemplo `FK_ID_DETALLE_COMPRA_VINILO`).

**15. Borrar un género que está en uso** (FK (NO ACTION))

```sql
DELETE FROM genero WHERE id_genero = 1;
```

Error esperado: Msg 547, `FK_VINILO_GENERO` o `FK_GENERO_MULTIPLE_GENERO`.

Captura: `casos-de-prueba/04-errores-de-borrado.png`

## 4. Pruebas que tienen que funcionar

### 4.1 UPDATE

Cada UPDATE tiene su WHERE y modifica un único registro, así que en cada uno SSMS tiene que informar `(1 fila afectada)`.

| N° | Qué se hace | Sentencia |
| --- | --- | --- |
| 1 | Se corrige el nombre de un usuario. | `UPDATE Usuario SET nombre_usuario = 'sofia.ramirez' WHERE id_usuario = 3;` |
| 2 | Se corrige una altura de dirección. | `UPDATE direccion SET altura_direccion = 1125 WHERE id_direccion = 1;` |
| 3 | Se sube el stock mínimo de Pink Floyd. | `UPDATE Vinilo SET stock_minimo = 8 WHERE id_vinilo = 7;` |
| 4 | Se cambia el nombre de un método de pago. | `UPDATE Metodo_pago SET nombre_Metodo_pago = 'Mercado Pago QR' WHERE id_metodo = 5;` |
| 5 | Un cliente cambia el color de su vinilo personalizado. | `UPDATE vinilo_personalizado SET id_color = 5 WHERE id_vinilo = 12;` |
| 6 | Se confirma el pago de la compra 11 (estaba pendiente). | `UPDATE Compra SET estado_de_compra = 'realizado' WHERE id_compra = 11;` |
| 7 | Se descuenta el stock del vinilo 2 de esa compra. | `UPDATE Vinilo SET stock_actual = stock_actual - 1 WHERE id_vinilo = 2;` |
| 8 | Se descuenta el stock del vinilo 17 de esa compra. | `UPDATE Vinilo SET stock_actual = stock_actual - 1 WHERE id_vinilo = 17;` |

Para comprobar los dos últimos puntos (confirmación de la compra y descuento de stock):

```sql
SELECT id_compra, estado_de_compra FROM Compra WHERE id_compra = 11;
SELECT id_vinilo, titulo_Vinilo, stock_actual FROM Vinilo WHERE id_vinilo IN (2, 17);
```

Resultado esperado: la compra 11 pasa de `pendiente` a `realizado`, el stock del vinilo 2 (Dynamo) baja de 26 a 25 y el del vinilo 17 (Libertango personalizado) baja de 3 a 2.

Captura: `casos-de-prueba/05-updates.png`

### 4.2 DELETE

Hay seis DELETE en el script, todos con su WHERE y sobre registros que nadie usa, y cada uno informa `(1 fila afectada)`:

1. Se borra la provincia 'Santa Cruz', cargada solo para esta prueba.
2. Se borra el color 'Dorado', cargado solo para esta prueba.
3. Se borra el género Blues del vinilo personalizado 14 (el cliente se lo saca): `DELETE FROM genero_multiple WHERE id_vinilo = 14 AND id_genero = 4;`
4. Se borra un teléfono de un proveedor: `DELETE FROM numero_proveedor WHERE codigo_area = 379 AND numero_proveedor = 4456121 AND id_proveedor = 1;`
5. Se borra un proveedor de prueba (id 11).
6. Se borra la dirección de prueba (id 11).

La prueba 5 sirve para comprobar el `ON DELETE CASCADE`. Ese proveedor se carga con un teléfono y un correo, y al borrarlo tienen que borrarse solos. Se verifica antes y después del DELETE:

```sql
SELECT COUNT(*) AS telefonos FROM numero_proveedor WHERE id_proveedor = 11;
SELECT COUNT(*) AS correos FROM correo_proveedor WHERE id_proveedor = 11;
```

Resultado esperado: antes del DELETE da 1 y 1, y después da 0 y 0, aunque nunca borramos esos teléfonos y correos a mano.

Captura: `casos-de-prueba/06-deletes-y-cascade.png`

## 5. Conclusión

Con estas pruebas comprobamos que los datos de prueba cargan completos y son coherentes, que las restricciones `UNIQUE`, `CHECK` y las claves primarias y foráneas rechazan los datos incorrectos, que las reglas de borrado protegen el historial de compras y de ingresos, y que el borrado en cascada funciona solo donde lo definimos.
