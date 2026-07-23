# OpenList - Choreo 部署说明

基于 [OpenListTeam/OpenList](https://github.com/OpenListTeam/OpenList) 官方镜像的 **Choreo Web Application** 适配层。

- 组件类型：**Web Application**（Dockerfile）
- 单公网端口 **`5244`**
- `USER 10014`
- 可写路径仅 **`/tmp`**（`--data /tmp/openlist/data`）
- 业务库：**外部 MySQL**（`DB_TYPE=mysql` + `DB_*`）
- 内嵌 **komari-agent**（`KOMARI_SERVER` + `KOMARI_SECRET` 均非空时启动）
- **无**本地 data 备份逻辑（状态以 MySQL 为准）

上游当前锁定版本见 [README.md](./README.md)（`# Version`）。

---

## 架构

```text
浏览器
  └─ https://openlist.example.com  （或 *.choreoapps.dev）
        └─ Choreo Web Application :5244
              ├─ /opt/openlist/openlist
              ├─ /tmp/openlist/*      （temp / 索引 / 日志；非持久，可丢）
              ├─ 外部 MySQL           （元数据 / 用户 / 存储配置）
              ├─ 各网盘驱动           （真实文件在云端）
              └─ /app/komari-agent    （可选；上报到你的 Komari 面板）
```

---

## 仓库结构

```text
choreo-openlist/
├── Dockerfile
├── entrypoint.sh
├── .trivyignore
├── .github/workflows/
│   └── update-version.yml   # 每日检查上游 release，同步 lite tag
├── README.md
└── README.choreo.md
```

---

## 1. 创建 Choreo Web Application

| 项 | 值 |
|---|---|
| Component type | **Web Application** |
| Build preset | **Dockerfile** |
| Dockerfile Path | `/Dockerfile` |
| Component Directory | `/` |
| Port | **`5244`** |

连接本仓库后 Build → Deploy。

文档：

- [Deploy a containerized application](https://wso2.com/engineering-platform/developer-platform/docs/develop-components/deploy-a-containerized-application/)
- [Build and deploy a web application](https://wso2.com/engineering-platform/developer-platform/docs/develop-components/develop-web-applications/build-and-deploy-a-single-page-web-application/)

---

## 2. 环境变量

镜像启动命令等价于：

```bash
./openlist server --no-prefix --data /tmp/openlist/data
```

因此 OpenList 配置字段可直接用环境变量注入（**无 `OPENLIST_` 前缀**），例如 `SITE_URL`、`JWT_SECRET`、`DB_TYPE`、`DB_HOST`…

官方配置参考：https://doc.oplist.org/configuration/configuration  
结构定义：`internal/conf/config.go`（`env` / `envPrefix` 标签）。

### 2.1 必配（生产）

| 变量 | 示例 / 说明 | 类型 |
|---|---|---|
| `SITE_URL` | `https://openlist.example.com`（**无**尾斜杠） | Config |
| `JWT_SECRET` | ≥16 随机串，**上线后勿随意轮换** | **Secret** |
| `OPENLIST_ADMIN_PASSWORD` | 初始 admin 密码（固定可避免重启后不知密码） | **Secret** |
| `DB_TYPE` | `mysql` | Config |
| `DB_HOST` | MySQL 主机 | Config / Secret |
| `DB_PORT` | `3306`（或托管库端口） | Config |
| `DB_USER` | 用户名 | Secret |
| `DB_PASS` | 密码 | **Secret** |
| `DB_NAME` | 库名 | Config |
| `DB_SSL_MODE` | 见下 | Config |
| `DB_TABLE_PREFIX` | 默认 `x_` | Config |

生成密钥示例：

```bash
openssl rand -base64 24   # JWT_SECRET
openssl rand -base64 18   # OPENLIST_ADMIN_PASSWORD
```

### 2.2 外部 MySQL

**拆字段方式（推荐，OpenList 会拼成 `tls=$DB_SSL_MODE`）：**

```bash
DB_TYPE=mysql
DB_HOST=gatewayXX.xxx.pingora.tidbcloud.com   # 例：TiDB Cloud
DB_PORT=4000                                  # TiDB Cloud 常见 4000；普通 MySQL 3306
DB_USER=...
DB_PASS=...
DB_NAME=openlist
DB_TABLE_PREFIX=x_
DB_SSL_MODE=true                              # 强制 TLS（托管库必配）
```

| `DB_SSL_MODE`（写入 go-sql-driver `tls=`） | 说明 |
|---|---|
| 空 / `false` | 不启用 TLS |
| **`true`** | **启用 TLS 并校验证书（TiDB Cloud / 多数托管库用这个）** |
| `skip-verify` | TLS 但不校验证书（仅排障） |
| `preferred` | 优先 TLS，失败可回落明文（**TiDB Cloud 不允许明文，不要用**） |

> 不要写 MySQL 客户端那套 `REQUIRED` / `VERIFY_CA`：OpenList 是 **原样** 塞进 `tls=` 参数，`REQUIRED` 不是 go-sql-driver 的合法值。

**或使用 DSN（二选一）：**

```bash
DB_TYPE=mysql
# TiDB Cloud 示例（端口多为 4000）
DB_DSN=user:pass@tcp(gatewayXX.xxx.pingora.tidbcloud.com:4000)/openlist?charset=utf8mb4&parseTime=True&loc=Local&tls=true
```

设置了完整可用的 `DB_DSN` 时，仍建议保留 `DB_TYPE=mysql`。

DSN 注意：

- 必须是 Go MySQL 驱动格式：`user:pass@tcp(host:port)/dbname?params`
- 建议带 `charset=utf8mb4&parseTime=True&loc=Local`
- **TiDB Cloud / 强制 SSL 的库必须带 `tls=true`**，否则报：`Connections using insecure transport are prohibited`
- 密码含 `@ : / ? #` 等特殊字符时要 URL 编码，或改用拆字段 `DB_USER`/`DB_PASS`…

| 来源 | 说明 |
|---|---|
| **TiDB Cloud** | Serverless 强制 TLS；端口常见 **4000**；DSN 或 `DB_SSL_MODE=true` |
| PlanetScale / Railway / 自建等 | 注入 `DB_*`；公网或经 VPN 可达 Choreo 出站 |
| Choreo Managed MySQL | 同样注入连接信息；注意 SSL |

**库侧建议：**

- 单独库 + 最小权限用户（读写本库即可）
- 强制 SSL（`DB_SSL_MODE=true` 或 DSN `tls=true`）
- 用托管侧的自动备份 / 快照（本镜像不做本地备份）
- 确认 Choreo 数据平面出站能连到你的 MySQL 主机端口

> **不要**在 Choreo 生产用 SQLite：`/tmp` 非持久，重启会丢库。

### 2.3 站点与运行时

| 变量 | 默认（镜像） | 说明 |
|---|---|---|
| `HTTP_PORT` | `5244` | 监听端口，需与 Choreo Port 一致 |
| `ADDR` | `0.0.0.0` | 监听地址 |
| `OPENLIST_DATA_DIR` | `/tmp/openlist/data` | `--data` 路径 |
| `TEMP_DIR` | `/tmp/openlist/temp` | 临时目录（每次启动会清理） |
| `BLEVE_DIR` | `/tmp/openlist/bleve` | 搜索索引目录（可重建） |
| `LOG_ENABLE` | `true` | |
| `LOG_NAME` | `/tmp/openlist/log/log.log` | 日志落在 /tmp |
| `TOKEN_EXPIRES_IN` | 官方默认 48 | 登录有效小时数 |
| `TZ` | `Asia/Shanghai` | |
| `UMASK` | `022` | |
| `RUN_ARIA2` | `false` | lite 镜像无 Aria2 |

### 2.4 Komari Agent

镜像内已包含 `/app/komari-agent`（构建时从 `ghcr.io/komari-monitor/komari-agent:latest` 复制）。  

| 变量 | 说明 | 类型 |
|---|---|---|
| `KOMARI_SERVER` | Agent 入口 `-e`，如 `https://komari.example.com`（**不要**写 `wss://`） | Config |
| `KOMARI_SECRET` | Agent token `-t`，在 Komari 面板创建/复制 | **Secret** |

启动命令等价于：

```bash
/app/komari-agent -e "$KOMARI_SERVER" -t "$KOMARI_SECRET" --disable-auto-update
```

注意：

- Agent 代表 **Choreo 容器本身** 的资源，不是外部网盘机器。
- 日志默认丢弃到 `/dev/null`（与其它 choreo 项目一致，避免刷屏）。
- 未配置时日志会打印 `[Komari] Not configured, skip.`，不影响 OpenList。

---

## 3. 部署步骤

1. 准备 **外部 MySQL** 库与用户，拿到连接信息（建议 SSL + 托管备份）。
2. 确认 Choreo 出站可访问该 MySQL（防火墙 / 白名单 / 公网）。
3. （推荐）在 Komari 面板拿到 agent 的 `-e` 基址与 token。
4. 推送本仓库到 GitHub，在 Choreo 创建 **Web Application**（见第 1 节）。
5. 在 Deploy / DevOps 页配置 Configs & Secrets（第 2 / 4 节）。
6. **Build Latest** → 处理 Trivy（升级或 `.trivyignore`）→ Deploy。
7. 打开组件 URL；日志中确认 DB 连接成功；Komari 面板应出现本节点。
8. 使用 `OPENLIST_ADMIN_PASSWORD`（或日志中的初始密码）登录 admin。
9. 后台添加一个网盘驱动做冒烟测试。
10. 将 `SITE_URL` 改成最终公网 HTTPS 地址后重新部署配置。
11. （可选）绑定自定义域名；Cloudflare 橙云时回源 SSL 常用 **Full**。

---

## 4. 最小 Secret 清单（复制用）

```bash
# 应用
SITE_URL=https://openlist.example.com
JWT_SECRET=...
OPENLIST_ADMIN_PASSWORD=...
HTTP_PORT=5244

# 外部 MySQL
DB_TYPE=mysql
DB_HOST=...
DB_PORT=3306
DB_USER=openlist
DB_PASS=...
DB_NAME=openlist
DB_SSL_MODE=true
DB_TABLE_PREFIX=x_

# Komari Agent（监控本容器；不配则跳过）
KOMARI_SERVER=https://komari.example.com
KOMARI_SECRET=...
```

---

## 5. 验证

```bash
# 首页
curl -sS -o /dev/null -w "%{http_code}\n" "https://openlist.example.com/"

# 登录后台 → 添加存储 → 列目录 / 预览
```

启动后日志中应看到类似：

```text
[DB] type=mysql host=... name=openlist user=...
[OpenList] Starting server...
```

---

## 6. 镜像与构建说明

| 项 | 说明 |
|---|---|
| 上游镜像 | `openlistteam/openlist:v4.2.3-lite`（与 README Version 同步） |
| 二进制 | `/opt/openlist/openlist` |
| 用户 | `10014`（Choreo 强制 10000–20000） |
| 数据 | `--data /tmp/openlist/data`（避开官方 VOLUME 挂载点） |
| Komari Agent | 从 `ghcr.io/komari-monitor/komari-agent:latest` 复制 |

**为何用 lite：** 官方 PaaS 文档提示完整镜像易触发临时盘限额；Choreo 公有云仅 `/tmp` 可写且 ephemeral，lite 更合适。需要缩略图时再考虑 `v*-ffmpeg`（体积/CPU↑）。

Trivy **CRITICAL** 会导致 Choreo 构建失败：

1. 先依赖 Dockerfile 内 `apk upgrade`
2. 定期重建镜像吃安全补丁
3. 短期无法修复时把 CVE 写入 `.trivyignore`（每行一个）

---

## 7. 限制与注意

| 点 | 说明 |
|---|---|
| Web Application 单端口 | 本应用只暴露 5244，符合 |
| `/tmp` 非持久 | 元数据在 MySQL；本地 temp/索引重启可丢、可重建 |
| 无本地备份脚本 | **请依赖外部 MySQL 的托管备份/快照** |
| 请求体约 256KB（云数据平面 Web App 文档） | 大文件勿指望经面板直传；优先网盘直链 / 302 |
| 请求总时长默认约 1 分钟、最长约 5 分钟 | 大文件中转下载可能中断 |
| OpenList 内置 S3/FTP/SFTP 端口 | 默认关闭，勿在 Web App 上开多端口服务 |
| Aria2 离线下载 | lite 无；Choreo 上不推荐先做 |
| `JWT_SECRET` / admin 密码 | 固定注入，避免重启会话/密码漂移 |
| `SITE_URL` | 反代、缩略图、部分预览依赖；必须为最终 HTTPS 源 |
| Scale-to-zero | 冷启动可接受则可开；状态在 MySQL |
| MySQL 网络 | Choreo 需能出站连你的库；部分托管库要加 IP 白名单 |

---

## 8. 故障速查

| 现象 | 处理 |
|---|---|
| 构建 USER 校验失败 | 确认 Dockerfile 末尾 `USER 10014` |
| Trivy CRITICAL | 升级基础包 / 换更新上游 tag / `.trivyignore` |
| 启动后很快 `terminated` / CrashLoop，控制台只有 `init logrus` | **旧镜像日志只写文件**。请更新到带 `--log-std` 的 entrypoint 后重部署，再看真正的 Fatal |
| 启动报 `failed to connect database` | 查 `DB_DSN` / `DB_*`：主机可达性、端口、用户密码、库名、SSL（**`tls=true` / `DB_SSL_MODE=true`**）、白名单 |
| `Connections using insecure transport are prohibited`（TiDB Cloud） | DSN 缺少 `tls=true`，或拆字段未设 `DB_SSL_MODE=true`；不要用 `REQUIRED` |
| 启动报 DB / connection refused | 检查 `DB_*`、SSL、防火墙/白名单、主机名是否公网可达；Choreo 出站能否访问你的 MySQL |
| 登录后 URL/资源错乱 | `SITE_URL` 是否为当前 HTTPS 域名且无尾 `/` |
| 重启后会话全失效 | 固定 `JWT_SECRET` |
| 重启后 admin 密码变了 | 设置 `OPENLIST_ADMIN_PASSWORD` |
| 页面可开但大上传失败 | 受 Web App 请求体限制；改用网盘客户端/直传 |
| Komari 面板无节点 | 确认 `KOMARI_SERVER` 与 `KOMARI_SECRET` **都**已设置；`-e` 用 `https://` 长/短基址（按你 Komari 边缘模式），不要 `wss://`；Choreo 出站可访问 Komari |
| 日志无 `[Komari] Starting agent...` | 变量为空或二进制不可执行；看是否打印 `Not configured, skip.` |

---

## 9. 上游与版本同步

- 上游仓库：https://github.com/OpenListTeam/OpenList  
- Docker 安装：https://doc.oplist.org/guide/installation/docker  
- 配置：https://doc.oplist.org/configuration/configuration  
- PaaS 参考：https://doc.oplist.org/guide/installation/paas  

### GitHub Actions（推荐）

工作流：`.github/workflows/update-version.yml`

| 项 | 说明 |
|---|---|
| 触发 | 每天 UTC 00:00；也可手动 `workflow_dispatch` |
| 检查 | `OpenListTeam/OpenList` 最新 GitHub Release tag |
| 写入 | `README.md` 的 `# Version` / `# Releases`；`Dockerfile` 的 `ARG OPENLIST_TAG=` |
| 镜像后缀 | 固定拼 `-lite`（`v4.2.3` → `v4.2.3-lite`） |
| 提交 | `docs: update to vX.Y.Z-lite` 并 push |
| 通知 | 可选：仓库 Secrets `TELEGRAM_TOKEN` + `TELEGRAM_TO` |
| 清理 | 保留最近约 7 天 / 至少 6 次 workflow run |

推送到 GitHub 后，在仓库 **Actions** 页启用该 workflow；需要 Telegram 时在 Secrets 里加上上述两项。

### 手动 bump

改两处：

1. `Dockerfile`：`ARG OPENLIST_TAG=vX.Y.Z-lite`  
2. `README.md`：`# Version` 与 `# Releases`

镜像 tag 示例：`v4.2.3` / `v4.2.3-lite` / `latest-lite` / `latest-ffmpeg`。
