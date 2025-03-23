# Sistema de Gestión de Los Ambientales

## Descripción del Proyecto

El **Sistema de Gestión de Los Ambientales** es una base de datos diseñada para gestionar de manera eficiente todas las operaciones relacionadas con los parques naturales bajo la supervisión del Ministerio del Medio Ambiente. El sistema abarca la administración de departamentos, parques, áreas, especies, personal, proyectos de investigación, visitantes y alojamientos, asegurando una solución robusta, optimizada y capaz de facilitar consultas críticas para la toma de decisiones. Su propósito es centralizar y organizar la información operativa y financiera, permitiendo un manejo efectivo de los recursos ambientales y el soporte a las decisiones estratégicas del Ministerio.

Las funcionalidades implementadas incluyen:
- Estructura relacional que modela departamentos, parques, áreas, especies, personal, proyectos, visitantes y alojamientos con relaciones claras (ej. un parque puede pertenecer a varios departamentos).
- 100 consultas SQL para análisis detallados, incluyendo estado de parques, inventarios, actividades del personal, estadísticas de proyectos y ocupación de alojamientos.
- 20 procedimientos almacenados para automatizar tareas como registro, actualización y gestión de recursos.
- 20 funciones para cálculos específicos como superficies, inventarios y costos operativos.
- 20 triggers para mantener la integridad de datos (ej. actualización automática de inventarios).
- 20 eventos automáticos para reportes y actualizaciones periódicas (ej. reportes semanales de ocupación).
- 5 roles de usuario con permisos específicos para distintos niveles de acceso.

## Requisitos del Sistema

Para ejecutar los scripts y trabajar con la base de datos, necesitas:
- **MySQL**: Versión 8.0 o superior (compatible con funciones, triggers y eventos).
- **Cliente MySQL**: MySQL Workbench, phpMyAdmin o la línea de comandos de MySQL.
- **Sistema Operativo**: Windows, Linux o macOS (compatible con MySQL).
- **Espacio en Disco**: Mínimo 100 MB para la base de datos y los 50+ registros por tabla.
- **Permisos**: Acceso de administrador en MySQL para crear usuarios, asignar privilegios y activar el scheduler de eventos.

## Instalación y Configuración

### Paso 1: Configurar el Entorno
1. Instala MySQL Server y un cliente (ej. MySQL Workbench) si no están instalados.
2. Inicia el servidor MySQL:
   - Linux: `sudo service mysql start`
   - Windows: Usa el panel de control o servicios.
3. Conéctate como usuario root: `mysql -u root -p`.

### Paso 2: Crear la Base de Datos y Estructura
1. Crea la base de datos:
   ```sql
   CREATE DATABASE Los_Ambientales;
   USE Los_Ambientales;


Ejecuta el archivo ddl.sql para generar la estructura:
MySQL Workbench: File > Open SQL Script > ddl.sql > Execute.
Línea de comandos: mysql -u root -p Los_Ambientales < ddl.sql.

Paso 3: Cargar Datos Iniciales
-Ejecuta el archivo dml.sql para insertar al menos 50 registros por tabla:
MySQL Workbench: File > Open SQL Script > dml.sql > Execute.
Línea de comandos: mysql -u root -p Los_Ambientales < dml.sql.

Paso 4: Ejecutar Componentes Adicionales
-Consultas: Ejecuta dql_select.sql para probar las 100 consultas.
Ejemplo: SELECT * FROM Parques_Naturales;
-Procedimientos Almacenados: Ejecuta dql_procedimientos.sql.
Ejemplo: CALL RegistrarParqueConVerificacion(1, 'Parque Central', '2025-03-22');
-Funciones: Ejecuta dql_funciones.sql.
Ejemplo: SELECT SuperficieParque(1);
-Triggers: Ejecuta dql_triggers.sql. Se activan automáticamente con operaciones en tablas.
-Eventos: Ejecuta dql_eventos.sql y activa el scheduler:
    SET GLOBAL event_scheduler = ON;
-Usuarios y Permisos: Ejecuta usuarios.sql como root.

Estructura de la Base de Datos
La base de datos Los_Ambientales incluye las siguientes tablas principales:

Departamentos: Datos de departamentos supervisados por el Ministerio.
Entidades_Responsables: Entidades que gestionan parques en uno o más departamentos.
Departamentos_Parques: Relación muchos-a-muchos entre departamentos y parques.
Parques_Naturales: Información de parques (nombre, fecha de declaración).
Areas: Áreas dentro de los parques (nombre, extensión).
Especies: Catálogo de especies (científica, vulgar, tipo: vegetal/animal/mineral).
Inventario_Especies: Número de individuos por especie en cada área.
Personal: Datos del personal (cédula, nombre, tipo: 001-004, sueldo).
Vigilancia_Areas: Asignaciones de personal de vigilancia (vehículos incluidos).
Conservacion_Areas: Asignaciones de personal de conservación (especialidades).
Entradas: Registro de entradas de visitantes por personal de gestión.
Proyectos_Investigacion: Proyectos con presupuesto y fechas.
Proyectos_Especies: Relación entre proyectos y especies estudiadas.
Investigadores_Proyectos: Asignaciones de investigadores a proyectos.
Visitantes: Datos de visitantes (cédula, nombre, dirección, profesión).
Alojamientos: Alojamientos en parques (capacidad limitada).
Visitantes_Alojamientos: Reservas de visitantes en alojamientos (fechas).

Las tablas están interconectadas mediante claves foráneas (ej. id_parque en Areas, Departamentos_Parques para múltiples departamentos por parque) para reflejar las relaciones del modelo.

Ejemplos de Consultas
1.Consulta básica: Número de parques por departamento
    SELECT d.nombre_departamento, COUNT(dp.id_parque) AS total_parques
    FROM Departamentos d
    LEFT JOIN Departamentos_Parques dp ON d.id_departamento = dp.id_departamento
    GROUP BY d.id_departamento, d.nombre_departamento;
Muestra cuántos parques naturales tiene cada departamento.

2.Consulta avanzada: Costo total de proyectos por investigador
    SELECT p.nombre, SUM(pi.presupuesto) AS costo_total
    FROM Personal p
    JOIN Investigadores_Proyectos ip ON p.numero_cedula = ip.numero_cedula
    JOIN Proyectos_Investigacion pi ON ip.id_proyecto = pi.id_proyecto
    WHERE p.tipo_personal = '004'
    GROUP BY p.numero_cedula, p.nombre
    HAVING costo_total > (SELECT AVG(presupuesto) FROM Proyectos_Investigacion);
Lista investigadores con costos de proyectos superiores al promedio, usando subconsulta.

3.Consulta de ocupación actual
    SELECT a.id_alojamiento, a.capacidad, COUNT(va.cedula_visitante) AS ocupados
    FROM Alojamientos a
    LEFT JOIN Visitantes_Alojamientos va ON a.id_alojamiento = va.id_alojamiento
    AND CURDATE() BETWEEN va.fecha_inicio AND va.fecha_fin
    GROUP BY a.id_alojamiento, a.capacidad;
Muestra la ocupación actual de cada alojamiento.

Procedimientos, Funciones, Triggers y Eventos

Procedimientos Almacenados
Cantidad: 20 procedimientos.
Funcionalidad: Automatizan registro y actualización de parques/áreas/especies, procesamiento de visitantes/alojamientos, asignación de personal y gestión de proyectos/presupuestos.
Ejemplo:
    CALL AsignarAlojamientoConCapacidad('V123', 1, '2025-04-01', '2025-04-05');
Asigna un alojamiento verificando capacidad disponible.

Funciones
Cantidad: 20 funciones.
Funcionalidad: Calculan superficies por departamento (SuperficieTotalPorDepartamento), inventarios por tipo/área (InventarioPorTipoArea), y costos operativos (CostoDiarioProyecto).
Ejemplo:
    SELECT SuperficieTotalPorDepartamento(1);
Devuelve la superficie total de parques en un departamento.

Triggers
Cantidad: 20 triggers.
Funcionalidad: Automatizan actualizaciones de inventarios al registrar áreas y registran movimientos/cambios salariales del personal.
Ejemplo:
    INSERT INTO Areas (id_area, id_parque, nombre_area, extension) VALUES (1, 1, 'Zona Norte', 100.50);
Activa un trigger para inicializar inventarios.

Eventos
Cantidad: 20 eventos.
Funcionalidad: Generan reportes semanales (visitantes, alojamientos) y actualizan inventarios periódicamente.
Ejemplo hipotético:
    CREATE EVENT ReporteSemanalVisitantes ON SCHEDULE EVERY 1 WEEK DO CALL ReporteVisitantes();
Genera un reporte semanal de visitantes.

Roles de Usuario y Permisos
Roles Definidos
1.Administrador
Permisos: Acceso total (ALL PRIVILEGES) a todas las tablas.
Uso: Gestiona toda la base de datos y usuarios.

2.Gestor de parques
Permisos: SELECT, INSERT, UPDATE, DELETE en Parques_Naturales, Areas, Especies, Inventario_Especies; SELECT en tablas relacionadas.
Uso: Administra parques, áreas y especies.

3.Investigador
Permisos: SELECT, INSERT, UPDATE en Proyectos_Investigacion, Proyectos_Especies, Investigadores_Proyectos; SELECT en Especies, Inventario_Especies, Personal, Areas.
Uso: Gestiona proyectos y consulta datos científicos.

4.Auditor
Permisos: SELECT en Proyectos_Investigacion, Personal, Parques_Naturales, Areas, Visitantes_Alojamientos, Alojamientos.
Uso: Revisa datos financieros y operativos.

5.Encargado de visitantes
Permisos: SELECT, INSERT, UPDATE, DELETE en Visitantes, Alojamientos, Visitantes_Alojamientos; SELECT en Parques_Naturales, Areas.
Uso: Gestiona visitantes y alojamientos.

Crear Usuarios y Asignar Permisos
-Conéctate como root: mysql -u root -p.
-Ejecuta el script usuarios.sql:
    CREATE USER 'administrador'@'localhost' IDENTIFIED BY 'admin123';
    GRANT ALL PRIVILEGES ON Los_Ambientales.* TO 'administrador'@'localhost';
    CREATE USER 'gestor_parques'@'localhost' IDENTIFIED BY 'parques456';
    GRANT SELECT, INSERT, UPDATE, DELETE ON Los_Ambientales.Parques_Naturales TO 'gestor_parques'@'localhost';
    -- Repite para cada usuario y permisos
    FLUSH PRIVILEGES;

Contribuciones
Este proyecto fue desarrollado individualmente por Ada Leal:

Diseño del modelo de datos y creación de ddl.sql.
Inserción de datos realistas en dml.sql.
Implementación de 100 consultas en dql_select.sql.
Creación de procedimientos almacenados en dql_procedimientos.sql.
Desarrollo de funciones en dql_funciones.sql.
Implementación de triggers en dql_triggers.sql.
Configuración de eventos en dql_eventos.sql.
Definición de roles y permisos en usuarios.sql.

Licencia y Contacto
Licencia
Este proyecto está bajo la Licencia MIT. Puedes usarlo y modificarlo libremente, siempre que se incluya el reconocimiento al autor original.

Contacto
Para preguntas, problemas o sugerencias, contacta a Ada Leal:

Email: adaleal62@gmail.com
GitHub: Ada2105

¡Gracias por usar el Sistema de Gestión de Los Ambientales!