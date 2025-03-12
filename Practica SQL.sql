create schema if not exists cluna_videoclub;

set schema 'cluna_videoclub';

--drop table socio CASCADE;

-- Crear la tabla Socio
CREATE TABLE IF NOT EXISTS socio (
    id_socio SERIAL PRIMARY KEY,
    dni VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido_1 VARCHAR(50) NOT NULL,
    apellido_2 VARCHAR(50),
    fecha_nacimiento DATE NOT NULL
);


-- Crear la tabla Telefono
CREATE TABLE IF NOT EXISTS telefono (
    id_telefono SERIAL PRIMARY KEY,
    id_socio INTEGER REFERENCES cluna_videoclub.socio(id_socio),
    numero VARCHAR(50) NOT NULL
);

-- Crear la tabla Email
CREATE TABLE IF NOT EXISTS email (
    id_email SERIAL PRIMARY KEY,
    id_socio INTEGER REFERENCES cluna_videoclub.socio(id_socio),
    direccion_email VARCHAR(50) NOT NULL
);

--drop table direccion CASCADE;
-- Crear la tabla Direccion
CREATE TABLE IF NOT EXISTS direccion (
    id_direccion SERIAL PRIMARY KEY,
    id_socio INTEGER REFERENCES cluna_videoclub.socio(id_socio),
    codigo_postal VARCHAR(5),
    calle VARCHAR(50) NOT NULL,
    numero VARCHAR(5) NOT NULL,
    piso VARCHAR(5),
    letra VARCHAR(1),
    ext VARCHAR(50)
);

--drop table genero CASCADE;
-- Crear la tabla Genero
CREATE TABLE IF NOT EXISTS genero (
    id_genero SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL
);


-- Crear la tabla Director
CREATE TABLE IF NOT EXISTS director (
    id_director SERIAL PRIMARY KEY,
    nombre VARCHAR(80) UNIQUE NOT NULL
);

--drop table pelicula CASCADE;
-- Crear la tabla Pelicula
CREATE TABLE IF NOT EXISTS pelicula (
    id_pelicula SERIAL PRIMARY KEY,
    titulo VARCHAR(80) NOT NULL,
    id_genero INTEGER REFERENCES cluna_videoclub.genero(id_genero),
    sinopsis TEXT,
    id_director INTEGER REFERENCES cluna_videoclub.director(id_director)
);

--drop table copia CASCADE;
-- Crear la tabla Copia
CREATE TABLE IF NOT EXISTS copia (
    id_copia SERIAL PRIMARY KEY,
    id_pelicula INTEGER REFERENCES cluna_videoclub.pelicula(id_pelicula)
);

--drop table prestamo CASCADE;
-- Crear la tabla Prestamo
CREATE TABLE IF NOT EXISTS prestamo (
    id_prestamo SERIAL PRIMARY KEY,
    id_copia INTEGER REFERENCES cluna_videoclub.copia(id_copia),
    id_socio INTEGER REFERENCES cluna_videoclub.socio(id_socio),
    fecha_alquiler DATE,
    fecha_devolucion DATE
);

--drop table tmp_videoclub CASCADE;
CREATE table IF NOT EXISTS tmp_videoclub (
	id_copia int4 NULL,
	fecha_alquiler_texto date NULL,
	dni varchar(50) NULL,
	nombre varchar(50) NULL,
	apellido_1 varchar(50) NULL,
	apellido_2 varchar(50) NULL,
	email varchar(50) NULL,
	telefono varchar(50) NULL,
	codigo_postal varchar(5) NULL,
	fecha_nacimiento varchar(50) NULL,
	numero varchar(5) NULL,
	piso varchar(5) NULL,
	letra varchar NULL,
	calle varchar NULL,
	ext varchar(50) NULL,
	titulo varchar(80) NULL,
	genero varchar(50) NULL,
	sinopsis text NULL,
	director varchar(80) NULL,
	fecha_alquiler date NULL,
	fecha_devolucion date NULL
);

-- Cargar datos en la tabla Socio
INSERT INTO cluna_videoclub.socio (dni, nombre, apellido_1, apellido_2, fecha_nacimiento, telefono, email)
SELECT DISTINCT dni, nombre, apellido_1, apellido_2, CAST(fecha_nacimiento AS DATE), telefono, email
FROM tmp_videoclub
ON CONFLICT (dni) DO NOTHING; -- Esto ignora si ya existe un DNI

-- Cargar datos en la tabla Telefono
INSERT INTO cluna_videoclub.telefono (id_socio, numero)
SELECT s.id_socio, t.telefono
FROM tmp_videoclub t
JOIN cluna_videoclub.socio s ON t.dni = s.dni;

-- Cargar datos en la tabla Email
INSERT INTO cluna_videoclub.email (id_socio, direccion_email)
SELECT s.id_socio, t.email
FROM tmp_videoclub t
JOIN cluna_videoclub.socio s ON t.dni = s.dni;

-- Cargar datos en la tabla Direccion
INSERT INTO cluna_videoclub.direccion (id_socio, codigo_postal, calle, numero, piso, letra, ext)
SELECT s.id_socio, t.codigo_postal, t.calle, t.numero, t.piso, t.letra, t.ext
FROM tmp_videoclub t
JOIN cluna_videoclub.socio s ON t.dni = s.dni;

-- Cargar datos en la tabla Genero
INSERT INTO cluna_videoclub.genero (nombre)
SELECT DISTINCT genero
FROM tmp_videoclub
ON CONFLICT (nombre) DO NOTHING;

-- Cargar datos en la tabla Director
INSERT INTO cluna_videoclub.director (nombre)
SELECT DISTINCT director
FROM tmp_videoclub
ON CONFLICT (nombre) DO NOTHING;

-- Cargar datos en la tabla Pelicula
INSERT INTO cluna_videoclub.pelicula (titulo, genero, sinopsis, director)
SELECT DISTINCT titulo, genero, sinopsis, director
FROM tmp_videoclub;

-- Cargar datos en la tabla Copia
INSERT INTO cluna_videoclub.copia (id_pelicula, fecha_alquiler, fecha_devolucion, id_socio)
SELECT p.id_pelicula, t.fecha_alquiler, t.fecha_devolucion, s.id_socio
FROM tmp_videoclub t
JOIN cluna_videoclub.pelicula p ON t.titulo = p.titulo
JOIN cluna_videoclub.socio s ON t.dni = s.dni;

-- Cargar datos en la tabla Prestamo
INSERT INTO cluna_videoclub.prestamo (id_copia, id_socio, fecha_alquiler, fecha_devolucion)
SELECT c.id_copia, s.id_socio, t.fecha_alquiler, t.fecha_devolucion
FROM tmp_videoclub t
JOIN cluna_videoclub.copia c ON t.id_copia = c.id_copia
JOIN cluna_videoclub.socio s ON t.dni = s.dni;