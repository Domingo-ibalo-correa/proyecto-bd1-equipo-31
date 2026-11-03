# Seguridad: permisos de usuarios y roles

Equipo 31 - La Frecuencia

Script: [scripts.sql](scripts.sql) (se ejecuta completo y como administrador, después de crear el procedimiento de la carpeta `procedimientos_funciones`)
Evidencias: carpeta [evidencias/](evidencias)

## 1. Definición y objetivo

La seguridad en la base de datos consiste en controlar quién puede ver o modificar cada dato. En SQL Server hay inicios de sesión (logins) a nivel de servidor, usuarios dentro de cada base y roles, que son grupos de permisos que se le asignan a varios usuarios. Los permisos se dan con `GRANT` y se prohíben con `DENY`. El objetivo es aplicar el principio de mínimo privilegio: cada uno tiene solo lo que necesita.

## 2. Ventajas y aplicaciones

- Protege la información sensible y el historial de ventas de cambios por error o sin autorización.
- Se pueden asignar responsabilidades según el perfil (administrador, lector, vendedor).
- Con roles es más fácil administrar los accesos, porque se cambian los permisos del rol y no los de cada usuario.
- Se puede dar permiso para ejecutar un procedimiento sin dar acceso a las tablas.

## 3. Implementación en SQL Server Express

Se usan `CREATE LOGIN`, `CREATE USER ... FOR LOGIN`, `CREATE ROLE`, `ALTER ROLE ... ADD MEMBER`, `GRANT` y `EXECUTE AS USER`. Las pruebas se hacen con `EXECUTE AS USER`, que permite probar lo que podría hacer cada usuario sin cerrar sesión ni activar la autenticación mixta de SQL Server. También se pueden hacer iniciando sesión con cada usuario si el servidor tiene la autenticación mixta activada.

Las claves de los logins son solo de prueba (como las de la guía) y al final del script hay un bloque comentado para borrar todo.

## 4. Caso concreto en La Frecuencia

Parte 1, permisos a nivel de usuario:

- `usuario_admin` es miembro de `db_owner` (administrador de la base).
- `usuario_lector` solo tiene `SELECT` sobre `Compra`, pero también `EXECUTE` sobre `sp_RegistrarVentaCompleta` (y sobre el tipo `TipoDetalleVenta`, que necesita para mandar los renglones).

Con eso se muestra la diferencia entre ejecutar un `INSERT` directo (el lector no puede) y hacerlo mediante el procedimiento (sí puede). Esto funciona porque el procedimiento y las tablas tienen el mismo dueño (`dbo`), y SQL Server no vuelve a controlar los permisos sobre las tablas dentro del procedimiento (cadena de propiedad).

Parte 2, permisos a nivel de rol:

- Se crea el rol `rol_consulta_vinilos` con `SELECT` sobre `Vinilo`.
- `usuario_con_rol` es miembro del rol y `usuario_sin_rol` no.

## 5. Demostración y resultados

El script hace cinco pruebas y muestra un resumen. Resultados esperados:

| Prueba | Usuario | Resultado esperado |
| --- | --- | --- |
| SELECT sobre Vinilo | usuario_con_rol | Correcto |
| SELECT sobre Vinilo | usuario_sin_rol | Acceso denegado (error 229) |
| INSERT directo sobre Compra | usuario_admin | Correcto |
| INSERT directo sobre Compra | usuario_lector | Acceso denegado (error 229) |
| EXEC sp_RegistrarVentaCompleta | usuario_lector | Correcto |

Con la prueba 3 se inserta una compra de prueba y se borra enseguida, para no dejar una compra sin renglones. La prueba 5 sí deja una venta registrada: la compra del cliente 5 con 1 unidad de El amor después del amor (stock de 26 a 25), y el script la muestra al final.

Con esto se ve que el lector no puede modificar la tabla directamente pero sí hacer la operación autorizada a través del procedimiento, y que el rol da el acceso solo a quienes pertenecen a él.

## Evidencias

- `evidencias/01-resumen-pruebas.png`: tabla resumen de las 5 pruebas.
- `evidencias/02-venta-por-procedimiento.png`: la venta que registró `usuario_lector`.
