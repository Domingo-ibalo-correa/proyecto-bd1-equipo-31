# Etapa 4 - Casos de uso

Equipo 31

En esta etapa hicimos tres consultas sobre la base de La Frecuencia. Están en `sql/consultas/` y cada una tiene su archivo explicativo acá en `docs/etapa-04/`.

- **Comprobante de venta** (`comprobante_venta.sql`, explicación en [comprobante-venta.md](comprobante-venta.md)): lo usaría el cliente o el vendedor para ver el detalle de una compra.
- **Informe de ventas** (`informe_ventas.sql`, explicación en [informe-ventas.md](informe-ventas.md)): lo usaría el dueño de la tienda para ver qué géneros y qué métodos de pago venden más en un período.
- **Consultas avanzadas** (`consulta_avanzada.sql`, explicación en [consulta-avanzada.md](consulta-avanzada.md)): también para el dueño. La primera busca a los clientes que más gastan y la segunda los vinilos que hay que volver a pedir.

Algunas cosas que tuvimos en cuenta de las reglas de negocio:

- En los informes solo contamos las compras con estado `realizado`, porque las pendientes y las canceladas no son ventas realmente (RN.05).
- Los precios salen de `Detalle_compra.precio_unidad`, que es el precio que se cobró ese día (RN.06).
- Para el género hay que mirar dos lugares, `Vinilo.id_genero` para los normales y `genero_multiple` para los personalizados (RN.03).

Para probarlas hay que correr primero `crear_bd.sql` y `datos_prueba.sql`. Las variables para cambiar (`@id_compra`, `@desde`, `@hasta`) están arriba de cada archivo.