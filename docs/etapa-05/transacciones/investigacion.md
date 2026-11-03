# Manejo de transacciones

Equipo 31 - La Frecuencia

Script: [scripts.sql](scripts.sql) (se ejecuta completo, después de `crear_bd.sql` y `datos_prueba.sql`)
Evidencias: carpeta [evidencias/](evidencias)

## 1. Definición y objetivo

Una transacción es un grupo de operaciones que se ejecutan como una sola unidad: o se hacen todas (`COMMIT`) o no se hace ninguna (`ROLLBACK`). Cumple las propiedades ACID: atomicidad (todo o nada), consistencia (los datos siguen cumpliendo las reglas), aislamiento (una transacción no se mezcla con otra que corre al mismo tiempo) y durabilidad (lo confirmado no se pierde).

## 2. Ventajas y aplicaciones

Una venta toca tres tablas: `Compra`, `Detalle_compra` y `Vinilo` (el stock). Si el sistema se cae o falta stock a mitad de camino, sin transacción podría quedar una compra sin renglones o un stock descontado sin venta. Con la transacción eso no puede pasar.

## 3. Implementación en SQL Server Express

Se usa `BEGIN TRANSACTION`, `COMMIT TRANSACTION` y `ROLLBACK TRANSACTION`. Al leer el stock usamos el bloqueo `UPDLOCK, HOLDLOCK`, para que otra venta que llegue en el mismo momento no lea el mismo stock antes de que lo descontemos.

Es la misma lógica que usa `sp_RegistrarVentaCompleta`, pero escrita a mano para poder ver cada paso.

## 4. Caso concreto en La Frecuencia

Un cliente compra vinilos y la operación tiene que:

1. crear la compra;
2. crear el renglón del detalle;
3. descontar el stock.

Si el stock no alcanza no se registra la compra, ni el detalle, ni se toca el stock (RN.05).

## 5. Demostración y resultados

El script hace dos pruebas.

Prueba 1, con stock suficiente: el cliente 4 compra 2 unidades de Kind of Blue, que tiene 20. Sale el mensaje `Venta registrada: se hizo COMMIT.`, la cantidad de compras sube en 1 y el stock pasa de 20 a 18.

Prueba 2, con stock insuficiente: se piden 10 unidades de Artaud y hay 4. Los INSERT de la compra y del detalle se hacen dentro de la transacción, pero el control de stock falla y se ejecuta `ROLLBACK`. Sale el mensaje `Stock insuficiente: se hizo ROLLBACK.` y las cantidades de compras y de renglones son iguales antes y después, y el stock de Artaud sigue en 4. Con esto se demuestra la atomicidad.

Un detalle es que el `ROLLBACK` deshace los datos pero no devuelve el número del IDENTITY, así que la próxima compra va a tener un número salteado. Es normal en SQL Server.

## Evidencias

- `evidencias/01-commit.png`: prueba 1, con los conteos antes y después.
- `evidencias/02-rollback.png`: prueba 2, con los conteos antes y después.
