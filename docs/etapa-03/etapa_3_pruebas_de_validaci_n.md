# Etapa 3 - Pruebas de validación

**Equipo 31 - La Frecuencia**

Para chequear que la base de datos haya quedado sólida y bien armada, armamos una batería de pruebas dividida en cuatro ejes: revisión de los registros iniciales, control de coherencia entre tablas, validación de restricciones (casos que la base tiene que rechazar obligatoriamente) y operaciones de modificación (`UPDATE` y `DELETE`) que sí tienen que pasar sin problemas.

Todas las sentencias están armadas dentro de `sql/dml/datos_prueba.sql`. Las pruebas que provocan errores intencionales están ubicadas al final del script y se encuentran comentadas: la idea es descomentarlas de a una en SQL Server Management Studio (seleccionando el bloque y usando el atajo `Ctrl+K`, `Ctrl+U`) para ir probándolas. Las capturas correspondientes de cada caso están guardadas en la carpeta `casos-de-prueba/`.

Como paso previo, recordamos que hay que ejecutar primero `crear_bd.sql` y enseguida `datos_prueba.sql` sobre una instancia de base de datos totalmente vacía.

---

## 1. Registros cargados

Una vez ejecutados los `INSERT`, corrimos la siguiente consulta para verificar que los volúmenes de datos en cada tabla sean los esperados:

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

**Resultado esperado:** 
* 10 usuarios
* 8 métodos de pago
* 18 vinilos
* 10 géneros
* 10 colores
* 10 provincias
* 10 ciudades
* 10 direcciones
* 12 compras
* 26 renglones de detalle de compra
* 8 vinilos personalizados
* 16 filas en `genero_multiple`
* 10 proveedores
* 10 ingresos
* 32 renglones de detalle de ingreso
* 12 teléfonos de proveedores
* 12 correos de proveedores

Como regla general, garantizamos que todas las tablas tengan un piso mínimo de 8 registros para que la base no quede desinflada.

**Evidencia:** `casos-de-prueba/01-registros-por-tabla.png`

---

## 2. Coherencia de los datos

Más allá de contar registros, nos tomamos el trabajo de cruzar información para asegurar que los datos guarden lógica entre sí.

### 2.1 Balance de stock (Ingresos menos Ventas)
El campo `stock_actual` de cada vinilo tiene que dar exactamente igual a la suma de lo que ingresó menos lo que se vendió en compras con estado `realizado`. Con este CTE detectamos si hay descalces:

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

**Resultado esperado:** 0 filas devueltas. Si le sacamos el filtro del `WHERE`, podemos ver los 18 vinilos con las dos columnas perfectamente emparejadas. Esto se puede correr ni bien se cargan los datos (antes de tocar la compra 11) o después de actualizarla; en ambos escenarios da cero diferencias porque las compras pendientes no descuentan stock hasta que se confirman formalmente.

### 2.2 Vinilos por debajo del stock mínimo
Validamos cuáles son los títulos que tocaron fondo y necesitan reposición urgente:

```sql
SELECT id_vinilo, artista_Vinilo, titulo_Vinilo, stock_actual, stock_minimo
FROM Vinilo
WHERE stock_actual < stock_minimo;
```

**Resultado esperado:** Exactamente 3 filas.

| id_vinilo | artista_Vinilo | titulo_Vinilo | stock_actual | stock_minimo |
| :--- | :--- | :--- | :---: | :---: |
| 3 | Luis Alberto Spinetta | Artaud | 4 | 5 |
| 4 | Mercedes Sosa | Gracias a la vida | 7 | 8 |
| 5 | Astor Piazzolla | Libertango | 5 | 6 |

### 2.3 Persistencia histórica del precio por compra
Queríamos chequear que si un disco sube de precio, las ventas viejas no se alteran. Tomamos a Pink Floyd (vinilo ID 7), que se vendió en tres momentos distintos:

```sql
SELECT c.fecha_compra, dc.precio_unidad
FROM Detalle_compra dc
JOIN Compra c ON c.id_compra = dc.id_compra
WHERE dc.id_vinilo = 7
ORDER BY c.fecha_compra;
```

**Resultado esperado:** 3 registros con sus respectivos valores: 39900.00 (12/08/2026), 39900.00 (05/09/2026) y 43100.00 (03/10/2026). Esto demuestra que la modificación posterior en la lista de precios no afectó los tickets ya emitidos.

### 2.4 Consistencia en géneros de vinilos
Por un lado, chequear que ningún vinilo de catálogo normal se quede sin género asignado:

```sql
SELECT COUNT(*) AS normales_sin_genero
FROM Vinilo
WHERE tipo_vinilo = 'Normal' AND id_genero IS NULL;
```
*(Resultado esperado: 0)*

Por el otro, asegurarnos de que los vinilos personalizados manejen su multiselección en la tabla `genero_multiple`:

```sql
SELECT v.id_vinilo, v.titulo_Vinilo, COUNT(gm.id_genero) AS cantidad_generos
FROM Vinilo v
LEFT JOIN genero_multiple gm ON gm.id_vinilo = v.id_vinilo
WHERE v.tipo_vinilo = 'Personalizado'
GROUP BY v.id_vinilo, v.titulo_Vinilo;
```
*(Resultado esperado: 8 filas correspondientes a los vinilos 11 al 18. Tienen 2 géneros cada uno, salvo el vinilo 14, que baja a 1 luego de probar un borrado en el punto 4.2).*

**Evidencia:** `casos-de-prueba/02-coherencia-de-datos.png`

---

## 3. Pruebas de restricciones (Casos con error esperado)

Para estas pruebas buscamos que SQL Server rechace de inmediato las sentencias mostrando los códigos de error correspondientes (como el `547` para restricciones `CHECK` y claves foráneas, o el `2627` para duplicados en `UNIQUE` y claves primarias). 

Dejamos este bloque al final del uso cotidiano porque un `INSERT` fallido igual quema un número de secuencia `IDENTITY`, y los scripts de prueba dependen de esos IDs exactos.

### 3.1 Inserciones con datos inválidos

1. **Correo duplicado (`UNIQUE`):**
   ```sql
   INSERT INTO Usuario (nombre_usuario, correo_usuario, contraseña_usuario) VALUES ('otro', 'lucia.gomez@example.com', 'clave1234');
   ```
   *Error esperado:* Msg 2627, restricción `UQ_correo_usuario`.

2. **Correo mal formado (`CHECK`):**
   ```sql
   INSERT INTO Usuario (nombre_usuario, correo_usuario, contraseña_usuario) VALUES ('otro', 'correo-sin-arroba', 'clave1234');
   ```
   *Error esperado:* Msg 547, restricción `CHK_correo_usuario`.

3. **Stock en negativo (`CHECK`):**
   ```sql
   INSERT INTO Vinilo (artista_Vinilo, stock_minimo, stock_actual, titulo_Vinilo, id_genero) VALUES ('X', 1, -5, 'Y', 1);
   ```
   *Error esperado:* Msg 547, restricción `CHK_stock`.

4. **Tipo de vinilo inventado (`CHECK`):**
   ```sql
   INSERT INTO Vinilo (artista_Vinilo, stock_minimo, stock_actual, titulo_Vinilo, tipo_vinilo, id_genero) VALUES ('X', 1, 1, 'Y', 'Raro', 1);
   ```
   *Error esperado:* Msg 547, restricción `CHK_tipo_vinilo`.

5. **Vinilo con género inexistente (FK):**
   ```sql
   INSERT INTO Vinilo (artista_Vinilo, stock_minimo, stock_actual, titulo_Vinilo, id_genero) VALUES ('X', 1, 1, 'Y', 99);
   ```
   *Error esperado:* Msg 547, restricción `FK_VINILO_GENERO`.

6. **Vinilo normal omitiendo el género (`CHECK`):**
   ```sql
   INSERT INTO Vinilo (artista_Vinilo, stock_minimo, stock_actual, titulo_Vinilo) VALUES ('X', 1, 1, 'Y');
   ```
   *Error esperado:* Msg 547, restricción `CHK_genero_segun_tipo`.

7. **Vinilo personalizado queriendo meter género directo en la tabla principal (`CHECK`):**
   ```sql
   INSERT INTO Vinilo (artista_Vinilo, stock_minimo, stock_actual, titulo_Vinilo, tipo_vinilo, id_genero) VALUES ('X', 1, 1, 'Y', 'Personalizado', 1);
   ```
   *Error esperado:* Msg 547, restricción `CHK_genero_segun_tipo`.

8. **Asignar géneros múltiples a un vinilo que es normal (FK):**
   ```sql
   INSERT INTO genero_multiple (id_vinilo, id_genero) VALUES (1, 2);
   ```
   *Error esperado:* Msg 547, restricción `FK_GENERO_MULTIPLE_VINILO_PERSONALIZADO`.

9. **Repetir el mismo género en un vinilo personalizado (PK compuesta):**
   ```sql
   INSERT INTO genero_multiple (id_vinilo, id_genero) VALUES (11, 1);
   ```
   *Error esperado:* Msg 2627, restricción `PK_GENERO_MULTIPLE`.

10. **Estado de compra no contemplado (`CHECK`):**
    ```sql
    INSERT INTO Compra (estado_de_compra, fecha_compra, id_usuario, id_metodo) VALUES ('enviado', '2026-10-15', 1, 1);
    ```
    *Error esperado:* Msg 547, restricción `CHK_estado_compra`.

11. **Cantidad en cero en detalle de compra (`CHECK`):**
    ```sql
    INSERT INTO Detalle_compra (precio_unidad, cantidad, id_compra, id_vinilo) VALUES (1000, 0, 12, 1);
    ```
    *Error esperado:* Msg 547, restricción `CHK_cantidad_compra`.

12. **Compra vinculada a un usuario fantasma (FK):**
    ```sql
    INSERT INTO Compra (estado_de_compra, fecha_compra, id_usuario, id_metodo) VALUES ('pendiente', '2026-10-15', 99, 1);
    ```
    *Error esperado:* Msg 547, restricción `FK_ID_COMPRA_USUARIO`.

**Evidencia:** `casos-de-prueba/03-errores-de-carga.png` (se pueden tirar todas juntas y sacar una sola captura general de la solapa de mensajes).

### 3.2 Borrados bloqueados por reglas de integridad (`NO ACTION`)
Demuestran que el sistema protege celosamente el historial transaccional impidiendo borrar datos vitales.

13. **Borrar un usuario con compras activas:**
    ```sql
    DELETE FROM Usuario WHERE id_usuario = 1;
    ```
    *Error esperado:* Msg 547 (`FK_ID_COMPRA_USUARIO`).

14. **Borrar un vinilo que figura en ventas e ingresos:**
    ```sql
    DELETE FROM Vinilo WHERE id_vinilo = 1;
    ```
    *Error esperado:* Msg 547 (por ejemplo, `FK_ID_DETALLE_COMPRA_VINILO`).

15. **Borrar un género que está siendo utilizado:**
    ```sql
    DELETE FROM genero WHERE id_genero = 1;
    ```
    *Error esperado:* Msg 547 (`FK_VINILO_GENERO`).

**Evidencia:** `casos-de-prueba/04-errores-de-borrado.png`

---

## 4. Pruebas de operaciones exitosas

### 4.1 Actualizaciones (`UPDATE`)
Cada sentencia cuenta con su filtro por `id` para asegurar el impacto exacto de una sola línea (`(1 fila afectada)` en la consola):

| N° | Descripción de la acción | Sentencia SQL |
| :---: | :--- | :--- |
| 1 | Corregir el nombre de usuario | `UPDATE Usuario SET nombre_usuario = 'sofia.ramirez' WHERE id_usuario = 3;` |
| 2 | Ajustar la altura de una dirección | `UPDATE direccion SET altura_direccion = 1125 WHERE id_direccion = 1;` |
| 3 | Subir el stock mínimo del disco de Pink Floyd | `UPDATE Vinilo SET stock_minimo = 8 WHERE id_vinilo = 7;` |
| 4 | Renombrar un medio de pago | `UPDATE Metodo_pago SET nombre_Metodo_pago = 'Mercado Pago QR' WHERE id_metodo = 5;` |
| 5 | Cambiar el color de un vinilo personalizado | `UPDATE vinilo_personalizado SET id_color = 5 WHERE id_vinilo = 12;` |
| 6 | Confirmar el pago de la compra N° 11 (estaba pendiente) | `UPDATE Compra SET estado_de_compra = 'realizado' WHERE id_compra = 11;` |
| 7 | Descontar el stock del vinilo 2 asociado a esa compra | `UPDATE Vinilo SET stock_actual = stock_actual - 1 WHERE id_vinilo = 2;` |
| 8 | Descontar el stock del vinilo 17 asociado a esa compra | `UPDATE Vinilo SET stock_actual = stock_actual - 1 WHERE id_vinilo = 17;` |

Para chequear que la confirmación de la compra y el descuento de inventario hayan surtido efecto en simultáneo, corrimos:
```sql
SELECT id_compra, estado_de_compra FROM Compra WHERE id_compra = 11;
SELECT id_vinilo, titulo_Vinilo, stock_actual FROM Vinilo WHERE id_vinilo IN (2, 17);
```
*Resultado:* La compra pasa de `pendiente` a `realizado`, el vinilo 2 (*Dynamo*) baja de 26 a 25 de stock, y el vinilo 17 (*Libertango personalizado*) baja de 3 a 2.

**Evidencia:** `casos-de-prueba/05-updates.png`

### 4.2 Borrados limpios y en cascada (`DELETE`)
Ejecutamos seis borrados sobre registros auxiliares o huérfanos que no rompen ninguna regla de negocio:

1. Borrar la provincia 'Santa Cruz' (cargada exclusivamente para pruebas).
2. Borrar el color 'Dorado' (cargado solo para pruebas).
3. Quitarle el género Blues al vinilo personalizado 14:
   ```sql
   DELETE FROM genero_multiple WHERE id_vinilo = 14 AND id_genero = 4;
   ```
4. Borrar un número de teléfono suelto de un proveedor.
5. Borrar un proveedor de prueba (ID 11).
6. Borrar una dirección de prueba (ID 11).

La prueba N° 5 sirve puntualmente para certificar el funcionamiento de la regla `ON DELETE CASCADE`. Como el proveedor 11 fue ingresado junto a un teléfono y un correo electrónico, al eliminar el registro cabecera los datos secundarios se limpian solos. Lo validamos contando registros antes y después:

```sql
SELECT COUNT(*) AS telefonos FROM numero_proveedor WHERE id_proveedor = 11;
SELECT COUNT(*) AS correos FROM correo_proveedor WHERE id_proveedor = 11;
```
*Resultado:* Da 1 y 1 antes del borrado, y pasa a 0 y 0 automáticamente tras eliminar al proveedor, sin necesidad de comandos manuales adicionales.

**Evidencia:** `casos-de-prueba/06-deletes-y-cascade.png`

---

## 5. Conclusión general

Con esta batería de validaciones pudimos comprobar que el diseño de nuestra base de datos es robusto: los datos de prueba se cargan sin inconvenientes guardando coherencia interna, las restricciones técnicas (`UNIQUE`, `CHECK`, PK y FK) frenan de forma correcta cualquier intento de ingresar anomalías, los mecanismos de protección impiden borrar información sensible del negocio, y las acciones en cascada responden exactamente tal como lo planeamos en el modelo.