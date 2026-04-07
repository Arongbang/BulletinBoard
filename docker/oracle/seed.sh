#!/bin/bash
# ============================================================
#  BulletinBoard — 개발용 샘플 데이터 시드
#  board_user(APP_USER)로 명시 접속하여 DML 실행
#
#  계정 정보 (로그인 테스트용):
#    admin   / password123  (role: ADMIN)
#    alice   / password123  (role: USER)
#    bob     / password123  (role: USER)
# ============================================================
set -e

echo ">>> [seed.sh] 샘플 데이터 삽입 시작..."

sqlplus -s "${APP_USER}/${APP_USER_PASSWORD}@//localhost/XEPDB1" <<'SQLEOF'
SET FEEDBACK ON

-- 기존 샘플 데이터 정리 (재실행 시 중복 방지)
DELETE FROM comments WHERE user_id IN (
    SELECT id FROM users WHERE username IN ('admin', 'alice', 'bob')
);
DELETE FROM posts WHERE user_id IN (
    SELECT id FROM users WHERE username IN ('admin', 'alice', 'bob')
);
DELETE FROM users WHERE username IN ('admin', 'alice', 'bob');

-- ============================================================
--  USERS  (비밀번호: password123, BCrypt rounds=10)
-- ============================================================

INSERT INTO users (id, username, password, role) VALUES (
    users_seq.NEXTVAL,
    'admin',
    '$2a$10$F5SaDamn7R/8yLWfIrCRre5DQRv9CVfC20Khu3fUtBhvTkjTEjYCe',
    'ADMIN'
);

INSERT INTO users (id, username, password, role) VALUES (
    users_seq.NEXTVAL,
    'alice',
    '$2a$10$F5SaDamn7R/8yLWfIrCRre5DQRv9CVfC20Khu3fUtBhvTkjTEjYCe',
    'USER'
);

INSERT INTO users (id, username, password, role) VALUES (
    users_seq.NEXTVAL,
    'bob',
    '$2a$10$F5SaDamn7R/8yLWfIrCRre5DQRv9CVfC20Khu3fUtBhvTkjTEjYCe',
    'USER'
);

-- ============================================================
--  POSTS
-- ============================================================

INSERT INTO posts (id, title, content, user_id, created_at, updated_at) VALUES (
    posts_seq.NEXTVAL,
    '게시판에 오신 것을 환영합니다!',
    '안녕하세요. 이 게시판은 Spring Boot + Vue 3 + Oracle XE 로 구성된 토이 프로젝트입니다.' || CHR(10) ||
    '자유롭게 글을 작성하고 댓글을 남겨보세요.',
    (SELECT id FROM users WHERE username = 'admin'),
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
);

INSERT INTO posts (id, title, content, user_id, created_at, updated_at) VALUES (
    posts_seq.NEXTVAL,
    'Docker Compose 로컬 개발 환경 구성 팁',
    'Oracle XE 컨테이너 최초 기동 시 약 3~4분 소요될 수 있습니다.' || CHR(10) ||
    'healthcheck 덕분에 backend 는 oracle-db 가 준비된 후에 시작됩니다.' || CHR(10) || CHR(10) ||
    '포트 안내:' || CHR(10) ||
    '- 웹 UI : http://localhost' || CHR(10) ||
    '- Oracle (외부 클라이언트용) : localhost:1522',
    (SELECT id FROM users WHERE username = 'admin'),
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
);

INSERT INTO posts (id, title, content, user_id, created_at, updated_at) VALUES (
    posts_seq.NEXTVAL,
    'Spring Security 세션 기반 인증 구현 후기',
    'JWT 대신 세션 쿠키 방식을 선택한 이유:' || CHR(10) ||
    '1. 토큰 탈취 시 즉시 무효화 가능' || CHR(10) ||
    '2. 구현이 단순하고 Spring Security 기본 지원' || CHR(10) ||
    '3. SameSite=Lax 설정으로 CSRF 위험 최소화',
    (SELECT id FROM users WHERE username = 'alice'),
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
);

INSERT INTO posts (id, title, content, user_id, created_at, updated_at) VALUES (
    posts_seq.NEXTVAL,
    'Oracle vs PostgreSQL 개발 경험 비교',
    'Oracle XE 를 처음 써봤는데 시퀀스 문법이 PostgreSQL SERIAL 과 다르네요.' || CHR(10) ||
    'DEFAULT seq.NEXTVAL 패턴에 익숙해지는 중입니다.' || CHR(10) ||
    '멱등성 처리를 위한 PL/SQL EXCEPTION 패턴도 재미있었습니다.',
    (SELECT id FROM users WHERE username = 'bob'),
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
);

-- ============================================================
--  COMMENTS
-- ============================================================

INSERT INTO comments (id, content, post_id, user_id, created_at) VALUES (
    comments_seq.NEXTVAL,
    '반갑습니다! 잘 부탁드려요 :)',
    (SELECT id FROM posts WHERE title = '게시판에 오신 것을 환영합니다!'),
    (SELECT id FROM users WHERE username = 'alice'),
    CURRENT_TIMESTAMP
);

INSERT INTO comments (id, content, post_id, user_id, created_at) VALUES (
    comments_seq.NEXTVAL,
    '저도 처음 왔습니다. 잘 만들어진 프로젝트네요!',
    (SELECT id FROM posts WHERE title = '게시판에 오신 것을 환영합니다!'),
    (SELECT id FROM users WHERE username = 'bob'),
    CURRENT_TIMESTAMP
);

INSERT INTO comments (id, content, post_id, user_id, created_at) VALUES (
    comments_seq.NEXTVAL,
    'healthcheck 설정 덕분에 백엔드 연결 오류가 없었어요. 감사합니다.',
    (SELECT id FROM posts WHERE title = 'Docker Compose 로컬 개발 환경 구성 팁'),
    (SELECT id FROM users WHERE username = 'alice'),
    CURRENT_TIMESTAMP
);

INSERT INTO comments (id, content, post_id, user_id, created_at) VALUES (
    comments_seq.NEXTVAL,
    '저도 JWT 대신 세션 방식이 간단해서 좋더라고요. 동의합니다.',
    (SELECT id FROM posts WHERE title = 'Spring Security 세션 기반 인증 구현 후기'),
    (SELECT id FROM users WHERE username = 'bob'),
    CURRENT_TIMESTAMP
);

INSERT INTO comments (id, content, post_id, user_id, created_at) VALUES (
    comments_seq.NEXTVAL,
    'SameSite=Lax 설정 챙겨주셔서 보안 신경 쓴 게 보입니다',
    (SELECT id FROM posts WHERE title = 'Spring Security 세션 기반 인증 구현 후기'),
    (SELECT id FROM users WHERE username = 'admin'),
    CURRENT_TIMESTAMP
);

INSERT INTO comments (id, content, post_id, user_id, created_at) VALUES (
    comments_seq.NEXTVAL,
    'Oracle 시퀀스는 처음엔 낯설었는데 익숙해지면 괜찮아요!',
    (SELECT id FROM posts WHERE title = 'Oracle vs PostgreSQL 개발 경험 비교'),
    (SELECT id FROM users WHERE username = 'alice'),
    CURRENT_TIMESTAMP
);

COMMIT;

SELECT '샘플 데이터 로드 완료' AS result,
       (SELECT COUNT(*) FROM users)    AS users_count,
       (SELECT COUNT(*) FROM posts)    AS posts_count,
       (SELECT COUNT(*) FROM comments) AS comments_count
FROM dual;

SQLEOF

echo ">>> [seed.sh] 샘플 데이터 삽입 완료."
