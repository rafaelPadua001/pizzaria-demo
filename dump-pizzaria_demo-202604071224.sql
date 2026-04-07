--
-- PostgreSQL database dump
--

\restrict uIKRF9hwUU3dRZxQgYXIX4YvnOj3qIFDUulPHqnlsea1u9OHWxqiPWxaZ0IosQ0

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2026-04-07 12:24:58

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
-- TOC entry 5068 (class 1262 OID 155659)
-- Name: pizzaria_demo; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE pizzaria_demo WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'br';


\unrestrict uIKRF9hwUU3dRZxQgYXIX4YvnOj3qIFDUulPHqnlsea1u9OHWxqiPWxaZ0IosQ0
\connect pizzaria_demo
\restrict uIKRF9hwUU3dRZxQgYXIX4YvnOj3qIFDUulPHqnlsea1u9OHWxqiPWxaZ0IosQ0

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
    password_hash character varying(255) NOT NULL,
    role character varying(50),
    restaurant_id integer
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
-- TOC entry 5069 (class 0 OID 0)
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
    updated_at timestamp with time zone,
    restaurant_id integer
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
-- TOC entry 5070 (class 0 OID 0)
-- Dependencies: 231
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- TOC entry 240 (class 1259 OID 196861)
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    type character varying(50) NOT NULL,
    title character varying(150) NOT NULL,
    message text NOT NULL,
    order_id integer,
    is_read boolean NOT NULL,
    created_at timestamp with time zone NOT NULL,
    restaurant_id integer NOT NULL
);


--
-- TOC entry 239 (class 1259 OID 196860)
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5071 (class 0 OID 0)
-- Dependencies: 239
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


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
    product_name character varying(150),
    restaurant_id integer
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
-- TOC entry 5072 (class 0 OID 0)
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
    delivery_fee double precision DEFAULT 0.0,
    order_status character varying(30) DEFAULT 'pending'::character varying,
    session_id character varying(120),
    CONSTRAINT orders_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'paid'::character varying, 'preparing'::character varying, 'ready'::character varying, 'sent'::character varying, 'cancelled'::character varying, 'confirmed'::character varying, 'delivered'::character varying, 'canceled'::character varying])::text[])))
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
-- TOC entry 5073 (class 0 OID 0)
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
-- TOC entry 5074 (class 0 OID 0)
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
-- TOC entry 5075 (class 0 OID 0)
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
    is_active boolean DEFAULT true,
    restaurant_id integer
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
-- TOC entry 5076 (class 0 OID 0)
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
    created_at timestamp without time zone NOT NULL,
    logo_url character varying(255),
    primary_color character varying(40),
    whatsapp_number character varying(30),
    email character varying(150),
    address character varying(255),
    city character varying(120),
    state character varying(60),
    mercadopago_public_key character varying(255),
    assistant_enabled boolean DEFAULT true,
    updated_at timestamp without time zone
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
-- TOC entry 5077 (class 0 OID 0)
-- Dependencies: 233
-- Name: restaurants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.restaurants_id_seq OWNED BY public.restaurants.id;


--
-- TOC entry 236 (class 1259 OID 188770)
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 235 (class 1259 OID 188769)
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5078 (class 0 OID 0)
-- Dependencies: 235
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


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
-- TOC entry 5079 (class 0 OID 0)
-- Dependencies: 219
-- Name: sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sections_id_seq OWNED BY public.sections.id;


--
-- TOC entry 238 (class 1259 OID 188781)
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(150) NOT NULL,
    password_hash character varying(255) NOT NULL,
    role character varying(50) NOT NULL,
    restaurant_id integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 237 (class 1259 OID 188780)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5080 (class 0 OID 0)
-- Dependencies: 237
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4797 (class 2604 OID 155664)
-- Name: admins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins ALTER COLUMN id SET DEFAULT nextval('public.admins_id_seq'::regclass);


--
-- TOC entry 4813 (class 2604 OID 163883)
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- TOC entry 4821 (class 2604 OID 196864)
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- TOC entry 4806 (class 2604 OID 155706)
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- TOC entry 4799 (class 2604 OID 155682)
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- TOC entry 4807 (class 2604 OID 163855)
-- Name: page_sections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_sections ALTER COLUMN id SET DEFAULT nextval('public.page_sections_id_seq'::regclass);


--
-- TOC entry 4810 (class 2604 OID 163869)
-- Name: pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages ALTER COLUMN id SET DEFAULT nextval('public.pages_id_seq'::regclass);


--
-- TOC entry 4804 (class 2604 OID 155690)
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- TOC entry 4815 (class 2604 OID 172048)
-- Name: restaurants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurants ALTER COLUMN id SET DEFAULT nextval('public.restaurants_id_seq'::regclass);


--
-- TOC entry 4817 (class 2604 OID 188773)
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- TOC entry 4798 (class 2604 OID 155674)
-- Name: sections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections ALTER COLUMN id SET DEFAULT nextval('public.sections_id_seq'::regclass);


--
-- TOC entry 4819 (class 2604 OID 188784)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 5040 (class 0 OID 155661)
-- Dependencies: 218
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.admins VALUES (1, 'admin', '$bcrypt-sha256$v=2,t=2b,r=12$Fe.1thrnKOkUf.dOb9qpOe$B/HifM0y/Tf6stBWXIShzLMTz9CcFEK', NULL, NULL);
INSERT INTO public.admins VALUES (2, 'rafael.f.p.faria@hotmail.com', '$bcrypt-sha256$v=2,t=2b,r=12$lxk1lThryZkJ1q6edw7R3O$hTn8iLPnB9qe7qKBmRIaO.XKFMRqfem', NULL, NULL);
INSERT INTO public.admins VALUES (3, 'teste@admin.com', '$bcrypt-sha256$v=2,t=2b,r=12$Vf1nKXvXTF5OAE9yGZKfze$hmVPesXEqWosCTIdMCs6TWUrBiNapyq', NULL, NULL);


--
-- TOC entry 5054 (class 0 OID 163880)
-- Dependencies: 232
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.categories VALUES (6, 'pizzas', 'Pizzas', 'Clássicas e especiais com massa artesanal.', '🍕', NULL, 'pizzas', 1, true, '2026-02-20 00:58:54.987216-03', NULL, NULL);
INSERT INTO public.categories VALUES (7, 'lanches', 'Lanches', 'Combos completos para matar a fome.', '🍔', NULL, 'lanches', 2, true, '2026-02-20 00:58:54.987216-03', NULL, NULL);
INSERT INTO public.categories VALUES (8, 'bebidas', 'Bebidas', 'Refrigerantes, sucos e águas geladas.', '🥤', NULL, 'bebidas', 3, true, '2026-02-20 00:58:54.987216-03', NULL, NULL);


--
-- TOC entry 5062 (class 0 OID 196861)
-- Dependencies: 240
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 5048 (class 0 OID 155703)
-- Dependencies: 226
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.order_items VALUES (95, 84, 9, 1, 44.90, 'Pepperoni Supreme', 1);
INSERT INTO public.order_items VALUES (96, 85, 9, 1, 44.90, 'Pepperoni Supreme', 1);


--
-- TOC entry 5044 (class 0 OID 155679)
-- Dependencies: 222
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.orders VALUES (84, NULL, '2026-03-15 18:17:54.122956', 'rafael', '6191865680', 47.64, 'paid', 1, 'paid', NULL, NULL, 0, 'preparing', '5b960f2b-3c2b-4c22-a539-12c7bdff0c01');
INSERT INTO public.orders VALUES (85, NULL, '2026-03-15 18:18:37.117088', 'rafael', '6191865680', 47.64, 'paid', 1, 'paid', '171906724-c819bd03-d7c9-4e99-96c8-416f8605582e', NULL, 0, 'preparing', '5b960f2b-3c2b-4c22-a539-12c7bdff0c01');


--
-- TOC entry 5050 (class 0 OID 163852)
-- Dependencies: 228
-- Data for Name: page_sections; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 5052 (class 0 OID 163866)
-- Dependencies: 230
-- Data for Name: pages; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 5046 (class 0 OID 155687)
-- Dependencies: 224
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.products VALUES (9, 'Pepperoni Supreme', 'Mussarela, pepperoni crocante, molho rústico e finalização com orégano.', 44.90, 6, '34c33b9543bb4b5ea8e6083c5cd797a9.webp', true, NULL);
INSERT INTO public.products VALUES (10, 'Quatro Queijos', 'Mussarela, gorgonzola, parmesão, provolone e toque de mel artesanal.', 46.90, 6, '31e3aebbac874922ad23aeb9f4200d51.avif', true, NULL);
INSERT INTO public.products VALUES (11, 'Combo Smash Clássico', 'Burger smash com cheddar, batatas crocantes e refrigerante 350ml.', 26.90, 7, '0c6ea64baecf4dc0bcbfb897eb94c18e.jpg', true, NULL);
INSERT INTO public.products VALUES (12, 'Combo Bacon Cheddar', 'Hambúrguer com bacon e cheddar, batatas rústicas e bebida à escolha.', 31.90, 7, 'b23be7c248bb4297a9a96dc5099fa97d.jpg', true, NULL);
INSERT INTO public.products VALUES (13, 'Combo Família', 'Cheeseburger completo, batatas generosas e bebida grande.', 44.90, 7, '5f8c08ecd05946b19ab38ffbe584ff18.jpg', true, NULL);
INSERT INTO public.products VALUES (16, 'Milkshake 400ml', 'Chocolate, baunilha ou morango com chantilly.', 14.90, 8, '01f56195f844451e933e026ac36fc027.jpg', true, NULL);
INSERT INTO public.products VALUES (15, 'Refrigerante 1,5L', 'Ideal para dividir. Opções variadas no gelo.', 12.90, 8, '619391ae3c27407abcb2d61a16e88538.jpg', true, NULL);
INSERT INTO public.products VALUES (14, 'Refrigerante Lata 350ml', 'Coca, Guaraná, Sprite ou Fanta bem gelados.', 6.90, 8, 'e40dedcbefb842ef96e6a0d71579391a.jpg', true, NULL);
INSERT INTO public.products VALUES (8, 'Margherita Clássicaa', 'Molho artesanal, mussarela, tomate italiano, manjericão e azeite extra virgem.', 39.90, 6, 'https://res.cloudinary.com/dnfnevy9e/image/upload/v1773373588/restaurant/pizzaria-demo/iwt6owrney2qpuk7aocp.avif', true, NULL);


--
-- TOC entry 5056 (class 0 OID 172045)
-- Dependencies: 234
-- Data for Name: restaurants; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.restaurants VALUES (1, 'Pizzaria Demo', 'pizzaria-demo', 'TEST-2446436736709243-040921-fed94a5bb0191a0e1903980cdd8485a4-171906724', '2026-02-24 17:39:14.95548', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, true, NULL);


--
-- TOC entry 5058 (class 0 OID 188770)
-- Dependencies: 236
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 5042 (class 0 OID 155671)
-- Dependencies: 220
-- Data for Name: sections; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 5060 (class 0 OID 188781)
-- Dependencies: 238
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 5081 (class 0 OID 0)
-- Dependencies: 217
-- Name: admins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.admins_id_seq', 3, true);


--
-- TOC entry 5082 (class 0 OID 0)
-- Dependencies: 231
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categories_id_seq', 9, true);


--
-- TOC entry 5083 (class 0 OID 0)
-- Dependencies: 239
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.notifications_id_seq', 1, false);


--
-- TOC entry 5084 (class 0 OID 0)
-- Dependencies: 225
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_items_id_seq', 96, true);


--
-- TOC entry 5085 (class 0 OID 0)
-- Dependencies: 221
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.orders_id_seq', 85, true);


--
-- TOC entry 5086 (class 0 OID 0)
-- Dependencies: 227
-- Name: page_sections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.page_sections_id_seq', 3, true);


--
-- TOC entry 5087 (class 0 OID 0)
-- Dependencies: 229
-- Name: pages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pages_id_seq', 1, false);


--
-- TOC entry 5088 (class 0 OID 0)
-- Dependencies: 223
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.products_id_seq', 26, true);


--
-- TOC entry 5089 (class 0 OID 0)
-- Dependencies: 233
-- Name: restaurants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.restaurants_id_seq', 1, true);


--
-- TOC entry 5090 (class 0 OID 0)
-- Dependencies: 235
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.roles_id_seq', 1, false);


--
-- TOC entry 5091 (class 0 OID 0)
-- Dependencies: 219
-- Name: sections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sections_id_seq', 1, true);


--
-- TOC entry 5092 (class 0 OID 0)
-- Dependencies: 237
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 1, false);


--
-- TOC entry 4824 (class 2606 OID 155666)
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- TOC entry 4826 (class 2606 OID 155668)
-- Name: admins admins_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_username_key UNIQUE (username);


--
-- TOC entry 4856 (class 2606 OID 163888)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- TOC entry 4858 (class 2606 OID 163890)
-- Name: categories categories_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_slug_key UNIQUE (slug);


--
-- TOC entry 4883 (class 2606 OID 196868)
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- TOC entry 4844 (class 2606 OID 155708)
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- TOC entry 4833 (class 2606 OID 155684)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- TOC entry 4847 (class 2606 OID 163863)
-- Name: page_sections page_sections_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_sections
    ADD CONSTRAINT page_sections_name_key UNIQUE (name);


--
-- TOC entry 4849 (class 2606 OID 163861)
-- Name: page_sections page_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.page_sections
    ADD CONSTRAINT page_sections_pkey PRIMARY KEY (id);


--
-- TOC entry 4852 (class 2606 OID 163875)
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- TOC entry 4854 (class 2606 OID 163877)
-- Name: pages pages_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_slug_key UNIQUE (slug);


--
-- TOC entry 4838 (class 2606 OID 155694)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- TOC entry 4862 (class 2606 OID 172052)
-- Name: restaurants restaurants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_pkey PRIMARY KEY (id);


--
-- TOC entry 4864 (class 2606 OID 172054)
-- Name: restaurants restaurants_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_slug_key UNIQUE (slug);


--
-- TOC entry 4867 (class 2606 OID 188778)
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- TOC entry 4869 (class 2606 OID 188776)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- TOC entry 4830 (class 2606 OID 155676)
-- Name: sections sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_pkey PRIMARY KEY (id);


--
-- TOC entry 4873 (class 2606 OID 188789)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4875 (class 2606 OID 188787)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4827 (class 1259 OID 155669)
-- Name: ix_admins_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_admins_id ON public.admins USING btree (id);


--
-- TOC entry 4859 (class 1259 OID 163891)
-- Name: ix_categories_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_categories_id ON public.categories USING btree (id);


--
-- TOC entry 4877 (class 1259 OID 196879)
-- Name: ix_notifications_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_notifications_created_at ON public.notifications USING btree (created_at);


--
-- TOC entry 4878 (class 1259 OID 196883)
-- Name: ix_notifications_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_notifications_id ON public.notifications USING btree (id);


--
-- TOC entry 4879 (class 1259 OID 196881)
-- Name: ix_notifications_is_read; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_notifications_is_read ON public.notifications USING btree (is_read);


--
-- TOC entry 4880 (class 1259 OID 196880)
-- Name: ix_notifications_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_notifications_order_id ON public.notifications USING btree (order_id);


--
-- TOC entry 4881 (class 1259 OID 196882)
-- Name: ix_notifications_restaurant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_notifications_restaurant_id ON public.notifications USING btree (restaurant_id);


--
-- TOC entry 4840 (class 1259 OID 155720)
-- Name: ix_order_items_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_order_items_id ON public.order_items USING btree (id);


--
-- TOC entry 4841 (class 1259 OID 155721)
-- Name: ix_order_items_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_order_items_order_id ON public.order_items USING btree (order_id);


--
-- TOC entry 4842 (class 1259 OID 155719)
-- Name: ix_order_items_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_order_items_product_id ON public.order_items USING btree (product_id);


--
-- TOC entry 4831 (class 1259 OID 155685)
-- Name: ix_orders_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_orders_id ON public.orders USING btree (id);


--
-- TOC entry 4845 (class 1259 OID 163864)
-- Name: ix_page_sections_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_page_sections_id ON public.page_sections USING btree (id);


--
-- TOC entry 4850 (class 1259 OID 163878)
-- Name: ix_pages_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_pages_id ON public.pages USING btree (id);


--
-- TOC entry 4835 (class 1259 OID 155701)
-- Name: ix_products_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_products_id ON public.products USING btree (id);


--
-- TOC entry 4836 (class 1259 OID 155700)
-- Name: ix_products_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_products_section_id ON public.products USING btree (category_id);


--
-- TOC entry 4860 (class 1259 OID 172055)
-- Name: ix_restaurants_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_restaurants_id ON public.restaurants USING btree (id);


--
-- TOC entry 4865 (class 1259 OID 188779)
-- Name: ix_roles_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_roles_id ON public.roles USING btree (id);


--
-- TOC entry 4828 (class 1259 OID 155677)
-- Name: ix_sections_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_sections_id ON public.sections USING btree (id);


--
-- TOC entry 4870 (class 1259 OID 188796)
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- TOC entry 4871 (class 1259 OID 188795)
-- Name: ix_users_restaurant_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_users_restaurant_id ON public.users USING btree (restaurant_id);


--
-- TOC entry 4834 (class 1259 OID 188806)
-- Name: orders_restaurant_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX orders_restaurant_created_at_idx ON public.orders USING btree (restaurant_id, created_at);


--
-- TOC entry 4839 (class 1259 OID 188807)
-- Name: products_restaurant_category_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX products_restaurant_category_idx ON public.products USING btree (restaurant_id, category_id);


--
-- TOC entry 4876 (class 1259 OID 188805)
-- Name: users_restaurant_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_restaurant_id_idx ON public.users USING btree (restaurant_id);


--
-- TOC entry 4884 (class 2606 OID 188800)
-- Name: admins admins_restaurant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id) ON DELETE SET NULL;


--
-- TOC entry 4890 (class 2606 OID 188746)
-- Name: categories categories_restaurant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id) ON DELETE SET NULL;


--
-- TOC entry 4892 (class 2606 OID 196869)
-- Name: notifications notifications_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- TOC entry 4893 (class 2606 OID 196874)
-- Name: notifications notifications_restaurant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id);


--
-- TOC entry 4888 (class 2606 OID 155709)
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- TOC entry 4889 (class 2606 OID 188756)
-- Name: order_items order_items_restaurant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id) ON DELETE SET NULL;


--
-- TOC entry 4885 (class 2606 OID 172059)
-- Name: orders orders_restaurant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id) ON DELETE SET NULL;


--
-- TOC entry 4886 (class 2606 OID 163905)
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- TOC entry 4887 (class 2606 OID 188751)
-- Name: products products_restaurant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id) ON DELETE SET NULL;


--
-- TOC entry 4891 (class 2606 OID 188790)
-- Name: users users_restaurant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id);


-- Completed on 2026-04-07 12:24:59

--
-- PostgreSQL database dump complete
--

\unrestrict uIKRF9hwUU3dRZxQgYXIX4YvnOj3qIFDUulPHqnlsea1u9OHWxqiPWxaZ0IosQ0

