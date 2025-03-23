USE Los_Ambientales

DELIMITER //

-- 1. Superficie total de parques por departamento
CREATE FUNCTION SuperficieTotalPorDepartamento(p_id_departamento INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_superficie DECIMAL(10,2);
    SELECT SUM(a.extension) INTO v_superficie
    FROM Departamentos_Parques dp
    JOIN Parques_Naturales p ON dp.id_parque = p.id_parque
    JOIN Areas a ON p.id_parque = a.id_parque
    WHERE dp.id_departamento = p_id_departamento;
    RETURN IFNULL(v_superficie, 0);
END //

-- 2. Superficie total de un parque
CREATE FUNCTION SuperficieParque(p_id_parque INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_superficie DECIMAL(10,2);
    SELECT SUM(extension) INTO v_superficie
    FROM Areas
    WHERE id_parque = p_id_parque;
    RETURN IFNULL(v_superficie, 0);
END //

-- 3. Número total de áreas por parque
CREATE FUNCTION NumeroAreasParque(p_id_parque INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_numero INT;
    SELECT COUNT(*) INTO v_numero
    FROM Areas
    WHERE id_parque = p_id_parque;
    RETURN IFNULL(v_numero, 0);
END //

-- 4. Inventario total de especies por área
CREATE FUNCTION InventarioTotalPorArea(p_id_area INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total INT;
    SELECT SUM(numero_inventario) INTO v_total
    FROM Inventario_Especies
    WHERE id_area = p_id_area;
    RETURN IFNULL(v_total, 0);
END //

-- 5. Inventario de especies por tipo en un área
CREATE FUNCTION InventarioPorTipoArea(p_id_area INT, p_tipo VARCHAR(50))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total INT;
    SELECT SUM(ie.numero_inventario) INTO v_total
    FROM Inventario_Especies ie
    JOIN Especies e ON ie.id_especie = e.id_especie
    WHERE ie.id_area = p_id_area AND e.tipo = p_tipo;
    RETURN IFNULL(v_total, 0);
END //

-- 6. Número de especies distintas por parque
CREATE FUNCTION EspeciesDistintasParque(p_id_parque INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total INT;
    SELECT COUNT(DISTINCT ie.id_especie) INTO v_total
    FROM Inventario_Especies ie
    JOIN Areas a ON ie.id_area = a.id_area
    WHERE a.id_parque = p_id_parque;
    RETURN IFNULL(v_total, 0);
END //

-- 7. Inventario total de un tipo de especie por parque
CREATE FUNCTION InventarioTipoPorParque(p_id_parque INT, p_tipo VARCHAR(50))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total INT;
    SELECT SUM(ie.numero_inventario) INTO v_total
    FROM Inventario_Especies ie
    JOIN Especies e ON ie.id_especie = e.id_especie
    JOIN Areas a ON ie.id_area = a.id_area
    WHERE a.id_parque = p_id_parque AND e.tipo = p_tipo;
    RETURN IFNULL(v_total, 0);
END //

-- 8. Número de visitantes actuales por parque
CREATE FUNCTION VisitantesActualesParque(p_id_parque INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total INT;
    SELECT COUNT(*) INTO v_total
    FROM Visitantes_Alojamientos va
    JOIN Alojamientos a ON va.id_alojamiento = a.id_alojamiento
    WHERE a.id_parque = p_id_parque
    AND CURDATE() BETWEEN va.fecha_inicio AND va.fecha_fin;
    RETURN IFNULL(v_total, 0);
END //

-- 9. Capacidad total de alojamientos por parque
CREATE FUNCTION CapacidadAlojamientosParque(p_id_parque INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_capacidad INT;
    SELECT SUM(capacidad) INTO v_capacidad
    FROM Alojamientos
    WHERE id_parque = p_id_parque;
    RETURN IFNULL(v_capacidad, 0);
END //

-- 10. Ocupación promedio de alojamientos por parque
CREATE FUNCTION OcupacionPromedioParque(p_id_parque INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_ocupados INT;
    DECLARE v_capacidad INT;
    SELECT COUNT(*) INTO v_ocupados
    FROM Visitantes_Alojamientos va
    JOIN Alojamientos a ON va.id_alojamiento = a.id_alojamiento
    WHERE a.id_parque = p_id_parque
    AND CURDATE() BETWEEN va.fecha_inicio AND va.fecha_fin;
    SELECT SUM(capacidad) INTO v_capacidad
    FROM Alojamientos
    WHERE id_parque = p_id_parque;
    RETURN IFNULL(v_ocupados / v_capacidad * 100, 0);
END //

-- 11. Costo total de sueldos por tipo de personal
CREATE FUNCTION CostoSueldosPorTipo(p_tipo_personal ENUM('001', '002', '003', '004'))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2);
    SELECT SUM(sueldo) INTO v_total
    FROM Personal
    WHERE tipo_personal = p_tipo_personal;
    RETURN IFNULL(v_total, 0);
END //

-- 12. Número de personal asignado por área
CREATE FUNCTION PersonalAsignadoArea(p_id_area INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total INT;
    SELECT COUNT(*) INTO v_total
    FROM (
        SELECT numero_cedula FROM Vigilancia_Areas WHERE id_area = p_id_area
        UNION
        SELECT numero_cedula FROM Conservacion_Areas WHERE id_area = p_id_area
    ) AS asignados;
    RETURN IFNULL(v_total, 0);
END //

-- 13. Costo total de proyectos por investigador
CREATE FUNCTION CostoProyectosInvestigador(p_numero_cedula VARCHAR(20))
RETURNS DECIMAL(15,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(15,2);
    SELECT SUM(pi.presupuesto) INTO v_total
    FROM Proyectos_Investigacion pi
    JOIN Investigadores_Proyectos ip ON pi.id_proyecto = ip.id_proyecto
    WHERE ip.numero_cedula = p_numero_cedula;
    RETURN IFNULL(v_total, 0);
END //

-- 14. Costo diario promedio de un proyecto
CREATE FUNCTION CostoDiarioProyecto(p_id_proyecto INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_presupuesto DECIMAL(15,2);
    DECLARE v_dias INT;
    SELECT presupuesto, DATEDIFF(fecha_fin, fecha_inicio) INTO v_presupuesto, v_dias
    FROM Proyectos_Investigacion
    WHERE id_proyecto = p_id_proyecto;
    RETURN IFNULL(v_presupuesto / v_dias, 0);
END //

-- 15. Número de proyectos activos por parque
CREATE FUNCTION ProyectosActivosParque(p_id_parque INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total INT;
    SELECT COUNT(DISTINCT pi.id_proyecto) INTO v_total
    FROM Proyectos_Investigacion pi
    JOIN Proyectos_Especies pe ON pi.id_proyecto = pe.id_proyecto
    JOIN Inventario_Especies ie ON pe.id_especie = ie.id_especie
    JOIN Areas a ON ie.id_area = a.id_area
    WHERE a.id_parque = p_id_parque
    AND CURDATE() BETWEEN pi.fecha_inicio AND pi.fecha_fin;
    RETURN IFNULL(v_total, 0);
END //

-- 16. Costo total operativo de vigilancia por área
CREATE FUNCTION CostoVigilanciaArea(p_id_area INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2);
    SELECT SUM(p.sueldo) INTO v_total
    FROM Vigilancia_Areas va
    JOIN Personal p ON va.numero_cedula = p.numero_cedula
    WHERE va.id_area = p_id_area;
    RETURN IFNULL(v_total, 0);
END //

-- 17. Costo total operativo de conservación por área
CREATE FUNCTION CostoConservacionArea(p_id_area INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2);
    SELECT SUM(p.sueldo) INTO v_total
    FROM Conservacion_Areas ca
    JOIN Personal p ON ca.numero_cedula = p.numero_cedula
    WHERE ca.id_area = p_id_area;
    RETURN IFNULL(v_total, 0);
END //

-- 18. Duración promedio de estadías por visitante
CREATE FUNCTION DuracionPromedioEstadia(p_cedula_visitante VARCHAR(20))
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_promedio DECIMAL(5,2);
    SELECT AVG(DATEDIFF(fecha_fin, fecha_inicio)) INTO v_promedio
    FROM Visitantes_Alojamientos
    WHERE cedula_visitante = p_cedula_visitante;
    RETURN IFNULL(v_promedio, 0);
END //

-- 19. Número de entradas registradas por personal
CREATE FUNCTION EntradasPorPersonal(p_numero_cedula VARCHAR(20))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total INT;
    SELECT COUNT(*) INTO v_total
    FROM Entradas
    WHERE numero_cedula = p_numero_cedula;
    RETURN IFNULL(v_total, 0);
END //

-- 20. Costo total de proyectos por tipo de especie
CREATE FUNCTION CostoProyectosPorTipoEspecie(p_tipo VARCHAR(50))
RETURNS DECIMAL(15,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(15,2);
    SELECT SUM(pi.presupuesto) INTO v_total
    FROM Proyectos_Investigacion pi
    JOIN Proyectos_Especies pe ON pi.id_proyecto = pe.id_proyecto
    JOIN Especies e ON pe.id_especie = e.id_especie
    WHERE e.tipo = p_tipo;
    RETURN IFNULL(v_total, 0);
END //

DELIMITER ;