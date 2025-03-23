-- Habilitar privilegios para el usuario actual (ejecutar como root o con permisos de GRANT)
-- Nota: Asegúrarse de ejecutar esto con un usuario con privilegios administrativos (ej. root)

-- Crear los 5 usuarios con contraseñas (ajústalas según tu política de seguridad)
CREATE USER 'administrador'@'localhost' IDENTIFIED BY 'admin123';
CREATE USER 'gestor_parques'@'localhost' IDENTIFIED BY 'parques456';
CREATE USER 'investigador'@'localhost' IDENTIFIED BY 'invest789';
CREATE USER 'auditor'@'localhost' IDENTIFIED BY 'audit101';
CREATE USER 'encargado_visitantes'@'localhost' IDENTIFIED BY 'visit202';

-- 1. Administrador: Acceso total a todas las tablas
GRANT ALL PRIVILEGES ON *.* TO 'administrador'@'localhost' WITH GRANT OPTION;
-- Permisos completos (SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, etc.) en toda la base de datos

-- 2. Gestor de parques: Gestión de parques, áreas y especies
GRANT SELECT, INSERT, UPDATE, DELETE ON Parques_Naturales TO 'gestor_parques'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON Areas TO 'gestor_parques'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON Especies TO 'gestor_parques'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON Inventario_Especies TO 'gestor_parques'@'localhost';
GRANT SELECT ON Departamentos TO 'gestor_parques'@'localhost'; -- Solo lectura para referencia
GRANT SELECT ON Departamentos_Parques TO 'gestor_parques'@'localhost'; -- Solo lectura para relación
-- Permite gestionar parques, áreas, especies e inventarios; lectura en tablas relacionadas

-- 3. Investigador: Acceso a datos de proyectos y especies
GRANT SELECT, INSERT, UPDATE ON Proyectos_Investigacion TO 'investigador'@'localhost';
GRANT SELECT, INSERT, UPDATE ON Proyectos_Especies TO 'investigador'@'localhost';
GRANT SELECT ON Especies TO 'investigador'@'localhost'; -- Lectura de especies
GRANT SELECT ON Inventario_Especies TO 'investigador'@'localhost'; -- Lectura de inventarios
GRANT SELECT, INSERT, UPDATE ON Investigadores_Proyectos TO 'investigador'@'localhost'; -- Gestionar asignaciones
GRANT SELECT ON Personal TO 'investigador'@'localhost'; -- Lectura de personal para referencia
GRANT SELECT ON Areas TO 'investigador'@'localhost'; -- Lectura de áreas para contexto
-- Permite gestionar proyectos, asignaciones y leer datos de especies y áreas

-- 4. Auditor: Acceso a reportes financieros
GRANT SELECT ON Proyectos_Investigacion TO 'auditor'@'localhost'; -- Lectura de presupuestos
GRANT SELECT ON Personal TO 'auditor'@'localhost'; -- Lectura de sueldos
GRANT SELECT ON Parques_Naturales TO 'auditor'@'localhost'; -- Lectura para contexto
GRANT SELECT ON Areas TO 'auditor'@'localhost'; -- Lectura para contexto
GRANT SELECT ON Visitantes_Alojamientos TO 'auditor'@'localhost'; -- Lectura para ocupación
GRANT SELECT ON Alojamientos TO 'auditor'@'localhost'; -- Lectura para capacidad
-- Solo lectura para datos financieros y operativos relevantes

-- 5. Encargado de visitantes: Gestión de visitantes y alojamientos
GRANT SELECT, INSERT, UPDATE, DELETE ON Visitantes TO 'encargado_visitantes'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON Alojamientos TO 'encargado_visitantes'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON Visitantes_Alojamientos TO 'encargado_visitantes'@'localhost';
GRANT SELECT ON Parques_Naturales TO 'encargado_visitantes'@'localhost'; -- Lectura para referencia
GRANT SELECT ON Areas TO 'encargado_visitantes'@'localhost'; -- Lectura para contexto
-- Permite gestionar visitantes, alojamientos y reservas; lectura en parques y áreas

-- Aplicar los privilegios
FLUSH PRIVILEGES;