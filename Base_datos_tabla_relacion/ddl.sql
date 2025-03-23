USE Los_Ambientales

-- Tabla 1: Entidades_Responsables
CREATE TABLE Entidades_Responsables (
    id_entidad INT PRIMARY KEY,
    nombre_entidad VARCHAR(100) NOT NULL
);

-- Tabla 2: Departamentos 
CREATE TABLE Departamentos (
    id_departamento INT PRIMARY KEY,
    nombre_departamento VARCHAR(100) NOT NULL,
    id_entidad_responsable INT NOT NULL,
    FOREIGN KEY (id_entidad_responsable) REFERENCES Entidades_Responsables(id_entidad)
);

-- Tabla 3: Parques_Naturales
CREATE TABLE Parques_Naturales (
    id_parque INT PRIMARY KEY,
    nombre_parque VARCHAR(100) NOT NULL,
    fecha_declaracion DATE NOT NULL
);

-- Tabla 4: Departamentos_Parques (relación muchos-a-muchos)
CREATE TABLE Departamentos_Parques (
    id_departamento INT,
    id_parque INT,
    PRIMARY KEY (id_departamento, id_parque),
    FOREIGN KEY (id_departamento) REFERENCES Departamentos(id_departamento),
    FOREIGN KEY (id_parque) REFERENCES Parques_Naturales(id_parque)
);

-- Tabla 5: Areas
CREATE TABLE Areas (
    id_area INT PRIMARY KEY,
    id_parque INT NOT NULL,
    nombre_area VARCHAR(100) NOT NULL,
    extension DECIMAL(10, 2) NOT NULL, -- En km², por ejemplo
    FOREIGN KEY (id_parque) REFERENCES Parques_Naturales(id_parque)
);

-- Tabla 6: Especies
CREATE TABLE Especies (
    id_especie INT PRIMARY KEY,
    denominacion_cientifica VARCHAR(100) NOT NULL UNIQUE,
    denominacion_vulgar VARCHAR(100),
    tipo ENUM('vegetal', 'animal', 'mineral') NOT NULL
);

-- Tabla 7: Inventario_Especies (relación muchos-a-muchos)
CREATE TABLE Inventario_Especies (
    id_area INT,
    id_especie INT,
    numero_inventario INT NOT NULL,
    PRIMARY KEY (id_area, id_especie),
    FOREIGN KEY (id_area) REFERENCES Areas(id_area),
    FOREIGN KEY (id_especie) REFERENCES Especies(id_especie)
);

-- Tabla 8: Personal
CREATE TABLE Personal (
    numero_cedula VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion TEXT,
    telefono_fijo VARCHAR(15),
    telefono_movil VARCHAR(15) NOT NULL,
    sueldo DECIMAL(10, 2) NOT NULL,
    tipo_personal ENUM('001', '002', '003', '004') NOT NULL
);

-- Tabla 9: Entradas (Personal de Gestión)
CREATE TABLE Entradas (
    id_entrada INT PRIMARY KEY,
    numero_cedula VARCHAR(20) NOT NULL,
    numero_registro INT NOT NULL,
    FOREIGN KEY (numero_cedula) REFERENCES Personal(numero_cedula)
);

-- Tabla 10: Vigilancia_Areas (Personal de Vigilancia)
CREATE TABLE Vigilancia_Areas (
    id_vigilancia INT PRIMARY KEY,
    numero_cedula VARCHAR(20) NOT NULL,
    id_area INT NOT NULL,
    tipo_vehiculo VARCHAR(50),
    marca_vehiculo VARCHAR(50),
    FOREIGN KEY (numero_cedula) REFERENCES Personal(numero_cedula),
    FOREIGN KEY (id_area) REFERENCES Areas(id_area)
);

-- Tabla 11: Conservacion_Areas (Personal de Conservación)
CREATE TABLE Conservacion_Areas (
    id_conservacion INT PRIMARY KEY,
    numero_cedula VARCHAR(20) NOT NULL,
    id_area INT NOT NULL,
    especialidad ENUM('limpieza', 'mantenimiento_caminos') NOT NULL,
    FOREIGN KEY (numero_cedula) REFERENCES Personal(numero_cedula),
    FOREIGN KEY (id_area) REFERENCES Areas(id_area)
);

-- Tabla 12: Proyectos_Investigacion
CREATE TABLE Proyectos_Investigacion (
    id_proyecto INT PRIMARY KEY,
    presupuesto DECIMAL(15, 2) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL
);

-- Tabla 13: Investigadores_Proyectos (relación muchos-a-muchos)
CREATE TABLE Investigadores_Proyectos (
    numero_cedula VARCHAR(20),
    id_proyecto INT,
    PRIMARY KEY (numero_cedula, id_proyecto),
    FOREIGN KEY (numero_cedula) REFERENCES Personal(numero_cedula),
    FOREIGN KEY (id_proyecto) REFERENCES Proyectos_Investigacion(id_proyecto)
);

-- Tabla 14: Proyectos_Especies (relación muchos-a-muchos)
CREATE TABLE Proyectos_Especies (
    id_proyecto INT,
    id_especie INT,
    PRIMARY KEY (id_proyecto, id_especie),
    FOREIGN KEY (id_proyecto) REFERENCES Proyectos_Investigacion(id_proyecto),
    FOREIGN KEY (id_especie) REFERENCES Especies(id_especie)
);

-- Tabla 15: Visitantes
CREATE TABLE Visitantes (
    cedula_visitante VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion TEXT,
    profesion VARCHAR(50)
);

-- Tabla 16: Alojamientos
CREATE TABLE Alojamientos (
    id_alojamiento INT PRIMARY KEY,
    id_parque INT NOT NULL,
    capacidad INT NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_parque) REFERENCES Parques_Naturales(id_parque)
);

-- Tabla 17: Visitantes_Alojamientos (relación muchos-a-muchos)
CREATE TABLE Visitantes_Alojamientos (
    cedula_visitante VARCHAR(20),
    id_alojamiento INT,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    PRIMARY KEY (cedula_visitante, id_alojamiento),
    FOREIGN KEY (cedula_visitante) REFERENCES Visitantes(cedula_visitante),
    FOREIGN KEY (id_alojamiento) REFERENCES Alojamientos(id_alojamiento)
);
