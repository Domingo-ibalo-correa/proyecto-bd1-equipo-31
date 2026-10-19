<div align="center">

<img src="https://github.com/user-attachments/assets/d6a3d281-197e-4f23-a632-75f70365aa98" height="60" alt="Logo La Frecuencia" />

<br><br>

<img src="https://github.com/user-attachments/assets/c9bd03f5-8546-4938-86c1-facd43aaa16b" width="260" height="260" alt="Disco de vinilo girando" />

# 🎶 La Frecuencia

### Sistema de base de datos para una tienda online de discos de vinilo

**Bases de Datos I · Grupo 31**


</div>

---

## 💿 Sobre el proyecto

**La Frecuencia** es un emprendimiento dedicado a la **venta minorista de discos de vinilo a través de una plataforma digital**. A diferencia de una tienda física tradicional, el canal online permite que clientes de distintas zonas exploren y compren música con mucha más flexibilidad.

El negocio necesita un sistema que resuelva tres pilares:

| Pilar | Qué busca lograr |
| :--- | :--- |
| 📦 **Catálogo y stock** | Descripciones precisas de cada vinilo y un inventario conocido en tiempo real |
| 🛒 **Proceso de venta online** | Un ciclo de compra eficiente y cómodo |
| 👤 **Gestión de clientes** | Perfiles registrados que ayuden a fidelizar compradores |

---

## 🎯 Alcance del sistema

El sistema se organiza en cuatro módulos:

###  Gestión de Stock y Catálogo
Organización y publicación de vinilos con descripciones detalladas, control de inventario con actualización en tiempo real e informes del estado del stock, con avisos cuando un vinilo se está por agotar.

###  Proveedores y Abastecimiento
Registro y administración de múltiples proveedores, y registro de los ingresos de mercadería con el detalle de quién suministró, a qué precio y en qué cantidad.

###  Clientes
Registro de usuarios, creación de cuentas y administración de perfil.

###  Ventas y Finanzas
Administración de métodos de pago online, registro de compras y facturación de cada cliente.



---

## Etapas del trabajo

### Etapa 1 · Requerimientos y dominio del negocio

| Entregable | Archivo |
| :--- | :--- |
| 📄 Información completa de la etapa | [etapa-01.md](docs/etapa-01/etapa-01.md) |
| 🏪 Descripción del caso | [descripcion-caso.md](docs/etapa-01/descripcion-caso.md) |
| 🎯 Alcance del sistema | [alcance.md](docs/etapa-01/alcance.md) |
| 📏 Reglas de negocio | [reglas-negocio.md](docs/etapa-01/reglas-negocio.md) |
| 📑 Entrega en PDF | [equipo31_etapa_1.pdf](docs/etapa-01/equipo31_etapa_1.pdf) |

### Etapa 2 · Modelado de datos

| Entregable | Archivo |
| :--- | :--- |
| 🧩 Diagrama Entidad-Relación (DER) | [Ver DER](docs/etapa-02/der/DER.png) |
| 🗃️ Modelo relacional sin normalizar | [Ver modelo](docs/etapa-02/ModeloRelacionalSinNormalizaci%C3%B3n.png) |
| ✅ Modelo normalizado | [Ver tablas normalizadas](docs/etapa-02/TablaNormalizada.png) |
| 📝 Proceso de normalización | [normalizacion.md](docs/etapa-02/normalizacion.md) |

### Etapa 3 · Implementación en SQL Server

La base de datos se llama `proyecto_grupo31_secuela` y tiene 17 tablas. Para armarla hay que ejecutar los scripts en este orden, sobre una base vacía:

1. [`sql/ddl/crear_bd.sql`](sql/ddl/crear_bd.sql): crea la base, las tablas y las restricciones.
2. [`sql/dml/datos_prueba.sql`](sql/dml/datos_prueba.sql): carga los datos de prueba, con las verificaciones, los UPDATE y DELETE de ejemplo y las pruebas de restricciones.

| Entregable | Archivo |
| :--- | :--- |
| 🛠️ Cómo se implementó (del modelo a las tablas) | [implementacion.md](docs/etapa-03/implementaci%C3%B3n.md) |
| 🔒 Restricciones de integridad (PK, FK, UNIQUE, CHECK) | [restricciones-integridad.md](docs/etapa-03/restricciones-integridad.md) |
| 🧪 Pruebas de validación | [pruebas-validacion.md](docs/etapa-03/pruebas-validacion.md) |
| 🗺️ Diagrama de la base creada | [diagrama-ddl.png](docs/etapa-03/diagrama-ddl.png) |
| 📸 Capturas de las pruebas | [casos-de-prueba/](docs/etapa-03/casos-de-prueba) |

### Etapa 4 · Consultas y casos de uso

Las consultas están en `sql/consultas/` y se ejecutan sobre la base ya creada y cargada (Etapa 3). Cada una tiene su archivo explicativo en `docs/etapa-04/`, con el código, la explicación y el resultado esperado.

| Consulta | Script SQL | Documento |
| :--- | :--- | :--- |
| 🧾 Comprobante de venta (encabezado, detalle, subtotales y total) | [comprobante_venta.sql](sql/consultas/comprobante_venta.sql) | [comprobante-venta.md](docs/etapa-04/comprobante-venta.md) |
| 📊 Informe de ventas por género y por método de pago en un rango de fechas | [informe_ventas.sql](sql/consultas/informe_ventas.sql) | [informe-ventas.md](docs/etapa-04/informe-ventas.md) |
| 🔎 Consulta avanzada (mejores clientes y vinilos a reponer) | [consulta_avanzada.sql](sql/consultas/consulta_avanzada.sql) | [consulta-avanzada.md](docs/etapa-04/consulta-avanzada.md) |

Además, [casos-uso.md](docs/etapa-04/casos-uso.md) explica quién usaría cada consulta y qué necesidad resuelve.

---

## Estructura del repositorio

```
docs/
  etapa-01/   requerimientos y reglas de negocio
  etapa-02/   DER, modelo relacional y normalización
  etapa-03/   implementación, restricciones y pruebas
  etapa-04/   casos de uso y explicación de las consultas
  etapa-05/
sql/
  ddl/        creación de la base y las tablas
  dml/        datos de prueba
  consultas/  consultas de la Etapa 4 (comprobante, informe y consultas avanzadas)
  tecnico/    procedimientos, funciones, triggers, transacciones, índices y seguridad (Etapa 5)
```

---

## Equipo

**Equipo "La Frecuencia" · Grupo 31**

- Javier Agustín Navarro Luque
- Leonardo Exequiel Aquino Ponce
- José Gabriel Gimeno
- José Ignacio Viudes Llanderal
- Domingo Ybaldo Ibalo Correa

---

<div align="center">

*Proyecto académico · Bases de Datos I*

</div>