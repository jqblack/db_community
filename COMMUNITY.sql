--
-- PostgreSQL database dump
--

-- Dumped from database version 10.11
-- Dumped by pg_dump version 10.1

-- Started on 2021-04-20 23:53:53

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 12924)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 3274 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 267 (class 1255 OID 163855)
-- Name: CambiarRolesInquilinos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "CambiarRolesInquilinos"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO 
  public."Roles"
(
  "idUsuario",
  "idTipo",
  "ID_residencial"
)
VALUES (
  NEW."ID_usuario",
  2,
  NEW."idResidencial"
);
 UPDATE 
  public."Departamentos" 
SET 

  "Disponible" = FALSE

WHERE 
  "ID_departamento" = NEW."ID_deparamento"
; 
RETURN NEW;
END;
$$;


ALTER FUNCTION public."CambiarRolesInquilinos"() OWNER TO postgres;

--
-- TOC entry 281 (class 1255 OID 155664)
-- Name: CargoQuejas(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "CargoQuejas"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
MyCantidadAdv INTEGER;
CantidadUser INTEGER;
MontoQuejas INTEGER;

BEGIN
MyCantidadAdv = (SELECT TQ."CantAdvertencia" FROM PUBLIC."TipoQuejas" AS TQ WHERE TQ."ID_TipoQuejas" = NEW."id_TipoQueja");

CantidadUser = (SELECT count(*) AS CANT FROM PUBLIC."historialQuejas" AS HQ WHERE 
HQ."ID_usuarioTo" = NEW."ID_usuarioTo" AND HQ."id_TipoQueja" = NEW."id_TipoQueja");

  IF CantidadUser >= MyCantidadAdv THEN
  
  	MontoQuejas = (SELECT TQ."CostoPenalizacion" FROM PUBLIC."TipoQuejas" AS TQ WHERE TQ."ID_TipoQuejas" = NEW."id_TipoQueja");
  
    INSERT INTO 
  	public."CuentaPorCobrar"
	(
  	"Idusuario",
  	"IdReferencia",
  	"IdTipoCuentaxCobrar",
  	monto,
 	pagado
	)
	VALUES (
  	NEW."ID_usuarioTo",
  	NEW."id_TipoQueja",
  	2,
  	MontoQuejas,
  	FALSE
	); 

  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION public."CargoQuejas"() OWNER TO postgres;

--
-- TOC entry 266 (class 1255 OID 172047)
-- Name: EntrarCliente(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "EntrarCliente"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO 
  public."Roles"
(
  "idUsuario",
  "idTipo",
  "ID_residencial"
)
VALUES (
  NEW."idUsuario",
  4,
  NEW."idResidencial"
);
RETURN NEW;
END;
$$;


ALTER FUNCTION public."EntrarCliente"() OWNER TO postgres;

--
-- TOC entry 280 (class 1255 OID 180282)
-- Name: LogQuejas(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "LogQuejas"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW."idStatus" = 1 THEN
  	INSERT INTO 
  public."QuejasLog"
(
  "ID_Queja",
  "ID_usuarioFrom",
  "ID_usuarioTo",
  "FechaQueja",
  "ID_EstadoQuejas",
  "Descripcion",
  "DescripcionLog",
  "currentDate",
  "id_usuarioLog"
)
VALUES (
  NEW."ID_Quejas",
  NEW."ID_usuarioFrom",
  NEW."ID_usuarioTo",
  NEW."currentDate",
  1,
  NEW."Descripcion",
  'HA CREADO UNA QUEJA',
  now(),
  NEW."idModifiedby"
);
ELSIF NEW."idStatus" = 2 THEN
 INSERT INTO 
  public."QuejasLog"
(
  "ID_Queja",
  "ID_usuarioFrom",
  "ID_usuarioTo",
  "FechaQueja",
  "ID_EstadoQuejas",
  "Descripcion",
  "DescripcionLog",
  "currentDate",
  "id_usuarioLog"
)
VALUES (
  NEW."ID_Quejas",
  NEW."ID_usuarioFrom",
  NEW."ID_usuarioTo",
  NEW."currentDate",
  2,
  NEW."Descripcion",
  'HA APROBADO UNA QUEJA',
  now(),
  NEW."idModifiedby"
);

ELSE
INSERT INTO 
  public."QuejasLog"
(
  "ID_Queja",
  "ID_usuarioFrom",
  "ID_usuarioTo",
  "FechaQueja",
  "ID_EstadoQuejas",
  "Descripcion",
  "DescripcionLog",
  "currentDate",
  "id_usuarioLog"
)
VALUES (
  NEW."ID_Quejas",
  NEW."ID_usuarioFrom",
  NEW."ID_usuarioTo",
  NEW."currentDate",
  2,
  NEW."Descripcion",
  'HA DENEGADO UNA QUEJA',
  now(),
  NEW."idModifiedby"
);
END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public."LogQuejas"() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 217 (class 1259 OID 91169)
-- Name: AreaComunesvsResidencial; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "AreaComunesvsResidencial" (
    "ID_areaComunes" integer NOT NULL,
    "ID_residencial" integer NOT NULL
);


ALTER TABLE "AreaComunesvsResidencial" OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 91183)
-- Name: AreaComunpendientesbyUsuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "AreaComunpendientesbyUsuarios" (
    id_areacomun integer NOT NULL,
    "fehcaAsignamiento" date DEFAULT now(),
    "idUsuario" integer NOT NULL,
    "idMantenimiento" integer NOT NULL,
    activo boolean DEFAULT true,
    "numMantenimiento" integer NOT NULL
);


ALTER TABLE "AreaComunpendientesbyUsuarios" OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 147467)
-- Name: AreaComunpendientesbyUsuarios_numMantenimiento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "AreaComunpendientesbyUsuarios_numMantenimiento_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "AreaComunpendientesbyUsuarios_numMantenimiento_seq" OWNER TO postgres;

--
-- TOC entry 3275 (class 0 OID 0)
-- Dependencies: 259
-- Name: AreaComunpendientesbyUsuarios_numMantenimiento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "AreaComunpendientesbyUsuarios_numMantenimiento_seq" OWNED BY "AreaComunpendientesbyUsuarios"."numMantenimiento";


--
-- TOC entry 216 (class 1259 OID 91164)
-- Name: AreasComunes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "AreasComunes" (
    "ID_areaComunes" integer DEFAULT nextval(('public.areascomunes_id_areacomunes_seq'::text)::regclass) NOT NULL,
    descripcion character varying(100),
    activo boolean DEFAULT true NOT NULL,
    nombre character varying(30)
);


ALTER TABLE "AreasComunes" OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 91172)
-- Name: AreasComunesVsMantenimientos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "AreasComunesVsMantenimientos" (
    id_areacomun integer NOT NULL,
    "id_TipoMantenimiento" integer NOT NULL,
    "idUsuarioDefault" integer NOT NULL,
    "fechaProgramada" date NOT NULL
);


ALTER TABLE "AreasComunesVsMantenimientos" OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 91115)
-- Name: Calificacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Calificacion" (
    "ID_usuario" integer NOT NULL,
    "ID_departamento" integer NOT NULL,
    "Calificacion" double precision,
    descripcion character varying,
    fecha date
);


ALTER TABLE "Calificacion" OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 91075)
-- Name: CuentaPorCobrar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "CuentaPorCobrar" (
    "Idusuario" integer NOT NULL,
    "IdReferencia" integer NOT NULL,
    "IdTipoCuentaxCobrar" integer NOT NULL,
    fecha timestamp(0) without time zone DEFAULT now() NOT NULL,
    monto double precision,
    pagado boolean DEFAULT false
);


ALTER TABLE "CuentaPorCobrar" OWNER TO postgres;

--
-- TOC entry 260 (class 1259 OID 163849)
-- Name: DepartamentoVSFoto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "DepartamentoVSFoto" (
    "idDepartamento" integer NOT NULL,
    imagen character varying
);
ALTER TABLE ONLY "DepartamentoVSFoto" ALTER COLUMN "idDepartamento" SET STATISTICS 0;
ALTER TABLE ONLY "DepartamentoVSFoto" ALTER COLUMN imagen SET STATISTICS 0;


ALTER TABLE "DepartamentoVSFoto" OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 98339)
-- Name: DepartamentoVsServicos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "DepartamentoVsServicos" (
    "ID_servicio" integer,
    "ID_Departamento" integer
);


ALTER TABLE "DepartamentoVsServicos" OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 91278)
-- Name: Departamentos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Departamentos" (
    "ID_departamento" integer NOT NULL,
    "ID_torre" integer NOT NULL,
    "Nombre_departamento" character varying(50),
    "Disponible" boolean DEFAULT true,
    "PrecioVenta" double precision,
    "PrecioAlquiler" double precision,
    "VentaDisponible" boolean,
    "cantidadBath" integer DEFAULT 1,
    canthabitaciones integer DEFAULT 1,
    "isAmueblado" boolean DEFAULT false,
    image character varying
);


ALTER TABLE "Departamentos" OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 91276)
-- Name: Departamentos_ID_departamento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Departamentos_ID_departamento_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Departamentos_ID_departamento_seq" OWNER TO postgres;

--
-- TOC entry 3276 (class 0 OID 0)
-- Dependencies: 241
-- Name: Departamentos_ID_departamento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Departamentos_ID_departamento_seq" OWNED BY "Departamentos"."ID_departamento";


--
-- TOC entry 226 (class 1259 OID 91207)
-- Name: DirigidoQueja; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "DirigidoQueja" (
    "ID_dirigido" integer NOT NULL,
    "Descripcion" character varying
);


ALTER TABLE "DirigidoQueja" OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 91205)
-- Name: DirigidoQueja_ID_dirigido_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "DirigidoQueja_ID_dirigido_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "DirigidoQueja_ID_dirigido_seq" OWNER TO postgres;

--
-- TOC entry 3277 (class 0 OID 0)
-- Dependencies: 225
-- Name: DirigidoQueja_ID_dirigido_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "DirigidoQueja_ID_dirigido_seq" OWNED BY "DirigidoQueja"."ID_dirigido";


--
-- TOC entry 257 (class 1259 OID 139273)
-- Name: EmpleadosvsResidencial; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "EmpleadosvsResidencial" (
    "idUsuario" integer NOT NULL,
    "idResidencial" integer NOT NULL,
    "FechaIngreso" date DEFAULT now(),
    activo boolean DEFAULT true
);
ALTER TABLE ONLY "EmpleadosvsResidencial" ALTER COLUMN "idUsuario" SET STATISTICS 0;
ALTER TABLE ONLY "EmpleadosvsResidencial" ALTER COLUMN "idResidencial" SET STATISTICS 0;
ALTER TABLE ONLY "EmpleadosvsResidencial" ALTER COLUMN "FechaIngreso" SET STATISTICS 0;


ALTER TABLE "EmpleadosvsResidencial" OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 91226)
-- Name: EstadosQuejas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "EstadosQuejas" (
    "ID_EstadoQuejas" integer NOT NULL,
    "descripcionEstado" character varying(30)
);


ALTER TABLE "EstadosQuejas" OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 91224)
-- Name: EstadosQuejas_ID_EstadoQuejas_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "EstadosQuejas_ID_EstadoQuejas_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "EstadosQuejas_ID_EstadoQuejas_seq" OWNER TO postgres;

--
-- TOC entry 3278 (class 0 OID 0)
-- Dependencies: 229
-- Name: EstadosQuejas_ID_EstadoQuejas_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "EstadosQuejas_ID_EstadoQuejas_seq" OWNED BY "EstadosQuejas"."ID_EstadoQuejas";


--
-- TOC entry 222 (class 1259 OID 91194)
-- Name: HistorialMantenimiento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "HistorialMantenimiento" (
    id_areacomun integer NOT NULL,
    "fehcaAsignamiento" date,
    "fechaCompletada" date,
    "idUsuario" integer NOT NULL
);


ALTER TABLE "HistorialMantenimiento" OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 91289)
-- Name: Inquilino; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Inquilino" (
    "ID_usuario" integer NOT NULL,
    "ID_deparamento" integer NOT NULL,
    "Nombre_departamento" character varying(50),
    "idResidencial" integer NOT NULL,
    "fechaIngreso" date DEFAULT now(),
    "idPersona" integer NOT NULL
);


ALTER TABLE "Inquilino" OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 91177)
-- Name: MantenimientoArea; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "MantenimientoArea" (
    "ID_TipoMantenimiento" integer NOT NULL,
    "Descripcion" character varying(50),
    "cantidadDias" integer
);


ALTER TABLE "MantenimientoArea" OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 91175)
-- Name: MantenimientoArea_ID_TipoMantenimiento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "MantenimientoArea_ID_TipoMantenimiento_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "MantenimientoArea_ID_TipoMantenimiento_seq" OWNER TO postgres;

--
-- TOC entry 3279 (class 0 OID 0)
-- Dependencies: 219
-- Name: MantenimientoArea_ID_TipoMantenimiento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "MantenimientoArea_ID_TipoMantenimiento_seq" OWNED BY "MantenimientoArea"."ID_TipoMantenimiento";


--
-- TOC entry 252 (class 1259 OID 98318)
-- Name: MantenimientovsResidencial; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "MantenimientovsResidencial" (
    "idMatenimiento" integer NOT NULL,
    "idResidencial" integer NOT NULL
);
ALTER TABLE ONLY "MantenimientovsResidencial" ALTER COLUMN "idMatenimiento" SET STATISTICS 0;
ALTER TABLE ONLY "MantenimientovsResidencial" ALTER COLUMN "idResidencial" SET STATISTICS 0;


ALTER TABLE "MantenimientovsResidencial" OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 91302)
-- Name: Municipio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Municipio" (
    "ID_municipio" integer NOT NULL,
    "ID_Provincia" integer NOT NULL,
    descripcion character varying(50)
);


ALTER TABLE "Municipio" OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 91300)
-- Name: Municipio_ID_municipio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Municipio_ID_municipio_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Municipio_ID_municipio_seq" OWNER TO postgres;

--
-- TOC entry 3280 (class 0 OID 0)
-- Dependencies: 246
-- Name: Municipio_ID_municipio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Municipio_ID_municipio_seq" OWNED BY "Municipio"."ID_municipio";


--
-- TOC entry 205 (class 1259 OID 91112)
-- Name: NumeroCuenta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "NumeroCuenta" (
    "NumeroCuenta" integer,
    "ID_usuario" integer
);


ALTER TABLE "NumeroCuenta" OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 91273)
-- Name: OwnersVsResidencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "OwnersVsResidencia" (
    "ID_usuario" integer NOT NULL,
    "Id_residencial" integer NOT NULL
);


ALTER TABLE "OwnersVsResidencia" OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 91139)
-- Name: Permisos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Permisos" (
    "idPermiso" integer NOT NULL,
    permiso character varying
);


ALTER TABLE "Permisos" OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 91137)
-- Name: Permisos_idPermiso_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Permisos_idPermiso_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Permisos_idPermiso_seq" OWNER TO postgres;

--
-- TOC entry 3281 (class 0 OID 0)
-- Dependencies: 210
-- Name: Permisos_idPermiso_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Permisos_idPermiso_seq" OWNED BY "Permisos"."idPermiso";


--
-- TOC entry 197 (class 1259 OID 91069)
-- Name: Persona; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Persona" (
    "IdPersona" integer NOT NULL,
    "Nombre" character varying(50),
    "Apellido" character varying(120),
    "ID_Sexo" integer NOT NULL,
    celular character varying(20)
);


ALTER TABLE "Persona" OWNER TO postgres;

--
-- TOC entry 196 (class 1259 OID 91067)
-- Name: Persona_IdPersona_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Persona_IdPersona_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Persona_IdPersona_seq" OWNER TO postgres;

--
-- TOC entry 3282 (class 0 OID 0)
-- Dependencies: 196
-- Name: Persona_IdPersona_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Persona_IdPersona_seq" OWNED BY "Persona"."IdPersona";


--
-- TOC entry 245 (class 1259 OID 91294)
-- Name: Provincia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Provincia" (
    "ID_provincia" integer NOT NULL,
    descripcion character varying(50)
);


ALTER TABLE "Provincia" OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 91292)
-- Name: Provincia_ID_provincia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Provincia_ID_provincia_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Provincia_ID_provincia_seq" OWNER TO postgres;

--
-- TOC entry 3283 (class 0 OID 0)
-- Dependencies: 244
-- Name: Provincia_ID_provincia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Provincia_ID_provincia_seq" OWNED BY "Provincia"."ID_provincia";


--
-- TOC entry 228 (class 1259 OID 91221)
-- Name: QuejasLog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "QuejasLog" (
    "ID_Queja" integer,
    "ID_usuarioFrom" integer NOT NULL,
    "ID_usuarioTo" integer NOT NULL,
    "FechaQueja" timestamp without time zone,
    "ID_EstadoQuejas" integer NOT NULL,
    "Descripcion" character varying(200),
    "DescripcionLog" character varying(100),
    "currentDate" timestamp without time zone,
    "id_usuarioLog" integer NOT NULL
);


ALTER TABLE "QuejasLog" OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 91237)
-- Name: Residencial; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Residencial" (
    "ID_residencial" integer NOT NULL,
    nombre character varying(50),
    "ID_provincia" integer NOT NULL,
    "ID_municipio" integer NOT NULL,
    "ID_sector" integer NOT NULL,
    areacuadrada integer,
    "MinimoVenta" double precision,
    "MinimoAlquiler" double precision,
    "ID_status" integer NOT NULL,
    "imgPortada" character varying DEFAULT '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'::character varying
);


ALTER TABLE "Residencial" OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 91235)
-- Name: Residencial_ID_residencial_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Residencial_ID_residencial_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Residencial_ID_residencial_seq" OWNER TO postgres;

--
-- TOC entry 3284 (class 0 OID 0)
-- Dependencies: 232
-- Name: Residencial_ID_residencial_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Residencial_ID_residencial_seq" OWNED BY "Residencial"."ID_residencial";


--
-- TOC entry 203 (class 1259 OID 91099)
-- Name: Roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Roles" (
    "idUsuario" integer NOT NULL,
    "idTipo" integer NOT NULL,
    "ID_residencial" integer NOT NULL
);


ALTER TABLE "Roles" OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 91310)
-- Name: Sector; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Sector" (
    "ID_sector" integer NOT NULL,
    "ID_Municipio" integer NOT NULL,
    descripcion character varying(50)
);


ALTER TABLE "Sector" OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 91308)
-- Name: Sector_ID_sector_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Sector_ID_sector_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Sector_ID_sector_seq" OWNER TO postgres;

--
-- TOC entry 3285 (class 0 OID 0)
-- Dependencies: 248
-- Name: Sector_ID_sector_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Sector_ID_sector_seq" OWNED BY "Sector"."ID_sector";


--
-- TOC entry 202 (class 1259 OID 91090)
-- Name: Servicios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Servicios" (
    "ID_servicio" integer NOT NULL,
    "Descripcion" character varying,
    cobro double precision,
    pago double precision,
    "idResidencial" integer NOT NULL
);


ALTER TABLE "Servicios" OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 180247)
-- Name: ServiciosPredeterminados; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "ServiciosPredeterminados" (
    "idTipopredeterminado" integer NOT NULL,
    "idServicio" integer NOT NULL
);
ALTER TABLE ONLY "ServiciosPredeterminados" ALTER COLUMN "idTipopredeterminado" SET STATISTICS 0;
ALTER TABLE ONLY "ServiciosPredeterminados" ALTER COLUMN "idServicio" SET STATISTICS 0;


ALTER TABLE "ServiciosPredeterminados" OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 91088)
-- Name: Servicios_ID_servicio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Servicios_ID_servicio_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Servicios_ID_servicio_seq" OWNER TO postgres;

--
-- TOC entry 3286 (class 0 OID 0)
-- Dependencies: 201
-- Name: Servicios_ID_servicio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Servicios_ID_servicio_seq" OWNED BY "Servicios"."ID_servicio";


--
-- TOC entry 231 (class 1259 OID 91232)
-- Name: SolicitudCompra; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "SolicitudCompra" (
    "ID_usuario" integer NOT NULL,
    fecha date DEFAULT now() NOT NULL,
    "ID_departamento" integer NOT NULL,
    "idResidencial" integer NOT NULL,
    "isCompra" boolean DEFAULT false,
    "Activo" boolean DEFAULT true
);


ALTER TABLE "SolicitudCompra" OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 139300)
-- Name: SolicitudEmpleados; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "SolicitudEmpleados" (
    "idUser" integer NOT NULL,
    "idResidencial" integer NOT NULL,
    fecha date DEFAULT now(),
    activo boolean DEFAULT true
);
ALTER TABLE ONLY "SolicitudEmpleados" ALTER COLUMN "idUser" SET STATISTICS 0;
ALTER TABLE ONLY "SolicitudEmpleados" ALTER COLUMN "idResidencial" SET STATISTICS 0;
ALTER TABLE ONLY "SolicitudEmpleados" ALTER COLUMN fecha SET STATISTICS 0;
ALTER TABLE ONLY "SolicitudEmpleados" ALTER COLUMN activo SET STATISTICS 0;


ALTER TABLE "SolicitudEmpleados" OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 180265)
-- Name: StatusQuejas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "StatusQuejas" (
    id integer NOT NULL,
    "Descripcion" character varying(20)
);
ALTER TABLE ONLY "StatusQuejas" ALTER COLUMN id SET STATISTICS 0;
ALTER TABLE ONLY "StatusQuejas" ALTER COLUMN "Descripcion" SET STATISTICS 0;


ALTER TABLE "StatusQuejas" OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 180263)
-- Name: StatusQuejas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "StatusQuejas_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "StatusQuejas_id_seq" OWNER TO postgres;

--
-- TOC entry 3287 (class 0 OID 0)
-- Dependencies: 264
-- Name: StatusQuejas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "StatusQuejas_id_seq" OWNED BY "StatusQuejas".id;


--
-- TOC entry 235 (class 1259 OID 91245)
-- Name: StatusResidencial; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "StatusResidencial" (
    "ID" integer NOT NULL,
    "Descripcion" character varying(20)
);


ALTER TABLE "StatusResidencial" OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 91243)
-- Name: StatusResidencial_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "StatusResidencial_ID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "StatusResidencial_ID_seq" OWNER TO postgres;

--
-- TOC entry 3288 (class 0 OID 0)
-- Dependencies: 234
-- Name: StatusResidencial_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "StatusResidencial_ID_seq" OWNED BY "StatusResidencial"."ID";


--
-- TOC entry 215 (class 1259 OID 91158)
-- Name: Status_usuarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Status_usuarios" (
    "ID_status" integer NOT NULL,
    "Descripcion" character varying(50)
);


ALTER TABLE "Status_usuarios" OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 91156)
-- Name: Status_usuarios_ID_status_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Status_usuarios_ID_status_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Status_usuarios_ID_status_seq" OWNER TO postgres;

--
-- TOC entry 3289 (class 0 OID 0)
-- Dependencies: 214
-- Name: Status_usuarios_ID_status_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Status_usuarios_ID_status_seq" OWNED BY "Status_usuarios"."ID_status";


--
-- TOC entry 200 (class 1259 OID 91082)
-- Name: TipoCuentaCobrar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "TipoCuentaCobrar" (
    "ID" integer NOT NULL,
    "Descripcion" character varying(50)
);


ALTER TABLE "TipoCuentaCobrar" OWNER TO postgres;

--
-- TOC entry 199 (class 1259 OID 91080)
-- Name: TipoCuentaCobrar_ID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "TipoCuentaCobrar_ID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "TipoCuentaCobrar_ID_seq" OWNER TO postgres;

--
-- TOC entry 3290 (class 0 OID 0)
-- Dependencies: 199
-- Name: TipoCuentaCobrar_ID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "TipoCuentaCobrar_ID_seq" OWNED BY "TipoCuentaCobrar"."ID";


--
-- TOC entry 262 (class 1259 OID 180235)
-- Name: TipoPredeterminadoserivios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "TipoPredeterminadoserivios" (
    numserial integer NOT NULL,
    tipo character varying(30) NOT NULL,
    "idResidencial" integer NOT NULL,
    fecha date DEFAULT now()
);
ALTER TABLE ONLY "TipoPredeterminadoserivios" ALTER COLUMN numserial SET STATISTICS 0;
ALTER TABLE ONLY "TipoPredeterminadoserivios" ALTER COLUMN tipo SET STATISTICS 0;
ALTER TABLE ONLY "TipoPredeterminadoserivios" ALTER COLUMN "idResidencial" SET STATISTICS 0;
ALTER TABLE ONLY "TipoPredeterminadoserivios" ALTER COLUMN fecha SET STATISTICS 0;


ALTER TABLE "TipoPredeterminadoserivios" OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 180233)
-- Name: TipoPredeterminadoserivios_numserial_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "TipoPredeterminadoserivios_numserial_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "TipoPredeterminadoserivios_numserial_seq" OWNER TO postgres;

--
-- TOC entry 3291 (class 0 OID 0)
-- Dependencies: 261
-- Name: TipoPredeterminadoserivios_numserial_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "TipoPredeterminadoserivios_numserial_seq" OWNED BY "TipoPredeterminadoserivios".numserial;


--
-- TOC entry 224 (class 1259 OID 91199)
-- Name: TipoQuejas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "TipoQuejas" (
    "ID_TipoQuejas" integer NOT NULL,
    "Descripcion" character varying(50),
    "CantAdvertencia" integer,
    "LimitePenalizacion" integer,
    "CostoPenalizacion" double precision,
    "ID_dirigido" integer,
    "idResidencial" integer NOT NULL
);


ALTER TABLE "TipoQuejas" OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 91197)
-- Name: TipoQuejas_ID_TipoQuejas_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "TipoQuejas_ID_TipoQuejas_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "TipoQuejas_ID_TipoQuejas_seq" OWNER TO postgres;

--
-- TOC entry 3292 (class 0 OID 0)
-- Dependencies: 223
-- Name: TipoQuejas_ID_TipoQuejas_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "TipoQuejas_ID_TipoQuejas_seq" OWNED BY "TipoQuejas"."ID_TipoQuejas";


--
-- TOC entry 208 (class 1259 OID 91125)
-- Name: TipoUsuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "TipoUsuario" (
    "idTipoUsuario" integer NOT NULL,
    tipo character varying
);


ALTER TABLE "TipoUsuario" OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 91134)
-- Name: TipoUsuarioVSPermisos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "TipoUsuarioVSPermisos" (
    "idTipoUsuario" integer NOT NULL,
    "idPermiso" integer NOT NULL
);


ALTER TABLE "TipoUsuarioVSPermisos" OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 91123)
-- Name: TipoUsuario_idTipoUsuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "TipoUsuario_idTipoUsuario_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "TipoUsuario_idTipoUsuario_seq" OWNER TO postgres;

--
-- TOC entry 3293 (class 0 OID 0)
-- Dependencies: 207
-- Name: TipoUsuario_idTipoUsuario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "TipoUsuario_idTipoUsuario_seq" OWNED BY "TipoUsuario"."idTipoUsuario";


--
-- TOC entry 237 (class 1259 OID 91253)
-- Name: Torre; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Torre" (
    "ID_torre" integer NOT NULL,
    "ID_residencial" integer NOT NULL,
    nombre_torre character varying(50),
    cantidadniveles integer
);


ALTER TABLE "Torre" OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 91251)
-- Name: Torre_ID_torre_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Torre_ID_torre_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "Torre_ID_torre_seq" OWNER TO postgres;

--
-- TOC entry 3294 (class 0 OID 0)
-- Dependencies: 236
-- Name: Torre_ID_torre_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Torre_ID_torre_seq" OWNED BY "Torre"."ID_torre";


--
-- TOC entry 204 (class 1259 OID 91104)
-- Name: Usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "Usuario" (
    "idUsuario" integer DEFAULT nextval(('public.usuario_idusuario_seq'::text)::regclass) NOT NULL,
    "userName" character varying(50),
    password character varying(100),
    "IdPersona" integer NOT NULL,
    "NumeroCuenta" character varying,
    "idStatusUsuario" integer NOT NULL,
    "IsClient" boolean DEFAULT false,
    "isAdmin" boolean DEFAULT false
);


ALTER TABLE "Usuario" OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 131167)
-- Name: areascomunes_id_areacomunes_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE areascomunes_id_areacomunes_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE areascomunes_id_areacomunes_seq OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 91216)
-- Name: historialQuejas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "historialQuejas" (
    "ID_Quejas" integer DEFAULT nextval(('public.historialquejas_id_quejas_seq'::text)::regclass) NOT NULL,
    "id_TipoQueja" integer NOT NULL,
    "ID_usuarioFrom" integer NOT NULL,
    "ID_usuarioTo" integer NOT NULL,
    "currentDate" timestamp without time zone,
    "ID_EstadoQuejas" integer NOT NULL,
    "Descripcion" character varying(200),
    "modifiedBy" character varying(30),
    "idModifiedby" integer NOT NULL,
    "id_Residencial" integer,
    "idStatus" integer DEFAULT 1,
    nombrefrom character varying(30)
);


ALTER TABLE "historialQuejas" OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 98359)
-- Name: historialquejas_id_quejas_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE historialquejas_id_quejas_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE historialquejas_id_quejas_seq OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 91150)
-- Name: sexo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE sexo (
    "ID_Sexo" integer NOT NULL,
    descripcion character varying(50)
);


ALTER TABLE sexo OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 91148)
-- Name: sexo_ID_Sexo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "sexo_ID_Sexo_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "sexo_ID_Sexo_seq" OWNER TO postgres;

--
-- TOC entry 3295 (class 0 OID 0)
-- Dependencies: 212
-- Name: sexo_ID_Sexo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "sexo_ID_Sexo_seq" OWNED BY sexo."ID_Sexo";


--
-- TOC entry 251 (class 1259 OID 91582)
-- Name: test; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE test (
    id integer NOT NULL,
    descri character varying(100),
    fecha timestamp(0) without time zone,
    fecha2 date
);
ALTER TABLE ONLY test ALTER COLUMN id SET STATISTICS 0;
ALTER TABLE ONLY test ALTER COLUMN descri SET STATISTICS 0;


ALTER TABLE test OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 91580)
-- Name: test_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE test_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE test_id_seq OWNER TO postgres;

--
-- TOC entry 3296 (class 0 OID 0)
-- Dependencies: 250
-- Name: test_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE test_id_seq OWNED BY test.id;


--
-- TOC entry 239 (class 1259 OID 91264)
-- Name: tipo_Torre; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "tipo_Torre" (
    "ID_tipo_torre" integer NOT NULL,
    "Descripcion" character varying
);


ALTER TABLE "tipo_Torre" OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 91262)
-- Name: tipo_Torre_ID_tipo_torre_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "tipo_Torre_ID_tipo_torre_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tipo_Torre_ID_tipo_torre_seq" OWNER TO postgres;

--
-- TOC entry 3297 (class 0 OID 0)
-- Dependencies: 238
-- Name: tipo_Torre_ID_tipo_torre_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "tipo_Torre_ID_tipo_torre_seq" OWNED BY "tipo_Torre"."ID_tipo_torre";


--
-- TOC entry 255 (class 1259 OID 131081)
-- Name: usuario_idusuario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE usuario_idusuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE usuario_idusuario_seq OWNER TO postgres;

--
-- TOC entry 2924 (class 2604 OID 147469)
-- Name: AreaComunpendientesbyUsuarios numMantenimiento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "AreaComunpendientesbyUsuarios" ALTER COLUMN "numMantenimiento" SET DEFAULT nextval('"AreaComunpendientesbyUsuarios_numMantenimiento_seq"'::regclass);


--
-- TOC entry 2939 (class 2604 OID 91281)
-- Name: Departamentos ID_departamento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Departamentos" ALTER COLUMN "ID_departamento" SET DEFAULT nextval('"Departamentos_ID_departamento_seq"'::regclass);


--
-- TOC entry 2926 (class 2604 OID 91210)
-- Name: DirigidoQueja ID_dirigido; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "DirigidoQueja" ALTER COLUMN "ID_dirigido" SET DEFAULT nextval('"DirigidoQueja_ID_dirigido_seq"'::regclass);


--
-- TOC entry 2929 (class 2604 OID 91229)
-- Name: EstadosQuejas ID_EstadoQuejas; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "EstadosQuejas" ALTER COLUMN "ID_EstadoQuejas" SET DEFAULT nextval('"EstadosQuejas_ID_EstadoQuejas_seq"'::regclass);


--
-- TOC entry 2921 (class 2604 OID 91180)
-- Name: MantenimientoArea ID_TipoMantenimiento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MantenimientoArea" ALTER COLUMN "ID_TipoMantenimiento" SET DEFAULT nextval('"MantenimientoArea_ID_TipoMantenimiento_seq"'::regclass);


--
-- TOC entry 2945 (class 2604 OID 91305)
-- Name: Municipio ID_municipio; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Municipio" ALTER COLUMN "ID_municipio" SET DEFAULT nextval('"Municipio_ID_municipio_seq"'::regclass);


--
-- TOC entry 2916 (class 2604 OID 91142)
-- Name: Permisos idPermiso; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Permisos" ALTER COLUMN "idPermiso" SET DEFAULT nextval('"Permisos_idPermiso_seq"'::regclass);


--
-- TOC entry 2907 (class 2604 OID 91072)
-- Name: Persona IdPersona; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Persona" ALTER COLUMN "IdPersona" SET DEFAULT nextval('"Persona_IdPersona_seq"'::regclass);


--
-- TOC entry 2944 (class 2604 OID 91297)
-- Name: Provincia ID_provincia; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Provincia" ALTER COLUMN "ID_provincia" SET DEFAULT nextval('"Provincia_ID_provincia_seq"'::regclass);


--
-- TOC entry 2933 (class 2604 OID 91240)
-- Name: Residencial ID_residencial; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Residencial" ALTER COLUMN "ID_residencial" SET DEFAULT nextval('"Residencial_ID_residencial_seq"'::regclass);


--
-- TOC entry 2946 (class 2604 OID 91313)
-- Name: Sector ID_sector; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Sector" ALTER COLUMN "ID_sector" SET DEFAULT nextval('"Sector_ID_sector_seq"'::regclass);


--
-- TOC entry 2911 (class 2604 OID 91093)
-- Name: Servicios ID_servicio; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Servicios" ALTER COLUMN "ID_servicio" SET DEFAULT nextval('"Servicios_ID_servicio_seq"'::regclass);


--
-- TOC entry 2954 (class 2604 OID 180268)
-- Name: StatusQuejas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "StatusQuejas" ALTER COLUMN id SET DEFAULT nextval('"StatusQuejas_id_seq"'::regclass);


--
-- TOC entry 2935 (class 2604 OID 91248)
-- Name: StatusResidencial ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "StatusResidencial" ALTER COLUMN "ID" SET DEFAULT nextval('"StatusResidencial_ID_seq"'::regclass);


--
-- TOC entry 2918 (class 2604 OID 91161)
-- Name: Status_usuarios ID_status; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Status_usuarios" ALTER COLUMN "ID_status" SET DEFAULT nextval('"Status_usuarios_ID_status_seq"'::regclass);


--
-- TOC entry 2910 (class 2604 OID 91085)
-- Name: TipoCuentaCobrar ID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "TipoCuentaCobrar" ALTER COLUMN "ID" SET DEFAULT nextval('"TipoCuentaCobrar_ID_seq"'::regclass);


--
-- TOC entry 2952 (class 2604 OID 180238)
-- Name: TipoPredeterminadoserivios numserial; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "TipoPredeterminadoserivios" ALTER COLUMN numserial SET DEFAULT nextval('"TipoPredeterminadoserivios_numserial_seq"'::regclass);


--
-- TOC entry 2925 (class 2604 OID 91202)
-- Name: TipoQuejas ID_TipoQuejas; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "TipoQuejas" ALTER COLUMN "ID_TipoQuejas" SET DEFAULT nextval('"TipoQuejas_ID_TipoQuejas_seq"'::regclass);


--
-- TOC entry 2915 (class 2604 OID 91128)
-- Name: TipoUsuario idTipoUsuario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "TipoUsuario" ALTER COLUMN "idTipoUsuario" SET DEFAULT nextval('"TipoUsuario_idTipoUsuario_seq"'::regclass);


--
-- TOC entry 2936 (class 2604 OID 91256)
-- Name: Torre ID_torre; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Torre" ALTER COLUMN "ID_torre" SET DEFAULT nextval('"Torre_ID_torre_seq"'::regclass);


--
-- TOC entry 2917 (class 2604 OID 91153)
-- Name: sexo ID_Sexo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sexo ALTER COLUMN "ID_Sexo" SET DEFAULT nextval('"sexo_ID_Sexo_seq"'::regclass);


--
-- TOC entry 2947 (class 2604 OID 91585)
-- Name: test id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY test ALTER COLUMN id SET DEFAULT nextval('test_id_seq'::regclass);


--
-- TOC entry 2937 (class 2604 OID 91267)
-- Name: tipo_Torre ID_tipo_torre; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "tipo_Torre" ALTER COLUMN "ID_tipo_torre" SET DEFAULT nextval('"tipo_Torre_ID_tipo_torre_seq"'::regclass);


--
-- TOC entry 3220 (class 0 OID 91169)
-- Dependencies: 217
-- Data for Name: AreaComunesvsResidencial; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "AreaComunesvsResidencial" ("ID_areaComunes", "ID_residencial") FROM stdin;
6	2
7	1
8	6
9	1
10	23
11	23
12	22
2	22
3	22
4	22
5	22
\.


--
-- TOC entry 3224 (class 0 OID 91183)
-- Dependencies: 221
-- Data for Name: AreaComunpendientesbyUsuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "AreaComunpendientesbyUsuarios" (id_areacomun, "fehcaAsignamiento", "idUsuario", "idMantenimiento", activo, "numMantenimiento") FROM stdin;
1	2021-04-19	6	1	t	26
\.


--
-- TOC entry 3219 (class 0 OID 91164)
-- Dependencies: 216
-- Data for Name: AreasComunes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "AreasComunes" ("ID_areaComunes", descripcion, activo, nombre) FROM stdin;
1	tEST	t	Test
2	Funcionara ??	t	Randiel la Para
3	esto es klk	t	klk
4	Area recreativa para darse un chapuson	t	pisina
5	patio de 100 m^2 para la recreacion	t	patio tracero
6	para el teteo	t	Salon de fiestas
7	area de recreacion	t	parque
8	area recreativa	t	pisina
9	area recreativs	t	pisina
10	Piscina	t	Piscina
11	Gold GYM	t	Gold GYM
12	area recreativa	t	Pisina
\.


--
-- TOC entry 3221 (class 0 OID 91172)
-- Dependencies: 218
-- Data for Name: AreasComunesVsMantenimientos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "AreasComunesVsMantenimientos" (id_areacomun, "id_TipoMantenimiento", "idUsuarioDefault", "fechaProgramada") FROM stdin;
1	1	1	2021-05-04
\.


--
-- TOC entry 3209 (class 0 OID 91115)
-- Dependencies: 206
-- Data for Name: Calificacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Calificacion" ("ID_usuario", "ID_departamento", "Calificacion", descripcion, fecha) FROM stdin;
3	1	2	1	2021-04-14
6	1	5	tests	2021-04-20
\.


--
-- TOC entry 3201 (class 0 OID 91075)
-- Dependencies: 198
-- Data for Name: CuentaPorCobrar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "CuentaPorCobrar" ("Idusuario", "IdReferencia", "IdTipoCuentaxCobrar", fecha, monto, pagado) FROM stdin;
1	4	1	2021-04-20 15:06:36	500	t
1	6	2	2021-04-20 12:34:54	3000	t
6	1	2	2021-04-20 18:21:19	3000	f
13	12	1	2021-04-20 19:03:11	2000	f
13	13	1	2021-04-20 19:10:02	4040	f
13	12	1	2021-04-20 19:10:02	2000	f
13	13	1	2021-04-20 19:10:12	4040	f
13	12	1	2021-04-20 19:10:12	2000	f
13	13	1	2021-04-20 19:11:56	4040	f
13	12	1	2021-04-20 19:11:56	2000	f
\.


--
-- TOC entry 3263 (class 0 OID 163849)
-- Dependencies: 260
-- Data for Name: DepartamentoVSFoto; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "DepartamentoVSFoto" ("idDepartamento", imagen) FROM stdin;
\.


--
-- TOC entry 3256 (class 0 OID 98339)
-- Dependencies: 253
-- Data for Name: DepartamentoVsServicos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "DepartamentoVsServicos" ("ID_servicio", "ID_Departamento") FROM stdin;
13	9
12	9
\.


--
-- TOC entry 3245 (class 0 OID 91278)
-- Dependencies: 242
-- Data for Name: Departamentos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Departamentos" ("ID_departamento", "ID_torre", "Nombre_departamento", "Disponible", "PrecioVenta", "PrecioAlquiler", "VentaDisponible", "cantidadBath", canthabitaciones, "isAmueblado", image) FROM stdin;
2	5	Hh	t	10000000	6000	t	1	5	f	\N
8	10	Q1	t	0	6000	f	1	2	t	https://i.ibb.co/55hwmnw/15471f2b6a07.jpg
3	3	1B	t	1000000	5000	f	1	2	t	\N
1	5	A2	t	100000	5000	f	1	1	t	\N
9	12	XA1	t	100000	5000	t	1	3	f	https://i.ibb.co/H4Sdn1n/8e821984e5e6.jpg
11	13	SS	t	1999000	10000	t	2	4	f	https://i.ibb.co/TMC03Bn/711a4bc156ec.jpg
10	14	X-14	t	5000000	8000	t	1	1	f	https://i.ibb.co/H4Sdn1n/8e821984e5e6.jpg
\.


--
-- TOC entry 3229 (class 0 OID 91207)
-- Dependencies: 226
-- Data for Name: DirigidoQueja; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "DirigidoQueja" ("ID_dirigido", "Descripcion") FROM stdin;
1	Residencial
2	Inquilino
\.


--
-- TOC entry 3260 (class 0 OID 139273)
-- Dependencies: 257
-- Data for Name: EmpleadosvsResidencial; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "EmpleadosvsResidencial" ("idUsuario", "idResidencial", "FechaIngreso", activo) FROM stdin;
6	3	2021-04-20	t
\.


--
-- TOC entry 3233 (class 0 OID 91226)
-- Dependencies: 230
-- Data for Name: EstadosQuejas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "EstadosQuejas" ("ID_EstadoQuejas", "descripcionEstado") FROM stdin;
1	Pendiente
2	En proceso
3	Denegada
4	Completada
\.


--
-- TOC entry 3225 (class 0 OID 91194)
-- Dependencies: 222
-- Data for Name: HistorialMantenimiento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "HistorialMantenimiento" (id_areacomun, "fehcaAsignamiento", "fechaCompletada", "idUsuario") FROM stdin;
\.


--
-- TOC entry 3246 (class 0 OID 91289)
-- Dependencies: 243
-- Data for Name: Inquilino; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Inquilino" ("ID_usuario", "ID_deparamento", "Nombre_departamento", "idResidencial", "fechaIngreso", "idPersona") FROM stdin;
13	9	XA1	21	2021-04-20	20
\.


--
-- TOC entry 3223 (class 0 OID 91177)
-- Dependencies: 220
-- Data for Name: MantenimientoArea; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "MantenimientoArea" ("ID_TipoMantenimiento", "Descripcion", "cantidadDias") FROM stdin;
1	Mantener la API	15
2	Arisita	15
3	Daniela	15
4	pintar	20
5	Mantenimiento Test	2
6	pintar	30
7	Limpieza	2
\.


--
-- TOC entry 3255 (class 0 OID 98318)
-- Dependencies: 252
-- Data for Name: MantenimientovsResidencial; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "MantenimientovsResidencial" ("idMatenimiento", "idResidencial") FROM stdin;
1	1
2	1
3	2
4	2
4	3
4	5
4	7
5	3
5	17
5	4
6	6
6	8
6	10
7	22
\.


--
-- TOC entry 3250 (class 0 OID 91302)
-- Dependencies: 247
-- Data for Name: Municipio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Municipio" ("ID_municipio", "ID_Provincia", descripcion) FROM stdin;
1	2	Altamira
2	2	Arenoso
3	3	Azua de Compostela
4	4	Baitoa
5	5	Bajos de Haina
6	6	Baní
7	7	Bánica
8	8	Bayaguana
9	9	Boca Chica
10	10	Bohechío
11	11	Bonao
12	12	Cabral
13	13	Cabrera
14	14	Cambita Garabitos
15	15	Castañuela
16	16	Castillo
17	17	Cayetano Germosen
18	18	Cevicos
19	19	Comendador
20	20	Concepción de La Vega
21	21	Constanza
22	22	Consuelo
23	23	Cotuí
24	24	Cristóbal
25	25	Dajabón
26	26	Duvergé
27	27	El Cercado
28	28	El Factor
29	29	El Llano
30	30	El Peñón
31	31	El Pino
32	32	El Valle
33	3	Enriquillo
34	2	Esperanza
35	3	Estebanía
36	4	Eugenio María de Hostos
37	5	Fantino
38	6	Fundación
39	7	Galván
40	8	Gaspar Hernández
41	9	Guananico
42	10	Guayabal
43	11	Guayacanes
44	12	Guaymate
45	13	Guayubín
46	14	Hato Mayor del Rey
47	15	Hondo Valle
48	16	Imbert
49	17	Jamao al Norte
50	18	Jánico
51	19	Jaquimeyes
52	20	Jarabacoa
53	21	Jima Abajo
54	22	Jimaní
55	23	Juan de Herrera
56	24	Juan Santiago
57	25	La Ciénaga
58	26	La Descubierta
59	27	La Mata
60	28	La Romana
61	29	Laguna Salada
62	30	Las Charcas
63	31	Las Guáranas
64	32	Las Matas de Farfán
65	4	Las Matas de Santa Cruz
66	2	Las Terrenas
67	3	Licey al Medio
68	4	Loma de Cabrera
69	5	Los Alcarrizos
70	6	Los Cacaos
71	7	Los Hidalgos
72	8	Los Ríos
73	9	Luperón
74	10	Maimón
75	11	Matanzas
76	12	Mella
77	13	Miches
78	14	Moca
79	15	Monción
80	16	Monte Plata
81	17	Nagua
82	18	Neiba
83	19	Nizao
84	20	Oviedo
85	21	Padre Las Casas
86	22	Paraíso
87	23	Partido
88	24	Pedernales
89	25	Pedro Brand
90	26	Pedro Santana
91	27	Pepillo Salcedo
92	28	Peralta
93	29	Peralvillo
94	30	Piedra Blanca
95	31	Pimentel
96	32	Polo
97	5	Postrer Río
98	2	Pueblo Viejo
99	3	Puñal
100	4	Quisqueya
101	5	Ramón Santana
102	6	Rancho Arriba
103	7	Restauración
104	8	Río San Juan
105	9	Sabana de la Mar
106	10	Sabana Grande de Boyá
107	11	Sabana Grande de Palenque
108	12	Sabana Iglesia
109	13	Sabana Larga
110	14	Sabana Yegua
111	15	Salcedo
112	16	Salinas
113	17	Salvaleón de Higüey
114	18	San Antonio de Guerra
115	19	San Cristóbal
116	20	San Felipe de Puerto Plata
117	21	San Fernando de Monte Cristi
118	22	San Francisco de Macorís
119	23	San Gregorio de Nigua
120	24	San Ignacio de Sabaneta
121	25	San José de las Matas
122	26	San José de los Llanos
123	27	San José de Ocoa
124	28	San Juan de la Maguana
125	29	San Luis
126	30	San Pedro de Macorís
127	31	San Rafael del Yuma
128	32	San Víctor
129	6	Sánchez
130	2	Santa Bárbara de Samaná
131	3	Santa Cruz de Barahona
132	4	Santa Cruz de El Seibo
133	5	Santa Cruz de Mao
134	6	Santiago de los Caballeros
135	7	Santo Domingo
136	8	Santo Domingo Este
137	9	Santo Domingo Norte
138	10	Santo Domingo Oeste
139	11	Sosúa
140	12	Tábara Arriba
141	13	Tamayo
142	14	Tamboril
143	15	Tenares
144	16	Vallejuelo
145	17	Vicente Noble
146	18	Villa Altagracia
147	19	Villa Bisonó
148	20	Villa González
149	21	Villa Hermosa
150	22	Villa Isabela
151	23	Villa Jaragua
152	24	Villa Los Almácigos
153	25	Villa Montellano
154	26	Villa Riva
155	27	Villa Tapia
156	28	Villa Vásquez
157	29	Yaguate
158	30	Yamasá
159	31	Yayas de Viajama
\.


--
-- TOC entry 3208 (class 0 OID 91112)
-- Dependencies: 205
-- Data for Name: NumeroCuenta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "NumeroCuenta" ("NumeroCuenta", "ID_usuario") FROM stdin;
\.


--
-- TOC entry 3243 (class 0 OID 91273)
-- Dependencies: 240
-- Data for Name: OwnersVsResidencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "OwnersVsResidencia" ("ID_usuario", "Id_residencial") FROM stdin;
1	1
1	20
1	19
1	3
14	21
16	22
16	23
\.


--
-- TOC entry 3214 (class 0 OID 91139)
-- Dependencies: 211
-- Data for Name: Permisos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Permisos" ("idPermiso", permiso) FROM stdin;
\.


--
-- TOC entry 3200 (class 0 OID 91069)
-- Dependencies: 197
-- Data for Name: Persona; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Persona" ("IdPersona", "Nombre", "Apellido", "ID_Sexo", celular) FROM stdin;
3	sadiel	henrique	1	\N
7	sadiel	henrique	1	\N
8	randiel	arias	1	\N
10	lolo	henriquez	1	\N
11	lala	aefas	2	\N
12	randiel2	arias2	1	\N
13	Cli	klk	1	8092332380
14	bianel	loquesea	1	1122258
15	sadiel	henriquez	1	8092332380
16	sad	sad	1	12456534232
17	xabier	hernad	1	8298223289
18	sadi	dell	1	58856555
19	test	cliente	2	5805921158
20	randy	el	1	125688095
21	Wester	junior	1	12132134234
22	cliente	sdas	1	3569
23	Administrador	llll	1	123456
24	clienteS	h	1	1234554
25	cliente2	2	1	123455
26	cliente3	3	1	12211313
\.


--
-- TOC entry 3248 (class 0 OID 91294)
-- Dependencies: 245
-- Data for Name: Provincia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Provincia" ("ID_provincia", descripcion) FROM stdin;
2	AZUA
3	BAORUCO
4	BARAHONA
5	DAJABÓN
6	DUARTE
7	ELÍAS PIÑA
8	EL SEIBO
9	ESPAILLAT
10	INDEPENDENCIA
11	LA ALTAGRACIA
12	LA ROMANA
13	LA VEGA
14	MARÍA TRINIDAD SÁNCHEZ
15	MONTE CRISTI
16	PEDERNALES
17	PERAVIA
18	PUERTO PLATA
19	HERMANAS MIRABAL
20	SAMANÁ
21	SAN CRISTÓBAL
22	SAN JUAN 
23	SAN PEDRO DE MACORÍS
24	SÁNCHEZ RAMÍREZ
25	SANTIAGO
26	SANTIAGO RODRÍGUEZ
27	VALVERDE
28	MONSEÑOR NOUEL
29	MONTE PLATA
30	HATO MAYOR
31	SAN JOSÉ DE OCOA
32	SANTO DOMINGO
1	Punta Cana
\.


--
-- TOC entry 3231 (class 0 OID 91221)
-- Dependencies: 228
-- Data for Name: QuejasLog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "QuejasLog" ("ID_Queja", "ID_usuarioFrom", "ID_usuarioTo", "FechaQueja", "ID_EstadoQuejas", "Descripcion", "DescripcionLog", "currentDate", "id_usuarioLog") FROM stdin;
24	6	6	2021-04-20 18:21:19.124973	1	weyyyyy	HA CREADO UNA QUEJA	2021-04-20 18:21:19.124973	6
24	6	6	2021-04-20 18:21:19.124973	2	weyyyyy	HA APROBADO UNA QUEJA	2021-04-20 18:23:32.816276	6
\.


--
-- TOC entry 3236 (class 0 OID 91237)
-- Dependencies: 233
-- Data for Name: Residencial; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Residencial" ("ID_residencial", nombre, "ID_provincia", "ID_municipio", "ID_sector", areacuadrada, "MinimoVenta", "MinimoAlquiler", "ID_status", "imgPortada") FROM stdin;
6	Pruebaaaaa	2	1	3	345435	\N	\N	1	null
7	Pepito	2	1	3	34534	\N	\N	1	null
8	awd55555555	3	2	3	1232434	\N	\N	1	null
9	Pepito2	2	1	3	32	\N	\N	1	null
10	Pepito44444d	2	2	4	42153	\N	\N	1	null
14	Resindeawd	3	1	3	58	\N	\N	1	null
16	limpiar2	4	4	4	34	\N	\N	1	null
17	Sadiel	2	3	2	58	\N	\N	1	null
2	Residencial Maria	2	2	3	34234	\N	\N	1	null
4	Residencial Sadiel	3	2	3	432	\N	\N	1	null
15	Residencial 15	4	4	4	345	\N	\N	1	null
5	Resinde	25	2	3	345345	\N	\N	1	null
3	Residencial Randiel	1	2	3	432	\N	\N	1	null
18	residencial S	1	1	1	100	\N	\N	1	null
1	Residencial Pedrito	3	2	2	12	\N	\N	1	https://i.ibb.co/TRfjTWB/6329550efcc0.jpg
19	Residencial Randiel	1	2	4	540000	\N	\N	1	https://i.ibb.co/NV5q9q4/7b8585e7dd4f.jpg
20	Residencial Maria	1	2	4	540000	\N	\N	1	https://i.ibb.co/NV5q9q4/7b8585e7dd4f.jpg
21	Residencial nueva fe	2	2	4	500	\N	\N	1	
22	santa	2	1	1	1000	\N	\N	1	https://i.ibb.co/H4Sdn1n/8e821984e5e6.jpg
23	alabama	1	1	3	1222	\N	\N	1	https://i.ibb.co/VT7dMkX/4d7f34859274.jpg
\.


--
-- TOC entry 3206 (class 0 OID 91099)
-- Dependencies: 203
-- Data for Name: Roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Roles" ("idUsuario", "idTipo", "ID_residencial") FROM stdin;
1	2	2
1	4	1
1	1	1
6	2	5
6	4	3
1	1	3
6	2	1
13	2	21
12	3	3
\.


--
-- TOC entry 3252 (class 0 OID 91310)
-- Dependencies: 249
-- Data for Name: Sector; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Sector" ("ID_sector", "ID_Municipio", descripcion) FROM stdin;
1	1	24 de abril
2	2	30 de mayo
3	3	Altos de Arroyo Hondo
4	4	Arroyo Manzano
5	5	Atala
6	6	Bella Vista
7	7	Buenos Aires
8	8	El Cacique
9	9	Centro de los Héroes
10	10	Centro Olímpico
11	11	Cerros de Arroyo Hondo
12	12	Ciudad Colonial
13	13	Ciudad Nueva
14	14	Ciudad Universitaria
15	15	Cristo Rey
16	16	Domingo Savio
17	17	El Millón
18	18	Ensanche Capotillo
19	19	Ensanche Espaillat
20	20	Ensanche La Fe
21	21	Ensanche Luperón
22	22	Ensanche Naco
23	23	Ensanche Quisqueya
24	24	Gazcue
25	25	General Antonio Duverge
26	26	Gualey
27	27	Honduras del Norte
28	28	Honduras del Oeste
29	29	Jardín Botánico
30	30	Jardín Zoológico
31	31	Jardines del Sur
32	32	Julieta Morales
33	1	La Agustina
34	2	La Castellana
35	3	La Esperilla
36	4	La Hondonada
37	5	La Isabela
38	6	La Julia
39	7	Las Praderas
40	8	La Zurza
41	9	Los Cacicazgos
42	10	Los Jardines
43	11	Los Peralejos
44	12	Los Prados
45	13	Los Restauradores
46	14	Los Ríos
47	15	María Auxiliadora
48	16	Mata Hambre
49	17	Mejoramiento Social
50	18	Mirador Norte
51	19	Mirador Sur
52	20	Miraflores
53	21	Miramar
54	22	Nuestra Señora de la Paz
55	23	Nuevo Arroyo Hondo
56	24	Palma Real
57	25	Paraíso
58	26	Paseo de los Indios
59	27	Piantini
60	28	Los Próceres
61	29	Renacimiento
62	30	San Carlos
63	31	San Diego
64	32	San Geronimo
65	1	San Juan Bosco
66	2	Simón Bolívar
67	3	Viejo Arroyo Hondo
68	4	Villas Agrícolas
69	5	Villa Consuelo
70	6	Villa Francisca
71	7	Villa Juana
\.


--
-- TOC entry 3205 (class 0 OID 91090)
-- Dependencies: 202
-- Data for Name: Servicios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Servicios" ("ID_servicio", "Descripcion", cobro, pago, "idResidencial") FROM stdin;
5	Primer Servicio	1200	1000	7
7	Cable	650	500	5
8	Telefono	600	400	5
9	sads	1212	220	5
10	asdaasdasdasdas	345	345	5
6	Agu	4000	3000	5
11	agua	300	1000	6
1	Pago de TV	23	23	1
2	Aseo de Mascotas	43	34	1
3	Netflix	3333	3333	1
4	Aseo Vehiculos	243	234	1
12	Agua	2000	1000	21
13	Netflix	4040	3000	21
16	Gimnacio	400	300	22
15	Aseo de Vehiculos	1200	900	23
17	Internet 100 mg	1000	2000	23
20	Mensualidad Normal	6000	0	23
19	Lavado de carros	2000	1234	22
18	Mensualidad VIP	10000	0	23
21	Deliveri	400	300	22
22	Desayuno	1235	1234	22
\.


--
-- TOC entry 3266 (class 0 OID 180247)
-- Dependencies: 263
-- Data for Name: ServiciosPredeterminados; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "ServiciosPredeterminados" ("idTipopredeterminado", "idServicio") FROM stdin;
1	1
1	3
2	3
3	12
3	13
4	12
5	13
5	12
6	16
6	22
6	10
6	9
\.


--
-- TOC entry 3234 (class 0 OID 91232)
-- Dependencies: 231
-- Data for Name: SolicitudCompra; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "SolicitudCompra" ("ID_usuario", fecha, "ID_departamento", "idResidencial", "isCompra", "Activo") FROM stdin;
6	2021-04-19	3	3	t	t
6	2021-04-19	3	3	t	t
6	2021-04-19	3	3	t	t
6	2021-04-19	3	3	t	t
6	2021-04-19	3	3	t	t
6	2021-04-19	2	5	t	t
6	2021-04-19	1	5	t	f
6	2021-04-19	1	5	f	f
6	2021-04-19	1	5	f	f
6	2021-04-20	3	3	f	t
6	2021-04-20	3	3	f	t
3	2021-04-20	3	3	f	f
3	2021-04-20	3	3	f	f
3	2021-04-20	8	1	f	t
13	2021-04-20	8	1	t	t
13	2021-04-20	9	21	f	f
15	2021-04-20	2	5	f	t
19	2021-04-20	11	22	f	t
\.


--
-- TOC entry 3261 (class 0 OID 139300)
-- Dependencies: 258
-- Data for Name: SolicitudEmpleados; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "SolicitudEmpleados" ("idUser", "idResidencial", fecha, activo) FROM stdin;
6	3	2021-04-19	f
12	3	2021-04-20	f
\.


--
-- TOC entry 3268 (class 0 OID 180265)
-- Dependencies: 265
-- Data for Name: StatusQuejas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "StatusQuejas" (id, "Descripcion") FROM stdin;
1	Activa
2	Aceptada
3	Denegada
\.


--
-- TOC entry 3238 (class 0 OID 91245)
-- Dependencies: 235
-- Data for Name: StatusResidencial; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "StatusResidencial" ("ID", "Descripcion") FROM stdin;
1	Activo
3	Inactivo
\.


--
-- TOC entry 3218 (class 0 OID 91158)
-- Dependencies: 215
-- Data for Name: Status_usuarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Status_usuarios" ("ID_status", "Descripcion") FROM stdin;
1	Activo
2	Inactivo
\.


--
-- TOC entry 3203 (class 0 OID 91082)
-- Dependencies: 200
-- Data for Name: TipoCuentaCobrar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "TipoCuentaCobrar" ("ID", "Descripcion") FROM stdin;
1	Cargos por servicio
2	Cargos por Quejas
\.


--
-- TOC entry 3265 (class 0 OID 180235)
-- Dependencies: 262
-- Data for Name: TipoPredeterminadoserivios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "TipoPredeterminadoserivios" (numserial, tipo, "idResidencial", fecha) FROM stdin;
1	VIP	3	2021-04-20
2	Normal	3	2021-04-20
3	Exclusivo	21	2021-04-20
4	Normal	21	2021-04-20
5	Exclusivo mas	21	2021-04-20
6	VIP	22	2021-04-20
7	Normal	22	2021-04-20
\.


--
-- TOC entry 3227 (class 0 OID 91199)
-- Dependencies: 224
-- Data for Name: TipoQuejas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "TipoQuejas" ("ID_TipoQuejas", "Descripcion", "CantAdvertencia", "LimitePenalizacion", "CostoPenalizacion", "ID_dirigido", "idResidencial") FROM stdin;
2	Test quejas	1	1	1200	1	2
1	Pila de Test que esta haciendo 	2	10	3000	1	1
4	ruido	2	3	200	2	5
5	averia	0	0	0	2	5
6	Ruido	2	3	200	2	20
7	Ruido	3	5	200	2	22
8	Escalera sucio	2	5	1200	1	23
\.


--
-- TOC entry 3211 (class 0 OID 91125)
-- Dependencies: 208
-- Data for Name: TipoUsuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "TipoUsuario" ("idTipoUsuario", tipo) FROM stdin;
2	Inquilino
1	Administrador
3	Cliente
4	Empleado
\.


--
-- TOC entry 3212 (class 0 OID 91134)
-- Dependencies: 209
-- Data for Name: TipoUsuarioVSPermisos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "TipoUsuarioVSPermisos" ("idTipoUsuario", "idPermiso") FROM stdin;
\.


--
-- TOC entry 3240 (class 0 OID 91253)
-- Dependencies: 237
-- Data for Name: Torre; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Torre" ("ID_torre", "ID_residencial", nombre_torre, cantidadniveles) FROM stdin;
2	7	Test torre	\N
4	5	Sadiel	3
5	5	Tto	4
6	5	Randiel	1
7	4	lala	2
3	3	test	2
9	18	XXI5	4
8	6	XD11	4
11	1	DXS	3
10	1	DXS1	3
12	21	XAs	3
13	22	Torre f	3
14	23	Torre Garcia	3
\.


--
-- TOC entry 3207 (class 0 OID 91104)
-- Dependencies: 204
-- Data for Name: Usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "Usuario" ("idUsuario", "userName", password, "IdPersona", "NumeroCuenta", "idStatusUsuario", "IsClient", "isAdmin") FROM stdin;
3	lolo7	654321	10		1	t	f
4	lala	123456	11		1	f	t
1	sadiel	123456	7		1	f	t
2	randiel	123456	8		1	f	t
5	randiel2	123456	12		1	t	f
6	cli	123456	13		1	t	f
7	bianel	123456	14		1	f	t
8	sado	123456	15		1	f	t
9	sadsad	123456	16		1	t	f
10	xabier	123456	17		1	f	t
11	Sad8	123456	18		1	f	t
12	test	123456	19		1	t	f
13	randy	123456	20		1	t	f
14	wester	123456	21		1	f	t
15	Hh	123456	22		1	t	f
17	cliente1	123456	24		1	t	f
18	cliente2	123456	25		1	t	f
19	cliente3	123456	26		1	t	f
16	admin	123456	23		1	f	t
\.


--
-- TOC entry 3230 (class 0 OID 91216)
-- Dependencies: 227
-- Data for Name: historialQuejas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "historialQuejas" ("ID_Quejas", "id_TipoQueja", "ID_usuarioFrom", "ID_usuarioTo", "currentDate", "ID_EstadoQuejas", "Descripcion", "modifiedBy", "idModifiedby", "id_Residencial", "idStatus", nombrefrom) FROM stdin;
21	1	6	6	2021-04-20 12:34:54.187307	1	cobrale	cli	6	1	2	This is a test
20	1	6	6	2021-04-20 12:31:37.571199	1	1	cli	6	1	3	Cliente test Editado
24	1	6	6	2021-04-20 18:21:19.124973	1	weyyyyy	cli	6	1	2	Cli klk
\.


--
-- TOC entry 3216 (class 0 OID 91150)
-- Dependencies: 213
-- Data for Name: sexo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY sexo ("ID_Sexo", descripcion) FROM stdin;
1	Masculino
2	Femenino
\.


--
-- TOC entry 3254 (class 0 OID 91582)
-- Dependencies: 251
-- Data for Name: test; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY test (id, descri, fecha, fecha2) FROM stdin;
1	Randiel	\N	\N
2	Randiel	\N	\N
3	Klok	2021-04-10 21:23:26	\N
4	KLOK 2	\N	2021-04-10
5	Por lo menos entro al else jaja	\N	\N
6	Por lo menos entro al else jaja	\N	\N
7	Por lo menos entro al else jaja	\N	\N
8	Si puede funcionar	\N	\N
\.


--
-- TOC entry 3242 (class 0 OID 91264)
-- Dependencies: 239
-- Data for Name: tipo_Torre; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "tipo_Torre" ("ID_tipo_torre", "Descripcion") FROM stdin;
\.


--
-- TOC entry 3298 (class 0 OID 0)
-- Dependencies: 259
-- Name: AreaComunpendientesbyUsuarios_numMantenimiento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"AreaComunpendientesbyUsuarios_numMantenimiento_seq"', 26, true);


--
-- TOC entry 3299 (class 0 OID 0)
-- Dependencies: 241
-- Name: Departamentos_ID_departamento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"Departamentos_ID_departamento_seq"', 11, true);


--
-- TOC entry 3300 (class 0 OID 0)
-- Dependencies: 225
-- Name: DirigidoQueja_ID_dirigido_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"DirigidoQueja_ID_dirigido_seq"', 2, true);


--
-- TOC entry 3301 (class 0 OID 0)
-- Dependencies: 229
-- Name: EstadosQuejas_ID_EstadoQuejas_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"EstadosQuejas_ID_EstadoQuejas_seq"', 6, true);


--
-- TOC entry 3302 (class 0 OID 0)
-- Dependencies: 219
-- Name: MantenimientoArea_ID_TipoMantenimiento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"MantenimientoArea_ID_TipoMantenimiento_seq"', 7, true);


--
-- TOC entry 3303 (class 0 OID 0)
-- Dependencies: 246
-- Name: Municipio_ID_municipio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"Municipio_ID_municipio_seq"', 1, false);


--
-- TOC entry 3304 (class 0 OID 0)
-- Dependencies: 210
-- Name: Permisos_idPermiso_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"Permisos_idPermiso_seq"', 1, false);


--
-- TOC entry 3305 (class 0 OID 0)
-- Dependencies: 196
-- Name: Persona_IdPersona_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"Persona_IdPersona_seq"', 26, true);


--
-- TOC entry 3306 (class 0 OID 0)
-- Dependencies: 244
-- Name: Provincia_ID_provincia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"Provincia_ID_provincia_seq"', 1, true);


--
-- TOC entry 3307 (class 0 OID 0)
-- Dependencies: 232
-- Name: Residencial_ID_residencial_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"Residencial_ID_residencial_seq"', 23, true);


--
-- TOC entry 3308 (class 0 OID 0)
-- Dependencies: 248
-- Name: Sector_ID_sector_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"Sector_ID_sector_seq"', 1, false);


--
-- TOC entry 3309 (class 0 OID 0)
-- Dependencies: 201
-- Name: Servicios_ID_servicio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"Servicios_ID_servicio_seq"', 22, true);


--
-- TOC entry 3310 (class 0 OID 0)
-- Dependencies: 264
-- Name: StatusQuejas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"StatusQuejas_id_seq"', 3, true);


--
-- TOC entry 3311 (class 0 OID 0)
-- Dependencies: 234
-- Name: StatusResidencial_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"StatusResidencial_ID_seq"', 3, true);


--
-- TOC entry 3312 (class 0 OID 0)
-- Dependencies: 214
-- Name: Status_usuarios_ID_status_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"Status_usuarios_ID_status_seq"', 2, true);


--
-- TOC entry 3313 (class 0 OID 0)
-- Dependencies: 199
-- Name: TipoCuentaCobrar_ID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"TipoCuentaCobrar_ID_seq"', 2, true);


--
-- TOC entry 3314 (class 0 OID 0)
-- Dependencies: 261
-- Name: TipoPredeterminadoserivios_numserial_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"TipoPredeterminadoserivios_numserial_seq"', 8, true);


--
-- TOC entry 3315 (class 0 OID 0)
-- Dependencies: 223
-- Name: TipoQuejas_ID_TipoQuejas_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"TipoQuejas_ID_TipoQuejas_seq"', 8, true);


--
-- TOC entry 3316 (class 0 OID 0)
-- Dependencies: 207
-- Name: TipoUsuario_idTipoUsuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"TipoUsuario_idTipoUsuario_seq"', 5, true);


--
-- TOC entry 3317 (class 0 OID 0)
-- Dependencies: 236
-- Name: Torre_ID_torre_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"Torre_ID_torre_seq"', 14, true);


--
-- TOC entry 3318 (class 0 OID 0)
-- Dependencies: 256
-- Name: areascomunes_id_areacomunes_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('areascomunes_id_areacomunes_seq', 12, true);


--
-- TOC entry 3319 (class 0 OID 0)
-- Dependencies: 254
-- Name: historialquejas_id_quejas_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('historialquejas_id_quejas_seq', 24, true);


--
-- TOC entry 3320 (class 0 OID 0)
-- Dependencies: 212
-- Name: sexo_ID_Sexo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"sexo_ID_Sexo_seq"', 2, true);


--
-- TOC entry 3321 (class 0 OID 0)
-- Dependencies: 250
-- Name: test_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('test_id_seq', 4, true);


--
-- TOC entry 3322 (class 0 OID 0)
-- Dependencies: 238
-- Name: tipo_Torre_ID_tipo_torre_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"tipo_Torre_ID_tipo_torre_seq"', 1, false);


--
-- TOC entry 3323 (class 0 OID 0)
-- Dependencies: 255
-- Name: usuario_idusuario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('usuario_idusuario_seq', 19, true);


--
-- TOC entry 2982 (class 2606 OID 147471)
-- Name: AreaComunpendientesbyUsuarios AreaComunpendientesbyUsuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "AreaComunpendientesbyUsuarios"
    ADD CONSTRAINT "AreaComunpendientesbyUsuarios_pkey" PRIMARY KEY ("numMantenimiento");


--
-- TOC entry 2978 (class 2606 OID 131170)
-- Name: AreasComunes AreasComunes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "AreasComunes"
    ADD CONSTRAINT "AreasComunes_pkey" PRIMARY KEY ("ID_areaComunes");


--
-- TOC entry 2968 (class 2606 OID 91122)
-- Name: Calificacion Calificacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Calificacion"
    ADD CONSTRAINT "Calificacion_pkey" PRIMARY KEY ("ID_usuario", "ID_departamento");


--
-- TOC entry 2958 (class 2606 OID 155672)
-- Name: CuentaPorCobrar CuentaPorCobrar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "CuentaPorCobrar"
    ADD CONSTRAINT "CuentaPorCobrar_pkey" PRIMARY KEY ("Idusuario", "IdReferencia", "IdTipoCuentaxCobrar", fecha);


--
-- TOC entry 3000 (class 2606 OID 91283)
-- Name: Departamentos Departamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Departamentos"
    ADD CONSTRAINT "Departamentos_pkey" PRIMARY KEY ("ID_departamento");


--
-- TOC entry 2986 (class 2606 OID 91215)
-- Name: DirigidoQueja DirigidoQueja_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "DirigidoQueja"
    ADD CONSTRAINT "DirigidoQueja_pkey" PRIMARY KEY ("ID_dirigido");


--
-- TOC entry 2990 (class 2606 OID 91231)
-- Name: EstadosQuejas EstadosQuejas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "EstadosQuejas"
    ADD CONSTRAINT "EstadosQuejas_pkey" PRIMARY KEY ("ID_EstadoQuejas");


--
-- TOC entry 2980 (class 2606 OID 91182)
-- Name: MantenimientoArea MantenimientoArea_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MantenimientoArea"
    ADD CONSTRAINT "MantenimientoArea_pkey" PRIMARY KEY ("ID_TipoMantenimiento");


--
-- TOC entry 3004 (class 2606 OID 91307)
-- Name: Municipio Municipio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Municipio"
    ADD CONSTRAINT "Municipio_pkey" PRIMARY KEY ("ID_municipio");


--
-- TOC entry 2972 (class 2606 OID 91147)
-- Name: Permisos Permisos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Permisos"
    ADD CONSTRAINT "Permisos_pkey" PRIMARY KEY ("idPermiso");


--
-- TOC entry 2956 (class 2606 OID 91074)
-- Name: Persona Persona_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Persona"
    ADD CONSTRAINT "Persona_pkey" PRIMARY KEY ("IdPersona");


--
-- TOC entry 3002 (class 2606 OID 91299)
-- Name: Provincia Provincia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Provincia"
    ADD CONSTRAINT "Provincia_pkey" PRIMARY KEY ("ID_provincia");


--
-- TOC entry 2992 (class 2606 OID 91242)
-- Name: Residencial Residencial_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Residencial"
    ADD CONSTRAINT "Residencial_pkey" PRIMARY KEY ("ID_residencial");


--
-- TOC entry 2964 (class 2606 OID 91103)
-- Name: Roles Roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Roles"
    ADD CONSTRAINT "Roles_pkey" PRIMARY KEY ("idUsuario", "idTipo", "ID_residencial");


--
-- TOC entry 3006 (class 2606 OID 91315)
-- Name: Sector Sector_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Sector"
    ADD CONSTRAINT "Sector_pkey" PRIMARY KEY ("ID_sector");


--
-- TOC entry 2962 (class 2606 OID 91098)
-- Name: Servicios Servicios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Servicios"
    ADD CONSTRAINT "Servicios_pkey" PRIMARY KEY ("ID_servicio");


--
-- TOC entry 3012 (class 2606 OID 180270)
-- Name: StatusQuejas StatusQuejas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "StatusQuejas"
    ADD CONSTRAINT "StatusQuejas_pkey" PRIMARY KEY (id);


--
-- TOC entry 2994 (class 2606 OID 91250)
-- Name: StatusResidencial StatusResidencial_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "StatusResidencial"
    ADD CONSTRAINT "StatusResidencial_pkey" PRIMARY KEY ("ID");


--
-- TOC entry 2976 (class 2606 OID 91163)
-- Name: Status_usuarios Status_usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Status_usuarios"
    ADD CONSTRAINT "Status_usuarios_pkey" PRIMARY KEY ("ID_status");


--
-- TOC entry 2960 (class 2606 OID 91087)
-- Name: TipoCuentaCobrar TipoCuentaCobrar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "TipoCuentaCobrar"
    ADD CONSTRAINT "TipoCuentaCobrar_pkey" PRIMARY KEY ("ID");


--
-- TOC entry 3010 (class 2606 OID 180241)
-- Name: TipoPredeterminadoserivios TipoPredeterminadoserivios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "TipoPredeterminadoserivios"
    ADD CONSTRAINT "TipoPredeterminadoserivios_pkey" PRIMARY KEY (numserial);


--
-- TOC entry 2984 (class 2606 OID 91204)
-- Name: TipoQuejas TipoQuejas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "TipoQuejas"
    ADD CONSTRAINT "TipoQuejas_pkey" PRIMARY KEY ("ID_TipoQuejas");


--
-- TOC entry 2970 (class 2606 OID 91133)
-- Name: TipoUsuario TipoUsuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "TipoUsuario"
    ADD CONSTRAINT "TipoUsuario_pkey" PRIMARY KEY ("idTipoUsuario");


--
-- TOC entry 2996 (class 2606 OID 91261)
-- Name: Torre Torre_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Torre"
    ADD CONSTRAINT "Torre_pkey" PRIMARY KEY ("ID_torre");


--
-- TOC entry 2966 (class 2606 OID 131084)
-- Name: Usuario Usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Usuario"
    ADD CONSTRAINT "Usuario_pkey" PRIMARY KEY ("idUsuario");


--
-- TOC entry 2988 (class 2606 OID 98362)
-- Name: historialQuejas historialQuejas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "historialQuejas"
    ADD CONSTRAINT "historialQuejas_pkey" PRIMARY KEY ("ID_Quejas");


--
-- TOC entry 2974 (class 2606 OID 91155)
-- Name: sexo sexo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY sexo
    ADD CONSTRAINT sexo_pkey PRIMARY KEY ("ID_Sexo");


--
-- TOC entry 3008 (class 2606 OID 91587)
-- Name: test test_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY test
    ADD CONSTRAINT test_pkey PRIMARY KEY (id);


--
-- TOC entry 2998 (class 2606 OID 91272)
-- Name: tipo_Torre tipo_Torre_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "tipo_Torre"
    ADD CONSTRAINT "tipo_Torre_pkey" PRIMARY KEY ("ID_tipo_torre");


--
-- TOC entry 3076 (class 2620 OID 163856)
-- Name: Inquilino CambiarRolesInquilinos; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "CambiarRolesInquilinos" AFTER INSERT ON public."Inquilino" FOR EACH ROW EXECUTE PROCEDURE "CambiarRolesInquilinos"();


--
-- TOC entry 3074 (class 2620 OID 180261)
-- Name: historialQuejas CargoQuejas; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "CargoQuejas" AFTER INSERT ON public."historialQuejas" FOR EACH ROW EXECUTE PROCEDURE "CargoQuejas"();


--
-- TOC entry 3077 (class 2620 OID 172049)
-- Name: EmpleadosvsResidencial EntrarCliente; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "EntrarCliente" AFTER INSERT ON public."EmpleadosvsResidencial" FOR EACH ROW EXECUTE PROCEDURE "EntrarCliente"();


--
-- TOC entry 3075 (class 2620 OID 180283)
-- Name: historialQuejas LogQuejas; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "LogQuejas" AFTER INSERT OR UPDATE ON public."historialQuejas" FOR EACH ROW EXECUTE PROCEDURE "LogQuejas"();


--
-- TOC entry 3028 (class 2606 OID 131171)
-- Name: AreaComunesvsResidencial AreaComunesvsResidencial_ID_areaComunes_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "AreaComunesvsResidencial"
    ADD CONSTRAINT "AreaComunesvsResidencial_ID_areaComunes_fkey" FOREIGN KEY ("ID_areaComunes") REFERENCES "AreasComunes"("ID_areaComunes");


--
-- TOC entry 3027 (class 2606 OID 91386)
-- Name: AreaComunesvsResidencial AreaComunesvsResidencial_ID_residencial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "AreaComunesvsResidencial"
    ADD CONSTRAINT "AreaComunesvsResidencial_ID_residencial_fkey" FOREIGN KEY ("ID_residencial") REFERENCES "Residencial"("ID_residencial");


--
-- TOC entry 3032 (class 2606 OID 131110)
-- Name: AreaComunpendientesbyUsuarios AreaComunpendientesbyUsuarios_idUsuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "AreaComunpendientesbyUsuarios"
    ADD CONSTRAINT "AreaComunpendientesbyUsuarios_idUsuario_fkey" FOREIGN KEY ("idUsuario") REFERENCES "Usuario"("idUsuario");


--
-- TOC entry 3033 (class 2606 OID 131181)
-- Name: AreaComunpendientesbyUsuarios AreaComunpendientesbyUsuarios_id_areacomun_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "AreaComunpendientesbyUsuarios"
    ADD CONSTRAINT "AreaComunpendientesbyUsuarios_id_areacomun_fkey" FOREIGN KEY (id_areacomun) REFERENCES "AreasComunes"("ID_areaComunes");


--
-- TOC entry 3030 (class 2606 OID 131105)
-- Name: AreasComunesVsMantenimientos AreasComunesVsMantenimientos_idUsuarioDefault_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "AreasComunesVsMantenimientos"
    ADD CONSTRAINT "AreasComunesVsMantenimientos_idUsuarioDefault_fkey" FOREIGN KEY ("idUsuarioDefault") REFERENCES "Usuario"("idUsuario");


--
-- TOC entry 3029 (class 2606 OID 91396)
-- Name: AreasComunesVsMantenimientos AreasComunesVsMantenimientos_id_TipoMantenimiento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "AreasComunesVsMantenimientos"
    ADD CONSTRAINT "AreasComunesVsMantenimientos_id_TipoMantenimiento_fkey" FOREIGN KEY ("id_TipoMantenimiento") REFERENCES "MantenimientoArea"("ID_TipoMantenimiento");


--
-- TOC entry 3031 (class 2606 OID 131176)
-- Name: AreasComunesVsMantenimientos AreasComunesVsMantenimientos_id_areacomun_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "AreasComunesVsMantenimientos"
    ADD CONSTRAINT "AreasComunesVsMantenimientos_id_areacomun_fkey" FOREIGN KEY (id_areacomun) REFERENCES "AreasComunes"("ID_areaComunes");


--
-- TOC entry 3023 (class 2606 OID 91366)
-- Name: Calificacion Calificacion_ID_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Calificacion"
    ADD CONSTRAINT "Calificacion_ID_departamento_fkey" FOREIGN KEY ("ID_departamento") REFERENCES "Departamentos"("ID_departamento");


--
-- TOC entry 3024 (class 2606 OID 131100)
-- Name: Calificacion Calificacion_ID_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Calificacion"
    ADD CONSTRAINT "Calificacion_ID_usuario_fkey" FOREIGN KEY ("ID_usuario") REFERENCES "Usuario"("idUsuario");


--
-- TOC entry 3014 (class 2606 OID 91326)
-- Name: CuentaPorCobrar CuentaPorCobrar_IdTipoCuentaxCobrar_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "CuentaPorCobrar"
    ADD CONSTRAINT "CuentaPorCobrar_IdTipoCuentaxCobrar_fkey" FOREIGN KEY ("IdTipoCuentaxCobrar") REFERENCES "TipoCuentaCobrar"("ID");


--
-- TOC entry 3015 (class 2606 OID 131085)
-- Name: CuentaPorCobrar CuentaPorCobrar_Idusuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "CuentaPorCobrar"
    ADD CONSTRAINT "CuentaPorCobrar_Idusuario_fkey" FOREIGN KEY ("Idusuario") REFERENCES "Usuario"("idUsuario");


--
-- TOC entry 3060 (class 2606 OID 91531)
-- Name: Departamentos Departamentos_ID_torre_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Departamentos"
    ADD CONSTRAINT "Departamentos_ID_torre_fkey" FOREIGN KEY ("ID_torre") REFERENCES "Torre"("ID_torre");


--
-- TOC entry 3068 (class 2606 OID 139293)
-- Name: EmpleadosvsResidencial EmpleadosvsResidencial_idResidencial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "EmpleadosvsResidencial"
    ADD CONSTRAINT "EmpleadosvsResidencial_idResidencial_fkey" FOREIGN KEY ("idResidencial") REFERENCES "Residencial"("ID_residencial");


--
-- TOC entry 3067 (class 2606 OID 139288)
-- Name: EmpleadosvsResidencial EmpleadosvsResidencial_idUsuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "EmpleadosvsResidencial"
    ADD CONSTRAINT "EmpleadosvsResidencial_idUsuario_fkey" FOREIGN KEY ("idUsuario") REFERENCES "Usuario"("idUsuario");


--
-- TOC entry 3034 (class 2606 OID 131115)
-- Name: HistorialMantenimiento HistorialMantenimiento_idUsuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "HistorialMantenimiento"
    ADD CONSTRAINT "HistorialMantenimiento_idUsuario_fkey" FOREIGN KEY ("idUsuario") REFERENCES "Usuario"("idUsuario");


--
-- TOC entry 3035 (class 2606 OID 131186)
-- Name: HistorialMantenimiento HistorialMantenimiento_id_areacomun_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "HistorialMantenimiento"
    ADD CONSTRAINT "HistorialMantenimiento_id_areacomun_fkey" FOREIGN KEY (id_areacomun) REFERENCES "AreasComunes"("ID_areaComunes");


--
-- TOC entry 3061 (class 2606 OID 91551)
-- Name: Inquilino Inquilino_ID_deparamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Inquilino"
    ADD CONSTRAINT "Inquilino_ID_deparamento_fkey" FOREIGN KEY ("ID_deparamento") REFERENCES "Departamentos"("ID_departamento");


--
-- TOC entry 3062 (class 2606 OID 131160)
-- Name: Inquilino Inquilino_ID_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Inquilino"
    ADD CONSTRAINT "Inquilino_ID_usuario_fkey" FOREIGN KEY ("ID_usuario") REFERENCES "Usuario"("idUsuario");


--
-- TOC entry 3065 (class 2606 OID 98321)
-- Name: MantenimientovsResidencial MantenimientovsResidencial_idMatenimiento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MantenimientovsResidencial"
    ADD CONSTRAINT "MantenimientovsResidencial_idMatenimiento_fkey" FOREIGN KEY ("idMatenimiento") REFERENCES "MantenimientoArea"("ID_TipoMantenimiento");


--
-- TOC entry 3066 (class 2606 OID 98326)
-- Name: MantenimientovsResidencial MantenimientovsResidencial_idResidencial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "MantenimientovsResidencial"
    ADD CONSTRAINT "MantenimientovsResidencial_idResidencial_fkey" FOREIGN KEY ("idResidencial") REFERENCES "Residencial"("ID_residencial");


--
-- TOC entry 3063 (class 2606 OID 91556)
-- Name: Municipio Municipio_ID_Provincia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Municipio"
    ADD CONSTRAINT "Municipio_ID_Provincia_fkey" FOREIGN KEY ("ID_Provincia") REFERENCES "Provincia"("ID_provincia");


--
-- TOC entry 3022 (class 2606 OID 131095)
-- Name: NumeroCuenta NumeroCuenta_ID_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "NumeroCuenta"
    ADD CONSTRAINT "NumeroCuenta_ID_usuario_fkey" FOREIGN KEY ("ID_usuario") REFERENCES "Usuario"("idUsuario");


--
-- TOC entry 3059 (class 2606 OID 131155)
-- Name: OwnersVsResidencia OwnersVsResidencia_ID_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OwnersVsResidencia"
    ADD CONSTRAINT "OwnersVsResidencia_ID_usuario_fkey" FOREIGN KEY ("ID_usuario") REFERENCES "Usuario"("idUsuario");


--
-- TOC entry 3058 (class 2606 OID 91526)
-- Name: OwnersVsResidencia OwnersVsResidencia_Id_residencial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "OwnersVsResidencia"
    ADD CONSTRAINT "OwnersVsResidencia_Id_residencial_fkey" FOREIGN KEY ("Id_residencial") REFERENCES "Residencial"("ID_residencial");


--
-- TOC entry 3013 (class 2606 OID 91316)
-- Name: Persona Persona_ID_Sexo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Persona"
    ADD CONSTRAINT "Persona_ID_Sexo_fkey" FOREIGN KEY ("ID_Sexo") REFERENCES sexo("ID_Sexo");


--
-- TOC entry 3045 (class 2606 OID 91471)
-- Name: QuejasLog QuejasLog_ID_EstadoQuejas_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "QuejasLog"
    ADD CONSTRAINT "QuejasLog_ID_EstadoQuejas_fkey" FOREIGN KEY ("ID_EstadoQuejas") REFERENCES "EstadosQuejas"("ID_EstadoQuejas");


--
-- TOC entry 3046 (class 2606 OID 98363)
-- Name: QuejasLog QuejasLog_ID_Queja_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "QuejasLog"
    ADD CONSTRAINT "QuejasLog_ID_Queja_fkey" FOREIGN KEY ("ID_Queja") REFERENCES "historialQuejas"("ID_Quejas");


--
-- TOC entry 3047 (class 2606 OID 131135)
-- Name: QuejasLog QuejasLog_ID_usuarioFrom_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "QuejasLog"
    ADD CONSTRAINT "QuejasLog_ID_usuarioFrom_fkey" FOREIGN KEY ("ID_usuarioFrom") REFERENCES "Usuario"("idUsuario");


--
-- TOC entry 3048 (class 2606 OID 131140)
-- Name: QuejasLog QuejasLog_ID_usuarioTo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "QuejasLog"
    ADD CONSTRAINT "QuejasLog_ID_usuarioTo_fkey" FOREIGN KEY ("ID_usuarioTo") REFERENCES "Usuario"("idUsuario");


--
-- TOC entry 3049 (class 2606 OID 131145)
-- Name: QuejasLog QuejasLog_id_usuarioLog_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "QuejasLog"
    ADD CONSTRAINT "QuejasLog_id_usuarioLog_fkey" FOREIGN KEY ("id_usuarioLog") REFERENCES "Usuario"("idUsuario");


--
-- TOC entry 3054 (class 2606 OID 91496)
-- Name: Residencial Residencial_ID_municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Residencial"
    ADD CONSTRAINT "Residencial_ID_municipio_fkey" FOREIGN KEY ("ID_municipio") REFERENCES "Municipio"("ID_municipio");


--
-- TOC entry 3053 (class 2606 OID 91491)
-- Name: Residencial Residencial_ID_provincia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Residencial"
    ADD CONSTRAINT "Residencial_ID_provincia_fkey" FOREIGN KEY ("ID_provincia") REFERENCES "Provincia"("ID_provincia");


--
-- TOC entry 3055 (class 2606 OID 91501)
-- Name: Residencial Residencial_ID_sector_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Residencial"
    ADD CONSTRAINT "Residencial_ID_sector_fkey" FOREIGN KEY ("ID_sector") REFERENCES "Sector"("ID_sector");


--
-- TOC entry 3056 (class 2606 OID 91506)
-- Name: Residencial Residencial_ID_status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Residencial"
    ADD CONSTRAINT "Residencial_ID_status_fkey" FOREIGN KEY ("ID_status") REFERENCES "StatusResidencial"("ID");


--
-- TOC entry 3018 (class 2606 OID 91341)
-- Name: Roles Roles_ID_residencial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Roles"
    ADD CONSTRAINT "Roles_ID_residencial_fkey" FOREIGN KEY ("ID_residencial") REFERENCES "Residencial"("ID_residencial");


--
-- TOC entry 3017 (class 2606 OID 91336)
-- Name: Roles Roles_idTipo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Roles"
    ADD CONSTRAINT "Roles_idTipo_fkey" FOREIGN KEY ("idTipo") REFERENCES "TipoUsuario"("idTipoUsuario");


--
-- TOC entry 3019 (class 2606 OID 131090)
-- Name: Roles Roles_idUsuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Roles"
    ADD CONSTRAINT "Roles_idUsuario_fkey" FOREIGN KEY ("idUsuario") REFERENCES "Usuario"("idUsuario");


--
-- TOC entry 3064 (class 2606 OID 91561)
-- Name: Sector Sector_ID_Municipio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Sector"
    ADD CONSTRAINT "Sector_ID_Municipio_fkey" FOREIGN KEY ("ID_Municipio") REFERENCES "Municipio"("ID_municipio");


--
-- TOC entry 3073 (class 2606 OID 180255)
-- Name: ServiciosPredeterminados ServiciosPredeterminados_idServicio_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "ServiciosPredeterminados"
    ADD CONSTRAINT "ServiciosPredeterminados_idServicio_fkey" FOREIGN KEY ("idServicio") REFERENCES "Servicios"("ID_servicio");


--
-- TOC entry 3072 (class 2606 OID 180250)
-- Name: ServiciosPredeterminados ServiciosPredeterminados_idTipopredeterminado_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "ServiciosPredeterminados"
    ADD CONSTRAINT "ServiciosPredeterminados_idTipopredeterminado_fkey" FOREIGN KEY ("idTipopredeterminado") REFERENCES "TipoPredeterminadoserivios"(numserial);


--
-- TOC entry 3016 (class 2606 OID 98331)
-- Name: Servicios Servicios_idResidencial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Servicios"
    ADD CONSTRAINT "Servicios_idResidencial_fkey" FOREIGN KEY ("idResidencial") REFERENCES "Residencial"("ID_residencial");


--
-- TOC entry 3050 (class 2606 OID 98379)
-- Name: SolicitudCompra SolicitudCompra_ID_departamento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "SolicitudCompra"
    ADD CONSTRAINT "SolicitudCompra_ID_departamento_fkey" FOREIGN KEY ("ID_departamento") REFERENCES "Departamentos"("ID_departamento");


--
-- TOC entry 3051 (class 2606 OID 131150)
-- Name: SolicitudCompra SolicitudCompra_ID_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "SolicitudCompra"
    ADD CONSTRAINT "SolicitudCompra_ID_usuario_fkey" FOREIGN KEY ("ID_usuario") REFERENCES "Usuario"("idUsuario");


--
-- TOC entry 3052 (class 2606 OID 139279)
-- Name: SolicitudCompra SolicitudCompra_idResidencial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "SolicitudCompra"
    ADD CONSTRAINT "SolicitudCompra_idResidencial_fkey" FOREIGN KEY ("idResidencial") REFERENCES "Residencial"("ID_residencial");


--
-- TOC entry 3069 (class 2606 OID 139305)
-- Name: SolicitudEmpleados SolicitudEmpleados_idResidencial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "SolicitudEmpleados"
    ADD CONSTRAINT "SolicitudEmpleados_idResidencial_fkey" FOREIGN KEY ("idResidencial") REFERENCES "Residencial"("ID_residencial");


--
-- TOC entry 3070 (class 2606 OID 139310)
-- Name: SolicitudEmpleados SolicitudEmpleados_idUser_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "SolicitudEmpleados"
    ADD CONSTRAINT "SolicitudEmpleados_idUser_fkey" FOREIGN KEY ("idUser") REFERENCES "Usuario"("idUsuario");


--
-- TOC entry 3071 (class 2606 OID 180242)
-- Name: TipoPredeterminadoserivios TipoPredeterminadoserivios_idResidencial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "TipoPredeterminadoserivios"
    ADD CONSTRAINT "TipoPredeterminadoserivios_idResidencial_fkey" FOREIGN KEY ("idResidencial") REFERENCES "Residencial"("ID_residencial");


--
-- TOC entry 3036 (class 2606 OID 91431)
-- Name: TipoQuejas TipoQuejas_ID_dirigido_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "TipoQuejas"
    ADD CONSTRAINT "TipoQuejas_ID_dirigido_fkey" FOREIGN KEY ("ID_dirigido") REFERENCES "DirigidoQueja"("ID_dirigido");


--
-- TOC entry 3037 (class 2606 OID 98354)
-- Name: TipoQuejas TipoQuejas_idResidencial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "TipoQuejas"
    ADD CONSTRAINT "TipoQuejas_idResidencial_fkey" FOREIGN KEY ("idResidencial") REFERENCES "Residencial"("ID_residencial");


--
-- TOC entry 3026 (class 2606 OID 91376)
-- Name: TipoUsuarioVSPermisos TipoUsuarioVSPermisos_idPermiso_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "TipoUsuarioVSPermisos"
    ADD CONSTRAINT "TipoUsuarioVSPermisos_idPermiso_fkey" FOREIGN KEY ("idPermiso") REFERENCES "Permisos"("idPermiso");


--
-- TOC entry 3025 (class 2606 OID 91371)
-- Name: TipoUsuarioVSPermisos TipoUsuarioVSPermisos_idTipoUsuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "TipoUsuarioVSPermisos"
    ADD CONSTRAINT "TipoUsuarioVSPermisos_idTipoUsuario_fkey" FOREIGN KEY ("idTipoUsuario") REFERENCES "TipoUsuario"("idTipoUsuario");


--
-- TOC entry 3057 (class 2606 OID 91511)
-- Name: Torre Torre_ID_residencial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Torre"
    ADD CONSTRAINT "Torre_ID_residencial_fkey" FOREIGN KEY ("ID_residencial") REFERENCES "Residencial"("ID_residencial");


--
-- TOC entry 3020 (class 2606 OID 91346)
-- Name: Usuario Usuario_IdPersona_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Usuario"
    ADD CONSTRAINT "Usuario_IdPersona_fkey" FOREIGN KEY ("IdPersona") REFERENCES "Persona"("IdPersona");


--
-- TOC entry 3021 (class 2606 OID 91351)
-- Name: Usuario Usuario_idStatusUsuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Usuario"
    ADD CONSTRAINT "Usuario_idStatusUsuario_fkey" FOREIGN KEY ("idStatusUsuario") REFERENCES "Status_usuarios"("ID_status");


--
-- TOC entry 3039 (class 2606 OID 91451)
-- Name: historialQuejas historialQuejas_ID_EstadoQuejas_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "historialQuejas"
    ADD CONSTRAINT "historialQuejas_ID_EstadoQuejas_fkey" FOREIGN KEY ("ID_EstadoQuejas") REFERENCES "EstadosQuejas"("ID_EstadoQuejas");


--
-- TOC entry 3040 (class 2606 OID 131120)
-- Name: historialQuejas historialQuejas_ID_usuarioFrom_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "historialQuejas"
    ADD CONSTRAINT "historialQuejas_ID_usuarioFrom_fkey" FOREIGN KEY ("ID_usuarioFrom") REFERENCES "Usuario"("idUsuario");


--
-- TOC entry 3041 (class 2606 OID 131125)
-- Name: historialQuejas historialQuejas_ID_usuarioTo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "historialQuejas"
    ADD CONSTRAINT "historialQuejas_ID_usuarioTo_fkey" FOREIGN KEY ("ID_usuarioTo") REFERENCES "Usuario"("idUsuario");


--
-- TOC entry 3042 (class 2606 OID 131130)
-- Name: historialQuejas historialQuejas_idModifiedby_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "historialQuejas"
    ADD CONSTRAINT "historialQuejas_idModifiedby_fkey" FOREIGN KEY ("idModifiedby") REFERENCES "Usuario"("idUsuario");


--
-- TOC entry 3043 (class 2606 OID 180271)
-- Name: historialQuejas historialQuejas_idStatus_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "historialQuejas"
    ADD CONSTRAINT "historialQuejas_idStatus_fkey" FOREIGN KEY ("idStatus") REFERENCES "StatusQuejas"(id);


--
-- TOC entry 3044 (class 2606 OID 180276)
-- Name: historialQuejas historialQuejas_id_Residencial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "historialQuejas"
    ADD CONSTRAINT "historialQuejas_id_Residencial_fkey" FOREIGN KEY ("id_Residencial") REFERENCES "Residencial"("ID_residencial");


--
-- TOC entry 3038 (class 2606 OID 91436)
-- Name: historialQuejas historialQuejas_id_TipoQueja_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "historialQuejas"
    ADD CONSTRAINT "historialQuejas_id_TipoQueja_fkey" FOREIGN KEY ("id_TipoQueja") REFERENCES "TipoQuejas"("ID_TipoQuejas");


-- Completed on 2021-04-20 23:53:57

--
-- PostgreSQL database dump complete
--

