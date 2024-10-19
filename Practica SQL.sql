create schema if not exists cluna_videoclub;

set schema 'cluna_videoclub';

drop table socio CASCADE;

-- Crear la tabla Socio
CREATE TABLE socio (
    id_socio SERIAL PRIMARY KEY,
    dni VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido_1 VARCHAR(50) NOT NULL,
    apellido_2 VARCHAR(50),
    fecha_nacimiento DATE NOT NULL,
    telefono VARCHAR(50) NOT NULL,
    email VARCHAR(50)
);

drop table direccion CASCADE;
-- Crear la tabla Direccion
CREATE TABLE direccion (
    id_direccion SERIAL PRIMARY KEY,
    id_socio INTEGER REFERENCES cluna_videoclub.socio(id_socio),
    codigo_postal VARCHAR(5),
    calle VARCHAR(50) NOT NULL,
    numero VARCHAR(5) NOT NULL,
    piso VARCHAR(5),
    letra VARCHAR(1),
    ext VARCHAR(50)
);

drop table pelicula CASCADE;
-- Crear la tabla Pelicula
CREATE TABLE pelicula (
    id_pelicula SERIAL PRIMARY KEY,
    titulo VARCHAR(80) NOT NULL,
    genero VARCHAR(50) NOT NULL,
    sinopsis TEXT,
    director VARCHAR(80)
);

drop table copia CASCADE;
-- Crear la tabla Copia
CREATE TABLE copia (
    id_copia SERIAL PRIMARY KEY,
    id_pelicula INTEGER REFERENCES cluna_videoclub.pelicula(id_pelicula),
    fecha_alquiler DATE,
    fecha_devolucion DATE,
    id_socio INTEGER REFERENCES cluna_videoclub.socio(id_socio)
);

drop table tmp_videoclub CASCADE;
CREATE TABLE tmp_videoclub (
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
SELECT DISTINCT dni, nombre, apellido_1, apellido_2,cast(fecha_nacimiento as date), telefono, email
FROM tmp_videoclub;

-- Cargar datos en la tabla Direccion
INSERT INTO cluna_videoclub.direccion (id_socio, codigo_postal, calle, numero, piso, letra, ext)
SELECT s.id_socio, codigo_postal, calle, numero, piso, letra, ext
FROM tmp_videoclub t
JOIN cluna_videoclub.socio s ON t.dni = s.dni;

-- Cargar datos en la tabla Pelicula
INSERT INTO cluna_videoclub.pelicula (titulo, genero, sinopsis, director)
SELECT DISTINCT titulo, genero, sinopsis, director
FROM tmp_videoclub;

-- Cargar datos en la tabla Copia
INSERT INTO cluna_videoclub.copia (id_pelicula, fecha_alquiler, fecha_devolucion, id_socio)
SELECT p.id_pelicula, fecha_alquiler, fecha_devolucion, s.id_socio
FROM tmp_videoclub t
JOIN cluna_videoclub.pelicula p ON t.titulo = p.titulo
JOIN cluna_videoclub.socio s ON t.dni = s.dni;