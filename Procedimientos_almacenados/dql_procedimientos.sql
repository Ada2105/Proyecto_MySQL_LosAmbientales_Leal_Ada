USE Los_Ambientales

DELIMITER //

-- 1. Registrar un nuevo parque con verificación
CREATE PROCEDURE RegistrarParqueConVerificacion(
    IN p_id_parque INT,
    IN p_nombre_parque VARCHAR(100),
    IN p_fecha_declaracion DATE
)
BEGIN
    IF EXISTS (SELECT 1 FROM Parques_Naturales WHERE id_parque = p_id_parque) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El ID del parque ya existe';
    ELSE
        INSERT INTO Parques_Naturales (id_parque, nombre_parque, fecha_declaracion)
        VALUES (p_id_parque, p_nombre_parque, p_fecha_declaracion);
    END IF;
END //

-- 2. Actualizar nombre de un parque
CREATE PROCEDURE ActualizarNombreParque(
    IN p_id_parque INT,
    IN p_nuevo_nombre VARCHAR(100)
)
BEGIN
    UPDATE Parques_Naturales
    SET nombre_parque = p_nuevo_nombre
    WHERE id_parque = p_id_parque;
END //

-- 3. Registrar área con verificación de parque
CREATE PROCEDURE RegistrarAreaConVerificacion(
    IN p_id_area INT,
    IN p_id_parque INT,
    IN p_nombre_area VARCHAR(100),
    IN p_extension DECIMAL(10,2)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Parques_Naturales WHERE id_parque = p_id_parque) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El parque no existe';
    ELSE
        INSERT INTO Areas (id_area, id_parque, nombre_area, extension)
        VALUES (p_id_area, p_id_parque, p_nombre_area, p_extension);
    END IF;
END //

-- 4. Actualizar extensión de un área
CREATE PROCEDURE ActualizarExtensionArea(
    IN p_id_area INT,
    IN p_nueva_extension DECIMAL(10,2)
)
BEGIN
    UPDATE Areas
    SET extension = p_nueva_extension
    WHERE id_area = p_id_area;
END //

-- 5. Registrar especie con tipo válido
CREATE PROCEDURE RegistrarEspecieConTipo(
    IN p_id_especie INT,
    IN p_denominacion_cientifica VARCHAR(100),
    IN p_denominacion_vulgar VARCHAR(100),
    IN p_tipo VARCHAR(50)
)
BEGIN
    IF p_tipo NOT IN ('vegetal', 'animal', 'mineral') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo de especie inválido';
    ELSE
        INSERT INTO Especies (id_especie, denominacion_cientifica, denominacion_vulgar, tipo)
        VALUES (p_id_especie, p_denominacion_cientifica, p_denominacion_vulgar, p_tipo);
    END IF;
END //

-- 6. Actualizar inventario de especie en área
CREATE PROCEDURE ActualizarInventarioEspecieArea(
    IN p_id_area INT,
    IN p_id_especie INT,
    IN p_nuevo_inventario INT
)
BEGIN
    INSERT INTO Inventario_Especies (id_area, id_especie, numero_inventario)
    VALUES (p_id_area, p_id_especie, p_nuevo_inventario)
    ON DUPLICATE KEY UPDATE numero_inventario = p_nuevo_inventario;
END //

-- 7. Registrar visitante con datos completos
CREATE PROCEDURE RegistrarVisitanteCompleto(
    IN p_cedula_visitante VARCHAR(20),
    IN p_nombre VARCHAR(100),
    IN p_direccion TEXT,
    IN p_profesion VARCHAR(50)
)
BEGIN
    INSERT INTO Visitantes (cedula_visitante, nombre, direccion, profesion)
    VALUES (p_cedula_visitante, p_nombre, p_direccion, p_profesion);
END //

-- 8. Asignar alojamiento con verificación de capacidad
CREATE PROCEDURE AsignarAlojamientoConCapacidad(
    IN p_cedula_visitante VARCHAR(20),
    IN p_id_alojamiento INT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    DECLARE v_ocupados INT;
    DECLARE v_capacidad INT;
    
    SELECT COUNT(*) INTO v_ocupados
    FROM Visitantes_Alojamientos
    WHERE id_alojamiento = p_id_alojamiento
    AND (p_fecha_inicio BETWEEN fecha_inicio AND fecha_fin
         OR p_fecha_fin BETWEEN fecha_inicio AND fecha_fin);
    
    SELECT capacidad INTO v_capacidad
    FROM Alojamientos
    WHERE id_alojamiento = p_id_alojamiento;
    
    IF v_ocupados >= v_capacidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Alojamiento lleno en esas fechas';
    ELSE
        INSERT INTO Visitantes_Alojamientos (cedula_visitante, id_alojamiento, fecha_inicio, fecha_fin)
        VALUES (p_cedula_visitante, p_id_alojamiento, p_fecha_inicio, p_fecha_fin);
    END IF;
END //

-- 9. Procesar salida de visitante
CREATE PROCEDURE ProcesarSalidaVisitante(
    IN p_cedula_visitante VARCHAR(20),
    IN p_id_alojamiento INT,
    IN p_fecha_inicio DATE
)
BEGIN
    DELETE FROM Visitantes_Alojamientos
    WHERE cedula_visitante = p_cedula_visitante
    AND id_alojamiento = p_id_alojamiento
    AND fecha_inicio = p_fecha_inicio;
END //

-- 10. Registrar entrada de visitante por personal
CREATE PROCEDURE RegistrarEntradaVisitante(
    IN p_id_entrada INT,
    IN p_numero_cedula VARCHAR(20),
    IN p_numero_registro INT
)
BEGIN
    INSERT INTO Entradas (id_entrada, numero_cedula, numero_registro)
    VALUES (p_id_entrada, p_numero_cedula, p_numero_registro);
END //

-- 11. Asignar personal de vigilancia con verificación
CREATE PROCEDURE AsignarVigilanciaConVerificacion(
    IN p_id_vigilancia INT,
    IN p_numero_cedula VARCHAR(20),
    IN p_id_area INT,
    IN p_tipo_vehiculo VARCHAR(50),
    IN p_marca_vehiculo VARCHAR(50)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Personal WHERE numero_cedula = p_numero_cedula AND tipo_personal = '002') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El personal no es de vigilancia';
    ELSE
        INSERT INTO Vigilancia_Areas (id_vigilancia, numero_cedula, id_area, tipo_vehiculo, marca_vehiculo)
        VALUES (p_id_vigilancia, p_numero_cedula, p_id_area, p_tipo_vehiculo, p_marca_vehiculo);
    END IF;
END //

-- 12. Asignar personal de conservación con verificación
CREATE PROCEDURE AsignarConservacionConVerificacion(
    IN p_id_conservacion INT,
    IN p_numero_cedula VARCHAR(20),
    IN p_id_area INT,
    IN p_especialidad ENUM('limpieza', 'mantenimiento_caminos')
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Personal WHERE numero_cedula = p_numero_cedula AND tipo_personal = '003') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El personal no es de conservación';
    ELSE
        INSERT INTO Conservacion_Areas (id_conservacion, numero_cedula, id_area, especialidad)
        VALUES (p_id_conservacion, p_numero_cedula, p_id_area, p_especialidad);
    END IF;
END //

-- 13. Registrar actividad de vigilancia
CREATE PROCEDURE RegistrarActividadVigilancia(
    IN p_id_vigilancia INT,
    IN p_actividad TEXT
)
BEGIN
    -- Simulación: Actualiza tipo_vehiculo como campo de actividad (puedes ajustar según necesidad)
    UPDATE Vigilancia_Areas
    SET tipo_vehiculo = CONCAT(tipo_vehiculo, ' - ', p_actividad)
    WHERE id_vigilancia = p_id_vigilancia;
END //

-- 14. Registrar actividad de conservación
CREATE PROCEDURE RegistrarActividadConservacion(
    IN p_id_conservacion INT,
    IN p_actividad TEXT
)
BEGIN
    -- Simulación: Actualiza especialidad como campo de actividad
    UPDATE Conservacion_Areas
    SET especialidad = CONCAT(especialidad, ' - ', p_actividad)
    WHERE id_conservacion = p_id_conservacion;
END //

-- 15. Registrar proyecto de investigación con presupuesto
CREATE PROCEDURE RegistrarProyectoConPresupuesto(
    IN p_id_proyecto INT,
    IN p_presupuesto DECIMAL(15,2),
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    IF p_presupuesto < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El presupuesto no puede ser negativo';
    ELSE
        INSERT INTO Proyectos_Investigacion (id_proyecto, presupuesto, fecha_inicio, fecha_fin)
        VALUES (p_id_proyecto, p_presupuesto, p_fecha_inicio, p_fecha_fin);
    END IF;
END //

-- 16. Actualizar presupuesto de proyecto
CREATE PROCEDURE ActualizarPresupuestoProyecto(
    IN p_id_proyecto INT,
    IN p_nuevo_presupuesto DECIMAL(15,2)
)
BEGIN
    UPDATE Proyectos_Investigacion
    SET presupuesto = p_nuevo_presupuesto
    WHERE id_proyecto = p_id_proyecto;
END //

-- 17. Asignar investigador a proyecto con verificación
CREATE PROCEDURE AsignarInvestigadorConVerificacion(
    IN p_numero_cedula VARCHAR(20),
    IN p_id_proyecto INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Personal WHERE numero_cedula = p_numero_cedula AND tipo_personal = '004') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El personal no es investigador';
    ELSE
        INSERT INTO Investigadores_Proyectos (numero_cedula, id_proyecto)
        VALUES (p_numero_cedula, p_id_proyecto);
    END IF;
END //

-- 18. Vincular especie a proyecto
CREATE PROCEDURE VincularEspecieProyecto(
    IN p_id_proyecto INT,
    IN p_id_especie INT
)
BEGIN
    INSERT INTO Proyectos_Especies (id_proyecto, id_especie)
    VALUES (p_id_proyecto, p_id_especie);
END //

-- 19. Calcular costo diario promedio de proyectos
CREATE PROCEDURE CalcularCostoDiarioProyectos()
BEGIN
    SELECT id_proyecto, presupuesto / DATEDIFF(fecha_fin, fecha_inicio) AS costo_diario
    FROM Proyectos_Investigacion
    WHERE fecha_fin > fecha_inicio;
END //

-- 20. Generar reporte de personal asignado por área
CREATE PROCEDURE ReportePersonalPorArea()
BEGIN
    SELECT a.id_area, a.nombre_area,
           COUNT(va.numero_cedula) AS vigilantes,
           COUNT(ca.numero_cedula) AS conservadores
    FROM Areas a
    LEFT JOIN Vigilancia_Areas va ON a.id_area = va.id_area
    LEFT JOIN Conservacion_Areas ca ON a.id_area = ca.id_area
    GROUP BY a.id_area, a.nombre_area;
END //

DELIMITER ;