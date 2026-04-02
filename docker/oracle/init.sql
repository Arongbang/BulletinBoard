-- ============================================================
--  BulletinBoard — Oracle XE 초기화 스크립트
--  실행 시점: 컨테이너 최초 기동 시 board_user 로 자동 실행
--             (oracle-data 볼륨이 비어 있을 때만 동작)
--
--  ※ board_user 계정 생성 및 기본 권한(CONNECT, RESOURCE)은
--    docker-compose.yml 의 APP_USER / APP_USER_PASSWORD 환경변수를
--    gvenzl/oracle-xe 이미지가 자동으로 처리합니다.
--    이 스크립트는 board_user 로 연결된 상태에서 실행되므로
--    CREATE USER / GRANT 명령이 필요 없습니다.
--
--  참고 — 이미지가 내부적으로 수행하는 동작 (직접 실행 불필요):
--    CREATE USER board_user IDENTIFIED BY board_pass;
--    GRANT CONNECT, RESOURCE, UNLIMITED TABLESPACE TO board_user;
-- ============================================================


-- ============================================================
--  SEQUENCES
--  멱등성: ORA-00955 (이미 존재) 발생 시 조용히 무시
-- ============================================================

BEGIN
    EXECUTE IMMEDIATE
        'CREATE SEQUENCE users_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN NULL; -- 이미 존재하면 건너뜀
        ELSE RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE
        'CREATE SEQUENCE posts_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN NULL;
        ELSE RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE
        'CREATE SEQUENCE comments_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN NULL;
        ELSE RAISE;
        END IF;
END;
/


-- ============================================================
--  TABLE: users
-- ============================================================

BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE users (
            id        NUMBER        DEFAULT users_seq.NEXTVAL PRIMARY KEY,
            username  VARCHAR2(50)  NOT NULL,
            password  VARCHAR2(255) NOT NULL,
            CONSTRAINT uq_users_username UNIQUE (username)
        )
    ';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN NULL;
        ELSE RAISE;
        END IF;
END;
/


-- ============================================================
--  TABLE: posts
-- ============================================================

BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE posts (
            id         NUMBER        DEFAULT posts_seq.NEXTVAL PRIMARY KEY,
            title      VARCHAR2(200) NOT NULL,
            content    CLOB          NOT NULL,
            user_id    NUMBER        NOT NULL,
            created_at TIMESTAMP     DEFAULT CURRENT_TIMESTAMP NOT NULL,
            updated_at TIMESTAMP     DEFAULT CURRENT_TIMESTAMP NOT NULL,
            CONSTRAINT fk_posts_user
                FOREIGN KEY (user_id) REFERENCES users(id)
        )
    ';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN NULL;
        ELSE RAISE;
        END IF;
END;
/


-- ============================================================
--  TABLE: comments
-- ============================================================

BEGIN
    EXECUTE IMMEDIATE '
        CREATE TABLE comments (
            id         NUMBER          DEFAULT comments_seq.NEXTVAL PRIMARY KEY,
            content    VARCHAR2(1000)  NOT NULL,
            post_id    NUMBER          NOT NULL,
            user_id    NUMBER          NOT NULL,
            created_at TIMESTAMP       DEFAULT CURRENT_TIMESTAMP NOT NULL,
            CONSTRAINT fk_comments_post
                FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
            CONSTRAINT fk_comments_user
                FOREIGN KEY (user_id) REFERENCES users(id)
        )
    ';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN NULL;
        ELSE RAISE;
        END IF;
END;
/


-- ============================================================
--  완료 확인 로그 (sqlplus 출력에서 확인 가능)
-- ============================================================

SELECT 'init.sql 완료 — ' || object_type || ': ' || object_name AS init_log
FROM   user_objects
WHERE  object_type IN ('TABLE', 'SEQUENCE')
ORDER  BY object_type, object_name;
