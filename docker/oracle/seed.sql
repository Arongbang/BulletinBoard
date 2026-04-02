-- ============================================================
--  BulletinBoard — 개발용 샘플 데이터 시드 스크립트
--  실행 시점: init.sql 이후 자동 실행 (파일명 순서 보장)
--             oracle-data 볼륨이 비어 있을 때만 동작
--
--  계정 정보 (로그인 테스트용):
--    admin   / password123
--    alice   / password123
--    bob     / password123
--
--  ※ 비밀번호는 BCrypt로 해시된 값을 직접 삽입합니다.
--    평문 'password123' 의 BCrypt 해시 (rounds=10, Spring BCryptPasswordEncoder 호환)
-- ============================================================


-- ============================================================
--  기존 샘플 데이터 정리 (재실행 시 중복 방지)
--  외래키 제약 순서에 따라 comments → posts → users 순으로 삭제
-- ============================================================

DELETE FROM comments WHERE user_id IN (
    SELECT id FROM users WHERE username IN ('admin', 'alice', 'bob')
);
DELETE FROM posts WHERE user_id IN (
    SELECT id FROM users WHERE username IN ('admin', 'alice', 'bob')
);
DELETE FROM users WHERE username IN ('admin', 'alice', 'bob');


-- ============================================================
--  USERS  (비밀번호: password123)
--  BCrypt 해시값은 rounds=10 기준, Spring Security 호환 포맷
-- ============================================================

INSERT INTO users (username, password) VALUES (
    'admin',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
);

INSERT INTO users (username, password) VALUES (
    'alice',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
);

INSERT INTO users (username, password) VALUES (
    'bob',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'
);


-- ============================================================
--  POSTS  (admin 2개, alice 1개, bob 1개)
-- ============================================================

INSERT INTO posts (title, content, user_id) VALUES (
    '게시판에 오신 것을 환영합니다!',
    '안녕하세요. 이 게시판은 Spring Boot + Vue 3 + Oracle XE 로 구성된 토이 프로젝트입니다.' || CHR(10) ||
    '자유롭게 글을 작성하고 댓글을 남겨보세요.',
    (SELECT id FROM users WHERE username = 'admin')
);

INSERT INTO posts (title, content, user_id) VALUES (
    'Docker Compose 로컬 개발 환경 구성 팁',
    'Oracle XE 컨테이너 최초 기동 시 약 3~4분 소요될 수 있습니다.' || CHR(10) ||
    'healthcheck 덕분에 backend 는 oracle-db 가 준비된 후에 시작됩니다.' || CHR(10) ||
    CHR(10) ||
    '포트 안내:' || CHR(10) ||
    '- 웹 UI : http://localhost' || CHR(10) ||
    '- Oracle (외부 클라이언트용) : localhost:1522',
    (SELECT id FROM users WHERE username = 'admin')
);

INSERT INTO posts (title, content, user_id) VALUES (
    'Spring Security 세션 기반 인증 구현 후기',
    'JWT 대신 세션 쿠키 방식을 선택한 이유:' || CHR(10) ||
    '1. 토큰 탈취 시 즉시 무효화 가능' || CHR(10) ||
    '2. 구현이 단순하고 Spring Security 기본 지원' || CHR(10) ||
    '3. SameSite=Lax 설정으로 CSRF 위험 최소화',
    (SELECT id FROM users WHERE username = 'alice')
);

INSERT INTO posts (title, content, user_id) VALUES (
    'Oracle vs PostgreSQL 개발 경험 비교',
    'Oracle XE 를 처음 써봤는데 시퀀스 문법이 PostgreSQL SERIAL 과 다르네요.' || CHR(10) ||
    'DEFAULT seq.NEXTVAL 패턴에 익숙해지는 중입니다.' || CHR(10) ||
    '멱등성 처리를 위한 PL/SQL EXCEPTION 패턴도 재미있었습니다.',
    (SELECT id FROM users WHERE username = 'bob')
);


-- ============================================================
--  COMMENTS
-- ============================================================

-- 1번 게시글 댓글
INSERT INTO comments (content, post_id, user_id) VALUES (
    '반갑습니다! 잘 부탁드려요 :)',
    (SELECT id FROM posts WHERE title = '게시판에 오신 것을 환영합니다!'),
    (SELECT id FROM users WHERE username = 'alice')
);

INSERT INTO comments (content, post_id, user_id) VALUES (
    '저도 처음 왔습니다. 잘 만들어진 프로젝트네요!',
    (SELECT id FROM posts WHERE title = '게시판에 오신 것을 환영합니다!'),
    (SELECT id FROM users WHERE username = 'bob')
);

-- 2번 게시글 댓글
INSERT INTO comments (content, post_id, user_id) VALUES (
    'healthcheck 설정 덕분에 백엔드 연결 오류가 없었어요. 감사합니다.',
    (SELECT id FROM posts WHERE title = 'Docker Compose 로컬 개발 환경 구성 팁'),
    (SELECT id FROM users WHERE username = 'alice')
);

-- 3번 게시글 댓글
INSERT INTO comments (content, post_id, user_id) VALUES (
    '저도 JWT 대신 세션 방식이 간단해서 좋더라고요. 동의합니다.',
    (SELECT id FROM posts WHERE title = 'Spring Security 세션 기반 인증 구현 후기'),
    (SELECT id FROM users WHERE username = 'bob')
);

INSERT INTO comments (content, post_id, user_id) VALUES (
    'SameSite=Lax 설정 챙겨주셔서 보안 신경 쓴 게 보입니다 👍',
    (SELECT id FROM posts WHERE title = 'Spring Security 세션 기반 인증 구현 후기'),
    (SELECT id FROM users WHERE username = 'admin')
);

-- 4번 게시글 댓글
INSERT INTO comments (content, post_id, user_id) VALUES (
    'Oracle 시퀀스는 처음엔 낯설었는데 익숙해지면 괜찮아요!',
    (SELECT id FROM posts WHERE title = 'Oracle vs PostgreSQL 개발 경험 비교'),
    (SELECT id FROM users WHERE username = 'alice')
);


-- ============================================================
--  커밋
-- ============================================================

COMMIT;


-- ============================================================
--  삽입 결과 확인
-- ============================================================

SELECT '샘플 데이터 로드 완료' AS result,
       (SELECT COUNT(*) FROM users)    AS users_count,
       (SELECT COUNT(*) FROM posts)    AS posts_count,
       (SELECT COUNT(*) FROM comments) AS comments_count
FROM dual;
