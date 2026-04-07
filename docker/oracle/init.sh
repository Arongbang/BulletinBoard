#!/bin/bash
# ============================================================
#  BulletinBoard — Oracle XE 스키마 초기화
#  gvenzl/oracle-xe 이미지는 .sql 파일을 SYS로 실행하므로
#  .sh 래퍼를 통해 board_user(APP_USER)로 명시 접속합니다.
# ============================================================
set -e

echo ">>> [init.sh] board_user 스키마 초기화 시작..."

sqlplus -s "${APP_USER}/${APP_USER_PASSWORD}@//localhost/XEPDB1" <<'SQLEOF'
SET SERVEROUTPUT ON
SET FEEDBACK ON

-- ============================================================
--  SEQUENCES  (멱등성: 이미 존재하면 무시)
-- ============================================================

BEGIN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE users_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE posts_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE comments_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
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
            role      VARCHAR2(20)  DEFAULT ''USER'' NOT NULL,
            CONSTRAINT uq_users_username UNIQUE (username)
        )
    ';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
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
    WHEN OTHERS THEN IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
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
    WHEN OTHERS THEN IF SQLCODE = -955 THEN NULL; ELSE RAISE; END IF;
END;
/

-- 완료 확인
SELECT 'init.sh 완료 — ' || object_type || ': ' || object_name AS init_log
FROM   user_objects
WHERE  object_type IN ('TABLE', 'SEQUENCE')
  AND  object_name IN ('USERS','POSTS','COMMENTS','USERS_SEQ','POSTS_SEQ','COMMENTS_SEQ')
ORDER  BY object_type, object_name;

SQLEOF

echo ">>> [init.sh] 스키마 초기화 완료."
