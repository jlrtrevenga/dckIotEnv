
-- Table: public.measures
-- DROP TABLE IF EXISTS public.measures;

CREATE TABLE IF NOT EXISTS public.measures
(
    device varchar(150) COLLATE pg_catalog."default",
    value real,
    timestamp_local timestamp without time zone
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.measures
    OWNER to postgres;



-- Señales de dispositivos: tablas message y signal

-- Tabla para recibir el mensaje del dispositivo si este está habilitado
-- payload puede ser de tipo json, ver mas adelante
CREATE TABLE IF NOT EXISTS public.message
(
    topic varchar(150) COLLATE pg_catalog."default" NOT NULL,
    payload varchar(500) COLLATE pg_catalog."default" NOT NULL,    
    processed boolean NOT NULL,
    timeEmission timestamp without time zone,
    timeReception timestamp without time zone
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.message
    OWNER to postgres;

-- Convertir el mensaje en datos de las señales correspondientes, decodificando el mensaje
CREATE TABLE IF NOT EXISTS public.signal
(
    deviceId varchar(16) COLLATE pg_catalog."default" NOT NULL,
    element varchar(16) COLLATE pg_catalog."default" NOT NULL,
    signal varchar(16) COLLATE pg_catalog."default" NOT NULL,
    value real COLLATE pg_catalog."default" NOT NULL,
    timeEmission timestamp without time zone,
    timeReception timestamp without time zone
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.measure
    OWNER to postgres;




-- Configuracion:
-- deviceType, asset, device, (element)

-- Señales asociadas a cada tipo/version de dispositivo
CREATE TABLE IF NOT EXISTS public.deviceType
(
    --deviceId varchar(16) COLLATE pg_catalog."default" NOT NULL,
    deviceType varchar(16) COLLATE pg_catalog."default" NOT NULL,
    deviceVersion varchar(16) COLLATE pg_catalog."default" NOT NULL,       
    elementSignal varchar(500) COLLATE pg_catalog."default" NOT NULL,    --Element/signal
    PRIMARY KEY(deviceType, deviceVersion, deviceSignal)
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.device
    OWNER to postgres;

INSERT INTO deviceType(deviceType, deviceVersion, elementSignal) VALUES ('heaterCnt', '01.01', 'room1/TempValue');
INSERT INTO deviceType(deviceType, deviceVersion, elementSignal) VALUES ('heaterCnt', '01.01', 'controller/tempSetpoint');  
INSERT INTO deviceType(deviceType, deviceVersion, elementSignal) VALUES ('heaterCnt', '01.01', 'controller/status');       --1/0 (ON/OFF)
INSERT INTO deviceType(deviceType, deviceVersion, elementSignal) VALUES ('heaterCnt', '01.01', 'controller/command');      --1/0 (ON/OFF)
INSERT INTO deviceType(deviceType, deviceVersion, elementSignal) VALUES ('heaterCnt', '01.01', 'heater/tempValue');  -- temperatura interna caldera
INSERT INTO deviceType(deviceType, deviceVersion, elementSignal) VALUES ('heaterCnt', '01.01', 'heater/status');     --1/0 (ON/OFF)



CREATE TABLE IF NOT EXISTS public.asset
(
    assetId varchar(16) COLLATE pg_catalog."default" NOT NULL,
    assetDescription varchar(100) COLLATE pg_catalog."default" NOT NULL,    
    PRIMARY KEY(assetId), 
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.asset
    OWNER to postgres;

INSERT INTO public.asset (assetId, assetDescription) 
    VALUES ('JLR01', 'Casa Madrid');



CREATE TABLE IF NOT EXISTS public.assetConfig
(
    assetId varchar(16) COLLATE pg_catalog."default" NOT NULL, 
    deviceId varchar(16) COLLATE pg_catalog."default" NOT NULL,   
    timeUpdate timestamp without time zone,
    PRIMARY KEY(assetId, deviceId), 
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.assetConfig
    OWNER to postgres;


INSERT INTO public.assetConfig (assetId, deviceId, timeUpdate) 
    VALUES ('JLR01', 'home5001', now);
INSERT INTO public.assetConfig (assetId, deviceId, timeUpdate) 
    VALUES ('JLR01', 'home5002', now);



CREATE TYPE devStatus AS ENUM ('preliminary', 'active', 'inactive', 'disabled');

-- Dispositivos predefinidos/activados/desactivados
CREATE TABLE IF NOT EXISTS public.device
(
    deviceId varchar(16) COLLATE pg_catalog."default" NOT NULL,
    deviceType varchar(16) COLLATE pg_catalog."default" NOT NULL,
    deviceVersion varchar(12) COLLATE pg_catalog."default" NOT NULL,       
    deviceStatus devStatus COLLATE pg_catalog."default" NOT NULL,    
    timeUpdate timestamp without time zone,
    PRIMARY KEY(deviceId, deviceType, deviceVersion)
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.device
    OWNER to postgres;

INSERT INTO public.device (deviceId, deviceType, deviceVersion, deviceStatus, timeUpdate) 
    VALUES ('home5001', 'heaterController', '01.01', 'active', now);
INSERT INTO public.device (deviceId, deviceType, deviceVersion, deviceStatus, timeUpdate) 
    VALUES ('home5001', 'heaterController', '01.01', 'active', now);



-- elementos: los distintos elementos monitorizados/controlados por un dispoistivo.
-- Ej: heater, controller, room1, etc.
/*
CREATE TABLE IF NOT EXISTS public.element
(
    deviceId varchar(16) COLLATE pg_catalog."default",    
    elementId varchar(16) COLLATE pg_catalog."default",
    elementDescription varchar(16) COLLATE pg_catalog."default"
    PRIMARY KEY(deviceId, elementId)
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.device
    OWNER to postgres;
*/






