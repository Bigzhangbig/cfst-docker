# cfst-docker 🚀

`cfst-docker` 是一个旨在通过 Docker 自动化运行 [CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest) 的轻量化工具。它的设计初衷是“设定后便无需再管”，自动完成测速并将结果同步到云端。

---

## ✨ 核心特性

- **开箱即用:** 极其简单的配置，容器启动即开始测速。
- **自动化上传:** 自动将测速结果推送到你的 GitHub Gist，方便随时查看。
- **多模式运行:** 支持单次执行、固定间隔循环或标准的 Cron 定时任务。
- **高度可定制:** 支持通过环境变量灵活调整测速参数。
- **轻量且兼容:** 基于 Alpine 镜像，体积小巧，支持 `amd64`, `arm64`, `arm/v7`, `386` 架构。
- **智能版本同步:** 镜像标签与上游工具同步。
- **健壮性:** 内置日志轮转、健康检查及错误退出机制。

## 🛠️ 项目性质

这是一个**个人实验性项目**，由 AI 编程助手 (Gemini) 生成和维护。

## 🚀 快速开始

### 1. 拉取镜像
```bash
docker pull ghcr.io/bigzhangbig/cfst-docker:latest
```

### 2. 准备配置 (.env)
```env
GIST_TOKEN=你的GitHub_Token
GIST_ID=你的Gist_ID
```

### 3. 选择运行模式

#### A. 单次模式 (One-shot)
运行完立即退出：
```bash
docker run --rm --env-file .env -v $(pwd)/data:/app/data ghcr.io/bigzhangbig/cfst-docker:latest
```

#### B. 循环模式 (Loop)
每隔一段时间执行一次（如每 1 小时）：
```bash
docker run -d --name cfst-loop --env-file .env --env LOOP_INTERVAL=3600 ghcr.io/bigzhangbig/cfst-docker:latest
```

#### C. 定时模式 (Cron)
使用标准 Cron 表达式（如每天凌晨 4 点）：
```bash
docker run -d --name cfst-cron --env-file .env --env CRON="0 4 * * *" ghcr.io/bigzhangbig/cfst-docker:latest
```

## ⚙️ 环境变量说明

| 变量 | 说明 | 默认值 |
| :--- | :--- | :--- |
| **调度参数** | | |
| `CRON` | Cron 表达式 (如 `*/30 * * * *`)。设置此变量将开启定时模式。 | 无 |
| `LOOP_INTERVAL` | 循环间隔秒数。若未设置 CRON 则检查此项开启循环模式。 | 无 |
| **核心测速参数** | | |
| `CF_N` | 延迟测速线程数 (`-n`) | `500` |
| `CF_DN` | 延迟测速后下载测速的数量 (`-dn`) | `20` |
| `CF_TL` | 平均延迟上限 (ms) (`-tl`) | `1000` |

<details>
<summary>👉 点击展开查看更多详细测速参数</summary>

| 变量 | 对应参数 | 说明 | 默认值 |
| :--- | :--- | :--- | :--- |
| `CF_T` | `-t` | 每个 IP 延迟测速次数 | `4` |
| `CF_DT` | `-dt` | 单个 IP 下载测速最长时间 (秒) | `10` |
| `CF_URL` | `-url` | 自定义测速地址 | 官方默认 |
| `CF_TP` | `-tp` | 指定测速端口 | `443` |
| **测速模式** | | | |
| `CF_HTTPING` | `-httping` | 是否切换为 HTTPing 模式 (`true`/`false`) | `false` |
| `CF_HTTPING_CODE` | `-httping-code` | HTTPing 时的有效状态码 | `200,301,302` |
| `CF_COLO` | `-cfcolo` | 匹配指定地区 (如 `HKG,SJC`) | 所有地区 |
| **过滤参数** | | | |
| `CF_TLL` | `-tll` | 平均延迟下限 (ms) | `0` |
| `CF_TLR` | `-tlr` | 丢包率上限 (0.00-1.00) | `1.00` |
| `CF_SL` | `-sl` | 下载速度下限 (MB/s) | `0.00` |
| **数据与显示** | | | |
| `CF_P` | `-p` | 显示结果数量 (0 为不显示) | `10` |
| `CF_F` | `-f` | 指定 IP 段数据文件路径 | `ip.txt` |
| `CF_IP` | `-ip` | 直接指定 IP/IP段 (逗号分隔) | 无 |
| `CF_DD` | `-dd` | 是否禁用下载测速 (`true`/`false`) | `false` |
| `CF_ALLIP` | `-allip` | 是否测速全部 IP (`true`/`false`) | `false` |

</details>

## 🤝 鸣谢

感谢 [XIU2/CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest) 提供的优秀原始工具。

---

*由 Gemini 驱动开发*
