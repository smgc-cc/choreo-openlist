#!/bin/sh
# ==============================
# OpenList Choreo entrypoint
# Web Application + 外部 MySQL + /tmp
# ==============================

set -e

OPENLIST_DATA_DIR="${OPENLIST_DATA_DIR:-/tmp/openlist/data}"
TEMP_DIR="${TEMP_DIR:-/tmp/openlist/temp}"
BLEVE_DIR="${BLEVE_DIR:-/tmp/openlist/bleve}"
HTTP_PORT="${HTTP_PORT:-5244}"

KOMARI_SERVER="${KOMARI_SERVER:-}"
KOMARI_SECRET="${KOMARI_SECRET:-}"

# 导出给 openlist（官方 --no-prefix 直接读这些名）
export TEMP_DIR BLEVE_DIR
export HTTP_PORT
export ADDR="${ADDR:-0.0.0.0}"
export DB_TYPE="${DB_TYPE:-mysql}"
export HOME="${HOME:-/tmp}"

# ==============================
# 1. 可写目录（Choreo 只读 FS → /tmp）
# ==============================
echo "[Init] Preparing /tmp paths..."
mkdir -p \
    "$OPENLIST_DATA_DIR" \
    "$TEMP_DIR" \
    "$BLEVE_DIR" \
    /tmp/openlist/log \
    /tmp/.config \
    /tmp/.local/share

# ==============================
# 2. MySQL 配置检查（不打印密码）
# ==============================
db_type_lc=$(printf '%s' "$DB_TYPE" | tr '[:upper:]' '[:lower:]')
if [ "$db_type_lc" = "mysql" ] || [ "$db_type_lc" = "postgres" ] || [ "$db_type_lc" = "postgresql" ]; then
    if [ -n "${DB_DSN:-}" ]; then
        # 只打印 host/库名形状，避免泄露密码
        dsn_shape=$(printf '%s' "$DB_DSN" | sed -E 's#[^:@/]+(:[^@]*)?@#***:***@#; s#:[^:@/]+@#:***@#')
        echo "[DB] type=${DB_TYPE} using DB_DSN shape=${dsn_shape}"
        case "$DB_DSN" in
            *@tcp\(*|*\(*:*\)/*|*@*/*) : ;;
            *)
                echo "[WARN] DB_DSN does not look like a MySQL DSN."
                echo "[WARN] Expected: user:pass@tcp(host:3306)/dbname?charset=utf8mb4&parseTime=True&loc=Local&tls=true"
                ;;
        esac
    elif [ -z "${DB_HOST:-}" ] || [ -z "${DB_USER:-}" ] || [ -z "${DB_NAME:-}" ]; then
        echo "[WARN] DB_TYPE=${DB_TYPE} but DB_HOST/DB_USER/DB_NAME (or DB_DSN) incomplete."
        echo "[WARN] Set them in Choreo Configs/Secrets before production use."
    else
        echo "[DB] type=${DB_TYPE} host=${DB_HOST} port=${DB_PORT:-} name=${DB_NAME} user=${DB_USER} ssl=${DB_SSL_MODE:-}"
    fi
elif [ "$db_type_lc" = "sqlite3" ] || [ "$db_type_lc" = "sqlite" ]; then
    echo "[WARN] SQLite on Choreo is ephemeral (/tmp). Prefer external MySQL for production."
else
    echo "[WARN] Unexpected DB_TYPE=${DB_TYPE}"
fi

if [ -z "${JWT_SECRET:-}" ]; then
    echo "[WARN] JWT_SECRET is empty; OpenList will generate a random one (sessions break after restart)."
fi

if [ -z "${SITE_URL:-}" ]; then
    echo "[WARN] SITE_URL is empty; set it to your public HTTPS origin (no trailing slash)."
fi

if [ -z "${OPENLIST_ADMIN_PASSWORD:-}" ]; then
    echo "[WARN] OPENLIST_ADMIN_PASSWORD not set; check container logs for the initial admin password."
fi

# ==============================
# 3. komari-agent（与 openwebui / deeix / lobehub 相同）
#    KOMARI_SERVER + KOMARI_SECRET 都非空时启动
# ==============================
if [ -n "$KOMARI_SERVER" ] && [ -n "$KOMARI_SECRET" ]; then
    if [ -x /app/komari-agent ]; then
        echo "[Komari] Starting agent -> ${KOMARI_SERVER}"
        /app/komari-agent \
            -e "$KOMARI_SERVER" \
            -t "$KOMARI_SECRET" \
            --disable-auto-update >/dev/null 2>&1 &
    else
        echo "[Komari] WARN: /app/komari-agent missing or not executable, skip."
    fi
else
    echo "[Komari] Not configured (need KOMARI_SERVER + KOMARI_SECRET), skip."
fi

# ==============================
# 4. 启动 OpenList
# ==============================
# 官方 entrypoint 校验 ./data 权限；这里改用 --data 指向 /tmp，并保留 --no-prefix
# 以便 SITE_URL / JWT_SECRET / DB_* / HTTP_PORT 等环境变量直接生效。
#
# 重要：OpenList 默认 LOG_ENABLE=true 时，init logrus 之后只写日志文件，
# Fatal（如 MySQL 连不上）不会出现在 Choreo Application Logs。
# 必须加 --log-std，把日志同时打到 stdout。
cd /opt/openlist

echo "[OpenList] Starting server..."
echo "[OpenList] data=${OPENLIST_DATA_DIR} port=${HTTP_PORT} db=${DB_TYPE}"
echo "[OpenList] log-std=on (required for Choreo console visibility)"

if [ "$#" -gt 0 ]; then
    exec "$@"
fi

exec ./openlist server --no-prefix --log-std --data "$OPENLIST_DATA_DIR"
