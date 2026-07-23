# ==========================================
# OpenList - Choreo Web Application 适配
# 基于官方镜像：单端口 5244 + 外部 MySQL + /tmp 可写
# ==========================================
# 版本锁定见 README.md # Version
ARG OPENLIST_TAG=v4.2.3-lite
FROM openlistteam/openlist:${OPENLIST_TAG}

USER root

# 系统层升级，降低 Trivy CRITICAL 失败率
RUN apk upgrade --no-cache \
    && apk add --no-cache \
        ca-certificates \
        tzdata \
        curl \
    && rm -rf /var/cache/apk/*

# 内嵌 komari-agent（与 openwebui / deeix / lobehub 一致；运行时由 KOMARI_* 控制是否启动）
COPY --from=ghcr.io/komari-monitor/komari-agent:latest /app/komari-agent /app/komari-agent

WORKDIR /opt/openlist

# 官方镜像声明了 VOLUME ["/opt/openlist/data/"]。
# 构建期不要对 volume 挂载点做 rm/ln（可能 Device or resource busy）。
# 运行时数据目录通过 --data /tmp/openlist/data 指定。
COPY entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh /app/komari-agent \
    && chown 10014:10014 /app/entrypoint.sh /app/komari-agent

# --- Choreo 默认运行时约定（均可被环境变量覆盖）---
ENV TZ=Asia/Shanghai \
    UMASK=022 \
    HOME=/tmp \
    XDG_CONFIG_HOME=/tmp/.config \
    XDG_DATA_HOME=/tmp/.local/share \
    # OpenList 数据与临时目录（只读根 FS → /tmp）
    OPENLIST_DATA_DIR=/tmp/openlist/data \
    TEMP_DIR=/tmp/openlist/temp \
    BLEVE_DIR=/tmp/openlist/bleve \
    # 监听
    HTTP_PORT=5244 \
    ADDR=0.0.0.0 \
    # 生产默认 MySQL（务必在 Choreo Secrets 补全 DB_*）
    DB_TYPE=mysql \
    DB_PORT=3306 \
    DB_TABLE_PREFIX=x_ \
    # 日志写 /tmp，避免撑爆
    LOG_ENABLE=true \
    LOG_NAME=/tmp/openlist/log/log.log \
    # 关闭 Aria2（lite 镜像本就没有；显式关掉避免误开）
    RUN_ARIA2=false

# Choreo 要求 numeric USER 10000-20000
USER 10014

EXPOSE 5244

ENTRYPOINT ["/app/entrypoint.sh"]
