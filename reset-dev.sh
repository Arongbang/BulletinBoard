#!/usr/bin/env bash
# ============================================================
#  reset-dev.sh — 개발 환경 완전 초기화 스크립트
#
#  수행 작업:
#    1. 모든 컨테이너 중지 및 제거
#    2. oracle-data 볼륨 삭제 (DB 데이터 완전 초기화)
#    3. 빌드 캐시 없이 이미지 재빌드
#    4. 컨테이너 백그라운드 기동
#    5. oracle-db healthcheck 통과 대기 후 로그 출력
#
#  사용법:
#    bash reset-dev.sh          # 기본 실행
#    bash reset-dev.sh --help   # 도움말
#
#  주의:
#    oracle-data 볼륨이 삭제되므로 기존 DB 데이터는 모두 사라집니다.
#    init.sql + seed.sql 이 자동 재실행되어 샘플 데이터가 다시 로드됩니다.
# ============================================================

set -euo pipefail

# ── 색상 출력 헬퍼 ────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ── 도움말 ───────────────────────────────────────────────────
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    cat <<EOF
사용법: bash reset-dev.sh [옵션]

옵션:
  --help, -h     이 도움말 출력
  --no-rebuild   이미지 재빌드 없이 볼륨만 초기화 후 재시작

개요:
  개발 환경을 완전히 초기화합니다.
  Oracle 볼륨이 삭제되어 init.sql + seed.sql 이 자동 재실행됩니다.

로그인 계정 (초기화 후):
  admin / password123
  alice / password123
  bob   / password123
EOF
    exit 0
fi

# ── 스크립트 위치 기준으로 프로젝트 루트 이동 ─────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
info "프로젝트 루트: $SCRIPT_DIR"

# ── .env 파일 존재 확인 ──────────────────────────────────────
if [[ ! -f ".env" ]]; then
    error ".env 파일이 없습니다. .env.example 을 복사 후 값을 설정하세요:"
    error "  cp .env.example .env"
    exit 1
fi

# ── 1단계: 컨테이너 + 볼륨 전체 제거 ─────────────────────────
echo ""
info "1단계: 컨테이너 및 oracle-data 볼륨 제거 중..."
docker compose down -v
success "컨테이너 및 볼륨 제거 완료"

# ── 2단계: 이미지 재빌드 (--no-rebuild 옵션 없을 때) ──────────
echo ""
if [[ "${1:-}" == "--no-rebuild" ]]; then
    warn "이미지 재빌드를 건너뜁니다 (--no-rebuild)"
else
    info "2단계: 이미지 재빌드 중... (소요 시간: 수 분)"
    docker compose build --no-cache
    success "이미지 재빌드 완료"
fi

# ── 3단계: 컨테이너 백그라운드 기동 ──────────────────────────
echo ""
info "3단계: 컨테이너 기동 중..."
docker compose up -d
success "컨테이너 기동 완료"

# ── 4단계: oracle-db healthcheck 대기 ────────────────────────
echo ""
info "4단계: Oracle DB 초기화 대기 중 (최대 5분)..."
info "  Oracle XE 최초 부팅은 3~4분 소요될 수 있습니다."

TIMEOUT=300   # 최대 대기 초
INTERVAL=10   # 상태 확인 간격(초)
ELAPSED=0

while [[ $ELAPSED -lt $TIMEOUT ]]; do
    STATUS=$(docker compose ps --format json oracle-db 2>/dev/null \
             | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('Health','unknown'))" \
             2>/dev/null || echo "unknown")

    if [[ "$STATUS" == "healthy" ]]; then
        success "Oracle DB 정상 기동 확인 (${ELAPSED}초 경과)"
        break
    fi

    echo -ne "\r${CYAN}[INFO]${NC}  대기 중... ${ELAPSED}/${TIMEOUT}초  (현재 상태: ${STATUS})   "
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

if [[ $ELAPSED -ge $TIMEOUT ]]; then
    warn "healthcheck 대기 시간 초과. 로그를 직접 확인하세요:"
    warn "  docker compose logs oracle-db"
fi

# ── 5단계: 초기화 결과 로그 출력 ─────────────────────────────
echo ""
info "5단계: Oracle 초기화 로그 확인"
echo "────────────────────────────────────────────────────────"
docker compose logs oracle-db 2>&1 \
    | grep -E "(init\.sql|seed\.sql|완료|ERROR|DONE|샘플)" \
    | tail -30 \
    || true
echo "────────────────────────────────────────────────────────"

# ── 완료 메시지 ───────────────────────────────────────────────
echo ""
success "======================================================"
success "  개발 환경 초기화가 완료되었습니다!"
success "======================================================"
echo ""
echo -e "  웹 UI    : ${GREEN}http://localhost${NC}"
echo -e "  백엔드   : Docker 내부 (nginx가 /api 프록시)"
echo -e "  Oracle   : localhost:1522 (외부 클라이언트용)"
echo ""
echo -e "  로그인 계정:"
echo -e "    ${YELLOW}admin${NC} / password123"
echo -e "    ${YELLOW}alice${NC} / password123"
echo -e "    ${YELLOW}bob${NC}   / password123"
echo ""
echo -e "  전체 로그: docker compose logs -f"
echo ""
