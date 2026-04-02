-- =====================
-- SEQUENCES
-- =====================
CREATE SEQUENCE users_seq    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE posts_seq    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE comments_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- =====================
-- TABLES
-- =====================
CREATE TABLE users (
    id       NUMBER        DEFAULT users_seq.NEXTVAL PRIMARY KEY,
    username VARCHAR2(50)  NOT NULL UNIQUE,
    password VARCHAR2(255) NOT NULL
);

CREATE TABLE posts (
    id         NUMBER          DEFAULT posts_seq.NEXTVAL PRIMARY KEY,
    title      VARCHAR2(200)   NOT NULL,
    content    CLOB            NOT NULL,
    user_id    NUMBER          NOT NULL,
    created_at TIMESTAMP       DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP       DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_posts_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE comments (
    id         NUMBER           DEFAULT comments_seq.NEXTVAL PRIMARY KEY,
    content    VARCHAR2(1000)   NOT NULL,
    post_id    NUMBER           NOT NULL,
    user_id    NUMBER           NOT NULL,
    created_at TIMESTAMP        DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_comments_post FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    CONSTRAINT fk_comments_user FOREIGN KEY (user_id) REFERENCES users(id)
);
