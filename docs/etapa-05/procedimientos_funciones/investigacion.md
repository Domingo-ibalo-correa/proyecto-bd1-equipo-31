# Procedimientos y funciones almacenadas

Equipo 31 - La Frecuencia

Script: [scripts.sql](scripts.sql) (se ejecuta completo, después de `crear_bd.sql` y `datos_prueba.sql`)
Evidencias: carpeta [evidencias/](evidencias)

## 1. Definición y objetivo

Un procedimiento almacenado es un conjunto de instrucciones SQL que se guarda dentro de la base de datos y se ejecuta con un nombre (`EXEC`). Puede recibir parámetros, hacer varias operaciones y devolver valores. Una función también recibe parámetros pero devuelve un valor (escalar) o una tabla, y se puede usar adentro de un `SELECT`.

El objetivo es dejar la lógica del negocio en la base, en un solo lugar, en vez de repetirla en cada consulta.

## 2. Ventajas y aplicaciones

- Se reutiliza la lógica: la regla de descuentos se escribe una vez y se usa en todos lados.
- Menos código repetido y más fácil de mantener, porque si cambia una regla se modifica en un solo lugar.
- Se puede dar permiso para ejecutar el procedimiento sin dar acceso directo a las tablas (lo usamos en la parte de seguridad).
- Registrar una venta toca varias tablas, y con un procedimiento se hace con una sola llamada.

## 3. Implementación en SQL Server Express

Usamos `CREATE OR ALTER FUNCTION` y `CREATE OR ALTER PROCEDURE`, que crean el objeto o lo reemplazan si ya existe (necesita SQL Server 2016 SP1 o más nuevo, y Express lo tiene). Para mandar varios vinilos en una venta usamos un tipo de tabla (`CREATE TYPE ... AS TABLE`) como parámetro del procedimiento.

## 4. Caso concreto en La Frecuencia

Funciones:

- `fn_TotalCompra(@id_compra)`: devuelve el total de una compra (suma de cantidad por precio de cada renglón). Es el mismo cálculo del comprobante de la Etapa 4.
- `fn_CalcularDescuentoCliente(@id_usuario)`: da el porcentaje de descuento según lo que el cliente compró en total (solo compras `realizado`). La guía propone 5% desde 200000 y 10% desde 500000, pero con nuestros datos de prueba casi ningún cliente llegaría, así que ajustamos los escalones: 150000 o más, 5%; 300000 o más, 10%; menos de eso, 0%.
- `fn_VinilosAReponer()`: devuelve una tabla con los vinilos que están por debajo del stock mínimo y cuántos faltan.

Procedimiento `sp_RegistrarVentaCompleta`. Recibe el cliente, el método de pago y los vinilos con su cantidad y precio, y en una sola transacción:

1. controla que existan el usuario y los vinilos y que haya stock de todo;
2. crea la compra en estado `realizado`;
3. crea los renglones guardando el precio histórico con el descuento del cliente aplicado (queda el precio que realmente se cobró, como pide la RN.06);
4. descuenta el stock;
5. si algo falla hace `ROLLBACK` y devuelve el error.

El precio lo manda quien llama porque nuestra tabla `Vinilo` no guarda un precio de lista, el precio se guarda en cada venta.

## 5. Demostración y resultados

Con los datos originales:

- `fn_TotalCompra(1)` devuelve 71100.00 (la compra 1 tiene dos vinilos de 31200 y 39900).
- Descuentos: martin.fernandez (id 2) tiene 309900 acumulados, así que le toca 10%. lucia.gomez (id 1) tiene 151700, le toca 5%. Todos los demás dan 0%.
- `fn_VinilosAReponer()` devuelve Artaud, Gracias a la vida y Libertango, con 1 unidad faltante cada uno (son los mismos 3 vinilos de la Etapa 3 y de la Etapa 4).

Procedimiento, prueba 1: venta correcta de martin.fernandez con 10% de descuento.

| titulo | cantidad | precio_unidad | subtotal |
| --- | --- | --- | --- |
| Clics Modernos | 2 | 28080.00 | 56160.00 |
| Dynamo | 1 | 29340.00 | 29340.00 |

Los precios son los que mandamos (31200 y 32600) menos el 10%. La compra queda `realizado` y el stock baja: Clics Modernos de 32 a 30 y Dynamo de 25 a 24. El número de la compra es el que siga en la tabla (un INSERT que falla también gasta un número del IDENTITY).

Prueba 2: venta con stock insuficiente. Se piden 10 unidades de Artaud y hay 4. El procedimiento devuelve el error 50005 (`Stock insuficiente para completar la venta.`), el usuario 3 sigue con una sola compra y el stock de Artaud sigue en 4. No quedó nada registrado.

Estas pruebas modifican datos, así que conviene correr antes las consultas de la Etapa 4 si se quieren ver sus resultados originales.

## Evidencias

- `evidencias/01-funciones.png`: resultado de las tres funciones.
- `evidencias/02-venta-correcta.png`: prueba 1 del procedimiento.
- `evidencias/03-stock-insuficiente.png`: prueba 2 del procedimiento.
