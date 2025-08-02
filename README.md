# 📦 Base de Datos — Alianza UTP

El presente repositorio contiene todos los scripts SQL necesarios para implementar la base de datos del sistema Alianza UTP, una plataforma desarrollada con el objetivo de facilitar la gestión de actividades, grupos estudiantiles y participación académica dentro de la Universidad Tecnológica de Panamá. La base de datos fue diseñada como parte del proyecto final de la asignatura Tópicos Especiales II, cursada en el quinto año de la carrera de Licenciatura en Ingeniería de Sistemas y Computación en la Universidad Tecnológica de Panamá.

Este desarrollo formó parte de un requerimiento académico donde se solicitó construir un sistema web completo, funcional y documentado, abarcando tanto el frontend, backend y la base de datos. El sistema Alianza UTP tiene como objetivo facilitar a los estudiantes la exploración, inscripción y gestión de actividades y grupos, promoviendo así una participación más activa y organizada en la comunidad universitaria.

Toda la lógica de negocio relacionada con usuarios, roles, sesiones, actividades, grupos, estados, notificaciones, tareas automatizadas y seguridad fue respaldada desde esta base de datos relacional, estructurada y documentada en este repositorio.
Esta base de datos respalda funcionalmente:
- La gestión de usuarios (estudiantes, docentes y administradores), sus datos personales, estados y roles.
- El registro, autenticación, recuperación de contraseña y validaciones de sesión seguras.
- La creación y organización de actividades académicas, sociales, culturales y deportivas, con control de asistencia e inscripción.
- La visualización y participación en grupos estudiantiles, junto con su categorización, estado y administración interna.
- Un historial completo de participación del usuario en actividades y grupos.
- Automatización de procesos mediante tareas programadas (`pg_cron`), como limpieza de sesiones caducadas, envío de recordatorios, y eliminación de códigos expirados.
- Emisión de notificaciones asincrónicas (via `LISTEN/NOTIFY`) que permiten al backend enviar correos en eventos como: bienvenida, cancelación de eventos, recordatorios o recuperación de contraseña.
---
## 📂 Estructura del repositorio

```text
├── docs/           # Diagramas o documentación visual (ej: ER Diagram)
├── extensions/     # Extensiones requeridas para PostgreSQL
├── functions/      # Funciones almacenadas definidas en PL/pgSQL
├── jobs/           # Tareas automatizadas con pg_cron
├── procedures/     # Procedimientos almacenados
├── schema/         # Scripts de creación de tablas, secuencias e índices
├── triggers/       # Triggers y funciones asociadas
```
---
## 🧱 Requisitos técnicos
PostgreSQL 15 o superior (idealmente).

Extensiones necesarias:
- `uuid-ossp`
- `pg_cron`

---
## ⚙️ Instalación y despliegue
La base de datos puede ser desplegada fácilmente desde cualquier IDE SQL compatible con PostgreSQL, como pgAdmin, DBeaver, DataGrip o directamente desde la terminal con psql.

Sigue los siguientes pasos para inicializar completamente el sistema:

Crear la base de datos

```bash
CREATE DATABASE alianza_utp;
```
Habilitar las extensiones necesarias
Ejecuta el siguiente script para activar las extensiones requeridas:

```bash
\i extensions/create_extensions.sql
```
Crear la estructura base del esquema
Esto incluye tablas, secuencias e índices:

```bash
\i schema/tables.sql
\i schema/sequences.sql
\i schema/indexes.sql
```
Cargar funciones, procedimientos y triggers
Ejecuta en el orden correspondiente según el diseño del proyecto:

```bash
\i functions/...
\i procedures/...
\i triggers/...
```
Cargar catálogos del sistema
Incluye tipos de usuario, género, estado, roles, categorías, etc.:

```bash
\i schema/catalogs.sql
```

Programar tareas automáticas (cron jobs)
Estas tareas incluyen limpieza de sesiones, códigos expirados y generación de notificaciones:
```bash
\i jobs/schedule_jobs.sql
```


> 📌 Nota: Asegúrate de ejecutar los scripts en el orden especificado para evitar errores de dependencias entre funciones y estructuras.

---
## ✍️ Autor

<table style="border-collapse: collapse; border: none;">
  <tr>
    <td style="border: none; padding: 0;">
      <img src="https://github.com/carroyo5.png" width="100" alt="Cristhian Arroyo"><br>
      <strong>Cristhian Arroyo</strong><br>
      Desarrollador y Administrador de Base de Datos  
      <br>
      <a href="https://github.com/carroyo5">@carroyo5</a>
    </td>
  </tr>
</table>


