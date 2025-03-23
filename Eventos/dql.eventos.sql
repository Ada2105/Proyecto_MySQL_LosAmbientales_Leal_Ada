USE Los_Ambientales

DELIMITER //

-- 1. Reporte semanal de total de visitantes (salida directa)
CREATE EVENT ReporteVisitantesSemanal
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-03-24 00:00:00' 
DO
BEGIN
    SELECT WEEK(fecha_inicio) AS semana, YEAR(fecha_inicio) AS anio, 
           COUNT(DISTINCT cedula_visitante) AS num_visitantes, NOW() AS fecha_generacion
    FROM Visitantes_Alojamientos
    WHERE fecha_inicio >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
    GROUP BY WEEK(fecha_inicio), YEAR(fecha_inicio);
END //

-- 2. Reporte semanal de ocupación por alojamiento (salida directa)
CREATE EVENT ReporteAlojamientosSemanal
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-03-24 00:00:00'
DO
BEGIN
    SELECT WEEK(va.fecha_inicio) AS semana, YEAR(va.fecha_inicio) AS anio, 
           a.id_alojamiento, COUNT(va.cedula_visitante) AS ocupacion, NOW() AS fecha_generacion
    FROM Alojamientos a
    LEFT JOIN Visitantes_Alojamientos va ON a.id_alojamiento = va.id_alojamiento
    AND va.fecha_inicio >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
    GROUP BY WEEK(va.fecha_inicio), YEAR(va.fecha_inicio), a.id_alojamiento;
END //

-- 3. Reporte semanal de visitantes por parque (salida directa)
CREATE EVENT ReporteVisitantesPorParqueSemanal
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-03-24 00:00:00'
DO
BEGIN
    SELECT p.nombre_parque, WEEK(va.fecha_inicio) AS semana, YEAR(va.fecha_inicio) AS anio, 
           COUNT(DISTINCT va.cedula_visitante) AS num_visitantes, NOW() AS fecha_generacion
    FROM Parques_Naturales p
    JOIN Alojamientos a ON p.id_parque = a.id_parque
    JOIN Visitantes_Alojamientos va ON a.id_alojamiento = va.id_alojamiento
    WHERE va.fecha_inicio >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
    GROUP BY p.id_parque, p.nombre_parque, WEEK(va.fecha_inicio), YEAR(va.fecha_inicio);
END //

-- 4. Reporte semanal de alojamientos con capacidad completa (salida directa)
CREATE EVENT ReporteAlojamientosCompletosSemanal
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-03-24 00:00:00'
DO
BEGIN
    SELECT WEEK(va.fecha_inicio) AS semana, YEAR(va.fecha_inicio) AS anio, 
           a.id_alojamiento, COUNT(va.cedula_visitante) AS ocupacion, a.capacidad, NOW() AS fecha_generacion
    FROM Alojamientos a
    JOIN Visitantes_Alojamientos va ON a.id_alojamiento = va.id_alojamiento
    WHERE va.fecha_inicio >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
    GROUP BY WEEK(va.fecha_inicio), YEAR(va.fecha_inicio), a.id_alojamiento, a.capacidad
    HAVING COUNT(va.cedula_visitante) >= a.capacidad;
END //

-- 5. Reporte semanal de visitantes por profesión (salida directa)
CREATE EVENT ReporteVisitantesPorProfesionSemanal
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-03-24 00:00:00'
DO
BEGIN
    SELECT v.profesion, WEEK(va.fecha_inicio) AS semana, YEAR(va.fecha_inicio) AS anio, 
           COUNT(DISTINCT va.cedula_visitante) AS num_visitantes, NOW() AS fecha_generacion
    FROM Visitantes v
    JOIN Visitantes_Alojamientos va ON v.cedula_visitante = va.cedula_visitante
    WHERE va.fecha_inicio >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
    GROUP BY v.profesion, WEEK(va.fecha_inicio), YEAR(va.fecha_inicio);
END //

-- 6. Reporte semanal de estadías promedio (salida directa)
CREATE EVENT ReporteEstadiasPromedioSemanal
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-03-24 00:00:00'
DO
BEGIN
    SELECT WEEK(fecha_inicio) AS semana, YEAR(fecha_inicio) AS anio, 
           AVG(DATEDIFF(fecha_fin, fecha_inicio)) AS duracion_promedio, NOW() AS fecha_generacion
    FROM Visitantes_Alojamientos
    WHERE fecha_inicio >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
    GROUP BY WEEK(fecha_inicio), YEAR(fecha_inicio);
END //

-- 7. Reporte semanal de alojamientos vacíos (salida directa)
CREATE EVENT ReporteAlojamientosVaciosSemanal
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-03-24 00:00:00'
DO
BEGIN
    SELECT WEEK(CURDATE()) AS semana, YEAR(CURDATE()) AS anio, 
           a.id_alojamiento, 0 AS ocupacion, NOW() AS fecha_generacion
    FROM Alojamientos a
    LEFT JOIN Visitantes_Alojamientos va ON a.id_alojamiento = va.id_alojamiento
    AND va.fecha_inicio >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
    WHERE va.cedula_visitante IS NULL;
END //

-- 8. Reporte semanal de visitantes recurrentes (salida directa)
CREATE EVENT ReporteVisitantesRecurrentesSemanal
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-03-24 00:00:00'
DO
BEGIN
    SELECT WEEK(fecha_inicio) AS semana, YEAR(fecha_inicio) AS anio, 
           cedula_visitante, COUNT(*) AS num_reservas, NOW() AS fecha_generacion
    FROM Visitantes_Alojamientos
    WHERE fecha_inicio >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
    GROUP BY WEEK(fecha_inicio), YEAR(fecha_inicio), cedula_visitante
    HAVING COUNT(*) > 1;
END //

-- 9. Reporte semanal de ingresos por alojamientos (simulado, salida directa)
CREATE EVENT ReporteIngresosAlojamientosSemanal
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-03-24 00:00:00'
DO
BEGIN
    SELECT WEEK(va.fecha_inicio) AS semana, YEAR(va.fecha_inicio) AS anio, 
           a.id_alojamiento, COUNT(va.cedula_visitante) * 50 AS ingresos_simulados, NOW() AS fecha_generacion
    FROM Alojamientos a
    JOIN Visitantes_Alojamientos va ON a.id_alojamiento = va.id_alojamiento
    WHERE va.fecha_inicio >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
    GROUP BY WEEK(va.fecha_inicio), YEAR(va.fecha_inicio), a.id_alojamiento;
END //

-- 10. Reporte semanal de capacidad disponible por parque (salida directa)
CREATE EVENT ReporteCapacidadDisponibleSemanal
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-03-24 00:00:00'
DO
BEGIN
    SELECT p.nombre_parque, WEEK(CURDATE()) AS semana, YEAR(CURDATE()) AS anio,
           SUM(a.capacidad) - COALESCE(COUNT(va.cedula_visitante), 0) AS capacidad_disponible, NOW() AS fecha_generacion
    FROM Parques_Naturales p
    JOIN Alojamientos a ON p.id_parque = a.id_parque
    LEFT JOIN Visitantes_Alojamientos va ON a.id_alojamiento = va.id_alojamiento
    AND va.fecha_inicio >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
    GROUP BY p.id_parque, p.nombre_parque, WEEK(CURDATE()), YEAR(CURDATE());
END //

-- 11. Incrementar inventario de animales diariamente (simulación)
CREATE EVENT ActualizarInventarioAnimalesDiario
ON SCHEDULE EVERY 1 DAY
STARTS '2025-03-22 00:00:00'
DO
BEGIN
    UPDATE Inventario_Especies ie
    JOIN Especies e ON ie.id_especie = e.id_especie
    SET ie.numero_inventario = ie.numero_inventario + FLOOR(RAND() * 2) -- Incremento aleatorio 0-1
    WHERE e.tipo = 'animal';
END //

-- 12. Reducir inventario de vegetales mensualmente (simulación)
CREATE EVENT ReducirInventarioVegetalesMensual
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-04-01 00:00:00'
DO
BEGIN
    UPDATE Inventario_Especies ie
    JOIN Especies e ON ie.id_especie = e.id_especie
    SET ie.numero_inventario = GREATEST(ie.numero_inventario - FLOOR(RAND() * 5), 0) -- Reducción aleatoria 0-4
    WHERE e.tipo = 'vegetal';
END //

-- 13. Actualizar inventario de minerales cada 6 meses
CREATE EVENT ActualizarInventarioMineralesSemestral
ON SCHEDULE EVERY 6 MONTH
STARTS '2025-09-01 00:00:00'
DO
BEGIN
    UPDATE Inventario_Especies ie
    JOIN Especies e ON ie.id_especie = e.id_especie
    SET ie.numero_inventario = ie.numero_inventario + FLOOR(RAND() * 10) -- Incremento aleatorio 0-9
    WHERE e.tipo = 'mineral';
END //

-- 14. Reiniciar inventario de animales con menos de 5 individuos
CREATE EVENT ReiniciarInventarioAnimalesBajosMensual
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-04-01 00:00:00'
DO
BEGIN
    UPDATE Inventario_Especies ie
    JOIN Especies e ON ie.id_especie = e.id_especie
    SET ie.numero_inventario = 10
    WHERE e.tipo = 'animal' AND ie.numero_inventario < 5;
END //

-- 15. Actualizar inventario de especies en áreas específicas diariamente
CREATE EVENT ActualizarInventarioAreasDiario
ON SCHEDULE EVERY 1 DAY
STARTS '2025-03-22 00:00:00'
DO
BEGIN
    UPDATE Inventario_Especies
    SET numero_inventario = numero_inventario + FLOOR(RAND() * 3) - 1 -- Cambio aleatorio -1 a 2
    WHERE id_area BETWEEN 1 AND 10; -- Solo primeras 10 áreas como ejemplo
END //

-- 16. Registrar inventario cero para especies no detectadas mensualmente
CREATE EVENT RegistrarEspeciesNoDetectadasMensual
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-04-01 00:00:00'
DO
BEGIN
    INSERT INTO Inventario_Especies (id_area, id_especie, numero_inventario)
    SELECT a.id_area, e.id_especie, 0
    FROM Areas a
    CROSS JOIN Especies e
    LEFT JOIN Inventario_Especies ie ON a.id_area = ie.id_area AND e.id_especie = ie.id_especie
    WHERE ie.id_especie IS NULL
    LIMIT 10; -- Limita a 10 inserciones por ejecución
END //

-- 17. Actualizar inventario de vegetales en parques grandes mensualmente
CREATE EVENT ActualizarVegetalesParquesGrandesMensual
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-04-01 00:00:00'
DO
BEGIN
    UPDATE Inventario_Especies ie
    JOIN Especies e ON ie.id_especie = e.id_especie
    JOIN Areas a ON ie.id_area = a.id_area
    SET ie.numero_inventario = ie.numero_inventario + FLOOR(RAND() * 10)
    WHERE e.tipo = 'vegetal' AND a.extension > 200;
END //

-- 18. Reducir inventario de animales en áreas pequeñas mensualmente
CREATE EVENT ReducirAnimalesAreasPequenasMensual
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-04-01 00:00:00'
DO
BEGIN
    UPDATE Inventario_Especies ie
    JOIN Especies e ON ie.id_especie = e.id_especie
    JOIN Areas a ON ie.id_area = a.id_area
    SET ie.numero_inventario = GREATEST(ie.numero_inventario - FLOOR(RAND() * 3), 0)
    WHERE e.tipo = 'animal' AND a.extension < 100;
END //

-- 19. Actualizar inventario de especies estudiadas mensualmente
CREATE EVENT ActualizarEspeciesEstudiadasMensual
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-04-01 00:00:00'
DO
BEGIN
    UPDATE Inventario_Especies ie
    JOIN Proyectos_Especies pe ON ie.id_especie = pe.id_especie
    SET ie.numero_inventario = ie.numero_inventario + FLOOR(RAND() * 5)
    WHERE EXISTS (SELECT 1 FROM Proyectos_Investigacion pi 
                  WHERE pi.id_proyecto = pe.id_proyecto 
                  AND CURDATE() BETWEEN pi.fecha_inicio AND pi.fecha_fin);
END //

-- 20. Limpiar inventarios obsoletos anualmente
CREATE EVENT LimpiarInventariosObsoletosAnual
ON SCHEDULE EVERY 1 YEAR
STARTS '2026-01-01 00:00:00'
DO
BEGIN
    DELETE FROM Inventario_Especies
    WHERE numero_inventario = 0 AND id_especie NOT IN (
        SELECT id_especie FROM Proyectos_Especies
        WHERE id_proyecto IN (SELECT id_proyecto FROM Proyectos_Investigacion 
                              WHERE CURDATE() <= fecha_fin)
    );
END //

DELIMITER ;