SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: asked_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asked_users (
    id bigint NOT NULL,
    user_id character varying,
    post_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: asked_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.asked_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: asked_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.asked_users_id_seq OWNED BY public.asked_users.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts (
    id bigint NOT NULL,
    title character varying,
    bestanswer_reward integer,
    source_url character varying,
    state character varying DEFAULT 'open'::character varying,
    body text,
    code text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id character varying
);


--
-- Name: review_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.review_links (
    id bigint NOT NULL,
    "from" integer,
    "to" integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reviews (
    id bigint NOT NULL,
    body text,
    thrown_coins integer DEFAULT 0,
    user_id character varying,
    post_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    "primary" boolean
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id character varying(36) NOT NULL,
    name character varying,
    email character varying,
    password_digest character varying,
    nickname character varying,
    admin boolean DEFAULT false,
    activation_digest character varying,
    activated boolean,
    activated_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    icon character varying,
    explanation character varying,
    coins integer,
    discarded_at timestamp without time zone
);


--
-- Name: join_reviews; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.join_reviews AS
 SELECT posts.id AS post_id,
    review.id AS review_id,
    review.body AS review_body,
    review.created_at AS review_created_at,
    review.thrown_coins AS review_thrown_coins,
        CASE
            WHEN (reviewer.discarded_at IS NULL) THEN review.user_id
            ELSE NULL::character varying
        END AS reviewer_id,
        CASE
            WHEN (reviewer.discarded_at IS NULL) THEN reviewer.name
            ELSE NULL::character varying
        END AS reviewer_name,
        CASE
            WHEN (reviewer.discarded_at IS NULL) THEN reviewer.nickname
            ELSE NULL::character varying
        END AS reviewer_nickname,
        CASE
            WHEN (reviewer.discarded_at IS NULL) THEN reviewer.icon
            ELSE NULL::character varying
        END AS reviewer_icon,
    response.id AS response_id,
    response.body AS response_body,
    response.created_at AS response_created_at,
    response.thrown_coins AS response_thrown_coins,
        CASE
            WHEN (responder.discarded_at IS NULL) THEN response.user_id
            ELSE NULL::character varying
        END AS responder_id,
        CASE
            WHEN (responder.discarded_at IS NULL) THEN responder.name
            ELSE NULL::character varying
        END AS responder_name,
        CASE
            WHEN (responder.discarded_at IS NULL) THEN responder.nickname
            ELSE NULL::character varying
        END AS responder_nickname,
        CASE
            WHEN (responder.discarded_at IS NULL) THEN responder.icon
            ELSE NULL::character varying
        END AS responder_icon
   FROM (((((public.posts
     LEFT JOIN public.reviews review ON ((review.post_id = posts.id)))
     LEFT JOIN public.users reviewer ON (((reviewer.id)::text = (review.user_id)::text)))
     LEFT JOIN public.review_links ON ((review.id = review_links."from")))
     LEFT JOIN public.reviews response ON ((response.id = review_links."to")))
     LEFT JOIN public.users responder ON (((responder.id)::text = (response.user_id)::text)))
  WHERE (review."primary" = true)
  ORDER BY review.created_at, response.created_at;


--
-- Name: master_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.master_sessions (
    id bigint NOT NULL,
    user_id character varying,
    token_digest character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: master_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.master_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: master_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.master_sessions_id_seq OWNED BY public.master_sessions.id;


--
-- Name: onetime_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.onetime_sessions (
    id bigint NOT NULL,
    user_id character varying,
    token_digest character varying,
    master_session_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: onetime_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.onetime_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: onetime_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.onetime_sessions_id_seq OWNED BY public.onetime_sessions.id;


--
-- Name: password_reset_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_reset_sessions (
    id bigint NOT NULL,
    user_id character varying,
    token_digest character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: password_reset_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.password_reset_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: password_reset_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.password_reset_sessions_id_seq OWNED BY public.password_reset_sessions.id;


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;


--
-- Name: review_coin_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.review_coin_transactions (
    id bigint NOT NULL,
    "from" character varying,
    "to" character varying,
    review_id bigint,
    amount integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: review_coin_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.review_coin_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: review_coin_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.review_coin_transactions_id_seq OWNED BY public.review_coin_transactions.id;


--
-- Name: review_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.review_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: review_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.review_links_id_seq OWNED BY public.review_links.id;


--
-- Name: reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reviews_id_seq OWNED BY public.reviews.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: show_reviews; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.show_reviews AS
 SELECT result.post_id,
    result.review_id,
    result.review_body,
    result.review_created_at,
    result.review_thrown_coins,
    result.reviewer_id,
    result.reviewer_name,
    result.reviewer_nickname,
    result.reviewer_icon,
    result.response_id,
    result.response_body,
    result.response_created_at,
    result.response_thrown_coins,
    result.responder_id,
    result.responder_name,
    result.responder_nickname,
    result.responder_icon
   FROM ( SELECT join_reviews.post_id,
            join_reviews.review_id,
            join_reviews.review_body,
            join_reviews.review_created_at,
            join_reviews.review_thrown_coins,
            join_reviews.reviewer_id,
            join_reviews.reviewer_name,
            join_reviews.reviewer_nickname,
            join_reviews.reviewer_icon,
            join_reviews.response_id,
            join_reviews.response_body,
            join_reviews.response_created_at,
            join_reviews.response_thrown_coins,
            join_reviews.responder_id,
            join_reviews.responder_name,
            join_reviews.responder_nickname,
            join_reviews.responder_icon
           FROM public.join_reviews
        UNION
         SELECT join_reviews.post_id,
            join_reviews.review_id,
            join_reviews.review_body,
            join_reviews.review_created_at,
            join_reviews.review_thrown_coins,
            join_reviews.reviewer_id,
            join_reviews.reviewer_name,
            join_reviews.reviewer_nickname,
            join_reviews.reviewer_icon,
            NULL::bigint AS response_id,
            NULL::text AS response_body,
            NULL::timestamp without time zone AS response_created_at,
            NULL::integer AS response_thrown_coins,
            NULL::character varying AS responder_id,
            NULL::character varying AS responder_name,
            NULL::character varying AS responder_nickname,
            NULL::character varying AS responder_icon
           FROM public.join_reviews
          WHERE (join_reviews.response_id IS NOT NULL)) result
  ORDER BY result.review_created_at, result.response_created_at NULLS FIRST;


--
-- Name: asked_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asked_users ALTER COLUMN id SET DEFAULT nextval('public.asked_users_id_seq'::regclass);


--
-- Name: master_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_sessions ALTER COLUMN id SET DEFAULT nextval('public.master_sessions_id_seq'::regclass);


--
-- Name: onetime_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.onetime_sessions ALTER COLUMN id SET DEFAULT nextval('public.onetime_sessions_id_seq'::regclass);


--
-- Name: password_reset_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_sessions ALTER COLUMN id SET DEFAULT nextval('public.password_reset_sessions_id_seq'::regclass);


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);


--
-- Name: review_coin_transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_coin_transactions ALTER COLUMN id SET DEFAULT nextval('public.review_coin_transactions_id_seq'::regclass);


--
-- Name: review_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_links ALTER COLUMN id SET DEFAULT nextval('public.review_links_id_seq'::regclass);


--
-- Name: reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews ALTER COLUMN id SET DEFAULT nextval('public.reviews_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: asked_users asked_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asked_users
    ADD CONSTRAINT asked_users_pkey PRIMARY KEY (id);


--
-- Name: master_sessions master_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_sessions
    ADD CONSTRAINT master_sessions_pkey PRIMARY KEY (id);


--
-- Name: onetime_sessions onetime_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.onetime_sessions
    ADD CONSTRAINT onetime_sessions_pkey PRIMARY KEY (id);


--
-- Name: password_reset_sessions password_reset_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_sessions
    ADD CONSTRAINT password_reset_sessions_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: review_coin_transactions review_coin_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_coin_transactions
    ADD CONSTRAINT review_coin_transactions_pkey PRIMARY KEY (id);


--
-- Name: review_links review_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_links
    ADD CONSTRAINT review_links_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_asked_users_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_asked_users_on_post_id ON public.asked_users USING btree (post_id);


--
-- Name: index_onetime_sessions_on_master_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_onetime_sessions_on_master_session_id ON public.onetime_sessions USING btree (master_session_id);


--
-- Name: index_posts_on_body; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_body ON public.posts USING btree (body);


--
-- Name: index_posts_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_code ON public.posts USING btree (code);


--
-- Name: index_posts_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_title ON public.posts USING btree (title);


--
-- Name: index_review_coin_transactions_on_review_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_review_coin_transactions_on_review_id ON public.review_coin_transactions USING btree (review_id);


--
-- Name: index_reviews_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reviews_on_post_id ON public.reviews USING btree (post_id);


--
-- Name: index_users_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_discarded_at ON public.users USING btree (discarded_at);


--
-- Name: onetime_sessions fk_rails_1428a351ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.onetime_sessions
    ADD CONSTRAINT fk_rails_1428a351ac FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: asked_users fk_rails_39ba0f630e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asked_users
    ADD CONSTRAINT fk_rails_39ba0f630e FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: master_sessions fk_rails_54bfde8022; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.master_sessions
    ADD CONSTRAINT fk_rails_54bfde8022 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: posts fk_rails_5b5ddfd518; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT fk_rails_5b5ddfd518 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: review_links fk_rails_7233df4717; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_links
    ADD CONSTRAINT fk_rails_7233df4717 FOREIGN KEY ("from") REFERENCES public.reviews(id);


--
-- Name: reviews fk_rails_74a66bd6c5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT fk_rails_74a66bd6c5 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: review_coin_transactions fk_rails_a45d8b3f22; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_coin_transactions
    ADD CONSTRAINT fk_rails_a45d8b3f22 FOREIGN KEY ("to") REFERENCES public.users(id);


--
-- Name: reviews fk_rails_a4cffdde38; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT fk_rails_a4cffdde38 FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: review_coin_transactions fk_rails_ab46003f6a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_coin_transactions
    ADD CONSTRAINT fk_rails_ab46003f6a FOREIGN KEY (review_id) REFERENCES public.reviews(id);


--
-- Name: onetime_sessions fk_rails_b8f193c7f1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.onetime_sessions
    ADD CONSTRAINT fk_rails_b8f193c7f1 FOREIGN KEY (master_session_id) REFERENCES public.master_sessions(id);


--
-- Name: review_coin_transactions fk_rails_dcb402afe8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_coin_transactions
    ADD CONSTRAINT fk_rails_dcb402afe8 FOREIGN KEY ("from") REFERENCES public.users(id);


--
-- Name: password_reset_sessions fk_rails_dd09dd6855; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_sessions
    ADD CONSTRAINT fk_rails_dd09dd6855 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: review_links fk_rails_e1d045a493; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_links
    ADD CONSTRAINT fk_rails_e1d045a493 FOREIGN KEY ("to") REFERENCES public.reviews(id);


--
-- Name: asked_users fk_rails_f27d95bd0d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asked_users
    ADD CONSTRAINT fk_rails_f27d95bd0d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20200807145129'),
('20200807154520'),
('20200807173416'),
('20200810210809'),
('20200811145804'),
('20200814115929'),
('20200820034203'),
('20200820070623'),
('20200825135639'),
('20200901015235'),
('20200901030647'),
('20200901113634'),
('20200901123706'),
('20200902094116'),
('20200902133349'),
('20200928045505'),
('20200929072258');


