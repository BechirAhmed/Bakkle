--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.6
-- Dumped by pg_dump version 9.3.8
-- Started on 2015-06-24 14:02:38 EDT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 198 (class 1259 OID 19375)
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: root; Tablespace: 
--

DROP TABLE IF EXISTS django_migrations;

CREATE TABLE django_migrations (
    id integer NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE public.django_migrations OWNER TO root;

--
-- TOC entry 199 (class 1259 OID 19381)
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE django_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_migrations_id_seq OWNER TO root;

--
-- TOC entry 2900 (class 0 OID 0)
-- Dependencies: 199
-- Name: django_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE django_migrations_id_seq OWNED BY django_migrations.id;


--
-- TOC entry 2784 (class 2604 OID 19424)
-- Name: id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY django_migrations ALTER COLUMN id SET DEFAULT nextval('django_migrations_id_seq'::regclass);


--
-- TOC entry 2894 (class 0 OID 19375)
-- Dependencies: 198
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: root
--

INSERT INTO django_migrations (app, name, applied) VALUES
('account','0001_initial','2015-06-24 17:25:35.756587+00'),
('contenttypes','0001_initial','2015-06-24 17:25:36.044017+00'),
('auth','0001_initial','2015-06-24 17:25:36.326227+00'),
('admin','0001_initial','2015-06-24 17:25:36.608629+00'),
('contenttypes','0002_remove_content_type_name','2015-06-24 17:25:36.891151+00'),
('auth','0002_alter_permission_name_max_length','2015-06-24 17:25:37.174027+00'),
('auth','0003_alter_user_email_max_length','2015-06-24 17:25:37.456576+00'),
('auth','0004_alter_user_username_opts','2015-06-24 17:25:37.739101+00'),
('auth','0005_alter_user_last_login_null','2015-06-24 17:25:38.021612+00'),
('auth','0006_require_contenttypes_0002','2015-06-24 17:25:38.304279+00'),
('items','0001_initial','2015-06-24 17:25:38.586728+00'),
('chat','0001_initial','2015-06-24 17:25:38.869887+00'),
('sessions','0001_initial','2015-06-24 17:25:39.15223+00'),
('timing','0001_initial','2015-06-24 17:25:39.434979+00');


--
-- TOC entry 2901 (class 0 OID 0)
-- Dependencies: 199
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('django_migrations_id_seq', 27, true);


--
-- TOC entry 2786 (class 2606 OID 19495)
-- Name: django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: root; Tablespace: 
--

ALTER TABLE ONLY django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


-- Completed on 2015-06-24 14:02:45 EDT

--
-- PostgreSQL database dump complete
--

