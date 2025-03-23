USE Los_Ambientales

-- Estado Actual de Parques (20 consultas)
-- 1.Cantidad de parques por departamento:
SELECT d.nombre_departamento, COUNT(dp.id_parque) AS num_parques
FROM Departamentos d
LEFT JOIN Departamentos_Parques dp ON d.id_departamento = dp.id_departamento
GROUP BY d.id_departamento, d.nombre_departamento;

-- 2.Superficie total por parque:
SELECT p.nombre_parque, SUM(a.extension) AS superficie_total
FROM Parques_Naturales p
JOIN Areas a ON p.id_parque = a.id_parque
GROUP BY p.id_parque, p.nombre_parque;

-- 3.Departamentos con más de 2 parques:
SELECT d.nombre_departamento, COUNT(dp.id_parque) AS num_parques
FROM Departamentos d
JOIN Departamentos_Parques dp ON d.id_departamento = dp.id_departamento
GROUP BY d.id_departamento, d.nombre_departamento
HAVING num_parques > 2;

-- 4.Superficie promedio por parque:
SELECT AVG(superficie) AS superficie_promedio
FROM (SELECT p.id_parque, SUM(a.extension) AS superficie
      FROM Parques_Naturales p
      JOIN Areas a ON p.id_parque = a.id_parque
      GROUP BY p.id_parque) AS sub;

-- 5.Parques declarados antes de 1990:
SELECT nombre_parque, fecha_declaracion
FROM Parques_Naturales
WHERE fecha_declaracion < '1990-01-01';

-- 6.Entidad responsable con más parques:
SELECT er.nombre_entidad, COUNT(dp.id_parque) AS num_parques
FROM Entidades_Responsables er
JOIN Departamentos d ON er.id_entidad = d.id_entidad_responsable
JOIN Departamentos_Parques dp ON d.id_departamento = dp.id_departamento
GROUP BY er.id_entidad, er.nombre_entidad
ORDER BY num_parques DESC
LIMIT 1;

-- 7.Superficie total por departamento:
SELECT d.nombre_departamento, SUM(a.extension) AS superficie_total
FROM Departamentos d
JOIN Departamentos_Parques dp ON d.id_departamento = dp.id_departamento
JOIN Areas a ON dp.id_parque = a.id_parque
GROUP BY d.id_departamento, d.nombre_departamento;

-- 8.Parques sin áreas asignadas:
SELECT p.nombre_parque
FROM Parques_Naturales p
LEFT JOIN Areas a ON p.id_parque = a.id_parque
WHERE a.id_area IS NULL;

-- 9.Departamentos con mayor superficie (subconsulta):
SELECT d.nombre_departamento, SUM(a.extension) AS superficie
FROM Departamentos d
JOIN Departamentos_Parques dp ON d.id_departamento = dp.id_departamento
JOIN Areas a ON dp.id_parque = a.id_parque
GROUP BY d.id_departamento, d.nombre_departamento
HAVING superficie > (SELECT AVG(superficie) FROM (SELECT SUM(a.extension) AS superficie
                                                 FROM Departamentos_Parques dp
                                                 JOIN Areas a ON dp.id_parque = a.id_parque
                                                 GROUP BY dp.id_departamento) AS avg_superficie);

-- 10.Parques por década de declaración:
SELECT FLOOR(YEAR(fecha_declaracion) / 10) * 10 AS decada, COUNT(*) AS num_parques
FROM Parques_Naturales
GROUP BY decada
ORDER BY decada;

-- 11.Superficie mínima por parque:
SELECT p.nombre_parque, MIN(a.extension) AS superficie_minima
FROM Parques_Naturales p
JOIN Areas a ON p.id_parque = a.id_parque
GROUP BY p.id_parque, p.nombre_parque;

-- 12.Parques con más de 300 km²:
SELECT p.nombre_parque, SUM(a.extension) AS superficie
FROM Parques_Naturales p
JOIN Areas a ON p.id_parque = a.id_parque
GROUP BY p.id_parque, p.nombre_parque
HAVING superficie > 300;

-- 13.Entidades responsables sin parques:
SELECT er.nombre_entidad
FROM Entidades_Responsables er
LEFT JOIN Departamentos d ON er.id_entidad = d.id_entidad_responsable
LEFT JOIN Departamentos_Parques dp ON d.id_departamento = dp.id_departamento
WHERE dp.id_parque IS NULL;

-- 14.Parques compartidos por más de un departamento:
SELECT p.nombre_parque, COUNT(dp.id_departamento) AS num_departamentos
FROM Parques_Naturales p
JOIN Departamentos_Parques dp ON p.id_parque = dp.id_parque
GROUP BY p.id_parque, p.nombre_parque
HAVING num_departamentos > 1;

-- 15.Superficie total del sistema:
SELECT SUM(extension) AS superficie_total_sistema
FROM Areas;

-- 16.Parques más antiguos por entidad:
SELECT er.nombre_entidad, MIN(p.fecha_declaracion) AS fecha_mas_antigua
FROM Entidades_Responsables er
JOIN Departamentos d ON er.id_entidad = d.id_entidad_responsable
JOIN Departamentos_Parques dp ON d.id_departamento = dp.id_departamento
JOIN Parques_Naturales p ON dp.id_parque = p.id_parque
GROUP BY er.id_entidad, er.nombre_entidad;

--17.Departamentos sin parques (subconsulta):
SELECT nombre_departamento
FROM Departamentos
WHERE id_departamento NOT IN (SELECT id_departamento FROM Departamentos_Parques);

-- 18.Superficie máxima por parque:
SELECT p.nombre_parque, MAX(a.extension) AS superficie_maxima
FROM Parques_Naturales p
JOIN Areas a ON p.id_parque = a.id_parque
GROUP BY p.id_parque, p.nombre_parque;

-- 19.Parques por entidad con superficie total:
SELECT er.nombre_entidad, COUNT(DISTINCT dp.id_parque) AS num_parques, SUM(a.extension) AS superficie
FROM Entidades_Responsables er
JOIN Departamentos d ON er.id_entidad = d.id_entidad_responsable
JOIN Departamentos_Parques dp ON d.id_departamento = dp.id_departamento
JOIN Areas a ON dp.id_parque = a.id_parque
GROUP BY er.id_entidad, er.nombre_entidad;

-- 20.Ranking de parques por superficie (agregación avanzada):
WITH RankingSuperficie AS (
    SELECT p.nombre_parque, SUM(a.extension) AS superficie,
           RANK() OVER (ORDER BY SUM(a.extension) DESC) AS ranking
    FROM Parques_Naturales p
    JOIN Areas a ON p.id_parque = a.id_parque
    GROUP BY p.id_parque, p.nombre_parque
)
SELECT nombre_parque, superficie, ranking
FROM RankingSuperficie
WHERE ranking <= 5;


-- Inventarios de Especies por Áreas y Tipos (20 consultas)
-- 21.Cantidad de especies por área:
SELECT a.nombre_area, COUNT(ie.id_especie) AS num_especies
FROM Areas a
LEFT JOIN Inventario_Especies ie ON a.id_area = ie.id_area
GROUP BY a.id_area, a.nombre_area;

-- 22.Especies por tipo: 
SELECT tipo, COUNT(*) AS num_especies
FROM Especies
GROUP BY tipo;

-- 23.SELECT a.nombre_area, e.denominacion_vulgar, ie.numero_inventario
FROM Areas a
JOIN Inventario_Especies ie ON a.id_area = ie.id_area
JOIN Especies e ON ie.id_especie = e.id_especie
WHERE ie.numero_inventario > 50;

-- 24.SELECT e.tipo, SUM(ie.numero_inventario) AS total_individuos
FROM Especies e
JOIN Inventario_Especies ie ON e.id_especie = ie.id_especie
GROUP BY e.tipo;

-- 25.Áreas sin especies registradas:
SELECT a.nombre_area
FROM Areas a
LEFT JOIN Inventario_Especies ie ON a.id_area = ie.id_area
WHERE ie.id_especie IS NULL;

-- 26.Especies más abundantes por área:
SELECT a.nombre_area, e.denominacion_vulgar, ie.numero_inventario
FROM Areas a
JOIN Inventario_Especies ie ON a.id_area = ie.id_area
JOIN Especies e ON ie.id_especie = e.id_especie
WHERE ie.numero_inventario = (SELECT MAX(numero_inventario) 
                              FROM Inventario_Especies ie2 
                              WHERE ie2.id_area = ie.id_area);

-- 27.Parques con más especies animales:
SELECT p.nombre_parque, COUNT(ie.id_especie) AS num_animales
FROM Parques_Naturales p
JOIN Areas a ON p.id_parque = a.id_parque
JOIN Inventario_Especies ie ON a.id_area = ie.id_area
JOIN Especies e ON ie.id_especie = e.id_especie
WHERE e.tipo = 'animal'
GROUP BY p.id_parque, p.nombre_parque
ORDER BY num_animales DESC
LIMIT 5;

-- 28.Promedio de individuos por especie:
SELECT e.denominacion_vulgar, AVG(ie.numero_inventario) AS promedio_individuos
FROM Especies e
JOIN Inventario_Especies ie ON e.id_especie = ie.id_especie
GROUP BY e.id_especie, e.denominacion_vulgar;

-- 29.Especies en más de 5 áreas:
SELECT e.denominacion_vulgar, COUNT(ie.id_area) AS num_areas
FROM Especies e
JOIN Inventario_Especies ie ON e.id_especie = ie.id_especie
GROUP BY e.id_especie, e.denominacion_vulgar
HAVING num_areas > 5;

-- 30.Total de individuos por parque:
SELECT p.nombre_parque, SUM(ie.numero_inventario) AS total_individuos
FROM Parques_Naturales p
JOIN Areas a ON p.id_parque = a.id_parque
JOIN Inventario_Especies ie ON a.id_area = ie.id_area
GROUP BY p.id_parque, p.nombre_parque;
 
-- 31.Áreas con solo especies vegetales:
SELECT a.nombre_area
FROM Areas a
JOIN Inventario_Especies ie ON a.id_area = ie.id_area
JOIN Especies e ON ie.id_especie = e.id_especie
GROUP BY a.id_area, a.nombre_area
HAVING COUNT(CASE WHEN e.tipo != 'vegetal' THEN 1 END) = 0;

-- 32.Especies con menos de 10 individuos en total:
SELECT e.denominacion_vulgar, SUM(ie.numero_inventario) AS total
FROM Especies e
JOIN Inventario_Especies ie ON e.id_especie = ie.id_especie
GROUP BY e.id_especie, e.denominacion_vulgar
HAVING total < 10;

-- 33.Distribución de especies por tipo en cada parque:
SELECT p.nombre_parque, e.tipo, COUNT(ie.id_especie) AS num_especies
FROM Parques_Naturales p
JOIN Areas a ON p.id_parque = a.id_parque
JOIN Inventario_Especies ie ON a.id_area = ie.id_area
JOIN Especies e ON ie.id_especie = e.id_especie
GROUP BY p.id_parque, p.nombre_parque, e.tipo;

-- 34.Áreas con mayor diversidad de especies (subconsulta):
SELECT a.nombre_area, COUNT(ie.id_especie) AS num_especies
FROM Areas a
JOIN Inventario_Especies ie ON a.id_area = ie.id_area
GROUP BY a.id_area, a.nombre_area
HAVING num_especies > (SELECT AVG(COUNT(id_especie)) 
                      FROM Inventario_Especies 
                      GROUP BY id_area);

-- 35.Especies exclusivas de un área:
SELECT e.denominacion_vulgar, a.nombre_area
FROM Especies e
JOIN Inventario_Especies ie ON e.id_especie = ie.id_especie
JOIN Areas a ON ie.id_area = a.id_area
GROUP BY e.id_especie, e.denominacion_vulgar, a.id_area, a.nombre_area
HAVING COUNT(ie.id_area) = 1;

-- 36.Total de minerales por parque:
SELECT p.nombre_parque, SUM(ie.numero_inventario) AS total_minerales
FROM Parques_Naturales p
JOIN Areas a ON p.id_parque = a.id_parque
JOIN Inventario_Especies ie ON a.id_area = ie.id_area
JOIN Especies e ON ie.id_especie = e.id_especie
WHERE e.tipo = 'mineral'
GROUP BY p.id_parque, p.nombre_parque;

-- 37.Áreas con más de 2 tipos de especies:
SELECT a.nombre_area, COUNT(DISTINCT e.tipo) AS num_tipos
FROM Areas a
JOIN Inventario_Especies ie ON a.id_area = ie.id_area
JOIN Especies e ON ie.id_especie = e.id_especie
GROUP BY a.id_area, a.nombre_area
HAVING num_tipos > 2;

-- 38.Especies con mayor número de individuos (agregación avanzada):
WITH EspeciesTotal AS (
    SELECT e.denominacion_vulgar, SUM(ie.numero_inventario) AS total_individuos
    FROM Especies e
    JOIN Inventario_Especies ie ON e.id_especie = ie.id_especie
    GROUP BY e.id_especie, e.denominacion_vulgar
)
SELECT denominacion_vulgar, total_individuos
FROM EspeciesTotal
WHERE total_individuos = (SELECT MAX(total_individuos) FROM EspeciesTotal);

-- 39.Parques con especies amenazadas:
SELECT DISTINCT p.nombre_parque
FROM Parques_Naturales p
JOIN Areas a ON p.id_parque = a.id_parque
JOIN Inventario_Especies ie ON a.id_area = ie.id_area
WHERE ie.numero_inventario < 5;

-- 40.Relación especies/área por parque:
SELECT p.nombre_parque, COUNT(ie.id_especie) / COUNT(DISTINCT a.id_area) AS especies_por_area
FROM Parques_Naturales p
JOIN Areas a ON p.id_parque = a.id_parque
JOIN Inventario_Especies ie ON a.id_area = ie.id_area
GROUP BY p.id_parque, p.nombre_parque;

-- Actividades del Personal según Tipo, Áreas y Sueldos (20 consultas)
-- 41.Cantidad de personal por tipo:
SELECT tipo_personal, COUNT(*) AS num_personal
FROM Personal
GROUP BY tipo_personal;

-- 42.Sueldo total por tipo de personal:
SELECT tipo_personal, SUM(sueldo) AS sueldo_total
FROM Personal
GROUP BY tipo_personal;

-- 43.Personal de gestión con más registros:
SELECT p.nombre, COUNT(e.id_entrada) AS num_registros
FROM Personal p
JOIN Entradas e ON p.numero_cedula = e.numero_cedula
WHERE p.tipo_personal = '001'
GROUP BY p.numero_cedula, p.nombre
ORDER BY num_registros DESC
LIMIT 1;

-- 44.Áreas vigiladas por personal:
SELECT p.nombre, a.nombre_area
FROM Personal p
JOIN Vigilancia_Areas va ON p.numero_cedula = va.numero_cedula
JOIN Areas a ON va.id_area = a.id_area
WHERE p.tipo_personal = '002';

-- 45.Sueldo promedio por tipo:
SELECT tipo_personal, AVG(sueldo) AS sueldo_promedio
FROM Personal
GROUP BY tipo_personal;

-- 46.Personal con sueldo superior al promedio (subconsulta):
SELECT nombre, sueldo, tipo_personal
FROM Personal p
WHERE sueldo > (SELECT AVG(sueldo) FROM Personal WHERE tipo_personal = p.tipo_personal);

-- 47.Áreas mantenidas por personal de conservación:
SELECT p.nombre, a.nombre_area, ca.especialidad
FROM Personal p
JOIN Conservacion_Areas ca ON p.numero_cedula = ca.numero_cedula
JOIN Areas a ON ca.id_area = a.id_area
WHERE p.tipo_personal = '003';

-- 48.Vehículos más usados por vigilancia:
SELECT tipo_vehiculo, marca_vehiculo, COUNT(*) AS num_usos
FROM Vigilancia_Areas
GROUP BY tipo_vehiculo, marca_vehiculo
ORDER BY num_usos DESC;

-- 49.Personal sin asignación:
SELECT p.nombre, p.tipo_personal
FROM Personal p
LEFT JOIN Entradas e ON p.numero_cedula = e.numero_cedula AND p.tipo_personal = '001'
LEFT JOIN Vigilancia_Areas va ON p.numero_cedula = va.numero_cedula AND p.tipo_personal = '002'
LEFT JOIN Conservacion_Areas ca ON p.numero_cedula = ca.numero_cedula AND p.tipo_personal = '003'
LEFT JOIN Investigadores_Proyectos ip ON p.numero_cedula = ip.numero_cedula AND p.tipo_personal = '004'
WHERE e.id_entrada IS NULL AND va.id_vigilancia IS NULL AND ca.id_conservacion IS NULL AND ip.id_proyecto IS NULL;

-- 50.Sueldo total del personal investigador:
SELECT SUM(sueldo) AS sueldo_total_investigadores
FROM Personal
WHERE tipo_personal = '004';

-- 51.Personal por especialidad de conservación:
SELECT ca.especialidad, COUNT(DISTINCT p.numero_cedula) AS num_personal
FROM Personal p
JOIN Conservacion_Areas ca ON p.numero_cedula = ca.numero_cedula
WHERE p.tipo_personal = '003'
GROUP BY ca.especialidad;

-- 52.Personal con más áreas vigiladas:
SELECT p.nombre, COUNT(va.id_area) AS num_areas
FROM Personal p
JOIN Vigilancia_Areas va ON p.numero_cedula = va.numero_cedula
WHERE p.tipo_personal = '002'
GROUP BY p.numero_cedula, p.nombre
ORDER BY num_areas DESC
LIMIT 1;

-- 53.Sueldo máximo por tipo:
SELECT tipo_personal, MAX(sueldo) AS sueldo_maximo
FROM Personal
GROUP BY tipo_personal;

-- 54.Personal investigador con más proyectos:
SELECT p.nombre, COUNT(ip.id_proyecto) AS num_proyectos
FROM Personal p
JOIN Investigadores_Proyectos ip ON p.numero_cedula = ip.numero_cedula
WHERE p.tipo_personal = '004'
GROUP BY p.numero_cedula, p.nombre
ORDER BY num_proyectos DESC
LIMIT 1;

-- 55.Áreas con más personal asignado:
WITH PersonalPorArea AS (
    SELECT id_area, COUNT(*) AS num_personal
    FROM (
        SELECT id_area FROM Vigilancia_Areas
        UNION ALL
        SELECT id_area FROM Conservacion_Areas
    ) AS areas_asignadas
    GROUP BY id_area
)
SELECT a.nombre_area, ppa.num_personal
FROM Areas a
JOIN PersonalPorArea ppa ON a.id_area = ppa.id_area
ORDER BY ppa.num_personal DESC
LIMIT 5;

-- 56.Personal con teléfono móvil único:
SELECT nombre, telefono_movil
FROM Personal
GROUP BY telefono_movil, nombre
HAVING COUNT(*) = 1;

-- 57.Sueldo promedio de personal con asignaciones:
SELECT AVG(p.sueldo) AS sueldo_promedio
FROM Personal p
WHERE EXISTS (
    SELECT 1 FROM Entradas e WHERE e.numero_cedula = p.numero_cedula
    UNION
    SELECT 1 FROM Vigilancia_Areas va WHERE va.numero_cedula = p.numero_cedula
    UNION
    SELECT 1 FROM Conservacion_Areas ca WHERE ca.numero_cedula = p.numero_cedula
    UNION
    SELECT 1 FROM Investigadores_Proyectos ip WHERE ip.numero_cedula = p.numero_cedula
);

-- 58.Personal por parque (vigilancia y conservación):
SELECT p2.nombre_parque, COUNT(DISTINCT p.numero_cedula) AS num_personal
FROM Personal p
JOIN (
    SELECT numero_cedula, id_area FROM Vigilancia_Areas
    UNION
    SELECT numero_cedula, id_area FROM Conservacion_Areas
) AS asignaciones ON p.numero_cedula = asignaciones.numero_cedula
JOIN Areas a ON asignaciones.id_area = a.id_area
JOIN Parques_Naturales p2 ON a.id_parque = p2.id_parque
GROUP BY p2.id_parque, p2.nombre_parque;

-- 59.Personal con sueldo por encima del promedio general:
SELECT nombre, sueldo, tipo_personal
FROM Personal
WHERE sueldo > (SELECT AVG(sueldo) FROM Personal);

-- 60.Distribución de personal por rango de sueldo:
SELECT CASE 
           WHEN sueldo < 1600 THEN 'Bajo'
           WHEN sueldo BETWEEN 1600 AND 1800 THEN 'Medio'
           ELSE 'Alto'
       END AS rango_sueldo, COUNT(*) AS num_personal
FROM Personal
GROUP BY rango_sueldo;

-- Estadísticas de Proyectos de Investigación (20 consultas)
-- 61.Costo total de proyectos:
SELECT SUM(presupuesto) AS costo_total
FROM Proyectos_Investigacion;

-- 62.Proyectos por año de inicio:
SELECT YEAR(fecha_inicio) AS anio, COUNT(*) AS num_proyectos
FROM Proyectos_Investigacion
GROUP BY anio;

-- 63.Costo promedio por proyecto:
SELECT AVG(presupuesto) AS costo_promedio
FROM Proyectos_Investigacion;

-- 64.Proyectos con más de 3 especies:
SELECT pi.id_proyecto, COUNT(pe.id_especie) AS num_especies
FROM Proyectos_Investigacion pi
JOIN Proyectos_Especies pe ON pi.id_proyecto = pe.id_proyecto
GROUP BY pi.id_proyecto
HAVING num_especies > 3;

-- 65.Investigadores por proyecto:
SELECT pi.id_proyecto, COUNT(ip.numero_cedula) AS num_investigadores
FROM Proyectos_Investigacion pi
JOIN Investigadores_Proyectos ip ON pi.id_proyecto = ip.id_proyecto
GROUP BY pi.id_proyecto;

-- 66.Costo total por investigador:
SELECT p.nombre, SUM(pi.presupuesto) AS costo_total
FROM Personal p
JOIN Investigadores_Proyectos ip ON p.numero_cedula = ip.numero_cedula
JOIN Proyectos_Investigacion pi ON ip.id_proyecto = pi.id_proyecto
WHERE p.tipo_personal = '004'
GROUP BY p.numero_cedula, p.nombre;

-- 67.Proyectos en curso
SELECT id_proyecto, fecha_inicio, fecha_fin
FROM Proyectos_Investigacion
WHERE '2025-03-20' BETWEEN fecha_inicio AND fecha_fin;

-- 68.Especies más estudiadas:
SELECT e.denominacion_vulgar, COUNT(pe.id_proyecto) AS num_proyectos
FROM Especies e
JOIN Proyectos_Especies pe ON e.id_especie = pe.id_especie
GROUP BY e.id_especie, e.denominacion_vulgar
ORDER BY num_proyectos DESC
LIMIT 5;

-- 69.Proyectos con mayor presupuesto:
SELECT id_proyecto, presupuesto
FROM Proyectos_Investigacion
ORDER BY presupuesto DESC
LIMIT 5;

-- 70.Costo promedio por especie estudiada:
SELECT AVG(pi.presupuesto / num_especies) AS costo_por_especie
FROM Proyectos_Investigacion pi
JOIN (SELECT id_proyecto, COUNT(id_especie) AS num_especies
      FROM Proyectos_Especies
      GROUP BY id_proyecto) AS especies ON pi.id_proyecto = especies.id_proyecto;

-- 71.Proyectos sin investigadores:
SELECT pi.id_proyecto
FROM Proyectos_Investigacion pi
LEFT JOIN Investigadores_Proyectos ip ON pi.id_proyecto = ip.id_proyecto
WHERE ip.numero_cedula IS NULL;

-- 72.Duración promedio de proyectos:
SELECT AVG(DATEDIFF(fecha_fin, fecha_inicio)) AS duracion_promedio_dias
FROM Proyectos_Investigacion;

-- 73.Proyectos con especies animales:
SELECT DISTINCT pi.id_proyecto
FROM Proyectos_Investigacion pi
JOIN Proyectos_Especies pe ON pi.id_proyecto = pe.id_proyecto
JOIN Especies e ON pe.id_especie = e.id_especie
WHERE e.tipo = 'animal';

-- 74.Investigadores con más de 5 proyectos:
SELECT p.nombre, COUNT(ip.id_proyecto) AS num_proyectos
FROM Personal p
JOIN Investigadores_Proyectos ip ON p.numero_cedula = ip.numero_cedula
WHERE p.tipo_personal = '004'
GROUP BY p.numero_cedula, p.nombre
HAVING num_proyectos > 5;

-- 75.Costo total por tipo de especie (subconsulta):
SELECT e.tipo, SUM(pi.presupuesto) AS costo_total
FROM Especies e
JOIN Proyectos_Especies pe ON e.id_especie = pe.id_especie
JOIN Proyectos_Investigacion pi ON pe.id_proyecto = pi.id_proyecto
GROUP BY e.tipo;

-- 76.Proyectos más largos:
SELECT id_proyecto, DATEDIFF(fecha_fin, fecha_inicio) AS duracion_dias
FROM Proyectos_Investigacion
ORDER BY duracion_dias DESC
LIMIT 5;

-- 77.Presupuesto total por año:
SELECT YEAR(fecha_inicio) AS anio, SUM(presupuesto) AS presupuesto_total
FROM Proyectos_Investigacion
GROUP BY anio;

-- 78.Proyectos con presupuesto por encima del promedio (subconsulta):
SELECT id_proyecto, presupuesto
FROM Proyectos_Investigacion
WHERE presupuesto > (SELECT AVG(presupuesto) FROM Proyectos_Investigacion);

-- 79.Especies estudiadas por más de un proyecto:
SELECT e.denominacion_vulgar, COUNT(pe.id_proyecto) AS num_proyectos
FROM Especies e
JOIN Proyectos_Especies pe ON e.id_especie = pe.id_especie
GROUP BY e.id_especie, e.denominacion_vulgar
HAVING num_proyectos > 1;

-- 80.Ranking de investigadores por costo:
WITH CostoPorInvestigador AS (
    SELECT p.nombre, SUM(pi.presupuesto) AS costo_total
    FROM Personal p
    JOIN Investigadores_Proyectos ip ON p.numero_cedula = ip.numero_cedula
    JOIN Proyectos_Investigacion pi ON ip.id_proyecto = pi.id_proyecto
    WHERE p.tipo_personal = '004'
    GROUP BY p.numero_cedula, p.nombre
)
SELECT nombre, costo_total, RANK() OVER (ORDER BY costo_total DESC) AS ranking
FROM CostoPorInvestigador;

-- Gestión de Visitantes y Ocupación de Alojamientos (20 consultas)
-- 81.Cantidad de visitantes por profesión:
SELECT profesion, COUNT(*) AS num_visitantes
FROM Visitantes
GROUP BY profesion;

-- 82.Ocupación total por alojamiento:
SELECT a.id_alojamiento, COUNT(va.cedula_visitante) AS num_visitantes
FROM Alojamientos a
LEFT JOIN Visitantes_Alojamientos va ON a.id_alojamiento = va.id_alojamiento
GROUP BY a.id_alojamiento;

-- 83.Alojamientos con capacidad completa:
SELECT a.id_alojamiento, a.capacidad
FROM Alojamientos a
JOIN Visitantes_Alojamientos va ON a.id_alojamiento = va.id_alojamiento
GROUP BY a.id_alojamiento, a.capacidad
HAVING COUNT(va.cedula_visitante) >= a.capacidad;

-- 84.Visitantes por parque:
SELECT p.nombre_parque, COUNT(DISTINCT va.cedula_visitante) AS num_visitantes
FROM Parques_Naturales p
JOIN Alojamientos a ON p.id_parque = a.id_parque
JOIN Visitantes_Alojamientos va ON a.id_alojamiento = va.id_alojamiento
GROUP BY p.id_parque, p.nombre_parque;

-- 85.Duración promedio de estadías:
SELECT AVG(DATEDIFF(fecha_fin, fecha_inicio)) AS duracion_promedio_dias
FROM Visitantes_Alojamientos;

-- 86.Alojamientos más ocupados:
SELECT a.id_alojamiento, a.categoria, COUNT(va.cedula_visitante) AS num_reservas
FROM Alojamientos a
JOIN Visitantes_Alojamientos va ON a.id_alojamiento = va.id_alojamiento
GROUP BY a.id_alojamiento, a.categoria
ORDER BY num_reservas DESC
LIMIT 5;

-- 87.Visitantes con estadías largas:
SELECT v.nombre, DATEDIFF(va.fecha_fin, va.fecha_inicio) AS duracion
FROM Visitantes v
JOIN Visitantes_Alojamientos va ON v.cedula_visitante = va.cedula_visitante
WHERE DATEDIFF(va.fecha_fin, va.fecha_inicio) > 5;

-- 88.Parques con más alojamientos:
SELECT p.nombre_parque, COUNT(a.id_alojamiento) AS num_alojamientos
FROM Parques_Naturales p
JOIN Alojamientos a ON p.id_parque = a.id_parque
GROUP BY p.id_parque, p.nombre_parque
ORDER BY num_alojamientos DESC;

-- 89.Ocupación por categoría de alojamiento:
SELECT a.categoria, COUNT(va.cedula_visitante) AS num_visitantes
FROM Alojamientos a
JOIN Visitantes_Alojamientos va ON a.id_alojamiento = va.id_alojamiento
GROUP BY a.categoria;

-- 90.Visitantes sin alojamiento:
SELECT v.nombre
FROM Visitantes v
LEFT JOIN Visitantes_Alojamientos va ON v.cedula_visitante = va.cedula_visitante
WHERE va.id_alojamiento IS NULL;

-- 91.Alojamientos disponibles hoy:
SELECT a.id_alojamiento, a.capacidad
FROM Alojamientos a
LEFT JOIN Visitantes_Alojamientos va ON a.id_alojamiento = va.id_alojamiento
AND '2025-03-20' BETWEEN va.fecha_inicio AND va.fecha_fin
WHERE va.cedula_visitante IS NULL;

-- 92.Visitantes por mes:
SELECT MONTH(fecha_inicio) AS mes, COUNT(DISTINCT cedula_visitante) AS num_visitantes
FROM Visitantes_Alojamientos
GROUP BY mes;

-- 93.Alojamientos con más de 20 de capacidad:
SELECT id_alojamiento, capacidad, categoria
FROM Alojamientos
WHERE capacidad > 20;

-- 94.Parques con ocupación total (subconsulta):
SELECT p.nombre_parque
FROM Parques_Naturales p
JOIN Alojamientos a ON p.id_parque = a.id_parque
WHERE NOT EXISTS (
    SELECT 1 FROM Visitantes_Alojamientos va
    WHERE va.id_alojamiento = a.id_alojamiento
    AND '2025-03-20' NOT BETWEEN va.fecha_inicio AND va.fecha_fin
);

-- 95.Visitantes frecuentes:
SELECT v.nombre, COUNT(va.id_alojamiento) AS num_reservas
FROM Visitantes v
JOIN Visitantes_Alojamientos va ON v.cedula_visitante = va.cedula_visitante
GROUP BY v.cedula_visitante, v.nombre
HAVING num_reservas > 1;

-- 96.Capacidad total por parque:
SELECT p.nombre_parque, SUM(a.capacidad) AS capacidad_total
FROM Parques_Naturales p
JOIN Alojamientos a ON p.id_parque = a.id_parque
GROUP BY p.id_parque, p.nombre_parque;

-- 97.Alojamientos con ocupación por encima del promedio (subconsulta):
SELECT a.id_alojamiento, COUNT(va.cedula_visitante) AS num_visitantes
FROM Alojamientos a
JOIN Visitantes_Alojamientos va ON a.id_alojamiento = va.id_alojamiento
GROUP BY a.id_alojamiento
HAVING num_visitantes > (SELECT AVG(COUNT(cedula_visitante)) 
                        FROM Visitantes_Alojamientos 
                        GROUP BY id_alojamiento);

-- 98.Estadías más largas por parque:
SELECT p.nombre_parque, MAX(DATEDIFF(va.fecha_fin, va.fecha_inicio)) AS max_duracion
FROM Parques_Naturales p
JOIN Alojamientos a ON p.id_parque = a.id_parque
JOIN Visitantes_Alojamientos va ON a.id_alojamiento = va.id_alojamiento
GROUP BY p.id_parque, p.nombre_parque;

-- 99.Visitantes por alojamiento en marzo 2025:
SELECT a.id_alojamiento, COUNT(va.cedula_visitante) AS num_visitantes
FROM Alojamientos a
JOIN Visitantes_Alojamientos va ON a.id_alojamiento = va.id_alojamiento
WHERE MONTH(va.fecha_inicio) = 3 AND YEAR(va.fecha_inicio) = 2025
GROUP BY a.id_alojamiento;

-- 100.Ranking de parques por ocupación:
WITH OcupacionParque AS (
    SELECT p.nombre_parque, COUNT(va.cedula_visitante) AS num_visitantes
    FROM Parques_Naturales p
    JOIN Alojamientos a ON p.id_parque = a.id_parque
    JOIN Visitantes_Alojamientos va ON a.id_alojamiento = va.id_alojamiento
    GROUP BY p.id_parque, p.nombre_parque
)
SELECT nombre_parque, num_visitantes, RANK() OVER (ORDER BY num_visitantes DESC) AS ranking
FROM OcupacionParque
LIMIT 5;



