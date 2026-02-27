--
-- PostgreSQL database cluster dump
--

-- Started on 2026-02-26 16:08:26

\restrict Frs0vYe8niA7ZkOwhYTLMEBeWwj98dcZm8Jd3vWgDwFHKvOMIFUPHwJbki1C899

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS;

--
-- User Configurations
--






\unrestrict Frs0vYe8niA7ZkOwhYTLMEBeWwj98dcZm8Jd3vWgDwFHKvOMIFUPHwJbki1C899

--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

\restrict 7maxGf8tvUv2wPyt2ofiuJVjWLf6EKZlLpgVKHNtKzOgErZ6Hdn2nZTgjZq5Z8Z

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2026-02-26 16:08:26

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

-- Completed on 2026-02-26 16:08:26

--
-- PostgreSQL database dump complete
--

\unrestrict 7maxGf8tvUv2wPyt2ofiuJVjWLf6EKZlLpgVKHNtKzOgErZ6Hdn2nZTgjZq5Z8Z

--
-- Database "demo_storeDb" dump
--

--
-- PostgreSQL database dump
--

\restrict 9uaaxkBBsfFVuwydq208gwPCzBs9ffQJhPbEYqwOPo7sZJpWtdIxN3JYDk4Fwne

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2026-02-26 16:08:26

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
-- TOC entry 5240 (class 1262 OID 147459)
-- Name: demo_storeDb; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE "demo_storeDb" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'br';


\unrestrict 9uaaxkBBsfFVuwydq208gwPCzBs9ffQJhPbEYqwOPo7sZJpWtdIxN3JYDk4Fwne
\connect "demo_storeDb"
\restrict 9uaaxkBBsfFVuwydq208gwPCzBs9ffQJhPbEYqwOPo7sZJpWtdIxN3JYDk4Fwne

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
-- TOC entry 6 (class 2615 OID 147860)
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- TOC entry 5241 (class 0 OID 0)
-- Dependencies: 6
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


--
-- TOC entry 2 (class 3079 OID 147971)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 5242 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 1040 (class 1247 OID 155655)
-- Name: variation_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.variation_type_enum AS ENUM (
    'color',
    'size'
);


--
-- TOC entry 315 (class 1255 OID 148008)
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 148009)
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addresses (
    id integer NOT NULL,
    client_user_id uuid NOT NULL,
    cep character varying(9) NOT NULL,
    logradouro character varying(255) NOT NULL,
    numero character varying(20) NOT NULL,
    complemento character varying(100),
    bairro character varying(100) NOT NULL,
    cidade character varying(100) NOT NULL,
    estado character varying(2) NOT NULL,
    pais character varying(50),
    referencia character varying(255),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    profile_id uuid
);


--
-- TOC entry 219 (class 1259 OID 148016)
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.addresses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5243 (class 0 OID 0)
-- Dependencies: 219
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.addresses_id_seq OWNED BY public.addresses.id;


--
-- TOC entry 220 (class 1259 OID 148017)
-- Name: blog_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blog_posts (
    id integer NOT NULL,
    page_id integer NOT NULL,
    slug character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    excerpt character varying(300),
    content text NOT NULL,
    cover_image character varying(500),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- TOC entry 221 (class 1259 OID 148022)
-- Name: blog_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.blog_posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5244 (class 0 OID 0)
-- Dependencies: 221
-- Name: blog_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.blog_posts_id_seq OWNED BY public.blog_posts.id;


--
-- TOC entry 222 (class 1259 OID 148023)
-- Name: cart_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_items (
    id integer NOT NULL,
    cart_id integer NOT NULL,
    product_id integer NOT NULL,
    product_name text NOT NULL,
    product_price numeric(10,2) NOT NULL,
    product_image text,
    product_height numeric(10,2),
    product_width numeric(10,2),
    product_weight numeric(10,2),
    product_length numeric(10,2),
    quantity integer,
    created_at timestamp without time zone,
    user_id uuid,
    variation_data json
);


--
-- TOC entry 223 (class 1259 OID 148028)
-- Name: cart_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cart_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5245 (class 0 OID 0)
-- Dependencies: 223
-- Name: cart_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cart_items_id_seq OWNED BY public.cart_items.id;


--
-- TOC entry 224 (class 1259 OID 148029)
-- Name: carts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.carts (
    id integer NOT NULL,
    created_at timestamp without time zone,
    client_id uuid,
    user_id uuid
);


--
-- TOC entry 225 (class 1259 OID 148032)
-- Name: carts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.carts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5246 (class 0 OID 0)
-- Dependencies: 225
-- Name: carts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.carts_id_seq OWNED BY public.carts.id;


--
-- TOC entry 276 (class 1259 OID 148311)
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    name character varying(50),
    is_subcategory boolean,
    parent_id integer,
    user_id uuid,
    id integer NOT NULL
);


--
-- TOC entry 277 (class 1259 OID 148336)
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.categories ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 226 (class 1259 OID 148036)
-- Name: client_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client_users (
    name character varying(150) NOT NULL,
    birth_date date NOT NULL,
    email character varying(150) NOT NULL,
    password_hash character varying(255) NOT NULL,
    type character varying(50) DEFAULT 'client'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- TOC entry 227 (class 1259 OID 148044)
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id integer NOT NULL,
    comment character varying(128),
    user_id character varying(50),
    user_name character varying(50),
    product_id integer,
    status character varying(50),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    avatar_url character varying(256)
);


--
-- TOC entry 228 (class 1259 OID 148049)
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5247 (class 0 OID 0)
-- Dependencies: 228
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- TOC entry 229 (class 1259 OID 148050)
-- Name: coupons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.coupons (
    id integer NOT NULL,
    user_id integer,
    title character varying(50),
    code character varying(50),
    discount real,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    image_path character varying(128),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    client_username character varying(50),
    client_id character varying(50)
);


--
-- TOC entry 230 (class 1259 OID 148053)
-- Name: coupons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.coupons ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.coupons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 231 (class 1259 OID 148054)
-- Name: coupons_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.coupons_user (
    id integer NOT NULL,
    coupon_id integer,
    title character varying(50),
    code character varying(50),
    discount real,
    start_date character varying(50),
    end_date character varying(50),
    created_at character varying(50),
    client_username character varying(50),
    updated_at character varying(50),
    client_id uuid
);


--
-- TOC entry 232 (class 1259 OID 148057)
-- Name: coupons_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.coupons_user ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.coupons_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 233 (class 1259 OID 148058)
-- Name: delivery_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delivery_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 234 (class 1259 OID 148059)
-- Name: delivery; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery (
    id integer DEFAULT nextval('public.delivery_id_seq'::regclass),
    product_ids json,
    recipient_name character varying(50),
    street character varying(50),
    number integer,
    complement character varying(50),
    city character varying(50),
    state character varying(50),
    zip_code character varying(50),
    country character varying(50),
    phone character varying(50),
    bairro character varying(50),
    total_value numeric(10,2),
    delivery_id integer,
    width real,
    height real,
    length real,
    weight real,
    melhorenvio_id character varying(50),
    order_id character varying(50),
    user_id character varying(255),
    user_name character varying(50),
    serviceid character varying(50),
    quote numeric,
    coupon character varying(50),
    discount numeric,
    delivery_min character varying(50),
    delivery_max character varying(50),
    status character varying(50),
    diameter numeric,
    format character varying(50),
    billed_weight numeric,
    receipt character varying(50),
    own_hand character varying(50),
    collect character varying(50),
    collect_schedule_at timestamp without time zone,
    reverse character varying(50),
    non_commercial character varying(50),
    authorization_code character varying(50),
    tracking character varying(50),
    self_tracking character varying(50),
    delivery_receipt character varying(50),
    additional_info character varying(50),
    cte_key character varying(50),
    paid_at timestamp without time zone,
    generated_at timestamp without time zone,
    posted_at timestamp without time zone,
    delivered_at timestamp without time zone,
    canceled_at timestamp without time zone,
    suspend_at timestamp without time zone,
    expired_at timestamp without time zone,
    create_at timestamp without time zone,
    updated_at timestamp without time zone,
    parse_api_at timestamp without time zone,
    received_at timestamp without time zone,
    risk character varying(50),
    product_id json
);


--
-- TOC entry 235 (class 1259 OID 148065)
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 236 (class 1259 OID 148066)
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id integer DEFAULT nextval('public.notifications_id_seq'::regclass),
    user_id character varying(50),
    message character varying(128),
    is_read boolean,
    created_at character varying(50),
    is_global boolean
);


--
-- TOC entry 237 (class 1259 OID 148070)
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 238 (class 1259 OID 148071)
-- Name: order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_items (
    id integer DEFAULT nextval('public.order_items_id_seq'::regclass),
    order_id integer,
    product_id integer,
    quantity integer,
    unit_price real,
    total_price real
);


--
-- TOC entry 239 (class 1259 OID 148075)
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    payment_id integer,
    delivery_id integer,
    shipment_info character varying(50),
    total_amount real,
    order_date timestamp without time zone,
    status character varying(50),
    user_id uuid
);


--
-- TOC entry 240 (class 1259 OID 148078)
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.orders ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 241 (class 1259 OID 148079)
-- Name: pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pages (
    name character varying(50),
    title character varying(50),
    content character varying(50),
    hero_title character varying(50),
    hero_subtitle character varying(128),
    hero_background_color character varying(50),
    hero_image character varying(128),
    hero_buttons character varying(512),
    carousel_images character varying(50),
    footer_text character varying(50),
    id integer NOT NULL
);


--
-- TOC entry 242 (class 1259 OID 148084)
-- Name: pages_new_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pages_new_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5248 (class 0 OID 0)
-- Dependencies: 242
-- Name: pages_new_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pages_new_id_seq OWNED BY public.pages.id;


--
-- TOC entry 243 (class 1259 OID 148085)
-- Name: password_reset_token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_reset_token (
    id character varying(50),
    user_id character varying(50),
    token character varying(50),
    expire_at character varying(50)
);


--
-- TOC entry 244 (class 1259 OID 148088)
-- Name: payment_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 245 (class 1259 OID 148089)
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    payment_id text,
    total_value real,
    payment_date character varying(50),
    payment_type character varying(50),
    cpf character varying(11),
    email character varying(50),
    status character varying(50),
    usuario_id uuid,
    coupon_code character varying(50),
    coupon_amount real,
    name character varying(50)
);


--
-- TOC entry 246 (class 1259 OID 148094)
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.payments ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 247 (class 1259 OID 148095)
-- Name: payments_product_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payments_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 248 (class 1259 OID 148096)
-- Name: payments_product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments_product (
    id integer DEFAULT nextval('public.payments_product_id_seq'::regclass) NOT NULL,
    payment_id integer,
    product_id integer,
    product_name character varying(64),
    product_quantity integer,
    product_price real
);


--
-- TOC entry 249 (class 1259 OID 148100)
-- Name: post_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_comments (
    id integer NOT NULL,
    post_id integer NOT NULL,
    user_id uuid,
    username character varying(100),
    user_avatar character varying(500),
    login_provider character varying(50),
    text text NOT NULL,
    status character varying(20) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- TOC entry 250 (class 1259 OID 148105)
-- Name: post_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5249 (class 0 OID 0)
-- Dependencies: 250
-- Name: post_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_comments_id_seq OWNED BY public.post_comments.id;


--
-- TOC entry 251 (class 1259 OID 148106)
-- Name: post_seo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_seo (
    id integer NOT NULL,
    post_id integer NOT NULL,
    keywords character varying(255),
    description character varying(255),
    canonical_url character varying(255),
    og_title character varying(255),
    og_description character varying(255),
    og_image character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- TOC entry 252 (class 1259 OID 148111)
-- Name: post_seo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_seo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5250 (class 0 OID 0)
-- Dependencies: 252
-- Name: post_seo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_seo_id_seq OWNED BY public.post_seo.id;


--
-- TOC entry 253 (class 1259 OID 148112)
-- Name: post_views; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_views (
    id integer NOT NULL,
    post_id integer NOT NULL,
    created_at timestamp without time zone
);


--
-- TOC entry 254 (class 1259 OID 148115)
-- Name: post_views_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_views_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5251 (class 0 OID 0)
-- Dependencies: 254
-- Name: post_views_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_views_id_seq OWNED BY public.post_views.id;


--
-- TOC entry 255 (class 1259 OID 148116)
-- Name: product_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_images (
    id integer NOT NULL,
    product_id integer,
    image_path character varying(256),
    is_thumbnail boolean,
    created_at timestamp without time zone
);


--
-- TOC entry 256 (class 1259 OID 148119)
-- Name: product_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.product_images ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.product_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 257 (class 1259 OID 148120)
-- Name: product_seo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_seo (
    id integer NOT NULL,
    product_id integer,
    meta_title character varying(128),
    meta_description character varying(512),
    slug character varying(50),
    keywords character varying(512),
    created_at character varying(50),
    updated_at character varying(50)
);


--
-- TOC entry 258 (class 1259 OID 148125)
-- Name: product_seo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.product_seo ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.product_seo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 259 (class 1259 OID 148126)
-- Name: product_variations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_variations (
    id integer NOT NULL,
    product_id integer NOT NULL,
    product_name character varying(255) NOT NULL,
    variation_type character varying(20) NOT NULL,
    value character varying(255) NOT NULL,
    quantity integer NOT NULL,
    created_at timestamp without time zone
);


--
-- TOC entry 260 (class 1259 OID 148131)
-- Name: product_variations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_variations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5252 (class 0 OID 0)
-- Dependencies: 260
-- Name: product_variations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_variations_id_seq OWNED BY public.product_variations.id;


--
-- TOC entry 261 (class 1259 OID 148132)
-- Name: product_videos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_videos (
    id character varying(50),
    product_id integer,
    video_path character varying(50),
    created_at timestamp without time zone
);


--
-- TOC entry 262 (class 1259 OID 148135)
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying(128),
    description character varying(1024),
    price numeric(10,2),
    category_id integer,
    subcategory_id integer,
    image_paths json,
    quantity integer,
    width real,
    height real,
    weight real,
    length real,
    user_id text,
    thumbnail_path character varying(512)
);


--
-- TOC entry 263 (class 1259 OID 148140)
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.products ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 264 (class 1259 OID 148141)
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
    user_id uuid,
    username character varying(50),
    full_name character varying(50),
    birth_date character varying(50),
    avatar_url character varying(255),
    phone character varying(20) DEFAULT ''::character varying NOT NULL,
    mobile character varying(20) DEFAULT ''::character varying NOT NULL,
    id integer NOT NULL,
    client_user_id uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- TOC entry 265 (class 1259 OID 148148)
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5253 (class 0 OID 0)
-- Dependencies: 265
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.profiles_id_seq OWNED BY public.profiles.id;


--
-- TOC entry 266 (class 1259 OID 148149)
-- Name: seo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.seo (
    id integer,
    route integer,
    metatitle character varying(128),
    metadescription character varying(256),
    metakeywords character varying(256),
    ogtitle character varying(64),
    ogdescription character varying(256),
    ogimage character varying(128)
);


--
-- TOC entry 278 (class 1259 OID 155652)
-- Name: seo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5254 (class 0 OID 0)
-- Dependencies: 278
-- Name: seo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.seo_id_seq OWNED BY public.seo.id;


--
-- TOC entry 267 (class 1259 OID 148154)
-- Name: stock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stock (
    id integer NOT NULL,
    id_product integer,
    user_id text,
    category_id integer,
    product_name character varying(128),
    product_price real,
    product_quantity real,
    variations jsonb,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- TOC entry 268 (class 1259 OID 148159)
-- Name: stock_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.stock ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.stock_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 269 (class 1259 OID 148160)
-- Name: subcategories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subcategories (
    id character varying(50),
    name character varying(50),
    category_id character varying(50)
);


--
-- TOC entry 270 (class 1259 OID 148163)
-- Name: token_blocklist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.token_blocklist (
    id integer NOT NULL,
    jti character varying(36) NOT NULL,
    user_id character varying(36) NOT NULL,
    created_at timestamp without time zone
);


--
-- TOC entry 271 (class 1259 OID 148166)
-- Name: token_blocklist_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.token_blocklist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5255 (class 0 OID 0)
-- Dependencies: 271
-- Name: token_blocklist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.token_blocklist_id_seq OWNED BY public.token_blocklist.id;


--
-- TOC entry 272 (class 1259 OID 148167)
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    email character varying(50),
    password character varying(64),
    name character varying(50),
    birth_date character varying(50),
    type character varying(50) DEFAULT 'client'::character varying NOT NULL,
    fcm_token text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- TOC entry 273 (class 1259 OID 148176)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 274 (class 1259 OID 148177)
-- Name: variations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.variations (
    id integer NOT NULL,
    product_id integer NOT NULL,
    variation_type character varying(50) NOT NULL,
    value character varying(100) NOT NULL,
    quantity integer
);


--
-- TOC entry 275 (class 1259 OID 148180)
-- Name: variations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.variations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5256 (class 0 OID 0)
-- Dependencies: 275
-- Name: variations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.variations_id_seq OWNED BY public.variations.id;


--
-- TOC entry 4935 (class 2604 OID 148314)
-- Name: addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses ALTER COLUMN id SET DEFAULT nextval('public.addresses_id_seq'::regclass);


--
-- TOC entry 4938 (class 2604 OID 148315)
-- Name: blog_posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_posts ALTER COLUMN id SET DEFAULT nextval('public.blog_posts_id_seq'::regclass);


--
-- TOC entry 4939 (class 2604 OID 148316)
-- Name: cart_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items ALTER COLUMN id SET DEFAULT nextval('public.cart_items_id_seq'::regclass);


--
-- TOC entry 4940 (class 2604 OID 148317)
-- Name: carts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carts ALTER COLUMN id SET DEFAULT nextval('public.carts_id_seq'::regclass);


--
-- TOC entry 4944 (class 2604 OID 148318)
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- TOC entry 4948 (class 2604 OID 148319)
-- Name: pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages ALTER COLUMN id SET DEFAULT nextval('public.pages_new_id_seq'::regclass);


--
-- TOC entry 4950 (class 2604 OID 148320)
-- Name: post_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_comments ALTER COLUMN id SET DEFAULT nextval('public.post_comments_id_seq'::regclass);


--
-- TOC entry 4951 (class 2604 OID 148321)
-- Name: post_seo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_seo ALTER COLUMN id SET DEFAULT nextval('public.post_seo_id_seq'::regclass);


--
-- TOC entry 4952 (class 2604 OID 148322)
-- Name: post_views id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_views ALTER COLUMN id SET DEFAULT nextval('public.post_views_id_seq'::regclass);


--
-- TOC entry 4953 (class 2604 OID 148323)
-- Name: product_variations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variations ALTER COLUMN id SET DEFAULT nextval('public.product_variations_id_seq'::regclass);


--
-- TOC entry 4956 (class 2604 OID 148324)
-- Name: profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles ALTER COLUMN id SET DEFAULT nextval('public.profiles_id_seq'::regclass);


--
-- TOC entry 4959 (class 2604 OID 155653)
-- Name: seo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seo ALTER COLUMN id SET DEFAULT nextval('public.seo_id_seq'::regclass);


--
-- TOC entry 4960 (class 2604 OID 148325)
-- Name: token_blocklist id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_blocklist ALTER COLUMN id SET DEFAULT nextval('public.token_blocklist_id_seq'::regclass);


--
-- TOC entry 4965 (class 2604 OID 148326)
-- Name: variations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variations ALTER COLUMN id SET DEFAULT nextval('public.variations_id_seq'::regclass);


--
-- TOC entry 5174 (class 0 OID 148009)
-- Dependencies: 218
-- Data for Name: addresses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.addresses (id, client_user_id, cep, logradouro, numero, complemento, bairro, cidade, estado, pais, referencia, created_at, updated_at, profile_id) FROM stdin;
48	e77f01ac-251c-4a28-9a23-e55fba2afc13	73082-180	Quadra QMS 19	11	sadsadsa	Setor de Mansões de Sobradinho	Brasília	DF	sadsadsa	\N	2025-12-24 12:17:48.020494	2025-12-24 12:17:48.020494	\N
\.


--
-- TOC entry 5176 (class 0 OID 148017)
-- Dependencies: 220
-- Data for Name: blog_posts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.blog_posts (id, page_id, slug, title, excerpt, content, cover_image, created_at, updated_at) FROM stdin;
23	1	como-escolher-sua-seda	Como escolher sua seda 	Descubra a melhor forma de escolher a sua seda	<p><strong>sadsadsadsadsasdsadsadsadsaguy</strong></p><p>&lt;ad-banner slot="1234567890" format="auto"&gt;&lt;/ad-banner&gt;</p><p><strong>oifjdsoifjdsofd</strong></p><p>&lt;ad-banner slot="1234567890" format="auto"&gt;&lt;/ad-banner&gt;</p><p><strong>dsadihsaiudhsaiudhsaidsa</strong></p><p>&lt;ad-banner slot="1234567890" format="auto"&gt;&lt;/ad-banner&gt;</p>	https://res.cloudinary.com/dnfnevy9e/image/upload/v1759169702/blogs/como-escolher-sua-seda/cover.png	2025-09-29 18:15:01.408837	\N
\.


--
-- TOC entry 5178 (class 0 OID 148023)
-- Dependencies: 222
-- Data for Name: cart_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_items (id, cart_id, product_id, product_name, product_price, product_image, product_height, product_width, product_weight, product_length, quantity, created_at, user_id, variation_data) FROM stdin;
155	6	82	Camiseta Oversize Roxa	69.90	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766587112/product_images/Camiseta_Oversize_Roxa/56710d72-89e2-45a8-8201-4f1d605aeb02_20251224143832270922.png	3.00	25.00	0.30	30.00	1	2026-01-04 00:48:36.816297	e77f01ac-251c-4a28-9a23-e55fba2afc13	[{"variation_id": 84, "quantity": 1, "value": "XG"}, {"variation_id": 89, "quantity": 1, "value": "#8507F3"}]
157	6	83	Caneca Personalizada	34.90	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766590169/product_images/Caneca_Personalizada/5ccb5095-0ea3-414a-ab09-088f9b944bcc_20251224152927255332.png	9.50	12.00	0.40	12.00	1	2026-01-04 01:42:38.660311	e77f01ac-251c-4a28-9a23-e55fba2afc13	[]
\.


--
-- TOC entry 5180 (class 0 OID 148029)
-- Dependencies: 224
-- Data for Name: carts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.carts (id, created_at, client_id, user_id) FROM stdin;
5	2025-12-24 14:41:32.656092	\N	9d509dc8-9f53-4be5-985a-7105090a1a23
6	2025-12-24 14:42:24.676023	\N	e77f01ac-251c-4a28-9a23-e55fba2afc13
\.


--
-- TOC entry 5232 (class 0 OID 148311)
-- Dependencies: 276
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.categories (name, is_subcategory, parent_id, user_id, id) FROM stdin;
Camisetas	f	\N	9d509dc8-9f53-4be5-985a-7105090a1a23	31
Básica	t	31	9d509dc8-9f53-4be5-985a-7105090a1a23	32
Canecas	f	\N	9d509dc8-9f53-4be5-985a-7105090a1a23	33
Personalizadas	t	33	9d509dc8-9f53-4be5-985a-7105090a1a23	34
Bonés	f	\N	9d509dc8-9f53-4be5-985a-7105090a1a23	35
Casual	t	31	9d509dc8-9f53-4be5-985a-7105090a1a23	36
Casual	t	35	9d509dc8-9f53-4be5-985a-7105090a1a23	37
Moletom	f	\N	9d509dc8-9f53-4be5-985a-7105090a1a23	38
Casual	t	38	9d509dc8-9f53-4be5-985a-7105090a1a23	39
\.


--
-- TOC entry 5182 (class 0 OID 148036)
-- Dependencies: 226
-- Data for Name: client_users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.client_users (name, birth_date, email, password_hash, type, created_at, updated_at, id) FROM stdin;
rafael 	2004-02-26	rafael.f.p.faria@hotmail.com	scrypt:32768:8:1$hlxgmAsjPZYL9W6q$78e9945f93bccd4bfd69e10ffd65db2698412b4fe8af76bde924dd395a98e38b862f5e556d3027126006dba58d5d4baaed40478759acb701cb9c833c1ff06367	client	2025-10-24 16:00:57.076011	\N	e77f01ac-251c-4a28-9a23-e55fba2afc13
\.


--
-- TOC entry 5183 (class 0 OID 148044)
-- Dependencies: 227
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.comments (id, comment, user_id, user_name, product_id, status, created_at, updated_at, avatar_url) FROM stdin;
\.


--
-- TOC entry 5185 (class 0 OID 148050)
-- Dependencies: 229
-- Data for Name: coupons; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.coupons (id, user_id, title, code, discount, start_date, end_date, image_path, created_at, updated_at, client_username, client_id) FROM stdin;
\.


--
-- TOC entry 5187 (class 0 OID 148054)
-- Dependencies: 231
-- Data for Name: coupons_user; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.coupons_user (id, coupon_id, title, code, discount, start_date, end_date, created_at, client_username, updated_at, client_id) FROM stdin;
\.


--
-- TOC entry 5190 (class 0 OID 148059)
-- Dependencies: 234
-- Data for Name: delivery; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.delivery (id, product_ids, recipient_name, street, number, complement, city, state, zip_code, country, phone, bairro, total_value, delivery_id, width, height, length, weight, melhorenvio_id, order_id, user_id, user_name, serviceid, quote, coupon, discount, delivery_min, delivery_max, status, diameter, format, billed_weight, receipt, own_hand, collect, collect_schedule_at, reverse, non_commercial, authorization_code, tracking, self_tracking, delivery_receipt, additional_info, cte_key, paid_at, generated_at, posted_at, delivered_at, canceled_at, suspend_at, expired_at, create_at, updated_at, parse_api_at, received_at, risk, product_id) FROM stdin;
124	["82"]	rafael 	Quadra QMS 19	11	sadsadsa	Brasília	DF	73082-180	sadsadsa	\N	Setor de Mansões de Sobradinho	162.33	\N	25	3	30	0.3	\N	\N	e77f01ac-251c-4a28-9a23-e55fba2afc13	apro	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
125	["82"]	rafael 	Quadra QMS 19	11	sadsadsa	Brasília	DF	73082-180	sadsadsa	\N	Setor de Mansões de Sobradinho	372.49	\N	125	15	150	1.5	\N	\N	e77f01ac-251c-4a28-9a23-e55fba2afc13	apro	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
126	[82]		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0	0	0	\N	\N	155f2da0-178f-477d-a474-4c94f9ce2bf5		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
127	[82]		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	0	0	0	\N	\N	155f2da0-178f-477d-a474-4c94f9ce2bf5		\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
128	[82]	Rafael 	Quadra QMS 19	11	Casa 17	Brasília	DF	73082-180	\N	\N	Setor de Mansões de Sobradinho	12.03	2	0	0	0	0	\N	\N	155f2da0-178f-477d-a474-4c94f9ce2bf5	rafael teste	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
129	[82]	Rafael 	Quadra QMS 19	11	Casa 17	Brasília	DF	73082-180	\N	\N	Setor de Mansões de Sobradinho	12.03	2	0	0	0	0	\N	\N	155f2da0-178f-477d-a474-4c94f9ce2bf5	rafael teste	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
130	[82]	Rafael 	Quadra QMS 19	11	Casa 17	Brasília	DF	73082-180	\N	\N	Setor de Mansões de Sobradinho	12.03	2	0	0	0	0	\N	\N	155f2da0-178f-477d-a474-4c94f9ce2bf5	rafael teste	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
131	[82]	Rafael 	Quadra QMS 19	11	Casa 17	Brasília	DF	73082-180	\N	\N	Setor de Mansões de Sobradinho	12.03	2	0	0	0	0	\N	\N	155f2da0-178f-477d-a474-4c94f9ce2bf5	rafael teste	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
132	[82]	Rafael 	Quadra QMS 19	11	Casa 17	Brasília	DF	73082-180	\N	\N	Setor de Mansões de Sobradinho	12.03	2	0	0	0	0	\N	\N	155f2da0-178f-477d-a474-4c94f9ce2bf5	rafael teste	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
133	[82]	Rafael 	Quadra QMS 19	11	Casa 17	Brasília	DF	73082-180	\N	\N	Setor de Mansões de Sobradinho	12.56	2	0	0	0	0	\N	\N	155f2da0-178f-477d-a474-4c94f9ce2bf5	rafael teste	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- TOC entry 5192 (class 0 OID 148066)
-- Dependencies: 236
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notifications (id, user_id, message, is_read, created_at, is_global) FROM stdin;
63	9d509dc8-9f53-4be5-985a-7105090a1a23	Novo pedido recebido: #245, Para: Cliente, valor total: R$162.33	f	2025-12-24 15:19:54.102097	t
64	2270f1e3-99e8-42c0-a0d7-930e750c8749	Novo pedido recebido: #245, Para: Cliente, valor total: R$162.33	f	2025-12-24 15:19:54.150893	t
65	97832ada-019c-42e3-b1e7-4b7f3c09a35c	Novo pedido recebido: #245, Para: Cliente, valor total: R$162.33	f	2025-12-24 15:19:54.309554	t
66	9d509dc8-9f53-4be5-985a-7105090a1a23	Novo pedido recebido: #246, Para: Cliente, valor total: R$372.49	f	2025-12-26 02:56:24.952296	t
67	2270f1e3-99e8-42c0-a0d7-930e750c8749	Novo pedido recebido: #246, Para: Cliente, valor total: R$372.49	f	2025-12-26 02:56:25.001529	t
68	97832ada-019c-42e3-b1e7-4b7f3c09a35c	Novo pedido recebido: #246, Para: Cliente, valor total: R$372.49	f	2025-12-26 02:56:25.047943	t
69	9d509dc8-9f53-4be5-985a-7105090a1a23	Novo pedido recebido: #247, Para: Cliente, valor total: R$82.46	f	2026-01-03 17:57:28.180183	t
70	2270f1e3-99e8-42c0-a0d7-930e750c8749	Novo pedido recebido: #247, Para: Cliente, valor total: R$82.46	f	2026-01-03 17:57:28.344648	t
71	97832ada-019c-42e3-b1e7-4b7f3c09a35c	Novo pedido recebido: #247, Para: Cliente, valor total: R$82.46	f	2026-01-03 17:57:28.391924	t
72	9d509dc8-9f53-4be5-985a-7105090a1a23	Novo pedido recebido: #248, Para: Cliente, valor total: R$82.46	f	2026-01-03 17:57:35.111661	t
73	2270f1e3-99e8-42c0-a0d7-930e750c8749	Novo pedido recebido: #248, Para: Cliente, valor total: R$82.46	f	2026-01-03 17:57:35.158283	t
74	97832ada-019c-42e3-b1e7-4b7f3c09a35c	Novo pedido recebido: #248, Para: Cliente, valor total: R$82.46	f	2026-01-03 17:57:35.207256	t
75	9d509dc8-9f53-4be5-985a-7105090a1a23	Novo pedido recebido: #249, Para: Rafael , valor total: R$81.93	f	2026-01-03 18:03:50.142848	t
76	2270f1e3-99e8-42c0-a0d7-930e750c8749	Novo pedido recebido: #249, Para: Rafael , valor total: R$81.93	f	2026-01-03 18:03:50.190868	t
77	97832ada-019c-42e3-b1e7-4b7f3c09a35c	Novo pedido recebido: #249, Para: Rafael , valor total: R$81.93	f	2026-01-03 18:03:50.239325	t
78	9d509dc8-9f53-4be5-985a-7105090a1a23	Novo pedido recebido: #250, Para: Rafael , valor total: R$81.93	f	2026-01-04 00:34:21.872479	t
79	2270f1e3-99e8-42c0-a0d7-930e750c8749	Novo pedido recebido: #250, Para: Rafael , valor total: R$81.93	f	2026-01-04 00:34:21.92262	t
80	97832ada-019c-42e3-b1e7-4b7f3c09a35c	Novo pedido recebido: #250, Para: Rafael , valor total: R$81.93	f	2026-01-04 00:34:21.970553	t
81	9d509dc8-9f53-4be5-985a-7105090a1a23	Novo pedido recebido: #251, Para: Rafael , valor total: R$81.93	f	2026-01-04 00:35:37.940174	t
82	2270f1e3-99e8-42c0-a0d7-930e750c8749	Novo pedido recebido: #251, Para: Rafael , valor total: R$81.93	f	2026-01-04 00:35:37.988582	t
83	97832ada-019c-42e3-b1e7-4b7f3c09a35c	Novo pedido recebido: #251, Para: Rafael , valor total: R$81.93	f	2026-01-04 00:35:38.1503	t
84	9d509dc8-9f53-4be5-985a-7105090a1a23	Novo pedido recebido: #252, Para: Rafael , valor total: R$81.93	f	2026-01-04 01:40:52.791086	t
85	2270f1e3-99e8-42c0-a0d7-930e750c8749	Novo pedido recebido: #252, Para: Rafael , valor total: R$81.93	f	2026-01-04 01:40:52.845838	t
86	97832ada-019c-42e3-b1e7-4b7f3c09a35c	Novo pedido recebido: #252, Para: Rafael , valor total: R$81.93	f	2026-01-04 01:40:53.001393	t
87	9d509dc8-9f53-4be5-985a-7105090a1a23	Novo pedido recebido: #253, Para: Rafael , valor total: R$81.93	f	2026-01-04 01:44:15.603737	t
88	2270f1e3-99e8-42c0-a0d7-930e750c8749	Novo pedido recebido: #253, Para: Rafael , valor total: R$81.93	f	2026-01-04 01:44:15.653939	t
89	97832ada-019c-42e3-b1e7-4b7f3c09a35c	Novo pedido recebido: #253, Para: Rafael , valor total: R$81.93	f	2026-01-04 01:44:15.703228	t
90	9d509dc8-9f53-4be5-985a-7105090a1a23	Novo pedido recebido: #254, Para: Rafael , valor total: R$82.46	f	2026-01-04 15:15:48.04236	t
91	2270f1e3-99e8-42c0-a0d7-930e750c8749	Novo pedido recebido: #254, Para: Rafael , valor total: R$82.46	f	2026-01-04 15:15:48.091881	t
92	97832ada-019c-42e3-b1e7-4b7f3c09a35c	Novo pedido recebido: #254, Para: Rafael , valor total: R$82.46	f	2026-01-04 15:15:48.139628	t
\.


--
-- TOC entry 5194 (class 0 OID 148071)
-- Dependencies: 238
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_items (id, order_id, product_id, quantity, unit_price, total_price) FROM stdin;
195	245	82	1	69.9	162.33
196	246	82	5	69.9	372.49
197	247	82	1	69.9	\N
198	248	82	1	69.9	\N
199	249	82	1	69.9	\N
200	250	82	1	69.9	81.93
201	251	82	1	69.9	81.93
202	252	82	1	69.9	81.93
203	253	82	1	69.9	81.93
204	254	82	1	69.9	82.46
\.


--
-- TOC entry 5195 (class 0 OID 148075)
-- Dependencies: 239
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.orders (id, payment_id, delivery_id, shipment_info, total_amount, order_date, status, user_id) FROM stdin;
245	176	124	73082-180	162.33	2025-12-24 15:19:54.097469	approved	e77f01ac-251c-4a28-9a23-e55fba2afc13
246	177	125	73082-180	372.49	2025-12-26 02:56:24.946489	approved	e77f01ac-251c-4a28-9a23-e55fba2afc13
247	178	126		82.46	2026-01-03 17:57:28.166918	pending	155f2da0-178f-477d-a474-4c94f9ce2bf5
248	179	127		82.46	2026-01-03 17:57:35.108758	pending	155f2da0-178f-477d-a474-4c94f9ce2bf5
249	180	128	73082-180	81.93	2026-01-03 18:03:50.139871	pending	155f2da0-178f-477d-a474-4c94f9ce2bf5
250	181	129	73082-180	81.93	2026-01-04 00:34:21.865719	approved	155f2da0-178f-477d-a474-4c94f9ce2bf5
251	182	130	73082-180	81.93	2026-01-04 00:35:37.937082	approved	155f2da0-178f-477d-a474-4c94f9ce2bf5
252	183	131	73082-180	81.93	2026-01-04 01:40:52.784803	approved	155f2da0-178f-477d-a474-4c94f9ce2bf5
253	184	132	73082-180	81.93	2026-01-04 01:44:15.598187	approved	155f2da0-178f-477d-a474-4c94f9ce2bf5
254	185	133	73082-180	82.46	2026-01-04 15:15:48.035566	approved	155f2da0-178f-477d-a474-4c94f9ce2bf5
\.


--
-- TOC entry 5197 (class 0 OID 148079)
-- Dependencies: 241
-- Data for Name: pages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pages (name, title, content, hero_title, hero_subtitle, hero_background_color, hero_image, hero_buttons, carousel_images, footer_text, id) FROM stdin;
Blog	Blog	<p>Blog description</p>	Blog	Blog	#3F51B5	http://localhost:5000/uploadImages/uploads/logo.png	[]	[]		1
Home Page	Home Page	<p><strong>Welcome To</strong></p>	Venda online com app próprio e loja integrada	Uma solução completa para transformar seu negócio em digital.	#000000	http://localhost:5000/uploadImages/uploads/logo.png	[]	[]		7
\.


--
-- TOC entry 5199 (class 0 OID 148085)
-- Dependencies: 243
-- Data for Name: password_reset_token; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.password_reset_token (id, user_id, token, expire_at) FROM stdin;
\.


--
-- TOC entry 5201 (class 0 OID 148089)
-- Dependencies: 245
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (id, payment_id, total_value, payment_date, payment_type, cpf, email, status, usuario_id, coupon_code, coupon_amount, name) FROM stdin;
176	1343394843	162.33	2025-12-24T11:19:53.934-04:00	crédito	12345678909	rafael.f.p.faria@hotmail.com	approved	e77f01ac-251c-4a28-9a23-e55fba2afc13	\N	0	apro
177	1325732532	372.49	2025-12-25T22:56:24.452-04:00	crédito	12345678909	rafael.f.p.fariadk@gmail.com	approved	e77f01ac-251c-4a28-9a23-e55fba2afc13	\N	0	apro
178	1325793464	82.46	2026-01-03 14:57:27.960189	pix		rafael.f.p.fariadk@gmail.com	pending	155f2da0-178f-477d-a474-4c94f9ce2bf5		0	
179	1325793468	82.46	2026-01-03 14:57:35.006672	pix		rafael.f.p.fariadk@gmail.com	pending	155f2da0-178f-477d-a474-4c94f9ce2bf5		0	
180	1325793496	81.93	2026-01-03 15:03:50.036214	pix	12345678909	rafael.f.p.fariadk@gmail.com	pending	155f2da0-178f-477d-a474-4c94f9ce2bf5		0	rafael teste
181	1343550649	81.93	2026-01-03T20:34:21.489-04:00	crédito	12345678909	rafael.f.p.fariadk@gmail.com	approved	155f2da0-178f-477d-a474-4c94f9ce2bf5		0	rafael teste
182	1343550661	81.93	2026-01-03T20:35:37.455-04:00	crédito	12345678909	rafael.f.p.fariadk@gmail.com	approved	155f2da0-178f-477d-a474-4c94f9ce2bf5		0	rafael teste
183	1343550927	81.93	2026-01-03T21:40:52.431-04:00	crédito	12345678909	rafael.f.p.fariadk@gmail.com	approved	155f2da0-178f-477d-a474-4c94f9ce2bf5		0	rafael teste
184	1343549111	81.93	2026-01-03T21:44:15.281-04:00	crédito	12345678909	rafael.f.p.fariadk@gmail.com	approved	155f2da0-178f-477d-a474-4c94f9ce2bf5		0	rafael teste
185	1325797680	82.46	2026-01-04T11:15:47.104-04:00	crédito	12345678909	rafael.f.p.fariadk@gmail.com	approved	155f2da0-178f-477d-a474-4c94f9ce2bf5		0	rafael teste
\.


--
-- TOC entry 5204 (class 0 OID 148096)
-- Dependencies: 248
-- Data for Name: payments_product; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments_product (id, payment_id, product_id, product_name, product_quantity, product_price) FROM stdin;
308	176	82	Camiseta Oversize Roxa	1	69.9
309	177	82	Camiseta Oversize Roxa	5	69.9
310	178	82	Camiseta Oversize Roxa	1	69.9
311	179	82	Camiseta Oversize Roxa	1	69.9
312	180	82	Camiseta Oversize Roxa	1	69.9
313	181	82	Camiseta Oversize Roxa	1	69.9
314	182	82	Camiseta Oversize Roxa	1	69.9
315	183	82	Camiseta Oversize Roxa	1	69.9
316	184	82	Camiseta Oversize Roxa	1	69.9
317	185	82	Camiseta Oversize Roxa	1	69.9
\.


--
-- TOC entry 5205 (class 0 OID 148100)
-- Dependencies: 249
-- Data for Name: post_comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.post_comments (id, post_id, user_id, username, user_avatar, login_provider, text, status, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5207 (class 0 OID 148106)
-- Dependencies: 251
-- Data for Name: post_seo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.post_seo (id, post_id, keywords, description, canonical_url, og_title, og_description, og_image, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5209 (class 0 OID 148112)
-- Dependencies: 253
-- Data for Name: post_views; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.post_views (id, post_id, created_at) FROM stdin;
16	23	2026-01-08 05:13:18.263196
\.


--
-- TOC entry 5211 (class 0 OID 148116)
-- Dependencies: 255
-- Data for Name: product_images; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_images (id, product_id, image_path, is_thumbnail, created_at) FROM stdin;
27	82	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766587114/product_images/Camiseta_Oversize_Roxa/56710d72-89e2-45a8-8201-4f1d605aeb02_20251224143833299945.png	f	2025-12-24 11:38:34.630266
28	84	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766604829/product_images/Bone_Casual/ChatGPT_Image_24_de_dez._de_2025_16_26_27_20251224193348016809.png	f	2025-12-24 16:33:50.003474
29	84	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766604830/product_images/Bone_Casual/ChatGPT_Image_24_de_dez._de_2025_16_28_26_20251224193348996955.png	f	2025-12-24 16:33:50.003474
30	85	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766606663/product_images/Moletom_Demo_Store__Preto_Classico/ChatGPT_Image_24_de_dez._de_2025_16_56_51_20251224200421242675.jpg	f	2025-12-24 17:04:24.895196
31	85	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766606665/product_images/Moletom_Demo_Store__Preto_Classico/ChatGPT_Image_24_de_dez._de_2025_16_56_57_20251224200423173407.jpg	f	2025-12-24 17:04:24.895196
\.


--
-- TOC entry 5213 (class 0 OID 148120)
-- Dependencies: 257
-- Data for Name: product_seo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_seo (id, product_id, meta_title, meta_description, slug, keywords, created_at, updated_at) FROM stdin;
66	82	Camiseta Oversize Roxa | Estilo Urbano – Rua11 Store	Camiseta oversize roxa com estilo urbano, confortável e versátil. Ideal para quem busca atitude, conforto e visual moderno no dia a dia.	camiseta-oversize-roxa-rua11	camiseta oversize roxa, camiseta oversized, camiseta streetwear, camiseta urbana, camiseta casual, moda streetwear, camiseta unissex, rua11 store	2025-12-24 14:38:34.581897	2025-12-24 14:38:34.581901
67	83	Caneca Personalizada em Cerâmica | Presente Criativo	Caneca personalizada em cerâmica com estampa exclusiva, ideal para presentear ou uso diário. Produto resistente, acabamento brilhante e frete simples.	caneca-personalizada-ceramica	caneca personalizada, caneca de cerâmica, caneca personalizada com nome, caneca para presente, caneca criativa, caneca personalizada barata, caneca personalizada ecommerce, caneca decorada, caneca café personalizada	2025-12-24 15:29:30.136789	2025-12-24 15:29:30.136792
68	84	Boné Casual Ajustável | Estilo e Conforto para o Dia a Dia	Boné casual ajustável com design moderno, confortável e resistente. Ideal para uso diário, lazer e estilo urbano. Aproveite.\r\n	bone-casual	boné casual,boné masculino,boné ajustável,boné moderno,acessório de moda,boné urbano,boné para o dia a dia,boné estiloso	2025-12-24 19:33:49.959123	2025-12-24 19:33:49.959126
69	85	Moletom Preto Demo Store Masculino | Conforto e Estilo Urbano	Moletom preto Demo Store masculino com capuz, bolso canguru e estampa exclusiva. Confortável, estiloso e ideal para o dia a dia urbano.	moletom-preto-demo-store-masculino	moletom preto, moletom masculino, moletom com capuz, moletom streetwear, moletom urbano, moletom demo store, roupa masculina, hoodie preto	2025-12-24 20:04:24.741318	2025-12-24 20:04:24.741322
\.


--
-- TOC entry 5215 (class 0 OID 148126)
-- Dependencies: 259
-- Data for Name: product_variations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_variations (id, product_id, product_name, variation_type, value, quantity, created_at) FROM stdin;
84	82	Camiseta Oversize Roxa	Size	XG	10	2025-12-24 14:38:34.583401
85	82	Camiseta Oversize Roxa	Size	GG	10	2025-12-24 14:38:34.583403
86	82	Camiseta Oversize Roxa	Size	G	10	2025-12-24 14:38:34.583405
87	82	Camiseta Oversize Roxa	Size	M	10	2025-12-24 14:38:34.583406
88	82	Camiseta Oversize Roxa	Size	P	10	2025-12-24 14:38:34.583407
89	82	Camiseta Oversize Roxa	Color	#8507F3	10	2025-12-24 14:38:34.583408
90	82	Camiseta Oversize Roxa	Color	#0F0F0F	10	2025-12-24 14:38:34.583409
91	83	Caneca Personalizada	Color	#FCF8F8	1	2025-12-24 15:40:25.038978
92	84	Boné Casual	Color	#0C0C0C	10	2025-12-24 19:33:49.960112
93	85	Moletom Demo Store – Preto Clássico	Size	GG	10	2025-12-24 20:04:24.742482
94	85	Moletom Demo Store – Preto Clássico	Color	#070707	10	2025-12-24 20:04:24.742485
\.


--
-- TOC entry 5217 (class 0 OID 148132)
-- Dependencies: 261
-- Data for Name: product_videos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_videos (id, product_id, video_path, created_at) FROM stdin;
\.


--
-- TOC entry 5218 (class 0 OID 148135)
-- Dependencies: 262
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.products (id, name, description, price, category_id, subcategory_id, image_paths, quantity, width, height, weight, length, user_id, thumbnail_path) FROM stdin;
82	Camiseta Oversize Roxa	Camiseta oversize confeccionada em algodão de alta qualidade, com caimento confortável e moderno. Ideal para o dia a dia, oferece liberdade de movimento e um visual urbano. Possui gola reforçada, mangas amplas e acabamento premium, garantindo durabilidade e estilo.\r\n\r\nProduto pensado para quem busca conforto sem abrir mão do visual.	69.90	31	32	["https://res.cloudinary.com/dnfnevy9e/image/upload/v1766587114/product_images/Camiseta_Oversize_Roxa/56710d72-89e2-45a8-8201-4f1d605aeb02_20251224143833299945.png"]	50	25	3	0.3	30	9d509dc8-9f53-4be5-985a-7105090a1a23	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766587112/product_images/Camiseta_Oversize_Roxa/56710d72-89e2-45a8-8201-4f1d605aeb02_20251224143832270922.png
83	Caneca Personalizada	Caneca personalizada em cerâmica de alta qualidade, ideal para presentear ou uso diário. Possui acabamento brilhante, estampa nítida e durável, resistente a lavagens. Perfeita para café, chá ou outras bebidas quentes e frias. Produto exclusivo, sem variação de modelo.\r\n\r\n📏 Dimensões e Especificações\r\n\r\nAltura: 9,5 cm\r\n\r\nLargura: 8 cm\r\n\r\nLargura (com alça): 12 cm\r\n\r\nPeso: 400 g\r\n\r\nCapacidade aproximada: 325 ml\r\n\r\n📦 Informações adicionais\r\n\r\nVariações: Não possui\r\n\r\nMaterial: Cerâmica\r\n\r\n	34.90	33	34	[""]	100	12	9.5	0.4	12	9d509dc8-9f53-4be5-985a-7105090a1a23	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766590169/product_images/Caneca_Personalizada/5ccb5095-0ea3-414a-ab09-088f9b944bcc_20251224152927255332.png
84	Boné Casual	O Boné Casual é a escolha ideal para quem busca estilo e conforto no dia a dia. Com design moderno e acabamento de qualidade, ele combina facilmente com diferentes looks, sendo perfeito para uso urbano, lazer ou atividades ao ar livre. Possui ajuste traseiro que garante melhor encaixe na cabeça e aba curva que oferece proteção contra o sol. Um acessório versátil, resistente e cheio de personalidade.	59.90	35	37	["https://res.cloudinary.com/dnfnevy9e/image/upload/v1766604829/product_images/Bone_Casual/ChatGPT_Image_24_de_dez._de_2025_16_26_27_20251224193348016809.png", "https://res.cloudinary.com/dnfnevy9e/image/upload/v1766604830/product_images/Bone_Casual/ChatGPT_Image_24_de_dez._de_2025_16_28_26_20251224193348996955.png"]	10	18	13	0.25	28	9d509dc8-9f53-4be5-985a-7105090a1a23	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766604828/product_images/Bone_Casual/ChatGPT_Image_24_de_dez._de_2025_16_25_34_20251224193345560596.png
85	Moletom Demo Store – Preto Clássico	O Moletom Demo Store Preto é a escolha ideal para quem busca estilo urbano, conforto e versatilidade no dia a dia. Produzido em tecido encorpado e macio, oferece excelente caimento e proteção térmica, sendo perfeito para dias frios ou meia-estação.\r\n\r\nCom design moderno e minimalista, o logotipo Demo Store estampado no peito adiciona personalidade e identidade à peça. Possui capuz ajustável com cordão, bolso canguru funcional e acabamento reforçado nos punhos e barra, garantindo durabilidade e conforto prolongado.\r\n\r\nIdeal para compor looks casuais, streetwear ou urbanos, seja para sair com amigos ou para o uso diário.	179.90	38	39	["https://res.cloudinary.com/dnfnevy9e/image/upload/v1766606663/product_images/Moletom_Demo_Store__Preto_Classico/ChatGPT_Image_24_de_dez._de_2025_16_56_51_20251224200421242675.jpg", "https://res.cloudinary.com/dnfnevy9e/image/upload/v1766606665/product_images/Moletom_Demo_Store__Preto_Classico/ChatGPT_Image_24_de_dez._de_2025_16_56_57_20251224200423173407.jpg"]	10	56	70	0.82	70	9d509dc8-9f53-4be5-985a-7105090a1a23	https://res.cloudinary.com/dnfnevy9e/image/upload/v1766606660/product_images/Moletom_Demo_Store__Preto_Classico/ChatGPT_Image_24_de_dez._de_2025_16_58_57_20251224200415465969.jpg
\.


--
-- TOC entry 5220 (class 0 OID 148141)
-- Dependencies: 264
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profiles (user_id, username, full_name, birth_date, avatar_url, phone, mobile, id, client_user_id, created_at, updated_at) FROM stdin;
\N	Christoffer Pádua 	Christoffer Pádua 	2005-07-21				2	\N	2025-10-22 00:55:10.962938	2025-10-22 21:15:43.645438
e77f01ac-251c-4a28-9a23-e55fba2afc13	client	rafael 	2025-10-24	https://res.cloudinary.com/dnfnevy9e/image/upload/v1761321842/user_avatars/fwc41kn2hlpy9z8oebep.jpg	(12) 34567-8909	(12) 34567-8909	13	\N	2025-10-24 16:03:39.35522	2025-10-24 13:03:58.352528
9d509dc8-9f53-4be5-985a-7105090a1a23	Teste	Teste	2000-01-01		(00) 00000-0000	(00) 00000-0000	17	\N	2025-11-25 00:57:39.960006	2025-12-22 23:24:11.552051
\.


--
-- TOC entry 5222 (class 0 OID 148149)
-- Dependencies: 266
-- Data for Name: seo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.seo (id, route, metatitle, metadescription, metakeywords, ogtitle, ogdescription, ogimage) FROM stdin;
1	7	dasdsadsa	dsadsa	sdsadsa	dsadsa	dsadsa	https://res.cloudinary.com/dnfnevy9e/image/upload/v1767542841/demo-store/seo/logo.png
2	7	teste	teste	teste	teste	teste	https://res.cloudinary.com/dnfnevy9e/image/upload/v1767542841/demo-store/seo/logo.png
\.


--
-- TOC entry 5223 (class 0 OID 148154)
-- Dependencies: 267
-- Data for Name: stock; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.stock (id, id_product, user_id, category_id, product_name, product_price, product_quantity, variations, created_at, updated_at) FROM stdin;
89	83	9d509dc8-9f53-4be5-985a-7105090a1a23	33	Caneca Personalizada	34.9	100	{"sizes": [], "colors": [{"value": "#FCF8F8", "quantity": 1}]}	2025-12-24 15:29:30.081185	2025-12-24 15:40:25.147367
90	84	9d509dc8-9f53-4be5-985a-7105090a1a23	35	Boné Casual	59.9	10	null	2025-12-24 19:33:49.904745	2025-12-24 19:33:49.904749
91	85	9d509dc8-9f53-4be5-985a-7105090a1a23	38	Moletom Demo Store – Preto Clássico	179.9	10	null	2025-12-24 20:04:24.689692	2025-12-24 20:04:24.689695
88	82	9d509dc8-9f53-4be5-985a-7105090a1a23	31	Camiseta Oversize Roxa	69.9	42	null	2025-12-24 14:38:34.523585	2026-01-04 15:15:47.981051
\.


--
-- TOC entry 5225 (class 0 OID 148160)
-- Dependencies: 269
-- Data for Name: subcategories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subcategories (id, name, category_id) FROM stdin;
\.


--
-- TOC entry 5226 (class 0 OID 148163)
-- Dependencies: 270
-- Data for Name: token_blocklist; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.token_blocklist (id, jti, user_id, created_at) FROM stdin;
73	2bbfc174-7867-489a-8f7e-212960a6aef9	9d509dc8-9f53-4be5-985a-7105090a1a23	2025-12-23 02:37:53.173583
74	822ca522-1f0b-486e-bee2-64ec3b41e8c1	e77f01ac-251c-4a28-9a23-e55fba2afc13	2025-12-24 21:39:12.660195
75	58c3dd39-5d9f-42ae-8d9f-482e497ef49d	9d509dc8-9f53-4be5-985a-7105090a1a23	2026-01-04 15:32:20.568693
76	4a9fff79-2288-45f0-b60f-5e68b30fbbb6	e77f01ac-251c-4a28-9a23-e55fba2afc13	2026-01-05 23:45:10.63523
\.


--
-- TOC entry 5228 (class 0 OID 148167)
-- Dependencies: 272
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (email, password, name, birth_date, type, fcm_token, created_at, updated_at, id) FROM stdin;
rafael.f.p.faria@hotmail.com	$2b$12$djZz.PBWYIXVn2IoVNdiGOmP0j0tBJ25.R6L9hoVXCguwB3goWlI.	Rafael Pádua	1991-06-05	admin	\N	2025-11-22 23:50:35.74066	2025-11-22 23:50:35.74066	9d509dc8-9f53-4be5-985a-7105090a1a23
paduachristoffer@gmail.com	$2b$12$WzkuF4w1h3isv7KZ/XVjX.LD4N5DCnfHr9NCZKVePviSv1WFH2tX2	Christoffer Pádua 	2005-07-21	admin	\N	2025-11-22 23:50:35.74066	2025-11-22 23:50:35.74066	2270f1e3-99e8-42c0-a0d7-930e750c8749
teste@email.com	$2b$12$sPuz7cwRfiNo6AAo1tsLvuzTIDryS44UZQbagkk.NwUY7g6uwzpQu	Teste	2000-01-01	admin	\N	2025-11-25 00:57:39.956587	2025-11-25 00:57:39.95659	97832ada-019c-42e3-b1e7-4b7f3c09a35c
\.


--
-- TOC entry 5230 (class 0 OID 148177)
-- Dependencies: 274
-- Data for Name: variations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.variations (id, product_id, variation_type, value, quantity) FROM stdin;
\.


--
-- TOC entry 5257 (class 0 OID 0)
-- Dependencies: 219
-- Name: addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.addresses_id_seq', 48, true);


--
-- TOC entry 5258 (class 0 OID 0)
-- Dependencies: 221
-- Name: blog_posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.blog_posts_id_seq', 23, true);


--
-- TOC entry 5259 (class 0 OID 0)
-- Dependencies: 223
-- Name: cart_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cart_items_id_seq', 157, true);


--
-- TOC entry 5260 (class 0 OID 0)
-- Dependencies: 225
-- Name: carts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.carts_id_seq', 6, true);


--
-- TOC entry 5261 (class 0 OID 0)
-- Dependencies: 277
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categories_id_seq', 39, true);


--
-- TOC entry 5262 (class 0 OID 0)
-- Dependencies: 228
-- Name: comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.comments_id_seq', 31, true);


--
-- TOC entry 5263 (class 0 OID 0)
-- Dependencies: 230
-- Name: coupons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.coupons_id_seq', 28, true);


--
-- TOC entry 5264 (class 0 OID 0)
-- Dependencies: 232
-- Name: coupons_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.coupons_user_id_seq', 13, true);


--
-- TOC entry 5265 (class 0 OID 0)
-- Dependencies: 233
-- Name: delivery_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.delivery_id_seq', 133, true);


--
-- TOC entry 5266 (class 0 OID 0)
-- Dependencies: 235
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.notifications_id_seq', 92, true);


--
-- TOC entry 5267 (class 0 OID 0)
-- Dependencies: 237
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_items_id_seq', 204, true);


--
-- TOC entry 5268 (class 0 OID 0)
-- Dependencies: 240
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.orders_id_seq', 254, true);


--
-- TOC entry 5269 (class 0 OID 0)
-- Dependencies: 242
-- Name: pages_new_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pages_new_id_seq', 7, true);


--
-- TOC entry 5270 (class 0 OID 0)
-- Dependencies: 244
-- Name: payment_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payment_products_id_seq', 3, true);


--
-- TOC entry 5271 (class 0 OID 0)
-- Dependencies: 246
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payments_id_seq', 185, true);


--
-- TOC entry 5272 (class 0 OID 0)
-- Dependencies: 247
-- Name: payments_product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payments_product_id_seq', 317, true);


--
-- TOC entry 5273 (class 0 OID 0)
-- Dependencies: 250
-- Name: post_comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.post_comments_id_seq', 7, true);


--
-- TOC entry 5274 (class 0 OID 0)
-- Dependencies: 252
-- Name: post_seo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.post_seo_id_seq', 4, true);


--
-- TOC entry 5275 (class 0 OID 0)
-- Dependencies: 254
-- Name: post_views_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.post_views_id_seq', 16, true);


--
-- TOC entry 5276 (class 0 OID 0)
-- Dependencies: 256
-- Name: product_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_images_id_seq', 33, true);


--
-- TOC entry 5277 (class 0 OID 0)
-- Dependencies: 258
-- Name: product_seo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_seo_id_seq', 70, true);


--
-- TOC entry 5278 (class 0 OID 0)
-- Dependencies: 260
-- Name: product_variations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_variations_id_seq', 96, true);


--
-- TOC entry 5279 (class 0 OID 0)
-- Dependencies: 263
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.products_id_seq', 86, true);


--
-- TOC entry 5280 (class 0 OID 0)
-- Dependencies: 265
-- Name: profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.profiles_id_seq', 17, true);


--
-- TOC entry 5281 (class 0 OID 0)
-- Dependencies: 278
-- Name: seo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seo_id_seq', 2, true);


--
-- TOC entry 5282 (class 0 OID 0)
-- Dependencies: 268
-- Name: stock_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.stock_id_seq', 92, true);


--
-- TOC entry 5283 (class 0 OID 0)
-- Dependencies: 271
-- Name: token_blocklist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.token_blocklist_id_seq', 76, true);


--
-- TOC entry 5284 (class 0 OID 0)
-- Dependencies: 273
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 3, true);


--
-- TOC entry 5285 (class 0 OID 0)
-- Dependencies: 275
-- Name: variations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.variations_id_seq', 1, false);


--
-- TOC entry 4967 (class 2606 OID 148195)
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- TOC entry 4969 (class 2606 OID 148197)
-- Name: blog_posts blog_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_posts
    ADD CONSTRAINT blog_posts_pkey PRIMARY KEY (id);


--
-- TOC entry 4971 (class 2606 OID 148199)
-- Name: blog_posts blog_posts_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_posts
    ADD CONSTRAINT blog_posts_slug_key UNIQUE (slug);


--
-- TOC entry 4973 (class 2606 OID 148201)
-- Name: cart_items cart_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_pkey PRIMARY KEY (id);


--
-- TOC entry 4975 (class 2606 OID 148203)
-- Name: carts carts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carts
    ADD CONSTRAINT carts_pkey PRIMARY KEY (id);


--
-- TOC entry 5016 (class 2606 OID 148338)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- TOC entry 4977 (class 2606 OID 148205)
-- Name: client_users client_users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_users
    ADD CONSTRAINT client_users_email_key UNIQUE (email);


--
-- TOC entry 4979 (class 2606 OID 148207)
-- Name: client_users client_users_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_users
    ADD CONSTRAINT client_users_pk PRIMARY KEY (id);


--
-- TOC entry 4981 (class 2606 OID 148209)
-- Name: pages pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id);


--
-- TOC entry 4983 (class 2606 OID 148211)
-- Name: payments_product payments_product_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments_product
    ADD CONSTRAINT payments_product_pkey PRIMARY KEY (id);


--
-- TOC entry 4985 (class 2606 OID 148213)
-- Name: post_comments post_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_comments
    ADD CONSTRAINT post_comments_pkey PRIMARY KEY (id);


--
-- TOC entry 4987 (class 2606 OID 148215)
-- Name: post_seo post_seo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_seo
    ADD CONSTRAINT post_seo_pkey PRIMARY KEY (id);


--
-- TOC entry 4989 (class 2606 OID 148217)
-- Name: post_seo post_seo_post_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_seo
    ADD CONSTRAINT post_seo_post_id_key UNIQUE (post_id);


--
-- TOC entry 4991 (class 2606 OID 148219)
-- Name: post_views post_views_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_views
    ADD CONSTRAINT post_views_pkey PRIMARY KEY (id);


--
-- TOC entry 4993 (class 2606 OID 148221)
-- Name: product_seo product_seo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_seo
    ADD CONSTRAINT product_seo_pkey PRIMARY KEY (id);


--
-- TOC entry 4996 (class 2606 OID 148223)
-- Name: product_variations product_variations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_variations
    ADD CONSTRAINT product_variations_pkey PRIMARY KEY (id);


--
-- TOC entry 4998 (class 2606 OID 148225)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- TOC entry 5000 (class 2606 OID 148227)
-- Name: profiles profiles_client_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_client_user_id_key UNIQUE (client_user_id);


--
-- TOC entry 5002 (class 2606 OID 148229)
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- TOC entry 5006 (class 2606 OID 148231)
-- Name: stock stock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT stock_pkey PRIMARY KEY (id);


--
-- TOC entry 5010 (class 2606 OID 148233)
-- Name: token_blocklist token_blocklist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.token_blocklist
    ADD CONSTRAINT token_blocklist_pkey PRIMARY KEY (id);


--
-- TOC entry 5004 (class 2606 OID 148235)
-- Name: profiles unique_user_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT unique_user_id UNIQUE (user_id);


--
-- TOC entry 5012 (class 2606 OID 148237)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 5014 (class 2606 OID 148239)
-- Name: variations variations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variations
    ADD CONSTRAINT variations_pkey PRIMARY KEY (id);


--
-- TOC entry 4994 (class 1259 OID 148240)
-- Name: ix_product_variations_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_product_variations_product_id ON public.product_variations USING btree (product_id);


--
-- TOC entry 5007 (class 1259 OID 148241)
-- Name: ix_token_blocklist_jti; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_token_blocklist_jti ON public.token_blocklist USING btree (jti);


--
-- TOC entry 5008 (class 1259 OID 148242)
-- Name: ix_token_blocklist_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_token_blocklist_user_id ON public.token_blocklist USING btree (user_id);


--
-- TOC entry 5028 (class 2620 OID 148243)
-- Name: profiles trigger_update_profiles_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- TOC entry 5017 (class 2606 OID 148244)
-- Name: addresses addresses_client_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_client_user_id_fkey FOREIGN KEY (client_user_id) REFERENCES public.client_users(id);


--
-- TOC entry 5018 (class 2606 OID 148249)
-- Name: addresses addresses_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(user_id) ON DELETE CASCADE;


--
-- TOC entry 5019 (class 2606 OID 148254)
-- Name: blog_posts blog_posts_page_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_posts
    ADD CONSTRAINT blog_posts_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id);


--
-- TOC entry 5020 (class 2606 OID 148259)
-- Name: cart_items cart_items_cart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_cart_id_fkey FOREIGN KEY (cart_id) REFERENCES public.carts(id);


--
-- TOC entry 5021 (class 2606 OID 148264)
-- Name: cart_items cart_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- TOC entry 5027 (class 2606 OID 148328)
-- Name: categories categories_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5022 (class 2606 OID 148269)
-- Name: cart_items fk_cart_items_user; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT fk_cart_items_user FOREIGN KEY (user_id) REFERENCES public.client_users(id);


--
-- TOC entry 5023 (class 2606 OID 148274)
-- Name: post_comments post_comments_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_comments
    ADD CONSTRAINT post_comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.blog_posts(id);


--
-- TOC entry 5024 (class 2606 OID 148279)
-- Name: post_seo post_seo_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_seo
    ADD CONSTRAINT post_seo_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.blog_posts(id);


--
-- TOC entry 5025 (class 2606 OID 148284)
-- Name: post_views post_views_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_views
    ADD CONSTRAINT post_views_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.blog_posts(id);


--
-- TOC entry 5026 (class 2606 OID 148289)
-- Name: variations variations_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.variations
    ADD CONSTRAINT variations_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


-- Completed on 2026-02-26 16:08:27

--
-- PostgreSQL database dump complete
--

\unrestrict 9uaaxkBBsfFVuwydq208gwPCzBs9ffQJhPbEYqwOPo7sZJpWtdIxN3JYDk4Fwne

--
-- Database "pizzaria_demo" dump
--

--
-- PostgreSQL database dump
--

\restrict u5FBNGOhtyWYeHGn2Ark2i5EuLdADMrARANzqDeh6FKCm2rdaNjogerOoo0ZCAU

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2026-02-26 16:08:27

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


\unrestrict u5FBNGOhtyWYeHGn2Ark2i5EuLdADMrARANzqDeh6FKCm2rdaNjogerOoo0ZCAU
\connect pizzaria_demo
\restrict u5FBNGOhtyWYeHGn2Ark2i5EuLdADMrARANzqDeh6FKCm2rdaNjogerOoo0ZCAU

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

COPY public.admins (id, username, password_hash) FROM stdin;
1	admin	$bcrypt-sha256$v=2,t=2b,r=12$Fe.1thrnKOkUf.dOb9qpOe$B/HifM0y/Tf6stBWXIShzLMTz9CcFEK
\.


--
-- TOC entry 5003 (class 0 OID 163880)
-- Dependencies: 232
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.categories (id, name, title, description, icon, image_url, slug, "order", is_active, created_at, updated_at) FROM stdin;
6	pizzas	Pizzas	Clássicas e especiais com massa artesanal.	🍕	\N	pizzas	1	t	2026-02-20 00:58:54.987216-03	\N
7	lanches	Lanches	Combos completos para matar a fome.	🍔	\N	lanches	2	t	2026-02-20 00:58:54.987216-03	\N
8	bebidas	Bebidas	Refrigerantes, sucos e águas geladas.	🥤	\N	bebidas	3	t	2026-02-20 00:58:54.987216-03	\N
\.


--
-- TOC entry 4997 (class 0 OID 155703)
-- Dependencies: 226
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_items (id, order_id, product_id, quantity, unit_price, product_name) FROM stdin;
1	1	\N	1	39.90	Margherita Clássica
2	2	16	1	14.90	Milkshake 400ml
3	3	10	1	46.90	Quatro Queijos
4	4	\N	1	8.90	Chá Gelado 400ml
5	5	\N	1	8.90	Chá Gelado 400ml
6	6	\N	1	8.90	Chá Gelado 400ml
7	7	\N	1	8.90	Chá Gelado 400ml
8	8	\N	1	10.00	Item Teste
9	9	\N	1	8.90	Chá Gelado 400ml
10	10	\N	1	8.90	Chá Gelado 400ml
11	11	\N	1	8.90	Chá Gelado 400ml
12	12	\N	1	8.90	Chá Gelado 400ml
13	13	\N	1	8.90	Chá Gelado 400ml
14	14	\N	1	8.90	Chá Gelado 400ml
15	15	\N	1	8.90	Chá Gelado 400ml
16	16	\N	1	8.90	Chá Gelado 400ml
17	17	\N	1	8.90	Chá Gelado 400ml
18	18	\N	1	8.90	Chá Gelado 400ml
19	19	\N	1	8.90	Chá Gelado 400ml
20	20	\N	1	8.90	Chá Gelado 400ml
21	21	\N	1	8.90	Chá Gelado 400ml
22	22	\N	1	8.90	Chá Gelado 400ml
23	23	\N	1	8.90	Chá Gelado 400ml
24	24	\N	1	8.90	Chá Gelado 400ml
25	25	\N	1	8.90	Chá Gelado 400ml
26	25	\N	1	5.00	Taxa de entrega
27	26	\N	1	14.90	Milkshake 400ml
28	26	\N	1	5.00	Taxa de entrega
29	27	\N	1	8.90	Chá Gelado 400ml
30	27	\N	1	5.00	Taxa de entrega
31	28	\N	1	8.90	Chá Gelado 400ml
32	28	\N	1	5.00	Taxa de entrega
33	29	\N	1	8.90	Chá Gelado 400ml
34	29	\N	1	5.00	Taxa de entrega
35	30	\N	1	8.90	Chá Gelado 400ml
36	30	\N	1	5.00	Taxa de entrega
37	31	\N	1	8.90	Chá Gelado 400ml
38	31	\N	1	5.00	Taxa de entrega
39	32	\N	1	8.90	Chá Gelado 400ml
40	32	\N	1	5.00	Taxa de entrega
41	33	\N	1	8.90	Chá Gelado 400ml
42	33	\N	1	5.00	Taxa de entrega
43	34	\N	1	8.90	Chá Gelado 400ml
44	34	\N	1	5.00	Taxa de entrega
45	35	\N	1	8.90	Chá Gelado 400ml
46	35	\N	1	5.00	Taxa de entrega
\.


--
-- TOC entry 4993 (class 0 OID 155679)
-- Dependencies: 222
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.orders (id, total, created_at, customer_name, customer_phone, total_amount, status, restaurant_id, payment_status, mercadopago_preference_id, mercadopago_payment_id, delivery_fee) FROM stdin;
1	\N	2026-02-23 05:52:10.016098	teste	\N	39.9	pending	\N	pending	\N	\N	0
2	\N	2026-02-23 06:00:32.82204	teste	\N	17.64	pending	\N	pending	\N	\N	0
3	\N	2026-02-23 14:20:03.048295	teste	\N	49.64	pending	\N	pending	\N	\N	0
4	\N	2026-02-24 19:30:22.075837	rafael	\N	13.9	pending	1	pending	\N	\N	5
5	\N	2026-02-24 19:32:14.952922	rafael	\N	13.9	pending	1	pending	\N	\N	5
6	\N	2026-02-24 19:36:39.88883	rafael	\N	13.9	pending	1	pending	\N	\N	5
7	\N	2026-02-24 19:39:28.786018	rafael	\N	13.9	pending	1	pending	\N	\N	5
8	\N	2026-02-24 19:58:54.792128	Teste Checkout	11999999999	10	pending	1	pending	\N	\N	0
9	\N	2026-02-24 19:59:50.719856	rafael	\N	13.9	pending	1	pending	\N	\N	5
10	\N	2026-02-25 02:13:28.457304	rafael	\N	13.9	pending	1	pending	\N	\N	5
12	\N	2026-02-25 02:21:30.999494	rafael	\N	13.9	pending	1	pending	\N	\N	5
11	\N	2026-02-25 02:18:39.511417	rafael	\N	13.9	pending	1	pending	171906724-fa5f1c4f-f5ad-42fa-b99d-4a21d9b15550	\N	5
13	\N	2026-02-25 02:35:02.438735	rafael	\N	13.9	pending	1	pending	171906724-f86e6739-fade-412c-adf1-638d74e2fd0a	\N	5
14	\N	2026-02-25 02:43:08.511649	rafael	\N	13.9	pending	1	pending	171906724-de99788c-578a-46e6-a189-d1459a9fed4a	\N	5
15	\N	2026-02-25 02:44:23.055959	rafael	\N	13.9	pending	1	pending	171906724-548770cd-4d89-4c06-8345-0134d4e1a797	\N	5
16	\N	2026-02-25 02:45:02.048869	rafael	\N	13.9	pending	1	pending	171906724-4fa072a9-e5ad-46e9-96d3-7e983c0bd1a2	\N	5
17	\N	2026-02-25 02:51:48.02006	rafael	\N	13.9	pending	1	pending	171906724-e417d54c-abcb-420e-a2e5-8affd4dc7955	\N	5
18	\N	2026-02-25 02:56:32.584428	rafael	\N	13.9	pending	1	pending	171906724-8b62cef5-d4a3-495c-870f-f6ea6b52d80d	\N	5
19	\N	2026-02-25 02:57:31.53928	rafael	\N	13.9	pending	1	pending	171906724-c9f89e50-6009-4c9d-a33b-74fea9437712	\N	5
20	\N	2026-02-25 03:00:52.593153	rafael	\N	13.9	pending	1	pending	171906724-9ded6226-2169-42e1-b620-a82e14c4a72b	\N	5
21	\N	2026-02-25 03:04:56.723522	rafael	\N	13.9	pending	1	pending	171906724-5dd19778-dbf4-4937-8468-1aca1144b791	\N	5
22	\N	2026-02-25 03:09:00.053244	rafael	\N	13.9	pending	1	pending	171906724-0da10095-6508-43c1-8543-714309ee3057	\N	5
23	\N	2026-02-25 03:10:33.105514	rafael	\N	13.9	pending	1	pending	171906724-2e2a3db2-2605-4866-afc9-c74b19ca2639	\N	5
24	\N	2026-02-25 03:13:09.436642	rafael	\N	13.9	pending	1	pending	171906724-1bddc21d-0cd1-429c-b197-f13b9292f7c8	\N	5
25	\N	2026-02-26 03:47:00.38733	rafael	\N	18.9	pending	1	pending	171906724-c01f2028-31e0-43d4-bc1b-aaa12a11f814	\N	5
26	\N	2026-02-26 03:49:56.334623	Rafael	\N	24.9	pending	1	pending	171906724-ddcded35-76f9-42f0-a62e-00ecd073f8c5	\N	5
27	\N	2026-02-26 04:18:19.304247	rafael	\N	18.9	pending	1	pending	171906724-3e33e1e6-e71c-43aa-831f-c85036232e78	\N	5
28	\N	2026-02-26 04:42:32.218152	rafael	\N	18.9	pending	1	pending	171906724-f32c9bf1-069b-4779-90a8-74d010e91a98	\N	5
29	\N	2026-02-26 04:44:25.722207	rafael	\N	18.9	pending	1	pending	171906724-961fa9eb-ead7-45fa-8e21-c272668d016e	\N	5
30	\N	2026-02-26 04:47:47.419131	rafael	\N	18.9	pending	1	pending	171906724-df08a965-69ef-4dce-b09b-c11c763b0d06	\N	5
31	\N	2026-02-26 04:52:33.260526	rafael	\N	18.9	pending	1	pending	171906724-7c48587a-db7a-4737-bd18-2d49e12f295e	\N	5
32	\N	2026-02-26 05:07:06.45165	rafael	\N	18.9	pending	1	pending	171906724-41f5a92c-12b8-41f7-97d1-c3cbd636649e	\N	5
33	\N	2026-02-26 05:27:48.679222	rafael	\N	18.9	pending	1	pending	\N	\N	5
34	\N	2026-02-26 16:46:59.253134	rafael	\N	18.9	pending	1	pending	171906724-3ce5c680-b7f5-4862-b030-1e7343cc529a	\N	5
35	\N	2026-02-26 16:52:35.596297	rafael	\N	18.9	pending	1	pending	171906724-bc1bdac9-88a8-4be5-b02b-cfcdc71de308	\N	5
\.


--
-- TOC entry 4999 (class 0 OID 163852)
-- Dependencies: 228
-- Data for Name: page_sections; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.page_sections (id, name, title, subtitle, content, image_url, link, "order", created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5001 (class 0 OID 163866)
-- Dependencies: 230
-- Data for Name: pages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pages (id, slug, title, content, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 4995 (class 0 OID 155687)
-- Dependencies: 224
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.products (id, name, description, price, category_id, image_url, is_active) FROM stdin;
8	Margherita Clássica	Molho artesanal, mussarela, tomate italiano, manjericão e azeite extra virgem.	39.90	6	cf070fcd3e6542eab202e0a0a0585db6.avif	t
9	Pepperoni Supreme	Mussarela, pepperoni crocante, molho rústico e finalização com orégano.	44.90	6	34c33b9543bb4b5ea8e6083c5cd797a9.webp	t
10	Quatro Queijos	Mussarela, gorgonzola, parmesão, provolone e toque de mel artesanal.	46.90	6	31e3aebbac874922ad23aeb9f4200d51.avif	t
11	Combo Smash Clássico	Burger smash com cheddar, batatas crocantes e refrigerante 350ml.	26.90	7	0c6ea64baecf4dc0bcbfb897eb94c18e.jpg	t
12	Combo Bacon Cheddar	Hambúrguer com bacon e cheddar, batatas rústicas e bebida à escolha.	31.90	7	b23be7c248bb4297a9a96dc5099fa97d.jpg	t
13	Combo Família	Cheeseburger completo, batatas generosas e bebida grande.	44.90	7	5f8c08ecd05946b19ab38ffbe584ff18.jpg	t
16	Milkshake 400ml	Chocolate, baunilha ou morango com chantilly.	14.90	8	01f56195f844451e933e026ac36fc027.jpg	t
15	Refrigerante 1,5L	Ideal para dividir. Opções variadas no gelo.	12.90	8	619391ae3c27407abcb2d61a16e88538.jpg	t
14	Refrigerante Lata 350ml	Coca, Guaraná, Sprite ou Fanta bem gelados.	6.90	8	e40dedcbefb842ef96e6a0d71579391a.jpg	t
\.


--
-- TOC entry 5005 (class 0 OID 172045)
-- Dependencies: 234
-- Data for Name: restaurants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.restaurants (id, name, slug, mercadopago_access_token, created_at) FROM stdin;
1	Pizzaria Demo	pizzaria-demo	TEST-2446436736709243-040921-fed94a5bb0191a0e1903980cdd8485a4-171906724	2026-02-24 17:39:14.95548
\.


--
-- TOC entry 4991 (class 0 OID 155671)
-- Dependencies: 220
-- Data for Name: sections; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sections (id, name, "order") FROM stdin;
\.


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


-- Completed on 2026-02-26 16:08:27

--
-- PostgreSQL database dump complete
--

\unrestrict u5FBNGOhtyWYeHGn2Ark2i5EuLdADMrARANzqDeh6FKCm2rdaNjogerOoo0ZCAU

-- Completed on 2026-02-26 16:08:27

--
-- PostgreSQL database cluster dump complete
--

