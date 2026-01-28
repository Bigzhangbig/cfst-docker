# cfst-docker 🚀

`cfst-docker` 是一个旨在通过 Docker 自动化运行 [CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest) 的轻量化工具。它的设计初衷是“设定后便无需再管”，自动完成测速并将结果同步到云端。

---

## ✨ 核心特性

- **开箱即用:** 极其简单的配置，容器启动即开始测速。
- **自动化上传:** 自动将测速结果推送到你的 GitHub Gist，方便随时查看。
- **高度可定制:** 支持通过环境变量灵活调整测速参数（如测速数量、下载测试大小等）。
- **轻量且兼容:** 基于 Alpine 镜像，支持多种 CPU 架构：
  - `linux/amd64` (标准 PC/服务器)
  - `linux/arm64` (树莓派 4/5, Apple Silicon)
  - `linux/arm/v7` (旧款树莓派等)
  - `linux/386` (32 位系统)
- **智能版本同步:** 镜像标签格式为 `v主版本号-构建次数`（如 `v2.3.4-1`），主版本号始终与上游工具同步。
- **透明日志:** 同时支持控制台与本地日志输出，包含清晰的运行摘要。

## 🛠️ 项目性质

这是一个**个人实验性项目**，具有以下特点：

- **AI 编程:** 本项目的所有代码均由 AI 编程助手 (Gemini) 生成和维护。
- **随缘更新:** 维护和功能迭代取决于个人时间和精力，不承诺固定的更新节奏。
- **极简主义:** 专注于核心功能的稳定与易用。

## 🚀 快速开始

### 1. 拉取镜像
你可以从 GitHub Container Registry 拉取最新镜像：

```bash
docker pull ghcr.io/bigzhangbig/cfst-docker:latest
```

### 2. 准备配置
创建一个 `.env` 文件并填入你的信息：

```env
GIST_TOKEN=你的GitHub_Token
GIST_ID=你的Gist_ID
```

### 3. 运行
使用 Docker 启动，建议挂载 `/app/data` 目录以持久化本地 `result.csv`：

```bash
docker run --rm \
  --env-file .env \
  -v $(pwd)/output:/app/data \
  ghcr.io/bigzhangbig/cfst-docker:latest
```

## ⚙️ 环境变量说明
你可以通过以下环境变量来自定义测速行为：

| 变量 | 对应参数 | 说明 | 默认值 | 
| :--- | :--- | :--- | :--- | 
| **基础参数** | | | | 
| `CF_N` | `-n` | 延迟测速线程数 | `500` | 
| `CF_T` | `-t` | 每个 IP 延迟测速次数 | `4` | 
| `CF_DN` | `-dn` | 延迟测速后下载测速的数量 | `20` | 
| `CF_DT` | `-dt` | 单个 IP 下载测速最长时间 (秒) | `10` | 
| `CF_URL` | `-url` | 自定义测速地址 | 官方默认 | 
| `CF_TP` | `-tp` | 指定测速端口 | `443` | 
| **测速模式** | | | | 
| `CF_HTTPING` | `-httping` | 是否切换为 HTTPing 模式 (`true`/`false`) | `false` | 
| `CF_HTTPING_CODE` | `-httping-code` | HTTPing 时的有效状态码 | `200,301,302` | 
| `CF_COLO` | `-cfcolo` | 匹配指定地区 (如 `HKG,SJC`) | 所有地区 | 
| **过滤参数** | | | | 
| `CF_TL` | `-tl` | 平均延迟上限 (ms) | `1000` | 
| `CF_TLL` | `-tll` | 平均延迟下限 (ms) | `0` | 
| `CF_TLR` | `-tlr` | 丢包率上限 (0.00-1.00) | `1.00` | 
| `CF_SL` | `-sl` | 下载速度下限 (MB/s) | `0.00` | 
| **数据与显示** | | | | 
| `CF_P` | `-p` | 显示结果数量 (0 为不显示) | `10` | 
| `CF_F` | `-f` | 指定 IP 段数据文件路径 | `ip.txt` | 
| `CF_IP` | `-ip` | 直接指定 IP/IP段 (逗号分隔) | 无 | 
| `CF_DD` | `-dd` | 是否禁用下载测速 (`true`/`false`) | `false` | 
| `CF_ALLIP` | `-allip` | 是否测速全部 IP (`true`/`false`) | `false` | 

## 🤝 鸣谢

感谢 [XIU2/CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest) 提供的优秀原始工具。

---

*由 Gemini 驱动开发*
