@echo off
chcp 65001 >nul
REM ============================================================
REM  reset-dev.bat — 개발 환경 완전 초기화 (Windows 전용)
REM
REM  bash reset-dev.sh 와 동일한 작업을 Windows CMD 에서 실행합니다.
REM  Git Bash / WSL 가 있다면 reset-dev.sh 사용을 권장합니다.
REM ============================================================

echo.
echo [INFO]  개발 환경 초기화를 시작합니다.
echo [INFO]  oracle-data 볼륨이 삭제되고 샘플 데이터가 재로드됩니다.
echo.

REM ── .env 파일 확인 ───────────────────────────────────────────
if not exist ".env" (
    echo [ERROR] .env 파일이 없습니다.
    echo         .env.example 을 복사 후 값을 설정하세요:
    echo           copy .env.example .env
    pause
    exit /b 1
)

REM ── 1단계: 컨테이너 + 볼륨 제거 ─────────────────────────────
echo [1/4] 컨테이너 및 oracle-data 볼륨 제거 중...
docker compose down -v
if errorlevel 1 (
    echo [ERROR] docker compose down 실패
    pause
    exit /b 1
)
echo [OK]   컨테이너 및 볼륨 제거 완료
echo.

REM ── 2단계: 이미지 재빌드 ─────────────────────────────────────
echo [2/4] 이미지 재빌드 중... (소요 시간: 수 분)
docker compose build --no-cache
if errorlevel 1 (
    echo [ERROR] 이미지 빌드 실패
    pause
    exit /b 1
)
echo [OK]   이미지 재빌드 완료
echo.

REM ── 3단계: 컨테이너 기동 ─────────────────────────────────────
echo [3/4] 컨테이너 기동 중...
docker compose up -d
if errorlevel 1 (
    echo [ERROR] 컨테이너 기동 실패
    pause
    exit /b 1
)
echo [OK]   컨테이너 기동 완료
echo.

REM ── 4단계: 안내 메시지 ───────────────────────────────────────
echo [4/4] Oracle DB 초기화 대기 중...
echo       Oracle XE 최초 부팅은 3~4분 소요될 수 있습니다.
echo       아래 명령으로 진행 상황을 확인하세요:
echo         docker compose logs -f oracle-db
echo.
echo ======================================================
echo   개발 환경이 백그라운드에서 시작되었습니다.
echo ======================================================
echo.
echo   웹 UI    : http://localhost
echo   Oracle   : localhost:1522 (외부 클라이언트용)
echo.
echo   로그인 계정:
echo     admin / password123
echo     alice / password123
echo     bob   / password123
echo.
echo   초기화 완료 확인:
echo     docker compose logs oracle-db
echo     (로그에서 "seed.sql 완료" 메시지 확인)
echo.

pause
