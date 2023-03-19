

-- DROP DATABASE IF EXISTS iotdb;
-- DROP SCHEMA IF EXISTS iot CASCADE;

CREATE DATABASE iotdb
    WITH
    OWNER = eng01
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

--CREATE SCHEMA iot;
CREATE SCHEMA IF NOT EXISTS iot;


---------------------------------------------
-- tablas de mensajes recibidos
-- payload puede ser de tipo json, ver mas adelante
--------------------------------------------- 


CREATE TABLE IF NOT EXISTS iot.measures
(
    measure varchar(500) COLLATE pg_catalog."default" NOT NULL,
    value real,
    timestamp_local timestamp without time zone
)
TABLESPACE pg_default;


CREATE TABLE IF NOT EXISTS iot.message
(
    topic varchar(150) COLLATE pg_catalog."default" NOT NULL,
    payload varchar(500) COLLATE pg_catalog."default" NOT NULL,    
    processed boolean NOT NULL,
    timeEmission timestamp without time zone,
    timeReception timestamp without time zone
)
TABLESPACE pg_default;


---------------------------------------------
-- modelo de datos
---------------------------------------------

-- Convertir el mensaje en datos de las señales correspondientes, decodificando el mensaje
CREATE TABLE IF NOT EXISTS iot.signal
(
    deviceId varchar(16) COLLATE pg_catalog."default" NOT NULL,
    element varchar(16) COLLATE pg_catalog."default" NOT NULL,
    signal varchar(60) COLLATE pg_catalog."default" NOT NULL,
    value real,
    timeEmission timestamp without time zone,
    timeReception timestamp without time zone
)
TABLESPACE pg_default;


-- Señales asociadas a cada tipo/version de dispositivo
CREATE TABLE IF NOT EXISTS iot.deviceModel
(
    deviceType varchar(16) COLLATE pg_catalog."default" NOT NULL,
    deviceVersion varchar(16) COLLATE pg_catalog."default" NOT NULL,       
    elementSignal varchar(500) COLLATE pg_catalog."default" NOT NULL,    --Element/signal
    PRIMARY KEY(deviceType, deviceVersion, elementSignal)
)
TABLESPACE pg_default;


CREATE TABLE IF NOT EXISTS iot.asset
(
    assetId varchar(16) COLLATE pg_catalog."default" NOT NULL,
    assetDescription varchar(100) COLLATE pg_catalog."default" NOT NULL,    
    PRIMARY KEY(assetId) 
)
TABLESPACE pg_default;

CREATE TYPE devStatus AS ENUM ('preliminary', 'active', 'inactive', 'disabled');

-- Dispositivos predefinidos/activados/desactivados
CREATE TABLE IF NOT EXISTS iot.device
(
    deviceId varchar(16) COLLATE pg_catalog."default" NOT NULL,
    deviceType varchar(16) COLLATE pg_catalog."default" NOT NULL,
    deviceVersion varchar(12) COLLATE pg_catalog."default" NOT NULL,           
    deviceStatus devStatus NOT NULL,    
    timeUpdate timestamp without time zone,
    PRIMARY KEY(deviceId)
)
TABLESPACE pg_default;


CREATE TABLE IF NOT EXISTS iot.assetModel
(
    assetId varchar(16),
    deviceId varchar(16),     
    timeUpdate timestamp without time zone,
    CONSTRAINT fk_assetId 
        FOREIGN KEY(assetId)
            REFERENCES iot.asset(assetId)
            ON DELETE SET NULL,
    CONSTRAINT fk_deviceId 
        FOREIGN KEY(deviceId)
            REFERENCES iot.device(deviceId)
            ON DELETE SET NULL
)
TABLESPACE pg_default;


---------------------------------------------
-- datos iniciales
---------------------------------------------

-- create deviceModels
INSERT INTO iot.deviceModel(deviceType, deviceVersion, elementSignal) VALUES ('heaterController', '01.01', 'room1/temperatureVal');
INSERT INTO iot.deviceModel(deviceType, deviceVersion, elementSignal) VALUES ('heaterController', '01.01', 'controller/temperatureSp');     --1/0 (ON/OFF)  
INSERT INTO iot.deviceModel(deviceType, deviceVersion, elementSignal) VALUES ('heaterController', '01.01', 'heater/run_cmd');               --1/0 (ON/OFF)
INSERT INTO iot.deviceModel(deviceType, deviceVersion, elementSignal) VALUES ('heaterController', '01.01', 'heater/run_status');            --1/0 (ON/OFF)

-- Create assets
INSERT INTO iot.asset (assetId, assetDescription) 
    VALUES ('JLR01', 'Casa Madrid');

-- Create devices, its type and status
INSERT INTO iot.device (deviceId, deviceType, deviceVersion, deviceStatus, timeUpdate) 
    VALUES ('home5001', 'heaterController', '01.01', 'active', now());
INSERT INTO iot.device (deviceId, deviceType, deviceVersion, deviceStatus, timeUpdate) 
    VALUES ('home5002', 'heaterController', '01.01', 'active', now());

-- Create Asset Model (Link devices to assets)
INSERT INTO iot.assetModel (deviceId, assetId, timeUpdate) 
    VALUES ('home5001','JLR01', now());
INSERT INTO iot.assetModel (deviceId, assetId, timeUpdate) 
    VALUES ('home5002','JLR01', now());



-- Create roles, users, database and schema

CREATE ROLE radmin WITH
  NOLOGIN SUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;

CREATE ROLE reng WITH
  NOLOGIN NOSUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;

CREATE ROLE ruser WITH
  NOLOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

CREATE ROLE readuser WITH
  NOLOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;


--CREATE USER admin01;      
-- Este usuario está definido en el contenedor dbsrv01, es el creador de la BB.DD. al instanciarla por primera vez.
-- Habría que cambiarlo tras crearla.

CREATE USER eng01 PASSWORD 'eng01';
CREATE USER user01 PASSWORD 'user01';
CREATE USER user02 PASSWORD 'user02';
CREATE USER user03 PASSWORD 'user03';
CREATE USER grafana01 PASSWORD 'grafana01';


GRANT ALL ON SCHEMA "iot" to reng;
GRANT ALL ON SCHEMA "iot" to readuser;
GRANT ALL ON SCHEMA "iot" to ruser;

GRANT ALL ON ALL TABLES IN SCHEMA "iot" to reng;
GRANT SELECT ON ALL TABLES IN SCHEMA "iot" to readuser;
GRANT SELECT ON ALL TABLES IN SCHEMA "iot" to ruser;
GRANT INSERT ON iot.measures, iot.message, iot.signal TO ruser;


--GRANT radmin TO admin01;
GRANT reng TO eng01;
GRANT ruser TO user01;
GRANT ruser TO user02;
GRANT ruser TO user03;
GRANT readuser TO grafana01;


ALTER USER eng01 IN DATABASE "iotdb" SET SEARCH_PATH = 'iot';
ALTER USER user01 IN DATABASE "iotdb" SET SEARCH_PATH = 'iot';
ALTER USER user02 IN DATABASE "iotdb" SET SEARCH_PATH = 'iot';
ALTER USER user03 IN DATABASE "iotdb" SET SEARCH_PATH = 'iot';
ALTER USER grafana01 IN DATABASE "iotdb" SET SEARCH_PATH = 'iot';


