--
-- PostgreSQL database dump
--

\restrict 6OshWpl86FA8ahm75KGejkR01hWovj6U3yK9nzTev9f8f9P9eFyacnUDsReko2D

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2026-02-26 15:59:01

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5011 (class 1262 OID 155659)
-- Name: pizzaria_demo; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE pizzaria_demo WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'br';


\unrestrict 6OshWpl86FA8ahm75KGejkR01hWovj6U3yK9nzTev9f8f9P9eFyacnUDsReko2D
\connect pizzaria_demo
\restrict 6OshWpl86FA8ahm75KGejkR01hWovj6U3yK9nzTev9f8f9P9eFyacnUDsReko2D

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 155661)
-- Name: admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admins (
    id integer NOT NULL,
    username character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL
);


--
-- TOC entry 217 (class 1259 OID 155660)
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5012 (class 0 OID 0)
-- Dependencies: 217
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admins_id_seq OWNED BY public.admins.id;


--
-- TOC entry 232 (class 1259 OID 163880)
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    title character varying(200),
    description text,
    icon character varying(10),
    image_url character varying(255),
    slug character varying(100) NOT NULL,
    "order" integer NOT NULL,
    is_active boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone
);


--
-- TOC entry 231 (class 1259 OID 163879)
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5013 (class 0 OID 0)
-- Dependencies: 231
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- TOC entry 226 (class 1259 OID 155703)
-- Name: order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_items (
    id integer NOT NULL,
    order_id integer NOT NULL,
    product_id integer,
    quantity integer NOT NULL,
    unit_price numeric(10,2) NOT NULL,
    product_name character varying(150)
);


--
-- TOC entry 225 (class 1259 OID 155702)
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5014 (class 0 OID 0)
-- Dependencies: 225
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- TOC entry 222 (class 1259 OID 155679)
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    total numeric(10,2),
    created_at timestamp without time zone NOT NULL,
    customer_name character varying(120),
    customer_phone character varying(20),
    total_amount double precision,
    status character varying(30) DEFAULT 'pending'::character varying,
    restaurant_id integer,
    payment_status character varying(30) DEFAULT 'pending'::character varying,
    mercadopago_preference_id character varying(255),
    mercadopago_payment_id character varying(255),
    delivery_fee double precision DEFAULT 0.0
);


--
-- TOC entry 221 (class 1259 OID 155678)
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5015 (class 0 OID 0)
-- Dependencies: 221
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- TOC entry 228 (class 1259 OID 163852)
-- Name: page_sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.page_sections (
    id integer NOT NULL,
    name character varying(120) NOT NULL,
    title character varying(200),
    subtitle text,
    content text,
    image_url character varying(255),
    link character varying(255),
    "order" integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 227 (class 1259 OID 163851)
-- Name: page_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.page_sections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5016 (class 0 OID 0)
-- Dependencies: 227
-- Name: page_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.page_sections_id_seq OWNED BY public.page_sections.id;


--
-- TOC entry 230 (class 1259 OID 163866)
-- Name: pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pages (
    id integer NOT NULL,
    slug character varying(160) NOT NULL,
    title character varying(200),
    content text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 229 (class 1259 OID 163865)
-- Name: pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5017 (class 0 OID 0)
-- Dependencies: 229
-- Name: pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pages_id_seq OWNED BY public.pages.id;


--
-- TOC entry 224 (class 1259 OID 155687)
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(160) NOT NULL,
    description text,
    price numeric(10,2) NOT NULL,
    category_id integer NOT NULL,
    image_url character varying(255),
    is_active boolean DEFAULT true
);


--
-- TOC entry 223 (class 1259 OID 155686)
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5018 (class 0 OID 0)
-- Dependencies: 223
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- TOC entry 234 (class 1259 OID 172045)
-- Name: restaurants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.restaurants (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    slug character varying(100) NOT NULL,
    mercadopago_access_token character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- TOC entry 233 (class 1259 OID 172044)
-- Name: restaurants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.restaurants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5019 (class 0 OID 0)
-- Dependencies: 233
-- Name: restaurants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.restaurants_id_seq OWNED BY public.restaurants.id;


--
-- TOC entry 220 (class 1259 OID 155671)
-- Name: sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sections (
    id integer NOT NULL,
    name character varying(120) NOT NULL,
    "order" integer NOT NULL
);


--
-- TOC entry 219 (class 1259 OID 155670)
-- Name: sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5020 (class 0 OID 0)
-- Dependencies: 219
-- Name: sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sections_id_seq OWNED BY public.sections.id;


--
-- TOC entry 4782 (class 2604 OID 155664)
-- Name: admins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins ALTER COLUMN id SET DEFAULT nextval('public.admins_id_seq'::regclass);


--
-- TOC entry 4797 (class 2604 OID 163883)
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- TOC entry 4790 (class 2604 OID 155706)
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- TOC entry 4784 (class 2604 OID 155682)
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- TOC entry 4791 (class 2604 OID 163855)
-- Name: page_sections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_sections ALTER COLUMN id SET DEFAULT nextval('public.page_sections_id_seq'::regclass);


--
-- TOC entry 4794 (class 2604 OID 163869)
-- Name: pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages ALTER COLUMN id SET DEFAULT nextval('public.pages_id_seq'::regclass);


--
-- TOC entry 4788 (class 2604 OID 155690)
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- TOC entry 4799 (class 2604 OID 172048)
-- Name: restaurants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurants ALTER COLUMN id SET DEFAULT nextval('public.restaurants_id_seq'::regclass);


--
-- TOC entry 4783 (class 2604 OID 155674)
-- Name: sections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections ALTER COLUMN id SET DEFAULT nextval('public.sections_id_seq'::regclass);


--
-- TOC entry 4989 (class 0 OID 155661)
-- Dependencies: 218
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.admins VALUES (1, 'admin', '$bcrypt-sha256$v=2,t=2b,r=12$Fe.1thrnKOkUf.dOb9qpOe$B/HifM0y/Tf6stBWXIShzLMTz9CcFEK');


--
-- TOC entry 5003 (class 0 OID 163880)
-- Dependencies: 232
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.categories VALUES (6, 'pizzas', 'Pizzas', 'Clássicas e especiais com massa artesanal.', '🍕', NULL, 'pizzas', 1, true, '2026-02-20 00:58:54.987216-03', NULL);
INSERT INTO public.categories VALUES (7, 'lanches', 'Lanches', 'Combos completos para matar a fome.', '🍔', NULL, 'lanches', 2, true, '2026-02-20 00:58:54.987216-03', NULL);
INSERT INTO public.categories VALUES (8, 'bebidas', 'Bebidas', 'Refrigerantes, sucos e águas geladas.', '🥤', NULL, 'bebidas', 3, true, '2026-02-20 00:58:54.987216-03', NULL);


--
-- TOC entry 4997 (class 0 OID 155703)
-- Dependencies: 226
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.order_items VALUES (1, 1, NULL, 1, 39.90, 'Margherita Clássica');
INSERT INTO public.order_items VALUES (2, 2, 16, 1, 14.90, 'Milkshake 400ml');
INSERT INTO public.order_items VALUES (3, 3, 10, 1, 46.90, 'Quatro Queijos');
INSERT INTO public.order_items VALUES (4, 4, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (5, 5, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (6, 6, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (7, 7, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (8, 8, NULL, 1, 10.00, 'Item Teste');
INSERT INTO public.order_items VALUES (9, 9, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (10, 10, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (11, 11, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (12, 12, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (13, 13, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (14, 14, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (15, 15, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (16, 16, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (17, 17, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (18, 18, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (19, 19, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (20, 20, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (21, 21, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (22, 22, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (23, 23, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (24, 24, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (25, 25, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (26, 25, NULL, 1, 5.00, 'Taxa de entrega');
INSERT INTO public.order_items VALUES (27, 26, NULL, 1, 14.90, 'Milkshake 400ml');
INSERT INTO public.order_items VALUES (28, 26, NULL, 1, 5.00, 'Taxa de entrega');
INSERT INTO public.order_items VALUES (29, 27, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (30, 27, NULL, 1, 5.00, 'Taxa de entrega');
INSERT INTO public.order_items VALUES (31, 28, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (32, 28, NULL, 1, 5.00, 'Taxa de entrega');
INSERT INTO public.order_items VALUES (33, 29, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (34, 29, NULL, 1, 5.00, 'Taxa de entrega');
INSERT INTO public.order_items VALUES (35, 30, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (36, 30, NULL, 1, 5.00, 'Taxa de entrega');
INSERT INTO public.order_items VALUES (37, 31, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (38, 31, NULL, 1, 5.00, 'Taxa de entrega');
INSERT INTO public.order_items VALUES (39, 32, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (40, 32, NULL, 1, 5.00, 'Taxa de entrega');
INSERT INTO public.order_items VALUES (41, 33, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (42, 33, NULL, 1, 5.00, 'Taxa de entrega');
INSERT INTO public.order_items VALUES (43, 34, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (44, 34, NULL, 1, 5.00, 'Taxa de entrega');
INSERT INTO public.order_items VALUES (45, 35, NULL, 1, 8.90, 'Chá Gelado 400ml');
INSERT INTO public.order_items VALUES (46, 35, NULL, 1, 5.00, 'Taxa de entrega');


--
-- TOC entry 4993 (class 0 OID 155679)
-- Dependencies: 222
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.orders VALUES (1, NULL, '2026-02-23 05:52:10.016098', 'teste', NULL, 39.9, 'pending', NULL, 'pending', NULL, NULL, 0);
INSERT INTO public.orders VALUES (2, NULL, '2026-02-23 06:00:32.82204', 'teste', NULL, 17.64, 'pending', NULL, 'pending', NULL, NULL, 0);
INSERT INTO public.orders VALUES (3, NULL, '2026-02-23 14:20:03.048295', 'teste', NULL, 49.64, 'pending', NULL, 'pending', NULL, NULL, 0);
INSERT INTO public.orders VALUES (4, NULL, '2026-02-24 19:30:22.075837', 'rafael', NULL, 13.9, 'pending', 1, 'pending', NULL, NULL, 5);
INSERT INTO public.orders VALUES (5, NULL, '2026-02-24 19:32:14.952922', 'rafael', NULL, 13.9, 'pending', 1, 'pending', NULL, NULL, 5);
INSERT INTO public.orders VALUES (6, NULL, '2026-02-24 19:36:39.88883', 'rafael', NULL, 13.9, 'pending', 1, 'pending', NULL, NULL, 5);
INSERT INTO public.orders VALUES (7, NULL, '2026-02-24 19:39:28.786018', 'rafael', NULL, 13.9, 'pending', 1, 'pending', NULL, NULL, 5);
INSERT INTO public.orders VALUES (8, NULL, '2026-02-24 19:58:54.792128', 'Teste Checkout', '11999999999', 10, 'pending', 1, 'pending', NULL, NULL, 0);
INSERT INTO public.orders VALUES (9, NULL, '2026-02-24 19:59:50.719856', 'rafael', NULL, 13.9, 'pending', 1, 'pending', NULL, NULL, 5);
INSERT INTO public.orders VALUES (10, NULL, '2026-02-25 02:13:28.457304', 'rafael', NULL, 13.9, 'pending', 1, 'pending', NULL, NULL, 5);
INSERT INTO public.orders VALUES (12, NULL, '2026-02-25 02:21:30.999494', 'rafael', NULL, 13.9, 'pending', 1, 'pending', NULL, NULL, 5);
INSERT INTO public.orders VALUES (11, NULL, '2026-02-25 02:18:39.511417', 'rafael', NULL, 13.9, 'pending', 1, 'pending', '171906724-fa5f1c4f-f5ad-42fa-b99d-4a21d9b15550', NULL, 5);
INSERT INTO public.orders VALUES (13, NULL, '2026-02-25 02:35:02.438735', 'rafael', NULL, 13.9, 'pending', 1, 'pending', '171906724-f86e6739-fade-412c-adf1-638d74e2fd0a', NULL, 5);
INSERT INTO public.orders VALUES (14, NULL, '2026-02-25 02:43:08.511649', 'rafael', NULL, 13.9, 'pending', 1, 'pending', '171906724-de99788c-578a-46e6-a189-d1459a9fed4a', NULL, 5);
INSERT INTO public.orders VALUES (15, NULL, '2026-02-25 02:44:23.055959', 'rafael', NULL, 13.9, 'pending', 1, 'pending', '171906724-548770cd-4d89-4c06-8345-0134d4e1a797', NULL, 5);
INSERT INTO public.orders VALUES (16, NULL, '2026-02-25 02:45:02.048869', 'rafael', NULL, 13.9, 'pending', 1, 'pending', '171906724-4fa072a9-e5ad-46e9-96d3-7e983c0bd1a2', NULL, 5);
INSERT INTO public.orders VALUES (17, NULL, '2026-02-25 02:51:48.02006', 'rafael', NULL, 13.9, 'pending', 1, 'pending', '171906724-e417d54c-abcb-420e-a2e5-8affd4dc7955', NULL, 5);
INSERT INTO public.orders VALUES (18, NULL, '2026-02-25 02:56:32.584428', 'rafael', NULL, 13.9, 'pending', 1, 'pending', '171906724-8b62cef5-d4a3-495c-870f-f6ea6b52d80d', NULL, 5);
INSERT INTO public.orders VALUES (19, NULL, '2026-02-25 02:57:31.53928', 'rafael', NULL, 13.9, 'pending', 1, 'pending', '171906724-c9f89e50-6009-4c9d-a33b-74fea9437712', NULL, 5);
INSERT INTO public.orders VALUES (20, NULL, '2026-02-25 03:00:52.593153', 'rafael', NULL, 13.9, 'pending', 1, 'pending', '171906724-9ded6226-2169-42e1-b620-a82e14c4a72b', NULL, 5);
INSERT INTO public.orders VALUES (21, NULL, '2026-02-25 03:04:56.723522', 'rafael', NULL, 13.9, 'pending', 1, 'pending', '171906724-5dd19778-dbf4-4937-8468-1aca1144b791', NULL, 5);
INSERT INTO public.orders VALUES (22, NULL, '2026-02-25 03:09:00.053244', 'rafael', NULL, 13.9, 'pending', 1, 'pending', '171906724-0da10095-6508-43c1-8543-714309ee3057', NULL, 5);
INSERT INTO public.orders VALUES (23, NULL, '2026-02-25 03:10:33.105514', 'rafael', NULL, 13.9, 'pending', 1, 'pending', '171906724-2e2a3db2-2605-4866-afc9-c74b19ca2639', NULL, 5);
INSERT INTO public.orders VALUES (24, NULL, '2026-02-25 03:13:09.436642', 'rafael', NULL, 13.9, 'pending', 1, 'pending', '171906724-1bddc21d-0cd1-429c-b197-f13b9292f7c8', NULL, 5);
INSERT INTO public.orders VALUES (25, NULL, '2026-02-26 03:47:00.38733', 'rafael', NULL, 18.9, 'pending', 1, 'pending', '171906724-c01f2028-31e0-43d4-bc1b-aaa12a11f814', NULL, 5);
INSERT INTO public.orders VALUES (26, NULL, '2026-02-26 03:49:56.334623', 'Rafael', NULL, 24.9, 'pending', 1, 'pending', '171906724-ddcded35-76f9-42f0-a62e-00ecd073f8c5', NULL, 5);
INSERT INTO public.orders VALUES (27, NULL, '2026-02-26 04:18:19.304247', 'rafael', NULL, 18.9, 'pending', 1, 'pending', '171906724-3e33e1e6-e71c-43aa-831f-c85036232e78', NULL, 5);
INSERT INTO public.orders VALUES (28, NULL, '2026-02-26 04:42:32.218152', 'rafael', NULL, 18.9, 'pending', 1, 'pending', '171906724-f32c9bf1-069b-4779-90a8-74d010e91a98', NULL, 5);
INSERT INTO public.orders VALUES (29, NULL, '2026-02-26 04:44:25.722207', 'rafael', NULL, 18.9, 'pending', 1, 'pending', '171906724-961fa9eb-ead7-45fa-8e21-c272668d016e', NULL, 5);
INSERT INTO public.orders VALUES (30, NULL, '2026-02-26 04:47:47.419131', 'rafael', NULL, 18.9, 'pending', 1, 'pending', '171906724-df08a965-69ef-4dce-b09b-c11c763b0d06', NULL, 5);
INSERT INTO public.orders VALUES (31, NULL, '2026-02-26 04:52:33.260526', 'rafael', NULL, 18.9, 'pending', 1, 'pending', '171906724-7c48587a-db7a-4737-bd18-2d49e12f295e', NULL, 5);
INSERT INTO public.orders VALUES (32, NULL, '2026-02-26 05:07:06.45165', 'rafael', NULL, 18.9, 'pending', 1, 'pending', '171906724-41f5a92c-12b8-41f7-97d1-c3cbd636649e', NULL, 5);
INSERT INTO public.orders VALUES (33, NULL, '2026-02-26 05:27:48.679222', 'rafael', NULL, 18.9, 'pending', 1, 'pending', NULL, NULL, 5);
INSERT INTO public.orders VALUES (34, NULL, '2026-02-26 16:46:59.253134', 'rafael', NULL, 18.9, 'pending', 1, 'pending', '171906724-3ce5c680-b7f5-4862-b030-1e7343cc529a', NULL, 5);
INSERT INTO public.orders VALUES (35, NULL, '2026-02-26 16:52:35.596297', 'rafael', NULL, 18.9, 'pending', 1, 'pending', '171906724-bc1bdac9-88a8-4be5-b02b-cfcdc71de308', NULL, 5);


--
-- TOC entry 4999 (class 0 OID 163852)
-- Dependencies: 228
-- Data for Name: page_sections; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 5001 (class 0 OID 163866)
-- Dependencies: 230
-- Data for Name: pages; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 4995 (class 0 OID 155687)
-- Dependencies: 224
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.products VALUES (8, 'Margherita Clássica', 'Molho artesanal, mussarela, tomate italiano, manjericão e azeite extra virgem.', 39.90, 6, 'cf070fcd3e6542eab202e0a0a0585db6.avif', true);
INSERT INTO public.products VALUES (9, 'Pepperoni Supreme', 'Mussarela, pepperoni crocante, molho rústico e finalização com orégano.', 44.90, 6, '34c33b9543bb4b5ea8e6083c5cd797a9.webp', true);
INSERT INTO public.products VALUES (10, 'Quatro Queijos', 'Mussarela, gorgonzola, parmesão, provolone e toque de mel artesanal.', 46.90, 6, '31e3aebbac874922ad23aeb9f4200d51.avif', true);
INSERT INTO public.products VALUES (11, 'Combo Smash Clássico', 'Burger smash com cheddar, batatas crocantes e refrigerante 350ml.', 26.90, 7, '0c6ea64baecf4dc0bcbfb897eb94c18e.jpg', true);
INSERT INTO public.products VALUES (12, 'Combo Bacon Cheddar', 'Hambúrguer com bacon e cheddar, batatas rústicas e bebida à escolha.', 31.90, 7, 'b23be7c248bb4297a9a96dc5099fa97d.jpg', true);
INSERT INTO public.products VALUES (13, 'Combo Família', 'Cheeseburger completo, batatas generosas e bebida grande.', 44.90, 7, '5f8c08ecd05946b19ab38ffbe584ff18.jpg', true);
INSERT INTO public.products VALUES (16, 'Milkshake 400ml', 'Chocolate, baunilha ou morango com chantilly.', 14.90, 8, '01f56195f844451e933e026ac36fc027.jpg', true);
INSERT INTO public.products VALUES (15, 'Refrigerante 1,5L', 'Ideal para dividir. Opções variadas no gelo.', 12.90, 8, '619391ae3c27407abcb2d61a16e88538.jpg', true);
INSERT INTO public.products VALUES (14, 'Refrigerante Lata 350ml', 'Coca, Guaraná, Sprite ou Fanta bem gelados.', 6.90, 8, 'e40dedcbefb842ef96e6a0d71579391a.jpg', true);


--
-- TOC entry 5005 (class 0 OID 172045)
-- Dependencies: 234
-- Data for Name: restaurants; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.restaurants VALUES (1, 'Pizzaria Demo', 'pizzaria-demo', 'TEST-2446436736709243-040921-fed94a5bb0191a0e1903980cdd8485a4-171906724', '2026-02-24 17:39:14.95548');


--
-- TOC entry 4991 (class 0 OID 155671)
-- Dependencies: 220
-- Data for Name: sections; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 5021 (class 0 OID 0)
-- Dependencies: 217
-- Name: admins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.admins_id_seq', 1, true);


--
-- TOC entry 5022 (class 0 OID 0)
-- Dependencies: 231
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categories_id_seq', 8, true);


--
-- TOC entry 5023 (class 0 OID 0)
-- Dependencies: 225
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_items_id_seq', 46, true);


--
-- TOC entry 5024 (class 0 OID 0)
-- Dependencies: 221
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.orders_id_seq', 35, true);


--
-- TOC entry 5025 (class 0 OID 0)
-- Dependencies: 227
-- Name: page_sections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.page_sections_id_seq', 3, true);


--
-- TOC entry 5026 (class 0 OID 0)
-- Dependencies: 229
-- Name: pages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pages_id_seq', 1, false);


--
-- TOC entry 5027 (class 0 OID 0)
-- Dependencies: 223
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.products_id_seq', 16, true);


--
-- TOC entry 5028 (class 0 OID 0)
-- Dependencies: 233
-- Name: restaurants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.restaurants_id_seq', 1, true);


--
-- TOC entry 5029 (class 0 OID 0)
-- Dependencies: 219
-- Name: sections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sections_id_seq', 1, true);


--
-- TOC entry 4801 (class 2606 OID 155666)
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- TOC entry 4803 (class 2606 OID 155668)
-- Name: admins admins_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_username_key UNIQUE (username);


--
-- TOC entry 4831 (class 2606 OID 163888)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- TOC entry 4833 (class 2606 OID 163890)
-- Name: categories categories_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_slug_key UNIQUE (slug);


--
-- TOC entry 4819 (class 2606 OID 155708)
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- TOC entry 4810 (class 2606 OID 155684)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- TOC entry 4822 (class 2606 OID 163863)
-- Name: page_sections page_sections_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_sections
    ADD CONSTRAINT page_sections_name_key UNIQUE (name);


--
-- TOC entry 4824 (class 2606 OID 163861)
-- Name: page_sections page_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_sections
    ADD CONSTRAINT page_sections_pkey PRIMARY KEY (id);


--
-- TOC entry 4827 (class 2606 OID 163875)
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- TOC entry 4829 (class 2606 OID 163877)
-- Name: pages pages_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_slug_key UNIQUE (slug);


--
-- TOC entry 4814 (class 2606 OID 155694)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- TOC entry 4837 (class 2606 OID 172052)
-- Name: restaurants restaurants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_pkey PRIMARY KEY (id);


--
-- TOC entry 4839 (class 2606 OID 172054)
-- Name: restaurants restaurants_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_slug_key UNIQUE (slug);


--
-- TOC entry 4807 (class 2606 OID 155676)
-- Name: sections sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_pkey PRIMARY KEY (id);


--
-- TOC entry 4804 (class 1259 OID 155669)
-- Name: ix_admins_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_admins_id ON public.admins USING btree (id);


--
-- TOC entry 4834 (class 1259 OID 163891)
-- Name: ix_categories_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_categories_id ON public.categories USING btree (id);


--
-- TOC entry 4815 (class 1259 OID 155720)
-- Name: ix_order_items_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_order_items_id ON public.order_items USING btree (id);


--
-- TOC entry 4816 (class 1259 OID 155721)
-- Name: ix_order_items_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_order_items_order_id ON public.order_items USING btree (order_id);


--
-- TOC entry 4817 (class 1259 OID 155719)
-- Name: ix_order_items_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_order_items_product_id ON public.order_items USING btree (product_id);


--
-- TOC entry 4808 (class 1259 OID 155685)
-- Name: ix_orders_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_orders_id ON public.orders USING btree (id);


--
-- TOC entry 4820 (class 1259 OID 163864)
-- Name: ix_page_sections_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_page_sections_id ON public.page_sections USING btree (id);


--
-- TOC entry 4825 (class 1259 OID 163878)
-- Name: ix_pages_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_pages_id ON public.pages USING btree (id);


--
-- TOC entry 4811 (class 1259 OID 155701)
-- Name: ix_products_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_products_id ON public.products USING btree (id);


--
-- TOC entry 4812 (class 1259 OID 155700)
-- Name: ix_products_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_products_section_id ON public.products USING btree (category_id);


--
-- TOC entry 4835 (class 1259 OID 172055)
-- Name: ix_restaurants_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_restaurants_id ON public.restaurants USING btree (id);


--
-- TOC entry 4805 (class 1259 OID 155677)
-- Name: ix_sections_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_sections_id ON public.sections USING btree (id);


--
-- TOC entry 4842 (class 2606 OID 155709)
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- TOC entry 4840 (class 2606 OID 172059)
-- Name: orders orders_restaurant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id) ON DELETE SET NULL;


--
-- TOC entry 4841 (class 2606 OID 163905)
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;


-- Completed on 2026-02-26 15:59:02

--
-- PostgreSQL database dump complete
--

\unrestrict 6OshWpl86FA8ahm75KGejkR01hWovj6U3yK9nzTev9f8f9P9eFyacnUDsReko2D

