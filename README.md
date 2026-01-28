# cfst-docker 🚀

`cfst-docker` 是一个旨在通过 Docker 自动化运行 [CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest) 的轻量化工具。它的设计初衷是“设定后便无需再管”，自动完成测速并将结果同步到云端。

---

## ✨ 核心特性

- **开箱即用:** 极其简单的配置，容器启动即开始测速。
- **自动化上传:** 自动将测速结果推送到你的 GitHub Gist，方便随时查看。
- **高度可定制:** 支持通过环境变量灵活调整测速参数（如测速数量、下载测试大小等）。
- **轻量且兼容:** 基于 Alpine 镜像，体积小巧，支持 `amd64` 和 `arm64` 架构。
- **透明日志:** 同时支持控制台与本地日志输出，包含清晰的运行摘要。

## 🛠️ 项目性质

这是一个**个人实验性项目**，具有以下特点：

- **AI 编程:** 本项目的所有代码均由 AI 编程助手 (Gemini) 生成和维护。
- **随缘更新:** 维护和功能迭代取决于个人时间和精力，不承诺固定的更新节奏。
- **极简主义:** 专注于核心功能的稳定与易用。

## 🚀 快速开始

> [!NOTE]
> 项目目前处于早期开发阶段，以下说明仅供参考。

### 1. 准备配置
创建一个 `.env` 文件并填入你的信息：

```env
GIST_TOKEN=你的GitHub_Token
GIST_ID=你的Gist_ID
```

### 2. 环境变量说明
你可以通过以下环境变量来自定义测速行为：

| 变量 | 说明 | 默认值 |
| :--- | :--- | :--- |
| `CF_N` | 延迟测速的 IP 数量 | `20` |
| `CF_T` | 每个 IP 的延迟测速次数 | `4` |
| `CF_DN` | 延迟测速后，进行下载测速的 IP 数量 | `10` |
| `CF_URL` | 自定义测速地址（用于下载测速） | 官方默认地址 |

### 3. 运行
使用 Docker 启动，建议挂载 `/app/data` 目录以持久化本地 `result.csv`：

```bash
docker run --rm \
  --env-file .env \
  -v $(pwd)/output:/app/data \
  cfst-test
```

## 🤝 鸣谢

感谢 [XIU2/CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest) 提供的优秀原始工具。

---

*由 Gemini 驱动开发*