USE Los_Ambientales

DELIMITER //

-- 1. Trigger para inicializar inventario al registrar nueva área
CREATE TRIGGER AfterInsertArea
AFTER INSERT ON Areas
FOR EACH ROW
BEGIN
    -- Inserta inventario inicial (0) para todas las especies en la nueva área
    INSERT INTO Inventario_Especies (id_area, id_especie, numero_inventario)
    SELECT NEW.id_area, id_especie, 0
    FROM Especies;
END //

-- 2. Trigger para ajustar inventario al modificar extensión de área
CREATE TRIGGER AfterUpdateAreaExtension
AFTER UPDATE ON Areas
FOR EACH ROW
BEGIN
    IF NEW.extension != OLD.extension THEN
        -- Ajusta inventario proporcionalmente (simulación simple)
        UPDATE Inventario_Especies
        SET numero_inventario = numero_inventario * (NEW.extension / OLD.extension)
        WHERE id_area = NEW.id_area;
    END IF;
END //

-- 3. Trigger para eliminar inventario al borrar un área
CREATE TRIGGER BeforeDeleteArea
BEFORE DELETE ON Areas
FOR EACH ROW
BEGIN
    DELETE FROM Inventario_Especies
    WHERE id_area = OLD.id_area;
END //

-- 4. Trigger para notificar inserción de inventario (salida directa)
CREATE TRIGGER AfterInsertInventario
AFTER INSERT ON Inventario_Especies
FOR EACH ROW
BEGIN
    SELECT CONCAT('Inventario insertado - Área: ', NEW.id_area, 
                  ', Especie: ', NEW.id_especie, 
                  ', Cantidad: ', NEW.numero_inventario) AS mensaje;
END //

-- 5. Trigger para notificar actualización de inventario (salida directa)
CREATE TRIGGER AfterUpdateInventario
AFTER UPDATE ON Inventario_Especies
FOR EACH ROW
BEGIN
    IF NEW.numero_inventario != OLD.numero_inventario THEN
        SELECT CONCAT('Inventario actualizado - Área: ', NEW.id_area, 
                      ', Especie: ', NEW.id_especie, 
                      ', Anterior: ', OLD.numero_inventario, 
                      ', Nuevo: ', NEW.numero_inventario) AS mensaje;
    END IF;
END //

-- 6. Trigger para notificar eliminación de inventario (salida directa)
CREATE TRIGGER AfterDeleteInventario
AFTER DELETE ON Inventario_Especies
FOR EACH ROW
BEGIN
    SELECT CONCAT('Inventario eliminado - Área: ', OLD.id_area, 
                  ', Especie: ', OLD.id_especie, 
                  ', Cantidad: ', OLD.numero_inventario) AS mensaje;
END //

-- 7. Trigger para notificar inserción de personal (salida directa)
CREATE TRIGGER AfterInsertPersonal
AFTER INSERT ON Personal
FOR EACH ROW
BEGIN
    SELECT CONCAT('Personal insertado - Cédula: ', NEW.numero_cedula, 
                  ', Nombre: ', NEW.nombre, 
                  ', Tipo: ', NEW.tipo_personal, 
                  ', Sueldo: ', NEW.sueldo) AS mensaje;
END //

-- 8. Trigger para notificar cambio de sueldo (salida directa)
CREATE TRIGGER AfterUpdateSueldoPersonal
AFTER UPDATE ON Personal
FOR EACH ROW
BEGIN
    IF NEW.sueldo != OLD.sueldo THEN
        SELECT CONCAT('Cambio de sueldo - Cédula: ', NEW.numero_cedula, 
                      ', Anterior: ', OLD.sueldo, 
                      ', Nuevo: ', NEW.sueldo) AS mensaje;
    END IF;
END //

-- 9. Trigger para notificar eliminación de personal (salida directa)
CREATE TRIGGER AfterDeletePersonal
AFTER DELETE ON Personal
FOR EACH ROW
BEGIN
    SELECT CONCAT('Personal eliminado - Cédula: ', OLD.numero_cedula, 
                  ', Nombre: ', OLD.nombre, 
                  ', Tipo: ', OLD.tipo_personal, 
                  ', Sueldo: ', OLD.sueldo) AS mensaje;
END //

-- 10. Trigger para notificar asignación de vigilancia (salida directa)
CREATE TRIGGER AfterInsertVigilancia
AFTER INSERT ON Vigilancia_Areas
FOR EACH ROW
BEGIN
    SELECT CONCAT('Asignación vigilancia - Cédula: ', NEW.numero_cedula, 
                  ', Área: ', NEW.id_area, 
                  ', Vehículo: ', NEW.tipo_vehiculo, ' ', NEW.marca_vehiculo) AS mensaje;
END //

-- 11. Trigger para notificar eliminación de vigilancia (salida directa)
CREATE TRIGGER AfterDeleteVigilancia
AFTER DELETE ON Vigilancia_Areas
FOR EACH ROW
BEGIN
    SELECT CONCAT('Eliminación vigilancia - Cédula: ', OLD.numero_cedula, 
                  ', Área: ', OLD.id_area, 
                  ', Vehículo: ', OLD.tipo_vehiculo, ' ', OLD.marca_vehiculo) AS mensaje;
END //

-- 12. Trigger para notificar asignación de conservación (salida directa)
CREATE TRIGGER AfterInsertConservacion
AFTER INSERT ON Conservacion_Areas
FOR EACH ROW
BEGIN
    SELECT CONCAT('Asignación conservación - Cédula: ', NEW.numero_cedula, 
                  ', Área: ', NEW.id_area, 
                  ', Especialidad: ', NEW.especialidad) AS mensaje;
END //

-- 13. Trigger para notificar eliminación de conservación (salida directa)
CREATE TRIGGER AfterDeleteConservacion
AFTER DELETE ON Conservacion_Areas
FOR EACH ROW
BEGIN
    SELECT CONCAT('Eliminación conservación - Cédula: ', OLD.numero_cedula, 
                  ', Área: ', OLD.id_area, 
                  ', Especialidad: ', OLD.especialidad) AS mensaje;
END //

-- 14. Trigger para notificar registro de entrada (salida directa)
CREATE TRIGGER AfterInsertEntrada
AFTER INSERT ON Entradas
FOR EACH ROW
BEGIN
    SELECT CONCAT('Registro entrada - Cédula: ', NEW.numero_cedula, 
                  ', Número Registro: ', NEW.numero_registro) AS mensaje;
END //

-- 15. Trigger para notificar asignación de investigador a proyecto (salida directa)
CREATE TRIGGER AfterInsertInvestigadorProyecto
AFTER INSERT ON Investigadores_Proyectos
FOR EACH ROW
BEGIN
    SELECT CONCAT('Asignación proyecto - Cédula: ', NEW.numero_cedula, 
                  ', Proyecto: ', NEW.id_proyecto) AS mensaje;
END //

-- 16. Trigger para notificar eliminación de investigador de proyecto (salida directa)
CREATE TRIGGER AfterDeleteInvestigadorProyecto
AFTER DELETE ON Investigadores_Proyectos
FOR EACH ROW
BEGIN
    SELECT CONCAT('Eliminación proyecto - Cédula: ', OLD.numero_cedula, 
                  ', Proyecto: ', OLD.id_proyecto) AS mensaje;
END //

-- 17. Trigger para notificar cambio de tipo de personal (salida directa)
CREATE TRIGGER AfterUpdateTipoPersonal
AFTER UPDATE ON Personal
FOR EACH ROW
BEGIN
    IF NEW.tipo_personal != OLD.tipo_personal THEN
        SELECT CONCAT('Cambio tipo personal - Cédula: ', NEW.numero_cedula, 
                      ', Anterior: ', OLD.tipo_personal, 
                      ', Nuevo: ', NEW.tipo_personal) AS mensaje;
    END IF;
END //

-- 18. Trigger para notificar actualización de teléfono móvil (salida directa)
CREATE TRIGGER AfterUpdateTelefonoPersonal
AFTER UPDATE ON Personal
FOR EACH ROW
BEGIN
    IF NEW.telefono_movil != OLD.telefono_movil THEN
        SELECT CONCAT('Cambio teléfono - Cédula: ', NEW.numero_cedula, 
                      ', Anterior: ', OLD.telefono_movil, 
                      ', Nuevo: ', NEW.telefono_movil) AS mensaje;
    END IF;
END //

-- 19. Trigger para ajustar inventario al agregar especie a proyecto
CREATE TRIGGER AfterInsertProyectoEspecie
AFTER INSERT ON Proyectos_Especies
FOR EACH ROW
BEGIN
    -- Incrementa inventario en 5 para la especie en todas las áreas (simulación)
    UPDATE Inventario_Especies
    SET numero_inventario = numero_inventario + 5
    WHERE id_especie = NEW.id_especie;
END //

-- 20. Trigger para ajustar inventario al eliminar especie de proyecto
CREATE TRIGGER AfterDeleteProyectoEspecie
AFTER DELETE ON Proyectos_Especies
FOR EACH ROW
BEGIN
    -- Reduce inventario en 5 para la especie (simulación)
    UPDATE Inventario_Especies
    SET numero_inventario = GREATEST(numero_inventario - 5, 0)
    WHERE id_especie = OLD.id_especie;
END //

DELIMITER ;